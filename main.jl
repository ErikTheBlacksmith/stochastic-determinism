include("functions.jl")
using Symbolics
@variables p[1:20]

function main(r)
    X = createDie(20, p)
    Y = createDie(20, p)
    for i in 2:r
        Y = rvOperate(+,X,Y)
        print(i)
    end
    return Y
end