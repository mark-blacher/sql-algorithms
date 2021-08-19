-- SQL code giving error massages

WITH probs(p) AS (
    VALUES (0.1::float), (0.4), (0.5)
), errors AS ( -- table contains all errors
    SELECT 'ERROR: negative probabilities'
    WHERE (SELECT 0 > ANY(SELECT * FROM probs))
    UNION ALL
    SELECT 'ERROR: sum of probabilities != 1.0'
    WHERE (SELECT ABS(SUM(p) - 1.0) > 1e-16
    FROM probs)
), entropy(entropy) AS ( -- compute if no errors
    SELECT -SUM(p * LOG(p) / LOG(2.0)) FROM probs
    WHERE NOT EXISTS(SELECT 1 FROM errors)
), result(result) AS (
    SELECT * FROM errors
    UNION ALL
    SELECT entropy::text FROM entropy
) SELECT * FROM result WHERE result IS NOT NULL