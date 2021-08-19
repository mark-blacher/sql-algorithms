# Python code giving error massages

from math import log2

if __name__ == "__main__":

    probs = [0.1, 0.4, 0.5]
    errors = []
    if any(p < 0 for p in probs) == True:
        errors += ["ERROR: negative probabilities"]
    if abs(sum(probs) - 1.0) > 1e-16:
        errors += ["ERROR: sum of probabilities != 1.0"]
    if len(errors):
        print(*errors, sep='\n')
    else:
        entropy = -sum([p * log2(p) for p in probs])
    print(entropy)