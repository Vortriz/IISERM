# Few things about this code:
# 1. I have used glove for word embedding and doc2vec for sentence embedding. I have also
#    used TF-IDF, LSA, and LDA for feature extraction.
# 2. I have trained Logistic Regression, Random Forest, LSTM, and Bi-LSTM models.
#    Bi LSTM Model's save functionality does not work properly (refer to this issue
#    https://github.com/keras-team/keras/issues/18913). So it will have to be retrained
#    every time the server is restarted.  Also, LSTM and Bi-LSTM models are constructed
#    using keras which does not have pipeline functionality.
# 3. I have used Flask to create a REST API for training and prediction both.


# Importing all the necessary modules
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import re
import string
import tensorflow as tf
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

# Some variables that we will be using while training models
random_state = 42
test_size = 0.2
epochs = 1

# Function to preprocess the data
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


# Data preparation for LSTM and Bi LSTM
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


# Logistic Regression
def train_lr(df):
    X_train_lr, X_test_lr, y_train_lr, y_test_lr = train_test_split(df['text'], df['type'], test_size=test_size, random_state=random_state)

    # Define a pipeline
    pipeline_lr = Pipeline([
        ('tfidf', TfidfVectorizer()),
        ('clf', LogisticRegression(penalty='l2', random_state=random_state, n_jobs=-1))
    ])

    # Now you can fit and predict using this pipeline as you would with a single estimator
    clf_lr = pipeline_lr.fit(X_train_lr, y_train_lr)
    dump(pipeline_lr, 'model_lr.pkl')

    return clf_lr, X_train_lr, X_test_lr, y_train_lr, y_test_lr


# Random Forests
def train_rf(df):
    X_train_rf, X_test_rf, y_train_rf, y_test_rf = train_test_split(df['text'], df['type'], test_size=test_size, random_state=random_state)

    # Define a pipeline
    pipeline_rf = Pipeline([
        ('tfidf', TfidfVectorizer()),
        ('clf', RandomForestClassifier(random_state=random_state, n_jobs=-1))
    ])

    # Now you can fit and predict using this pipeline as you would with a single estimator
    clf_rf = pipeline_rf.fit(X_train_rf, y_train_rf)
    dump(pipeline_rf, 'model_rf.pkl')

    return clf_rf, X_train_rf, X_test_rf, y_train_rf, y_test_rf


# LSTM
def train_lstm(df):
    data_lstm, labels_lstm, tokenizer = prepare_lstm_data(df)
    X_train_lstm, X_test_lstm, y_train_lstm, y_test_lstm = train_test_split(data_lstm, labels_lstm, test_size=test_size, random_state=random_state)

    # Build the LSTM model
    model_lstm = Sequential()
    model_lstm.add(Embedding(len(tokenizer.word_index) + 1, 100, trainable=False))
    model_lstm.add(LSTM(128))
    model_lstm.add(Dense(1, activation='sigmoid'))

    model_lstm.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

    # Train the model
    history_lstm = model_lstm.fit(X_train_lstm, y_train_lstm, validation_data=(X_test_lstm, y_test_lstm), epochs=epochs, batch_size=128)
    model_lstm.save('model_lstm.keras')

    return model_lstm, history_lstm, X_train_lstm, X_test_lstm, y_train_lstm, y_test_lstm


# Bidirectional LSTM
def train_bilstm(df):
    data_bilstm, labels_bilstm, tokenizer = prepare_lstm_data(df)
    X_train_bilstm, X_test_bilstm, y_train_bilstm, y_test_bilstm = train_test_split(data_bilstm, labels_bilstm, test_size=test_size, random_state=random_state)

    # Build the Bidirectional LSTM model with L2 regularization
    model_bilstm = Sequential()
    model_bilstm.add(Embedding(input_dim=5000, output_dim=64))
    model_bilstm.add(Bidirectional(LSTM(64, return_sequences=True, kernel_regularizer=l2(0.01), recurrent_regularizer=l2(0.01), bias_regularizer=l2(0.01))))
    model_bilstm.add(Dropout(0.5))
    model_bilstm.add(Bidirectional(LSTM(64, kernel_regularizer=l2(0.01), recurrent_regularizer=l2(0.01), bias_regularizer=l2(0.01))))
    model_bilstm.add(Dropout(0.5))
    model_bilstm.add(Dense(1, activation='sigmoid'))

    model_bilstm.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

    # Train the model
    history_bilstm = model_bilstm.fit(X_train_bilstm, y_train_bilstm, validation_data=(X_test_bilstm, y_test_bilstm), epochs=epochs, batch_size=128)
    # model_bilstm.save('model_bilstm.keras')

    return model_bilstm, history_bilstm, X_train_bilstm, X_test_bilstm, y_train_bilstm, y_test_bilstm

