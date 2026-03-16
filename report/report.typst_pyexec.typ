
#show figure.where(kind: "subfigure"): set figure(supplement: "Figure")

#show figure.where(kind: image): outer => {
  counter(figure.where(kind: "subfigure")).update(0)
  set figure(numbering: (..nums) => {
    let outer-nums = counter(figure.where(kind: image)).at(outer.location())
    std.numbering("1a", ..outer-nums, ..nums)
  })
  show figure.where(kind: "subfigure"): inner => {
    show figure.caption: it => context {
      std.numbering("(a)", it.counter.at(inner.location()).last())
      [ ]
      it.body
    }
    inner
  }
  outer
}
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


= Seasonality

The file #raw("eur_usd_20120101_20120301.txt") (download it on Moodle) contains data on the EUR / USD exchange rate for the period of January 1st to March 1st 2012, with the following data structure:

#v(0.3em)
#align(center)[#raw("timestamp   bid   ask")]
#v(0.3em)

Where #emph[timestamp] denotes the time (in seconds) measured starting from 01 Jan 1970 00:00:00.

Considering bins of 15 minutes, plot the two histograms of the daily and weekly distributions of ticks. Comment on the obtained histograms.

```python
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import numpy as np
import datetime

data = np.loadtxt('eur_usd_20120101_20120301.txt')
dates = np.array([datetime.datetime.fromtimestamp(x) for x in data[:, 0]])
bins = np.arange(0, 24*60, 15)
week_bins = np.arange(0, 7*24*60, 15)

def selection(dates: list, day_number: int = 1, week: bool = False) -> list:
  first_day = dates[0].date() + datetime.timedelta(days=1)
  if week:
    return [d for d in dates if first_day <= d.date() < first_day + datetime.timedelta(days=7)]
  return [d for d in dates if d.date() == first_day]

plt.figure()
plt.hist(selection(dates, day_number=1), bins=len(bins))
plt.gca().xaxis.set_major_locator(mdates.HourLocator())
plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
plt.title("Daily distribution of ticks")
plt.gcf().autofmt_xdate()
plt.tight_layout()
plt.show()
```

#figure(image(".typst_pyexec/figures/cell_1_1.svg"), caption: [Daily distribution of ticks])


```python
plt.figure()
plt.hist(selection(dates, day_number=1, week=True), bins=len(week_bins))
plt.gca().xaxis.set_major_locator(mdates.DayLocator())
plt.gca().xaxis.set_minor_locator(mdates.HourLocator())
plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%d %b'))
plt.title("Weekly distribution of ticks")
plt.gcf().autofmt_xdate()
plt.tight_layout()
plt.show()
```

#figure(image(".typst_pyexec/figures/cell_2_1.svg"), caption: [Weekly distribution of ticks])


// time=data[:, 0] % (3600*24)
//
// bins = np.arange(0,24*60*60 +15*60, 15*60)
//
// plt.xticks(ticks=bins[::4]), labels=[…]])
//
// labels=[datetime.fromtimestamp(x, timezone.utc).strgtime(‘%Hh’) for x in bins[::4]]

#v(1em)

// Section 2
= AR(1) process

For different values of $phi_1$, simulate and plot an AR(1) process: $X_t = phi_1 X_(t-1) + epsilon_t$ with $X_0 = 0$ and $epsilon_t ~ cal(N)(0, 1)$.

```python
def AR(phi: float = 0.1, X_0: float = 0, size: int = 1000) -> np.ndarray:
  X_t = [X_0]
  for i in range(size):
    X_t.append(X_t[-1] * phi + np.random.normal(loc=0, scale=1))
  return np.array(X_t)
```


#show figure.where(
  kind: "subfigure",
): set figure.caption(position: top)

```python
plt.figure()
plt.suptitle("Test on values of $\\phi_1$")
index = 1
for i, j in zip([0.1, 0.5, 0.9, 1], ["Stationary process\n", "Mean-reverting process\n", "Trendy process\n", "Exploding process\n"]):
  plt.subplot(2, 2, index)
  plt.plot(AR(i))
  plt.title(j + f"$\\phi_1 = {i}$")
  plt.xlabel("Time")
  plt.ylabel("$X_t$")
  index += 1
plt.show()
```

#figure(grid(columns: 2, align: bottom, [#figure(image(".typst_pyexec/figures/cell_4_1_1.svg"), kind: "subfigure", caption: [Stationary process #linebreak() $phi_1 = 0.1$])], [#figure(image(".typst_pyexec/figures/cell_4_1_2.svg"), kind: "subfigure", caption: [Mean-reverting process #linebreak() $phi_1 = 0.5$])], [#figure(image(".typst_pyexec/figures/cell_4_1_3.svg"), kind: "subfigure", caption: [Trendy process #linebreak() $phi_1 = 0.9$])], [#figure(image(".typst_pyexec/figures/cell_4_1_4.svg"), kind: "subfigure", caption: [Exploding process #linebreak() $phi_1 = 1$])]), caption: [Test on values of $phi_1$], kind: image)


In particular, how do you obtain:

- A stationary process?
- A mean-reverting process?
- A trendy process?
- An exploding process?

#v(1em)

// Section 3
= Mean-Reversion in Finance: The discrete Vasicek model

In the previous exercise, you explored the theoretical properties of the AR(1) process.

In quantitative finance, while stock log-prices $p_t$ (where $p_t = ln(S_t)$ and $S_t$ is the stock price) are often modeled as random walks (a non-stationary AR(1) process with $phi_1 = 1$), interest rates are structurally different: they typically cannot grow indefinitely but instead fluctuate around a long-term macroeconomic equilibrium rate.

