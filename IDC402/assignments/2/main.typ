#import "lib.typ": *

#show heading.where(level: 3): it => {
  set block(above: 3em)
  block(it.body, above: 4em)
}

#show link: underline


#show: ilm.with(
  title: [IDC402 \ Assignment - 2],
  group-no: "",
  date: datetime(year: 2024, month: 04, day: 30),
  abstract: none,
  // bibliography: bibliography("refs.bib"),
  figure-index: (enabled: false),
  table-index: (enabled: true),
  listing-index: (enabled: true)
)

=== Q1. #strong[Analyze the long-term behavior of the map $display(x_(n+1) = (r x_n) / (1 + x_n^2))$, where $r > 0$. Find and classify all fixed points as a function of $r$ and their stability.]

For fixed points,

$
  x = (r x)/(1+x^2) \
  therefore x (1 - r + x^2) = 0 \
  therefore x = 0 "or" x = plus.minus sqrt(r - 1)
$

For $0 < r lt.eq 1$, $x = 0$ is the only fixed point. For $r > 1$, $x = 0$ and $x = plus.minus sqrt(r - 1)$ are fixed points.

For stability of these fixed points, we need to find the derivative of the map:

$
  f(x) & = (r x)/(1 + x^2) \
  f'(x) & = (r(1 + x^2) - 2r x^2)/(1 + x^2)^2 = (r(1 - x^2))/(1 + x^2)^2
$

- For $x = 0$:

  $ f'(0) = r > 0 $

  - Therefore x = 0 is stable for $r < 1$ and unstable for $r > 1$.

  - At $r = 1$, $f' (0) = 1$, which is inconclusive, so

    $ abs(x_(n+1)) = abs(x_n/(1 + x_n^2)) < abs(x_n/1) = abs(x_n) $

    So $x_n$ is stable for $r = 1$.

- For $x = plus.minus sqrt(r - 1)$:

  $ f'(sqrt(r - 1)) = (r(1 - (r - 1)))/(1 + (r - 1))^2 = (r (2-r))/r^2 = 2/r - 1 $

  - Therefore $x = plus.minus sqrt(r - 1)$ is stable for $r > 1$.

#v(2em)

To check the long-term behavior of the map, we see how $x$ evolves for different values of $r$:
  - For $r lt.eq 1$  and $x_0 eq.not 0$

  $ abs(x_(n+1)) = r abs(x_n/(1 + x_n^2)) < r abs(x_n/1) = r abs(x_n) < abs(x_n) $

  We showed that $x_n$ is monotonically decreasing and hence cant have periodic solutions.

  - For $r > 1$

  $ abs(x_(n+1)) = r abs(x_n/(1 + x_n^2)) < r abs(x_n/1) = r abs(x_n) < abs(x_n) $

  So the sequence $abs(x_n)$ is monotonically increasing or monotonically decreasing, and constant only if the sequence starts at a fixed point.

  So the solutions can never be periodic or chaotic.


=== Q2. #strong[Calculate the Lyapunov exponent of the map : $x_n + 1 = 10 x_n (mod 1)$ with $x$ belongs to $[0, 1]$. Can there be periodic solutions or chaos?]

This function can also be written as

$ f(x) = cases(
  10x & #h(1em) 0 <= x < 0.1 \
  10x - 1 & #h(1em) 0.1 <= x < 0.2 \
  10x - 2 & #h(1em) 0.2 <= x < 0.3 \
  & dots.v
)
$

We can see that the function is piecewise linear with slope $10$. The Lyapunov exponent is given by

$ lambda = lim_(n -> infinity) 1/n sum_(i=0)^(n-1) ln(abs(f'(x_i))) = 10 $

Since the Lyapunov exponent is positive, we can conclude that the system is chaotic.


=== Q3. #strong[For the following Lorenz system with parameters $σ = 10, β = 8/3$, plot $x(t)$, $y(t)$ and $x$ vs $z$. Find fixed points for each value of $r$ and discuss the different behaviours one observes:]

#strong[1. $r = 10$
2. $r = 24.5$
3. $r = 126.5$]

#grid(
  columns: (1fr, 1fr),
  row-gutter: 1em,
  figure(
    image("images/10.0_x.png"),
    caption: [$x(t)$ for $r = 10.0$],
  ),
  figure(
    image("images/10.0_y.png"),
    caption: [$y(t)$ for $r = 10.0$],
  ),

  figure(
    image("images/10.0_yvx.png"),
    caption: [$y(x)$ for $r = 10.0$],
  ),
  figure(
    image("images/10.0_zvx.png"),
    caption: [$z(x)$ for $r = 10.0$],
  ),

  figure(
    image("images/24.5_x.png"),
    caption: [$x(t)$ for $r = 24.5$],
  ),
  figure(
    image("images/24.5_y.png"),
    caption: [$y(t)$ for $r = 24.5$],
  ),

  figure(
    image("images/24.5_yvx.png"),
    caption: [$y(x)$ for $r = 24.5$],
  ),
  figure(
      image("images/24.5_zvx.png"),
      caption: [$z(x)$ for $r = 24.5$],
  ),

  figure(
    image("images/126.5_x.png"),
    caption: [$x(t)$ for $r = 126.5$],
  ),
  figure(
    image("images/126.5_y.png"),
    caption: [$y(t)$ for $r = 126.5$],
  ),

  figure(
    image("images/126.5_yvx.png"),
    caption: [$y(x)$ for $r = 126.5$],
  ),
  figure(
    image("images/126.5_zvx.png"),
    caption: [$z(x)$ for $r = 126.5$],
  ),
)