def plot_roc_curve(clf_lr, clf_rf, model_lstm, model_bilstm, X_test_lr, X_test_rf, X_test_lstm, X_test_bilstm, y_test_lr, y_test_rf, y_test_lstm, y_test_bilstm):
    # Get the prediction probabilities
    lr_probs = clf_lr.predict_proba(X_test_lr)[:, 1]
    rf_probs = clf_rf.predict_proba(X_test_rf)[:, 1]
    lstm_probs = model_lstm.predict(X_test_lstm).ravel()
    bilstm_probs = model_bilstm.predict(X_test_bilstm).ravel()

    # Compute the ROC curves
    lr_fpr, lr_tpr, _ = roc_curve(y_test_lr, lr_probs)
    rf_fpr, rf_tpr, _ = roc_curve(y_test_rf, rf_probs)
    lstm_fpr, lstm_tpr, _ = roc_curve(y_test_lstm, lstm_probs)
    bilstm_fpr, bilstm_tpr, _ = roc_curve(y_test_bilstm, bilstm_probs)

    # Plot the ROC curves
    plt.figure(figsize=(10, 8))
    plt.plot(lr_fpr, lr_tpr, label='Logistic Regression (AUC = %0.2f)' % auc(lr_fpr, lr_tpr))
    plt.plot(rf_fpr, rf_tpr, label='Random Forest (AUC = %0.2f)' % auc(rf_fpr, rf_tpr))
    plt.plot(lstm_fpr, lstm_tpr, label='LSTM (AUC = %0.2f)' % auc(lstm_fpr, lstm_tpr))
    plt.plot(bilstm_fpr, bilstm_tpr, label='Bi-LSTM (AUC = %0.2f)' % auc(bilstm_fpr, bilstm_tpr))
    plt.plot([0, 1], [0, 1], 'k--')
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('ROC')
    plt.legend(loc='lower right')
    plt.show()

    return

def plot_metrics(history_lstm, history_bilstm):
    plt.figure(figsize=(12,6))

    # Plotting accuracy
    plt.subplot(1, 2, 1)
    # plt.plot(clf_lr.history['accuracy'], label='Model 1')
    # plt.plot(clf_rf.history['accuracy'], label='Model 2')
    plt.plot(history_lstm.history['accuracy'], label='Model LSTM')
    plt.plot(history_bilstm.history['accuracy'], label='Model Bi LSTM')
    plt.title('Accuracy')
    plt.xlabel('Epochs')
    plt.ylabel('Accuracy')
    plt.legend()

    # Plotting loss
    plt.subplot(1, 2, 2)
    # plt.plot(clf_lr.history['loss'], label='Model 1')
    # plt.plot(clf_rf.history['loss'], label='Model 2')
    plt.plot(history_lstm.history['loss'], label='Model LSTM')
    plt.plot(history_bilstm.history['loss'], label='Model Bi LSTM')
    plt.title('Loss')
    plt.xlabel('Epochs')
    plt.ylabel('Loss')
    plt.legend()

    plt.tight_layout()
    plt.show()

    return

print("Reading data...")
df = pd.read_csv('data.csv', header=None, names=['id','text', 'type'], skiprows=1) # The data file is named 'data.csv'
df.drop(labels='id', axis=1, inplace=True)

print("Preprocessing data...")
df = preprocess_data(df)

# print(apply_tfidf(df))                               # uncomment this line to test TF-IDF vectorization
# print(apply_lsa(apply_tfidf(df)))                        # uncomment this line to test LSA
# print(apply_lda(apply_tfidf(df)))                        # uncomment this line to test LDA
# print(vectorize_glove(df))                  # uncomment this line to test GloVe vectorization
# print(vectorize_doc2vec(df))              # uncomment this line to test Doc2Vec vectorization
# print(prepare_lstm_data(df)) # uncomment this line to test preprocessing for LSTM and Bi-LSTM

print("Training Logistic Regression model...")
# clf_lr, X_train_lr, X_test_lr, y_train_lr, y_test_lr = train_lr(df)

