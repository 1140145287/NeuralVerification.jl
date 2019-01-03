"""
    Certify(optimizer)

Certify uses semidefinite programming to compute over-approximated certificates for a neural network with only one hidden layer.

# Problem requirement
1. Network: one hidden layer, any activation that is differentiable almost everywhere whose derivative is bound by 0 and 1
2. Input: hypercube
3. Output: halfspace

# Return
`BasicResult`

# Method
Semindefinite programming.
Default `optimizer` is `SCSSolver()`.

# Property
Sound but not complete.

# Reference
A. Raghunathan, J. Steinhardt, and P. Liang,
"Certified Defenses against Adversarial Examples,"
*ArXiv Preprint ArXiv:1801.09344*, 2018.
"""
@with_kw struct Certify{O<:AbstractMathProgSolver}
    optimizer::O  = SCSSolver()
end

# can pass keyword args to optimizer
# Certify(optimizer::DataType = SCSSolver; kwargs...) =  Certify(optimizer(;kwargs...))

function solve(solver::Certify, problem::Problem)
    @assert length(problem.network.layers) == 2 "Network should only contain one hidden layer!"
    model = Model(solver = solver.optimizer)
    c, d = tosimplehrep(problem.output)
    v = c * problem.network.layers[2].weights
    W = problem.network.layers[1].weights
    M = get_M(v[1, :], W)
    n = size(M, 1)
    @variable(model, P[1:n, 1:n], SDP)
    # Compute value
    Tr = M * P
    output = c * compute_output(problem.network, problem.input.center) .- d[1]
    epsilon = problem.input.radius[1]
    o = output + epsilon/4 * sum(Tr[i, i] for i in 1:n)
    # Specify problem
    @constraint(model, diag(P) .<= ones(n))
    @objective(model, Max, o[1])
    status = solve(model, suppress_warnings = true)
    return interpret_result(solver, status, o[1])
end

# True if o < 0
# Undertermined if otherwise
function interpret_result(solver::Certify, status, o)
    # println("Upper bound: ", getvalue(o[1]))
    if getvalue(o) <= 0
        return BasicResult(:SAT)
    else
        return BasicResult(:Unknown)
    end
end

# M is used in the semidefinite program
function get_M(v::Vector{Float64}, W::Matrix{Float64})
    m = W' * Diagonal(v)
    mxs, mys = size(m)
    o = ones(size(W, 2), 1)
    # TODO Mrow2 and Mrow3 look suspicious (dims don't match in the general case).
    Mrow1 = [zeros(1, 1+mxs)    o'*m]
    Mrow2 = [zeros(mxs, 1+mxs)     m]
    Mrow3 = [m'*o  m' zeros(mys, mys)]

    M = [Mrow1; Mrow2; Mrow3]
    return M
end


