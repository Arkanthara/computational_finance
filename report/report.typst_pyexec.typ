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


// ─── First steps ────────────────────────────────────────────────────────────
= First steps

The goal of this series is to implement different execution strategies and to see the different prices we would have obtained on real data. In the following exercises, we consider a fictitious order to buy *12 million euros*.

We will again use the file `eur_usd_20120101_20120301.txt` (downloadable from Moodle, TP\_03) that contains data on the EUR/USD exchange rate from January 1st to March 1st 2012 and has the following data structure:

#block(
  fill: luma(235),
  inset: (x: 1em, y: 0.6em),
  radius: 4pt,
  width: 100%,
)[
  `timestamp   bid   ask`
]

Similarly to the previous TPs, load this file and remove the outliers (date in 1970).

Then, pick several random time-intervals from the data (at least twenty). We will use them in the following exercises.

```python
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import numpy as np
import datetime

np.random.seed(2026)

data = np.loadtxt("eur_usd_20120101_20120301.txt")
dates = np.array([datetime.datetime.fromtimestamp(x) for x in data[:, 0]])
# Remove outliers
mask = dates > datetime.datetime(2011, 11, 11)
dates = dates[mask]
bids = data[mask, 1]
asks = data[mask, 2]
mid_prices = (bids + asks) / 2
random_indices = np.random.choice(np.arange(len(dates)), size=20, replace=False)
```


// ─── Section 1 ──────────────────────────────────────────────────────────────
= TWAP algorithm

- For each of the twenty starting times you picked, simulate the execution of the aforementioned order with the *TWAP* algorithm, using 12 slices executed every 15 minutes.

  ```python
  def time_indexer(
      dates: np.ndarray, start_date: datetime.datetime, slice_interval: int = 15
  ) -> np.ndarray:
      results = np.arange(len(dates), dtype=int)
      mask = (dates >= start_date) & (
          dates < start_date + datetime.timedelta(minutes=slice_interval)
      )
      results = results[mask]
      return results
  
  
  def twap(
      dates: np.ndarray,
      mid_prices: np.ndarray,
      start_idx: int,
      num_slices: int = 12,
      slice_interval: int = 15,
  ) -> np.ndarray:
      prices = []
      for i in range(num_slices):
          idx = time_indexer(
              dates,
              dates[start_idx] + datetime.timedelta(minutes=i * slice_interval),
              slice_interval,
          )
          if len(idx) > 0:
              prices.append(np.mean(mid_prices[idx]))
      return np.array(prices)
  
  
  twap_prices = twap(dates, asks, random_indices[0])  # Example for the first random index
  
  dates_for_plot = [
      dates[random_indices[0]] + datetime.timedelta(minutes=i * 15) for i in range(12)
  ]
  idx_for_decision_price = time_indexer(
      dates, dates[random_indices[0]], slice_interval=12 * 15
  )
  
  plt.figure()
  plt.plot(dates_for_plot, twap_prices, label="TWAP Execution Prices")
  plt.gca().xaxis.set_major_locator(mdates.HourLocator())
  plt.gca().xaxis.set_minor_locator(mdates.MinuteLocator(interval=15))
  plt.gca().xaxis.set_major_formatter(mdates.DateFormatter("%y-%m-%d %H:%M"))
  plt.title("TWAP execution prices")
  plt.xlabel("Time")
  plt.ylabel("Price")
  plt.gcf().autofmt_xdate()
  plt.tight_layout()
  plt.legend()
  plt.show()
  ```
  
  #figure(image(".typst_pyexec/figures/cell_2_1.svg"), caption: [TWAP execution prices])
  

