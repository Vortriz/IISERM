import marimo

__generated_with = "0.12.0"
app = marimo.App(width="medium")


@app.cell
def _(mo):
    mo.md(
        r"""
        # WS 10 01-04-25

        > Name: Rishi Vora
        > 
        > Roll No: MS21113
        """
    )
    return


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell
def _(mo):
    mo.md(
        r"""
        ## Write a class 'Sequence', which will take DNA/protein sequence as input:

        - Attributes: 'sequence', 'length of sequence', 'label'
        - Method to find whether input sequence is DNA/protein (based on type of character A/T/G/C belongs to DNA sequence, otherwise it is protein sequence.). Update attribute label as DNA/Protein
        - Method to compute Composition of sequence (dimer/trimer etc).
        """
    )
    return


@app.cell
def _():
    class Sequence:
        def __init__(self, seq):
            self.seq = seq
            self.len = self.__seqlen__()
            self.label = self.__label__()

        def __seqlen__(self):
            return len(self.seq)

        def __label__(self):
            for i in self.seq:
                if i not in 'ATGC':
                    return "Protein"
                    break
            else:
                return "DNA"

        def composition(self, N) :
            """
            Calculate the composition of the sequence in terms of N-mers.
            """

            comp = {}
            for n in set([self.seq[i:i+N] for i in range(self.len - (N-1))]) :
                comp[n] = self.seq.count(n)

            return comp
    return (Sequence,)


@app.cell
def _(Sequence):
    seq = Sequence('ATGCATGAACA')
    return (seq,)


@app.cell
def _(seq):
    seq.seq
    return


@app.cell
def _(seq):
    seq.len
    return


@app.cell
def _(seq):
    seq.label
    return


@app.cell
def _(seq):
    seq.composition(2)
    return


if __name__ == "__main__":
    app.run()
