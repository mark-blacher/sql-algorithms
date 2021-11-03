import numpy as np
import time

# this file contains a gradient descent implementation 
# for l2-regularized logistic regression in Python

# - the first 100 samples from the iris dataset,
#   two features (sepal_length and sepal_width --> first and second column),
#   the third column is the intercept
# - samples are shuffled
# - samples belong only to two different classes ('setosa' and 'versicolor')
X = np.array([[5.5, 2.4, 1.],
              [5.4, 3., 1.],
              [5.5, 4.2, 1.],
              [5.5, 2.4, 1.],
              [5., 2.3, 1.],
              [5.1, 3.5, 1.],
              [5.5, 3.5, 1.],
              [5.8, 2.7, 1.],
              [5.6, 2.5, 1.],
              [6.7, 3.1, 1.],
              [5.8, 2.6, 1.],
              [5.1, 3.4, 1.],
              [6.3, 3.3, 1.],
              [6.9, 3.1, 1.],
              [6.4, 3.2, 1.],
              [5.2, 4.1, 1.],
              [5.4, 3.4, 1.],
              [5.1, 3.8, 1.],
              [6., 2.9, 1.],
              [5.4, 3.7, 1.],
              [4.7, 3.2, 1.],
              [6.1, 2.8, 1.],
              [6.2, 2.9, 1.],
              [6., 2.2, 1.],
              [5.1, 3.8, 1.],
              [5., 3.2, 1.],
              [5.6, 2.7, 1.],
              [5.2, 3.5, 1.],
              [5.1, 3.8, 1.],
              [4.4, 3., 1.],
              [5.8, 2.7, 1.],
              [5.7, 2.8, 1.],
              [6.5, 2.8, 1.],
              [5.7, 3., 1.],
              [5.6, 3., 1.],
              [5., 3.5, 1.],
              [5.3, 3.7, 1.],
              [5.2, 2.7, 1.],
              [5.1, 3.3, 1.],
              [4.9, 3.1, 1.],
              [6.7, 3.1, 1.],
              [5.5, 2.3, 1.],
              [6.7, 3., 1.],
              [5.7, 4.4, 1.],
              [6., 2.7, 1.],
              [4.5, 2.3, 1.],
              [4.8, 3., 1.],
              [6.1, 3., 1.],
              [5., 3.4, 1.],
              [5.1, 2.5, 1.],
              [5., 3.5, 1.],
              [5.7, 2.8, 1.],
              [4.8, 3.4, 1.],
              [5., 3.6, 1.],
              [6.6, 2.9, 1.],
              [5., 3.3, 1.],
              [5.1, 3.7, 1.],
              [6.3, 2.3, 1.],
              [4.6, 3.1, 1.],
              [6.4, 2.9, 1.],
              [4.8, 3.1, 1.],
              [5.6, 3., 1.],
              [5.9, 3.2, 1.],
              [4.4, 3.2, 1.],
              [4.6, 3.2, 1.],
              [5.5, 2.5, 1.],
              [4.4, 2.9, 1.],
              [5., 2., 1.],
              [5.1, 3.5, 1.],
              [5.5, 2.6, 1.],
              [4.9, 2.4, 1.],
              [4.6, 3.6, 1.],
              [5.9, 3., 1.],
              [6.1, 2.9, 1.],
              [5., 3.4, 1.],
              [5.7, 2.9, 1.],
              [4.3, 3., 1.],
              [6.2, 2.2, 1.],
              [6., 3.4, 1.],
              [5.8, 4., 1.],
              [4.7, 3.2, 1.],
              [5.2, 3.4, 1.],
              [4.8, 3.4, 1.],
              [5.7, 3.8, 1.],
              [5.4, 3.4, 1.],
              [7., 3.2, 1.],
              [5., 3., 1.],
              [4.6, 3.4, 1.],
              [6.1, 2.8, 1.],
              [6.8, 2.8, 1.],
              [4.9, 3., 1.],
              [5.4, 3.9, 1.],
              [5.6, 2.9, 1.],
              [5.7, 2.6, 1.],
              [5.4, 3.9, 1.],
              [6.6, 3., 1.],
              [4.9, 3.1, 1.],
              [6.3, 2.5, 1.],
              [4.8, 3., 1.],
              [4.9, 3.6, 1.]])

# -1 = 'setosa', 1 ='versicolor'
y = np.array([1, 1, -1, 1, 1, -1, -1, 1, 1, 1, 1, -1, 1, 1, 1, -1, -1, -1, 1, -1, -1, 1, 1, 1,
              -1, -1, 1, -1, -1, -1, 1, 1, 1, 1, 1, -1, -1, 1, -1, -1, 1, 1, 1, -1, 1, -1, -1, 1,
              -1, 1, -1, 1, -1, -1, 1, -1, -1, 1, -1, 1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, -1,
              1, 1, -1, 1, -1, 1, 1, -1, -1, -1, -1, -1, -1, 1, -1, -1, 1, 1, -1, -1, 1, 1, -1, 1,
              -1, 1, -1, -1])


# - l2-regularized logistic regression
#   minimize f: 0.5*w'*w+c*sum(log(vector(1)+exp(-y.*(X*w))))
# - compute derivative with respect to w (vector of weights we want to learn):
#   http://www.matrixcalculus.org/
#   df/dw: w-c*X'*(exp(-y.*(X*w)).*y./(vector(1)+exp(-y.*(X*w))))

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
  alpha = 0.001  # learning rate
  for i in range(iterations):
    g = gradient(X, c, w, y)
    w = w - alpha * g
  return w


# predict classes of samples in X, use weights w
def predict(X, w):
  z = np.dot(X, w)
  probs = 1 / (1 + np.exp(-z))
  return np.where(probs >= 0.5, 1, -1)


if __name__ == "__main__":
  tic = time.time()
  w = gradient_descent(X, y, c=2, iterations=100)
  print("seconds:", time.time() - tic)
  print("w:", w)
  y_predicted = predict(X, w)
  print("accuracy:", sum(y_predicted == y) / X.shape[0])
