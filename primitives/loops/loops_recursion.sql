-- SQL code using    loops with recursion

WITH RECURSIVE x(x, i) AS (
    VALUES (0::float, 0::int)
    UNION ALL
    SELECT x, i + 1 FROM (
        WITH x(x, i) AS ( -- recursive reference of x
            SELECT * FROM x -- work around for PostgreSQL
        ), fD(fD) AS ( -- f'
            SELECT 2 * x - SIN(x) + 2 * COS(x) FROM x
        ), fD2(fD2) AS ( -- f''
            SELECT 2 - COS(x) - 2 * SIN(x) FROM x
        ) SELECT x - fD / fD2, fD, i FROM x, fD, fD2
    ) AS x_new(x, fD, i) WHERE ABS(fD) > 1e-6
) SELECT x FROM x WHERE i = (SELECT MAX(i) FROM x);