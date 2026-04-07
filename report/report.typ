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

// ─── Section 1 ──────────────────────────────────────────────────────────────
= TWAP algorithm

- For each of the twenty starting times you picked, simulate the execution of the aforementioned order with the *TWAP* algorithm, using 12 slices executed every 15 minutes.

- Compute the execution prices you got and compare them to the decision prices ${"ask"}(t_i),\ forall i in {1, dots, 20}$.

// ─── Section 2 ──────────────────────────────────────────────────────────────
= VWAP algorithm

- Picking the same twenty starting times, simulate the execution of the aforementioned order with the *VWAP* algorithm, using 12 slices executed every 15 minutes. You can use the daily distribution of ticks as historical data to estimate volumes traded in each 15-minute interval.

- Compute the execution prices you got and compare them to the decision prices and the TWAP prices.

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
