-- - this file contains a SQL implementation of the Revised Simplex Method (RSM) 
-- - algorithmically, this SQL implementation corresponds to the 
--   Python version from rsm.py
-- - refer to rsm.py for details

---------- Example Problem ----------
-- Merz, M., & Wüthrich, M. (2013): Mathematik für Wirtschaftswissenschaftler.
-- pp. 761 -- 762
--
-- A company is considered that wants to form a portfolio from four 
-- different assets A1, A2, A3 and A4.
-- These assets differ in their expected annual returns and in their risk, 
-- which is expressed by a risk ratio.
-- 
--                                      assets
--                                A1   A2   A3   A4
-- Expected rate of return in %   3    5    10   20
-- risk ratio                     1    2     4    8
-- 
-- For the constructed portfolio it shall apply that
-- 
-- a) it has the highest possible expected return,
-- b) at least 40% is invested in asset A1 and
-- c) the risk ratio of the entire portfolio is not greater than 4.
-- 
-- For this purpose, the variables
-- x0 , x1 , x2 , x3
-- denote the assets A1, A2, A3 and A4, respectively, in the portfolio.
--
-- Maximize z(x0, x1, x2, x3) = 0.03x0 + 0.05x1 + 0.1x2 + 0.2x3
-- 
-- subject to
--                                  x0 +     x1 +    x2 +    x3  =   1
--                                  x0                          >=   0.4
--                                  x0 +    2x1 +   4x2 +   8x3 <=   4
--                                   
-- To solve it, we transform the problem with the Big M Method (M is a large number). 
-- see here for details:
-- https://en.wikipedia.org/wiki/Big_M_method
-- 
-- Reformulated (with Big M) the problem is:
-- 
-- Maximize z(x0, x1, x2, x3) = 0.03x0 + 0.05x1 + 0.1x2 + 0.2x3       -Mx5 -Mx6
-- 
-- subject to
--                                  x0 +     x1 +    x2 +    x3       + x5            =   1
--                                  x0                            -x4      + x6       =   0.4
--                                  x0 +    2x1 +   4x2 +   8x3                 + x7  =   4
--                                   
-- Results:
-- Maximum expected return z = 10.29 %
-- Optimal investments:
--                  A1 = 57.14 %
--                  A4 = 42.86 %
-- 
-- Enter problem data here --> vectors and matrices must be provided with explicit indices i and j (i=row, j=column) --> sparse COO format.
-- To generate some more sample LP problems, see "convert_examples_to_sql.py".
WITH RECURSIVE c (i, val) AS (
    VALUES     (0, 0.03),  (1, 0.05),  (2, 0.1),  (3, 0.2),              (5, -10000),  (6, -10000)
), A (i, j, val) AS (                                                              -- identity matrix
	VALUES (0, 0, 1),  (0, 1, 1), (0, 2, 1), (0, 3, 1),                (0, 5, 1),
	       (1, 0, 1),                                     (1, 4, -1),              (1, 6, 1),
	       (2, 0, 1),  (2, 1, 2), (2, 2, 4), (2, 3, 8),                                        (2, 7, 1)
), b (i, val) AS (
	VALUES (0, 1.0),
	       (1, 0.4),
	       (2, 4)
----------  revised simplex method starts here   ----------
), c_internal (i, val) AS (
  SELECT CAST(i AS INTEGER), CAST(val AS DOUBLE PRECISION) FROM c WHERE val > 2.220446049250313e-16 OR val < -2.220446049250313e-16
), A_internal (i, j, val) AS (
  SELECT CAST(i AS INTEGER), CAST(j AS INTEGER), CAST(val AS DOUBLE PRECISION) FROM A WHERE val > 2.220446049250313e-16 OR val < -2.220446049250313e-16
), b_internal (i, val) AS (
  SELECT CAST(i AS INTEGER), CAST(val AS DOUBLE PRECISION) FROM b
), info_message(idx, info_message) AS (
  VALUES (1, 'optimal solution found'),
	 (2, 'solution is infeasible because not all negative Big M starting basic variables could be replaced'),
	 (3, 'unbounded maximization problem'),
	 (4, 'ERROR: all values in b must be >= 0, multiply corresponding constraints by -1 and use Big M method to handle >= b[i]'),
	 (5, 'ERROR: number of values in b does not match the number of constraints'),
	 (6, 'ERROR: duplicates of index i exist in c'),
	 (7, 'ERROR: duplicates of index-tuples (i, j) exist in A'),
	 (8, 'ERROR: duplicates of index i exist b'),
	 (9, 'ERROR: invalid identity matrix of slack variables'),
	(10, 'ERROR: NULL values in c'),
	(11, 'ERROR: NULL values in A'),
	(12, 'ERROR: NULL values in b'),
	(13, 'ERROR: at least one column contains only zeros in A')
), m (m) AS ( -- number of constraints
  SELECT CAST(COUNT(i) AS INTEGER) FROM b_internal
), n (n) AS ( -- number of problem variables (without slack variables)
  SELECT CAST(MAX(j) + 1 - (SELECT * FROM m) AS INTEGER) FROM A_internal
), E (i, j, val) AS ( -- extract identity matrix
  SELECT * FROM (SELECT i, CAST(j - n AS INTEGER), CAST(val AS DOUBLE PRECISION) FROM A_internal, n WHERE j >= n) tmp
----- BEGIN error checking --> is the maximization problem valid? ("input validation")
), is_negative_b(is_negative_b) AS ( -- 4
  SELECT COUNT(true) <> 0 FROM b_internal WHERE val < 0
), is_wrong_amount_in_b(is_wrong_amount_in_b) AS ( -- 5
  SELECT m <> (SELECT COUNT(DISTINCT i) FROM A_internal) FROM m
), is_duplicates_in_c(is_duplicates_in_c) AS ( -- 6
  SELECT COUNT(DISTINCT i) <> COUNT(i) FROM c_internal
), is_duplicates_A(is_duplicates_A) AS ( -- 7 must test this for efficiency
  SELECT COUNT(DISTINCT CONCAT(i,'-',j)) <> COUNT(CONCAT(i,'-',j)) FROM A_internal
), is_duplicates_in_b(is_duplicates_in_b) AS ( -- 8
  SELECT COUNT(DISTINCT i) <> COUNT(i) FROM b_internal
), is_invalid_E(is_invalid_E) AS ( -- 9
  SELECT * FROM (
		WITH is_ones_in_diagonal(is_ones_in_diagonal) AS (
		   SELECT COUNT(*) = (SELECT m FROM m) FROM E WHERE val = 1.0 AND i = j
		), is_all_non_diagonal_zero(is_all_non_diagonal_zero) AS (
		   SELECT COUNT(*) = 0 FROM E WHERE val <> 0.0 AND i <> j
		)
  SELECT NOT (is_ones_in_diagonal AND is_all_non_diagonal_zero) FROM is_ones_in_diagonal, is_all_non_diagonal_zero) t1
), is_null_in_c(is_null_in_c) AS ( -- 10
  SELECT COUNT(*) > 0 FROM c_internal WHERE i IS NULL OR val IS NULL
), is_null_in_A(is_null_in_A) AS ( -- 11
  SELECT COUNT(*) > 0 FROM A_internal WHERE i IS NULL OR j IS NULL OR val IS NULL
), is_null_in_b(is_null_in_b) AS ( -- 12
  SELECT COUNT(*) > 0 FROM b_internal WHERE i IS NULL OR val IS NULL
), is_zero_column_in_A(is_zero_column_in_A) AS ( -- 13
  SELECT COUNT(DISTINCT j) <> (SELECT n + m FROM n, m) FROM A_internal
), get_all_errors(idx) AS (
  SELECT 4 FROM is_negative_b WHERE is_negative_b UNION ALL
  SELECT 5 FROM is_wrong_amount_in_b WHERE is_wrong_amount_in_b UNION ALL
  SELECT 6 FROM is_duplicates_in_c WHERE is_duplicates_in_c UNION ALL
  SELECT 7 FROM is_duplicates_A WHERE is_duplicates_A UNION ALL
  SELECT 8 FROM is_duplicates_in_b WHERE is_duplicates_in_b UNION ALL
  SELECT 9 FROM is_invalid_E WHERE is_invalid_E UNION ALL
  SELECT 10 FROM is_null_in_c WHERE is_null_in_c UNION ALL
  SELECT 11 FROM is_null_in_A WHERE is_null_in_A UNION ALL
  SELECT 12 FROM is_null_in_b WHERE is_null_in_b UNION ALL
  SELECT 13 FROM is_zero_column_in_A WHERE is_zero_column_in_A
----- END error checking
), c_all AS (
  SELECT j AS i, t1.val + COALESCE(c_internal.val, 0) AS val FROM n, (
	   WITH RECURSIVE seq(j, val) AS (
	       SELECT 0, 0.0
	       UNION ALL
	       SELECT j + 1, 0.0 FROM seq WHERE j < (SELECT n + m FROM m, n)
	   )
	   SELECT * FROM seq
  ) t1 LEFT JOIN c_internal ON j = c_internal.i
), negative_slack_indices(idx) AS (
  SELECT i FROM c WHERE i >= (SELECT * FROM n) AND val < -1e-12
), B_inv (iter, exit_flag, i, j, val) AS ( -- exit_flag: 1 = solution found, 2 = infeasible, 3 = unbounded
  SELECT * FROM (SELECT 0, -1, * FROM E UNION ALL SELECT 0, -1, i, i + n, NULL FROM b_internal, n) tmp WHERE (SELECT COUNT(*) FROM get_all_errors) = 0
  UNION ALL
  SELECT iter + 1, exit_flag, i, j, val FROM(
    WITH B_inv_last AS (
      SELECT * FROM B_inv WHERE exit_flag = -1
    ), Mappings AS ( -- extract mappings to base variables
      SELECT * FROM B_inv_last WHERE val IS NULL
    ), B_1 AS ( -- extract inverted base matrix
      SELECT * FROM B_inv_last WHERE val IS NOT NULL
    ), B_inv_b AS ( -- B_inv_b = B_inv.dot(b)
      SELECT B_1.i AS i, SUM(B_1.val * b_internal.val) AS val FROM B_1, b_internal WHERE B_1.j = b_internal.i GROUP BY B_1.i
    ), c_B AS ( -- c_B = c[B_idx], get c's of all base variables
      SELECT Mappings.i AS i, c_all.val AS val FROM Mappings JOIN c_all ON c_all.i = Mappings.j
    ), c_B_B_inv AS ( -- c_B_B_inv = c_B.dot(B_inv)
      SELECT B_1.j AS j, SUM(c_B.val * B_1.val) AS val FROM n, B_1 JOIN c_B ON c_B.i = B_1.i GROUP BY B_1.j
    ), c_B_B_inv_A AS ( -- c_B_B_inv.dot(A[:,list(range(n))])
      SELECT A_internal.j AS j, SUM(A_internal.val * c_B_B_inv.val) AS val FROM c_B_B_inv, A_internal, n WHERE A_internal.j NOT IN (SELECT j AS i FROM Mappings) AND c_B_B_inv.j = A_internal.i AND A_internal.j < n GROUP BY A_internal.j
    ), c_B_B_inv_A_c AS (
      SELECT i AS j, COALESCE(t.val, 0) - c_all.val AS val FROM c_B_B_inv_A t JOIN c_all ON c_all.i = t.j
    ), _c AS (
      SELECT * FROM c_B_B_inv_A_c UNION ALL SELECT c_B_B_inv.j + n AS j, c_B_B_inv.val AS val FROM n, c_B_B_inv, Mappings WHERE c_B_B_inv.j = Mappings.i AND c_B_B_inv.j + n NOT IN (SELECT j FROM Mappings) AND c_B_B_inv.j + n NOT IN (SELECT idx FROM negative_slack_indices)
    ), min_c AS (
      SELECT x_enter, val FROM (SELECT j AS x_enter, val, ROW_NUMBER() OVER() rn FROM _c WHERE val = (SELECT MIN(val) FROM _c)) tmp WHERE rn = 1
    -- test for optimality
    ), is_optimal(is_optimal) AS ( -- c_min + EPS >= 0
      SELECT (SELECT val + 1e-12 >= 0 FROM min_c) OR (SELECT COUNT(*) = 0 FROM min_c)
    ), is_in_n(is_in_n) AS (
      SELECT CASE WHEN x_enter < n THEN 1 ELSE 0 END FROM min_c, n
    ), p_prime AS (
      SELECT i AS j, B_1.val AS val FROM is_in_n, min_c, n, B_1 WHERE is_in_n = 0 AND B_1.j = x_enter - n UNION ALL
      SELECT B_1.i AS j, SUM(t1.val * B_1.val) AS val FROM is_in_n, B_1, (SELECT i AS j, A_internal.val FROM A_internal, min_c WHERE A_internal.j = min_c.x_enter) t1 WHERE is_in_n = 1 AND B_1.j = t1.j GROUP BY B_1.i
    ), x_B_div_col AS (
      SELECT j, B_inv_b.val / p_prime.val AS val FROM p_prime, B_inv_b WHERE p_prime.val > 1e-12 AND p_prime.j = B_inv_b.i
    -- test for unboundness
    ), is_unbounded(is_ubounded) AS (
      SELECT NOT is_optimal AND (SELECT COUNT(*) = 0 FROM x_B_div_col) FROM is_optimal
    -- test for infeasibility
    ), is_infeasible(is_infeasible) AS (
      SELECT is_optimal AND (SELECT COUNT(*) <> 0 FROM Mappings, B_inv_b WHERE B_inv_b.i = Mappings.i AND Mappings.j IN (SELECT idx FROM negative_slack_indices) AND B_inv_b.val > 0) FROM is_optimal ----
    ), min_leave AS (
      SELECT x_leave, val FROM (SELECT j AS x_leave, val, ROW_NUMBER() OVER() rn FROM x_B_div_col WHERE val = (SELECT MIN(val) AS val FROM x_B_div_col)) tmp WHERE rn = 1
    ), new_Mappings AS (
      SELECT iter, exit_flag, i, j, Mappings.val FROM min_leave, Mappings WHERE i <> min_leave.x_leave  UNION ALL
      SELECT iter, exit_flag, i, x_enter AS j, Mappings.val FROM min_c, min_leave, Mappings WHERE i = min_leave.x_leave
    ), mult_val(mult_val) AS (
      SELECT 1.0 / p_prime.val FROM p_prime, min_leave WHERE j = x_leave
    ), new_E AS (
      SELECT i, j, E.val FROM E, min_leave WHERE j <> x_leave UNION ALL
      SELECT j AS i, x_leave AS j, p_prime.val * -mult_val AS val FROM p_prime, mult_val, min_leave WHERE j <> x_leave UNION ALL
      SELECT x_leave, x_leave, mult_val FROM min_leave, mult_val
    ), new_B_inv AS (
      SELECT new_E.i, B_1.j, SUM(new_E.val * B_1.val) AS val FROM new_E, B_1 WHERE new_E.j = B_1.i GROUP BY new_E.i, B_1.j
    ), new_B_inv_result AS (
      SELECT iter, exit_flag, new_B_inv.i, new_B_inv.j, new_B_inv.val FROM new_B_inv, (SELECT * FROM (SELECT *, ROW_NUMBER() OVER() rn FROM new_Mappings) t1 WHERE rn = 1) t2 UNION ALL SELECT * FROM new_Mappings
    ), new_exit_num(new_exit_num) AS (
      SELECT CAST((SELECT * FROM is_optimal) AS INTEGER) + CAST((SELECT * FROM  is_infeasible) AS INTEGER) + CAST((SELECT * FROM is_unbounded) AS INTEGER) * 3
    ), choose_result AS (
      SELECT * FROM new_B_inv_result WHERE NOT (SELECT CAST(new_exit_num AS BOOLEAN) FROM  new_exit_num) UNION ALL SELECT iter, (SELECT * FROM new_exit_num), i, j, val FROM B_inv_last WHERE (SELECT CAST(new_exit_num AS BOOLEAN) FROM  new_exit_num)
    ) SELECT iter, exit_flag, i, j, val FROM choose_result
    ) mock WHERE TRUE -- mock is empty if we are done
), B_inv_last AS (
  SELECT * FROM B_inv WHERE exit_flag > -1
), Mappings AS ( -- extract mappings to base variables
  SELECT * FROM B_inv_last WHERE val IS NULL
), B_1 AS ( -- extract inverted base matrix
  SELECT * FROM B_inv_last WHERE val IS NOT NULL
), B_inv_b AS ( -- B_inv_b = B_inv.dot(b)
  SELECT B_1.i AS i, SUM(B_1.val * b_internal.val) AS val FROM B_1, b_internal WHERE B_1.j = b_internal.i GROUP BY B_1.i
), c_B AS ( -- c_B = c[B_idx], get c's of all base variables
  SELECT Mappings.i AS i, c_all.val AS val FROM Mappings JOIN c_all ON c_all.i = Mappings.j
), z(z) AS (  -- print("z =", c_B.dot(B_inv_b))
  SELECT SUM(B_inv_b.val * c_B.val) AS val FROM c_B, B_inv_b WHERE B_inv_b.i = c_B.i
), x_B AS ( -- print("x_B =", sorted(list(zip(B_idx, B_inv_b))))
  SELECT j as var, B_inv_b.val FROM B_inv_b, Mappings WHERE B_inv_b.i = Mappings.i ORDER BY j
), smallest_exit_flag AS (
  SELECT MIN(idx) AS idx FROM (SELECT idx FROM get_all_errors UNION ALL SELECT exit_flag FROM (SELECT exit_flag, ROW_NUMBER() OVER() rn FROM B_inv_last) t1 WHERE rn = 1) t1
), get_info_message(idx, info_message) AS (
  SELECT idx, info_message FROM info_message WHERE idx = (SELECT * FROM smallest_exit_flag)
), get_non_zero_variables(var, val) AS (
  SELECT * FROM x_B WHERE var < (SELECT n FROM n) AND val > 1e-12
), get_non_zero_slack_variables(var, val) AS (
  SELECT * FROM x_B WHERE var >= (SELECT n FROM n) AND val > 1e-12
), pretty_print(result, values) AS (
  SELECT 'message:', info_message FROM get_info_message UNION ALL
  SELECT 'success:', CAST(idx = 1 AS TEXT) FROM get_info_message UNION ALL
  SELECT 'max z:', CAST(z AS TEXT) FROM z WHERE z IS NOT NULL UNION ALL
  SELECT 'nonzero x:', txt FROM (SELECT ARRAY_TO_STRING(ARRAY(SELECT 'x' || CAST(var AS TEXT) || '=' || CAST(val AS TEXT) FROM get_non_zero_variables ORDER BY var), ', ') AS txt) t1 WHERE txt <> '' UNION ALL
  SELECT 'nonzero slack vars:', txt FROM (SELECT ARRAY_TO_STRING(ARRAY(SELECT 'x' || CAST(var AS TEXT) || '=' || CAST(val AS TEXT) FROM get_non_zero_slack_variables ORDER BY var), ', ') AS txt) t1 WHERE txt <> '' UNION ALL
  SELECT 'iterations:', CAST( iter AS TEXT) FROM (SELECT iter FROM (SELECT iter, ROW_NUMBER() OVER() rn FROM B_inv_last) t1 WHERE rn = 1) t1 WHERE iter IS NOT NULL
)

SELECT * FROM pretty_print



