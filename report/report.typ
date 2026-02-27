// Main report file
#import "template.typ": make-report, report-footnote
#import "metadata.typ": my-report
#import "@preview/theofig:0.1.0": definition
#import "@preview/pyrunner:0.3.0" as py

// Main content
#show: make-report.with(my-report)
#show raw.where(block: true): set block(fill: luma(240), inset: 1em, radius: 0.5em, width: 100%)
#show raw.where(block: false): box.with(
  fill: rgb("#e573e927"),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)

= Computing returns

The following series describes the value of a portfolio at the end of each month:

#align(center)[
  #table(
    columns: 14,
    stroke: 0.5pt,
    align: center,
    [*Month*], [Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec], [$t$],
    [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [$P(t)$],
    [100], [101], [102], [103], [104], [105], [106], [107], [108], [109], [110], [111], [112],
  )
]

The initial value of the portfolio being 100, the annual return is:

$ R_a = R_12(12) = frac(P(12) - P(0), P(0)) = 12% $

1. Compute monthly returns $\{R(t) mid t = 1, dots, 12\}$.

  The monthly returns are the following:
  - $R_1 = (P(1) - P(0))/P(0) = (101 - 100)/100 = 1/100$
  - $R_2 = (P(2) - P(1))/P(1) = (102 - 101)/101 = 1/101$
  - $R_3 = (P(3) - P(2))/P(2) = (103 - 102)/102 = 1/102$
  - $R_4 = (P(4) - P(3))/P(3) = (104 - 103)/103 = 1/103$
  - $R_5 = (P(5) - P(4))/P(4) = (105 - 104)/104 = 1/105$
  - $R_6 = (P(6) - P(5))/P(5) = (106 - 105)/105 = 1/106$
  - $R_7 = (P(7) - P(6))/P(6) = (107 - 106)/106 = 1/107$
  - $R_8 = (P(8) - P(7))/P(7) = (108 - 107)/107 = 1/108$
  - $R_9 = (P(9) - P(8))/P(8) = (109 - 108)/108 = 1/109$
  - $R_10 = (P(10) - P(9))/P(9) = (110 - 109)/109 = 1/110$
  - $R_11 = (P(11) - P(10))/P(10) = (111 - 110)/110 = 1/111$
  - $R_12 = (P(12) - P(11))/P(11) = (112 - 111)/111 = 1/112$

2. Compute the annual return $R_a$ from the monthly returns (you should find 12% again). Compare it to the sum of the monthly returns.

  $ 1 + R_a = product_(i = 1)^12 (1 + R_i) <=> R_a = [product_(i = 1)^12 (1 + R_i)] - 1 = 12% $

  ```python
  R = [1/(100 + i) for i in range(12)]
  R_a = 1
  for R_i in R:
    R_a *= (1 + R_i)
  R_a -= 1
  print(f"R_a = {R_a:.2f}")
  ```
  #raw(
    py.block(
      ```
      R = [1/(100 + i) for i in range(12)]
      R_a = 1
      for R_i in R:
        R_a *= (1 + R_i)
      R_a -= 1
      f"R_a = {R_a:.2f}"
      ```,
    ),
    lang: "python",
  )



3. Compute the average monthly return $R_m$ and compare it to the average of the monthly returns.

  - Average monthly return:
    $R_m = (1 + R_a/12)^12 - 1 = 2%$

    ```python
    R_m = (1 + 12/100 * 1/12)**2
    R_m -= 1
    print(f"R_m = {R_m:.2f}")
    ```
    #raw(
      py.block(
        ```
        R_m = (1 + 12/100 * 1/12)**2
        R_m -= 1
        f"R_m = {R_m:.2f}"
        ```,
      ),
      lang: "python",
    )
  - Average of the monthly returns:
    $1/12 sum_(i = 1)^12 R_i = 1/12 (1/100 + 1/101 + dots + 1/112) = 1%$

    ```python
    R = [1/(100 + i) for i in range(12)]
    average = 0
    for R_i in R:
      average += R_i
    average /= 12
    print(f"Average of monthly returns: {average:.2f}")
    ```
    #raw(
      py.block(
        ```
        R = [1/(100 + i) for i in range(12)]
        average = 0
        for R_i in R:
          average += R_i
        average /= 12
        f"Average of monthly returns: {average:.2f}"
        ```,
      ),
      lang: "python",
    )

  So it means that the average of the monthly returns is different from the average monthly return.


