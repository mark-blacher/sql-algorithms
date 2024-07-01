WITH RECURSIVE features(val) AS (
  VALUES (20::int)
), samples(val) AS (
  VALUES (10000::int)
-- generate data and run least squares
), Xdata(i, j, val) AS (
  SELECT s1 AS i, s2 AS j, RANDOM() AS val FROM GENERATE_SERIES(0, (SELECT val - 1 FROM samples)) s1, GENERATE_SERIES(0, (SELECT val - 1 FROM features)) s2
), ydata(i, val) AS (
  SELECT s AS i, RANDOM() AS val FROM GENERATE_SERIES(0, (SELECT val - 1 FROM samples)) s
--- here starts the least squares computation ---
), M(i, j, val) AS ( -- X.T.dot(X)
  SELECT X1.j, X2.j,  SUM(X1.val * X2.val) FROM Xdata X1, Xdata X2 WHERE X1.i=X2.i GROUP BY X1.j, X2.j HAVING X2.j >= X1.j
), b(i, val) AS ( -- X.T.dot(y)
  SELECT X.j, SUM(X.val * y.val) FROM Xdata X, ydata y WHERE X.i=y.i GROUP BY X.j
), n(val) AS (
  SELECT MAX(i) + 1 FROM M
), RA(i, j, val, is_R, idx) AS ( -- Cholesky decomposition
  SELECT i, j, val, false, 0::int FROM M
UNION ALL
  SELECT i, j, val, is_R, idx + 1 FROM (
    WITH RA(i, j, val, is_R, idx) AS (
	  SELECT * FROM RA
	), Rkk(i, j, val, is_R, idx) AS (
	  SELECT i, j, SQRT(val), true, idx FROM RA WHERE i=idx AND j=idx
	), Rkkp1(i, j, val, is_R, idx) AS (
	  SELECT i, j, val / (SELECT val FROM Rkk), true, idx FROM RA WHERE i=idx AND j>idx
	), triuouterproduct(i, j, val) AS (
	  SELECT p1.j, p2.j, p1.val * p2.val FROM Rkkp1 p1, Rkkp1 p2 WHERE p2.j>=p1.j
	), A_slice(i, j, val, is_R, idx) AS (
	  SELECT RA.i, RA.j, RA.val - op.val, false, RA.idx FROM RA, triuouterproduct op WHERE RA.i=op.i AND RA.j=op.j
	) SELECT * FROM Rkk UNION ALL SELECT * FROM Rkkp1 UNION ALL SELECT * FROM A_slice
  ) AS tmp WHERE idx < (SELECT * FROM n)
), U(i, j, val) AS (
  SELECT i, j, val FROM RA WHERE is_R=true
), yy(i, val, idx) AS ( -- forward substitution
  SELECT i, val / (SELECT val FROM U WHERE i=0 AND j=0), 1::int FROM b WHERE i=0
UNION ALL
  SELECT i, val, idx + 1 FROM (
    WITH yy(i, val, idx) AS (
	  SELECT * FROM yy
	), L_dot_y(val, idx) AS (
	  SELECT SUM(yy.val * U.val), idx FROM yy, U WHERE yy.i=U.i AND U.j=idx GROUP BY idx
	), y_idx(i, val, idx) AS (
	  SELECT i, (b.val - L_dot_y.val) / (SELECT val FROM U WHERE i=idx AND j=idx), idx FROM L_dot_y, b WHERE i=idx
	) SELECT * FROM yy UNION ALL SELECT * FROM y_idx
  ) AS tmp WHERE idx < (SELECT val FROM n)
), y(i, val, idx) AS (
  SELECT i, val, idx - 1 FROM yy WHERE idx=(SELECT val FROM n)
), xx(i, val, idx) AS ( -- back substitution
   SELECT idx, val / (SELECT val FROM U WHERE i=idx AND j=idx), idx - 1 FROM y WHERE i=idx
UNION ALL
  SELECT i, val, idx - 1 FROM (
	WITH xx(i, val, idx) AS (
	  SELECT * FROM xx
	), L_dot_x(val, idx) AS (
	  SELECT SUM(xx.val * U.val), idx FROM xx, U WHERE xx.i=U.j AND U.i=idx GROUP BY idx
	), x_idx(i, val, idx) AS (
	  SELECT i, (y.val - L_dot_x.val) / (SELECT val FROM U WHERE i=L_dot_x.idx AND j=L_dot_x.idx), L_dot_x.idx FROM L_dot_x, y WHERE i=L_dot_x.idx
	) SELECT * FROM xx UNION ALL SELECT * FROM x_idx
  ) AS tmp WHERE idx >= 0
), x(i, val) AS (
  SELECT i, val FROM xx WHERE idx=-1 ORDER BY i
) SELECT * FROM x ORDER by i


