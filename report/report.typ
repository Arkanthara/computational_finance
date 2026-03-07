// Main report file
#import "template.typ": make-report, report-footnote
#import "metadata.typ": my-report
// #import ".typst_pyimage/pyimage.typ": pyinit, pycontent, pyimage

// Main content
#show: make-report.with(my-report)
#show raw.where(block: true): set block(fill: luma(240), inset: 1em, radius: 0.5em, width: 100%)
#show raw.where(block: false): box.with(
  fill: rgb("#e573e927"),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)


```python
R = [1/(100 + i) for i in range(12)]
R_a = 1
for R_i in R:
  R_a *= (1 + R_i)
R_a -= 1
print(f"R_a = {R_a:.2f}")
```
// #raw(
//   py.block(
//     ```
//     R = [1/(100 + i) for i in range(12)]
//     R_a = 1
//     for R_i in R:
//       R_a *= (1 + R_i)
//     R_a -= 1
//     f"R_a = {R_a:.2f}"
//     ```,
//   ),
//   lang: "python",
// )

= General instructions

Each student is expected to upload on Moodle a zip file named as `firstname_lastname`, containing the following:

- A report in pdf format to answer exercise questions.
- The code used to generate the results of the report.
- If preferred, submit a unique Jupyter notebook with both code and report explanations.

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

= Deadline

Any questions to: Lorenzo Bini.

Upload on Moodle due by: *March 9, 2026 at 11:59 pm*

#pagebreak()

= Correlation of two random variables

- Let $A$ and $B$ be two independent random variables such that $A tilde cal(N)(mu_A, sigma_A)$ and $B tilde cal(N)(mu_B, sigma_B)$, with $mu_A = mu_B = 0$, $sigma_A = 1$ and $sigma_B = 2$.
- Let $X$ and $Y$ be two random variables such that $X = A + 4B$ and $Y = 2A + B$.

*1. Derive analytically the following quantities:*

#set enum(numbering: "(a)")
#let Var = math.op("Var")
#let Cov = math.op("Cov")
#let Cor = math.op("Cor")

+ $mu_X$, $mu_Y$, $sigma_X$ and $sigma_Y$, the expectations and standard deviations of $X$ and $Y$.

  - #align(
      left,
      $
        mu_X & = EE[X] \
             & = EE[A + 4B] \
             & = EE[A] + 4EE[B] \
             & = mu_A + 4 mu_B \
             & = 0
      $,
    )
  - #align(
      left,
      $
        mu_Y & = EE[Y] \
             & = EE[2A + B] \
             & = 2EE[A] + EE[B] \
             & = 2mu_A + mu_B \
             & = 0
      $,
    )
  - #align(
      left,
      $
        sigma_X^2 & = Var[X] \
                  & = Var[A + 4B] \
                  & = Var[A] + 4^2 Var[B] \
                  & = sigma_A^2 + 4^2 sigma_B^2 \
                  & = 1 + 16 dot 2^2 \
                  & = 65 \
      $,
    )
    So $sigma_X = sqrt(65)$
  - #align(
      left,
      $
        sigma_Y^2 & = Var[Y] \
                  & = Var[2A + B] \
                  & = 2^2 Var[A] + Var[B] \
                  & = 4 sigma_A^2 + sigma_B^2 \
                  & = 4 + 4 \
                  & = 8 \
      $,
    )
    So $sigma_Y = sqrt(8) = 2sqrt(2)$

+ The covariance between $X$ and $Y$, defined as:
  $ Cov(X, Y) = bb(E)[(X - mu_X)(Y - mu_Y)] $

  - #align(
      left,
      $
        Cov(X, Y) & = EE[(X - mu_X)(Y - mu_Y)] \
        & = EE[X Y] \
        & = EE[(A + 4B)(2A + B)] \
        & = EE[2A^2 + A B + 8A B + 4B^2] \
        & = 2EE[A^2] + 9 EE[A B] + 4EE[B^2] \
        & = 2EE[A^2] + 4EE[B^2] text("      Independance") ==> EE[A B] <=> EE[A]EE[B] \
        & = 2(Var(A) + EE[A]^2) + 4(Var(B) + EE[B])^#report-footnote($Var(U) = EE[U^2] - EE[U]^2 <==> E[U^2] = Var(U) + EE[U]^2$) \
        & = 2(sigma_A^2 + mu_A^2) + 4(sigma_B^2 + mu_B) \
        & = 2sigma_A^2 + 4sigma_B^2 \
        & = 18 \
      $,
    )

