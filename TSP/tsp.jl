push!(LOAD_PATH, string(pwd(), "/.."))

using GeneticAlgorithmSolver: GASolver, solve

include("plotter.jl")

const WORLD_SIZE = 200
const CITIES = 20
const PROBLEMAN_SIZE = CITIES::Int
const POPULATION_SIZE = 200::Int
const MAX_GENERATION = 1000::Int
const EQUALS_GENERATIONS = 10000::Int

type City
    lat::Float64
    long::Float64
end

#cities = Array{City}(CITIES)
#for i = 1:CITIES
#    cities[i] = City(rand() * WORLD_SIZE, rand() * WORLD_SIZE)
#end
cities = [City(60, 200) City(180, 200) City(80, 180) City(140, 180) City(20, 160) City(100, 160) City(200, 160) City(140, 140) City(40, 120) City(100, 120) City(180, 100) City(60, 80) City(120, 80) City(180, 60) City(20, 40) City(100, 40) City(200, 40) City(20, 20) City(60, 20) City(160, 20)]
println(cities)

function imprimeSolucao(solucao)
    xs = Array{Float64}(length(solucao) + 1)
    ys = Array{Float64}(length(solucao) + 1)
    for i = 1:length(solucao)
        city = cities[round(Int, solucao[i])]
        ys[i] = city.long
        xs[i] = city.lat
    end
    city = cities[round(Int, solucao[1])]
    ys[end] = city.long
    xs[end] = city.lat
    println(xs)
    println(ys)
    draw(xs, ys, "tsp.png")
end

function ehViavel(solucao)
    return fitness(solucao) < WORLD_SIZE ^ 2
end

function distance(c1::City, c2::City)
    d = sqrt((c1.lat - c2.lat) ^ 2 + (c1.long - c2.long) ^ 2)

    return d == 0 ? error("This was not supposed to happen") : d
end

function fitness(solucao)
    d = 0

    for i = 1:length(solucao)
        city1 = cities[round(Int, solucao[i])]
        if i == length(solucao)
        	city2 = cities[round(Int, solucao[1])]
        else
            city2 = cities[round(Int, solucao[i + 1])]
        end

        d += distance(city1, city2)
    end

    return 1/d
end

function newIndividual()
    return shuffle(collect(1:PROBLEMAN_SIZE))
end

metrics = []

function shouldStop(m)
    if length(metrics) != EQUALS_GENERATIONS
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
    #ajusted = Array{Float64}(length(route))
    #allCities = collect(1:length(route))
    #notVisitedCities = setdiff(allCities, route)
    #visitedCities = []

    #for i = 1:length(route)
    #    city = route[i]
    #    if findfirst(visitedCities, city) != 0
    #        city = splice!(notVisitedCities, 1)
    #    end
    #    append!(visitedCities, [city])

    #    ajusted[i] = city
    #end

    return route
end

solved = solve(POPULATION_SIZE, PROBLEMAN_SIZE, newIndividual, ajust, fitness, shouldStop, MAX_GENERATION, false)
println("Solução encontrada na geração ", solved[2])
println(solved[1])
imprimeSolucao(solved[1])
println(1/fitness(solved[1]))
println(fitness(solved[1]))
println(ehViavel(solved[1]))

#imprimeSolucao([16.0,13.0,20.0,9.0,18.0,3.0,11.0,19.0,8.0,12.0,4.0,6.0,10.0,7.0,5.0,15.0,1.0,14.0,2.0,17.0])