# uncomment the following lines to get metrics of Logistic Regression model
# pipeline_lr = load('model_lr.pkl')
# y_pred_lr = pipeline_lr.predict(X_test_lr)
# print("Logistic Regression:\n", classification_report(y_test_lr, y_pred_lr))

print("Training Random Forest model...")
# clf_rf, X_train_rf, X_test_rf, y_train_rf, y_test_rf = train_rf(df)

# uncomment the following lines to get metrics of Random Forest model
# pipeline_rf = load('model_rf.pkl')
# y_pred_rf = pipeline_rf.predict(X_test_rf)
# print(classification_report(y_test_rf, y_pred_rf))

print("Training LSTM model...")
# model_lstm, history_lstm, X_train_lstm, X_test_lstm, y_train_lstm, y_test_lstm = train_lstm(df)

# uncomment the following lines to get metrics of LSTM model
# model_lstm = load_model('model_lstm.keras')
# loss_lstm, accuracy_lstm = model_lstm.evaluate(X_test_lstm, y_test_lstm)
# print('Test Loss: {}'.format(loss_lstm))
# print('Test Accuracy: {}'.format(accuracy_lstm))

print("Training Bi-LSTM model...")
# model_bilstm, history_bilstm, X_train_bilstm, X_test_bilstm, y_train_bilstm, y_test_bilstm = train_bilstm(df)

# uncomment the following lines to get metrics of Bi-LSTM model
# loss_bilstm, accuracy_bilstm = model_bilstm.evaluate(X_test_bilstm, y_test_bilstm)
# print('Test Loss: {}'.format(loss_bilstm))
# print('Test Accuracy: {}'.format(accuracy_bilstm))

print("Plotting metrics...")
# plot_roc_curve(clf_lr, clf_rf, model_lstm, model_bilstm, X_test_lr, X_test_rf, X_test_lstm, X_test_bilstm, y_test_lr, y_test_rf, y_test_lstm, y_test_bilstm)

# plot_metrics(history_lstm, history_bilstm)


# Flask app code begins here
app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json(force=True)
    model_type = data['model_type']
    input_data = np.array(data['input_data'])

    df = pd.DataFrame({'text': input_data, 'type': [0]*len(input_data)})
    df = preprocess_data(df)

    # print(df)

    model_dict = {
        'lr': 'model_lr.pkl',
        'rf': 'model_rf.pkl',
        'lstm': 'model_lstm.keras',
        # 'bilstm': 'model_bilstm.h5'
    }

    model_file = model_dict.get(model_type)
    if model_file is None:
        return jsonify({'error': 'Invalid model type'})

    if model_type == 'lr':
        pipeline_lr = load(model_file)
        prediction = pipeline_lr.predict(input_data)
    elif model_type == 'rf':
        pipeline_rf = load(model_file)
        prediction = pipeline_rf.predict(input_data)
    elif model_type == 'lstm':
        model_lstm = load_model(model_file)
        data_lstm, labels_lstm, tokenizer = prepare_lstm_data(df)
        prediction = (np.ndarray.flatten(model_lstm.predict(data_lstm)) > 0.5).astype(int)
    elif model_type == 'bilstm':
        # model = load_model(model_file)
        data_bilstm, labels_bilstm, tokenizer = prepare_lstm_data(df)
        prediction = (np.ndarray.flatten(model_bilstm.predict(data_bilstm)) > 0.5).astype(int)

    # print(df['text'])

    return jsonify({'prediction': prediction.tolist()})

@app.route('/train', methods=['POST'])
def train():
    # provide model type (lr, rf, lstm, bilstm), X_train, and y_train
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
        'bilstm': train_bilstm
    }

    model = model_dict.get(model_type)
    if model is None:
        return jsonify({'error': 'Invalid model type'})
    
    if model_type == 'lr':
        clf_lr, X_train_lr, X_test_lr, y_train_lr, y_test_lr = model(df)
    elif model_type == 'rf':
        clf_rf, X_train_rf, X_test_rf, y_train_rf, y_test_rf  = model(df)
    elif model_type == 'lstm':
        model_lstm, history_lstm, X_train_lstm, X_test_lstm, y_train_lstm, y_test_lstm = model(df)
    elif model_type == 'bilstm':
        model_bilstm, history_bilstm, X_train_bilstm, X_test_bilstm, y_train_bilstm, y_test_bilstm = model(df)

    return jsonify({'message': 'Model trained and saved. Now you can make predictions.'})

if __name__ == '__main__':
    app.run(port=2745, debug=True)