# Supplement for the paper - Machine Learning, Linear Algebra, and More: Is SQL All You Need?


## Linear Programming Problem
This folder contains a Linear Programming solver implemented in SQL. 

## Requirements
See [requirements](../README.md#Requirements) of the whole repository.  

## Usage
The repository contains multiple files. The files `rsm.py` and `rsm.sql` can run standalone. The file `examples.py` 
does contain a collection of further examples and the file `convert_examples_to_sql.py` can be used to convert one 
example into an SQL file.

You can run the `rms.py` file with 
````commandline
python rsm.py

    message: optimal solution found
    success: True
    max z:   410.0
    x:       [70. 90.]
    slack:   [50.  0.  0.]
    nit:     3
    seconds: 0.0481724739074707

````
and the SQL file `rsm.sql` using 
````commandline
psql postgres -h 127.0.0.1 -d postgres -f rsm.sql

       result    |                                values
    -------------+-----------------------------------------------------------------------
     message:    | optimal solution found
     success:    | true
     max z:      | 0.10285714285714286
     nonzero x:  | x0=0.5714285714285714, x3=0.42857142857142855, x4=0.17142857142857137
     iterations: | 4
    (5 rows)
````

To create the SQL query for another problem the problem can be uncommented in `convert_examples_to_sql.py` and afterwards
the query can be created with 
```commandline
python convert_examples_to_sql.py
```
This prints the query onto the console. The query can then be copied into `rsm.sql` and it can be proceed as described above.

