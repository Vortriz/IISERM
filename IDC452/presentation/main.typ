#import "@preview/touying:0.6.1": *
#import "theme.typ": *

#import "@preview/physica:0.9.5": *
#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge

#show: university-theme.with(
  config-colors(
    primary: rgb("#13496d"),
    secondary: rgb("#00708f"),
    tertiary: rgb("#00989d"),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#000000"),
  ),
  config-info(
    title: [Quantum Algorithm for Link Prediction in Complex Networks],
    subtitle: [],
    author: [Rishi Vora (MS21113)],
    date: [2025-04-12],
    institution: [IISER Mohali],
  ),
  aspect-ratio: "16-9"
)


#set heading(numbering: "1.1 ")
#show figure.caption: set text(15pt)


#title-slide()

= Introduction

== Why link prediction?

- Complex system --- A system whose collective behavior is difficult to derive from a knowledge of the system's components.
- Network science studies complex systems represented as networks (graphs) of interconnected entities.
- How these networks form, evolve, and influence behaviors across domains like social networks, biological systems, etc.
- Link prediction --- forecasts where new connections might form in a network.
- Approaches for link prediction include machine learning techniques, studying global perturbations.
- Paths based methods --- Predict links based on path length between different nodes.

= Classical methods

== How they work?

Link prediction methods take as input a graph $G (cal(V), cal(E))$ where $cal(V)$ is the set of nodes with size $N = |cal(V)|$ and $cal(E)$ is the set of undirected links, often described by the adjacency matrix $A in {0, 1}^(N times N)$ where

$
  A_(i j) = A_(j i) = cases(
    1 "if" (i, j) in cal(E),
    0 "otherwise"
  )
$

and output a matrix of predictions $P in RR^(N times N)$ where each entry $p_(i j)$ is a score value quantifying the likelihood of a link existing between nodes $i$ and $j$.

A matrix $S in RR^(N times N)$ quantifies the similarity between any two nodes.

== The approaches

=== TCP based

- Predictions are based on similarity between two nodes i.e. $P = S$.
- Similarity is quantified based on the number of shared connections, i.e., paths of even lengths $(S = A^(2n))$.
- Useful in social networks where the number of common friends is a good predictor of future connections.

=== L3 based

- Predictions are based on node $i$ being similar to the existing neighbours of another node $j$, i.e. $P = A S$.
- Similarity is quantified based on number of similar neighbours, i.e., paths of odd lengths $(S = A^(2n + 1))$.
- Useful in biological networks like protein pairs.

= Quantum Link Prediction

== Proposal

- Classical methods produce likelihood score $p_(i j)$ for all possible $(i, j)$

- But practically, we only need the ones which cross a certain threshold.

- We use quantum walks to encode path-based link prediction @moutinho_2023.

- We encode the prediction scores in the amplitudes of a superposition and perform measurements. The predictions with the highest score will be naturally sampled with higher probability.

- Utilises both even and odd path lengths.

== The method

We use the continuous-time quantum walk (CTQW) formalism. The Hilbert space of the walk is defined by ${ket(j)}$ where $j in cal(V)$. The Hamiltonian is the adjacency matrix $A$ of the graph @portugal_2018. The walk itself is defined as the solution of the differential equation

$ i dv(,t) ket(psi(t)) = A ket(psi(0)) $

which is

$ ket(psi(t)) = e^(- i A t) ket(psi(0)) $

#pagebreak()

=== The circuit

#figure(
  image("assets/qlp_circuit.png", height: 80%),
  caption: [Circuit for Quantum Link Prediction @moutinho_2023],
)

=== The algorithm

- There are $n = log_2 N$ qubits ($q_n$) to serve as binary label to each node $N$ and an extra ancillary qubit $q_a$.
- The state evolves as:

#diagram(
  label-size: 0.7em,
  spacing: (7em, 5.8em),
  (
  node((0,0), outset: -150pt, width: 300pt, align(left, $ket(psi_j_0 (0)) = ket(0)_a ket(j)_n$)),
  edge((0.8,0), $H_q times.circle I_a$, "->"),
  node((1,0), outset:10pt, $ket(psi_j_1 (0)) = 1/sqrt(2) (ket(0) + ket(1))_a ket(j)_n$),
  edge($"CTQW"(t) = & ketbra(0, 0)_a (e^(-i A t))_n \ & + ketbra(1, 1)_a (e^(+i A t))_n$, "->", label-side: right),
  node((1,1), outset:10pt, $ket(psi_j_2 (0)) = & 1/sqrt(2) (ket(0)_a e^(-i A t) ket(j)_n \ & + ket(1)_a e^(+i A t) ket(j)_n)$)
  ),
  edge($H_q times.circle I_a$, "->"),
  node((0,1), $ket(psi_j_3 (0)) = & ket(0)_a ((e^(-i A t) + e^(+i A t))/2) ket(j)_n \ & + ket(1)_a ((e^(-i A t) - e^(+i A t))/2) ket(j)_n$)
)

#pagebreak()

The final state before measurement can be resolved as

$ ket(0)_a (sum_(k=0)^infinity c_"even" (k, t) A^(2k)) ket(j)_n & + i ket(1)_a (sum_(k=0)^infinity c_"odd" (k, t) A^(2k+1)) ket(j)_n $

where

$
  c_"even" (k, t) = ((-1)^k t^(2k))/(2k)! \
  c_"odd" (k, t) = ((-1)^(k+1) t^(2k+1))/(2k+1)!
$

#pagebreak()

=== Obtaining results

To obtain the relevant predictions from this state, we repeatedly sample as follows: First, we measure $q_1$ yielding $ket(0)$ or $ket(1)$, collapsing the rest of the qubits to either

$
  ket(psi (t))_n^"even" prop (sum_(k=0)^infinity c_"even" (k, t) A^(2k)) ket(j) quad "OR" quad ket(psi (t))_n^"odd" prop (sum_(k=0)^infinity c_"odd" (k, t) A^(2k+1)) ket(j)
$

Now when $q_n$ is measured, the probability of yielding binary string corresponding to node $i$ is

$
  p_(i j)^"even" prop mel(i, sum_(k=0)^infinity c_"even" (k, t) A^(2k), j) quad "OR" quad p_(i j)^"odd" prop mel(i, sum_(k=0)^infinity c_"odd" (k, t) A^(2k+1), j)
$

#pagebreak()

=== Disadvantages

The immediate cons of this approach are:

- A sample may correspond to an even or odd prediction, which can only be known after measurement of $q_a$. So this may result in a sampling overhead (based on the requirements) and unwanted predictions will have to be discarded.
- The sample may correspond to initial node itself or an already existing link, which also needs to be discarded, resulting in more overhead.

These overhead may not be significant depending upon the degree distribution of the network and the samples taken per node.

== Bibliography .
#bibliography("references.bib")

#focus-slide[#align(center)[Thank you! \ \ #text(size: 30pt, "Questions?")]]