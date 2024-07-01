WITH RECURSIVE X(f1, f2, f3, f4, y) AS (
-- iris data
    VALUES
    (CAST(5.8 AS DOUBLE PRECISION), CAST(4.0 AS DOUBLE PRECISION), CAST(1.2 AS DOUBLE PRECISION), CAST(0.2 AS DOUBLE PRECISION), CAST(0 AS INTEGER)),
    (5.1, 2.5, 3.0, 1.1, 1),
    (6.6, 3.0, 4.4, 1.4, 1),
    (5.4, 3.9, 1.3, 0.4, 0),
    (7.9, 3.8, 6.4, 2.0, 2),
    (6.3, 3.3, 4.7, 1.6, 1),
    (6.9, 3.1, 5.1, 2.3, 2),
    (5.1, 3.8, 1.9, 0.4, 0),
    (4.7, 3.2, 1.6, 0.2, 0),
    (6.9, 3.2, 5.7, 2.3, 2),
    (5.6, 2.7, 4.2, 1.3, 1),
    (5.4, 3.9, 1.7, 0.4, 0),
    (7.1, 3.0, 5.9, 2.1, 2),
    (6.4, 3.2, 4.5, 1.5, 1),
    (6.0, 2.9, 4.5, 1.5, 1),
    (4.4, 3.2, 1.3, 0.2, 0),
    (5.8, 2.6, 4.0, 1.2, 1),
    (5.6, 3.0, 4.5, 1.5, 1),
    (5.4, 3.4, 1.5, 0.4, 0),
    (5.0, 3.2, 1.2, 0.2, 0),
    (5.5, 2.6, 4.4, 1.2, 1),
    (5.4, 3.0, 4.5, 1.5, 1),
    (6.7, 3.0, 5.0, 1.7, 1),
    (5.0, 3.5, 1.3, 0.3, 0),
    (7.2, 3.2, 6.0, 1.8, 2),
    (5.7, 2.8, 4.1, 1.3, 1),
    (5.5, 4.2, 1.4, 0.2, 0),
    (5.1, 3.8, 1.5, 0.3, 0),
    (6.1, 2.8, 4.7, 1.2, 1),
    (6.3, 2.5, 5.0, 1.9, 2),
    (6.1, 3.0, 4.6, 1.4, 1),
    (7.7, 3.0, 6.1, 2.3, 2),
    (5.6, 2.5, 3.9, 1.1, 1),
    (6.4, 2.8, 5.6, 2.1, 2),
    (5.8, 2.8, 5.1, 2.4, 2),
    (5.3, 3.7, 1.5, 0.2, 0),
    (5.5, 2.3, 4.0, 1.3, 1),
    (5.2, 3.4, 1.4, 0.2, 0),
    (6.5, 2.8, 4.6, 1.5, 1),
    (6.7, 2.5, 5.8, 1.8, 2),
    (6.8, 3.0, 5.5, 2.1, 2),
    (5.1, 3.5, 1.4, 0.3, 0),
    (6.0, 2.2, 5.0, 1.5, 2),
    (6.3, 2.9, 5.6, 1.8, 2),
    (6.6, 2.9, 4.6, 1.3, 1),
    (7.7, 2.6, 6.9, 2.3, 2),
    (5.7, 3.8, 1.7, 0.3, 0),
    (5.0, 3.6, 1.4, 0.2, 0),
    (4.8, 3.0, 1.4, 0.3, 0),
    (5.2, 2.7, 3.9, 1.4, 1),
    (5.1, 3.4, 1.5, 0.2, 0),
    (5.5, 3.5, 1.3, 0.2, 0),
    (7.7, 3.8, 6.7, 2.2, 2),
    (6.9, 3.1, 5.4, 2.1, 2),
    (7.3, 2.9, 6.3, 1.8, 2),
    (6.4, 2.8, 5.6, 2.2, 2),
    (6.2, 2.8, 4.8, 1.8, 2),
    (6.0, 3.4, 4.5, 1.6, 1),
    (7.7, 2.8, 6.7, 2.0, 2),
    (5.7, 3.0, 4.2, 1.2, 1),
    (4.8, 3.4, 1.6, 0.2, 0),
    (5.7, 2.5, 5.0, 2.0, 2),
    (6.3, 2.7, 4.9, 1.8, 2),
    (4.8, 3.0, 1.4, 0.1, 0),
    (4.7, 3.2, 1.3, 0.2, 0),
    (6.5, 3.0, 5.8, 2.2, 2),
    (4.6, 3.4, 1.4, 0.3, 0),
    (6.1, 3.0, 4.9, 1.8, 2),
    (6.5, 3.2, 5.1, 2.0, 2),
    (6.7, 3.1, 4.4, 1.4, 1),
    (5.7, 2.8, 4.5, 1.3, 1),
    (6.7, 3.3, 5.7, 2.5, 2),
    (6.0, 3.0, 4.8, 1.8, 2),
    (5.1, 3.8, 1.6, 0.2, 0),
    (6.0, 2.2, 4.0, 1.0, 1),
    (6.4, 2.9, 4.3, 1.3, 1),
    (6.5, 3.0, 5.5, 1.8, 2),
    (5.0, 2.3, 3.3, 1.0, 1),
    (6.3, 3.3, 6.0, 2.5, 2),
    (5.5, 2.5, 4.0, 1.3, 1),
    (5.4, 3.7, 1.5, 0.2, 0),
    (4.9, 3.1, 1.5, 0.2, 0),
    (5.2, 4.1, 1.5, 0.1, 0),
    (6.7, 3.3, 5.7, 2.1, 2),
    (4.4, 3.0, 1.3, 0.2, 0),
    (6.0, 2.7, 5.1, 1.6, 1),
    (6.4, 2.7, 5.3, 1.9, 2),
    (5.9, 3.0, 5.1, 1.8, 2),
    (5.2, 3.5, 1.5, 0.2, 0),
    (5.1, 3.3, 1.7, 0.5, 0),
    (5.8, 2.7, 4.1, 1.0, 1),
    (4.9, 3.1, 1.5, 0.1, 0),
    (7.4, 2.8, 6.1, 1.9, 2),
    (6.2, 2.9, 4.3, 1.3, 1),
    (7.6, 3.0, 6.6, 2.1, 2),
    (6.7, 3.0, 5.2, 2.3, 2),
    (6.3, 2.3, 4.4, 1.3, 1),
    (6.2, 3.4, 5.4, 2.3, 2),
    (7.2, 3.6, 6.1, 2.5, 2),
    (5.6, 2.9, 3.6, 1.3, 1),
    (5.7, 4.4, 1.5, 0.4, 0),
    (5.8, 2.7, 3.9, 1.2, 1),
    (4.5, 2.3, 1.3, 0.3, 0),
    (5.5, 2.4, 3.8, 1.1, 1),
    (6.9, 3.1, 4.9, 1.5, 1),
    (5.0, 3.4, 1.6, 0.4, 0),
    (6.8, 2.8, 4.8, 1.4, 1),
    (5.0, 3.5, 1.6, 0.6, 0),
    (4.8, 3.4, 1.9, 0.2, 0),
    (6.3, 3.4, 5.6, 2.4, 2),
    (5.6, 2.8, 4.9, 2.0, 2),
    (6.8, 3.2, 5.9, 2.3, 2),
    (5.0, 3.3, 1.4, 0.2, 0),
    (5.1, 3.7, 1.5, 0.4, 0),
    (5.9, 3.2, 4.8, 1.8, 1),
    (4.6, 3.1, 1.5, 0.2, 0),
    (5.8, 2.7, 5.1, 1.9, 2),
    (4.8, 3.1, 1.6, 0.2, 0),
    (6.5, 3.0, 5.2, 2.0, 2),
    (4.9, 2.5, 4.5, 1.7, 2),
    (4.6, 3.2, 1.4, 0.2, 0),
    (6.4, 3.2, 5.3, 2.3, 2),
    (4.3, 3.0, 1.1, 0.1, 0),
    (5.6, 3.0, 4.1, 1.3, 1),
    (4.4, 2.9, 1.4, 0.2, 0),
    (5.5, 2.4, 3.7, 1.0, 1),
    (5.0, 2.0, 3.5, 1.0, 1),
    (5.1, 3.5, 1.4, 0.2, 0),
    (4.9, 3.0, 1.4, 0.2, 0),
    (4.9, 2.4, 3.3, 1.0, 1),
    (4.6, 3.6, 1.0, 0.2, 0),
    (5.9, 3.0, 4.2, 1.5, 1),
    (6.1, 2.9, 4.7, 1.4, 1),
    (5.0, 3.4, 1.5, 0.2, 0),
    (6.7, 3.1, 4.7, 1.5, 1),
    (5.7, 2.9, 4.2, 1.3, 1),
    (6.2, 2.2, 4.5, 1.5, 1),
    (7.0, 3.2, 4.7, 1.4, 1),
    (5.8, 2.7, 5.1, 1.9, 2),
    (5.4, 3.4, 1.7, 0.2, 0),
    (5.0, 3.0, 1.6, 0.2, 0),
    (6.1, 2.6, 5.6, 1.4, 2),
    (6.1, 2.8, 4.0, 1.3, 1),
    (7.2, 3.0, 5.8, 1.6, 2),
    (5.7, 2.6, 3.5, 1.0, 1),
    (6.3, 2.8, 5.1, 1.5, 2),
    (6.4, 3.1, 5.5, 1.8, 2),
    (6.3, 2.5, 4.9, 1.5, 1),
    (6.7, 3.1, 5.6, 2.4, 2),
    (4.9, 3.6, 1.4, 0.1, 0)
), iterations (iterations) AS (
    VALUES (CAST(2000 AS INTEGER))
), alpha (alpha) AS (
    VALUES (CAST(0.001 AS DOUBLE PRECISION))
), _X AS (
    SELECT *, ROW_NUMBER() OVER() AS row_id FROM (SELECT DISTINCT * FROM X) AS T
), log_reg_softmax(i, y, w1, w2, w3, w4, intercept) AS (
    VALUES
    (CAST(0 AS INTEGER), CAST(0 AS INTEGER), CAST(0 AS DOUBLE PRECISION), CAST(0 AS DOUBLE PRECISION), CAST(0 AS DOUBLE PRECISION), CAST(0 AS DOUBLE PRECISION), CAST(0 AS DOUBLE PRECISION)),
    (CAST(0 AS INTEGER), CAST(1 AS INTEGER), CAST(0 AS DOUBLE PRECISION), CAST(0 AS DOUBLE PRECISION), CAST(0 AS DOUBLE PRECISION), CAST(0 AS DOUBLE PRECISION), CAST(0 AS DOUBLE PRECISION)),
    (CAST(0 AS INTEGER), CAST(2 AS INTEGER), CAST(0 AS DOUBLE PRECISION), CAST(0 AS DOUBLE PRECISION), CAST(0 AS DOUBLE PRECISION), CAST(0 AS DOUBLE PRECISION), CAST(0 AS DOUBLE PRECISION))
    UNION ALL
    SELECT i, y, w1, w2, w3, w4, intercept FROM(
        WITH log_reg_softmax_mock AS (
            SELECT * FROM log_reg_softmax
        ), XW AS (
            SELECT CAST(log_reg_softmax_mock.y = _X.y  AS INTEGER) AS y_class, row_id AS rn, log_reg_softmax_mock.y, (f1 * w1 + f2 * w2 + f3 * w3 + f4 * w4 + intercept) AS val FROM _X, log_reg_softmax_mock
        ), XW_exps AS (
            SELECT y_class, rn, y, EXP(val - MAX(val) OVER(PARTITION BY rn)) AS exps FROM XW
        ), y_minus_sm AS (
            SELECT y_class, rn, y, y_class - exps / (SUM(exps) OVER(PARTITION BY rn)) + 2.220446049250313e-16 AS y_sm FROM XW_exps
        ), X_t_dot_y_minus_sm AS (
            SELECT -SUM(f1 * y_sm) AS w1, -SUM(f2 * y_sm) AS w2, -SUM(f3 * y_sm) AS w3, -SUM(f4 * y_sm) AS w4, -SUM(y_sm) AS intercept, y_minus_sm.y FROM y_minus_sm, _X WHERE row_id=rn GROUP BY y_minus_sm.y ORDER BY y_minus_sm.y
        ), grad AS (
            SELECT a.w1 + b.w1 AS w1, a.w2 + b.w2 AS w2, a.w3 + b.w3 AS w3, a.w4 + b.w4 AS w4, a.intercept + b.intercept AS intercept, b.y FROM log_reg_softmax_mock a, X_t_dot_y_minus_sm b WHERE a.y = b.y
        ), w_new(i, y, w1, w2, w3, w4, intercept) AS (
            SELECT i + 1, a.y, a.w1 - alpha * b.w1, a.w2 - alpha * b.w2, a.w3 - alpha * b.w3, a.w4 - alpha * b.w4, a.intercept - alpha * b.intercept FROM log_reg_softmax_mock a, grad b, alpha WHERE a.y = b.y
        ) SELECT * FROM w_new) tmp, iterations WHERE i <= iterations
), weights AS (
    SELECT y, w1, w2, w3, w4, intercept FROM log_reg_softmax, iterations WHERE i = iterations
), _XX AS (
    SELECT *, ROW_NUMBER() OVER() AS row_id FROM X
), XW AS (
    SELECT CAST(weights.y = _XX.y  AS INTEGER) AS y_class, row_id AS rn, weights.y, (f1 * w1 + f2 * w2 + f3 * w3 + f4 * w4 + intercept) AS val FROM _XX, weights
), XW_exps AS (
    SELECT y_class, rn, y, EXP(val - MAX(val) OVER(PARTITION BY rn)) AS exps FROM XW
), y_sm AS (
    SELECT y_class, rn, y, exps / (SUM(exps) OVER(PARTITION BY rn)) + 2.220446049250313e-16 AS y_sm FROM XW_exps
), accuracy AS (
    SELECT SUM(CAST(class_rank = 1 AS INTEGER)) / CAST(COUNT(class_rank) AS DOUBLE PRECISION) AS accuracy FROM (SELECT y_class, y_sm, RANK() OVER (PARTITION BY rn ORDER BY y_sm DESC) AS class_rank FROM y_sm) AS ranked WHERE y_class = 1
)

SELECT 'class weights ' || CAST(y AS TEXT) || ':' AS stats_and_params, ARRAY_TO_STRING(ARRAY[w1, w2, w3, w4, intercept], ', ') AS "values" FROM weights
UNION ALL
SELECT 'train accuracy:  ', CAST(accuracy AS TEXT) FROM accuracy
ORDER BY stats_and_params;

