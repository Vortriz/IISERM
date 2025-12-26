import marimo

__generated_with = "0.18.0"
app = marimo.App(width="medium")

with app.setup:
    # Initialization code that runs before all other cells
    import marimo as mo
    import numpy as np


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q1
    """)
    return


@app.cell
def _():
    x = np.array([[1, 2], [3, 4]])
    return (x,)


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    ## 1) Row swapping
    """)
    return


@app.function
def row_swap(matrix, row1, row2):
    """Swap two rows of a matrix."""
    matrix[[row1, row2]] = matrix[[row2, row1]]
    return matrix


@app.cell
def _(x):
    row_swap(x, 0, 1)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    ## b) Row scaling
    """)
    return


@app.function
def row_scale(matrix, row, scale):
    """Scale a row of a matrix by a given factor."""
    matrix[row] = matrix[row] * scale
    return matrix


@app.cell
def _(x):
    row_scale(x, 0, 5)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    ## c) Row addition
    """)
    return


@app.function
def row_add(matrix, row1, row2, scale=1):
    """Add a scaled version of one row to another row."""
    matrix[row1] = matrix[row1] + matrix[row2] * scale
    return matrix


@app.cell
def _(x):
    row_add(x, 1, 0, 2)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q2
    """)
    return


@app.cell
def _():
    system1 = np.array(
        [[4, -1, 2, 3, 20], [0, -2, 7, -4, -7], [0, 0, 6, 5, 4], [0, 0, 0, 3, 6]]
    )
    system2 = np.array(
        [[2, 0, 0, 0, 6], [-1, 4, 0, 0, 5], [3, -2, -1, 0, 4], [1, -2, 6, 3, 2]]
    )
    system3 = np.array(
        [
            [2, 5, 0, -4, 6],
            [-4, -4, -3, 7, 36],
            [-6, -3, -7, -6, 35],
            [-1, 2, -6, 5, 63],
        ]
    )
    return system1, system2, system3


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    ## a) Row reduction
    """)
    return


@app.function
def row_reduce(matrix):
    """Perform row reduction on a matrix."""
    matrix = matrix.astype(float)  # Ensure we are working with floats
    rows, cols = matrix.shape

    for r in range(rows):
        # Remove 0 from pivots
        if matrix[r, r] == 0:
            for r2 in range(r + 1, rows):
                if matrix[r2, r] != 0:
                    row_swap(matrix, r, r2)
                    break
        # Convert to upper triangular form
        for r2 in range(r + 1, rows):
            row_add(matrix, r2, r, -matrix[r2, r] / matrix[r, r])
    return matrix


@app.cell
def _(system3):
    row_reduce(system3)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    ## b) Back substitution
    """)
    return


@app.function
def back_substitution(matrix):
    """Perform back substitution on a row-reduced matrix."""
    rows, cols = matrix.shape
    solution = np.zeros(rows)

    for r in range(rows - 1, -1, -1):
        solution[r] = (
            matrix[r, -1] - np.sum(matrix[r, r + 1 : cols - 1] * solution[r + 1 :])
        ) / matrix[r, r]

    return solution


@app.cell
def _(system1):
    back_substitution(system1)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    ## c) Forward substitution
    """)
    return


@app.function
def forward_substitution(matrix):
    """Perform forward substitution on a row-reduced matrix."""
    rows, cols = matrix.shape
    solution = np.zeros(rows)

    for r in range(rows):
        solution[r] = (matrix[r, -1] - np.sum(matrix[r, :r] * solution[:r])) / matrix[
            r, r
        ]

    return solution


@app.cell
def _(system2):
    forward_substitution(system2)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q3
    """)
    return


@app.function
def solve_linear_system(A, b):
    return back_substitution(row_reduce(np.column_stack((A, b))))


@app.cell
def _():
    solve_linear_system(
        np.array([[2, 5, 0, -4], [-4, -4, -3, 7], [-6, -3, -7, -6], [-1, 2, -6, 5]]),
        np.array([6, 36, 35, 63]),
    )
    return


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
