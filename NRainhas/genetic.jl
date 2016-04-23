#module GeneticAlgorithmSolver
#export GASolver, solve

type Ranking
    fitness::Float64
    index::Int32
end

type GASolver
    populationSize::Int32
    individualSize::Int32
    newIndividual::Function
    fitness::Function
    mutateRate::Float64
    reproduceRate::Float64
    population::AbstractArray{Float64,2}
    ranking::AbstractArray{Ranking}
    solution::AbstractVector{Float64}

    GASolver(populationSize, individualSize, newIndividual, fitness, mutateRate, reproduceRate) = new(
        populationSize,
        individualSize,
        newIndividual,
        fitness,
        mutateRate,
        reproduceRate,
        Array{Float64,2}(populationSize, individualSize),
        Array{Ranking}(populationSize),
        Array{Float64}(individualSize)
    )
end

function generateFirstPopulation(solver::GASolver)
    for i = 1:solver.populationSize
        solver.population[i, :] = solver.newIndividual()
    end

    solver.population
end

function generateNewPopulation(solver::GASolver)
    population = solver.population

    for i = 1:solver.populationSize
        if i % 2 == 0
            continue
        end

        firstIndividual = solver.ranking[i].index
        secondIndividual = solver.ranking[i + 1].index

        if rand() > solver.reproduceRate
            newIndividuals = reproduce(solver.population[firstIndividual, :], solver.population[secondIndividual, :], solver.mutateRate)
            population[firstIndividual, :] = newIndividuals[1]
            population[secondIndividual, :] = newIndividuals[2]
        else
            population[firstIndividual, :] = shuffle(collect(1:size(solver.population, 2)))
            population[secondIndividual, :] = shuffle(collect(1:size(solver.population, 2)))
        end
    end

    solver.population = population
end

function randomIndex(a::AbstractArray)
    return round(Int, rand() * (length(a) - 1) + 1)
end

function reproduce(a::AbstractArray, b::AbstractArray, mutateRate::Float64)
    point = randomIndex(a)
    return mutate([sub(a, 1:point); sub(b, (point + 1):length(b))], [sub(b, 1:point); sub(a, (point + 1):length(a))], mutateRate)
end

function mutate(a::AbstractArray, b::AbstractArray, mutateRate::Float64)
    return (mutate(a, mutateRate), mutate(b, mutateRate))
end

function mutate(a::AbstractArray, mutateRate)
    if rand() > mutateRate
        point1 = randomIndex(a)
        point2 = randomIndex(a)
        aux = a[point1]
        a[point1] = a[point2]
        a[point2] = aux
    end

    return a
end

function rank(solver::GASolver)
    for i = 1:solver.populationSize
        solver.ranking[i] = Ranking(fitness(solver.population[i, :]), i)
    end

    solver.ranking = sort(solver.ranking, by = x -> x.fitness)
end

function metrics(solver::GASolver)
    metrics = zeros(Float64, 3)
    values = Array{Float64}(length(solver.ranking))
    for i in eachindex(values)
        values[i] = solver.ranking[i].fitness
    end

    metrics[1] = minimum(values)
    metrics[2] = maximum(values)
    metrics[3] = mean(values)

    return metrics
end

function solve(populationSize::Int64, individualSize::Int64, newIndividual::Function, fitness::Function, shouldStop::Function)
    solver = GASolver(populationSize, individualSize, newIndividual, fitness, 0.8, 0.2)
    generation = 0
    generateFirstPopulation(solver)

    while generation != 1000000
        generation += 1
        solver.ranking = rank(solver)

        if shouldStop(metrics(solver))
            println("Geração: ", generation, " ", solver.ranking[1].fitness)
            break
        end
        if generation % 10 == 0
            println("Geração: ", generation, " ", solver.ranking[1].fitness)
        end
        solver.population = generateNewPopulation(solver)
    end

    solver.solution = collect(solver.population[solver.ranking[1].index, :])

    return solver.solution
end

#end
