#set document(title: "[14X030] Introduction to Computational Finance — Exercise #10")
#set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm))
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true)

#align(center)[
  #text(size: 14pt, weight: "bold")[{14X030} Introduction to Computational Finance]

  #v(0.4em)
  #text(size: 12pt)[Exercise \#10]

  #v(0.3em)
  #text(size: 11pt)[May 5, 2026]
]

#v(1em)

= General instructions

Each student is expected to upload on Moodle a zip file named as _firstname\_lastname_, containing the followings:

- A report in pdf format to answer exercise questions.
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

Upload on Moodle due by: *May 11, 2026 at 11:59 pm*

#pagebreak()

= The Greeks

Let an asset $S$ with initial value $S_0$ at $t = 0$. We consider both a European option to buy this asset (call) and to sell it (put), both with maturity $T = 1$ (in years) and strike price $K = 120$. We assume a constant volatility $sigma = 20%$ over their lifespan, and a risk-free rate $r = 5%$.

== Plotting the Greeks

Using the Black-Scholes formula to evaluate the call and the put price as a function of the initial asset price $S_0$, plot the evolution of:

- the price of the call/put;
- the $Delta$ of the call/put;
- the $Gamma$ of the call/put.

Comment on the meaning of these graphs.

== Hedging a short call

Suppose the asset price is $S_0 = 100$, and we sell 1000 calls.

- Which position should we have to be $Delta$-neutral?
- What is the profit of this strategy, supposing that $S_(0+epsilon) = 105$? $S_(0+epsilon) = 95$?
- In the two previous cases, compare the quality of this hedging strategy with having a fully naked (no position) or a fully covered option (buying a quantity of 1000 of the underlying asset).

== Hedging a short put

Suppose the asset price is $S_0 = 100$, and we sell 1000 puts.

- Which position should we have to be $Delta$-neutral?
- What is the profit of this strategy, supposing that $S_(0+epsilon) = 105$? $S_(0+epsilon) = 95$?
- In the two previous cases, compare the quality of this hedging strategy with having a fully naked or a fully covered option.
