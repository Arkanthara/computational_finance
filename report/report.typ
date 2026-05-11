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

= The Greeks

Let an asset $S$ with initial value $S_0$ at $t = 0$. We consider both a European option to buy this asset (call) and to sell it (put), both with maturity $T = 1$ (in years) and strike price $K = 120$. We assume a constant volatility $sigma = 20%$ over their lifespan, and a risk-free rate $r = 5%$.

== Plotting the Greeks

Using the Black-Scholes formula to evaluate the call and the put price as a function of the initial asset price $S_0$, plot the evolution of:

- the price of the call/put;
- the $Delta$ of the call/put;
- the $Gamma$ of the call/put.

Comment on the meaning of these graphs.

```python
%| grid-inset: 6pt
%| label: fig1
import numpy as np
from scipy.stats import norm
import matplotlib.pyplot as plt

def black_scholes_and_greeks(
    S0: float, K: float, T: float, r: float, sigma: float, call: bool = True
) -> float:
    """
    Price a European option using the Black-Scholes formula.

    Parameters:
    S0: float
      Initial stock price
    K: float
      Strike price
    T: float
      Time to maturity (in years)
    r: float
      Risk-free interest rate
    sigma: float
      Volatility of the underlying asset
    call: bool
      Whether the option is a call (True) or a put (False)

    Returns:
    float: Estimated option price
    """
    d1 = (np.log(S0 / K) + (r + 0.5 * sigma**2) * T) / (sigma * np.sqrt(T))
    d2 = d1 - sigma * np.sqrt(T)
    if call:
        delta = norm.cdf(d1)
        gamma = norm.pdf(d1) / (S0 * sigma * np.sqrt(T))
        option_price = S0 * norm.cdf(d1) - K * np.exp(-r * T) * norm.cdf(d2)
    else:
        delta = norm.cdf(d1) - 1
        gamma = norm.pdf(d1) / (S0 * sigma * np.sqrt(T))
        option_price = K * np.exp(-r * T) * norm.cdf(-d2) - S0 * norm.cdf(-d1)

    return option_price, delta, gamma

K = 120
T = 1
r = 0.05
sigma = 0.20

S_values = np.arange(80, 160)

plt.figure(figsize=(10, 10))
plt.subplot(3, 1, 1)
plt.plot(S_values, [black_scholes_and_greeks(S, K, T, r, sigma, call=True)[0] for S in S_values], label="Call Price")
plt.plot(S_values, [black_scholes_and_greeks(S, K, T, r, sigma, call=False)[0] for S in S_values], label="Put Price")
plt.xlabel("Initial asset price $S_0$")
plt.ylabel("Price")
plt.title("Prices as a function of initial asset price")
plt.legend()
plt.subplot(3, 1, 2)
plt.plot(S_values, [black_scholes_and_greeks(S, K, T, r, sigma, call=True)[1] for S in S_values], label="Call Delta")
plt.plot(S_values, [black_scholes_and_greeks(S, K, T, r, sigma, call=False)[1] for S in S_values], label="Put Delta")
plt.xlabel("Initial asset price $S_0$")
plt.ylabel("Delta")
plt.title("$Delta$ as a function of initial asset price")
plt.legend()
plt.subplot(3, 1, 3)
plt.plot(S_values, [black_scholes_and_greeks(S, K, T, r, sigma, call=True)[2] for S in S_values], label="Call Gamma")
plt.plot(S_values, [black_scholes_and_greeks(S, K, T, r, sigma, call=False)[2] for S in S_values], label="Put Gamma")
plt.xlabel("Initial asset price $S_0$")
plt.ylabel("Gamma")
plt.title("$Gamma$ as a function of initial asset price")
plt.legend()
plt.tight_layout()
plt.show()
```

The @fig1-a shows the evolution of the call and put price of the asset as a function of the initial asset price.

The @fig1-b shows the rate of change of the option price with respect to the initial asset price.
We can see that the $Delta_c$ (Call Delta) is positive whereas the $Delta_p$ (Put Delta) is negative.
This is because the call option gives the right to buy the asset at a fixed price, so its value increases as the asset price increases, while the put option gives the right to sell the asset at a fixed price, so its value decreases as the asset price increases.

The @fig1-c shows the rate of change of the $Delta$ of the option price with respect to the initial asset price.
We can see that the $Gamma$ of both the call and the put option is the same and is positive, which means that the $Delta$ of both options increases as the asset price increases.

== Hedging a short call

Suppose the asset price is $S_0 = 100$, and we sell 1000 calls.

- Which position should we have to be $Delta$-neutral?
  
  To be $Delta$-neutral means that the total $Delta$ of our position should be zero. Since we sell 1000 calls, we have a negative $Delta$ from the calls. To offset this, we need to buy a certain quantity of the underlying asset to have a positive $Delta$ that cancels out the negative $Delta$ from the calls.

  Indeed, for $S_0 = 100$:
  ```python
  Delta_c = black_scholes_and_greeks(100, K, T, r, sigma, call=True)[1]
  print(f"Delta of the call option: {Delta_c}")
  ```
  So to be $Delta$-neutral, we need to buy a total of $1000 times Delta_c = 287$ shares.

