-- noinspection SqlNoDataSourceInspectionForFile

-- - this file contains a gradient descend implementation
--   for l2-regularized logistic regression in PostgreSQL dialect
-- - algorithmically, this SQL implementation corresponds to the
--   Python version from demo_gradient_descend.py
-- - refer to demo_gradient_descend.py for details

-- - this SQL programming style does not require explicit indices for
--   vectors and matrices
-- - to avoid joins, matrices and vectors are kept in a single relation
-- - a column in the relation represents either an independent vector
--   or a vector of a matrix
-- - this programming style depends on column names and is therefore
--   less universal than the COO form of demo_gradient_descend.sql
-- - but, in terms of speed and memory consumption, this representation
--   (without explicit indices) is superior to the COO form
WITH RECURSIVE log_reg(i, {weights}, intercept) AS (
VALUES
  (0::int, {floats}, 0.0::float)
UNION ALL
  SELECT i + 1, {weights}, intercept FROM (
    WITH w(i, {weights}, intercept) AS (
      SELECT * FROM log_reg
    ), cse(val, {features}) AS (  -- np.exp(-(y * X.dot(w)))
      SELECT exp(({features_times_weight} + intercept) * -y), {features}, y FROM X, w
    ), v(val, {features}) AS ( -- cse * y / (1 + cse)
      SELECT val * y / (1.0 + val), {features} FROM cse
    ), c_X_T_dot_v({temp_with_intercept}) AS ( -- c * X.T.dot(v), c = 2
      SELECT {sum_feature_times_val}, {regularization} * SUM(val) FROM v
    ), g ({g_with_intercept}) AS ( -- w - c_X_T_dot_v
      SELECT {weight_minus_temp_with_intercept} FROM c_X_T_dot_v, w
    ) SELECT i, {weight_times_reg_with_intercept} FROM w, g -- w - alpha * g, alpha=0.001
  ) AS w(i, {weights}, intercept) WHERE i < {iterations}
), w({weights}, intercept) AS (
  SELECT {weights}, intercept from log_reg WHERE i = (SELECT MAX(i) FROM log_reg)
), predicted(y_pred, y) AS ( -- np.where(1 / (1 + np.exp(-np.dot(X, w))) >= 0.5, 1, -1)
  SELECT
    CASE WHEN (1 / (1 + EXP(-({features_times_weight} + intercept)))) >= 0.5
      THEN 1::float
      ELSE -1::float
    END, y FROM X, w
), accuracy(val) AS ( -- sum(y_pred == y) / y_pred.shape[0])
  SELECT SUM(1)::float / (SELECT COUNT(*) FROM predicted) FROM predicted WHERE y_pred = y
), pretty_print(result, values) AS (
  SELECT 'w:', (SELECT {weight_comma_text} || intercept::text FROM w) UNION ALL
  SELECT 'accuracy:', (SELECT val::text FROM accuracy)
) SELECT * FROM pretty_print;

