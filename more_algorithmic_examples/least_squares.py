import numpy as np


# https://johnfoster.pge.utexas.edu/numerical-methods-book/LinearAlgebra_LU.html
def cholesky_decomposition(M):
    """
    Compute the cholesky decomposition of a SPD matrix M.
    :param M: (N, N) real valued matrix.
    :return: R: (N, N) upper triangular matrix with positive diagonal entries if M is SPD.
    """

    A = np.copy(M).astype('float64')
    n = A.shape[0]
    R = np.zeros_like(A).astype('float64')

    for k in range(n):
        R[k, k] = np.sqrt(A[k, k])
        R[k, k + 1:] = A[k, k + 1:] / R[k, k]
        A[k + 1:, k + 1:] -= np.triu(np.outer(R[k, k + 1:], R[k, k + 1:]))

    return R


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


def cholesky_solve(A, b):
    U = cholesky_decomposition(A)
    L = U.T

    y = forward_substitution(L, b)
    return back_substitution(U, y)


if __name__ == "__main__":
    # Interest_Rate, Unemployment_Rate, Intercept
    # https://datatofish.com/multiple-linear-regression-python/
    X = np.array([[2.75, 5.3, 1.],
                  [2.5, 5.3, 1.],
                  [2.5, 5.3, 1.],
                  [2.5, 5.3, 1.],
                  [2.5, 5.4, 1.],
                  [2.5, 5.6, 1.],
                  [2.5, 5.5, 1.],
                  [2.25, 5.5, 1.],
                  [2.25, 5.5, 1.],
                  [2.25, 5.6, 1.],
                  [2., 5.7, 1.],
                  [2., 5.9, 1.],
                  [2., 6., 1.],
                  [1.75, 5.9, 1.],
                  [1.75, 5.8, 1.],
                  [1.75, 6.1, 1.],
                  [1.75, 6.2, 1.],
                  [1.75, 6.1, 1.],
                  [1.75, 6.1, 1.],
                  [1.75, 6.1, 1.],
                  [1.75, 5.9, 1.],
                  [1.75, 6.2, 1.],
                  [1.75, 6.2, 1.],
                  [1.75, 6.1, 1.]], dtype=np.double)

    # Stock_Index_Price
    y = np.array(
        [1464, 1394, 1357, 1293, 1256, 1254, 1234, 1195, 1159, 1167, 1130, 1075, 1047, 965, 943, 958, 971, 949, 884,
         866, 876, 822, 704, 719], dtype=np.double)

    # inefficient numpy way
    coff = np.linalg.inv(X.T.dot(X)).dot(X.T).dot(y)
    print(coff)

    # efficient numpy way
    coff2 = np.linalg.solve(X.T.dot(X), X.T.dot(y))
    print(coff2)

    # cholesky
    coff3 = cholesky_solve(X.T.dot(X), X.T.dot(y))
    print(coff3)
