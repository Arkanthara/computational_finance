#set document(title: "[14X030] Introduction to Computational Finance — Exercise #11")
#set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm))
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true)
#set heading(numbering: none)

// ---------- Title block ----------
#align(center)[
  #text(weight: "bold", size: 13pt)[\[14X030\] Introduction to Computational Finance]

  #v(4pt)
  #text(size: 12pt)[Exercise \#11]

  #v(4pt)
  #text(size: 11pt)[May 12, 2026]
]

#v(12pt)
#line(length: 100%)

// ---------- General instructions ----------
= General instructions

Each student is expected to upload on Moodle a zip file named as *firstname\_lastname*, containing the following:

- A report in PDF format to answer exercise questions.
- The code used to generate the results of the report.
- If preferred, submit a unique Jupyter notebook with both code and report explanations.

= Deeper instructions

*Report:*
- Answers to the TP questions. Figures and numerical results are necessary but strictly not sufficient: provide your analysis/comments as well.
- Example: if your results surprise you, explain why and explain what the expected result was.
- Pay attention to the presentation: axis labels, legend, etc.

*Code:*
- Implementation questions + code used to produce the results and figures in the report.
- Programming language of your choice.
- Do not use ChatGPT, or any other LLM/AI-assisted tools while writing down your code. Try by yourself, otherwise it will be counted as failed.
- I strongly recommend Python/Julia: I won't be able to assist you in the same way if you use a different language.

= Deadline

Any questions to: Lorenzo Bini.

Upload on Moodle due by: *May 18, 2026 at 11:59 pm*

#line(length: 100%)
#v(6pt)

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

// ============================================================
// Exercise 2 — Interest curve
// ============================================================
= Interest curve

Consider we have some bonds with a coupon paid semi-annually (Fig. 1) and some other with a coupon paid annually (Fig. 2).

- Using the bootstrap algorithm seen during the course, compute the zero-coupon rate for each maturity.
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
