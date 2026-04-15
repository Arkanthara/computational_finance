#set page(margin: 2.5cm)
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true)
#set heading(numbering: none)

#show math.equation: set text(size: 10.5pt)

// ─── Title Block ───────────────────────────────────────────────────────────
#align(center)[
  #text(size: 13pt, weight: "bold")[{14X030} Introduction to Computational Finance]

  #v(4pt)
  #text(size: 12pt)[Exercise \#7]

  #v(4pt)
  #text(size: 11pt)[April 14, 2026]
]

#v(0.8em)
#line(length: 100%, stroke: 0.5pt)
#v(0.8em)

// ─── General Instructions ──────────────────────────────────────────────────
= General instructions

Each student is expected to upload on Moodle a zip file named as *firstname\_lastname*, containing the following:

- A report in pdf format to answer exercise questions.
- The code used to generate the results of the report.
- If preferred, submit a unique Jupyter notebook with both code and report explanations.

// ─── Deeper Instructions ───────────────────────────────────────────────────
= Deeper instructions

*Report:*
- Answers to the TP questions. Figures and numerical results are necessary but strictly not sufficient: provide your analysis/comments as well.
- Example: if your results surprise you, explain why and explain what the expected result was.
- Pay attention to the presentation: axis labels, legend, etc.

*Code:*
- Implementation questions + code used to produce the results and figures in the report.
- Programming language of your choice.
- Do not use ChatGPT, or any other LLM/AI-assisted tools while writing down your code. Try by yourself, otherwise it will be counted as failed.
- I strongly recommend Python/Julia: I won't be able to assist you in the same way if you use a different language.

// ─── Deadline ─────────────────────────────────────────────────────────────
= Deadline

Any questions to: *Lorenzo Bini*.

Upload on Moodle due by: *April 20, 2026 at 11:59 pm*

#pagebreak()

// ─── Part 1: Optimal Portfolio ─────────────────────────────────────────────
= Optimal Portfolio

In this series we look at the closing prices of McDonald's, Bank of America, IBM, Chevron, Coca-Cola, Novartis and AT&T, over a one-year time span extending from 2013-05-01 to 2014-05-01.

Download the file `closing_prices.csv` on Moodle. You can load it with the following Python code:

```python
import pandas as pd

df = pd.read_csv('closing_prices.csv')
data = df.to_numpy()  # if you prefer working with np array
```

We define the weight vector of the portfolio $bold(w) = {w_1, ..., w_7}$ such that
$sum_(i=1)^(7) w_i = 1$.

*1.* Write a function that estimates the expected return and the risk (standard deviation of returns) for a given weight vector. Then, plot the return against the risk for 100 000 randomly chosen weight vectors (Monte-Carlo simulation). What do you observe?

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

*3.* Using the efficient frontier, find the weight of the portfolio with the minimal volatility. What can you say about the return of this portfolio?

#pagebreak()

// ─── Part 2: No-Short Selling ──────────────────────────────────────────────
= Optimal Portfolio under No-Short Selling Constraints

At this point, you will extend the optimal portfolio analysis by imposing a no-short selling constraint (i.e.\ all portfolio weights must be non-negative). You will compute the efficient frontier under this additional constraint and compare it to the unconstrained (Markowitz) efficient frontier.

Keep using the provided `closing_prices.csv` file which contains the closing prices of McDonald's, Bank of America, IBM, Chevron, Coca-Cola, Novartis, and AT&T over one year (from 2013-05-01 to 2014-05-01). Load the data and compute the daily returns for each stock.

*1.* Formulate the portfolio optimization as a minimization problem where the objective is to minimize the portfolio variance subject to the following constraints:
  - The portfolio return is equal to a given target $mu_p$.
  - The sum of weights is equal to 1.
  - All weights are non-negative (no short selling).

*2.* Use a suitable Python optimization library (e.g., `cvxpy`) to solve the constrained problem.

*3.* Plot the constrained efficient frontier over the same range of previous $mu_p$.

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