+ The correlation coefficient between $X$ and $Y$, defined as:
  $ Cor(X, Y) = frac(Cov(X, Y), sigma_X sigma_Y) $
  - #align(
      left,
      $
        Cor(X, Y) & = Cov(X, Y)/(sigma_X sigma_Y) \
                  & = 18/(sqrt(65) dot 2sqrt(2)) \
                  & approx 0.789
      $,
    )

#set enum(numbering: "1.")

*2. Using the language of your choice:*

#set enum(numbering: "(a)")

+ Simulate $n = 10000$ realizations of $A$ and $B$ and draw the graph of the corresponding realizations of $X$ vs realizations of $Y$.

  ```python
  import numpy as np
  import matplotlib.pyplot as plt

  # Generate n realizations

  np.random.seed(0)
  n = 10000
  mu_a, sig_a = 0, 1
  mu_b, sig_b = 0, 2
  a = np.random.normal(mu_a, sig_a, n)
  b = np.random.normal(mu_b, sig_b, n)
  x = a + 4 * b
  y = 2 * a + b

  z = np.linspace(np.min(x), np.max(x), 200)

  # Plot results
  plt.figure()
  plt.plot(x, y, 'o', label='Realizations')
  plt.plot(z, (1 - 18 / (np.sqrt(65) * 2 * np.sqrt(2))) * z, 'r--', label='Correlation line')
  plt.xlabel("Realizations of X")
  plt.ylabel("Realizations of Y")
  plt.title("Realizations of X vs Y" )
  plt.legend()
  plt.show()
  ```



+ How does this relate to the value of $"Cor"(X, Y)$? Is the slope equal to the correlation coefficient? Comment on this last point.

+ Compute the empirical correlation coefficient from the $n$ realizations and compare it to the value of $"Cor"(X, Y)$ obtained from the above analytical derivation (1c).

#set enum(numbering: "1.")

#pagebreak()

= Hidden sine

Consider the following time series:

$ forall t in {1, dots, n}, quad X_t = sin lr((frac(2 pi t, T))) + epsilon_t $

with $epsilon_t tilde cal(N)(0, 1)$, $T = 10$ and $n = 1000$.

#set enum(numbering: "1.")

+ Plot a realization of the time series above.

  ```python
  T = 10
  X_t = lambda t: np.sin(2 * np.pi * t / T) + np.random.normal(0, 1)
  X = X_t(np.arange(1, 1001))
  
  plt.figure()
  plt.plot(X)
  plt.xlabel("Time")
  plt.ylabel("X_t")
  plt.title("Realization of the time series")
  plt.show()
  ```

+ Compute and plot the corresponding ACF graph for lags $0$ to $50$.

+ Try with other values of $T$ and comment on the impact of $T$ on the ACF graph.

= AR model on an empirical time series

The file `eur_usd.txt` (download it from Moodle) contains the daily EUR/USD price evolution with the following data structure:

```
timestamp price
```

where `timestamp` denotes the time (in seconds) measured starting from 01 Jan 1970 00:00:00.000.

You can use the following snippet of Python code to load the data:

```python
from datetime import datetime
import numpy as np
data = np.loadtxt('eur_usd.txt')
price_ts = data[:, 1]
# Tip: You can convert the timestamp to a better format:
days = [datetime.fromtimestamp(x).strftime('%b %d') for x in data[:, 0]]
```

*1. Preprocessing of the time series.*

#set enum(numbering: "(a)")

+ Plot the time series. Does it look stationary?

+ Compute the corresponding daily returns and plot this new time series. Does it look stationary? From now on subtract the mean of this series to center it around zero.

#set enum(numbering: "1.")

