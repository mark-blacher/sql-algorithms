# Supplement for the publication - Machine Learning, Linear Algebra, and More: Is SQL All You Need?

## Requirements
### Python and Anaconda
For our experiments we use python version 3.8 and Anaconda version 4.9.2  

The experiments require the following python packages.
* numpy (version 1.21.1)
* matplotlib (version 3.4.2)
* scikit-learn (version 0.24.2)
* tableauhyperapi (version 0.0.13287)
* postgres (version 3.0.0)
* psycopg2 (version 2.9.1)

All packages can be installed using anaconda and the yaml file with

 `conda env create -f environment.yml`
 
after this the environment is activated with

`conda activate exql`

and can be deleted with 

`conda env remove -n exql`.

### Postgres
The experiments further need a postgres DBMS installation. The postgres installation should have a 
database with the following configuaration:
* name: 'postgres',
* user: 'postgres',
* password: 'postgres',
* host: 'localhost'.


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
where you can set beforehand the single or multi-threaded case

### CASE 1

### CASE 2



## Troubleshooting
### Postgres returns `nan`.
Under windows there is a problem with the correct file rights. Postgres does not 
have the right to read from the csv files created for the database insert.
Please just add the user ___Everybody___ with the right ___read___ to the 
files `data.csv`, `X.csv`, `y.csv`.
