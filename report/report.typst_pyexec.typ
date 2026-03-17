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
    padded_ts = np.pad(ts, pad_width=N - (N % 2), mode="symmetric")
    return np.convolve(padded_ts, np.ones(N) / N, mode="valid")


plt.figure()
plt.title("Simple Moving Average")
plt.plot(np.arange(n), ts, label="Time series")
plt.plot(np.arange(n), SMA(ts, N=10), label="SMA")
plt.legend()
plt.show()
```

#raw("---------------------------------------------------------------------------\nValueError                                Traceback (most recent call last)\nCell In[144], line 17\n     15 plt.title(\"Simple Moving Average\")\n     16 plt.plot(np.arange(n), ts, label=\"Time series\")\n---> 17 plt.plot(np.arange(n), SMA(ts, N=10), label=\"SMA\")\n     18 plt.legend()\n     19 plt.show()\n\nFile ~/.cache/uv/archive-v0/zuhJDJJIk2YrBDgqeBSJm/lib/python3.14/site-packages/matplotlib/pyplot.py:3838, in plot(scalex, scaley, data, *args, **kwargs)\n   3830 @_copy_docstring_and_deprecators(Axes.plot)\n   3831 def plot(\n   3832     *args: float | ArrayLike | str,\n   (...)   3836     **kwargs,\n   3837 ) -> list[Line2D]:\n-> 3838     return gca().plot(\n   3839         *args,\n   3840         scalex=scalex,\n   3841         scaley=scaley,\n   3842         **({\"data\": data} if data is not None else {}),\n   3843         **kwargs,\n   3844     )\n\nFile ~/.cache/uv/archive-v0/zuhJDJJIk2YrBDgqeBSJm/lib/python3.14/site-packages/matplotlib/axes/_axes.py:1777, in Axes.plot(self, scalex, scaley, data, *args, **kwargs)\n   1534 \"\"\"\n   1535 Plot y versus x as lines and/or markers.\n   1536 \n   (...)   1774 (``'green'``) or hex strings (``'#008000'``).\n   1775 \"\"\"\n   1776 kwargs = cbook.normalize_kwargs(kwargs, mlines.Line2D)\n-> 1777 lines = [*self._get_lines(self, *args, data=data, **kwargs)]\n   1778 for line in lines:\n   1779     self.add_line(line)\n\nFile ~/.cache/uv/archive-v0/zuhJDJJIk2YrBDgqeBSJm/lib/python3.14/site-packages/matplotlib/axes/_base.py:297, in _process_plot_var_args.__call__(self, axes, data, return_kwargs, *args, **kwargs)\n    295     this += args[0],\n    296     args = args[1:]\n--> 297 yield from self._plot_args(\n    298     axes, this, kwargs, ambiguous_fmt_datakey=ambiguous_fmt_datakey,\n    299     return_kwargs=return_kwargs\n    300 )\n\nFile ~/.cache/uv/archive-v0/zuhJDJJIk2YrBDgqeBSJm/lib/python3.14/site-packages/matplotlib/axes/_base.py:494, in _process_plot_var_args._plot_args(self, axes, tup, kwargs, return_kwargs, ambiguous_fmt_datakey)\n    491     axes.yaxis.update_units(y)\n    493 if x.shape[0] != y.shape[0]:\n--> 494     raise ValueError(f\"x and y must have same first dimension, but \"\n    495                      f\"have shapes {x.shape} and {y.shape}\")\n    496 if x.ndim > 2 or y.ndim > 2:\n    497     raise ValueError(f\"x and y can be no greater than 2D, but have \"\n    498                      f\"shapes {x.shape} and {y.shape}\")\n\nValueError: x and y must have same first dimension, but have shapes (1000,) and (1011,)", lang: "traceback")

#figure(image(".typst_pyexec/figures/cell_2_1.svg"), caption: [Simple Moving Average])

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
plt.plot(np.arange(n), EMA(ts, alpha=1), label="EMA")
plt.legend()
plt.show()
```

#figure(image(".typst_pyexec/figures/cell_3_1.svg"), caption: [Exponential Moving Average])


  Make sure that $"SMA"("ts", N = 1) = "EMA"("ts", alpha = 1) = "ts"$.

```python
assert np.array_equal(ts, SMA(ts, N=1)) and np.array_equal(
    ts, EMA(ts, alpha=1)
), "SMA(ts, N = 1) must be equal to EMA(ts, alpha=1) and ts !"
```



+ For the following, you can use a library if you did not succeed to implement your own moving
  averages. On the same graph, plot the nine following curves:
  - The original time series `ts`
  - ${"SMA"("ts", N), "EMA"("ts", alpha = 2 / (N+1)), forall N in {10, 50, 100, 200}}$

```python
plt.figure()
plt.title("Time series, simple moving average and exponential moving average")
plt.plot(np.arange(n), ts, label="Time series")
for N in [10, 50, 100, 200]:
    plt.plot(np.arange(n), SMA(ts, N), label=f"SMA(ts, N={N})")
    plt.plot(np.arange(n), EMA(ts, 2 / (N + 1)), label=f"EMA(ts, alpha=2/({N} + 1))")
plt.legend()
plt.show()
```

