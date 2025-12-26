import marimo

__generated_with = "0.17.7"
app = marimo.App(width="medium")

with app.setup:
    # Initialization code that runs before all other cells
    import marimo as mo
    import numpy as np
    from lab3_4 import row_swap, row_add, forward_substitution, back_substitution


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q1
    """)
    return


@app.function
def lu_decomposition(matrix):
    """Perform LU decomposition on a matrix."""
    matrix = matrix.astype(float)  # Ensure we are working with floats
    N = matrix.shape[0]

    P, L = np.identity(N), np.identity(N)

    for r in range(N):
        # Remove 0 from pivots
        if matrix[r, r] == 0:
            for r2 in range(r + 1, N):
                if matrix[r2, r] != 0:
                    row_swap(matrix, r, r2)
                    row_swap(P, r, r2)
                    break
        # Convert to upper triangular form and create L
        for r2 in range(r + 1, N):
            l = matrix[r2, r] / matrix[r, r]
            row_add(matrix, r2, r, -l)
            L[r2, r] = l

    return L, matrix, P


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q2
    """)
    return


@app.function
def lu_solve(A, b):
    """Solve Ax = b using LU decomposition."""
    L, U, P = lu_decomposition(A)
    Pb = np.matmul(P, b)

    y = forward_substitution(np.concatenate((L, np.expand_dims(Pb, axis=0).T), axis=1))
    x = back_substitution(np.concatenate((U, np.expand_dims(y, axis=0).T), axis=1))

    return x


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q3
    """)
    return


@app.cell
def _():
    A_lu = np.array([[2, 5, 0, -4], [-4, -4, -3, 7], [-6, -3, -7, -6], [-1, 2, -6, 5]])
    b_lu_1 = np.array([6, 36, 35, 63])
    b_lu_2 = np.array([56, 66, 58, -14])
    b_lu_3 = np.array([9, 6, -22, 10])
    return A_lu, b_lu_1, b_lu_2, b_lu_3


@app.cell
def _(A_lu, b_lu_1):
    lu_solve(A_lu, b_lu_1)
    return


@app.cell
def _(A_lu, b_lu_2):
    lu_solve(A_lu, b_lu_2)
    return


@app.cell
def _(A_lu, b_lu_3):
    lu_solve(A_lu, b_lu_3)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q4
    """)
    return


@app.function
def jacobi_iteration(A, b, x0=None, tol=1e-12, max_iterations=1000):
    """Solve Ax = b using the Jacobi iterative method."""
    N = A.shape[0]
    if x0 is None:
        x0 = np.zeros(N)
    x = np.copy(x0)

    for it_count in range(max_iterations):
        x_new = np.zeros_like(x)
        for i in range(N):
            s = np.dot(A[i, :], x) - A[i, i] * x[i]
            x_new[i] = (b[i] - s) / A[i, i]
        if np.linalg.norm(x_new - x, ord=np.inf) < tol:
            return x_new
        x = x_new
    raise ValueError(
        "Jacobi method did not converge within the maximum number of iterations"
    )


@app.function
def gauss_seidel(A, b, x0=None, tol=1e-12, max_iterations=1000):
    """Solve Ax = b using the Gauss-Seidel iterative method."""
    N = A.shape[0]
    if x0 is None:
        x0 = np.zeros(N)
    x = x0

    for it_count in range(max_iterations):
        x_old = np.copy(x)
        for i in range(N):
            s = np.dot(A[i, :], x) - A[i, i] * x[i]
            x[i] = (b[i] - s) / A[i, i]
        if np.linalg.norm(x - x_old, ord=np.inf) < tol:
            return x
    # raise ValueError("Gauss-Seidel method did not converge within the maximum number of iterations")
    return x


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q5
    """)
    return


@app.cell
def _():
    A_im, b_im = np.zeros((50, 50)), np.ones(50) * 5

    for i in range(50):
        for j in range(50):
            if i == j:
                A_im[i, j] = 12
            elif abs(i - j) == 1:
                A_im[i, j] = -2
            elif abs(i - j) == 2:
                A_im[i, j] = 1
    return A_im, b_im


@app.cell
def _(A_im, b_im):
    jacobi_iteration(A_im, b_im)
    return


@app.cell
def _(A_im, b_im):
    gauss_seidel(A_im, b_im)
    return


if __name__ == "__main__":
    app.run()
