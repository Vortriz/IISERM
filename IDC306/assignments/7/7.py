import marimo

__generated_with = "0.11.10"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell
def _():
    import random
    return (random,)


@app.cell
def _(mo):
    mo.md(r"""### Bubble Sort""")
    return


@app.cell
def _(a):
    def bubblepass(arr) :
        c = 0
        k = len(a)

        for i in range(k-1) :
            if a[i] > a[i+1] :
                c+=1
                a[i], a[i+1] = a[i+1], a[i]

        return c, a
    return (bubblepass,)


@app.cell
def _(bubblepass):
    def bubblesort(arr) :
        a = arr.copy()
    
        c = 1
        while c > 0 :
            c, a = bubblepass(a)

        return a
    return (bubblesort,)


@app.cell
def _(random):
    a = [random.randint(1, 100) for _ in range(25)]
    print(a)
    return (a,)


@app.cell
def _(a, bubblesort):
    bubblesort(a)
    return


@app.cell
def _(mo):
    mo.md(r"""### Insert Sort""")
    return


@app.cell
def _():
    def insert(a, b) :
    	k = len(a)-1
    	a.append(b)
    	j = k

    	while j >= 0 and a[j] > a[j+1] :
    		a[j], a[j+1] = a[j+1], a[j]
    		j-=1

    	return a
    return (insert,)


@app.cell
def _(insert):
    def insertsort(arr) :
        a = arr.copy()
        k = len(a)

        for i in range(k) :
            a_prime, ai, a_pprime  = a[:i], a[i], a[i+1:]
            a_prime = insert(a_prime, ai)
            a = a_prime + a_pprime
    
        return a
    return (insertsort,)


@app.cell
def _(a, insertsort):
    insertsort(a)
    return


if __name__ == "__main__":
    app.run()
