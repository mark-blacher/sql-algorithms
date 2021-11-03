-- - this file contains a gradient descent implementation 
--   for l2-regularized logistic regression in PostgreSQL dialect
-- - algorithmically, this SQL implementation corresponds to the 
--   Python version from demo_gradient_descent.py
-- - refer to demo_gradient_descent.py for details

-- - this SQL programming style does not require explicit indices for  
--   vectors and matrices
-- - to avoid joins, matrices and vectors are kept in a single relation
-- - a column in the relation represents either an independent vector 
--   or a vector of a matrix
-- - this programming style depends on column names and is therefore 
--   less universal than the COO form of demo_gradient_descent.sql
-- - but, in terms of speed and memory consumption, this representation
--   (without explicit indices) is superior to the COO form 
WITH RECURSIVE X(f1, f2, y) AS (
VALUES
  (5.5::float ,2.4::float ,1::float),
  (5.4 ,3.0 ,1),
  (5.5 ,4.2 ,-1),
  (5.5 ,2.4 ,1),
  (5.0 ,2.3 ,1),
  (5.1 ,3.5 ,-1),
  (5.5 ,3.5 ,-1),
  (5.8 ,2.7 ,1),
  (5.6 ,2.5 ,1),
  (6.7 ,3.1 ,1),
  (5.8 ,2.6 ,1),
  (5.1 ,3.4 ,-1),
  (6.3 ,3.3 ,1),
  (6.9 ,3.1 ,1),
  (6.4 ,3.2 ,1),
  (5.2 ,4.1 ,-1),
  (5.4 ,3.4 ,-1),
  (5.1 ,3.8 ,-1),
  (6.0 ,2.9 ,1),
  (5.4 ,3.7 ,-1),
  (4.7 ,3.2 ,-1),
  (6.1 ,2.8 ,1),
  (6.2 ,2.9 ,1),
  (6.0 ,2.2 ,1),
  (5.1 ,3.8 ,-1),
  (5.0 ,3.2 ,-1),
  (5.6 ,2.7 ,1),
  (5.2 ,3.5 ,-1),
  (5.1 ,3.8 ,-1),
  (4.4 ,3.0 ,-1),
  (5.8 ,2.7 ,1),
  (5.7 ,2.8 ,1),
  (6.5 ,2.8 ,1),
  (5.7 ,3.0 ,1),
  (5.6 ,3.0 ,1),
  (5.0 ,3.5 ,-1),
  (5.3 ,3.7 ,-1),
  (5.2 ,2.7 ,1),
  (5.1 ,3.3 ,-1),
  (4.9 ,3.1 ,-1),
  (6.7 ,3.1 ,1),
  (5.5 ,2.3 ,1),
  (6.7 ,3.0 ,1),
  (5.7 ,4.4 ,-1),
  (6.0 ,2.7 ,1),
  (4.5 ,2.3 ,-1),
  (4.8 ,3.0 ,-1),
  (6.1 ,3.0 ,1),
  (5.0 ,3.4 ,-1),
  (5.1 ,2.5 ,1),
  (5.0 ,3.5 ,-1),
  (5.7 ,2.8 ,1),
  (4.8 ,3.4 ,-1),
  (5.0 ,3.6 ,-1),
  (6.6 ,2.9 ,1),
  (5.0 ,3.3 ,-1),
  (5.1 ,3.7 ,-1),
  (6.3 ,2.3 ,1),
  (4.6 ,3.1 ,-1),
  (6.4 ,2.9 ,1),
  (4.8 ,3.1 ,-1),
  (5.6 ,3.0 ,1),
  (5.9 ,3.2 ,1),
  (4.4 ,3.2 ,-1),
  (4.6 ,3.2 ,-1),
  (5.5 ,2.5 ,1),
  (4.4 ,2.9 ,-1),
  (5.0 ,2.0 ,1),
  (5.1 ,3.5 ,-1),
  (5.5 ,2.6 ,1),
  (4.9 ,2.4 ,1),
  (4.6 ,3.6 ,-1),
  (5.9 ,3.0 ,1),
  (6.1 ,2.9 ,1),
  (5.0 ,3.4 ,-1),
  (5.7 ,2.9 ,1),
  (4.3 ,3.0 ,-1),
  (6.2 ,2.2 ,1),
  (6.0 ,3.4 ,1),
  (5.8 ,4.0 ,-1),
  (4.7 ,3.2 ,-1),
  (5.2 ,3.4 ,-1),
  (4.8 ,3.4 ,-1),
  (5.7 ,3.8 ,-1),
  (5.4 ,3.4 ,-1),
  (7.0 ,3.2 ,1),
  (5.0 ,3.0 ,-1),
  (4.6 ,3.4 ,-1),
  (6.1 ,2.8 ,1),
  (6.8 ,2.8 ,1),
  (4.9 ,3.0 ,-1),
  (5.4 ,3.9 ,-1),
  (5.6 ,2.9 ,1),
  (5.7 ,2.6 ,1),
  (5.4 ,3.9 ,-1),
  (6.6 ,3.0 ,1),
  (4.9 ,3.1 ,-1),
  (6.3 ,2.5 ,1),
  (4.8 ,3.0 ,-1),
  (4.9 ,3.6 ,-1)
), log_reg(i, w1, w2, intercept) AS (
VALUES
  (0::int, 0.0::float, 0.0::float, 0.0::float)
UNION ALL
  SELECT i + 1, w1, w2, intercept FROM (
    WITH w(i, w1, w2, intercept) AS ( 
      SELECT * FROM log_reg
    ), cse(val, f1, f2) AS (  -- np.exp(-(y * X.dot(w)))
      SELECT exp((f1 * w1 + f2 * w2 + intercept) * -y), f1, f2, y FROM X, w
    ), v(val, f1, f2) AS ( -- cse * y / (1 + cse)
      SELECT val * y / (1.0 + val), f1, f2 FROM cse 
    ), c_X_T_dot_v(t1, t2, t3) AS ( -- c * X.T.dot(v), c = 2
      SELECT 2 * SUM(f1 * val), 2 * SUM(f2 * val), 2 * SUM(val) FROM v
    ), g (g1, g2, g3) AS ( -- w - c_X_T_dot_v
      SELECT w1 - t1, w2 - t2, intercept - t3 FROM c_X_T_dot_v, w
    ) SELECT i, w1 - 0.001 * g1, w2 - 0.001 * g2, intercept - 0.001 * g3 FROM w, g -- w - alpha * g, alpha=0.001
  ) AS w(i, w1, w2, intercept) WHERE i < 100
), w(w1, w2, intercept) AS (
  SELECT w1, w2, intercept from log_reg WHERE i = (SELECT MAX(i) FROM log_reg)
), predicted(y_pred, y) AS ( -- np.where(1 / (1 + np.exp(-np.dot(X, w))) >= 0.5, 1, -1)
  SELECT 
    CASE WHEN (1 / (1 + EXP(-(f1 * w1 + f2 * w2 + intercept)))) >= 0.5 
      THEN 1::float 
      ELSE -1::float
    END, y FROM X, w
), accuracy(val) AS ( -- sum(y_pred == y) / y_pred.shape[0])
  SELECT SUM(1)::float / (SELECT COUNT(*) FROM predicted) FROM predicted WHERE y_pred = y
), pretty_print(result, values) AS (
  SELECT 'w:', (SELECT w1::text || ', ' || w2::text || ', ' || intercept::text FROM w) UNION ALL
  SELECT 'accuracy:', (SELECT val::text FROM accuracy)
) SELECT * FROM pretty_print;
