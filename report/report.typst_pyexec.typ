
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


= Limit Order Book — Maslov model

The goal of this series is to implement the Maslov model (check the paper for more details), which allows to reproduce interesting stylized facts while being relatively simple.

We consider the following version of the model:

- One trader at each time step.
- Buyer or seller, with probability $1 - q$ and $q$.
- Issues a market order (buy at ask / sell at bid) with probability $1 - r$ or a limit order with probability $r$. The price for the limit order is defined as $p - K$ when buying and $p + K$ when selling, with $p$ the market price, defined as the last price said in the market. $K$ is a positive random variable.
- Each trader buys or sells a quantity of one.
- An order cannot be canceled.
- If an order cannot be executed (e.g. a sell market order but there is no buy order in the LOB), then nothing happens at this time step.

+ Implement the procedure above and unroll it for 1000 iterations. Use $q = r = 0.5$ and $K = 1$ with probability 1. Plot the time series of the market, ask, bid and mid prices $p(t)$, $a(t)$, $b(t)$ and $m(t) = (b(t) + a(t)) / 2$. Are there any difference between the mid and the market prices?
  ```python
  import numpy as np
  import matplotlib.pyplot as plt
  
  np.random.seed(2026)
  
  
  def Maslov(iterations: int = 1000, q: float = 0.5, r: float = 0.5, K: float = 1):
      # Initial price
      p = [100.0]
      orders = []
      sells = []
      best_asks = []
      best_bids = []
      for i in range(iterations):
          # Buy process
          if np.random.rand() <= 1 - q:
              # Buyer
              if np.random.rand() <= 1 - r:
                  if sells:
                      sells.sort()
                      p.append(sells.pop())
              # Market maker
              else:
                  orders.append(p[-1] - K)
                  p.append(p[-1])
          # Sell process
          else:
              # Seller
              if np.random.rand() <= 1 - r:
                  if orders:
                      orders.sort(reverse=True)
                      p.append(orders.pop())
              # Market maker
              else:
                  sells.append(p[-1] + K)
                  p.append(p[-1])
          if sells:
              best_asks.append(np.min(sells))
          else:
              best_asks.append(np.nan)
          if orders:
              best_bids.append(np.max(orders))
          else:
              best_bids.append(np.nan)
      p = np.array(p)
      best_asks = np.array(best_asks)
      best_bids = np.array(best_bids)
      mid_price = (best_asks + best_bids) / 2
      spread = best_asks - best_bids
      return p, best_asks, best_bids, mid_price, spread
  
  
  p, a, b, mid_price, spread = Maslov()
  
  plt.figure()
  plt.plot(p, label="Price of the market")
  plt.plot(a, label="Asks")
  plt.plot(b, label="Bids")
  plt.plot(mid_price, label="Mid-price")
  plt.xlabel("Time")
  plt.ylabel("Price")
  plt.legend()
  plt.show()
  ```
  
  #image(".typst_pyexec/figures/cell_1_1.svg")
  

+ Plot the time series of returns of the market price, what do you observe?

  ```python
  def returns(ts: np.ndarray, N: int = 1) -> np.ndarray:
      result = ts.copy()
      result[:N] = np.nan
      return (result[N:] - result[:-N]) / result[:-N]
  
  
  plt.figure()
  plt.plot(returns(p))
  plt.title("Time series of returns of the market price")
  plt.xlabel("Time")
  plt.ylabel("Returns")
  plt.show()
  ```
  
  #figure(image(".typst_pyexec/figures/cell_2_1.svg"), caption: [Time series of returns of the market price])
  

+ Plot the histogram of the values of this series. What can you say of this distribution? Is it a normal distribution?

  ```python
  plt.figure()
  plt.hist(returns(p), bins=25)
  plt.title("Histogram of Returns")
  plt.xlabel("Returns")
  plt.ylabel("Frequency")
  plt.show()
  ```
  
  #figure(image(".typst_pyexec/figures/cell_3_1.svg"), caption: [Histogram of Returns])
  

+ Plot and comment the ACF graph of this series.

  ```python
  from statsmodels.graphics.tsaplots import plot_acf
  
  plt.figure()
  plot_acf(returns(p), lags=50)
  plt.title("ACF of Returns")
  plt.xlabel("Lags")
  plt.ylabel("Autocorrelation")
  plt.show()
  ```
  
  #figure(grid(columns: 1, [#figure(image(".typst_pyexec/figures/cell_4_1.svg"), kind: "subfigure")], [#figure(image(".typst_pyexec/figures/cell_4_2.svg"), kind: "subfigure", caption: [ACF of Returns])]), caption: [ACF of Returns], kind: image)
  

+ Compute the bid–ask spread $s(t) = a(t) - b(t)$ and plot its time series.

+ Plot a histogram of the spread values. Comment on whether the distribution is fat-tailed.

+ For selected time points, analyze the order book depth: for a range of price levels relative to the best bid/ask, compute the aggregated number of orders.

+ Plot the depth distribution and discuss its shape in relation to empirical observations.

+ Change the parameters of the model to understand how they influence the market and comment about this point.

#pagebreak()

// Part 2
= Heterogeneous Order Sizes and Trader Behavior on LOB Dynamics

Finally, you will extend the basic Maslov model to include heterogeneity in order sizes and trader behavior. You will investigate how these extensions influence the market price dynamics, volatility, and autocorrelation structure of returns.

We now consider the following version of the model:

- Instead of assuming every order has unit size, assume that order sizes are drawn from a distribution (for example, a discrete uniform distribution between 1 and 5).
- Introduce two types of traders:
  - *Aggressive Traders:* With a higher probability (e.g., 0.8) they submit market orders.
  - *Passive Traders:* With a higher probability (e.g., 0.8) they submit limit orders.
- Let each trader, at each time step, be randomly classified as aggressive or passive.

#v(0.5em)

+ Run the simulation for 1000 iterations with the extended model.

+ Record the time series of the market price and compute the returns.

+ Plot the histogram of returns and calculate basic statistics (mean, variance).

+ Compute and plot the autocorrelation function (ACF) of the return series.

+ Discuss how the introduction of heterogeneous order sizes and trader behavior affects the price dynamics compared to the baseline model. Comment on any observed changes in volatility clustering or the fat-tailed nature of the return distribution.
