import marimo

__generated_with = "0.11.6"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell
def _(mo):
    mo.md(r"""### Q1. Simulate list datatype as a stack and queue""")
    return


@app.cell
def _():
    stack = []

    stack.append(1)
    stack.append(2)
    stack.append(3)

    print("Stack after pushing elements:", stack)

    print("Popped element:", stack.pop())
    print("Popped element:", stack.pop())

    print("Stack after popping elements:", stack)
    return (stack,)


@app.cell
def _():
    queue = []

    queue.append(1)
    queue.append(2)
    queue.append(3)

    print("Queue after enqueuing elements:", queue)

    print("Dequeued element:", queue.pop(0))
    print("Dequeued element:", queue.pop(0))

    print("Queue after dequeuing elements:", queue)
    return (queue,)


@app.cell
def _(mo):
    mo.md(r"""### Q2. Write a matrix as a list of lists. Users should input number of rows, columns followed by entries of matrix. The output should be a matrix. """)
    return


@app.cell
def _():
    print("We are going to construct a matrix")
    rows = int(input("Enter the number of rows you want: "))
    cols = int(input("Enter the number of columns you want: "))

    matrix = []

    print("Now you will enter the elements of the matrix (row-wise)")

    for r in range(rows) :
        row = []
        for c in range(cols) :
            elem = input(f"Enter ({r+1},{c+1}) element: ")
            row.append(elem)
        matrix.append(row)

    print("\nMatrix constructed")

    for row in matrix :
        print(row)
    return c, cols, elem, matrix, r, row, rows


@app.cell
def _(mo):
    mo.md(r"""### Q3. Input a line of a sequence using input method and then combine these into a sequence. Followed by finding the number of unique characters in the string and find their occurrence. The input sequence could be protein/DNA.""")
    return


@app.cell
def _():
    print("We are going to construct a sequence line-by-line\nKeep the entry blank to stop\n")

    seq = ""
    part = "init"

    while part :
        part = input("Enter a sequence: ")
        seq += part

    print(f"\nThe sequence is:\n{seq}\n")

    unique_elems = set(seq)
    print(f"There are {len(unique_elems)} unique elements in the sequence. They are:\n{unique_elems}\n")

    for ue in unique_elems :
        print(f"'{ue}' occurs {seq.count(ue)} times")
    return part, seq, ue, unique_elems


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
