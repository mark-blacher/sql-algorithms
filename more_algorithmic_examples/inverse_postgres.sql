WITH RECURSIVE A(i, j, val) AS ( 
  VALUES (0::int, 0::int, 4.0::float),  (0, 1, 12.0), (0, 2, -16.0), (0, 3, 34.0),
         (1, 0, 24.0), (1, 1, 37.0), (1, 2, -43.0), (1, 3, 3.0),
         (2, 0, -10.0), (2, 1, -430.0), (2, 2, 98.0), (2, 3, -13.0),
         (3, 0, 39.0), (3, 1, 3.0),  (3, 2, -13.0), (3, 3, 177.0)
), n(val) AS (
  SELECT MAX(i) + 1 FROM A
), UL(i, j, val, is_L, idx) AS (
  SELECT i, j, val, false, 0 FROM A 
UNION ALL
  SELECT i, j, val, is_L, idx + 1 FROM (
    WITH UL(i, j, val, is_L, idx) AS (
	  SELECT * FROM UL
	), factor(i, j, val, is_L, idx) AS (
	  SELECT i, j, val / (SELECT val FROM UL WHERE i=idx AND j=idx AND is_L=false), true, idx FROM UL WHERE i>idx AND j=idx AND is_L=false
	), outerproduct(i, j, val) AS (
	  SELECT factor.i, UL.j, factor.val * UL.val AS val FROM factor, UL WHERE UL.is_L=false AND UL.i=UL.idx
	), U_slice(i, j, val, is_L, idx) AS (
	  SELECT t.i, t.j, UL.val - t.val, is_L, idx FROM UL, outerproduct AS t WHERE UL.is_L=false AND t.i=UL.i AND t.j=UL.j
	)  SELECT * FROM factor UNION ALL SELECT * FROM U_slice
  ) AS tmp WHERE idx < (SELECT val - 1 FROM n)
), L(i, j, val, is_L) AS (
  SELECT * FROM UL WHERE is_L=true UNION ALL SELECT i, j, 1, true, 0 FROM A WHERE j=i
), U(i, j, val, is_L) AS (
  SELECT * FROM UL WHERE is_L=false AND i=idx AND j>=i
), Ainvv(i, j, val, idx) AS (
   VALUES (-1::int, -1::int, -1.0::float, 0::int) -- invalid 
UNION ALL
   SELECT i, j, val, idx + 1 FROM (
     WITH RECURSIVE idx(val) AS (
	   SELECT idx FROM Ainvv LIMIT 1	 
	 ), b(i, val) AS (
       SELECT A.i, CASE WHEN A.i = idx.val THEN 1::float ELSE 0::float END FROM A, idx WHERE A.j=idx.val
     ), yy(i, val, idx) AS ( -- forward substitution
       SELECT i, val / (SELECT val FROM L WHERE i=0 AND j=0), 1::int FROM b WHERE i=0
     UNION ALL
       SELECT i, val, idx + 1 FROM (
        WITH yy(i, val, idx) AS (
     	  SELECT * FROM yy
     	), L_dot_y(val, idx) AS (
     	  SELECT SUM(yy.val * L.val), yy.idx FROM yy, L WHERE yy.i=L.j AND L.i=yy.idx GROUP BY yy.idx
     	), y_idx(i, val, idx) AS (
     	  SELECT i, (b.val - L_dot_y.val) / (SELECT val FROM L WHERE i=L_dot_y.idx AND j=L_dot_y.idx), idx FROM L_dot_y, b WHERE i=idx
     	) SELECT * FROM yy UNION ALL SELECT * FROM y_idx
       ) AS tmp WHERE idx < (SELECT val FROM n)
     ), y(i, val, idx) AS (
       SELECT i, val, idx - 1 FROM yy WHERE idx=(SELECT val FROM n)
     ), xx(i, val, idx) AS ( -- back substitution
        SELECT idx, val / (SELECT val FROM U WHERE i=y.idx AND j=y.idx), idx - 1 FROM y WHERE i=idx
     UNION ALL
       SELECT i, val, idx - 1 FROM (
     	WITH xx(i, val, idx) AS (
     	  SELECT * FROM xx
     	), L_dot_x(val, idx) AS (
     	  SELECT SUM(xx.val * U.val), xx.idx FROM xx, U WHERE xx.i=U.j AND U.i=xx.idx GROUP BY xx.idx
     	), x_idx(i, val, idx) AS (
     	  SELECT i, (y.val - L_dot_x.val) / (SELECT val FROM U WHERE i=L_dot_x.idx AND j=L_dot_x.idx), L_dot_x.idx FROM L_dot_x, y WHERE i=L_dot_x.idx
     	) SELECT * FROM xx UNION ALL SELECT * FROM x_idx
       ) AS tmp WHERE idx >= 0
     ), x(i, val) AS (
       SELECT i, val FROM xx WHERE idx=-1
     ) SELECT x.i, idx.val AS j, x.val, idx.val AS idx FROM x, idx   
   ) AS tmp WHERE idx < (SELECT val FROM n)
) SELECT i, j, val FROM Ainvv WHERE i>-1 ORDER BY i, j

