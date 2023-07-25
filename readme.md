# Stochastic Determinism v2

A proof of concept for stochastic models without the need for Monte Carlo methods.

This is meant to function very simply as an extension of the julia language, giving Dictionaries an extra utility: as random variables.

There are no dependancies, although having Plots.jl might be useful if you want to plot your random variables.

to define a random variable, simply create a dictionary with the keys and values as states and probabilities like so:
```Julia
X = Dict(i => 1//6 for i in 1:6) 
```

This is a six sided die! There are more utility functions later which make Things like this easier.
```Julia
import("sdfunctions.jl")
```

Let's create another random variable, Y, and give it fair values one to ten instead
```Julia
Y = Dict(i => 1//10 for i in 1:10) 
```

Obviously, you can operate on random variables,
```Julia
X + Y
X - Y
Y - X
X * Y
X / Y
# etc etc
# these are all overhead for the function rvOperate(op, X, Y)
```

I should note that if you wanted to for example add two to X,
```Julia
Z = X + 2 # wrong
Z = X + rv(2) # correct, converts 1 into Dict(2 => 1)
```

And furthermore you can find the expected values and variance of any random variable
```Julia
E(Z) # 11//2
V(Z) # 35//12
E(Y + rv(1)) == E(Y) + 1 # true
V(Y + rv(1)) == V(Y) + 1 # false
```

Now what if we wanted something like rolling a n-sided die where n is determined by a die? Since you can't have dictionaries as states, we do the following
```Julia
X - Dict(i => 1//6 for i in 1:6) 
M = Dict(i => Dict(j => 1//j for j in 1:i) for i in 1:6)
# 1 => {1 => 1}
# 2 => {1 => 1//2, 2 => 1//2}
# 3 => {1 => 1//3, 2 => 1//3, 3 => 1//3}
# etc

# so now we have we have the base probabilites and the random variables to map the outcomes of X to

Y = rvMap(X, M)
```

I have added the following functions, some of which can have random variables as parameters
```Julia
duniform(iterable) # discrete uniform [duniform(1:6) is a die]
binom(n,p) # both n and p can be rv
poisson(λ, vals) # λ can be an rv
compound sum(N, Xi) # both are rv, Σ(from i=1->N) (Xi)
```

Lastly I have added a way to plot rv, abiet not the best
```Julia
import Plots
plotrv(Plots.bar, Z, "Z")
```

That's about it, please feel free to use or add to it under the license. I have more plans for this as need be.
