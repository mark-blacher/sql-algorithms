-- SQL code using conditions

WITH params(temperature) AS (
    VALUES (300::float), (170)
), kelvin_to_celsius(temperature) AS ( -- inline
    SELECT temperature - 273.15 FROM params
), kelvin_to_fahrenheit(temperature) AS ( -- inline
    SELECT temperature * 9 / 5 - 459.67 FROM params
), -- branching on a random value starts now
condition AS ( -- random condition
    VALUES (random() > 0.5)
), A(A) AS ( -- only one relation is selected
    SELECT * FROM kelvin_to_celsius WHERE
    (SELECT * FROM condition)
    UNION ALL
    SELECT * FROM kelvin_to_fahrenheit WHERE
    NOT (SELECT * FROM condition)
) SELECT * FROM A
