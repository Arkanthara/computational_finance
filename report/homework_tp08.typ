#set document(title: "[14X030] Introduction to Computational Finance — Exercise #8")
#set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm))
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true)

#show heading.where(level: 1): it => block(
  above: 1.4em,
  below: 0.8em,
  text(weight: "bold", size: 13pt, it.body)
)

// ── Title block ──────────────────────────────────────────────────────────────
#align(center)[
  #text(size: 14pt, weight: "bold")[
    [14X030] Introduction to Computational Finance
  ]
  #v(0.4em)
  #text(size: 13pt)[Exercise \#8]
  #v(0.2em)
  #text(size: 11pt, style: "italic")[April 21, 2026]
]

#v(1em)
#line(length: 100%, stroke: 0.5pt)
#v(0.6em)

// ── General instructions ─────────────────────────────────────────────────────
= General Instructions

Each student is expected to upload on Moodle a zip file named as `firstname_lastname`,
containing the following:

- A report in PDF format to answer exercise questions.
- The code used to generate the results of the report.
- If preferred, submit a unique Jupyter notebook with both code and report explanations.

// ── Deeper instructions ──────────────────────────────────────────────────────
= Deeper Instructions

*Report:*

- Answers to the TP questions. Figures and numerical results are necessary but strictly
  not sufficient: provide your analysis/comments as well.
- Example: if your results surprise you, explain why and explain what the expected
  result was.
- Pay attention to the presentation: axis labels, legend, etc.

*Code:*

- Implementation questions + code used to produce the results and figures in the report.
- Programming language of your choice.
- Do not use ChatGPT, or any other LLM/AI-assisted tools while writing down your code.
  Try by yourself, otherwise it will be counted as failed.
- I strongly recommend Python/Julia: I won't be able to assist you in the same way if
  you use a different language.

// ── Deadline ─────────────────────────────────────────────────────────────────
= Deadline

Any questions to: Lorenzo Bini.

Upload on Moodle due by: *April 27, 2026 at 11:59 pm*

#v(0.6em)
#line(length: 100%, stroke: 0.5pt)
#v(1em)

// ── Minority Game ────────────────────────────────────────────────────────────
= Minority Game

Let $N$ be the number of agents, $M$ the number of bits of history and $S$ the number of
strategies available to each agent among the $2^(2^M)$ possible strategies.

- Each agent initializes the utilities of its strategies to zero.
- Initialize the history $mu(0)$ to a random list of $M$ bits.
- For $t$ in $1, dots, T$:
  - Each agent $i in {1, dots, N}$ samples a strategy $s_i (t)$ according to the softmax
    distribution of utilities:
    $ frac(exp(Gamma_i u_(s(t))), sum_(s') exp(Gamma_i u_(s'(t)))) quad "where" Gamma_i > 0. $
  - Given the current history $mu(t)$, each agent uses its chosen strategy $s_i (t)$ to
    pick an action $a_i (t) in {+1, -1}$.
  - Compute the attendance:
    $ A(t) = sum_(i=1)^(N) a_i (t). $
  - Update the utility of the chosen strategies with a linear payoff:
    $ u_(s_i)(t) = u_(s_i)(t-1) - a_i (t) dot frac(A(t), beta) $
  - Remove the oldest bit of history and add a new one.

#v(0.8em)

*1.* #h(0.4em)
*(a)* Why is the above procedure called a minority game?

*(b)* What is the role of $Gamma_i$? In particular, what does a large or a small value of
$Gamma_i$ mean?

#v(0.4em)

*2.* #h(0.4em) Implement a minority game. You can use $beta = 1$ and $Gamma_i = 0.01$,
$forall i in {1, dots, N}$. To add a new bit of history, you can either pick it at random
or from some function of the attendance ($1$ if positive attendance, $0$ if negative
attendance for instance).

#v(0.4em)

*3.* #h(0.4em) Simulate a minority game with $S = 2$ strategies for $T = 100$ steps for
values of $N$ in ${51, 101, 251, 501, 1001}$ and values of $M$ in ${0, 1, dots, 18}$.
On a log-log plot, represent $sigma^2 \/ N$, the scaled variance of the attendance, against
$alpha = 2^M \/ N$.

#v(0.4em)

*4.* #h(0.4em) What is the critical value $alpha_c$ for which the volatility reaches a
minimum?

#v(0.4em)

*5.* #h(0.4em) *(Optional)* Define an initial price $p(0)$ (for instance $100$) and then
update it as follows:
$ p(t) = p(t-1) exp!left( frac(A(t), lambda) right) $
with $lambda$ some positive constant. What is the intuition behind this update rule? Plot
price curves for different values of $alpha$ and $lambda$ and comment.
