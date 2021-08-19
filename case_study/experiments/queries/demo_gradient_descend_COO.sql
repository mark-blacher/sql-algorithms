WITH RECURSIVE w_init (i, val) AS (
	SELECT DISTINCT j, 0.0::float FROM X ORDER BY j
), log_reg(it, i, val) AS (
  SELECT 0, i, val FROM w_init
UNION ALL
  SELECT it + 1, i, val FROM (
    WITH w(it, i, val) AS (
      SELECT it, i, val FROM log_reg
    ), X_dot_w(i, val) AS ( -- X.dot(w)
      SELECT X.i, SUM(X.val * w.val) FROM X, w WHERE X.j = w.i GROUP BY X.i
    ), cse(i, val) AS ( -- np.exp(-(y * X_dot_w))
      SELECT y.i, EXP(-(y.val * X_dot_w.val)) FROM y, X_dot_w WHERE y.i = X_dot_w.i
    ), v(i, val) AS ( -- cse * y / (1 + cse)
      SELECT y.i, cse.val * y.val / (1 + cse.val) FROM cse, y WHERE cse.i = y.i
    ), c_X_T_dot_v(i, val) AS (-- c * X.T.dot(v), c = 2
      SELECT X.j, {regularization} * SUM(X.val * v.val) FROM X, v WHERE X.i = v.i GROUP BY X.j
    ), g(i, val) AS ( -- w - c_X_T_dot_v
      SELECT w.i, w.val - c_X_T_dot_v.val FROM w, c_X_T_dot_v WHERE w.i = c_X_T_dot_v.i
    ) SELECT it, w.i, w.val - {step_width} * g.val FROM w, g WHERE w.i = g.i -- w - alpha * g, alpha=0.001
  ) AS w(it, i, val) WHERE it < {iterations} -- specify the number of iterations here
), w(i, val) AS (
  SELECT i, val from log_reg WHERE it = (SELECT MAX(it) FROM log_reg)
), probs(i, val) AS ( -- 1 / (1 + np.exp(-np.dot(X, w)))
  SELECT X.i, 1 / (1 + EXP(-SUM(X.val * w.val))) FROM X, w WHERE X.j = w.i GROUP BY X.i
), predicted(i, val) AS ( -- np.where(probs >= 0.5, 1, -1)
  SELECT i, CASE WHEN val >= 0.5 THEN 1.0::float ELSE -1.0::float END FROM probs
), accuracy(val) AS ( -- sum(y_predicted == y) / y.shape[0])
  SELECT SUM(1)::float / (SELECT COUNT(*) FROM y) FROM y, predicted WHERE y.i = predicted.i AND y.val = predicted.val
), pretty_print(result, values) AS (
  SELECT 'w:', ARRAY_TO_STRING(ARRAY(SELECT val FROM w ORDER BY i), ', ') UNION ALL
  SELECT 'accuracy:', (SELECT val::text FROM accuracy)
) SELECT * FROM pretty_print;
