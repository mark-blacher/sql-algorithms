-- SQL code using procedures

WITH params(temperature) AS (
    VALUES (300::float), (170)
), kelvin_to_celsius(temperature) AS ( -- inline
    SELECT temperature - 273.15 FROM params
), kelvin_to_fahrenheit(temperature) AS ( -- inline
    SELECT temperature * 9 / 5 - 459.67 FROM params
) SELECT * FROM kelvin_to_fahrenheit;