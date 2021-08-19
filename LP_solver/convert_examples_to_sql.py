# this function converts a given Numpy LP problem into its SQL equivalent formulation
def convert_to_sql(c, A, b):
  _c = ""
  _b = ""
  _A = ""

  is_i_first = True
  for i in range(len(c)):
    if c[i] != 0:
      if is_i_first:
        _c += "(" + str(i) + ", CAST(" + str(c[i]) + " AS DOUBLE PRECISION)), "
        is_i_first = False
      else:
        _c += "(" + str(i) + ", " + str(c[i]) + "), "
  _c = _c[:-2] + ""

  is_i_first = True
  for i in range(len(b)):
    if is_i_first:
      _b += "(" + str(i) + ", CAST(" + str(b[i]) + " AS DOUBLE PRECISION)), "
      is_i_first = False
    else:
      _b += "(" + str(i) + ", " + str(b[i]) + "), "
  _b = _b[:-2] + ""

  is_i_first = True
  for i in range(A.shape[0]):
    for j in range(A.shape[1]):
      if A[i, j] != 0:
        if is_i_first:
          _A += "(" + str(i) + ", " + str(j) + ", CAST(" + str(A[i, j]) + " AS DOUBLE PRECISION)), "
          is_i_first = False
        else:
          _A += "(" + str(i) + ", " + str(j) + ", " + str(A[i, j]) + "), "
    _A += "\n         "
  _A = _A[:-12]

  sql_problem = """
WITH RECURSIVE c (i, val) AS (
  VALUES {0}
), A (i, j, val) AS (
  VALUES {1}
), b (i, val) AS (
  VALUES {2}
    """.format(_c, _A, _b)

  return sql_problem


if __name__ == '__main__':
  from examples import *

  c, A, b = problem_basic()
  # c, A, b = problem_portfolio()
  # c, A, b = problem_dietary()
  # c, A, b = problem_c_B_B_inv_negatives_values()
  # c, A, b = problem_unbounded()
  # c, A, b = problem_infeasible()
  # c, A, b = problem_degenerated()
  # c, A, b = generate_random_LP(m=20, n=40, density=0.5, seed=0)

  # the printed LP problem must be copied to rsm.sql
  print(convert_to_sql(c, A, b))
