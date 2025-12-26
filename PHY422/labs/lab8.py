import marimo

__generated_with = "0.17.7"
app = marimo.App(width="medium")

with app.setup:
    # Initialization code that runs before all other cells
    import marimo as mo

    import numpy as np
    import pandas as pd
    import matplotlib.pyplot as plt
    import sympy as sy

    from lab6_7 import newton, newton_cos


@app.cell
def _():
    cos = lambda x: np.cos(x)
    sin = lambda x: np.sin(x)
    return cos, sin


@app.cell(hide_code=True)
def _():
    mo.md(r"""

    """)
    return


@app.function
def q1(f, x, h=0.1, tolerance=None):
    k = 0
    D = []
    while True:
        D_k = (f(x + 10 ** (-k) * h) - f(x - 10 ** (-k) * h)) / (2 * 10 ** (-k) * h)
        D.append(D_k)
        if k >= 1 and tolerance is not None and abs(D[k] - D[k - 1]) < tolerance:
            print("Less than tolerance")
            return D[-1]
        elif k >= 2 and abs(D[k] - D[k - 1]) < abs(D[k - 1] - D[k - 2]):
            print("Minimum difference exceeded")
            return D[-2]
        k += 1


@app.cell
def _(cos):
    q1(cos, np.pi / 2)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q2
    """)
    return


@app.function
def cd_O2(f, x, h=0.1):
    return (f(x + h) - f(x - h)) / (2 * h)


@app.function
def cd_O4(f, x, h=0.1):
    return (-f(x + 2 * h) + 8 * f(x + h) - 8 * f(x - h) + f(x - 2 * h)) / (12 * h)


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q3
    """)
    return


@app.function
def q3a():
    f = lambda x: np.cos(x)
    x = 0.8
    negate_pows = range(1, 5)

    df = pd.DataFrame(columns=["h", "O(h^2)", "O(h^4)"], index=negate_pows)

    for i in negate_pows:
        h = 10 ** (-i)
        df.loc[df.index[i - 1]] = [h, cd_O2(f, x, h), cd_O4(f, x, h)]

    return df


@app.cell
def _():
    q3a_res = q3a()
    q3a_res
    return (q3a_res,)


@app.cell
def _(sin):
    -sin(0.8)
    return


@app.function
def q3c(df):
    df["Error (O(h^2))"] = np.abs(df["O(h^2)"] - (-np.sin(0.8)))

    return df


@app.cell
def _(q3a_res):
    q3c_res = q3c(q3a_res)
    q3c_res
    return (q3c_res,)


@app.cell
def _(q3c_res):
    plt.loglog(
        q3c_res["h"], q3c_res["Error (O(h^2))"], marker="o", label="O(h^2) Error"
    )
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q4
    """)
    return


@app.function
def q4(f, x, n, h=1):
    D = np.zeros((n, n))
    it = np.nditer(D, flags=["multi_index"])
    for _ in it:
        j, k = it.multi_index
        if k <= j:
            if k == 0:
                D[j, k] = (f(x + 2 ** (-j) * h) - f(x - 2 ** (-j) * h)) / (
                    2 ** (-j + 1) * h
                )
            else:
                D[j, k] = D[j, k - 1] + (D[j, k - 1] - D[j - 1, k - 1]) / (4**k - 1)

    return D


@app.cell
def _(cos):
    q4(cos, 0.8, 3)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    # Q5
    """)
    return


@app.cell
def _():
    h = 0.1
    X = np.arange(0, 1.5, h)
    P = newton_cos(X)
    P = sy.lambdify(sy.symbols("x"), P)
    P
    return P, h


@app.cell
def _(P, h, sin):
    cd_O4(P, 0.5, h), -sin(0.5)
    return


if __name__ == "__main__":
    app.run()
