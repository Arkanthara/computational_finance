#set document(title: "[14X030] Introduction to Computational Finance — Exercise #9")
#set page(margin: (x: 2.5cm, y: 2.5cm))
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true)
#set heading(numbering: none)

#show heading.where(level: 1): it => {
  set text(size: 13pt, weight: "bold")
  v(0.8em)
  it
  v(0.4em)
}

#show heading.where(level: 2): it => {
  set text(size: 11pt, weight: "bold")
  v(0.6em)
  it
  v(0.3em)
}

// Title block
#align(center)[
  #text(size: 13pt, weight: "bold")[[14X030] Introduction to Computational Finance]

  #text(size: 12pt, weight: "bold")[Exercise \# 9]

  #text(size: 11pt)[April 28, 2026]
]

#v(1em)
#line(length: 100%)
#v(0.5em)

= General instructions

Each student is expected to upload on Moodle a zip file named as *firstname\_lastname*, containing the following:

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

Upload on Moodle due by: *May 4, 2026 at 11:59 pm*

#pagebreak()

= Option pricing: Black-Scholes versus Binomial Tree

Let an asset $S$ be valuated at $t = 0$ at $S_0 = 100$. We consider a European option to buy this asset (call) with maturity $T = 1$ (in years) and strike price $K = 120$. The goal of this exercise is to compare two methods to price this option, Black-Scholes and Binomial Tree. We assume a constant volatility $sigma = 20%$ over the lifespan of the call, and a risk-free rate $r = 5%$.

+ Implement the Black-Scholes formula to determine the value of this call at $t = 0$.

+ Implement a binomial tree to determine the initial value of the call. Your implementation should take the depth of the tree as an argument.

+ On the same graph, plot the evolution of the estimated value of the call option as a function of the binomial tree depth, as well as the value derived with Black-Scholes. What do you observe? How deep should be the tree in order to get a reasonable approximation of the Black-Scholes value?

= Implied Volatility from Binomial Prices

Using your binomial-tree pricer, compute the implied Black–Scholes volatility for different strikes and tree depths. Plot the resulting volatility "smile" and discuss convergence as the tree deepens.

== 1. Strikes & Tree Depths

- Fix $S_0 = 100$, $T = 1$, $r = 0.05$.
- Consider strikes $K in {80, 90, 100, 110, 120}$.
- Use three binomial-tree depths: $N in {20, 100, 500}$.

== 2. Compute Tree Prices

For each $(K, N)$, compute the call price

$ C_"tree" = "binomial\_call"(S_0, K, T, r, sigma_"true", N), quad sigma_"true" = 0.20. $

== 3. Implied Volatility via Bisection Method

- Implement the Black–Scholes call price

$ C_"BS"(S_0, K, T, r, sigma) = S_0 N(d_1) - K e^(-r T) N(d_2), $

with

$ d_(1,2) = frac(ln(S_0 \/ K) + (r plus.minus frac(1,2) sigma^2) T, sigma sqrt(T)). $

- For each tree price $C_"tree"$, solve for $sigma_"imp"$ satisfying

$ C_"BS"(S_0, K, T, r, sigma_"imp") = C_"tree" $

by using a bisection#footnote[Instead of coding the bisection loop yourself, you can use Python's `scipy.optimize.bisect`. Define $f(sigma) = C_"BS"(S_0, K, T, r, sigma) - C_"tree"$. Call `bisect(f, 1e-4, 2.0, xtol=1e-6)` to find $sigma_"imp"$. This will be more concise and handles convergence for you.] over $sigma in [10^(-4), 2.0]$ with tolerance $10^(-6)$.

== 4. Volatility Smile Plot

- On one chart, plot $sigma_"imp"(K)$ vs. $K$ for each tree depth $N$, then add a horizontal line at $sigma_"true" = 0.20$ as well.
- Comment on how the smile flattens as $N$ increases.
