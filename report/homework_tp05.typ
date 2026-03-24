#set document(title: "[14X030] Introduction to Computational Finance — Exercise #5")
#set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm))
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: none)

// Title block
#align(center)[
  #text(size: 13pt, weight: "bold")[[14X030] Introduction to Computational Finance]

  #v(0.4em)
  #text(size: 12pt)[Exercise \#5]

  #v(0.3em)
  #text(size: 11pt)[March 24, 2026]
]

#v(1em)
#line(length: 100%)
#v(0.5em)

// General Instructions
= General instructions

Each student is expected to upload on Moodle a zip file named as `firstname_lastname`, containing the followings:

- A report in pdf format to answer exercise questions.
- The code used to generate the results of the report.
- If preferred, submit a unique Jupyter notebook with both code and report explanations.

#v(0.5em)
#line(length: 100%)
#v(0.5em)

// Deeper Instructions
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

#v(0.5em)
#line(length: 100%)
#v(0.5em)

// Deadline
= Deadline

Any questions to: Lorenzo Bini.

Upload on Moodle due by: *March 30, 2026 at 11:59 pm*

#pagebreak()

// Part 1
= Limit Order Book — Maslov model

The goal of this series is to implement the Maslov model (check the paper for more details), which allows to reproduce interesting stylized facts while being relatively simple.

We consider the following version of the model:

- One trader at each time step.
- Buyer or seller, with probability $1 - q$ and $q$.
- Issues a market order (buy at ask / sell at bid) with probability $1 - r$ or a limit order with probability $r$. The price for the limit order is defined as $p - K$ when buying and $p + K$ when selling, with $p$ the market price, defined as the last price said in the market. $K$ is a positive random variable.
- Each trader buys or sells a quantity of one.
- An order cannot be canceled.
- If an order cannot be executed (e.g. a sell market order but there is no buy order in the LOB), then nothing happens at this time step.

#v(0.5em)

+ Implement the procedure above and unroll it for 1000 iterations. Use $q = r = 0.5$ and $K = 1$ with probability 1. Plot the time series of the market, ask, bid and mid prices $p(t)$, $a(t)$, $b(t)$ and $m(t) = (b(t) + a(t)) / 2$. Are there any difference between the mid and the market prices?

+ Plot the time series of returns of the market price, what do you observe?

+ Plot the histogram of the values of this series. What can you say of this distribution? Is it a normal distribution?

+ Plot and comment the ACF graph of this series.

+ Compute the bid–ask spread $s(t) = a(t) - b(t)$ and plot its time series.

+ Plot a histogram of the spread values. Comment on whether the distribution is fat-tailed.

+ For selected time points, analyze the order book depth: for a range of price levels relative to the best bid/ask, compute the aggregated number of orders.

+ Plot the depth distribution and discuss its shape in relation to empirical observations.

+ Change the parameters of the model to understand how they influence the market and comment about this point.

#pagebreak()

// Part 2
= Heterogeneous Order Sizes and Trader Behavior on LOB Dynamics

Finally, you will extend the basic Maslov model to include heterogeneity in order sizes and trader behavior. You will investigate how these extensions influence the market price dynamics, volatility, and autocorrelation structure of returns.

We now consider the following version of the model:

- Instead of assuming every order has unit size, assume that order sizes are drawn from a distribution (for example, a discrete uniform distribution between 1 and 5).
- Introduce two types of traders:
  - *Aggressive Traders:* With a higher probability (e.g., 0.8) they submit market orders.
  - *Passive Traders:* With a higher probability (e.g., 0.8) they submit limit orders.
- Let each trader, at each time step, be randomly classified as aggressive or passive.

#v(0.5em)

+ Run the simulation for 1000 iterations with the extended model.

+ Record the time series of the market price and compute the returns.

+ Plot the histogram of returns and calculate basic statistics (mean, variance).

+ Compute and plot the autocorrelation function (ACF) of the return series.

+ Discuss how the introduction of heterogeneous order sizes and trader behavior affects the price dynamics compared to the baseline model. Comment on any observed changes in volatility clustering or the fat-tailed nature of the return distribution.
