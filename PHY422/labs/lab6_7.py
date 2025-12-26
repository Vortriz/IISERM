import marimo

__generated_with = "0.17.7"
app = marimo.App(width="medium")

with app.setup:
    # Initialization code that runs before all other cells
    import marimo as mo

    import numpy as np
    from numpy.polynomial import Polynomial
    import sympy as sy
    from sympy.plotting import plot as sy_plot
    import matplotlib.pyplot as plt

    from lab3_4 import solve_linear_system


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q1
    """)
    return


@app.cell
def _():
    f1 = Polynomial([1, 2, 3])
    return (f1,)


@app.function
def horner(P, x):
    b = 0
    for a in reversed(P.coef):
        b = a + b * x

    return b


@app.cell
def _(f1):
    horner(f1, 2) == f1(2)
    return


@app.function
def horner_derivative(P, x):
    P_der = Polynomial(P.coef[1:] * np.arange(1, len(P.coef)))
    return horner(P_der, x)


@app.cell
def _(f1):
    horner_derivative(f1, 2) == f1.deriv()(2)
    return


@app.function
def horner_derivative_alt(P, x):
    b, d = 0, 0
    for a in reversed(P.coef[1:]):
        b = a + b * x
        d = b + d * x

    return d


@app.cell
def _(f1):
    horner_derivative_alt(f1, 2) == f1.deriv()(2)
    return


@app.function
def horner_integral(P, x):
    P_int = Polynomial(np.insert(P.coef / np.arange(1, len(P.coef) + 1), 0, 0))
    return horner(P_int, x)


@app.cell
def _(f1):
    horner_integral(f1, 1)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q2

    makes no sense when asked to use Horner's method
    """)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q3
    """)
    return


@app.function
def vandermonde(X):
    # points = np.array(X)
    n = len(X)
    V = np.zeros((n, n))
    for i in range(n):
        V[:, i] = X**i
    return V


@app.cell
def _():
    points_3 = np.array([(1, 1.06), (2, 1.12), (3, 1.34), (5, 1.78)])
    vandermonde(points_3[:, 0])
    return (points_3,)


@app.function
def vandermonde_poly(points):
    V = vandermonde(points[:, 0])
    a = solve_linear_system(V, points[:, 1])
    return Polynomial(a)


@app.cell
def _(points_3):
    vandermonde_poly(points_3)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q4
    """)
    return


@app.function
def lagrange(X, Y):
    L = 0
    x = sy.symbols("x")
    for i in range(len(X)):
        X_temp = np.delete(X, i)
        L += sy.prod(x - X_temp) / np.prod(X[i] - X_temp) * Y[i]

    return L


@app.function
def lagrange_compare(f_intr, f, deg):
    x = sy.symbols("x")
    lo, hi = 0, 1.2

    x_range = (x, lo, hi)

    L = sy_plot(
        f_intr(np.linspace(start=lo, stop=hi, num=deg + 1)),
        x_range,
        show=False,
        legend=True,
        label=f"lagrange ({deg})",
    )
    c = sy_plot(f(x), x_range, show=False)
    L.append(c[0])
    L.show()


@app.function
def lagrange_cos(X):
    return lagrange(X, np.cos(X))


@app.cell
def _():
    lagrange_cos(np.linspace(0, 1.2, 4))
    return


@app.cell
def _():
    lagrange_compare(lagrange_cos, sy.cos, 1)
    return


@app.cell
def _():
    lagrange_compare(lagrange_cos, sy.cos, 2)
    return


@app.cell
def _():
    lagrange_compare(lagrange_cos, sy.cos, 3)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q4 (without sympy)
    """)
    return


@app.function
def lagrange_alt(x, X, Y):
    L = 0
    for i in range(len(X)):
        X_temp = np.delete(X, i)
        L += np.prod(x - X_temp) / np.prod(X[i] - X_temp) * Y[i]

    return L


@app.function
def lagrange_alt_cos(x, X):
    return lagrange_alt(x, X, np.cos(X))


@app.function
def lagrange_alt_compare(f_intr, f, deg):
    lims = (0, 1.2)
    x = np.linspace(*lims, 500)
    y_intr = np.array([f_intr(xi, np.linspace(*lims, num=deg + 1)) for xi in x])

    plt.plot(x, f(x), label="cos(x)", color="blue")
    plt.plot(x, y_intr, label=f"lagrange ({deg})", color="orange")
    plt.show()


@app.cell
def _():
    lagrange_alt_compare(lagrange_alt_cos, np.cos, 1)
    return


@app.cell
def _():
    lagrange_alt_compare(lagrange_alt_cos, np.cos, 2)
    return


@app.cell
def _():
    lagrange_alt_compare(lagrange_alt_cos, np.cos, 3)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q5
    """)
    return


