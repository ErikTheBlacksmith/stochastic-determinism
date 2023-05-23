using Symbolics

struct State
    value::Num
    prob::Num
end
Base.:isless(a::State,b::State) = (a.value<b.value)

struct RandomVariable
    states::Vector{State}
end

function rvSimplify(X::RandomVariable)
    states = X.states
    for i in eachindex(states)
        states[i] = State(states[i].value,simplify(states[i].prob))
    end
    return RandomVariable(states)
end

function rvSubstitute(X::RandomVariable,subDict::Dict)
    xStates = X.states
    for i in eachindex(xStates)
        xStates[i] = State(xStates[i].value, substitute(xStates[i].prob,subDict))
    end
    return RandomVariable(xStates)
end

"""
    reduceStates(v::Vector{State})

Inputs a vector of `State`s and outputs an "equivalent" sorted
`State` vector with combined probabilities.

**Example**
```jldoctest
julia> s = [State(1,1//4), State(2,1//4), State(1,1//2)]

julia> reduceStates(s)
2-element Vector{State}:
  State(1, 3//4)
  State(2, 1//4)
```
"""
function reduceStates(v::Vector{State})
    stateDict = Dict{Num, State}()
    for i in eachindex(v)
        if haskey(stateDict, v[i].value)
            stateDict[v[i].value] = stateOperate(returna,+,stateDict[v[i].value], v[i])
        else
            stateDict[v[i].value] = v[i]
        end
    end
    return sort(collect(values(stateDict)))
end

"should be just returning either of two identical variables"
returna(a,b) = return a

"""
    stateOperate(f::Function, g::Function, x::State, y::State)
performs f on the values of two `State`s and g on their probabilities
returns a new `State`

Used in `Isequal` to add probabilities and `rvOperate`
"""
function stateOperate(f::Function, g::Function, x::State, y::State)
    return State(f(x.value,y.value), g(x.prob,y.prob))
end

"""
    rvOperate(f::Function, X::RandomVariable, Y::RandomVariable)
performs a "tensor product" on the states of two random variables

**Examples:**\n
for some `X::RandomVariable`, `Y::RandomVariable`
```jldoctest
#Z = X+Y
julia> Z::RandomVariable = rvOperate(+,X,Y)

#Z = Y//X
julia> Z::RandomVariable = rvOperate(//,Y,X)
```
"""
function rvOperate(f::Function, X::RandomVariable, Y::RandomVariable)
    R = Array{State}(undef, length(X.states), length(Y.states))
    for i in eachindex(X.states), j in eachindex(Y.states)
        R[i,j] = stateOperate(f, *, X.states[i], Y.states[j])
    end
    return RandomVariable(reduceStates(vec(R)))
end

"calculates expected value for **discrete** `RandomVariable`"
function E(X::RandomVariable)
    return sum([state.value * state.prob for state in X.states])
end


#make an n sided die
function createDie(maxN , var)
    return RandomVariable([State(i,var[i]) for i in 1:maxN])
end

function createDieSub(maxN, range, var)
    numPossible = length(range)
    outDict = Dict()
    for i in 1:maxN
        if i in range
            outDict[var[i]] = 1//numPossible
        else
            outDict[var[i]] = 0
        end
    end
    return outDict
end

function createDieSub2(maxN, range, var)
    numPossible = length(range)
    outDict = Dict()
    for i in 1:maxN
        if i in range
            outDict[var[i]] = 1/numPossible
        else
            outDict[var[i]] = 0
        end
    end
    return outDict
end