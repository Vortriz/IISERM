#import "@preview/touying:0.5.3": *
#import "@preview/curryst:0.3.0" as curryst: rule

#import "theme.typ": *

#import "@preview/physica:0.9.3": *
#import "@preview/xarrow:0.3.1": *

#show: university-theme.with(
  config-colors(
    primary: rgb("#04364A"),
    secondary: rgb("#176B87"),
    tertiary: rgb("#448C95"),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#000000"),
  ),
  config-info(
    title: [Exploiting the Intrinsic Dynamics of a Driven Pendulum for Machine Learning],
    subtitle: [],
    author: [Rishi Vora (MS21113)],
    date: [2024-11-16],
    institution: [IISER Mohali],
  ),
)


#set heading(numbering: "1.")
#show figure.caption: set text(15pt)

#title-slide()

= What is Reservoir Computing?

---

Reservoir computing (RC) is an umbrella term for a number of different machine learning techniques that use dynamical systems #footnote([A _dynamical system_ is a rule for time evolution on a state space.]), also referred to as "reservoir". Usually, the system's rich transient (i.e. short term) dynamics are used to perform temporal (time-dependent) computations. However, it can also be applied to spatial (time-independent) tasks.

#figure(
  image("images/rc.jpg", height: 40%),
  caption: [Schematic of a typical RC @vandersande_2017]
)

---

== How can we use it?

Particularly, we look at the driven pendulum as a dynamical system. Moreover, we will see how it:

- performs in temporal tasks
- performs in spatial tasks
- performs under noise

= Driven Pendulum

== The system

Consider a pendulum with length $l$, the bob of mass $m$, periodically driven by a force of amplitude $F$, in an environment with damping coefficient $b$.

The equation of motion is given by:

$ dv(x,t,2) =  - g/l sin(x) - k dv(x,t) + f sgn(sin(omega t)) $

where $f = F/m, k = b/m$.

---

Here are some numerical simulations by varying the parameters,

#figure(
  image("images/bifurcation.png", height: 65%),
  caption: [Bifurcation diagram of the driven pendulum @mandal_2022. (a,b) have fixed $omega = 1.0$ while (c,d) have fixed $f = 1.5$. \ (a,c) show the asymptotic behaviour of the system while (b,d) show the transient dynamics.]
)

#pause
The transient dynamics look rich! We can use this to encode our data.

---

= The Scheme

== Choice of encoding

Encoding options we have:

#pause

1. Encode with initial condition #pause
  - Different trajectories can evolve similarly (not a one-to-one mapping)
  - Leads to input information loss, hence inefficient

#pause
2. Encode with system parameters #pause
  - Use amplitude $(f)$ and frequency $(omega)$
  - Each point in the $f - omega$ parameter space corresponds to a unique trajectory, hence more efficient

#pause
So clearly, we shall work with the parameters.

---

We will be working with 1D data, so varying either parameter is fine. So lets try both ways!

#pause
=== Amplitude encoding

Encode input data using forcing amplitude $f$ (with $omega$ fixed).
- Linearly map the input data to the chosen range of $f in [f_min, f_max]$.

#pause
=== Frequency encoding

Encode input data using forcing frequency $omega$ (with $f$ fixed).
- Linearly map the input data to the chosen range of $omega in [omega_min, omega_max]$.

---

== Regression

#pause
Let $u(t) = [u(t_1); u(t_2); dots; u(t_L)]$ #footnote[all arrays with semicolon $(;)$ as separator represent column vectors] denote the input signal and $v(t) = [v(t_1); v(t_2); dots; v(t_L)]$ denote the corresponding output signal.

#pause
1. Perform encoding
  - Amplitude encoding: $u(t_i) xarrow([f_min, f_max]) (f_i, omega)$ \
 So $u(t) arrow [(f_1 omega_1), (f_2, omega_2), dots, (f_i, omega_i)]$ where all $omega_i = omega$

  - Frequency encoding: $u(t_i) xarrow([omega_min, omega_max]) (f, omega_i)$ \
 So $u(t) arrow [(f_1 omega_1), (f_2, omega_2), dots, (f_i, omega_i)]$ where all $f_i = f$

