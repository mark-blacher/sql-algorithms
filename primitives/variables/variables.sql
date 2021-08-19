-- SQL code using declaration and incrementation of a variable

WITH x(x) AS ( -- x is immutable
    VALUES (1)
), x2(x) AS ( -- create new variable
    SELECT x + 1 FROM x
) SELECT x FROM x2; -- print result