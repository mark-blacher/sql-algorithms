# Supplement for the paper - Machine Learning, Linear Algebra, and More: Is SQL All You Need?

## Structure of the Repository

````
.
├── LP_solver                  # A Linear Programming solver written in SQL
├── case_study                 # Case study and experiments for the paper using logistic regression
│   ├── demonstration          # Stand alone files for logistic regression
│   └── experiments            # Experimental files to reproduce the results of the paper
├── more_algorithmic_examples  # additional SQL-only algorithms not mentioned in the paper
├── primitives                 # Stand alone files for the primitives of chapter 3 
│   ├── conditions             # Implementation of conditions
│   ├── errors                 # Catching and handling errors
│   ├── loops                  # Implementation of loops
│   ├── functions              # Using functions
└── └── variables              # Variable declaration and usage
````

__See each folder for more information.__

## Requirements
### Python and Anaconda
All files were tested using Python version 3.8 and Anaconda version 4.9.2  

Further we require the following Python packages.
* numpy (version 1.21.1)
* matplotlib (version 3.4.2)
* scikit-learn (version 0.24.2)
* tableauhyperapi (version 0.0.13287)
* postgres (version 3.0.0)
* psycopg2 (version 2.9.1)

All packages can be installed using Anaconda and the yaml file with

 `conda env create -f environment.yml`
 
after this the environment is activated with

`conda activate exql`

and can be deleted with 

`conda env remove -n exql`.

### Postgres
The experiments further need a postgres DBMS installation. We used psql version 12.7. You can install postgres on linux using

````commandline
sudo apt-get install postgresql-12.7 postgresql-contrib-12.7
````
The postgres installation should have a 
database with the following configuaration:
* name: 'postgres',
* user: 'postgres',
* password: 'pw',
* host: 'localhost'.


