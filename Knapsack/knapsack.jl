push!(LOAD_PATH, string(pwd(), "/.."))

using GeneticAlgorithmSolver: GASolver, solve

const INDIVIDUAL_SIZE = 150
const KNAPSACK_CAPACITY = 500
const POPULATION_SIZE = 10
const MAX_GENERATION = 100000
const EQUALS_GENERATIONS = 10000

type Item
    weight::Float64
    value::Float64
end

itens = Array{Item}(INDIVIDUAL_SIZE)
itens[1] = Item(2, 3)
itens[2] = Item(3, 4)
itens[3] = Item(4, 5)
itens[4] = Item(5, 8)
itens[5] = Item(9, 10)
valuesSum = 0.0::Float64
for i in eachindex(itens)
    itens[i] = Item(round(Int, rand() * 10), round(Int, rand() * 100))
    valuesSum += itens[i].value
end

associations = Array{Float64, 2}(INDIVIDUAL_SIZE, INDIVIDUAL_SIZE)
maxBenefit = 0.0
for i in 1:INDIVIDUAL_SIZE
    for j in 1:INDIVIDUAL_SIZE
        if i != j && rand() < 0.5
            associations[i, j] = 5.0 - rand() * 10.0
            if associations[i, j] > maxBenefit
                maxBenefit = associations[i, j]
            end
        else
            associations[i, j] = 0.0::Float64
        end
    end
end

valuesSum += maxBenefit * INDIVIDUAL_SIZE

function fitness(solucao)
    weight = 0.0::Float64
    value = valuesSum::Float64
    used = []
    for i in eachindex(solucao)
        if solucao[i] == 1
            weight += itens[i].weight
            value -= itens[i].value
            push!(used, i)
        end
    end

    for i in eachindex(used)
        for j in eachindex(used)
            if i != j
                value += associations[i, j]
            end
        end
    end

    return weight > KNAPSACK_CAPACITY ? valuesSum + weight : value
end

function newIndividual()
    return shuffle(round(rand(INDIVIDUAL_SIZE)))
end

metrics = []
function shouldStop(m)
    if length(metrics) != EQUALS_GENERATIONS
        push!(metrics, round(Int, m[1]))
    else
        metrics[indmax(metrics)] = round(m[1])
        if round(Int, mean(metrics)) == round(Int, m[1])
            return true
        end
    end
    return false
end

function imprimeSolucao(solucao)
    total = Item(0.0, 0.0)
    print("Itens: ")
    for i in eachindex(solucao)
        if solucao[i] == 1
            total.value += itens[i].value
            total.weight += itens[i].weight
            print(round(Int, i), " ")
        end
    end
    println()
    println("Total value: ", total.value)
    println("Total weight: ", total.weight)
    println("Allowed weight: ", KNAPSACK_CAPACITY)
end

function knapsack()
    solved = solve(POPULATION_SIZE, INDIVIDUAL_SIZE, newIndividual, fitness, shouldStop, MAX_GENERATION, 0.05)
    println("Solução encontrada na geração ", solved[2])
    imprimeSolucao(solved[1])
end
knapsack()
