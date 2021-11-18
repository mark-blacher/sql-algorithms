
import os

# single threaded or use mkl
single = False
if single:
    threads_amount = "1"
else:
    threads_amount = "36"
os.environ["MKL_NUM_THREADS"] = threads_amount
os.environ["NUMEXPR_NUM_THREADS"] = threads_amount
os.environ["OMP_NUM_THREADS"] = threads_amount

import argparse
from timeit import default_timer as timer
import pickle

import numpy as np
import matplotlib.pyplot as plt

from tableauhyperapi import HyperProcess, Telemetry, Connection, HyperException, CreateMode, escape_string_literal

from postgres import Postgres
import psycopg2 as psy

from sklearn.datasets import make_blobs
from sklearn.preprocessing import StandardScaler


def create_data(features=10, samples=10000, seed=0, cluster_std=0.8):
    """
    Create a dataset with 'features' features and 'samples' datapoints.

    The dataset returned is split into data X and classes y. We also transform X to be a designmatrix
    :param features: number of features
    :param samples: number of datapoints
    :param seed:
    :param center_box:
    :param cluster_std:
    :return: (X, y)
    """
    X, y = make_blobs(n_samples=samples, centers=2, n_features=features, random_state=seed, center_box=(-1, 1),
                      cluster_std=cluster_std)
    # normalize X
    scaler = StandardScaler().fit(X)
    X = scaler.transform(X)
    # class labels are -1 and 1
    y[y == 0] = -1
    # create a designmatrix
    X = np.hstack((X, np.ones((len(X), 1))))
    return X, y


###########
# QUERIES #
###########
def get_queries_for_COO(X, y):
    """
    Creates the database queries for the COO format and creates also the X.csv and y.csv
    :param X: numpy array containing the features
    :param y: numpy array containing the classes
    :return: list of string queries
    """
    queries = [
        "DROP TABLE IF EXISTS Y;",
        "CREATE TEMPORARY TABLE Y (i INTEGER , val DOUBLE PRECISION );",
        "DROP TABLE IF EXISTS X;",
        "CREATE TEMPORARY TABLE X (i INTEGER , j INTEGER , val DOUBLE PRECISION );",
    ]
    # insert into y
    values = []
    for row, value in enumerate(y):
        values.append(f"({row}, {value})")
        if row + 1 % 10000 == 0:
            queries.append(f"INSERT INTO Y (i, val) VALUES {','.join(values)};")
            values = []
    if values:
        queries.append(f"INSERT INTO Y (i, val) VALUES {','.join(values)};")
    # insert into X
    values = []
    for row, x in enumerate(X):
        for col, value in enumerate(x):
            values.append(f"({row}, {col}, {value})")
        if row + 1 % 10000 == 0:
            queries.append(f"INSERT INTO X (i, j, val) VALUES {','.join(values)};")
            values = []
    if values:
        query = f"INSERT INTO X (i, j, val) VALUES {','.join(values)};"
        queries.append(query)
    return queries


def get_queries_for_db_friendly(X, y):
    """
    Creates the database queries for the database friendly format
    :param X: numpy array containing the features
    :param y: numpy array containing the classes
    :return: list of string queries
    """
    # drop design vector
    X = X[:, :-1]
    feature_names = ["f" + str(i + 1) for i in range(len(X.T))]
    column_types = ' '.join([f + ' DOUBLE PRECISION,' for f in feature_names])
    queries = ["DROP TABLE IF EXISTS X;",
               f"CREATE TEMPORARY TABLE X ({column_types} y DOUBLE PRECISION);"]
    values = []
    feature_tuple = f"({''.join([f + ',' for f in feature_names])}y)"
    for col, row in enumerate(X):
        value_tuple = f"({','.join([str(num) for num in row])},{str(float(y[col]))})"
        values.append(value_tuple)
        if col + 1 % 10000 == 0:
            queries.append(f"INSERT INTO" + f" X {feature_tuple} VALUES {','.join(values)};")
            values = []
    if values:
        queries.append(f"INSERT INTO" + f" X {feature_tuple} VALUES {','.join(values)};")
    return queries


