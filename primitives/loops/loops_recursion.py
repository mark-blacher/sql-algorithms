# Python code using loops with recursion

from math import sin, cos

if __name__ == "__main__":
    # Newton's method: compute x so that
    # f(x) = x^2 + cos(x) + 2 * sin(x) is minimized
    x = 0
    while True:
        fD = 2 * x - sin(x) + 2 * cos(x)  # f'
        if abs(fD) < 1e-6:
            break
        fD2 = 2 - cos(x) - 2 * sin(x)  # f''
        x -= fD / fD2  # update x
    print(x)  # -0.975012