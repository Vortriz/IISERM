#import "lib.typ": *

#show: ilm.with(
  title: [IDC402 \ Assignment - 1],
  group-no: "",
  date: datetime(year: 2024, month: 04, day: 30),
  abstract: none,
  // bibliography: bibliography("refs.bib"),
  figure-index: (enabled: false),
  table-index: (enabled: true),
  listing-index: (enabled: true)
)

#strong[Q1. Find an approximate fixed points addd discuss their stability graphically for the following dynamical system

$ dot(x) = e^x - cos x $

where $dot(x) = d x\/d t$.]

The exact solutions are hard to find analytically, so we plot $e^x$ and $cos x$ to see where they intersect, to graphically get the roots $x^ast$ of the equation $f (x^ast) = e^x^ast - cos x^ast = 0$. The regions having $e^x > cos x$ have a flow to the right whereas the ones with $e^x < cos x$ have a flow to the left.

#figure(
  grid(
    columns: 1,
    [#image("images/1.png")]
  ),
)

#pagebreak()

#strong[Q2. Identify the dynamical system that has following fixed points with respective stabilities on the real axis: Clearly, there are multiple answers. You need to identify one possible system.]

#figure(
  grid(
    columns: 1,
    [#image("images/2.png")]
  ),
)

One possible system with these set of fixed points is

$ f(x) = x (x+1)^2 (x-2) $

#figure(
  grid(
    columns: 1,
    [#image("images/2.1.png")]
  ),
)

#pagebreak()

#strong[Q3. Show that following dynamical system displays saddle-node bifurcation. Plot fixed plots and discuss their stabilities for various regions of control parameter $r$. What is the bifurcation point and also plot bifurcation diagram.

$ dot(x) = r + x - ln (1 + x) $]

The $ln$ term can be expanded to give

$
dot(x) = f (x) & = r + x - (x - x^2/2 + dots) \
& = r + x^2/2
$

This can be rescaled to the form $dot(x) = r + x^2$ which is the normal form for saddle-node bifurcation. Thus, this system undergoes a saddle-node bifurcation.

We plot $r + x$ and $ln(1 + x)$ to see where they intersect, to graphically find the fixed points of the system. The regions having $r + x > ln(1 + x)$ have a flow to the right whereas the ones with $r + x < ln(1 + x)$ have a flow to the left. The bifurcation occurs when the curves both intersect tangentially.

#figure(
  grid(
    columns: 1,
    [#image("images/3.png")]
  ),
)

This value of $r$ can be found by equating the curves and their slopes

$
d/(d x) (r + x) = d/ (d x) ln(1 + x) \
therefore 1 = 1/(1 + x) \
therefore x = 0
$

which is put in

$
r + x = ln(1 + x) \
therefore r = 0
$

#pagebreak()

Hence, $r = 0$ is the bifurcation point. The bifurcation diagram is like

#figure(
  grid(
    columns: 1,
    [#image("images/3.1.png")]
  ),
)

#pagebreak()

#strong[Q4. Consider the normal form of subcritical pitchfork bifurcation,

$ dot(x) = r x + x^3 $

where $r$ is the control parameter. This system is discussed in class. When $r > 0$, there is no stable solution for this system. Now to stabilize the system, an additional term is added which results into following dynamical system,

$ dot(x) = r x + x^3 − x^5. $

Calculate all its fixed points and discuss their nature. Draw bifurcation diagram and also argue why there is a possible hysteresis effect in this system.]

First we solve $f (x) = r x - x^3 + x^5 = 0$ by factoring out $x$, which gives $x (r - x^2 + x^4) = 0$. S0, $x = 0$ is a fixed point. For nonzero $x$, set $r - x^2 + x^4 = 0$. Substitute $u = x^2$ to obtain a quadratic in $u$, $u^2 - u + r = 0$. The discriminant is $Delta = 1 - 4r$. Real solutions in $u$ (and hence for $x$) exist when $Delta ≥ 0$, i.e. $r <= 1/4$.

The solutions for $u$ are:
$ u_(1,2) = (1 plus.minus sqrt(1 - 4r))/2. $

Since $x^2 = u$, the additional fixed points are
$ x = plus.minus √((1 ± sqrt(1 - 4r))/2).$

As for stability, the derivative

$ f' (x) = d/(d x) (r x - x^3 + x^5) = r - 3x^2 + 5x^4. $

- At $x = 0$, $f '(0) = r$ so that:

  – If $r < 0$, $x = 0$ is locally attracting (stable).

  – If $r > 0$, $x = 0$ is repelling (unstable).

• For nonzero fixed points (with $x^2 = u$), substitute $u$ into $f '(x)$:

$ f '(x) = r - 3u + 5u^2 $.

Noting that $u$ satisfies $u^2 - u + r = 0$ (i.e. $u^2 = u - r$), we can simplify:

  $f '(x) = r - 3u + 5(u - r) = 2u - 4r$.

For $u_1 = (1 + sqrt(1 - 4r))/2$, $f '(x) = 1 + sqrt(1 - 4r) - 4r$. For typical $r$-values where these fixed points exist ($r < 1/4$) this derivative is positive, indicating that these fixed points are unstable.

For $u^2 = (1 - sqrt(1 - 4r))/2$, $f '(x) = 1 - sqrt(1 - 4r) - 4r$. Depending on $r$, this expression can be negative, suggesting stability.

• At $r = 1/4$, the discriminant $Delta = 0$ and the two branches of nonzero fixed points coalesce in a saddle-node bifurcation.

• At $r = 0$, the stability of $x = 0$ changes (a pitchfork bifurcation).

#pagebreak()

#strong[Q5. Suppose that our overdamped pendulum is connected to a torsional spring. As the pendulum rotates, the spring winds up and generates an opposing torque $-k theta$. Then the equation of motion becomes $b dot(theta) + m g L sin theta = Gamma - k theta$.

a) Does this equation give a well-defined vector field on the circle?]

To check if it is well defined, we check if $f (theta + 2 pi) = f (theta)$, which is not true in this case. So it does not give a well defined vector field on a circle.

#strong[b) Nondimensionalize the equation.]

Rearranging the equation to get

$ b/(m g L) dot(theta) = Gamma/(m g L) - k/(m g L) theta $

Taking

$ tau = (m g L)/b, quad gamma = Gamma/(m g L), quad kappa = k/(m g L) $

we get

$ theta' = - sin theta + gamma - kappa theta $

#strong[c) What does the pendulum do in the long run?]

Since $gamma$ and $kappa$ both should be $>= 0$, we can divide this into two major cases:

- If $b = 0$, then this the case of overdamped pendulum.
- If $b > 0$, then the graph shows that there will be many saddle-node bifurcations.
