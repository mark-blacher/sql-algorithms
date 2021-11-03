# Supplement for the publication - Machine Learning, Linear Algebra, and More: Is SQL All You Need?


## Experiments
This folder contains all information to reproduce the performance measurements shown in the publication.

## Requirements
See [requirements](../../README.md#Requirements) of the whole repository.  


## Usage
The repository contains multiple files. `main.py` contains the experiments and ___xxx___ are additional
case studies. 

### Usage of`main.py`
All experiments can be performed using the `main.py` file. Line 5 of this file allows to 
change between a single threaded case and a multi-threaded case. In the multi-threaded case you can change 
the number of points in line 9 setting the variable `threads_amount`

````python
single = False # activates the multi threaded case
...
threads_amount = <MAX NUMBER OF POSSIBLE THREADS>
````

To run the experiments as in the paper you can use the command
````commandline
python main.py --all True
````
If you want to run a single configuration with a specific number of features and data points you can do so with
````commandline
python main.py -f <NUMBER OF FEATURES> -s <NUMBER OF DATA POINTS>
````


## Troubleshooting
### Postgres returns `nan`.
Under windows there is a problem with the correct file rights. Postgres does not 
have the right to read from the csv files created for the database insert.
Please just add the user ___Everybody___ with the right ___read___ to the 
files `data.csv`, `X.csv`, `y.csv`.

It can also occur if the data set is to large.

### Hyper returns `nan`
This can also happen if the created data set is to large.
