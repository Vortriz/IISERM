import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import re
import string
from flask import Flask, request, jsonify
from gensim.models import Doc2Vec
from gensim.models.doc2vec import TaggedDocument
from joblib import dump, load
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from sklearn.decomposition import TruncatedSVD, LatentDirichletAllocation
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, roc_curve, auc
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import LabelEncoder
from tensorflow.keras.layers import Dense, LSTM, Embedding, Bidirectional, Dropout
from keras.models import Sequential, save_model, load_model
from tensorflow.keras.preprocessing.sequence import pad_sequences
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.regularizers import l2

def preprocess_data(df):
    df['type'] = df['type'].apply(lambda x: 1 if x == 'question' else 0)

    # Define a function to clean the text
    def clean_text(text):
        text = re.sub(r'\d+', '', text)  # remove digits
        text = text.translate(str.maketrans('', '', string.punctuation.replace('?', '')))  # remove punctuation except '?'
        text = text.lower()  # convert to lowercase
        text = re.sub(r'\s+', ' ', text).strip()  # remove extra whitespaces

        # filter out the stopwords except for interrogative words
        stop_words = set(stopwords.words('english')) - set(['what', 'where', 'when', 'why', 'how', 'which', 'who'])
        tokens = word_tokenize(text)
        filtered_text = [word for word in tokens if word not in stop_words]
        return ' '.join(filtered_text)

    # Apply the function to the text column
    df['text'] = df['text'].apply(clean_text)

    return df

# Apply TF-IDF vectorization
def apply_tfidf(df):
    return TfidfVectorizer().fit_transform(df['text'])

# Apply LSA on TF-IDF vectors
def apply_lsa(X_tfidf):
    return TruncatedSVD(n_components=100).fit_transform(X_tfidf)

# Apply LDA on TF-IDF vectors
def apply_lda(X_tfidf):
    return LatentDirichletAllocation(n_components=10, n_jobs = -1).fit_transform(X_tfidf)

# Generate glove vectors
def vectorize_glove(df):
    embeddings_index = {}

    with open('glove.6B.100d.txt', 'r', encoding='utf-8') as f:
        for line in f:
            values = line.split()
            word = values[0]
            coefs = np.asarray(values[1:], dtype='float32')
            embeddings_index[word] = coefs

    def sentence_vector(sentence):
        words = sentence.split()
        word_vectors = [embeddings_index.get(word, np.zeros((100,))) for word in words]
        return np.mean(word_vectors, axis=0)

    return df['text'].apply(sentence_vector)

# Generate doc2vec vectors
def vectorize_doc2vec(df):
    # Prepare the data for Doc2Vec
    documents = [TaggedDocument(doc, [i]) for i, doc in enumerate(df['text'].apply(lambda x: x.split(' ')))]

    # Train a Doc2Vec model
    model = Doc2Vec(documents, vector_size=100, window=2, min_count=1)

    # Generate sentence vectors
    return df['text'].apply(lambda x: model.infer_vector(x.split(' ')))

def prepare_lstm_data(df):
    # Tokenize and pad sequences
    tokenizer = Tokenizer()
    tokenizer.fit_on_texts(df['text'])
    sequences = tokenizer.texts_to_sequences(df['text'])
    data_lstm = pad_sequences(sequences, maxlen=100)

    # Prepare the labels
    le = LabelEncoder()
    labels_lstm = le.fit_transform(df['type'])

    return data_lstm, labels_lstm, tokenizer

# df = pd.read_csv('data.csv', header=None, names=['id','text', 'type'], skiprows=1)
# df.drop(labels='id', axis=1, inplace=True)

# df = preprocess_data(df)

# X_train_rf, X_test_rf, y_train_rf, y_test_rf = train_test_split(df['text'], df['type'], test_size=0.2, random_state=42)

# # Define a pipeline
# pipeline = Pipeline([
#     ('tfidf', TfidfVectorizer()),
#     ('clf', RandomForestClassifier(random_state=42, n_jobs=-1))
# ])

# # Now you can fit and predict using this pipeline as you would with a single estimator
# pipeline.fit(X_train_rf, y_train_rf)
# dump(pipeline, 'model_rf.pkl') 

app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json(force=True)
    model_type = data['model_type']
    input_data = np.array(data['input_data'])

    df = pd.DataFrame({'text': input_data, 'type': [0]*len(input_data)})
    df = preprocess_data(df)

    print(df)

    model_dict = {
        'lr': 'model_lr.joblib',
        'rf': 'model_rf.joblib',
        'lstm': 'model_lstm.keras',
        'bilstm': 'model_bilstm.h5'
    }

    model_file = model_dict.get(model_type)
    if model_file is None:
        return jsonify({'error': 'Invalid model type'})

    if model_type == 'lr':
        model = load(model_file)
        df['text'] = vectorize_doc2vec(df)
        # print(df['text'].to_list())
        prediction = model.predict(df['text'].to_list())
    elif model_type == 'rf':
        pipeline = load('model_rf.pkl')
        # predictions = pipeline.predict(X_test_rf)
        # model = load(model_file)
        # X_tfidf = apply_tfidf(df)
        prediction = pipeline.predict(input_data)
    else:
        model = load_model(model_file)
        data_lstm, labels_lstm, tokenizer = prepare_lstm_data(df)
        prediction = (np.ndarray.flatten(model.predict(data_lstm)) > 0.5).astype(int)

    # print(df['text'])

    return jsonify({'prediction': prediction.tolist()})

@app.route('/train', methods=['POST'])
def train():
    data = request.get_json(force=True)
    model_type = data['model_type']
    X_train = np.array(data['X_train'])
    y_train = np.array(data['y_train'])

    df = pd.DataFrame({'text': X_train, 'type': y_train})
    df = preprocess_data(df)

    model_dict = {
        'lr': train_lr,
        'rf': train_rf,
        'lstm': train_lstm,
        'bi_lstm': train_bilstm
    }

    model = model_dict.get(model_type)

    if model is None:
        return jsonify({'error': 'Invalid model type'})
    
    trained_model, X_train, X_test, y_train, y_test = model(df)

    return jsonify({'message': 'Model trained and saved. Now you can make predictions.'})

if __name__ == '__main__':
    app.run(port=2745, debug=True)