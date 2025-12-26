import marimo

__generated_with = "0.17.7"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo

    return (mo,)


@app.cell
def _():
    import numpy as np

    return (np,)


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Q1
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    /// admonition | Note
    `g_fpif` denotes $x = g(x)$ form of $g(x)$
    ///
    """)
    return


@app.cell
def _():
    g1 = lambda x: x**3 - 7 * x + 2

    g1_fpif = lambda x: (x**3 + 2) / 7

    d_g1 = lambda x: 3 * x**2 - 7
    return d_g1, g1, g1_fpif


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## (a) Iteration method
    """)
    return


@app.cell
def _(np):
    def iteration(gx, a, tol=np.float64(1e-8), max_iter=100):
        for i in range(1, max_iter + 1):
            a_new = gx(a)
            if np.abs(a_new - a) < tol:
                return {"root": a_new, "iter": i}
            a = a_new
        return {"root": a, "iter": max_iter}

    return (iteration,)


@app.cell
def _(g1_fpif, iteration, np):
    iteration(g1_fpif, np.float64(1.0))
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## (b) Bisection method
    """)
    return


@app.cell
def _(np):
    def bisection(gx, a, b, tol=np.float64(1e-8), max_iter=100):
        if not ((a < b) and (gx(a) * gx(b) < 0)):
            raise ValueError("Invalid interval or function does not change sign.")

        for i in range(1, max_iter + 1):
            c = (a + b) / 2

            if np.abs(gx(c)) < tol or np.abs(b - a) < tol:
                return {"root": c, "iter": i}

            # Check if a and c have the same sign
            if gx(a) * gx(c) > 0:
                a = c
            else:
                b = c

        return {"root": c, "iter": max_iter}

    return (bisection,)


@app.cell
def _(bisection, g1, np):
    bisection(g1, np.float64(0.0), np.float64(2.0))
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## (c) Method of false position (Regula falsi method)
    """)
    return


@app.cell
def _(np):
    def regula_falsi(gx, a, b, tol=np.float64(1e-8), max_iter=100):
        if not ((a < b) and (gx(a) * gx(b) < 0)):
            raise ValueError("Invalid interval or function does not change sign.")

        for i in range(1, max_iter + 1):
            c = b - gx(b) * (b - a) / (gx(b) - gx(a))

            if np.abs(gx(c)) < tol or np.abs(b - a) < tol:
                return {"root": c, "iter": i}

            # Check if a and c have the same sign
            if gx(a) * gx(c) > 0:
                a = c
            else:
                b = c

        return {"root": c, "iter": max_iter}

    return (regula_falsi,)


@app.cell
def _(g1, np, regula_falsi):
    regula_falsi(g1, np.float64(0.0), np.float64(2.0))
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## (d) Newton-Raphson method
    """)
    return


@app.cell
def _(np):
    def newton_raphson(gx, d_gx, x0, tol=np.float64(1e-8), max_iter=100):
        x = x0
        for i in range(1, max_iter + 1):
            fx = gx(x)
            dfx = d_gx(x)

            if dfx == 0:
                raise ValueError("Derivative is zero. No solution found.")

            x_new = x - fx / dfx

            if np.abs(x_new - x) < tol:
                return {"root": x_new, "iter": i}
            x = x_new

        return {"root": x, "iter": max_iter}

    return (newton_raphson,)


@app.cell
def _(d_g1, g1, newton_raphson, np):
    newton_raphson(g1, d_g1, np.float64(1.5))
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## (e) Secant method
    """)
    return


@app.cell
def _(np):
    def secant(gx, x0, x1, tol=np.float64(1e-8), max_iter=100):
        for i in range(1, max_iter + 1):
            if gx(x1) - gx(x0) == 0:
                raise ValueError("Division by zero in secant method.")

            x2 = x1 - gx(x1) * (x1 - x0) / (gx(x1) - gx(x0))

            if np.abs(x2 - x1) < tol:
                return {"root": x2, "iter": i}

            x0, x1 = x1, x2

        return {"root": x2, "iter": max_iter}

    return (secant,)


@app.cell
def _(g1, np, secant):
    secant(g1, np.float64(-2), np.float64(-4))
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Q2
    """)
    return


@app.cell
def _(np):
    g2 = lambda x: x ** (x - np.cos(x))

    g2_fpif = lambda x: x ** (x - np.cos(x)) - x
    return (g2_fpif,)


@app.cell
def _(bisection, g2_fpif, np):
    bisection(
        g2_fpif,
        np.float64(1.14),
        np.float64(2),
        tol=np.float64(1e-12),
        max_iter=1000,
    )
    return


@app.cell
def _(g2_fpif, np, regula_falsi):
    regula_falsi(
        g2_fpif,
        np.float64(1.14),
        np.float64(2),
        tol=np.float64(1e-12),
        max_iter=1000,
    )
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Q3
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## (a) Submersed spherical ball
    """)
    return


