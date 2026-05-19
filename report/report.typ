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

// ============================================================
// Exercise 1 — Bonds
// ============================================================
= Bonds

Suppose we have a bond with 3 years maturity, a face value of 100\$ and coupons of 10% paid semi-annually:

#figure(
  table(
    columns: (auto, auto),
    align: center,
    stroke: 0.5pt,
    table.header(
      [*time \[years\]*], [*coupon \[\$\]*],
    ),
    [0.5], [5],
    [1.0], [5],
    [1.5], [5],
    [2.0], [5],
    [2.5], [5],
    [3.0], [5],
  ),
)

- What is the required yield to sell the bond at par?

  We consider the yield to be constant during the life of the bond.

  We note $y$ the yield.

  We want the price of the bond to be equal to its face value, i.e. 100\$.

  So we have:

  $
    100 &= 5e^(-y dot 0.5) + 5e^(-y dot 1) + 5e^(-y dot 1.5) + 5e^(-y dot 2) + 5e^(-y dot 2.5) + 105e^(-y dot 3) \
    &= 5e^(-0.5y) + 5(e^(-0.5y))^2 + 5(e^(-0.5y))^3 + 5(e^(-0.5y))^4 + 5(e^(-0.5y))^5 + 105(e^(-0.5y))^6 \
    &= 5x + 5x^2 + 5x^3 + 5x^4 + 5x^5 + 105x^6 \
    <=> 0 &= 5x + 5x^2 + 5x^3 + 5x^4 + 5x^5 + 105x^6 - 100 \
    <=> 0 &= 21x^6 + x^5 + x^4 + x^3 + x^2 + x - 20 \
  $

  ```python
  import numpy as np
  from scipy.optimize import fsolve

  def equation(x):
      return 21 * x**6 + x**5 + x**4 + x**3 + x**2 + x - 20

  x_solution = fsolve(equation, 1)[0]
  y_solution = -2 * np.log(x_solution)
  print(f"Required yield to sell the bond at par: {y_solution}")
  ```

  So yield is approximately 9.7%.

  

// ============================================================
// Exercise 2 — Interest curve
// ============================================================
= Interest curve

Consider we have some bonds with a coupon paid semi-annually (@fig1) and some other with a coupon paid annually (@fig2).

- Using the bootstrap algorithm seen during the course, compute the zero-coupon rate for each maturity.

  We note $r_i$ the zero-coupon rate for maturity $t_i$.

  We have $(1 + R/m)^m = e^r$, where $R$ is the yield of the bond, and $m$ is the number of compounding periods per year.


- Draw the graph of the zero-coupon rate against the maturity. What do you observe?

// ============================================================
// Exercise 3 — Duration and Interest Rate Sensitivity
// ============================================================
= Duration and Interest Rate Sensitivity

Lastly, you will compute the Macaulay and modified durations of selected bonds using the zero-coupon rates obtained from bootstrapping. Then, you will analyze how bond prices respond to small parallel shifts in the yield curve.

*1. Select Two Bonds:* Choose one bond from Fig. 1 (semi-annual coupons) and one bond from Fig. 2 (annual coupons).

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: center,
    stroke: 0.5pt,
    table.header(
      [*Principal*], [*Maturity (month)*], [*Coupons (%)*], [*Price*],
    ),
    [100], [1],  [0], [99.80],
    [100], [2],  [0], [99.60],
    [100], [3],  [0], [99.40],
    [100], [6],  [3], [100.27],
    [100], [12], [4], [101.57],
  ),
  caption: [Bonds with a coupon paid semi-annually],
) <fig1>

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: center,
    stroke: 0.5pt,
    table.header(
      [*Principal*], [*Maturity (year)*], [*Coupons (%)*], [*Price*],
    ),
    [100], [2],  [4], [103.21],
    [100], [3],  [4], [104.85],
    [100], [4],  [4], [106.36],
    [100], [5],  [4], [107.77],
    [100], [7],  [0], [84.48],
    [100], [10], [0], [77.72],
  ),
  caption: [Bonds with a coupon paid annually],
) <fig2>

*2. Compute Durations:*

- Using the zero-coupon rates computed in Exercise 2, calculate the present value of each cash flow.
- Compute the Macaulay duration as the weighted average time to receive the bond's cash flows:
$
  D_M = sum_i lr((frac(P V_i, P) dot.c t_i)),
$
where $P V_i$ is the present value of the cash flow at time $t_i$, and $P$ is the total bond price.

- Then compute the modified duration, which adjusts for the interest rate level:
$
  D_"mod" = frac(D_M, 1 + r),
$
where $r$ is the yield used to discount the cash flows.

*3.* Simulate a parallel upward shift of 10 basis points (0.001) in the entire zero-coupon curve.

*4.* Recompute the bond price under the shifted curve.

*5.* Compare the predicted price change using modified duration with the actual price change from repricing.

*6.* How well does modified duration approximate the price change? Which bond is more sensitive to rate changes and why?
