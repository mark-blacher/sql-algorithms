WITH RECURSIVE Xdata(i, j, val) AS ( 
  VALUES  (0::int,0::int,2.75::float),  (0,1,5.3),  (0,2,1.0),
  (1,0,2.5),  (1,1,5.3),  (1,2,1.0),
  (2,0,2.5),  (2,1,5.3),  (2,2,1.0),
  (3,0,2.5),  (3,1,5.3),  (3,2,1.0),
  (4,0,2.5),  (4,1,5.4),  (4,2,1.0),
  (5,0,2.5),  (5,1,5.6),  (5,2,1.0),
  (6,0,2.5),  (6,1,5.5),  (6,2,1.0),
  (7,0,2.25),  (7,1,5.5),  (7,2,1.0),
  (8,0,2.25),  (8,1,5.5),  (8,2,1.0),
  (9,0,2.25),  (9,1,5.6),  (9,2,1.0),
  (10,0,2.0),  (10,1,5.7),  (10,2,1.0),
  (11,0,2.0),  (11,1,5.9),  (11,2,1.0),
  (12,0,2.0),  (12,1,6.0),  (12,2,1.0),
  (13,0,1.75),  (13,1,5.9),  (13,2,1.0),
  (14,0,1.75),  (14,1,5.8),  (14,2,1.0),
  (15,0,1.75),  (15,1,6.1),  (15,2,1.0),
  (16,0,1.75),  (16,1,6.2),  (16,2,1.0),
  (17,0,1.75),  (17,1,6.1),  (17,2,1.0),
  (18,0,1.75),  (18,1,6.1),  (18,2,1.0),
  (19,0,1.75),  (19,1,6.1),  (19,2,1.0),
  (20,0,1.75),  (20,1,5.9),  (20,2,1.0),
  (21,0,1.75),  (21,1,6.2),  (21,2,1.0),
  (22,0,1.75),  (22,1,6.2),  (22,2,1.0),
  (23,0,1.75),  (23,1,6.1),  (23,2,1.0)
), ydata(i, val) AS (   
  VALUES (0::int, 1464::float),
  (1,1394),
  (2,1357),
  (3,1293),
  (4,1256),
  (5,1254),
  (6,1234),
  (7,1195),
  (8,1159),
  (9,1167),
  (10,1130),
  (11,1075),
  (12,1047),
  (13,965),
  (14,943),
  (15,958),
  (16,971),
  (17,949),
  (18,884),
  (19,866),
  (20,876),
  (21,822),
  (22,704),
  (23,719)

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
) SELECT * FROM x ORDER BY i


