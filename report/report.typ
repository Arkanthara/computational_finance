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

      This procedure is called a minority game because we study the global behavior of a population of agents thanks to the modelisation of each agent's behavior. Each agent has to choose a strategy among a set of strategies, and each agent will try to be in the minority group in order to win.

*(b)* What is the role of $Gamma_i$? In particular, what does a large or a small value of
$Gamma_i$ mean?
      $Gamma_i$ is a parameter that controls the exploration-exploitation trade-off of the agents. A large value of $Gamma_i$ means that the agent will be more likely to choose the strategy with the highest utility, while a small value of $Gamma_i$ means that the agent will be more likely to explore other strategies.

*2.* #h(0.4em) Implement a minority game. You can use $beta = 1$ and $Gamma_i = 0.01$,
$forall i in {1, dots, N}$. To add a new bit of history, you can either pick it at random
or from some function of the attendance ($1$ if positive attendance, $0$ if negative
attendance for instance).

```python
import numpy as np

def minority_game(N: int, M: int, S: int, T: int, beta: float = 1, G: float = 0.5) -> list:
    """
    Simulate a minority game with N agents, M bits of history, S strategies, and T time steps.
    
    Parameters:
    - N: Number of agents
    - M: Number of bits of history
    - S: Number of strategies available to each agent
    - T: Number of time steps to simulate
    - beta: Scaling factor for utility updates
    - G: Exploration parameter for the softmax distribution
         Small G means more exploration, large G means more exploitation.

    Returns:
    - attendance: List of attendance values at each time step
    """
    # Initialize utilities
    u = np.zeros((N, S))
    
    # Initialize history
    history = np.random.randint(2, size=M).tolist()
    
    # Store attendance
    attendance = []
    
    for t in range(T):
        # Sample strategies
        x = G * u
        x = x - np.max(x, axis=1, keepdims=True)  # stabilize
        exp_x = np.exp(x)
        probs = exp_x / np.sum(exp_x, axis=1, keepdims=True)
        s = np.array([np.random.choice(S, p=probs[i]) for i in range(N)], dtype=int)
        
        # Determine actions based on chosen strategies and current history
        if M > 0:
            actions = np.array([1 if history[min(s[i], M-1)] == 1 else -1 for i in range(N)])
        else:
            actions = np.random.choice([-1, 1], size=N)
        
        # Compute attendance
        A_t = np.sum(actions)
        attendance.append(A_t)
        
        # Update utilities
        for i in range(N):
            u[i, s[i]] -= actions[i] * A_t / beta
        
        # Update history
        new_bit = 1 if A_t > 0 else 0
        if M > 0:
          history.pop(0)
          history.append(new_bit)
    
    return attendance
```


*3.* #h(0.4em) Simulate a minority game with $S = 2$ strategies for $T = 100$ steps for
values of $N$ in ${51, 101, 251, 501, 1001}$ and values of $M$ in ${0, 1, dots, 18}$.
On a log-log plot, represent $sigma^2 \/ N$, the scaled variance of the attendance, against
$alpha = 2^M \/ N$.

```python
import matplotlib.pyplot as plt
def plot_scaled_variance(N_values, M_values, T=100):
    scaled_variances = []
    alphas = []
    
    for N in N_values:
        for M in M_values:
            attendance = minority_game(N, M, S=2, T=T, G=1)
            variance = np.var(attendance)
            scaled_variance = variance / N
            alpha = 2**M / N
            
            scaled_variances.append(scaled_variance)
            alphas.append(alpha)
    
    plt.figure(figsize=(10, 6))
    plt.loglog(alphas, scaled_variances, 'o')
    plt.xlabel(r'$\alpha = \frac{2^M}{N}$')
    plt.ylabel(r'$\sigma^2 / N$')
    plt.title('Scaled Variance of Attendance vs Alpha')
    plt.grid(True)
    plt.show()

plot_scaled_variance(N_values=[51, 101, 251, 501, 1001], M_values=range(19))
```


#v(0.4em)

*4.* #h(0.4em) What is the critical value $alpha_c$ for which the volatility reaches a
minimum?

To perform the plot, I decided to use $G = 1$ since in this way, the agent will choose the strategy instead of exploring other strategies.

The critical value $alpha_c$ for which the volatility reaches a minimum is when $alpha$ is very small (close to zero).
This means that when the history length $M$ is much smaller than the number of agents $N$, the system has a low volatility... This is due to the fact that when $M$ is small, the agents don't have enough information to make informed decisions, so they tend to make similar decisions, which leads to a low volatility.

But when $M$ is large, they can make very different decisions thanks to the large amount of information they have. This leads to a high volatility.

#v(0.4em)

*5.* #h(0.4em) *(Optional)* Define an initial price $p(0)$ (for instance $100$) and then
update it as follows:
$ p(t) = p(t-1) exp(frac(A(t), lambda)) $
with $lambda$ some positive constant. What is the intuition behind this update rule? Plot
price curves for different values of $alpha$ and $lambda$ and comment.
