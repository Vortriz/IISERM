import marimo

__generated_with = "0.11.10"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell
def _(mo):
    mo.md(r"""### Write a program to store username and password credentials (in dict). Check the password whether is consists of at least one upper case character, one lower case character, one number, symbol (@,-,=) and at least 10 character long. The first time username should be able to create password. For the second time the username should be promoted to change the password and make sure it is not the same password as last three times. (Space not allowed within password).""")
    return


@app.cell
def _():
    creds = dict()

    # ASCII codes
    space = 32
    upper = list(range(65, 91))
    lower = list(range(97, 123))
    number = list(range(48, 58))
    symbol = [64, 45, 61]

    req_len = 10
    return creds, lower, number, req_len, space, symbol, upper


@app.cell
def _(creds, lower, number, req_len, space, symbol, upper):
    username = input("Enter username: ")

    if username not in creds :
        print("New username! Set a password.\n")
        creds[username] = []
    else :
        print("Change password. Should not be same as previous 3 passwords!\n")

    print("It should consist of at least one upper case character, one lower case character, one number, symbol (@,-,=) and be at least 10 character long\n")

    password = input("Enter password: ")
    password_set = set(password)
    validity = False

    if len(password) < req_len :
        print("Password must be at least 10 characters long!")
    elif not any(ord(char) in upper for char in password_set) :
        print("Password must contain at least one uppercase letter!")
    elif not any(ord(char) in lower for char in password_set) :
        print("Password must contain at least one lowercase letter!")
    elif not any(ord(char) in number for char in password_set) :
        print("Password must contain at least one number!")
    elif not any(ord(char) in symbol for char in password_set) :
        print("Password must contain at least one symbol (@,-,=)!")
    elif any(ord(char) == space for char in password_set) :
        print("Password must not contain any spaces!")
    else :
        validity = True

    if len(creds[username]) > 3 :
        print("DEBUG: removing oldest password")
        creds[username] = creds[username][1:]

    # print("DEBUG: ", creds[username])

    if validity and password not in creds[username] :
        creds[username].append(password)
        print("Password set successfully!")
    elif password in creds[username] :
        print("Password cannot be same as previous 3 passwords!")
    else :
        print("Password not set!")
    return password, password_set, username, validity


@app.cell
def _():
    ### Read the fasta_file.txt as has been shared before. Read the file to compute composition of mononucleotide, dinucleotide, tri-nucleotide and store these information in a dict() data structure, which can be used to extract the relevant information for each sequence. Find ORF for each sequence.
    return


@app.cell
def _():
    with open("fasta_file.txt", "r") as f :
        lines = f.read().splitlines()

    sequences = dict()

    for line in lines :
        if line.startswith(">") :
            seqid = line[1:15]
            sequences[seqid] = ""
        else :
            sequences[seqid] += line

    composition = dict()

    start_codons = ["ATG", "GTG"]
    stop_codons = ["TAG", "TAA", "TGA"]

    for seqid in sequences :
        seq = sequences[seqid]
        seqlen = len(seq)
        composition[seqid] = dict()
    
        for mono in set(seq) :
            composition[seqid][mono] = sequences[seqid].count(mono)
        for di in set([seq[i:i+2] for i in range(len(seq)-1)]) :
            composition[seqid][di] = sequences[seqid].count(di)
        for tri in set([seq[i:i+3] for i in range(len(seq)-2)]) :
            composition[seqid][tri] = sequences[seqid].count(tri)

        print(f"\n\n{seqid}:")
        print(f"Composition: {composition[seqid]}")

        for frame in [0, 1, 2] :
            i = frame
    
            for i in range(frame, seqlen-2, 3) :
                start_codon = seq[i:i+3]
    
                if start_codon in start_codons :
    
                    for j in range(i, seqlen-1, 3) :
                        stop_codon = seq[j:j+3]
    
                        if stop_codon in stop_codons :
                            orf = seq[i:j+3+1]
                            print(f"ORF found in frame {frame+1} from {i+1} to {j+3}:")
                            print(orf)
                            i = j
                            break
    return (
        composition,
        di,
        f,
        frame,
        i,
        j,
        line,
        lines,
        mono,
        orf,
        seq,
        seqid,
        seqlen,
        sequences,
        start_codon,
        start_codons,
        stop_codon,
        stop_codons,
        tri,
    )


if __name__ == "__main__":
    app.run()