- Compute the execution prices you got and compare them to the decision prices ${"ask"}(t_i),\ forall i in {1, dots, 20}$.

  ```python
  # Printing the difference between TWAP execution prices and decision price for the first random index
  decision_price = asks[random_indices[0]]
  realized_prices = twap(dates, asks, random_indices[0])
  print(f"Overall price payed with decision price: {decision_price * 12e6:.2f}")
  print(f"Overall price payed with TWAP: {np.sum(realized_prices * 12e6 / 12):.2f}")
  print(
      f"Difference: {(np.sum(realized_prices * 12e6 / 12) - decision_price * 12e6):.2f}"
  )
  ```
  
  #raw("Overall price payed with decision price: 15877920.00\nOverall price payed with TWAP: 15858120.61\nDifference: -19799.39")
  

  We can see on the first random index that the TWAP execution price is lower than the decision price, allowing us to save around 20,000 euros on the execution of the order which is not negligible.

  If we plot the difference between the TWAP execution prices and decision prices for all the random indices as follows, we can see that the TWAP execution prices are generally lower than the decision prices since the bars are mostly negative.
  This is due to the TWAP algorithm that mitigates market impact by spreading the order over time, allowing to take advantage of price fluctuations and potentially obtain better prices than the initial decision price.
  However, some times, the TWAP execution price can be higher than the decision price due to the market behavior during the execution period.
  This is shown by the few positive bars in the plot.

  So the TWAP algorithm is quite effective, but can lead to worse execution prices depending on the market.

  Another problem with this algorithm is that some concurrent companies can study the order flow, predict the execution of the orders and take advantage of it, which can lead to worse execution prices for the TWAP algorithm.

  ```python
  differences = np.zeros(20)
  for i in range(20):
      twap_price = twap(dates, asks, random_indices[i]) * 12e6 / 12
      twap_price = np.sum(twap_price)
      decision_price = asks[random_indices[i]] * 12e6
      differences[i] = twap_price - decision_price
  plt.figure()
  plt.bar(range(20), differences, label="TWAP Execution Price - Decision Price")
  plt.title("TWAP Execution Prices vs Decision Prices")
  plt.xlabel("Random Index")
  plt.xticks(range(20), [f"Index {i}" for i in range(1, 21)], rotation=45)
  plt.ylabel("Price")
  plt.legend()
  plt.show()
  ```
  
  #figure(image(".typst_pyexec/figures/cell_4_1.svg"), caption: [TWAP Execution Prices vs Decision Prices])
  

// ─── Section 2 ──────────────────────────────────────────────────────────────
= VWAP algorithm

- Picking the same twenty starting times, simulate the execution of the aforementioned order with the *VWAP* algorithm, using 12 slices executed every 15 minutes. You can use the daily distribution of ticks as historical data to estimate volumes traded in each 15-minute interval.

  ```python
  def get_previous_day_volume_distribution(
      dates: np.ndarray, random_index: int, slice_interval: int = 15, num_slices: int = 12
  ) -> np.ndarray:
      volume_distribution = np.zeros(num_slices)
      start_time = dates[random_index] - datetime.timedelta(days=1)
      for i in range(num_slices):
          mask_slice = (
              dates >= start_time + datetime.timedelta(minutes=i * slice_interval)
          ) & (dates < start_time + datetime.timedelta(minutes=(i + 1) * slice_interval))
          volume_distribution[i] = np.sum(mask_slice)
      volume_distribution /= np.sum(volume_distribution)  # Normalize to get distribution
      return volume_distribution
  
  
  def vwap(
      dates: np.ndarray,
      prices: np.ndarray,
      random_index: int,
      num_slices: int = 12,
      slice_interval: int = 15,
  ) -> tuple[np.ndarray, np.ndarray]:
      volume_distribution = get_previous_day_volume_distribution(
          dates, random_index, slice_interval, num_slices
      )
      slice_volumes = volume_distribution
      execution_prices = twap(
          dates, prices, random_index, num_slices, slice_interval
      )  # Get TWAP prices for the slices
      return execution_prices, slice_volumes
  ```
  

