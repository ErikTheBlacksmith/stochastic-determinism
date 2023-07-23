const RandomVariable = Dict{T, Real} where T

function rvOperate(f::Function, X::Dict, Y::Dict; K =keytype(X),V = valtype(X))
    out = Dict()
    for i in keys(X)
        mergewith!(+,out, reduce(mergewith(+), [Dict(f(i,j) => *(X[i],Y[j])) for j in keys(Y)]))
    end
    return out
end

function rvMap(X::Dict , D::Dict)
    out = Dict()
    for i in keys(X)
        mergewith!(+,out, Dict(keys(D[i]) .=> (values(D[i]) .* X[i])))
    end
    return out
end

function E(X::Dict) 
    return sum(keys(X) .* values(X))
end

function V(X::Dict)
    Expectation = E(X)
    return sum([(x-Expectation)^2*p for (x,p) in X])
end

function Base.:+(X::Dict, Y::Dict)
    rvOperate(+, X, Y)
end

function Base.:-(X::Dict, Y::Dict)
    rvOperate(-, X, Y)
end

function Base.:*(X::Dict, Y::Dict)
    rvOperate(*, X, Y)
end

function Base.:/(X::Dict, Y::Dict)
    rvOperate(/, X, Y)
end

function Base.://(X::Dict, Y::Dict)
    rvOperate(//, X, Y)
end

function rv(x::Number)
    return Dict(x=>1)
end

#make an n sided die
function duniform(vals, probs = -1)
    if probs == -1
        return Dict(vals .=> 1//length(vals))
    else
        return Dict(vals .=> probs)
    end
end

function binom(n::Int, p::Number)
    return Dict(0:n .=> [binomial(n,k)* p^k * (1-p)^(n-k) for k in 0:n])
end

function binom(n::Dict, p::Number; dict!::Dict = Dict())
    # create map of binomial(x∈n, p)
    for x in keys(n)
        if x ∉ keys(dict!)
            dict![x] = binom(x,p)
        end
    end
    return rvMap(n, dict!)
end

function binom(n::Int, p::Dict; dict!::Dict = Dict())
    # create map of binomial(n, y∈p)
    for y in keys(p)
        if y ∉ keys(dict!)
            dict![y] = binom(n,y)
        end
    end
    return rvMap(p, dict!)
end

function binom(n::Dict, p::Dict; dict!::Dict = Dict())
    # create map of binomial(x∈n, p)
    for x in keys(n), y in keys(p)
        if !haskey(dict!,(x,y))
            dict![(x,y)] = binom(x,y)
        end
    end
    return rvMap(rvOperate(tuple, n, p), dict!)
end

"stirlings factorial approximation"
str_appx(n) = sqrt(2*π*n)*(n/ℯ)^n

function poisson(λ::Number, vals = 0:100; fact_appx = false)
    if fact_appx
        return Dict(x=> exp(-λ) * λ^x / (x < 15 ? factorial(x) : str_appx(x)) for x in vals)
    else
        return Dict(x=> exp(-λ) * λ^x / factorial(big(x)) for x in vals)
    end
end    

function poisson(λ::Dict, vals = 0:100; fact_appx = false, dict!::Dict = Dict())
    # create map of poisson(x∈λ)
    for x ∈ keys(λ)
        if x ∉ keys(dict!)
            dict![x] = poisson(x,vals; fact_appx=fact_appx)
        end
    end
    return rvMap(λ, dict!)
end    

function compoundsumDict(X::Dict, max)
    out = Dict(0 => Dict(keytype(X)(0) => valtype(X)(1)), 1=> X)
    for i in 2:max
        out[i] = out[i-1]+X
    end
    return out
end

function compoundsum(N::Dict, Xi::Dict; dict!::Dict = Dict())
    # is potentially given dict! good?
    if haskey(dict!, minimum(keys(N))) && haskey(dict!, maximum(keys(N)))
        return rvMap(N, dict!)
    end

    # create map
    for n in 0:maximum(keys(N))
        if haskey(dict!, n)
            continue
        end

        # need to make key
        if n == 0
            dict![0] = Dict(0=>1)
        else
            dict![n] = dict![n-1] + Xi
        end
    end
    return rvMap(N, dict!)
end

const Σ = compoundsum

function plotrv(f, X::Dict, label= missing)
    k,v = zip(sort(collect(X))...) |> collect
    f(collect(k),collect(v), label=label)
end

