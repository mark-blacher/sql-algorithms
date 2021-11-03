# Supplement for the publication - Machine Learning, Linear Algebra, and More: Is SQL All You Need?


## Demonstratation
This folder contains files to perfom a stand alone gradient descent with Python or SQL.

## Requirements
See [requirements](../../README.md#Requirements) of the whole repository.  

## Usage
The repository contains multiple files, that all can run stand alone. 
You can run the Python file with 
````commandline
python demo_gradient_descend.py

    seconds: 0.0012402534484863281
    w: [ 1.38182256 -2.34118793 -0.23206473]
    accuracy: 0.99
````
and the SQL files using 
````commandline
psql postgres -h 127.0.0.1 -d postgres -f demo_gradient_descend.sql

      result   |                            values
    -----------+--------------------------------------------------------------
     w:        | 1.3818225599433474, -2.341187931329547, -0.23206472696197072
     accuracy: | 0.99
    (2 rows) 
````
or for the data base friendly case

```sql
psql postgres -h 127.0.0.1 -d postgres -f demo_gradient_descend_db-friendly.sql

      result   |                            values
    -----------+--------------------------------------------------------------
     w:        | 1.3818225599433474, -2.341187931329547, -0.23206472696197072
     accuracy: | 0.99
    (2 rows)
````
All three commands return a weight vector and a accuracy.
