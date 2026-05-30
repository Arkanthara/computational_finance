#set document(title: "Introduction to Computational Finance - Exercise #13")
#set page(numbering: "1")
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.")

#align(center)[
  = [14X030] Introduction to Computational Finance
  Exercise #13 \
  May 26, 2026
]

== General instructions

Each student is expected to upload on Moodle a zip file named as `firstname_lastname`, containing the followings:

- A report in pdf format to answer exercise questions.
- The code used to generate the results of the report.
- If preferred, submit a unique Jupyter notebook with both code and report explanations.

== Deeper instructions

*Report:*

- Answers to the TP questions. Figures and numerical results are necessary but strictly not sufficient: provide your analysis/comments as well.
- Example: if your results surprise you, explain why and explain what the expected result was.
- Pay attention to the presentation: axis labels, legend, etc.

*Code:*

- Implementation questions + code used to produce the results and figures in the report.
- Programming language of your choice.
- Do not use ChatGPT, or any other LLM/AI-assisted tools while writing down your code. Try by yourself, otherwise it will be counted as failed.
- I strongly recommend Python/Julia: I won't be able to assist you in the same way if you use a different language.

== Deadline

Any questions to: Lorenzo Bini. \
Upload on Moodle due by: June 01, 2026 at 11:59 pm

---

== Exercise #1: Futures valuation

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
+ Plot the evolution of $S_t$ and $F_t$ on the same graph.
+ What can you say about the way $F_t$ converges towards $S_T$?

== Exercise #2: Mark-to-Market P/L of a Futures Position

In this exercise, you will track the monthly profit and loss of a long futures position, marked to market at each observation date, and see how variation margin accumulates over time.

+ *Futures Prices:* You already computed $F_t = S_t exp(r(T - t))$ at each monthly date $t$ for both scenarios in Exercise #1.

+ *Mark-to-Market P/L:*
  - Assume you enter a long futures contract at $t_0 = 0$ at price $F_0$.
  - At each subsequent date $t_i$, your variation margin (PnL) is 
    $
    Delta P_i = F_(t_i) - F_(t_(i-1)).
    $
  - Compute $Delta P_i$ for $i = 1, 2, ..., 6$ (every 2 months), and the cumulative P/L $"CumPL"_i = sum_(j=1)^i Delta P_j$.

+ *Plotting & Discussion:*
  - On one chart, plot the two scenarios of cumulative P/L versus $t$.
  - On a second chart, overlay $Delta P_i$ (bar chart) for each scenario.
  - Comment on the variability of monthly variation margins under each scenario.
