import marimo

__generated_with = "0.11.6"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell
def _(mo):
    mo.md(r"""## Q1. Write a program to check matching username and password. Use "input" function. Loop it for fixed iteration or infinite iteration till password is correct.""")
    return


@app.cell
def _():
    username = "admin"
    password = "somepassword"

    input_username = input("Enter username: ")

    if input_username != username :
        print("Invalid username. Exiting...")
        exit()

    tries = 3

    while tries:
        input_password = input("Enter password: ")

        if input_password != password :
            tries -= 1
            print(f"Incorrect password. {tries} tries remaining...")
        else :
            print("Correct username and password combination!")
            break

    if tries == 0 :
        print("You have exceeded the maximum number of tries. Exiting...")
    return input_password, input_username, password, tries, username


@app.cell
def _(mo):
    mo.md(r"""## Q2. Write a program to find DNA composition, where sequences is asked by the user. """)
    return


@app.cell
def _():
    seq1 = input("Enter sequence: ")

    counts = {"A": 0, "T": 0, "G": 0, "C": 0}

    for ch1 in seq1 :
        if ch1 not in counts.keys() :
            print("Invalid sequence (contains characters apart from ATGC). Exiting...")
            exit()
        else :
            counts[ch1] += 1

    print(counts)
    return ch1, counts, seq1


@app.cell
def _(mo):
    mo.md("""## Q3. Write a program to find ORF for a given sequence.""")
    return


@app.cell
def _():
    seq2 = input("Enter sequence: ")

    for ch2 in seq2 :
        if ch2 not in ["A", "T", "G", "C"] :
            print("Invalid sequence (contains characters apart from ATGC). Exiting...")

    start_codons = ["ATG", "GTG"]
    stop_codons = ["TAG", "TAA", "TGA"]

    seqlen = len(seq2)

    for frame in [0, 1, 2] :
        i = frame

        for i in range(frame, seqlen-2, 3) :
            start_codon = seq2[i:i+3]

            if start_codon in start_codons :

                for j in range(i, seqlen-1, 3) :
                    stop_codon = seq2[j:j+3]

                    if stop_codon in stop_codons :
                        orf = seq2[i:j+3+1]
                        print(f"ORF found in frame {frame+1} from {i+1} to {j+3}:")
                        print(orf)
                        i = j
                        break
    return (
        ch2,
        frame,
        i,
        j,
        orf,
        seq2,
        seqlen,
        start_codon,
        start_codons,
        stop_codon,
        stop_codons,
    )


if __name__ == "__main__":
    app.run()