One of the foundational models capturing this phenomenon is the Vasicek model for the short-term interest rate. In its discrete-time formulation, the interest rate $r_t$ evolves according to:

#v(0.3em)

$ r_t - r_(t-1) = kappa (theta - r_(t-1)) + sigma epsilon_t $

#v(0.3em)

where $epsilon_t ~ cal(N)(0, 1)$, $kappa$ represents the speed of mean reversion, $theta$ is the long-term average level, and $sigma$ is the volatility of the rate.

Answer the following questions:

#v(0.5em)
*1. Autoregressive Representation:* Show that the discrete Vasicek model can be algebraically rewritten as a classical AR(1) process with drift, of the form $r_t = c + phi_1 r_(t-1) + sigma epsilon_t$.
Explicitly identify the constants $c$ and $phi_1$ in terms of the initial Vasicek parameters $kappa$ and $theta$.

We want to find $phi_1$ and $c$ such as:

#align(
  left,
  $
    r_t = r_(t-1) + kappa (theta - r_(t-1)) + sigma epsilon_t & = c + phi_1 r_(t-1) + sigma epsilon_t \
                   <==> r_(t-1) + kappa theta - kappa r_(t-1) & = c + phi_1 r_(t-1) \
                       <==> kappa theta + (1 - kappa) r_(t-1) & = c + phi_1 r_(t-1) \
  $,
)

So $phi_1 = (1 - kappa)$ and $c = kappa theta$.

#v(0.5em)
*2. Mean-Reversion Condition:* Based on your findings from the previous AR(1) exercise (specifically, the mean-reverting process case), what strict mathematical boundaries must the speed of mean reversion $kappa$ satisfy for the interest rate process $r_t$ to be weakly stationary? What are the financial reality and the dynamics of $r_t$ if $kappa = 0$?

To have a mean-reverting process, the condition was found that $abs(phi_1) < 1$.

As $phi_1 = (1 - kappa)$, it means that $0 < kappa < 2$.

In this way, $r_t$ will always return to $0$ value, meaning that $r_t$ will oscillate around the mean $0$ and be weakly stationary.#report-footnote("A weakly stationary process has a constant mean and variance")

If $kappa = 0$, $phi_1 = 1$ meaning that the process $r_t$ follows a random walk, disabling by the way all good predictions.

#v(0.5em)
*3. Long-term Equilibrium:* Assuming the stationarity condition holds, rigorously compute the unconditional expectation $E[r_t]$ and the unconditional variance $"Var"(r_t)$ as $t -> infinity$. Discuss how the parameter $theta$ dictates the long-term properties of the interest rates model.

As the stationarity condition holds, it means that $EE[r_t] = EE[r_(t - 1)]$ and $"Var"(r_t) = "Var"(r_(t-1))$.

So we have:

#let Var = math.op("Var")

#align(left, $
               EE[r_t] &= EE[(1 - kappa) r_(t - 1) + kappa theta] \
               &= (1 - kappa)EE [r_(t - 1)] + EE[kappa theta] \
               &= (1 - kappa)EE [r_t] + kappa theta \
               <==> 0 &= (1 - kappa)EE [r_t] + kappa theta - EE[r_t] \
               <==> - kappa theta &= - kappa EE [r_t] \
               <==> theta &= EE[r_t] \
             $)
and:

#align(left, $
               Var(r_t) &= Var((1 - kappa) r_(t - 1) + kappa theta) \
               &= (1 - kappa)^2 Var(r_(t - 1)) \
               &= (1 - kappa)^2 Var(r_t) \
               <==> 0 &= (1 - kappa)^2 Var(r_t) - Var(r_t) \
               <==> 0 &= kappa^2 Var(r_t) - 2kappa Var(r_t) \
               <==> 0 &= (kappa^2 -2kappa) Var(r_t) \
               <==> 0 &= Var(r_t) \
             $)

#v(0.5em)
*4. Simulation and Visualization:* Simulate a single path of the discrete Vasicek model over $T = 300$ time steps using the following parameters: $r_0 = 0.05$, $kappa = 0.1$, $theta = 0.05$, and $sigma = 0.01$. Plot the simulated interest rate $r_t$ against time $t$, and overlay a horizontal line representing the long-term equilibrium rate $theta$. Comment on the observed dynamics, contrasting them with a classic random walk.

```python
def Vasicek(T: int = 300, r_0: float = 0.05, kappa: float = 0.1, theta: float = 0.05, sigma: float = 0.01) -> np.ndarray:
  r_t = [r_0]
  for i in range(T-1):
    r_t.append(kappa * (theta - r_t[-1]) + sigma * np.random.normal(loc=0, scale=1) + r_t[-1] )
  return np.array(r_t)

T = 300
theta = 0.05

plt.figure()
plt.title("Simulation of a single path of discrete Vasicek model")
plt.plot(np.arange(T), Vasicek(T=T, theta=theta), label="Vasicek model")
plt.plot(np.arange(T), np.ones(T) * theta, label="Long-term equilibrium rate")
plt.xlabel("Time")
plt.ylabel("Interest rate")
plt.legend()
plt.show()
```

#figure(image(".typst_pyexec/figures/cell_5_1.svg"), caption: [Simulation of a single path of discrete Vasicek model])

Compared to a random walk, we can observe that in the Vasicek model a growth is always followed by a decline, making the model oscillating around the long-term equilibrium baseline.

This is not the case in a random walk, since it can go far away from the long-term equilibrium without joining it again.

// Section 4
= Vocabulary

*1.* Describe what are bonds and stocks and the difference between them.

#v(0.3em)
*2.* What is an option? A future?

#v(0.3em)
*3.* What is an index? What are the typical methods to weight the items of an index? For instance, what method is used by Nasdaq and S&P 500?