#pause
2. For $t = t_i$, run the reservoir with $(x, dot(x)) = (0, 0)$ and $(f_i, omega_i)$ corresponding to $u(t_i)$

---

#pause
3. Record reservoir state at sampling rate of $kappa Omega$ $(kappa in bb(Z))$ for $N$ cycles
  - For amplitude encoding: $Omega = omega$ (frequency of driving force)
  - For frequency encoding: $Omega = omega_0$ (natural frequency of the oscillator)
 Store it as $S_i = [x(0); x(tau); dots; x(kappa N tau)]$

#pause
4. Repeat (2) and (3) for all $u(t_i)$ where $i = 1, 2, 3, dots, L$

#pause
5. The reservoir state vector corresponding to $u(t_i)$
  - for nontemporal tasks will be $X_i eq.triple S_i$
  - for temporal tasks will be $X_i eq.triple [w_0 S_(i-m), w_1, S_(i-m-1), dots, w_m S_i]$ where $w_j$ are linearly decreasing weights. \ $m$ is the finite memory which allows us to achieve _fading memory_ effect to process temporal data. So, the first $m$ number of input points are used only to generate the dynamics.

---

6. All $X_i$ are stacked to form state vector matrix $frak(R) eq.triple [X_1, X_2, dots, X_L]$. The output signal $v(t)$ is used for regression to connection matrix $W$. $ v = W frak(R) $ For training, we calculate $W$ using the known $v(t)$ as $ W = v frak(R)^(-1) $

---

= Performance Analysis

== Description

- Nontemporal: \ Approximate the following polynomial $ f(x) = (x-3) (x-2) (x-1) x (x+1) (x+2) (x+3) $ for $ x in [-3,3]$ 

- Temporal: \ Infer missing variable ($y(t)$ or $z(t)$) from the given state variable ($x(t)$) for a chaotic Lorenz system given by

$
  dot(x) & = 10 (y - x) \
  dot(y) & = x (28 - z) - y \
  dot(z) & = x y - 8/3 z
$

---

== Results

#figure(
  image("images/results.png", height: 85%),
  caption: [The comparison of predicted output with the target for (a, b) task 1 and (c, d) task 2. (a) and (c) are the results obtained with the amplitude encoding scheme, and (b) and (d) are those obtained with frequency encoding.  @mandal_2022]
)

#figure(
  table(
    columns: (1fr,1fr,1fr,1fr,1fr),
    row-gutter: 1em,
    stroke: none,
    fill: (x, y) =>
      if y == 0 { gray.lighten(70%) },
    inset: 8pt,
    align: center,
    table.header[#text(weight: "bold")[Input encoding]][#text(weight: "bold")[Task 1]][#text(weight: "bold")[Task 1 \ (with noise)]][#text(weight: "bold")[Task 2]][#text(weight: "bold")[Task 2 \ (with noise)]],
    [$f$], [$10^(-10)$], [$10^(-2)$], [$10^(-5)$], [$10^(-5)$],
    [$omega$], [$10^(-8)$], [$10^(-3)$], [$10^(-5)$], [$10^(-5)$]
  ),
  caption: [Comparison of performance, as quantified by the RMSE @mandal_2022. For Task 1, the reservoir was trained with $500$ data points; for Task 2, the reservoir was trained with temporal data of length $5000$. The results for Task 2 are for $x(t) arrow z(t)$ prediction. For testing performance in the presence of noise, each state variable was perturbed with a random noise, uniformly distributed in the range $[−0.01 : 0.01]$.]
)

---

= Conclusion

---

- A simple driven pendulum holds great potential to be used as a reservoir for machine learning tasks!
- Showed construction of such a reservoir
- Excellence in both temporal and nontemporal tasks
- It works great in noisy conditions, too!

#pause
#large-center-text[Thank you!]

---

#bibliography("references.bib")

---

#focus-slide[#align(center)[Questions?]]