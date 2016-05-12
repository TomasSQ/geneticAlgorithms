push!(LOAD_PATH, string(pwd(), "/.."))

using GeneticAlgorithmSolver: GASolver, solve

const INDIVIDUAL_SIZE = 33
const KNAPSACK_CAPACITY = 500
const POPULATION_SIZE = 10
const MAX_GENERATION = 100000
const EQUALS_GENERATIONS = 10000

type Item
    id::Int
    name::AbstractString
    volume::Float64
    value::Float64
    Item(item::Tuple{Int64,ASCIIString,Float64,Float64}) = new(item[1], item[2], item[3], item[4])
    Item(item::Tuple{Int64,ASCIIString,Int,Int}) = new(item[1], item[2], item[3], item[4])
    Item(item::Tuple{Int64,ASCIIString,Float64,Int}) = new(item[1], item[2], item[3], item[4])
end

array = [(1, "Arroz", 5, 6); (2, "Feijao", 1, 6); (3, "Panela", 2, 1); (4, "Macarrao", 0.5, 4); (5, "Fosforo", 0.1, 2);
         (6, "Faca", 0.1, 3); (7, "Garfo", 0.1, 1); (8, "Colher", 0.1, 2);
         (9, "Colchao", 10, 10); (10, "Colchao inflavel", 2, 10); (11, "enchedor", 1, 1);
         (12, "Barraca", 7, 15); (13, "Barraca grande", 15, 7); (14, "Isolante termico", 1, 5);
         (15, "Protetor solar", 0.3, 3); (16, "Repelente", 0.1, 3); (17, "Sabonete", 0.01, 1);
         (18, "Casaco", 1, 5); (19, "Camisa", 0.5, 6); (20, "Meias", 0.5, 3); (21, "Intima", 0.5, 3); (22, "Saia", 0.5, 1); (23, "Vestido", 0.5, 1);
         (24, "Chocolate", 0.3, 1); (25, "Tenis", 0.5, 10); (26, "Tenis extra", 0.5, 3); (27, "Sapatilha", 0.3, 1);
         (28, "Escova de dente", 0.5, 1); (29, "Papel higienico", 0.5, 2); (30, "Celular", 0.5, 1);
         (31, "Bussula", 0.1, 6); (32, "Toalha", 1, 2); (33, "Roupa de cama", 6, 3)]
valuesSum = 0.0::Float64
itens = Array{Item}(INDIVIDUAL_SIZE)
for i in eachindex(array)
    itens[i] = Item(array[i])
    valuesSum += itens[i].value
end

associations = zeros(INDIVIDUAL_SIZE, INDIVIDUAL_SIZE)
associations[1, 1] = 5
associations[1, 2] = 10
associations[1, 4] = -2
associations[1, 7] = 2
associations[2, 3] = 5
associations[2, 7] = 2
associations[2, 8] = 2
associations[3, 4] = 5
maxBenefit = 10 

valuesSum += maxBenefit * INDIVIDUAL_SIZE

function fitness(solucao)
    volume = 0.0::Float64
    value = valuesSum::Float64
    used = []
    for i in eachindex(solucao)
        if solucao[i] == 1
            volume += itens[i].volume
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

    return volume > KNAPSACK_CAPACITY ? valuesSum + volume : value
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
            total.volume += itens[i].volume
            print(round(Int, i), " ")
        end
    end
    println()
    println("Total value: ", total.value)
    println("Total volume: ", total.volume)
    println("Allowed volume: ", KNAPSACK_CAPACITY)
end

function knapsack()
    solved = solve(POPULATION_SIZE, INDIVIDUAL_SIZE, newIndividual, fitness, shouldStop, MAX_GENERATION, 0.05)
    println("Solução encontrada na geração ", solved[2])
    imprimeSolucao(solved[1])
end
knapsack()
