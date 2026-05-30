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

= Futures valuation

We consider a non-dividend-paying stock $X$ that is valued at $S_0 = 100$ today, and the risk-free rate per year is $r = 0.1$. Furthermore, we assume the price $S_t$ of $X$ to evolve along two scenarios as follows:

#align(center, table(
  columns: (auto, auto, auto),
  align: center,
  [$t$ (month)], [Price Scenario 1], [Price Scenario 2],
  [0], [100], [100],
  [2], [105], [99],
  [4], [104], [101],
  [6], [108], [98],
  [8], [113], [97],
  [10], [109], [99],
  [12], [112], [97],
))

We consider a future with maturity $T = 12$ months.

+ Compute the future value $F_t$ at each date for both scenarios as time passes by.

  ```python
  import numpy as np
  # Given data
  S0 = 100
  r = 0.1
  T = 1  # in years
  # Time points in years
  t = np.array([0, 2, 4, 6, 8, 10, 12]) / 12
  # Stock price scenarios
  S_scenario_1 = np.array([100, 105, 104, 108, 113, 109, 112])
  S_scenario_2 = np.array([100, 99, 101, 98, 97, 99, 97])
  # Compute futures prices
  F_scenario_1 = S_scenario_1 * np.exp(r * (T - t))
  F_scenario_2 = S_scenario_2 * np.exp(r * (T - t))
  ```

+ Plot the evolution of $S_t$ and $F_t$ on the same graph.

  ```python
  import matplotlib.pyplot as plt
  # Plotting
  plt.figure(figsize=(10, 6))
  plt.plot(t * 12, S_scenario_1, label='Stock Price Scenario 1', marker='o')
  plt.plot(t * 12, F_scenario_1, label='Futures Price Scenario 1', marker='x')
  plt.plot(t * 12, S_scenario_2, label='Stock Price Scenario 2', marker='o')
  plt.plot(t * 12, F_scenario_2, label='Futures Price Scenario 2', marker='x')
  plt.title('Stock Price and Futures Price Evolution')
  plt.xlabel('Time (months)')
  plt.ylabel('Price')
  plt.legend()
  plt.grid()
  plt.show()
  ```
+ What can you say about the way $F_t$ converges towards $S_T$?

  We can see that the futures price $F_t$ converges towards the stock price at maturity $S_T$ as time approaches maturity.
  We can also observe that the futures price is generally above the stock price.
  Indeed, the futures price includes the cost of carry, which is the cost of holding the underlying asset until maturity, and this cost is positive due to the positive risk-free rate. Therefore, $F_t$ is greater than $S_t$ for all $t < T$, and they converge at maturity when $F_T = S_T$.


#pagebreak()
= Mark-to-Market P/L of a Futures Position

In this exercise, you will track the monthly profit and loss of a long futures position, marked to market at each observation date, and see how variation margin accumulates over time.

+ *Futures Prices:* You already computed $F_t = S_t exp(r(T - t))$ at each monthly date $t$ for both scenarios in Exercise #1.

+ *Mark-to-Market P/L:*
  - Assume you enter a long futures contract at $t_0 = 0$ at price $F_0$.
  - At each subsequent date $t_i$, your variation margin (PnL) is 
    $
    Delta P_i = F_(t_i) - F_(t_(i-1)).
    $
  - Compute $Delta P_i$ for $i = 1, 2, ..., 6$ (every 2 months), and the cumulative P/L $"CumPL"_i = sum_(j=1)^i Delta P_j$.

    ```python
    # Compute Mark-to-Market P/L
    # For Scenario 1
    Delta_P_scenario_1 = np.diff(F_scenario_1)
    CumPL_scenario_1 = np.cumsum(Delta_P_scenario_1)
    # For Scenario 2
    Delta_P_scenario_2 = np.diff(F_scenario_2)
    CumPL_scenario_2 = np.cumsum(Delta_P_scenario_2)
    ```

+ *Plotting & Discussion:*
  - On one chart, plot the two scenarios of cumulative P/L versus $t$.

    ```python
    # Plotting Cumulative P/L
    plt.figure(figsize=(10, 6))
    plt.plot(t[1:] * 12, CumPL_scenario_1, label='Cumulative P/L Scenario 1', marker='o')
    plt.plot(t[1:] * 12, CumPL_scenario_2, label='Cumulative P/L Scenario 2', marker='o')
    plt.title('Cumulative P/L of Long Futures Position')
    plt.xlabel('Time (months)')
    plt.ylabel('Cumulative P/L')
    plt.legend()
    plt.grid()
    plt.show()
    ```
  - On a second chart, overlay $Delta P_i$ (bar chart) for each scenario.
    ```python
    # Plotting Delta P
    plt.figure(figsize=(10, 6))
    width = 0.35
    plt.bar(t[1:] * 12 - width/2, Delta_P_scenario_1, width=width, label='Delta P Scenario 1')
    plt.bar(t[1:] * 12 + width/2, Delta_P_scenario_2, width=width, label='Delta P Scenario 2')
    plt.title('Monthly Variation Margin (Delta P)')
    plt.xlabel('Time (months)')
    plt.ylabel('Delta P')
    plt.legend()
    plt.grid()
    plt.show()
    ```
  - Comment on the variability of monthly variation margins under each scenario.

    In fact, instead of waiting until maturity to realize the final benefit or loss of the futures position, the mark-to-market mechanism allows us to track the P/L on a monthly basis. We can see that the variation margin (Delta P) fluctuates over time, reflecting the changes in the futures price. The cumulative P/L shows how the overall profit or loss evolves as we approach maturity.
    In case of the first scenario, the cumulative P/L is positive, meaning that the user is in a profitable position, while in the second scenario, the cumulative P/L is negative, indicating a loss.

    The variation of the first scenario is generally positive, indicating that the futures price is increasing over time, while the second scenario shows more variability with more negative variation margins, reflecting a decrease in the futures price.
    The variation of the first scenario seems to be more volatile, since the futures price has more significant changes, while the second scenario has smaller variations in the futures price, leading to less volatile variation margins.
