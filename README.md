Attempt for FP32-friendly approximation and evaluation of smooth nonlinear functions (e.g., tanh, sigmoid, GELU) using global or piecewise Chebyshev expansions and a Clenshaw-style recurrence.

## Overview

Motivated by the challenge of efficient inference on resource-constrained hardware, can we precompute compact approximations to smooth nonlinear functions $f : \mathbb{R} \to \mathbb{R}$ such as the ones present in neural network accelerators that maintain $\~10^{-7}$ accuracy on specified domains that we can evaluate in fp32 arithmetic with no operations more expensive than multiplication/addition.


This system automatically constructs optimal function approximations through two stages: Given a function $f$ and domain $[a,b]$, automatically selects between global and piecewise Chebyshev representations based on our cost. Then, we return a compact encoding  $\theta \in \mathbb{R}^B$ containing all approximation metadata and coefficients. Given $\theta$ and input $x$, selects the active polynomial piece and evaluates using Clenshaw recurrence, which is numerically stable and only requires multiplication/addition.

#### Files:
- `Fapprox.m` - Constructs global or piecewise Chebyshev approximations over a specified domain.
- `Rb_transform.m` - Encodes the selected Chebyshev representation into a flat parameter vector  $\theta \in \mathbb{R}^B$.
- `Feval.m` - Selects the active piece and applies a stable Clenshaw recurrence for evaluation.


## Usage

#### Requirements: 
MATLAB with Chebfun toolbox

```matlab
% Approximate tanh on [-5, 5] with tolerance 1e-8 in FP64
f = @(x) tanh(x);
p_best = Fapprox([-5, 5], f, 1e-8);

% Encode into compact representation
theta = Rb_transform(p_best);

% Evaluate at a point in FP32
x = single(2.3);
y = Feval(theta, x);
```

Run `test_pipeline.m` to reproduce all results.