*2. Analysis of the time series of daily returns.*

#set enum(numbering: "(a)")

+ Compute and plot the ACF for lags $0$ to $10$.

+ Using the analytical expressions seen during the course, compute the parameter $phi_1$ of the AR(1) model for this time series.

+ Use your model to do predictions from the initial value. Plot the predictions along the time series of daily returns on the same graph. What do you think of these predictions?

#set enum(numbering: "1.")

*3. AR(p) model with a library.*

#set enum(numbering: "(a)")

+ In Python, you can use the `statsmodels` library to fit an AR($p$) model on a time series.

  ```python
  from statsmodels.tsa.ar_model import AutoReg
  predictions = AutoReg(your_time_series, lags=p).fit().predict()
  ```

  Plot the AR(1) predictions computed with this library and compare it to the predictions of your model obtained in 2c (hint: it should be really similar).

+ Using this library, plot the predictions for higher-order AR models. Does the quality of the predictions improve?

#set enum(numbering: "1.")

#pagebreak()

= FX risk management: EWMA volatility and 1-day VaR

A bit of introduction before delving into the exercise:

- *FX risk:* If you hold a position in a foreign currency (e.g., you are long EUR/USD), you are exposed to FX risk, which is the risk that exchange rate movements will lead to losses.

- *EWMA volatility:* The Exponentially Weighted Moving Average (EWMA) model estimates volatility by giving more weight to recent returns. The formula $sigma_t^2 = lambda sigma_(t-1)^2 + (1 - lambda) r_(t-1)^2$ updates the variance estimate at time $t$ based on the previous variance and the most recent return.

- *VaR:* Value-at-Risk (VaR) is a risk measure that quantifies the potential loss in value of a portfolio over a defined period for a given confidence level. For example, a 1-day 99% VaR of $X$ means there is a 1% chance that the loss will exceed $X$ in 1 day.

- *Rolling 1-day forecast:* This means that each day, you compute a new 1-day-ahead forecast for VaR using all available data up to that day. As new data comes in, your estimates will update, reflecting the latest market conditions.

You will now have to build a simple EWMA model and translate it into a 1-day VaR forecast, then evaluate how often losses breach the VaR threshold. Assuming you hold an EUR/USD exposure, use the daily EUR/USD prices in `eur_usd.txt` to:

#set enum(numbering: "1.")

+ Compute the daily log-returns $r_t = ln(P_t \/ P_(t-1))$ and plot the series.

+ Estimate the conditional volatility with an EWMA model:
  $ sigma_t^2 = lambda sigma_(t-1)^2 + (1 - lambda) r_(t-1)^2 $
  using $lambda = 0.94$. Initialize $sigma_0^2$ with the sample variance of the return series. Plot $sigma_t$.

+ Assume a position value of $V_0 = 10'000'000$ USD. Compute the 1-day VaR at 99% and 95%:
  $ "VaR"_t^alpha = z_alpha sigma_t V_0, quad z_(0.99) = 2.326, quad z_(0.95) = 1.645 $
  where $z_alpha$ is the standard normal quantile satisfying $P(Z <= z_alpha) = alpha$ for $Z tilde cal(N)(0, 1)$. Plot the daily loss $L_t = -V_0 r_t$ together with $"VaR"_t^(99%)$ and $"VaR"_t^(95%)$.

+ *(Optional)* Backtest the VaR: since $sigma_t$ uses $r_(t-1)$, interpret $"VaR"_t$ as a 1-day-ahead forecast for day $t$. Compute the fraction of days such that $L_t > "VaR"_t^(99%)$ and $L_t > "VaR"_t^(95%)$. Compare to the expected exceedance rates (1% and 5%) and report the expected number of exceedances ($n_alpha$) for the sample size. Comment on the impact of a short sample.

  #block(
    fill: luma(235),
    inset: 8pt,
    radius: 4pt,
    [*Note on the interpretation:* VaR backtests are noisy on short samples. If you have only a few dozen observations, it is entirely plausible to observe zero 99% exceedances even when the model is correct. This exercise is about the workflow and interpretation, not about passing a formal backtest.],
  )