def get_queries_CSV(X, y, hyper=True):
    """
    Creates the database queries for inserting the data in the database friendly format via CSV copy, creates data.csv
    :param X: numpy array containing the features
    :param y: numpy array containing the classes
    :param hyper: boolean checking if the queries are for hyper or postgres
    :return: list of string queries
    """
    # drop design vector and concatenate X and y
    X = X[:,:-1]
    T = np.vstack([X.T, y]).T

    # save X and y as csv files
    path_to_csv = "data.csv"
    np.savetxt(path_to_csv, T)

    # create table definition
    feature_names = ["f" + str(i + 1) for i in range(len(X.T))]
    column_types = ' '.join([f + ' DOUBLE PRECISION,' for f in feature_names])
    queries = ["DROP TABLE IF EXISTS X;",
               f"CREATE TEMPORARY TABLE X ({column_types} y DOUBLE PRECISION);"]
    if hyper:
        csv_insert = f"COPY X FROM {escape_string_literal(path_to_csv)} WITH (format csv, delimiter ' ');"
    else:
        csv_insert = f"COPY X FROM {escape_string_literal(os.path.abspath(path_to_csv))} DELIMITER ' ';"
    queries.append(csv_insert)
    return queries


def get_queries_CSV_COO(X, y, hyper=True):
    """
    Creates the database queries for inserting the data in the COO format via CSV copy, creates X.csv, y.csv
    :param X: numpy array containing the features
    :param y: numpy array containing the classes
    :param hyper: boolean checking if the queries are for hyper or postgres
    :return: list of string queries
    """
    # create new coordinate matrices for X and y
    COO_y = list()
    for row, value in enumerate(y):
        COO_y.append([row, value])
    COO_X = list()
    for row, x in enumerate(X):
        for col, value in enumerate(x):
            COO_X.append([row, col, value])

    # save those two
    X_file = "X.csv"
    y_file = "Y.csv"
    np.savetxt(X_file, np.array(COO_X), '%i %i %f')
    np.savetxt(y_file, np.array(COO_y), '%i %f')

    # create the queries for insert
    queries = [
        "DROP TABLE IF EXISTS Y;",
        "CREATE TEMPORARY TABLE Y (i INTEGER , val DOUBLE PRECISION );",
        "DROP TABLE IF EXISTS X;",
        "CREATE TEMPORARY TABLE X (i INTEGER , j INTEGER , val DOUBLE PRECISION );",
    ]

    if hyper:
        csv_insert = [
            f"COPY Y FROM {escape_string_literal(y_file)} WITH (format csv, delimiter ' ');",
            f"COPY X FROM {escape_string_literal(X_file)} WITH (format csv, delimiter ' ');"
        ]
    else:
        csv_insert = [
            f"COPY Y FROM {escape_string_literal(os.path.abspath(y_file))} WITH DELIMITER ' ';",
            f"COPY X FROM {escape_string_literal(os.path.abspath(X_file))} WITH DELIMITER ' ';"
        ]
    # add the specific queries to the list of all queries
    for query in csv_insert:
        queries.append(query)
    return queries


def get_gradient_descent_query(COO=True, parameter=None):
    """
    Generates the query for solving the logistic regression problem
    :param COO: boolean indicating if the data are in the C00 format
    :param parameter: dictionary containing number of iterations, features, regularization parameter and step width
    :return:
    """
    iterations = parameter.get('iterations', 10)
    features = parameter.get('features', 10)
    regularization = parameter.get('regularization', 2)
    step_width = parameter.get('step_width', 0.001)
    if COO:
        with open(os.path.join('queries', f'demo_gradient_descent_COO.sql')) as f:
            query = f.read().format(
                iterations=iterations,
                regularization=regularization,
                step_width=step_width
            )
    else:
        # create format strings
        n_features = features
        weights = ",".join([f"w{i + 1}" for i in range(n_features)])
        features = ",".join([f"f{i + 1}" for i in range(n_features)])
        floats = ",".join(["0.0::float"] * n_features)
        features_times_weight = "+".join([f"f{i + 1}*w{i + 1}" for i in range(n_features)])
        temp_with_intercept = ",".join([f"t{i + 1}" for i in range(n_features + 1)])
        # may have to change the regularization parameter
        sum_feature_times_val = ",".join([f"{regularization}*SUM(f{i + 1}*val)" for i in range(n_features)])
        g_with_intercept = ",".join([f"g{i + 1}" for i in range(n_features + 1)])
        # may have to change the step size
        weight_minus_temp_with_intercept = ",".join(
            [f"w{i + 1}-t{i + 1}" for i in range(n_features)]) + f",intercept-t{n_features + 1}"
        weight_times_reg_with_intercept = ",".join([f"w{i + 1}-{step_width}*g{i + 1}" for i in
                                                    range(n_features)]) + f",intercept-{step_width}*g{n_features + 1}"
        weight_comma_text = "||".join([f"w{i + 1}::text||','" for i in range(n_features)])

        # load the file and replace everything specific for the model
        with open(os.path.join('queries', f'demo_gradient_descent_db-friendly.sql')) as f:
            query = f.read().format(
                iterations=iterations,
                weights=weights,
                features=features,
                features_times_weight=features_times_weight,
                temp_with_intercept=temp_with_intercept,
                floats=floats,
                sum_feature_times_val=sum_feature_times_val,
                g_with_intercept=g_with_intercept,
                weight_minus_temp_with_intercept=weight_minus_temp_with_intercept,
                weight_times_reg_with_intercept=weight_times_reg_with_intercept,
                weight_comma_text=weight_comma_text,
                step_width=step_width,
                regularization=regularization
            )
    return query


