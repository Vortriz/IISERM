import numpy as np
from numpy import linalg as LA
from numpy import array, identity, diagonal
from math import sqrt

import time


# ... or generate a random symmetric matrix
ndim = 5
mt = np.zeros((ndim, ndim))
for dim in range(ndim, 0, -1):
    v = 10 * np.random.rand(dim)
    if dim == ndim:
        mt = np.diag(v)
    else:
        exdim = ndim - dim
        mt += np.diag(v, -exdim) + np.diag(v, exdim)

a = np.copy(mt)


# a=np.array([[8.,-1.,3.,-1.],[-1.,6.,2.,0.],[3.,2.,9.,1.],[-1.,0.,1.,7.]])
# a=np.array([[8.,-1.,3.],[-1.,6.,2.],[3.,2.,9.]])
# a=np.array([[2.,-1.],[-1.,3.]])


# internally obtained eigen vals/vecs from numpy
print("matrix\n", a)
tic0 = time.time()
w, v = LA.eigh(a)
print("\n---Internal numpy method:--\n")

print("Numpy time", time.time() - tic0)

print("eigenvalues:\n", w)
print("vectors:\n", v)

# Jacobi method from http://w3mentor.com/learn/python/scientific-computation/python-code-for-solving-eigenvalue-problem-by-jacobis-method/


def jacobi(ain, tol=1.0e-11):  # Jacobi method
    def maxElem(a):  # Find largest off-diag. element a[k,l]
        n = len(a)
        aMax = 0.0
        for i in range(n - 1):
            for j in range(i + 1, n):
                if abs(a[i, j]) >= aMax:
                    aMax = abs(a[i, j])
                    k = i
                    l = j
        return aMax, k, l

    def rotate(a, p, k, l):  # Rotate to make a[k,l] = 0
        n = len(a)
        aDiff = a[l, l] - a[k, k]
        if abs(a[k, l]) < abs(aDiff) * 1.0e-36:
            t = a[k, l] / aDiff
        else:
            phi = aDiff / (2.0 * a[k, l])
            t = 1.0 / (abs(phi) + sqrt(phi**2 + 1.0))
            if phi < 0.0:
                t = -t
        c = 1.0 / sqrt(t**2 + 1.0)
        s = t * c
        tau = s / (1.0 + c)
        temp = a[k, l]

        a[k, l] = 0.0
        a[k, k] = a[k, k] - t * temp
        a[l, l] = a[l, l] + t * temp
        for i in range(k):  # Case of i < k
            temp = a[i, k]
            a[i, k] = temp - s * (a[i, l] + tau * temp)
            a[i, l] = a[i, l] + s * (temp - tau * a[i, l])
        for i in range(k + 1, l):  # Case of k < i < l
            temp = a[k, i]
            a[k, i] = temp - s * (a[i, l] + tau * a[k, i])
            a[i, l] = a[i, l] + s * (temp - tau * a[i, l])
        for i in range(l + 1, n):  # Case of i > l
            temp = a[k, i]
            a[k, i] = temp - s * (a[l, i] + tau * temp)
            a[l, i] = a[l, i] + s * (temp - tau * a[l, i])
        for i in range(n):  # Update transformation matrix
            temp = p[i, k]
            p[i, k] = temp - s * (p[i, l] + tau * p[i, k])
            p[i, l] = p[i, l] + s * (temp - tau * p[i, l])

    a = np.copy(ain)
    n = len(a)
    maxRot = 5 * (n**2)  # Set limit on number of rotations
    p = identity(n) * 1.0  # Initialize transformation matrix

    for i in range(maxRot):  # Jacobi rotation loop
        aMax, k, l = maxElem(a)
        if aMax < tol:
            return diagonal(a), p
        rotate(a, p, k, l)

    print("Jacobi method did not converge")


print("\n---Jacobi method:---\n")

tic = time.time()
wj, vj = jacobi(a)

print("Jacobi time", time.time() - tic)
print("eigenvalues:\n", wj)
print("vectors:\n", vj)

# compare the sorted eigenvalues

print("\n Jacobi:\n", np.sort(wj))
print("\n Numpy native:\n", np.sort(w))
