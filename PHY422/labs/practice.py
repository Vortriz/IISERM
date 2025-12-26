import marimo

__generated_with = "0.17.7"
app = marimo.App(width="medium")

with app.setup:
    # Initialization code that runs before all other cells
    import marimo as mo

    import numpy as np
    from lab3_4 import solve_linear_system


@app.function
def row_swap(matrix, row1, row2):
    matrix[[row1, row2]] = matrix[[row2, row1]]


@app.function
def row_add(matrix, row1, row2, scale=1):
    matrix[row1] = matrix[row1] + matrix[row2] * scale


@app.function
def upper_triangular(A, b):
    A, b = A.copy().astype(float), b.copy().astype(float)
    n = A.shape[0]

    for i in range(n):
        # remove 0 from pivot
        if A[i][i] == 0 and i != n-1:
            for j in range(i+1, n):
                if A[j][i] != 0:
                    row_swap(A, i, j)
                    row_swap(b, i, j)
                    print("swapped", i, j)

        # make remaining column 0
        for k in range(i+1, n):
            factor = -A[k, i]/A[i,i]
            row_add(A, k, i, factor)
            row_add(b, k, i, factor)

    return A, b


@app.function
def back_substitution(A, b):
    n = len(b)
    sol = np.zeros(n)

    for k in range(n-1, -1, -1):
        sol[k] = (b[k] - np.sum(A[k,k+1:] * sol[k+1:])) / A[k,k]

    return sol


@app.cell
def _():
    A1 = np.array(
        [
            [2, 5, 0, -4],
            [-4, -4, -3, 7],
            [-6, -3, -7, -6],
            [-1, 2, -6, 5],
        ]
    )
    b1 = np.array([6, 36, 35, 63])

    A1, b1 = upper_triangular(A1, b1)
    back_substitution(A1, b1)
    return


@app.function
def lu_decomposition(A, b):
    A, b = A.copy().astype(float), b.copy().astype(float)
    n = len(b)

    P, L = np.identity(n), np.zeros((n,n))

    for i in range(n):
        # remove 0 from pivot
        if A[i][i] == 0 and i != n-1:
            for j in range(i+1, n):
                if A[j][i] != 0:
                    row_swap(A, i, j)
                    row_swap(b, i, j)
                    row_swap(P, i, j)
                    row_swap(L, i, j)
                    print("swapped", i, j)

        # make remaining column 0
        for k in range(i+1, n):
            factor = -A[k, i]/A[i,i]
            row_add(A, k, i, factor)
            row_add(b, k, i, factor)
            L[k, i] = -factor

    np.fill_diagonal(L, 1)

    return P, L, A


@app.cell
def _():
    A2 = np.array(
        [
            [2, 5, 0, -4],
            [-4, -4, -3, 7],
            [-6, -3, -7, -6],
            [-1, 2, -6, 5],
        ]
    )
    b2 = np.array([6, 36, 35, 63])

    P, L, U = lu_decomposition(A2, b2)
    P, L ,U
    return L, P, U


@app.cell
def _(L, P, U):
    P @ L @ U
    return


@app.function
def least_squares_poly(X, Y, m):
    A, b = np.zeros((m+1,m+1)), np.zeros(m+1)
    it = np.nditer(A, flags=['multi_index'])
    for _ in it:
        i,j = it.multi_index
        A[i, j] = np.sum(X**(i+j))
    for k in range(m+1):
        b[k] = np.sum(X**k * Y)

    return solve_linear_system(A, b)


@app.cell
def _():
    f = lambda x: 1.44 / x**2 + 0.24 * x
    X = np.array([0.25, 1, 1.5, 2, 2.4, 5])
    Y = f(X)
    least_squares_poly(X, Y, 2)
    return


if __name__ == "__main__":
    app.run()
