# this file contains some LP problems
import numpy as np

def problem_basic():
  # Merz, M., & Wüthrich, M. (2013): Mathematik für Wirtschaftswissenschaftler.
  # p. 763
  #
  # Maximize 2x1 + 3x2
  #
  # subject to
  # 4x1 + 3x2 <= 600
  # 2x1 + 2x2 <= 320
  # 3x1 + 7x2 <= 840
  #
  # x1, x2 >= 0
  c = np.array([ 2, 3,   0, 0, 0])
  A = np.array([[4, 3,   1, 0, 0],
                [2, 2,   0, 1, 0],
                [3, 7,   0, 0, 1]])
  b = np.array([600, 320, 840])
  return c, A, b

def problem_portfolio():
  # Merz, M., & Wüthrich, M. (2013): Mathematik für Wirtschaftswissenschaftler.
  # pp. 761 -- 762
  #
  # Maximize 0.03x1 + 0.05x2 + 0.1x3 + 0.2x4
  #
  # subject to
  # x1 +     x2 +    x3 +    x4  =   1
  # x1                          >=   0.4
  # x1 +    2x2 +   4x3 +   8x4 <=   4
  #
  # x1, x2, x3, x4 >= 0
  M = -1000000
  c = np.array([0.03, 0.05, 0.1, 0.2,   0,   M, M, 0])
  A = np.array([[  1,    1,   1,   1,   0,   1, 0, 0],
                [  1,    0,   0,   0,  -1,   0, 1, 0],
                [  1,    2,   4,   8,   0,   0, 0, 1]])
  b = np.array([1, 0.4, 4])
  return c, A, b

def problem_dietary():
  # Matousek, J., & Gärtner, B. (2007): Understanding and using linear programming.
  # p. 12
  #
  # Minimize 0.75x1 + 0.5x2 + 0.15x3
  #
  # subject to
  # 35x1 + 0.5x2 + 0.5x3 >= 0.5
  # 60x1 + 300x2 + 10x3 >= 15
  # 30x1 + 20x2 + 10x3 >= 4.
  #
  # x1, x2, x3 >= 0
  M = -1000000
  c = np.array([-0.75, -0.5, -0.15,   0, 0, 0,   M, M, M])
  A = np.array([[  35,  0.5,   0.5,  -1, 0, 0,   1, 0, 0],
                [  60,  300,    10,   0,-1, 0,   0, 1, 0],
                [  30,   20,    10,   0, 0,-1,   0, 0, 1]])
  b = np.array([0.5, 15, 4])
  return c, A, b

# this is an important edge case that can happen
def problem_c_B_B_inv_negatives_values():
  # https://www.youtube.com/watch?v=npHOAgrYOos
  # optimum: x5 = 22, x6 = 24, z = 160
  #
  # Maximize 4x1 + 3x2 + 2x3 + 5x4 + 4x5 + 3x6
  #
  # subject to
  # 3x1 + 3x2       +  x4 + x5 - x6 <= 42
  #  x1 +       2x3 + 3x4 + x5 + x6 <= 50
  # 3x1 +  x2 + 2x3 +  x4 + 2x5     <= 44
  #  x1 + 2x2 +  x3 + 3x4 +     2x6 <= 48
  #
  # x1, x2, x3, x4, x5, x6 >= 0
  c = np.array([ 4, 3, 2, 5, 4, 3,   0, 0, 0, 0])
  A = np.array([[3, 3, 0, 1, 1,-1,   1, 0, 0, 0],
                [1, 0, 2, 3, 1, 1,   0, 1, 0, 0],
                [3, 1, 2, 1, 2, 0,   0, 0, 1, 0],
                [1, 2, 1, 3, 0, 2,   0, 0, 0, 1]])
  b = np.array([42, 50, 44, 48])
  return c, A, b

def problem_unbounded():
  # Matousek, J., & Gärtner, B. (2007): Understanding and using linear programming.
  # p. 61
  #
  # Maximize x1
  #
  # subject to
  #  x1 - x2 <= 1
  # -x1 + x2 <= 2
  #
  # x1, x2 >= 0
  c = np.array([  1, 0,   0, 0])
  A = np.array([[ 1,-1,   1, 0],
                [-1, 1,   0, 1]])
  b = np.array([1, 2])
  return c, A, b

def problem_infeasible():
  # http://web.mit.edu/lpsolve_v5525/doc/Infeasible.htm
  #
  # Minimize x1 + x2
  # subject to
  # x1      >= 6
  #      x2 >= 6
  # x1 + x2 <= 11
  #
  # x1, x2 >= 0
  M = -1000000
  c = np.array([-1,-1,   0, 0,   M, M, 0])
  A = np.array([[1, 0,  -1, 0,   1, 0, 0],
                [0, 1,   0,-1,   0, 1, 0],
                [1, 1,   0, 0,   0, 0, 1]])
  b = np.array([6, 6, 11])
  return c, A, b

def problem_degenerated():
  # Matousek, J., & Gärtner, B. (2007): Understanding and using linear programming.
  # p. 62
  #
  # Maximize x2
  #
  # subject to
  #  -x1 + x2 <= 0
  #   x1      <= 2
  #
  # x1, x2 >= 0
  c = np.array([  0, 1,   0, 0])
  A = np.array([[-1, 1,   1, 0],
                [ 1, 0,   0, 1]])
  b = np.array([0, 2])
  return c, A, b


# https://math.stackexchange.com/questions/244142/generating-random-linear-programming-problems
def generate_random_LP(m, n, density=1.0, seed=0):
  np.random.seed(seed)
  c = np.random.uniform(low=-100, high=100, size=(n,))
  A = np.random.uniform(low=-1, high=100, size=(m, n))
  A *= np.random.uniform(low=0, high=1, size=(m, n)) < density
  x_opt = np.random.randint(100, size=n)
  b = A.dot(x_opt) + np.random.uniform(low=1, high=10, size=(m,))
  A_and_S = np.hstack((A, np.identity(m)))  # add slack variables
  return np.hstack((c, np.zeros(m))), A_and_S, b