@app.function
def lagrange_coef_poly(X, i):
    x = sy.symbols("x")
    X_temp = np.delete(X, i)
    L_i = sy.prod(x - X_temp) / np.prod(X[i] - X_temp)

    return L_i


@app.function
def lagrange_coef_poly_compare():
    x = sy.symbols("x")
    lo, hi = 0, 1.2

    x_range = (x, lo, hi)
    X = np.linspace(start=lo, stop=hi, num=3 + 1)

    L0 = sy_plot(
        lagrange_coef_poly(X, 0), x_range, show=False, legend=True, label=f"L_3,0"
    )
    L1 = sy_plot(
        lagrange_coef_poly(X, 1), x_range, show=False, legend=True, label=f"L_3,1"
    )
    L2 = sy_plot(
        lagrange_coef_poly(X, 2), x_range, show=False, legend=True, label=f"L_3,2"
    )
    L3 = sy_plot(
        lagrange_coef_poly(X, 3), x_range, show=False, legend=True, label=f"L_3,3"
    )
    P = sy_plot(
        lagrange_cos(X), x_range, show=False, legend=True, label=f"lagrange (3)"
    )
    P.append(L0[0])
    P.append(L1[0])
    P.append(L2[0])
    P.append(L3[0])
    P.show()


@app.cell
def _():
    lagrange_coef_poly_compare()
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q6
    """)
    return


@app.function
def newton(X, Y):
    x = sy.symbols("x")
    N = 0
    for k in range(len(X)):
        N += divided_diff(X, Y, 0, k) * sy.prod(x - X[:k])

    return N


@app.function
def divided_diff(X, Y, k, j):
    if j == k:
        return Y[k]
    else:
        return (
            divided_diff(X, Y, k + 1, j) - divided_diff(X, Y, k, j - 1)
        ) / (X[j] - X[k])


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q6 (without sympy)
    """)
    return


@app.function
def newton_alt(x, X, Y):
    N = 0
    for k in range(len(X)):
        N += divided_diff_alt(X, Y, k, k) * np.prod(x - X[:k])

    return N


@app.function
def divided_diff_alt(X, Y, k, j):
    if j == 0:
        return Y[k]
    else:
        return (divided_diff_alt(X, Y, k, j-1) - divided_diff_alt(X, Y, k-1, j-1)) / (X[k] - X[k-j])


@app.function
def newton_alt_cos(x, X):
    return newton_alt(x, X, np.cos(X))


@app.cell
def _():
    asd = np.linspace(0, 1.2, 500)
    asdy = [newton_alt_cos(x, np.linspace(1, 1.2, 12)) for x in asd]
    plt.plot(asd, asdy)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q7
    """)
    return


@app.function
def newton_compare(f_intr, f, n):
    x = sy.symbols("x")
    lo, hi = 0, 1.2

    x_range = (x, lo, hi)

    N = sy_plot(
        f_intr(np.linspace(start=lo, stop=hi, num=n)),
        x_range,
        show=False,
        legend=True,
        label=f"newton ({n})",
    )
    c = sy_plot(f(x), x_range, show=False)
    N.append(c[0])
    N.show()


@app.function
def newton_cos(X):
    return newton(X, np.cos(X))


@app.cell
def _():
    newton_compare(newton_cos, sy.cos, 4)
    return


@app.cell
def _():
    newton_compare(newton_cos, sy.cos, 6)
    return


@app.cell
def _():
    newton_compare(newton_cos, sy.cos, 12)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q8
    """)
    return


@app.function
def linear_least_squares_2d(X, Y):
    X, Y = np.array(X), np.array(Y)

    n = len(X)
    m = (n * np.sum(X * Y) - np.sum(X) * np.sum(Y)) / (
        n * np.sum(X**2) - (np.sum(X))**2
    )
    c = (np.sum(Y) - m * np.sum(X)) / n
    return m, c


@app.function
def linear_least_squares_gen(X, Y):
    X = np.vstack((X, np.ones(len(X)))).T
    beta = np.linalg.inv(X.T @ X) @ X.T @ Y
    return beta


@app.cell
def _():
    X_8, Y_8 = [1, 2, 3, 4], [1, 2, 3, 4]
    return X_8, Y_8


