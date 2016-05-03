push!(LOAD_PATH, string(pwd(), "/.."))

using GeneticAlgorithmSolver: GASolver, solve
using Plots

pyplot()

const WORLD_SIZE = 1000
const CITIES = 30
const PROBLEMAN_SIZE = CITIES::Int64
const POPULATION_SIZE = 200::Int64
const MAX_GENERATION = 100000::Int64
const EQUALS_GENERATIONS = 10000::Int64

type City
    lat::Float64
    long::Float64
end

cities = Array{City}(CITIES)
for i = 1:CITIES
    cities[i] = City(rand() * WORLD_SIZE, rand() * WORLD_SIZE)
end
#cities = [City(60, 200);City(180, 200);City(80, 180);City(140, 180);City(20, 160);City(100, 160);City(200, 160);City(140, 140);City(40, 120);City(100, 120);City(180, 100);City(60, 80);City(120, 80);City(180, 60);City(20, 40);City(100, 40);City(200, 40);City(20, 20);City(60, 20);City(160, 20);]

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
    plot(xs, ys)
    scatter!(xs, ys,markersize=6,c=:orange)
    png("tsp")
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

solved = solve(POPULATION_SIZE, PROBLEMAN_SIZE, newIndividual, fitness, shouldStop, MAX_GENERATION,
    singleCrossover=false, canRepetedGene=false)
println("Solução encontrada na geração ", solved[2])
println(solved[1])
imprimeSolucao(solved[1])
println(fitness(solved[1]))
println(ehViavel(solved[1]))

#imprimeSolucao([16.0,13.0,20.0,9.0,18.0,3.0,11.0,19.0,8.0,12.0,4.0,6.0,10.0,7.0,5.0,15.0,1.0,14.0,2.0,17.0])