= Continuously compounded return

Consider a constant annual interest rate of $R = 2.11%$ with a continuous compounding.

1. With an initial amount of \$10 000, what will be the value in:
  - 1 year?
  - 5 years?
  - 10 years?

  We note $n = 1$ year, $F V_n$ the Future Value at year $n$ and $P V = 10000$ the Present Value.

  The continuous compounding formula is $F V_n = P V dot e^(R n)$

  So we have:
  - $F V_1 = P V dot e^(R) = 10000 dot e^(0.0211) = 10213.24 \$$
  - $F V_5 = P V dot e^(R dot 5) = 10000 dot e^(0.0211 dot 5) = 11112.66 \$$
  - $F V_10 = P V dot e^(R dot 10) = 10000 dot e^(0.0211 dot 10) = 12349.12 \$$

2. What is the initial amount to have a final amount of \$10 000 in:
  - 1 year?
  - 3 years?
  - 10 years?

  Now, we know the final amount $F V_n = 10000\$$.
  So the initial amount $P V$ is:
  $ F V_n = P V dot e^(R n) <=> P V = F V_n e^(-R n) $
  So to have a final amount of $10000$ after $n$ years, the initial amount must be:
  - For $n = 1$: $P V = F V_1 e^(-R) = 10000 e^(-0.0211) = 9791.21\$$
  - For $n = 3$: $P V = F V_3 e^(-R dot 3) = 10000 e^(-0.0211 dot 3) = 9386.62\$$
  - For $n = 10$: $P V = F V_10 e^(-R dot 10) = 10000 e^(-0.0211 dot 10) = 8097.74\$$

= Portfolio of Microsoft and Starbucks stock

You purchase 10 shares of each Microsoft and Starbucks stock at the end of month $t - 1$ at prices $P_"msft"(t-1) = \$85$ and $P_"sbux"(t-1) = \$30$.

1. Compute $V(t-1)$, the initial value of the portfolio.

  The initial value $V(t - 1)$ of the portfolio is:
  $ V(t - 1) = 10 dot P_"msft"(t-1) + 10 dot P_"sbux"(t-1) = 10 dot 85 + 10 dot 30 = 850 + 300 = 1150\$ $

2. Compute the portfolio shares $alpha_"msft"$ and $alpha_"sbux"$.
  
  - The portfolio share $alpha_"msft"$ has a value of: $alpha_"msft" = 10 / (10 + 10) = 1/2$

  - The portfolio share $alpha_"sbux"$ has a value of: $alpha_"sbux" = 10 / (10 + 10) = 1/2$

Consider now that at the end of month $t$, the prices are $P_"msft"(t) = \$90$ and $P_"sbux"(t) = \$28$.

3. Compute $R_"msft"(t)$ and $R_"sbux"(t)$, the one-period return of Microsoft and Starbucks stocks.

  - $R_"msft"(t) = (P_"msft"(t) - P_"msft"(t-1))/P_"msft"(t-1) = (90 - 85)/85 approx 5.9%$
  - $R_"sbux"(t) = (P_"sbux"(t) - P_"sbux"(t-1))/P_"sbux"(t-1) = (28 - 30)/30 approx -6.7%$

4. Compute the one-period return of the portfolio $R(t)$ and its value $V(t)$ at the end of month $t$.

  - The one-period return of the portfolio $R(t)$ is:
  $ R(t) = sum_(i in {"msft", "sbux"}) alpha_i R_i = alpha_"msft" R_"msft" + alpha_"sbux" R_"sbux" = 1/2 dot 5.9% - 1/2 dot 6.7% = -0.4% $
  - The value $V(t)$ of the portfolio is:
  $ V(t) = V(t - 1) (1 + R(t)) = 1150 (1 - 0.004) = 1145.4\$ $

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
