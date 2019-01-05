# NeuralVerification.jl

This library contains implementations of various methods to soundly verify deep neural networks.
In general, we verify whether a neural network satisfies certain input-output constraints.
The verification methods are divided into five categories:
* *Reachability methods:*
[ExactReach](https://arxiv.org/abs/1712.08163),
[MaxSens](https://arxiv.org/abs/1708.03322),
[Ai2](https://ieeexplore.ieee.org/document/8418593),

* *Primal optimization methods:*
[NSVerify](https://arxiv.org/abs/1706.07351),
[MIPVerify](https://arxiv.org/abs/1711.07356),
[ILP](https://arxiv.org/abs/1605.07262)

* *Dual optimization methods:*
[Duality](https://arxiv.org/abs/1803.06567),
[ConvDual](https://arxiv.org/abs/1711.00851),
[Certify](https://arxiv.org/abs/1801.09344)

* *Search and reachability methods:*
[ReluVal](https://arxiv.org/abs/1804.10829),
[DLV](https://arxiv.org/abs/1610.06940),
[FastLin](https://arxiv.org/abs/1804.09699),
[FastLip](https://arxiv.org/abs/1804.09699)

* *Search and optimization methods:*
[Sherlock](https://arxiv.org/abs/1709.09130),
[BaB](https://arxiv.org/abs/1711.00455),
[Planet](https://arxiv.org/abs/1705.01320),
[Reluplex](https://arxiv.org/abs/1702.01135)


## Installation
To download this library, clone it from the julia package manager like so:
```julia
(v1.0) pkg> add https://github.com/sisl/NeuralVerification.jl
```

Please note that the implementations of the algorithms are pedagogical in nature, and so may not perform optimally.
Derivation and discussion of these algorithms is presented in _link to paper_.

*Note:* At present, `Ai2`, `ExactReach`, and `Duality` do not work in higher dimensions (e.g. image classification).
This is being addressed in [#9](https://github.com/sisl/NeuralVerification.jl/issues/9)

The implementations run in Julia 1.0.

## Example Usage
### Choose a solver
```julia
using NeuralVerification

solver = BaB()
```
### Set up the problem
```julia
nnet = read_nnet("examples/networks/small_nnet.nnet")
input_set  = Hyperrectangle(low = [-1.0], high = [1.0])
output_set = Hyperrectangle(low = [-1.0], high = [70.0])
problem = Problem(nnet, input_set, output_set)
```
### Solve
```julia
julia> result = solve(solver, problem)
CounterExampleResult(:UNSAT, [1.0])

julia> result.status
:UNSAT
```

For a full list of `Solvers` and their properties, requirements, and `Result` types, please refer to the documentation.