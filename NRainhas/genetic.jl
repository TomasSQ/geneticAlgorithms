#module GeneticAlgorithmSolver
#export GASolver, solve

type Ranking
    fitness::Float64
    index::Int32
end

type GASolver
    emptyPopulation::Function
    newIndividual::Function
    fitness::Function
    mutateRate::Float64
    reproduceRate::Float64
    population::AbstractArray{Float64,2}
    ranking::AbstractArray{Ranking}
    solution::AbstractVector{Float64}

    GASolver(emptyPopulation, newIndividual, fitness, mutateRate, reproduceRate) = (
        solver = new();
        solver.emptyPopulation = emptyPopulation;
        solver.newIndividual = newIndividual;
        solver.fitness = fitness;
        solver.mutateRate = mutateRate;
        solver.reproduceRate = reproduceRate;
        solver.population = emptyPopulation();
        solver.ranking = Array{Ranking}(size(solver.population, 1));
        solver.solution = zeros(Float64, size(solver.population, 1));
        solver
    )
end

solver = "UNDEFINED"

function generateFirstPopulation(solver::GASolver)
    for i = 1:size(solver.population, 1)
        solver.population[i, :] = solver.newIndividual()
    end

    solver.population
end

function generateNewPopulation(solver::GASolver)
    population = solver.emptyPopulation()
    for i = 1:size(solver.ranking, 1)
        if i % 2 == 0
            continue
        end

        firstIndividual = solver.ranking[i].index
        secondIndividual = solver.ranking[i + 1].index

        if rand() > solver.reproduceRate
            newIndividuals = reproduce(solver.population[firstIndividual, :], solver.population[secondIndividual, :])
            population[firstIndividual, :] = newIndividuals[1]
            population[secondIndividual, :] = newIndividuals[2]
        else
            population[firstIndividual, :] = shuffle(collect(1:size(solver.population, 2)))
            population[secondIndividual, :] = shuffle(collect(1:size(solver.population, 2)))
        end
    end

    solver.population = population
end

function randomIndex(a)
    return round(Int, rand() * (length(a) - 1) + 1)
end

function reproduce(a, b)
    point = randomIndex(a)
    return mutate([sub(a, 1:point); sub(b, (point + 1):length(b))], [sub(b, 1:point); sub(a, (point + 1):length(a))])
end

function mutate(a, b)
    return (mutate(a), mutate(b))
end

function mutate(a)
    if rand() > 0.80
        point1 = randomIndex(a)
        point2 = randomIndex(a)
        aux = a[point1]
        a[point1] = a[point2]
        a[point2] = aux
    end

    return a
end

function rank(solver::GASolver)
    populationSize = size(solver.population, 1)

    for i in 1:populationSize
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

function solve(populationSize, emptyPopulation, newIndividual, fitness, shouldStop)
    solver = GASolver(emptyPopulation, newIndividual, fitness, 0.8, 0.2)
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