@app.cell
def _(X_8, Y_8):
    linear_least_squares_2d(X_8, Y_8)
    return


@app.cell
def _(X_8, Y_8):
    linear_least_squares_gen(X_8, Y_8)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    ## a)
    """)
    return


@app.function
def linearized_least_squares_pow(X, Y):
    X_log, Y_log = np.log(X), np.log(Y)
    m, c = linear_least_squares_2d(X_log, Y_log)

    plt.scatter(X_log, Y_log)
    plt.plot(
        X_log,
        m * X_log + c,
        color="red",
        label=f"log(Y) = {m:.4f} log(X) {'+' if np.sign(c) == 1 else '-'} {np.abs(c):.4f}",
    )
    plt.legend()
    plt.xlabel("log(X)")
    plt.ylabel("log(Y)")
    plt.show()


@app.cell
def _():
    X_8a = np.array(
        [57.59, 108.11, 149.57, 227.84, 778.14, 1427.0, 2870.3, 4499.9, 5909.0]
    )
    Y_8a = np.array([87.99, 224.70, 365.26, 686.98, 4332.4, 10759, 30684, 60188, 90710])
    return X_8a, Y_8a


@app.cell
def _(X_8a, Y_8a):
    linearized_least_squares_pow(X_8a[:4], Y_8a[:4])
    return


@app.cell
def _(X_8a, Y_8a):
    linearized_least_squares_pow(X_8a, Y_8a)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    ## b)
    """)
    return


@app.function
def linearized_logistic_growth(t, P, L=1000):
    X, Y = np.array(t), np.log(L / np.array(P) - 1)
    m, c = linear_least_squares_2d(X, Y)

    plt.scatter(X, Y)
    plt.plot(
        X,
        m * X + c,
        color="red",
        label=f"log(Y) = {m:.4f} log(X) {'+' if np.sign(c) == 1 else '-'} {np.abs(c):.4f}",
    )
    plt.legend()
    plt.xlabel("t")
    plt.ylabel(f"log({L}/P - 1)")
    plt.show()


@app.cell
def _():
    t_8b = [0, 1, 2, 3, 4]
    P_8b = [200, 400, 650, 850, 950]
    linearized_logistic_growth(t_8b, P_8b)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q9
    """)
    return


@app.function
def f_9(x):
    return 1.44 / x**2 + 0.24 * x


@app.cell
def _():
    X_9 = np.array([0.25, 1, 1.5, 2, 2.4, 5])
    Y_9 = f_9(X_9)
    points_9 = np.column_stack((X_9, Y_9))
    return (points_9,)


@app.function
def least_squares_poly(points, deg):
    X = points[:, 0]

    xi_pows = np.zeros((len(X), 2 * deg + 1))
    for d in range(2 * deg + 1):
        xi_pows[:, d] = X**d

    xi_pows_sum = np.sum(xi_pows, axis=0)
    Y = np.sum(np.tile(points[:, 1], (deg + 1, 1)).T * xi_pows[:, : deg + 1], axis=0)

    mat = np.zeros((deg + 1, deg + 1))
    for i in range(deg + 1):
        mat[i] = xi_pows_sum[i : i + deg + 1]

    a = solve_linear_system(mat, Y)
    return a


@app.cell
def _(points_9):
    least_squares_poly(points_9, 2)
    return


@app.function
def gen_poly_from_coefs(a):
    x = sy.symbols("x")
    P = 0
    for i, coef in enumerate(a):
        P += coef * x**i

    return P


@app.function
def plot_least_squares_poly(f, points, deg):
    x = sy.symbols("x")
    X, Y = points[:, 0], points[:, 1]

    x_range = (x, min(X), max(X))
    ylim = (min(Y) - 1, max(Y) + 1)

    P = gen_poly_from_coefs(least_squares_poly(points, deg))

    L = sy_plot(f(x), ylim=ylim, show=False, label=f"least squares poly ({deg})")
    c = sy_plot(P, show=False)
    L.append(c[0])
    L.show()


@app.cell
def _(points_9):
    plot_least_squares_poly(f_9, points_9, 2)
    return


@app.cell
def _(points_9):
    plot_least_squares_poly(f_9, points_9, 3)
    return


@app.cell
def _(points_9):
    plot_least_squares_poly(f_9, points_9, 4)
    return


@app.cell
def _(points_9):
    plot_least_squares_poly(f_9, points_9, 5)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # [TODO] Splines 😭
    """)
    return


if __name__ == "__main__":
    app.run()
