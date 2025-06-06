import marimo

__generated_with = "0.11.10"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell
def _(mo):
    mo.md(
        r"""
        ### Write a program to store username and password credentials (in dict). Check the password whether is consists of at least one upper case character, one lower case character, one number, symbol (@,-,=) and at least 10 character long. The first time username should be able to create password. For the second time the username should be promoted to change the password and make sure it is not the same password as last three times. (Space not allowed within password).

        > All checks are done using functions now
        """
    )
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
def _():
    def check_len(password, req_len) :
        if len(password) < req_len :
            print("Password must be at least 10 characters long!")
            return False
        else :
            return True

    def check_upper(password, upper) :
        if not any(ord(char) in upper for char in password) :
            print("Password must contain at least one uppercase letter!")
            return False
        else :
            return True

    def check_lower(password, lower) :
        if not any(ord(char) in lower for char in password) :
            print("Password must contain at least one lowercase letter!")
            return False
        else :
            return True

    def check_number(password, number) :
        if not any(ord(char) in number for char in password) :
            print("Password must contain at least one number!")
            return False
        else :
            return True

    def check_symbol(password, symbol) :
        if not any(ord(char) in symbol for char in password) :
            print("Password must contain at least one symbol (@,-,=)!")
            return False
        else :
            return True

    def check_space(password, space) :
        if any(ord(char) == space for char in password) :
            print("Password must not contain any spaces!")
            return False
        else :
            return True

    return (
        check_len,
        check_lower,
        check_number,
        check_space,
        check_symbol,
        check_upper,
    )


@app.cell
def _(
    check_len,
    check_lower,
    check_number,
    check_space,
    check_symbol,
    check_upper,
    creds,
    lower,
    number,
    space,
    symbol,
    upper,
):
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

    if check_len(password, 10) and check_upper(password, upper) and check_lower(password, lower) and check_number(password, number) and check_symbol(password, symbol) and check_space(password, space) :
        validity = True

    if len(creds[username]) > 3 :
        creds[username] = creds[username][1:]

    if validity and password not in creds[username] :
        creds[username].append(password)
        print("Password set successfully!")
    elif password in creds[username] :
        print("Password cannot be same as previous 3 passwords!")
    else :
        print("Password not set!")
    return password, password_set, username, validity


@app.cell
def _(mo):
    mo.md(
        """
        ### Read the fasta_file.txt as has been shared before. Read the file to compute composition of mononucleotide, dinucleotide, tri-nucleotide and store these information in a dict() data structure, which can be used to extract the relevant information for each sequence. Find ORF for each sequence.

        > `count` and `orf` functions implemented
        """
    )
    return


@app.cell
def _():
    def count(sequences, seqid, composition, N) :
        seq = sequences[seqid]
    
        for n in set([seq[i:i+N] for i in range(len(seq)-(N-1))]) :
            composition[seqid][n] = sequences[seqid].count(n)

        return composition

    def orf(seq) :
        seqlen = len(seq)

        start_codons = ["ATG", "GTG"]
        stop_codons = ["TAG", "TAA", "TGA"]
    
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
    return count, orf


@app.cell
def _(count, orf):
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

    for seqid in sequences :
        composition[seqid] = dict()

        composition = count(sequences, seqid, composition, 1)
        composition = count(sequences, seqid, composition, 2)
        composition = count(sequences, seqid, composition, 3)

        print(f"\n\n{seqid}:")
        print(f"Composition: {composition[seqid]}")

        orf(sequences[seqid])
    return composition, f, line, lines, seqid, sequences


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
