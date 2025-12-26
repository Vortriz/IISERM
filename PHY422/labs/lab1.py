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
    from decimal import Decimal, getcontext
    import seaborn as sns

    return Decimal, getcontext, np, sns


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Q1
    """)
    return


@app.cell
def _():
    a = 2**32
    a = a + 2**3
    print(a)
    return


@app.cell
def _():
    b = 2**64
    b = b + 2**3
    print(b)
    return


@app.cell
def _(np):
    c = np.int16(2**15 - 1)
    print(c)
    print(c + np.int16(1))
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Q2
    """)
    return


@app.cell
def _(getcontext):
    getcontext().prec = 6
    return


@app.cell
def _(np):
    def f1(x):
        return x * (np.sqrt(x + 1) - np.sqrt(x))

    def g1(x):
        return x / (np.sqrt(x + 1) + np.sqrt(x))

    return f1, g1


@app.cell
def _(Decimal, f1, g1):
    x1 = Decimal(500)
    print(f1(x1), g1(x1))
    return


@app.cell
def _(f1, g1):
    y1 = 500
    print(f1(y1), g1(y1))
    return


@app.cell
def _(mo):
    mo.md(r"""
    # Q3
    """)
    return


@app.cell
def _(Decimal, np):
    def f2(x):
        return (np.exp(x) - 1 - x) / x**2

    def g2(x):
        return Decimal(1) / Decimal(2) + x / 6 + x**2 / 24

    return f2, g2


@app.cell
def _(Decimal, f2, g2):
    x2 = Decimal(0.01)
    print(f2(x2), g2(x2))
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Q4
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Q5
    """)
    return


@app.cell
def _():
    n = 20
    return (n,)


@app.cell
def _(n):
    seq: list[int] = [1 / 3**i for i in range(n)]
    print(seq)
    return (seq,)


@app.cell
def _(n):
    def rn(r):
        for i in range(1, n):
            r[i] = 1 / 3 * r[i - 1]
        return r

    r_a: list[int] = [0] * n
    r_a[0] = 1
    print(rn(r_a))
    return r_a, rn


@app.cell
def _(n):
    def pn(p):
        for i in range(2, n):
            p[i] = 4 / 3 * p[i - 1] - 1 / 3 * p[i - 2]
        return p

    p_a: list[int] = [0] * n
    p_a[0] = 1
    p_a[1] = 1 / 3

    print(pn(p_a))
    return p_a, pn


@app.cell
def _(n):
    def qn(q):
        for i in range(2, n):
            q[i] = 10 / 3 * q[i - 1] - q[i - 2]
        return q

    q_a: list[int] = [0] * n
    q_a[0] = 1
    q_a[1] = 1 / 3

    print(qn(q_a))
    return q_a, qn


@app.cell
def _(n, rn):
    r_b: list[int] = [0] * n
    r_b[0] = 0.99996

    print(rn(r_b))
    return (r_b,)


@app.cell
def _(n, pn):
    p_b: list[int] = [0] * n
    p_b[0] = 1
    p_b[1] = 0.33332

    print(pn(p_b))
    return (p_b,)


@app.cell
def _(n, qn):
    q_b: list[int] = [0] * n
    q_b[0] = 1
    q_b[1] = 0.33332

    print(qn(q_b))
    return (q_b,)


@app.cell
def _(
    n,
    p_a: list[int],
    p_b: list[int],
    q_a: list[int],
    q_b: list[int],
    r_a: list[int],
    r_b: list[int],
    seq: list[int],
):
    err_r_a = [abs(1 - r_a[i] / seq[i]) for i in range(n)]
    err_p_a = [abs(1 - p_a[i] / seq[i]) for i in range(n)]
    err_q_a = [abs(1 - q_a[i] / seq[i]) for i in range(n)]
    err_r_b = [abs(1 - r_b[i] / seq[i]) for i in range(n)]
    err_p_b = [abs(1 - p_b[i] / seq[i]) for i in range(n)]
    err_q_b = [abs(1 - q_b[i] / seq[i]) for i in range(n)]
    return err_p_a, err_p_b, err_q_a, err_q_b, err_r_a, err_r_b


@app.cell
def _(err_r_a, n, sns):
    sns.relplot(x=range(n), y=err_r_a, label="r_a")
    return


@app.cell
def _(err_p_a, n, sns):
    sns.relplot(x=range(n), y=err_p_a, label="p_a")
    return


@app.cell
def _(err_q_a, n, sns):
    sns.relplot(x=range(n), y=err_q_a, label="q_a")
    return


@app.cell
def _(err_r_b, n, sns):
    sns.relplot(x=range(n), y=err_r_b, label="r_b")
    return


@app.cell
def _(err_p_b, n, sns):
    sns.relplot(x=range(n), y=err_p_b, label="p_b")
    return


@app.cell
def _(err_q_b, n, sns):
    sns.relplot(x=range(n), y=err_q_b, label="q_b")
    return


if __name__ == "__main__":
    app.run()