#raw("---------------------------------------------------------------------------\nValueError                                Traceback (most recent call last)\nCell In[146], line 15\n     13 plt.plot(np.arange(n), ts, label=\"Time series\")\n     14 for N in [10, 50, 100, 200]:\n---> 15   plt.plot(np.arange(n), SMA(ts, N), label=f\"SMA(ts, N={N})\")\n     16   plt.plot(np.arange(n), EMA(ts, 2/(N + 1)), label=f\"EMA(ts, alpha=2/({N} + 1))\")\n     17 plt.legend()\n\nFile ~/.cache/uv/archive-v0/zuhJDJJIk2YrBDgqeBSJm/lib/python3.14/site-packages/matplotlib/pyplot.py:3838, in plot(scalex, scaley, data, *args, **kwargs)\n   3830 @_copy_docstring_and_deprecators(Axes.plot)\n   3831 def plot(\n   3832     *args: float | ArrayLike | str,\n   (...)   3836     **kwargs,\n   3837 ) -> list[Line2D]:\n-> 3838     return gca().plot(\n   3839         *args,\n   3840         scalex=scalex,\n   3841         scaley=scaley,\n   3842         **({\"data\": data} if data is not None else {}),\n   3843         **kwargs,\n   3844     )\n\nFile ~/.cache/uv/archive-v0/zuhJDJJIk2YrBDgqeBSJm/lib/python3.14/site-packages/matplotlib/axes/_axes.py:1777, in Axes.plot(self, scalex, scaley, data, *args, **kwargs)\n   1534 \"\"\"\n   1535 Plot y versus x as lines and/or markers.\n   1536 \n   (...)   1774 (``'green'``) or hex strings (``'#008000'``).\n   1775 \"\"\"\n   1776 kwargs = cbook.normalize_kwargs(kwargs, mlines.Line2D)\n-> 1777 lines = [*self._get_lines(self, *args, data=data, **kwargs)]\n   1778 for line in lines:\n   1779     self.add_line(line)\n\nFile ~/.cache/uv/archive-v0/zuhJDJJIk2YrBDgqeBSJm/lib/python3.14/site-packages/matplotlib/axes/_base.py:297, in _process_plot_var_args.__call__(self, axes, data, return_kwargs, *args, **kwargs)\n    295     this += args[0],\n    296     args = args[1:]\n--> 297 yield from self._plot_args(\n    298     axes, this, kwargs, ambiguous_fmt_datakey=ambiguous_fmt_datakey,\n    299     return_kwargs=return_kwargs\n    300 )\n\nFile ~/.cache/uv/archive-v0/zuhJDJJIk2YrBDgqeBSJm/lib/python3.14/site-packages/matplotlib/axes/_base.py:494, in _process_plot_var_args._plot_args(self, axes, tup, kwargs, return_kwargs, ambiguous_fmt_datakey)\n    491     axes.yaxis.update_units(y)\n    493 if x.shape[0] != y.shape[0]:\n--> 494     raise ValueError(f\"x and y must have same first dimension, but \"\n    495                      f\"have shapes {x.shape} and {y.shape}\")\n    496 if x.ndim > 2 or y.ndim > 2:\n    497     raise ValueError(f\"x and y can be no greater than 2D, but have \"\n    498                      f\"shapes {x.shape} and {y.shape}\")\n\nValueError: x and y must have same first dimension, but have shapes (1000,) and (1011,)", lang: "traceback")

#figure(image(".typst_pyexec/figures/cell_5_1.svg", width: 140%), caption: [Time series, simple moving average and exponential moving average])


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

#figure(image(".typst_pyexec/figures/cell_6_1.svg"), caption: [Time series and exponential moving average])


  What do you observe when $alpha$ varies?

// ─── Section 2 ───────────────────────────────────────────────────────────────
= Scaling law

For this exercise, load the data provided in TP\_03 (EUR/USD, tick-by-tick, from January 1st
to March 1st 2012).

+ Plot the time series of mid-price against true time.

```python
import matplotlib.dates as mdates

import datetime

data = np.loadtxt("eur_usd_20120101_20120301.txt")
dates = np.array([datetime.datetime.fromtimestamp(x) for x in data[:, 0]])
bids = data[:, 1]
asks = data[:, 2]
plt.figure()
plt.title("Time series of mid-price against true time")
plt.plot(dates, (asks + bids) / 2)
plt.gca().xaxis.set_major_locator(mdates.WeekdayLocator())
plt.gcf().autofmt_xdate()
plt.show()
# bins = np.arange(0, 24*60 * 60, 15 * 60)
# print(len(bins))
# def selection(dates: list, day_number: int = 0, week: bool = False) -> list:
#   first_day = dates[0].date() + datetime.timedelta(days=1)
#   if week:
#     return [d for d in dates if first_day <= d.date() < first_day +
# datetime.timedelta(days=7)]
#   return [d for d in dates if d.date() == first_day]
# plt.figure()
# plt.hist(selection(dates, day_number=1), bins=len(bins))
# plt.gca().xaxis.set_major_locator(mdates.HourLocator())
# plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
# plt.legend()
# plt.title("Test")
# plt.gcf().autofmt_xdate()
# plt.show()
```

#figure(image(".typst_pyexec/figures/cell_7_1.svg"), caption: [Time series of mid-price against true time])


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
