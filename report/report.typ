// Main report file
#import "template.typ": make-report, report-footnote
#import "metadata.typ": my-report
#import "@preview/theofig:0.1.0": definition

// Main content
#show: make-report.with(my-report)

= Computing returns

The following series describes the value of a portfolio at the end of each month:

#align(center)[
  #table(
    columns: 14,
    stroke: 0.5pt,
    align: center,
    [*Month*], [Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec],
    [$t$],     [0],   [1],   [2],   [3],   [4],   [5],   [6],   [7],   [8],   [9],   [10],  [11],  [12],
    [$P(t)$],  [100], [101], [102], [103], [104], [105], [106], [107], [108], [109], [110], [111], [112],
  )
]

The initial value of the portfolio being 100, the annual return is:

$ R_a = R_12(12) = frac(P(12) - P(0), P(0)) = 12% $

1. Compute monthly returns $\{R(t) mid t = 1, dots, 12\}$.

2. Compute the annual return $R_a$ from the monthly returns (you should find 12% again). Compare it to the sum of the monthly returns.

3. Compute the average monthly return $R_m$ and compare it to the average of the monthly returns.

= Continuously compounded return

Consider a constant annual interest rate of $R = 2.11%$ with a continuous compounding.

1. With an initial amount of \$10 000, what will be the value in:
  + 1 year?
  + 5 years?
  + 10 years?

2. What is the initial amount to have a final amount of \$10 000 in:
  + 1 year?
  + 3 years?
  + 10 years?

= Portfolio of Microsoft and Starbucks stock

You purchase 10 shares of each Microsoft and Starbucks stock at the end of month $t - 1$ at prices $P_"msft"(t-1) = \$85$ and $P_"sbux"(t-1) = \$30$.

1. Compute $V(t-1)$, the initial value of the portfolio.

2. Compute the portfolio shares $alpha_"msft"$ and $alpha_"sbux"$.

Consider now that at the end of month $t$, the prices are $P_"msft"(t) = \$90$ and $P_"sbux"(t) = \$28$.

3. Compute $R_"msft"(t)$ and $R_"sbux"(t)$, the one-period return of Microsoft and Starbucks stocks.

4. Compute the one-period return of the portfolio $R(t)$ and its value $V(t)$ at the end of month $t$.

= Present / Future value

Consider a constant annual return $R = 4.5%$, semi-annually compounded (i.e. two payments a year).

1. With an initial amount of \$10 000, what will be the value in:
  + 1 year?
  + 5 years?
  + 10 years?

2. What is the initial amount to have a final amount of \$10 000 in:
  + 1 year?
  + 3 years?
  + 10 years?

3. *Optional:* Let $R$ be the one-period return, $n$ the number of periods, and $m$ the number of payments per period. How would you prove that:

$ lim_(m -> +infinity) lr((1 + frac(R, m)))^(m n) = e^(R n) $