- Compute the execution prices you got and compare them to the decision prices and the TWAP prices.

  // ```python
  // vwap_prices, vwap_volumes = vwap(dates, asks, random_indices[0])
  // twap_prices = twap(dates, asks, random_indices[0]) * 12e6 / 12
  // decision_price = asks[random_indices[0]] * 12e6

  // print(f"Overall price payed with decision price: {decision_price:.2f}")
  // print(f"Overall price payed with TWAP: {np.sum(twap_prices):.2f}")
  // print(f"Overall price payed with VWAP: {np.sum(vwap_prices * vwap_volumes * 12e6):.2f}")
  // print(f"Difference between VWAP and decision price: {(np.sum(vwap_prices * vwap_volumes * 12e6) - decision_price):.2f}")
  // print(f"Difference between TWAP and decision price: {(np.sum(twap_prices) - decision_price):.2f}")
  // ```

  The VWAP execution price follows a similar pattern to the TWAP algorithm, but it takes into account the activity in the market by weighting the execution prices according to the volume distribution of previous days.
  In this way, the VWAP algorithm is less predictable than the TWAP algorithm for a concurrent company, which can lead to better execution prices.

  If we look at the difference between VWAP and TWAP execution prices, we can see that the TWAP execution tends to be better than the VWAP execution by having more negative bars.

  However, the VWAP execution can be better in case of unfavorable market conditions during execution period since when the bars are positive, the VWAP execution price is better than the TWAP execution price.


  ```python
  differences_vwap = np.zeros(20)
  differences_twap = np.zeros(20)
  for i in range(20):
      vwap_prices, vwap_volumes = vwap(dates, asks, random_indices[i])
      twap_prices = twap(dates, asks, random_indices[i]) * 12e6 / 12
      vwap_volumes *= 12e6  # Scale volumes to the total order size
      vwap_execution_price = np.sum(vwap_prices * vwap_volumes)
      twap_execution_price = np.sum(twap_prices)
      decision_price = asks[random_indices[i]] * 12e6
      differences_vwap[i] = vwap_execution_price - decision_price
      differences_twap[i] = twap_execution_price - decision_price
  
  plt.figure()
  plt.bar(range(20), differences_vwap, label="VWAP Difference")
  plt.bar(range(20), differences_twap, label="TWAP Difference", alpha=0.7)
  plt.title("Execution Prices vs Decision Prices")
  plt.xlabel("Random Index")
  plt.xticks(range(20), [f"Index {i}" for i in range(1, 21)], rotation=45)
  plt.ylabel("Price")
  plt.legend()
  plt.show()
  ```
  
  #figure(image(".typst_pyexec/figures/cell_6_1.svg"), caption: [Execution Prices vs Decision Prices])
  

// ─── Section 3 ──────────────────────────────────────────────────────────────
= Algorithm based on price evolution

Finally, implement an execution algorithm that takes into account the price evolution. For instance, you can split the order into 12 equal slices and trade a slice at each downward directional change $delta$.

- Picking again the same initial times, compute the execution prices you got with this method and compare them with the ones previously obtained.

- How should you choose $delta$ to execute the full order over 3 hours?

// ─── Section 4 ──────────────────────────────────────────────────────────────
= Impact of Market Volatility

In this task, you will analyze how market volatility affects the execution prices obtained using different execution strategies (TWAP, VWAP, and the price-evolution-based method).

*1. Compute Market Volatility:*

- Define volatility as the standard deviation of mid-price returns over a rolling window of 30 minutes.
- Compute this measure for the selected 20 time intervals.

*2. Analyze Execution Performance Under Different Volatility Conditions:*

- Divide the 20 intervals into two groups:
  - *Low-volatility periods:* Where the rolling standard deviation is in the bottom 50% of the dataset.
  - *High-volatility periods:* Where the rolling standard deviation is in the top 50%.

- Compute and compare the execution prices obtained using TWAP, VWAP, and price-evolution strategies across both groups. Which strategy performs best in volatile markets?

- Is there a strategy that minimizes execution price deviation across all market conditions?
