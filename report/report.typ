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


// ─── Section 1 ───────────────────────────────────────────────────────────────
= Time average

You can use the following snippet of Python code to generate a time series:

```python
import numpy as np
import matplotlib.pyplot as plt

np.random.seed(1)
n = 1000
ts = 100 + np.cumsum(np.random.uniform(-1, 1, n))
```

+ Code your own implementation of:
  - A simple moving average (SMA)
```python
def SMA(ts: np.ndarray, N: int) -> np.ndarray:
  index = np.arange(len(ts))
  convolution_index = index[N//2:-N//2 + 1]
  return convolution_index, np.convolve(ts, np.ones(N)/N, mode="valid")

plt.figure()
plt.title("Simple Moving Average")
plt.plot(np.arange(n), ts, label="Time series")
plt.plot(*SMA(ts, N=10), label="SMA")
plt.legend()
plt.show()
```
  - An exponential moving average (EMA)

```python
def EMA(ts: np.ndarray, alpha: float) -> np.ndarray:
  EMA = [ts[0]]
  for i in range(1, len(ts)):
    EMA.append(alpha * ts[i] + (1 - alpha) * EMA[-1])
  return np.array(EMA)

plt.figure()
plt.title("Exponential Moving Average")
plt.plot(np.arange(n), ts, label="Time series")
plt.plot(np.arange(n), EMA(ts, alpha=0.5), label="EMA")
plt.legend()
plt.show()
```

  Make sure that $"SMA"("ts", N = 1) = "EMA"("ts", alpha = 1) = "ts"$.

```python
assert np.array_equal(ts, SMA(ts, N=1)[1]) and np.array_equal(ts, EMA(ts, alpha=1)), "SMA(ts, N = 1) must be equal to EMA(ts, alpha=1) and ts !"
```


+ For the following, you can use a library if you did not succeed to implement your own moving
  averages. On the same graph, plot the nine following curves:
  - The original time series `ts`
  - ${"SMA"("ts", N), "EMA"("ts", alpha = 2 / (N+1)), forall N in {10, 50, 100, 200}}$

```python
%| img-width: 100%
plt.figure()
plt.title("Time series, simple moving average and exponential moving average")
plt.plot(np.arange(n), ts, label="Time series")
for N in [10, 50, 100, 200]:
  plt.plot(*SMA(ts, N), label=f"SMA(ts, N={N})")
  plt.plot(np.arange(n), EMA(ts, 2/(N + 1)), label=f"EMA(ts, alpha=2/({N} + 1))")
plt.legend()
plt.show()
```

  What can you say of SMA vs EMA? How does the fit and the lag relate to $N$?

+ On the same graph, plot the four following curves:
  - The original time series `ts`
  - ${"EMA"("ts", alpha), forall alpha in {0.01, 0.1, 0.5}}$

```python
plt.figure()
plt.title("Time series and exponential moving average")
plt.plot(np.arange(n), ts, label="Time series")
for alpha in [0.01, 0.1, 0.5]:
  plt.plot(np.arange(n), EMA(ts, alpha), label=f"EMA(ts, alpha={alpha})")
plt.legend()
plt.show()
```

  What do you observe when $alpha$ varies?

// ─── Section 2 ───────────────────────────────────────────────────────────────
= Scaling law

For this exercise, load the data provided in TP\_03 (EUR/USD, tick-by-tick, from January 1st
to March 1st 2012).

+ Plot the time series of mid-price against true time.

```python
import matplotlib.dates as mdates
import datetime

data = np.loadtxt('eur_usd_20120101_20120301.txt')
dates = np.array([datetime.datetime.fromtimestamp(x) for x in data[:, 0]])
bids = data[:, 1]
asks = data[:, 2]
plt.figure()
plt.title("Time series of mid-price against true time")
plt.plot(dates, (asks + bids) / 2)
plt.gca().xaxis.set_major_locator(mdates.WeekdayLocator())
plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%b %d %Y'))
plt.gcf().autofmt_xdate()
plt.show()
```

+ On the same graph, plot the directional changes for $delta = 0.01$.

+ Draw a log-log plot of the number of directional changes as a function of the scale $delta$
  for values of $delta in [10^(-5), 10^(-2)]$. What do you observe?

// ─── Section 3 ───────────────────────────────────────────────────────────────
= Intrinsic Time Return

The purpose of this exercise is to investigate how measuring returns in intrinsic time
(i.e. using directional change events as time markers) changes the statistical properties
of asset returns relative to the standard physical-time approach.

+ Use the provided EUR/USD tick-by-tick dataset. Compute the mid-price as the average of
  bid and ask.

+ Using $delta = 0.001$ for directional changes:
  - Compute the returns between successive directional change events (intrinsic returns).
  - Compute the returns over fixed physical time intervals (e.g., daily returns) for comparison.
  - Plot histograms of both sets of returns. Compare statistical properties (mean, standard
    deviation, skewness, kurtosis) of intrinsic versus physical-time returns, and discuss how
    the use of intrinsic time might provide different insights into market dynamics.

// ─── Section 4 ───────────────────────────────────────────────────────────────
= Crossover Strategy Simulation

In this exercise, you will have to design and backtest a simple moving average crossover trading
strategy using real EUR/USD data. The strategy uses two moving averages, a fast and a slow one,
to generate buy and sell signals.

+ Compute two exponential moving averages (EMA): a fast one with a short window
  (e.g., $alpha_f = 2 \/ (N_f + 1)$ with $N_f = 20$) and a slow one with a longer window
  (e.g., $alpha_s = 2 \/ (N_s + 1)$ with $N_s = 2000$).

+ Define a *buy signal* when the fast EMA crosses above the slow EMA and a *sell signal*
  when it crosses below.

+ Simulate trading over the available data. For simplicity, assume you buy one unit on a buy
  signal and sell (or short) one unit on a sell signal.

+ Plot the mid-price with the fast and slow EMAs, and indicate the buy/sell points.

+ Discuss the strategy's effectiveness and potential limitations/improvements, for example try
  resampling the data (e.g., to 5-minute intervals) to reduce the number of signals: would it
  smooth out some of the noise? What do you observe?
