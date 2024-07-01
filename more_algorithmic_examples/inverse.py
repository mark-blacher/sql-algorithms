import numpy as np


# https://johnfoster.pge.utexas.edu/numerical-methods-book/LinearAlgebra_LU.html
def lu_decomposition(A):
    n = A.shape[0]

    U = A.copy().astype('float64')
    L = np.eye(n, dtype=np.float64)

    for i in range(n - 1):
        factor = U[i + 1:, i] / U[i, i]
        L[i + 1:, i] = factor
        U[i + 1:, :] -= np.outer(factor, U[i, :])

    return L, U


def forward_substitution(L, b):
    # get number of rows
    n = L.shape[0]
    y = np.zeros_like(b, dtype=np.double)
    y[0] = b[0] / L[0, 0]

    for i in range(1, n):
        y[i] = (b[i] - np.dot(L[i, :i], y[:i])) / L[i, i]
    return y


def back_substitution(U, y):
    # number of rows
    n = U.shape[0]
    x = np.zeros_like(y, dtype=np.double)
    x[-1] = y[-1] / U[-1, -1]

    for i in range(n - 2, -1, -1):
        x[i] = (y[i] - np.dot(U[i, i:], x[i:])) / U[i, i]
    return x


def lu_solve(A, b):
    L, U = lu_decomposition(A)
    y = forward_substitution(L, b)

    return back_substitution(U, y)


def lu_inverse(A):
    n = A.shape[0]

    Ainv = np.zeros((n, n)).astype('float64')
    b = np.eye(n, dtype=np.double)
    L, U = lu_decomposition(A)

    for i in range(n):
        y = forward_substitution(L, b[i, :])
        Ainv[:, i] = back_substitution(U, y)

    return Ainv


if __name__ == "__main__":
    M = np.array([[4, 12, -16, 34],
                  [24, 37, -43, 3],
                  [-10, -430, 98, -13],
                  [39, 3, -13, 177]])

    print(np.linalg.inv(M))
    print()
    print(lu_inverse(M))
