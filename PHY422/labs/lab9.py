import marimo

__generated_with = "0.17.7"
app = marimo.App(width="medium")

with app.setup:
    # Initialization code that runs before all other cells
    import marimo as mo

    import numpy as np
    import scipy as sp


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q1

    $$\int_{a}^{b} f(x) dx \approx \frac{h}{2} \left[ f(a) + f(b) + 2 \sum_{i=1}^{n-1} f(x_{i}) \right]$$
    """)
    return


@app.function
def composite_trapezodial_rule(f, a, b, n):
    assert b >= a and n > 0 and isinstance(n, int)

    h = (b - a) / n

    return (
        h
        / 2
        * (
            f(a)
            + f(b)
            + 2 * np.sum(np.vectorize(f)(np.linspace(a, b, num=n + 1)[1:-1]))
        )
    )


@app.cell
def _():
    (
        composite_trapezodial_rule(np.sin, 0, np.pi, 4),
        sp.integrate.quad(np.sin, 0, np.pi)[0],
    )
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q2

    $$\int_{a}^{b} f(x) dx \approx \frac{h}{3} \left[ f(a) + f(b) + 2 \sum_{i=1}^{n/2-1} f(x_{2i}) + 4 \sum_{i=1}^{n/2} f(x_{2i-1}) \right]$$
    """)
    return


@app.function
def composite_simpson_rule(f, a, b, n):
    assert b >= a and n > 0 and isinstance(n, int)

    h = (b - a) / n

    return (
        h
        / 3
        * (
            f(a)
            + f(b)
            + 2 * np.sum(np.vectorize(f)(np.linspace(a, b, num=n + 1)[2:-1:2]))
            + 4 * np.sum(np.vectorize(f)(np.linspace(a, b, num=n + 1)[1:-1:2]))
        )
    )


@app.cell
def _():
    composite_simpson_rule(np.sin, 0, np.pi, 4), sp.integrate.quad(np.sin, 0, np.pi)[0]
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q3
    """)
    return


@app.cell
def _():
    f = lambda x: 2 + np.sin(2 * np.sqrt(x))
    return (f,)


@app.cell
def _(f):
    (
        composite_trapezodial_rule(f, 1, 6, 10),
        composite_simpson_rule(f, 1, 6, 10),
        sp.integrate.quad(f, 1, 6)[0],
    )
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q4
    """)
    return


@app.function
def gauss_legendre_quadrature(f, a, b, n):
    assert b >= a and n > 0 and isinstance(n, int)

    [xi, wi] = np.polynomial.legendre.leggauss(n)

    return (b - a) / 2 * np.sum(wi * np.vectorize(f)((b - a) / 2 * xi + (a + b) / 2))


@app.cell
def _():
    (
        gauss_legendre_quadrature(np.sin, 0, np.pi, 4),
        sp.integrate.quad(np.sin, 0, np.pi)[0],
    )
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q5
    """)
    return


@app.cell
def _():
    f_5a = lambda x: (1 / np.sqrt(2 * np.pi) * np.exp(-(x**2) / 2))
    gauss_legendre_quadrature(f_5a, 0, 1, 4), sp.integrate.quad(f_5a, 0, 1)[0]
    return


@app.cell
def _():
    f_5b = lambda x: np.exp(x) * np.cos(x)
    gauss_legendre_quadrature(f_5b, -1, 1, 4), sp.integrate.quad(f_5b, -1, 1)[0]
    return


@app.cell
def _():
    f_5c = lambda x: 1 / (2 + x)
    gauss_legendre_quadrature(f_5c, -1, 1, 4), sp.integrate.quad(f_5c, -1, 1)[0]
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q6
    """)
    return


@app.function
def approx_pi(n):
    f = np.vectorize(lambda x: np.sqrt(1 - x**2))
    f2 = np.vectorize(lambda x: 1 - x**2)

    N = np.random.uniform(0, 1, n)
    pi = 4 * np.mean(f(N))

    E = np.sqrt(1 / (n - 1) * (np.mean(f2(N)) - np.mean(f(N)) ** 2))

    return pi, E


@app.cell
def _():
    approx_pi(100000)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q7
    """)
    return


@app.function
def monte_carlo_integration(f, limits, n):
    assert n > 0 and isinstance(n, int)
    assert limits.ndim == 2 and limits.shape[1] == 2
    for a, b in limits:
        assert b >= a

    X_i = np.zeros((limits.shape[0], n))
    for i, (a, b) in enumerate(limits):
        X_i[i, :] = np.random.uniform(a, b, n)

    A = np.prod(limits[:, 1] - limits[:, 0])

    integral = A * np.mean(np.vectorize(f)(*X_i))

    return integral


@app.cell
def _():
    f7 = lambda x, y: 4 - x**2 - y**2
    (
        monte_carlo_integration(f7, np.array([[0, 5 / 4], [0, 5 / 4]]), 100000),
        sp.integrate.dblquad(f7, 0, 5 / 4, lambda x: 0, lambda x: 5 / 4)[0],
    )
    return


if __name__ == "__main__":
    app.run()