#v(2em)

The fixed points of the Lorenz system are $(0, 0, 0)$ (for all paramater values) and $(plus.minus sqrt(beta (r - 1)), plus.minus sqrt(beta (r - 1)), r - 1)$ (for $r > 1$). So

  - For $r = 10$, the fixed points are $(0, 0, 0)$ and $(plus.minus 3.162, plus.minus 3.162, 9)$.
  - For $r = 24.5$, the fixed points are $(0, 0, 0)$ and $(plus.minus 4.123, plus.minus 4.123, 23.5)$.
  - For $r = 126.5$, the fixed points are $(0, 0, 0)$ and $(plus.minus 8.165, plus.minus 8.165, 125.5)$.

The system exhibits chaotic behavior for $r = 24.5$ and $r = 126.5$.


=== #strong[Q4. Consider the Lienard equation]

#strong[$ diaer(x) - (mu -x^2) dot(x) + x = 0 $]

#strong[Show that the system exhibits supercritical Hopf bifurcation around the only fixed point of the system? Create phase portraits for few $mu$ values to show that bifurcation.]

Converting this to a system of first order equations, we have

$
  dot(x) & = y \
  dot(y) & = (mu - x^2) y - x \
$

The fixed point of the system is $(0, 0)$ for all values of $mu$. The Jacobian matrix at the fixed point is given by

$
  J = mat(
    0, 1;
    -1, mu;
  )
$

The eigenvalues of the Jacobian matrix are given by

$
  lambda_(1,2) = (mu plus.minus sqrt(mu^2 - 4))/2
$

For $mu < 0$, the eigenvalues are complex conjugates with negative real part, so the fixed point is stable. For $mu = 0$, the eigenvalues are purely imaginary. For $mu > 0$, the eigenvalues are complex conjugates with positive real part, so the fixed point is unstable. Thus, we can conclude that the system Hopf bifurcates at $mu = 0$.

To check if this a supercritical bifurcation, we look at the original equation again. The term $-(mu - x^2) dot(x)$ acts as damping.

- When $mu > 0$ and $x$ is very small ($x^2 < mu$), the damping term is negative and pushing the trajectories away from the origin.

- When $mu > 0$ and $x$ is larger ($x^2 > mu$), the damping term is positive and pulling the trajectories towards the origin.

This means that there exists a stable limit cycle for $mu > 0$. Since the fixed point is stable for $mu < 0$ and unstable for $mu > 0$, and the system exhibits a stable limit cycle for $mu > 0$, we can conclude that there is a supercritical Hopf bifurcation at $mu = 0$.

This can be visualized by plotting the phase portraits for different values of $mu$ through $0$:

#grid(
  columns: (1fr, 1fr),
  row-gutter: 1em,
  figure(
    image("images/lienard--0.5.png"),
    caption: [$mu = -0.5$],
  ),
  figure(
    image("images/lienard--0.1.png"),
    caption: [$mu = -0.1$],
  ),
  figure(
    image("images/lienard-0.0.png"),
    caption: [$mu = 0$],
  ),
  figure(
    image("images/lienard-0.1.png"),
    caption: [$mu = 0.1$],
  ),
  figure(
    image("images/lienard-0.5.png"),
    caption: [$mu = 0.5$],
  ),
  figure(
    image("images/lienard-2.0.png"),
    caption: [$mu = 2$],
  ),
)

#blockquote[The plots have been made in #link("https://julialang.org/")[Julia] using #link("https://docs.juliadiffeq.org/stable/")[DifferentialEquations.jl], #link("https://docs.juliaplots.org/stable/")[Plots.jl] and #link("https://docs.makie.org/stable/")[Makie.jl]].