@app.cell
def _(np):
    r = 10
    rho = 0.638
    f1h = lambda h: (4 / 3) * np.pi * rho * r**3 - np.pi * h**2 * (3 * r - h) / 3
    return f1h, r


@app.cell
def _(f1h, np, r, secant):
    secant(f1h, np.float64(0), np.float64(2 * r))
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## (b) Projectile motion with linear Stokes drag
    """)
    return


@app.cell
def _(np):
    g = 9.8
    C = 10
    v_y = 100 * np.cos(np.radians(45))

    yt = lambda t: C * (v_y + g * C) * (1 - np.exp(-t / C)) - g * C * t
    return (yt,)


@app.cell
def _(np, secant, yt):
    secant(yt, np.float64(10), np.float64(20))
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## (c) $h (x)$
    """)
    return


@app.cell
def _(np):
    hx = lambda x: x * np.sin(x)
    hhx = lambda x: hx(x) - 1
    return (hhx,)


@app.cell
def _(hhx, np, secant):
    secant(hhx, np.float64(0), np.float64(2))
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## (d) Plane cutting sphere
    """)
    return


@app.cell
def _():
    f2h = lambda h: h**3 - 3 * h**2 + 1
    return (f2h,)


@app.cell
def _(f2h, np, secant):
    secant(f2h, np.float64(0), np.float64(1), tol=np.float64(1e-10))
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Q4
    """)
    return


@app.cell
def _(np):
    def square_root(a, x0, tol=np.float64(1e-8), max_iter=100):
        if a < 0:
            raise ValueError("Cannot compute square root of negative number.")

        x = x0

        for i in range(1, max_iter + 1):
            x_new = (x + a / x) / 2

            if np.abs(x_new - x) < tol:
                return {"sqrt": x_new, "iter": i}

            x = x_new

        return {"sqrt": x, "iter": max_iter}

    return (square_root,)


@app.cell
def _(np, square_root):
    square_root(7, 1, tol=np.float64(1e-10))
    return


@app.cell
def _(np):
    def cube_root(a, x0, tol=np.float64(1e-8), max_iter=100):
        x = x0

        for i in range(1, max_iter + 1):
            x_new = (2 * x + a / (x**2)) / 3

            if np.abs(x_new - x) < tol:
                return {"cbrt": x_new, "iter": i}

            x = x_new

        return {"cbrt": x, "iter": max_iter}

    return (cube_root,)


@app.cell
def _(cube_root, np):
    cube_root(7, 1, tol=np.float64(1e-10))
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Q5def newton_raphson(gx, d_gx, x0, tol=np.float64(1e-8), max_iter=100):
        x = x0
        for i in range(1, max_iter+1):
            fx = gx(x)
            dfx = d_gx(x)

            if dfx == 0:
                raise ValueError("Derivative is zero. No solution found.")

            x_new = x - fx / dfx

            if np.abs(x_new - x) < tol:
                return {"root": x_new, "iter": i}
            x = x_new

        return {"root": x, "iter": max_iter}
    """)
    return


@app.cell
def _(np):
    def acc_newton_raphson(gx, d_gx, x0, M=2, tol=np.float64(1e-8), max_iter=100):
        x = x0
        for i in range(1, max_iter + 1):
            fx = gx(x)
            dfx = d_gx(x)

            if dfx == 0:
                raise ValueError("Derivative is zero. No solution found.")

            x_new = x - M * fx / dfx

            if np.abs(x_new - x) < tol:
                return {"root": x_new, "iter": i}
            x = x_new

        return {"root": x, "iter": max_iter}

    return (acc_newton_raphson,)


@app.cell
def _(np):
    f3 = lambda x: (x - 1) * np.log(x)

    d_f3 = lambda x: np.log(x) + 1 - 1 / x
    return d_f3, f3


@app.cell
def _(d_f3, f3, newton_raphson, np):
    newton_raphson(f3, d_f3, np.float64(2))
    return


@app.cell
def _(acc_newton_raphson, d_f3, f3, np):
    acc_newton_raphson(f3, d_f3, np.float64(2))
    return


if __name__ == "__main__":
    app.run()
