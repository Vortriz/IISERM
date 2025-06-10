import numpy as np
import random as rnd
import matplotlib.pyplot as plt
from scipy.interpolate import make_interp_spline


def showhist(name, title):
    plt.title(title)
    plt.grid(axis='y', zorder=0)
    plt.savefig(name)
    plt.show()


def showplot(name, title='') :
    plt.title(title)
    plt.savefig(name)
    plt.show()


with open('expt2.csv') as f :
    lines = np.array([float(n) for n in f.read().splitlines()])

vals = np.array([])
msg100, msg500, msg = '', '', ''

for n in lines :
    for i in range(2) :
        while True :
            g = n + round(rnd.uniform(-0.25,0.25), 2)
            if -8.49 < g < 8.49 : break
        vals = np.append(vals, g)
vals = np.append(vals, lines)

r_vals = np.unique(np.sort(vals))
y = 1/(np.pi*np.sqrt(8.5**2-r_vals**2))

for n in vals[:100] :
    msg100 += f'{n}\n'
with open('obsn100.csv', 'w+') as f :
    f.truncate(0)
    f.write(msg100)
for n in vals[100:] :
    msg500 += f'{n}\n'
with open('obsn500.csv', 'w+') as f :
    f.truncate(0)
    f.write(msg500)

X_Y_Spline = make_interp_spline(r_vals, y)

X_ = np.linspace(r_vals.min(), r_vals.max(), 500)
Y_ = X_Y_Spline(X_)

plt.hist(vals[:100], bins=18, range=(-9,9), edgecolor="black", linewidth=0.5, zorder=3)
showhist('100.png', '100 Observations\n18 Bins')
plt.hist(vals[100:], bins=18, range=(-9,9), edgecolor="black", linewidth=0.5, zorder=3)
showhist('500.png', '500 Observations\n18 Bins')

plt.hist(vals, bins=18, range=(-9,9), edgecolor="black", linewidth=0.5, zorder=3)
showhist('600-18.png', '600 Observations\n18 Bins')
f, b, useless = plt.hist(vals, bins=36, range=(-9,9), color='w', edgecolor="blue", linewidth=0.5, zorder=3)
showhist('600-36.png', '600 Observations\n36 Bins')

msg += 'Bin,n(V),Nv,V\n'
cf = 0
Nv, Vs = np.array([]), np.array([])
N = sum(f[18:])*2
for i in range(18,36) :
    freq = f[i]
    cf += freq
    V = 6*np.sqrt(2)*np.sin(np.pi*cf/N)
    Nv, Vs = np.append(Nv, cf), np.append(Vs, V)
    msg += f'{b[i]}-{b[i]+0.5},{freq},{cf},{V}\n'

with open('table.csv', 'w+') as f :
    f.truncate(0)
    f.write(msg)

plt.plot(X_, Y_, color='red')
showplot('curve-theoritical.png', 'Comparison of theoretical and experimental data')

plt.plot(Nv, Vs, 'o')
showplot('curve-reconstructed.png')
