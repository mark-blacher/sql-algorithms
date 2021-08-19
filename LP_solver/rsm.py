# - this file contains a Numpy implementation of the Revised Simplex Method (RSM)
#   (see function "rsm_numpy")
# - for algorithmic details see:
#   Hillier, Frederick S. (2014): Introduction to Operations Research.
# - RSM is used to solve Linear Programs (LP)
# - in vectorized notation, an LP optimization problem can be described as follows:
#
#     parameters
#        matrix A
#        vector b, c
#     variables
#        vector x
#     max
#        c'*x
#     st
#        A*x <= b
#        x >= 0
#
# - to compute with "rsm_numpy" a correct result, the LP problem formulation must comply with the following rules:
#   - Minimization LP problems must be transformed into maximization LP problems
#   - constraints of type "... >= b" and "... = b" need to be transformed with Big M Method
#     (https://en.wikipedia.org/wiki/Big_M_method) to constraints of type "... <= b"
#   - all values in b must be greater than or equal to 0 (b >= 0)
#   - the identity matrix for the starting basic variables in A must be provided explicitly
#   - cost c for starting basic variables can be only zero or a large negative number (Big M)
#   --> see "examples.py" for some example problems and how they are transformed to meet
#       the requirements for this RSM implementation

import time
import numpy as np


# helper class for returning and printing the results
class Rsm_Result:
  def __init__(self, message, success, z, x, slack, nit, sec, concise=False):
    self.message = message
    self.success = success
    self.z = z
    self.x = x
    self.slack = slack
    self.nit = nit
    self.sec = sec
    self.concise = concise

  def __str__(self):
    x = ""
    if not self.concise:
      x += "x:       " + str(self.x) + "\n" + "slack:   " + str(self.slack) + "\n"

    return "message: " + self.message + "\n" + \
           "success: " + str(self.success) + "\n" + \
           "max z:   " + str(self.z) + "\n" + \
           x + \
           "nit:     " + str(self.nit) + "\n" + \
           "seconds: " + str(self.sec)

# Revised Simplex Method
# find a vector x
# that maximizes c'x
# subject to Ax <= b
# and x >= 0
def rsm_numpy(c, A, b):
  tic = time.time()
  success = False
  z = -np.inf
  x_B = []
  EPS = 1e-12
  m = A.shape[0]  # amount constraints
  n = A.shape[1] - m  # amount variables
  B_idx = np.array(list(range(n, n + m)))
  c_all = c
  iteration = 1

  lt_zero_slack = np.where(c[B_idx] < -EPS)[0] + n

  B_inv = np.identity(m)
  E = np.identity(m)

  message = ""

  while True:
    B_inv_b = B_inv.dot(b)
    if len(np.where(B_inv_b < -EPS)[0]) != 0:
      # The implementation does not support finding a valid starting point
      print("infeasible --> values in b must be >= 0")
      exit(-1)

    c_B = c_all[B_idx]
    c_B_B_inv = c_B.dot(B_inv)

    _c = np.hstack((c_B_B_inv.dot(A[:, list(range(n))]) - c[list(range(n))], c_B_B_inv))
    _c[B_idx] = np.inf  # set values of items in the base to infinity
    _c[lt_zero_slack] = np.inf  # negative slack (BIG M) can't become a member of the base
    c_min = np.min(_c)

    if c_min + EPS >= 0:
      message = "optimal solution found"
      success = True
      z = c_B.dot(B_inv_b)
      x_B = list(zip(B_idx, B_inv_b))

      # test for BIG M infeasibility
      lt_zero_in_B = list(set(lt_zero_slack) & set(B_idx))
      if lt_zero_in_B and len(np.where(B_inv_b[np.where(B_idx == lt_zero_in_B)[0]] != 0)[0]):
        message = "solution is infeasible because not all negative Big M starting basic variables could be replaced"
        success = False
      break

    x_enter = np.where(_c == c_min)[0][0]
    if x_enter < n:
      p_prime = B_inv.dot(A[:, x_enter])
    else:
      p_prime = B_inv[:, x_enter - n]

    idx_gt_zero = np.where(p_prime > EPS)[0]
    if len(idx_gt_zero) == 0:
      message = "unbounded maximization problem"
      z = c_B.dot(B_inv_b)
      x_B = list(zip(B_idx, B_inv_b))
      break
    x_B_div_col = B_inv_b[idx_gt_zero] / p_prime[idx_gt_zero]

    x_leave_min = np.min(x_B_div_col)
    x_leave = idx_gt_zero[np.where(x_B_div_col == x_leave_min)[0][0]]

    B_idx[x_leave] = x_enter
    # update old inverse instead computing new one
    mult_val = np.longdouble(1) / p_prime[x_leave]
    E[:, x_leave] = p_prime * -mult_val
    E[:, x_leave][x_leave] = mult_val
    B_inv = E.dot(B_inv)

    E[:, x_leave] = 0
    E[x_leave, x_leave] = 1
    iteration += 1

  toc = time.time()

  x = np.zeros(n)
  slack = np.zeros(m)

  for item in x_B:
    if item[0] < n:
      x[item[0]] = item[1]
    else:
      slack[item[0] - n] = item[1]

  return Rsm_Result(message, success, z, x, slack, iteration, toc - tic)


if __name__ == '__main__':
  # import the sample LP problems
  from examples import *

  c, A, b = problem_basic()
  # c, A, b = problem_portfolio()
  # c, A, b = problem_dietary()
  # c, A, b = problem_c_B_B_inv_negatives_values()
  # c, A, b = problem_unbounded()
  # c, A, b = problem_infeasible()
  # c, A, b = problem_degenerated()
  # c, A, b = generate_random_LP(m=20, n=40, density=0.5, seed=0)

  # solve LP problem
  result = rsm_numpy(c, A, b)
  # if True then do not output variables
  result.concise = False
  print(result)
