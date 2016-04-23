push!(LOAD_PATH, string(pwd(), "/.."))

using GeneticAlgorithmSolver: GASolver, solve

const PROBLEMAN_SIZE = 8::Int64
const MAX_GENERATION = 10000::Int64

type Cidade
    x::Int64
    y::Int64
end

function ehViavel(solucao)
    return fitness(solucao) < 1000
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

solved = solve(POPULATION_SIZE, PROBLEMAN_SIZE, newIndividual, fitness, (metrics) -> metrics[1] == 0, MAX_GENERATION)
println("Solução encontrada na geração ", solved[2])
println(solved[1])
imprimeSolucao(solved[1])
println(ehViavel(solved[1]))
