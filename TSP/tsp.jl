push!(LOAD_PATH, string(pwd(), "/.."))

using GeneticAlgorithmSolver: GASolver, solve

const WORLD_SIZE = 10000
const CITIES = 20
const PROBLEMAN_SIZE = CITIES::Int64
const POPULATION_SIZE = 100::Int64
const MAX_GENERATION = 50000::Int64

type City
    lat::Float64
    long::Float64
end

cities = Array{City}(CITIES)
for i = 1:CITIES
    cities[i] = City(rand() * WORLD_SIZE, rand() * WORLD_SIZE)
end

function imprimeSolucao(solucao)
end

function ehViavel(solucao)
    return fitness(solucao) < 1000
end

function distance(c1::City, c2::City)
    d = sqrt((c1.lat - c2.lat) ^ 2 + (c1.long - c2.long) ^ 2)
    return d == 0 ? error("This was not supposed to happen") : d
end

function fitness(solucao)
    d = 0

    for i in eachindex(solucao)
        city1 = cities[round(Int, solucao[i])]
        city2 = cities[round(Int, solucao[1])]
        if i < length(solucao)
            city2 = cities[round(Int, solucao[i + 1])]
        end
        d += distance(city1, city2)
    end

    return d
end

function newIndividual()
    return shuffle(collect(1:PROBLEMAN_SIZE))
end

metrics = []

function shouldStop(m)
    if length(metrics) != 10000
        push!(metrics, m[1])
    else
        metrics[indmax(metrics)] = m[1]
        if round(Int, mean(metrics)) == round(Int, m[1])
            return true
        end
    end
    return false
end

function ajust(route)
    ajusted = Array{Float64}(length(route))
    allCities = collect(1:length(route))
    notVisitedCities = setdiff(allCities, route)
    visitedCities = []

    for i = 1:length(route)
        city = route[i]
        if findfirst(visitedCities, city) != 0
            city = splice!(notVisitedCities, 1)
        end
        append!(visitedCities, [city])

        ajusted[i] = city
    end

    return ajusted
end

solved = solve(POPULATION_SIZE, PROBLEMAN_SIZE, newIndividual, ajust, fitness, shouldStop, MAX_GENERATION, false)
println("Solução encontrada na geração ", solved[2])
println(solved[1])
imprimeSolucao(solved[1])
println(fitness(solved[1]))
println(ehViavel(solved[1]))
