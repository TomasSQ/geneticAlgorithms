include("genetic.jl")

PROBLEMAN_SIZE = 10
POPULATION_SIZE = 200

function ehViavel(solucao)
    return fitness(solucao) == 0
end

function imprimeLinha(solucao)
    print("+")
    for coluna in eachindex(solucao)
        print("---+")
    end
    println("")
end

function imprimeSolucao(solucao)
    imprimeLinha(solucao)

    for linha in eachindex(solucao)
        print("|")
        for coluna in eachindex(solucao)
            print(" ")
            if coluna == solucao[linha]
                print("x")
            else
                print(" ")
            end
            print(" |")
        end
        println("")
        imprimeLinha(solucao)
    end
    println("")
end

solved = solve(POPULATION_SIZE, () -> zeros(Int8, POPULATION_SIZE, PROBLEMAN_SIZE), () -> shuffle(collect(1:PROBLEMAN_SIZE)))
println("Solução")
println(solved.solution)
imprimeSolucao(solved.solution)
println(ehViavel(solved.solution))
