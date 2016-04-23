push!(LOAD_PATH, pwd())
println(LOAD_PATH)

#using GeneticAlgorithmSolver: GASolver, solve
include("genetic.jl")

const PROBLEMAN_SIZE = 10::Int64
const POPULATION_SIZE = 200::Int64

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

function fitness(solucao)
    distancia = 0

    for i in eachindex(solucao)
        for j = (i + 1):length(solucao)
            if solucao[i] == solucao[j] ||
                solucao[i] + (j - i) == solucao[j] ||
                solucao[i] - (j - i) == solucao[j]
                distancia += 1
            end
        end
    end

    return distancia
end

function newIndividual()
    return shuffle(collect(1:PROBLEMAN_SIZE))
end

solution = solve(POPULATION_SIZE, PROBLEMAN_SIZE, newIndividual, fitness, (metrics) -> metrics[1] == 0)
println("Solução")
println(solution)
imprimeSolucao(solution)
println(ehViavel(solution))
