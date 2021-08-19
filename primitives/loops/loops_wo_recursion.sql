-- SQL code using loops

WITH RECURSIVE exp(x, i, e_pow_x) AS (
    VALUES (1.5::float, 1, 1.0::float),
    (4.0 , 1, 1.0 )
    UNION ALL
    SELECT x, i + 1, e_pow_x + POWER(x, i) / !!i
    FROM exp WHERE i < 20 -- no recursive reference
) SELECT e_pow_x FROM exp WHERE i = 20;