# Supplement for the publication - Machine Learning, Linear Algebra, and More: Is SQL All You Need?


## Primitives
This folder contains different sub-folders with the primitives from chapter 3 of the publication. 

Each sub-folder `conditions, errors, loops, functions` and `variables` contains a Python file and 
a corresponding SQL file with the same operation performed as in the Python file. 

## Requirements
See [requirements](../README.md#Requirements) of the whole repository.

## Usage
For the example of the variables the files can b can be executed using
````commandline
python variables.py
````
for the Python file and 
````commandline
psql postgres -h 127.0.0.1 -d postgres -f variables.sql
````
for the SQL file. Both commands return the value 2. 

This approach is similar for all other primitives.
