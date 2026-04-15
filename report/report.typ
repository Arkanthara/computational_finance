// Main report file
#import "template.typ": make-report, report-footnote
#import "metadata.typ": my-report

// Main content
#show: make-report.with(my-report)
#show raw.where(block: true): set block(fill: luma(240), inset: 1em, radius: 0.5em, width: 100%)
#show raw.where(block: false): box.with(
  fill: rgb("#e573e927"),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)


// ─── Part 1: Optimal Portfolio ─────────────────────────────────────────────
= Optimal Portfolio

In this series we look at the closing prices of McDonald's, Bank of America, IBM, Chevron, Coca-Cola, Novartis and AT&T, over a one-year time span extending from 2013-05-01 to 2014-05-01.

Download the file `closing_prices.csv` on Moodle. You can load it with the following Python code:

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

df = pd.read_csv('closing_prices.csv')
data = df.to_numpy()  # if you prefer working with np array
```

We define the weight vector of the portfolio $bold(w) = {w_1, ..., w_7}$ such that
$sum_(i=1)^(7) w_i = 1$.

*1.* Write a function that estimates the expected return and the risk (standard deviation of returns) for a given weight vector. Then, plot the return against the risk for 100 000 randomly chosen weight vectors (Monte-Carlo simulation). What do you observe?

  ```python
  def returns(data: np.ndarray) -> np.ndarray:
      """
      Compute the daily returns from the closing prices.

      Parameters:
      data (np.ndarray): A 2D array where each column represents the closing prices of an asset.

      Returns:
      np.ndarray: A 2D array of daily returns for each asset.
      """
      return (data[1:] - data[:-1]) / data[:-1]


  def portfolio_performance(weights: np.ndarray, returns: np.ndarray) -> tuple[float, float]:
      """
      Compute the expected return and risk of a portfolio given its weights and the returns of the assets.

      Parameters:
      weights (np.ndarray): A 1D array of portfolio weights.
      returns (np.ndarray): A 2D array where each column represents the returns of an asset.

      Returns:
      tuple[float, float]: A tuple containing the expected return and risk (standard deviation) of the portfolio.
      """
      # Ensure weights sum to 1
      weights = weights / np.sum(weights)

      # Ensure weights have correct shape
      if weights.ndim == 1:
          weights = weights.reshape(-1, 1)
      
      # Compute expected return
      expected_return = (np.mean(returns, axis=0) @ weights)[0]
      
      # Compute risk (standard deviation)
      risk = (np.std(returns, axis=0) @ weights)[0]
      
      return expected_return, risk

  risks = []
  rets = []
  for _ in range(100000):
      random_weights = np.random.rand(7)
      ret, risk = portfolio_performance(random_weights, data)
      rets.append(ret)
      risks.append(risk)
  plt.figure()
  plt.scatter(risks, rets)
  plt.xlabel('Risk (Standard Deviation)')
  plt.ylabel('Expected Return')
  plt.title('Monte-Carlo Simulation of Portfolio Performance')
  plt.show()
  ```

  The scatter plot follows an eliptic shape, with a clear upper boundary. This boundary corresponds to the efficient frontier, which represents the set of optimal portfolios that offer the highest expected return for a given level of risk.

*2.* We introduced the following analytical expressions during the course to compute the weight vector that minimizes the risk given a desired portfolio return $mu_p$:

$
a &= bold(1)^T C^(-1) bold(1) \
b &= bold(1)^T C^(-1) bold(mu) \
c &= bold(mu)^T C^(-1) bold(mu) \
d &= a c - b^2 \
lambda_1 &= (c - b mu_p) / d \
lambda_2 &= (a mu_p - b) / d \
bold(w) &= C^(-1)(lambda_1 bold(1) + lambda_2 bold(mu))
$

With $bold(mu) = {mu_1, ..., mu_7}$ the expected returns of each stock and $C$ the covariance matrix of returns.

Using this expression, draw Markowitz's efficient frontier for portfolio return $mu_p in [-0.0006,\ +0.0004]$.

  ```python
  def closed_form(mu: np.ndarray, cov: np.ndarray, mu_p: float) -> np.ndarray:
      """
      Compute the optimal portfolio weights using the closed-form solution.

      Parameters:
      mu (np.ndarray): A 1D array of expected returns for each asset.
      cov (np.ndarray): A 2D array representing the covariance matrix of returns.
      mu_p (float): The desired portfolio return.

      Returns:
      np.ndarray: A 1D array of optimal portfolio weights.
      """
      ones = np.ones(len(mu))
      inv_cov = np.linalg.inv(cov)

      a = ones.T @ inv_cov @ ones
      b = ones.T @ inv_cov @ mu
      c = mu.T @ inv_cov @ mu
      d = a * c - b ** 2

      lambda_1 = (c - b * mu_p) / d
      lambda_2 = (a * mu_p - b) / d

      weights = inv_cov @ (lambda_1 * ones + lambda_2 * mu)
      
      return weights.flatten()

  mu = np.mean(returns(data), axis=0)
  cov = np.cov(returns(data).T)

  mu_p_values = np.linspace(-0.0006, 0.0004, 100)
  efficient_frontier = []
  for mu_p in mu_p_values:
      weights = closed_form(mu, cov, mu_p)
      ret, risk = portfolio_performance(weights, returns(data))
      efficient_frontier.append((risk, ret))
  efficient_frontier = np.array(efficient_frontier)

  plt.figure()
  plt.plot(efficient_frontier[:, 0], efficient_frontier[:, 1], label='Efficient Frontier')
  plt.xlabel('Risk (Standard Deviation)')
  plt.ylabel('Expected Return')
  plt.title('Markowitz Efficient Frontier')
  plt.legend()
  plt.show()
  ```

*3.* Using the efficient frontier, find the weight of the portfolio with the minimal volatility. What can you say about the return of this portfolio?

  ```python
  min_vol_index = np.argmin(efficient_frontier[:, 0])
  min_vol_weights = closed_form(mu, cov, mu_p_values[min_vol_index])
  min_vol_return, min_vol_risk = portfolio_performance(min_vol_weights, returns(data))

  print(f"Minimum Volatility Portfolio Weights:\n{min_vol_weights}")
  print(f"Expected Return: {min_vol_return}")
  print(f"Risk (Standard Deviation): {min_vol_risk}")
  ```

  The portfolio with the minimal volatility is a portfolio with a return ...

#pagebreak()

// ─── Part 2: No-Short Selling ──────────────────────────────────────────────
= Optimal Portfolio under No-Short Selling Constraints

At this point, you will extend the optimal portfolio analysis by imposing a no-short selling constraint (i.e. all portfolio weights must be non-negative). You will compute the efficient frontier under this additional constraint and compare it to the unconstrained (Markowitz) efficient frontier.

Keep using the provided `closing_prices.csv` file which contains the closing prices of McDonald's, Bank of America, IBM, Chevron, Coca-Cola, Novartis, and AT&T over one year (from 2013-05-01 to 2014-05-01). Load the data and compute the daily returns for each stock.

*1.* Formulate the portfolio optimization as a minimization problem where the objective is to minimize the portfolio variance subject to the following constraints:
  - The portfolio return is equal to a given target $mu_p$.
  - The sum of weights is equal to 1.
  - All weights are non-negative (no short selling).

  The portfolio variance can be expressed as $w^T C w$, where $w$ is the weight vector and $C$ is the covariance matrix of returns.
  So the optimization problem can be formulated as:
  $
    min_w w^T C w - q w^T mu \
  $
  with the constraints:
  - $w^T mu = mu_p$ (target return constraint)
  - $sum(w) = 1$ (weights sum to 1)
  - $w_i >= 0$ for all $i$ (no short selling)

  Here, $q in [0, infinity)$ is the risk factor that controls the trade-off between risk and return.


*2.* Use a suitable Python optimization library (e.g., `cvxpy`) to solve the constrained problem.

  ```python
  import cvxpy as cp
  def optimize_portfolio(mu: np.ndarray, cov: np.ndarray, mu_p: float) -> np.ndarray:
      """
      Optimize the portfolio weights under no-short selling constraints.

      Parameters:
      mu (np.ndarray): A 1D array of expected returns for each asset.
      cov (np.ndarray): A 2D array representing the covariance matrix of returns.
      mu_p (float): The desired portfolio return.

      Returns:
      np.ndarray: A 1D array of optimal portfolio weights.
      """
      n = len(mu)
      w = cp.Variable(n)
      
      # Define the objective function (minimize variance)
      objective = cp.Minimize(cp.quad_form(w, cov))
      
      # Define the constraints
      constraints = [
          w @ mu == mu_p,  # Target return constraint
          cp.sum(w) == 1,   # Weights sum to 1
          w >= 0            # No short selling
      ]
      
      # Solve the optimization problem
      prob = cp.Problem(objective, constraints)
      prob.solve()
      
      return np.array(w.value)
  ```

*3.* Plot the constrained efficient frontier over the same range of previous $mu_p$.

  ```python
  constrained_frontier = []
  for mu_p in mu_p_values:
      weights = optimize_portfolio(mu, cov, mu_p)
      print(weights)
      print(weights.sum())
      ret, risk = portfolio_performance(weights, returns(data))
      constrained_frontier.append((risk, ret))
  constrained_frontier = np.array(constrained_frontier)

  plt.figure()
  plt.plot(efficient_frontier[:, 0], efficient_frontier[:, 1], label='Unconstrained Efficient Frontier')
  plt.plot(constrained_frontier[:, 0], constrained_frontier[:, 1], label='Constrained Efficient Frontier', linestyle='--')
  plt.xlabel('Risk (Standard Deviation)')
  plt.ylabel('Expected Return')
  plt.title('Efficient Frontiers with and without No-Short Selling Constraint')
  plt.legend()
  plt.show()
  ```

*4.* Compare the unconstrained (computed from Exercise \#1) and constrained efficient frontiers.

*5.* Discuss the impact of the no-short selling constraint on the risk-return trade-off.

*6.* Identify and report the portfolio with minimal risk under the no-short selling constraint and comment on its expected return.

#v(1em)
#block(
  fill: luma(235),
  inset: 10pt,
  radius: 4pt,
  [
    *Note:* You can use the `cvxpy` library to solve the constrained optimization problem. The library allows you to define the optimization variables, objective function, and constraints in a straightforward manner. Make sure to install it if you haven't already:
    ```
    pip install cvxpy
    ```
  ]
)