############
# POSTGRES #
############
def postgres_experiment(X, y, iterations, COO=True, parameter=None, csv=False, verbose=False):
    """
    Solves the logistic regression problem for X, y using postgres
    :param X: numpy array containing the features
    :param y: numpy array containing the classes
    :param iterations: integer number of iterations
    :param COO: boolean if the COO format is used
    :param parameter: dictionary with the parameter of the optimization problem (see 'get_gradient_descent_query')
    :param csv: boolean if the data is inserted via csv copy
    :param verbose: boolean if True more information are printed
    :return: runtime, weight vector and accuracy score
    """
    # get connection to the database
    conn = psy.connect(user='postgres', password='pw', database='postgres', host='localhost')
    conn.set_isolation_level(psy.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()

    # create tables and insert data
    if COO:
        if csv:
            queries = get_queries_CSV_COO(X, y, hyper=False)
        else:
            queries = get_queries_for_COO(X, y)
    else:
        if csv:
            queries = get_queries_CSV(X, y, hyper=False)
        else:
            queries = get_queries_for_db_friendly(X, y)
    tic = timer()
    for query in queries:
        try:
            cur.execute(query)
        except Exception as e:
            print(e)
            return np.nan, None, None
    toc = timer()
    if verbose:
        print(f"Insert data in {toc-tic}s.")
    conn.commit()

    # execute query
    query = get_gradient_descent_query(COO=COO, parameter=parameter)
    # burn in
    for _ in range(iterations):
        try:
            cur.execute(query)
        except Exception:
            return np.nan, None, None
    tic = timer()
    for _ in range(iterations):
        try:
            cur.execute(query)
        except Exception:
            return np.nan, None, None
    toc = timer()
    w, a = cur.fetchall()
    # it returns a tuple with one string for all values
    w = [float(i) for i in w[1:][0].split(',')]
    a = float(a[1])
    conn.close()
    return (toc - tic) / iterations / parameter.get('iterations'), w, a


#########
# HYPER #
#########
def hyper_experiment(X, y, iterations, COO=True, parameter=None, csv=False, verbose=False):
    """
    Solves the logistic regression problem for X, y using hyper
    :param X: numpy array containing the features
    :param y: numpy array containing the classes
    :param iterations: integer number of iterations
    :param COO: boolean if the COO format is used
    :param parameter: dictionary with the parameter of the optimization problem (see 'get_gradient_descent_query')
    :param csv: boolean if the data is inserted via csv copy
    :param verbose: boolean if True more information are printed
    :return: runtime, weight vector and accuracy score
    """
    parameters = {
        "log_config": "",
        "initial_compilation_mode": "o",  # o, v, c
        "max_query_size": "10000000000",
        "hard_concurrent_query_thread_limit": threads_amount
    }
    with HyperProcess(telemetry=Telemetry.DO_NOT_SEND_USAGE_DATA_TO_TABLEAU, parameters=parameters) as hyper:
        with Connection(hyper.endpoint, f'data.hyper', CreateMode.CREATE_AND_REPLACE) as connection:
            # create tables and insert data
            if COO:
                if csv:
                    queries = get_queries_CSV_COO(X, y, hyper=True)
                else:
                    queries = get_queries_for_COO(X, y)
            else:
                if csv:
                    queries = get_queries_CSV(X, y, hyper=True)
                else:
                    queries = get_queries_for_db_friendly(X, y)
            tic = timer()
            for query in queries:
                connection.execute_list_query(query)
            toc = timer()
            if verbose:
                print(f"Insert data in {toc - tic}s.")

            # execute query
            query = get_gradient_descent_query(COO=COO, parameter=parameter)
            # burn in
            for _ in range(iterations):
                result = connection.execute_list_query(query)
            tic = timer()
            for _ in range(iterations):
                result = connection.execute_list_query(query)
            toc = timer()

    if result:
        w_a = dict(result)
        w = [float(i) for i in w_a['w:'].split(',')]
        a = float(w_a['accuracy:'])
        runtime = (toc - tic) / iterations / parameter.get('iterations', 10)
        return runtime, w, a
    return None, None, None


#########
# NUMPY #
#########
def numpy(X, y, iterations, parameter):
    """
    Solves the logistic regression problem for X, y using numpy
    :param X: numpy array containing the features
    :param y: numpy array containing the classes
    :param iterations: integer number of iterations
    :param parameter: dictionary with the parameter of the optimization problem (see 'get_gradient_descent_query')
    :return: runtime, weight vector and accuracy score
    """
    iters = parameter.get('iterations', 10)
    features = parameter.get('features', 10)
    regularization = parameter.get('regularization', 2)
    step_width = parameter.get('step_width', 0.001)

    # generate Python code from linear algebra: https://lina.ti2.uni-jena.de/
    def gradient(X, c, w, y):
        """
        Generated with LinA from input:
            w-c*X'*(exp(-y.*(X*w)).*y./(vector(1)+exp(-y.*(X*w))))
        Matrices:
            X
        Vectors:
            w, y
        Scalars:
            c
        Matching matrix and vector dimensions:
            X.shape[1] == w.shape[0]
            X.shape[0] == y.shape[0]
        """
        cse = np.exp(-(y * X.dot(w)))
        return w - c * X.T.dot(cse * y / (1 + cse))

    # batch gradient descent
    def gradient_descent(X, y, c, iterations):
        # initialize weights
        w = np.zeros(X.shape[1])
        alpha = step_width  # learning rate
        for i in range(iterations):
            g = gradient(X, c, w, y)
            w = w - alpha * g
        return w

    # predict classes of samples in X, use weights w
    def predict(X, w):
        z = np.dot(X, w)
        probs = 1 / (1 + np.exp(-z))
        return np.where(probs >= 0.5, 1, -1)

    # burnin
    for _ in range(iterations):
        w = list(gradient_descent(X, y, c=regularization, iterations=iters))
        a = sum(abs(predict(X, w) == y)) / len(X)
    tic = timer()
    for _ in range(iterations):
        w = list(gradient_descent(X, y, c=regularization, iterations=iters))
        a = sum(abs(predict(X, w) == y)) / len(X)
    toc = timer()

    return (toc - tic) / iterations / iters, w, a


########
# PLOT #
########
def plot_experiments(file="results.p", features=None):
    results = pickle.load(open(file, "rb"))
    # rearange data
    data = {}
    sample_sizes = []
    for var in results:
        if features and var not in features:
            continue
        data[var] = {}
        for sample_size in results[var]:
            if sample_size not in sample_sizes:
                sample_sizes.append(sample_size)
            for key, value in results[var][sample_size].items():
                # skip numpy
                if key == 'n':
                    continue
                if key not in data[var]:
                    data[var][key] = [results[var][sample_size]['n'] / value]
                else:
                    data[var][key].append(results[var][sample_size]['n'] / value)

    # adjust font of matplotlib
    plt.rc('axes', labelsize=11)

    # plot the data
    markers = {"n": ",", "h": "+", "hc": ".", "p": "o", "pc": '*'}
    fig, axes = plt.subplots(len(data), 1, figsize=(7, 8), sharex="all", sharey="all")
    for var, axis in zip(data, axes):
        axis.set_ylabel(f"{var} features\nspeedup against numpy")
        axis.set_xscale("log")
        axis.set_yticks((0,5,10,15,20,25,30,35,40))
        for experiment, values in data[var].items():
            v_wo_nan = [i for i in values if not np.isnan(i)]
            axis.plot(sample_sizes[:len(v_wo_nan)], v_wo_nan, label=experiment, marker=markers[experiment])
        axis.legend(["hyper", "hyper C00", "postgres", "postgres COO"], loc="lower right")
        # insert baseline one
        axis.plot(sample_sizes, [1]*len(sample_sizes), color="gray", linestyle="dotted")
    axis.set_xlabel(f"number of data points")
    plt.subplots_adjust(hspace=.0)
    plt.yscale("log")
    plt.savefig("plot.pdf")
    plt.show()
    return True

#######
# CSV #
#######
def results_to_array(data, save=True):
    """
    Translates a data dictionary into a numpy array (optional loads data)
    :param data: dictionary or string to a pickle file
    :return: numpy array
    """
    if isinstance(data, dict):
        pass
    elif isinstance(data, str):
        data = pickle.load(open(data, "rb"))
    else:
        raise Exception("data should be a dictionary or a string to a file.")

    array = []
    column_names = ["features", "data points", "numpy", "hyper", "hyper COO", "postgres", "postgres COO"]

    for feature, sizes in data.items():
        for size, times in sizes.items():
            el = [feature, size]
            for experiment, time in times.items():
                el.append(time)
            array.append(el)
    array = np.array(array)
    if save:
        np.savetxt("results.csv", array, header=",".join(column_names), delimiter=",", comments="")
    return array


if __name__ == "__main__":

    ### PARSE COMMAND LINE ARGUMENTS ###
    parser = argparse.ArgumentParser(description='Experiments for CIDR2021 publication.')
    parser.add_argument('-s', '--samples', type=int, help='number of data points in the generated dataset', default=100)
    parser.add_argument('-f', '--features', type=int, help='number of features in the generated dataset', default=4)
    parser.add_argument('-i', '--iterations', type=int, help='number of iterations for the gradient descent',
                        default=100)
    parser.add_argument('-v', '--verbose', type=bool, help='activate verbose mode', default=False)
    parser.add_argument('--all', help='run all experiments')
    args = parser.parse_args()

    ### CREATE DATA ###
    X, y = create_data(args.features, args.samples)

    ### PARAMETER FOR THE OPTIMIZATION ###
    parameter = {
        'iterations': 10,
        'regularization': 2,
        'step_width': 0.000001,
        'features': args.features
    }

    result_file = "results.p"

    results = {}

    if result_file in os.listdir():
        # plot_experiments(result_file, features=[4,16,64])
        results = pickle.load(open(result_file, "rb"))
        print("Loaded recent results file.")

    if args.all:
        for features in [4, 8, 16, 32, 64, 128]:
            if features in results.keys():
                continue
            print(f"Start with feature {features}.")
            parameter['features'] = features
            results[features] = {}
            for samples in [1e3, 1e4, 1e5, 1e6, 1e7]:
                if samples in results[features]:
                    continue
                print(f"Start with sample size {samples}.")
                results[features][samples] = {}
                X, y = create_data(features, int(samples))

                ### NUMPY ###
                runtime, wn, an = numpy(X, y, args.iterations, parameter)
                results[features][samples]['n'] = runtime

                ### HYPER ###
                runtime, wh, ah = hyper_experiment(X, y, iterations=args.iterations, COO=False, parameter=parameter, verbose=args.verbose, csv=True)
                results[features][samples]['h'] = runtime
                runtime, whc, ahc = hyper_experiment(X, y, iterations=args.iterations, COO=True, parameter=parameter, verbose=args.verbose, csv=True)
                results[features][samples]['hc'] = runtime

                if not (np.allclose(wn, wh) and np.allclose(wh, whc)):
                    print(
                        f"Numerical issue with {features} features and {samples} data points. Weight vectors are not aligned.")

                ### POSTGRES ###
                runtime, wp, ap = postgres_experiment(X, y, iterations=args.iterations, COO=True, parameter=parameter)
                results[features][samples]['p'] = runtime
                runtime, wpc, apc = postgres_experiment(X, y, iterations=args.iterations, COO=False, parameter=parameter)
                results[features][samples]['pc'] = runtime

                if not (np.allclose(wn, wh) and np.allclose(wh, whc) and np.allclose(wn, wp) and np.allclose(wp, wpc)):
                    print(f"May something is np.nan for {features} features, {samples} data points.")

                # save results
                pickle.dump(results, open(result_file, "wb"))
        # plot_experiments(result_file)

    else:
        runtime, wpc, apc = postgres_experiment(X, y, iterations=args.iterations, COO=True, parameter=parameter, csv=False)
        print("postgres COO", runtime)
        runtime, wh, ah = hyper_experiment(X, y, iterations=args.iterations, COO=False, parameter=parameter, verbose=args.verbose, csv=True)
        print("hyper", runtime)
        runtime, whc, ahc = hyper_experiment(X, y, iterations=args.iterations, COO=True, parameter=parameter, verbose=args.verbose, csv=True)
        print("hyper COO", runtime)
        runtime, wn, an = numpy(X, y, args.iterations, parameter)
        print("numpy", runtime)

        assert np.allclose(wn, wh) and np.allclose(wh, whc) and np.allclose(wh, wpc),\
            f"Numerical issue with {args.features} features and {args.samples} data points. Weight vectors are not aligned."