- What is the profit of this strategy, supposing that $S_(0+epsilon) = 105$? $S_(0+epsilon) = 95$?

  Suppose we sell 1000 calls at the initial price, and we buy 287 shares of the underlying asset to be $Delta$-neutral.
  The profit of this strategy at $S_(0+epsilon) = 105$ would be:
  - The profit from selling the calls: $-1000 times (105 - 100) dot 0.287 = -1435$
  - The profit from buying the shares: $287 times (105 - 100) = 1435$
  So the total profit would be $-1435 + 1435 = 0$.

  At $S_(0+epsilon) = 95$:
  - The profit from selling the calls: $-1000 times (95 - 100) dot 0.287 = 1435$
  - The profit from buying the shares: $287 times (95 - 100) = -1435$
  So the total profit would be $1435 - 1435 = 0$.

  So in both cases, the profit of this strategy is zero, which means that it is a perfect hedge against small changes in the asset price.

- In the two previous cases, compare the quality of this hedging strategy with having a fully naked (no position) or a fully covered option (buying a quantity of 1000 of the underlying asset).

  In both $S_(0+epsilon) = 105$ and $S_(0+epsilon) = 95$, the option will not be exercised since $S_(0+epsilon) < K = 120$.

  If we had a fully naked option, as the option will not be exercised, the profit would be the prime from selling the calls.
  However, if the asset price increases significantly, the buyer will exercise the option, and we will have a large loss since we do not have any position in the underlying asset to offset this loss. So the naked position is very risky.

  If we had a fully covered option, we would buy a quantity of 1000 of the underlying asset, so at $S_(0+epsilon) = 105$, the profit would be $1000 times (105 - 100) = 5000$ plus the prime since the assets have taken some value, and at $S_(0+epsilon) = 95$, the profit would be $1000 times (95 - 100) = -5000$ plus the prime since the assets have lost some value. 
  Then, if the asset price increases significantly, the buyer will exercise the option and we will loose nothing since we have the underlying asset to offset this loss. However, if the asset price decreases significantly, we will have a large loss compensated by the prime since we have bought a large quantity of the underlying asset. So the covered position is very expensive, but allows to avoid the risk of infinite losses.

  In contrast, the $Delta$-neutral strategy provides a perfect hedge against small changes in the asset price, resulting in a profit of zero in both cases.

== Hedging a short put

Suppose the asset price is $S_0 = 100$, and we sell 1000 puts.

- Which position should we have to be $Delta$-neutral?

  To be $Delta$-neutral, we need to offset the negative $Delta$ from selling the puts by buying a certain quantity of the underlying asset. Since the $Delta$ of a put option is negative, we need to buy a positive quantity of the underlying asset to have a positive $Delta$ that cancels out the negative $Delta$ from the puts.

  For $S_0 = 100$:
  ```python
  Delta_p = black_scholes_and_greeks(100, K, T, r, sigma, call=False)[1]
  print(f"Delta of the put option: {Delta_p}")
  ```
  So to be $Delta$-neutral, we need to sell a total of $1000 times |Delta_p| = 712$ shares.

- What is the profit of this strategy, supposing that $S_(0+epsilon) = 105$? $S_(0+epsilon) = 95$?

  Suppose we sell 1000 puts at the initial price, and we sell 712 shares of the underlying asset to be $Delta$-neutral.
  The profit of this strategy at $S_(0+epsilon) = 105$ would be:
  - The profit from selling the puts: $-1000 times (105 - 100) dot (-0.712) = 3560$
  - The profit from selling the shares: $-712 times (105 - 100) = -3560$
  So the total profit would be $3560 - 3560 = 0$.

  At $S_(0+epsilon) = 95$:
  - The profit from selling the puts: $-1000 times (95 - 100) dot (-0.712) = -3560$
  - The profit from selling the shares: $-712 times (95 - 100) = 3560$
  So the total profit would be $-3560 + 3560 = 0$.

- In the two previous cases, compare the quality of this hedging strategy with having a fully naked or a fully covered option.

  In both $S_(0+epsilon) = 105$ and $S_(0+epsilon) = 95$, the option will not be exercised since $S_(0+epsilon) < K = 120$.

  If we had a fully naked option, as the option will not be exercised, the profit would be the prime from selling the puts.
  If the strike price is reached, the buyer will exercise the option, and we will have a large loss since we will have to buy the underlying asset at a higher price.

  If we had a fully covered option, we would sell a quantity of 1000 of the underlying asset, so we will have the profit of the prime and the profit from selling the shares. Then, if the asset price reaches the strike price, the buyer will exercise the option and we will have a large loss since we will have to buy the underlying asset at a higher price, but this loss will be compensated by the profit from selling the shares, allowing us to avoid the risk of infinite losses.