# Python code using loops

from math import factorial

if __name__ == "__main__":
    # Taylor series for approximating e^x
    x = [1.5, 4.0]
    e_pow_x = [1.0] * len(x)  # make list of ones
    for i in range(1, 20):
        for j in range(len(x)):
            e_pow_x[j] += x[j] ** i / factorial(i)
    print(e_pow_x)  # e^x = 1 + x^1/1! + x^2/2! + ...