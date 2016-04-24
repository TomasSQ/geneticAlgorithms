module GeneticAlgorithmSolver
export solve

const DEBUG = true

type Ranking
    fitness::Float64
    index::Int32
end

type GASolver
    populationSize::Int32
    individualSize::Int32
    newIndividual::Function
    ajust::Function
    fitness::Function
    mutateRate::Float64
    reproduceRate::Float64
    population::AbstractArray{Float64,2}
    ranking::AbstractArray{Ranking}
    solution::AbstractVector{Float64}
    generation::Int64
    maximization::Bool

    GASolver(populationSize, individualSize, newIndividual, ajust, fitness, mutateRate, reproduceRate, maximization) = new(
        populationSize,
        individualSize,
        newIndividual,
        ajust,
        fitness,
        mutateRate,
        reproduceRate,
        Array{Float64,2}(populationSize, individualSize),
        Array{Ranking}(populationSize),
        Array{Float64}(individualSize),
        0,
        maximization
    )
end

function generateFirstPopulation!(solver::GASolver)
    for i = 1:solver.populationSize
        solver.population[i, :] = solver.newIndividual()
    end

    solver.population
end

function generateNewPopulation!(solver::GASolver)
    population = Array{Float64}(solver.populationSize, solver.individualSize)

    population[1, :] = solver.population[getFitnessest(solver).index, :]

    for i = 2:solver.populationSize
        if rand() > solver.reproduceRate
            firstIndividual = tournament(solver)
            secondIndividual = tournament(solver)

            population[i, :] = solver.ajust(crossover(firstIndividual, secondIndividual, solver.mutateRate))
        else
            population[i, :] = solver.newIndividual()
        end
    end

    solver.population = population
end

function tournament(solver::GASolver)
    values = getValues(solver)
    randValue = rand() * sum(values)::Float64
    sumFitness = 0.0
    for i = 1:solver.populationSize
        sumFitness += values[i]

        if randValue <= sumFitness
            return solver.population[i, :]
        end
    end
end

function randomIndex(a::AbstractArray)
    return round(Int, rand() * (length(a) - 1) + 1)
end

function crossover(a::AbstractArray, b::AbstractArray, mutateRate::Float64)
    point = randomIndex(a)
    return mutate([sub(a, 1:point); sub(b, (point + 1):length(b))], mutateRate)
end

function mutate(a::AbstractArray, mutateRate)
    if rand() > mutateRate
        for i = 1:randomIndex(a)
            point1 = randomIndex(a)
            point2 = randomIndex(a)
            aux = a[point1]
            a[point1] = a[point2]
            a[point2] = aux
        end
    end

    return a
end

function rank!(solver::GASolver)
    for i = 1:solver.populationSize
        solver.ranking[i] = Ranking(solver.fitness(solver.population[i, :]), i)
    end

    #normalize!(solver)
end

function normalize!(solver::GASolver)
    sorted = sort(solver.ranking, by = (x) -> x.fitness, rev=!solver.maximization)

    values = getValues(solver)
    min = solver.maximization ? minimum(values) : maximum(values)
    max = solver.maximization ? maximum(values) : minimum(values)
    factor = (max - min) / (solver.populationSize - 1)

    for i = 1:solver.populationSize
        solver.ranking[i] = Ranking(min + factor * (i - 1), sorted[i].index)
    end
end

function getFitnessest(solver::GASolver)
    max = -Inf
    maxI = 0
    min = Inf
    minI = 0
    for i = 1:solver.populationSize
        if solver.ranking[i].fitness > max
            max = solver.ranking[i].fitness
            maxI = solver.ranking[i].index
        end
        if solver.ranking[i].fitness < min
            min  = solver.ranking[i].fitness
            minI = solver.ranking[i].index
        end
    end

    return solver.maximization ? Ranking(max, maxI) : Ranking(min, minI)
end

function getValues(solver::GASolver)
    values = Array{Float64}(length(solver.ranking))
    for i in eachindex(values)
        values[i] = solver.ranking[i].fitness
    end

    return values
end

function metrics(solver::GASolver)
    metrics = zeros(Float64, 3)
    values = getValues(solver)

    metrics[1] = minimum(values)
    metrics[2] = maximum(values)
    metrics[3] = mean(values)

    return metrics
end

function solve(populationSize::Int64, individualSize::Int64, newIndividual::Function, ajust::Function, fitness::Function, shouldStop::Function, maxGeneration::Int64, maximization::Bool)
    solver = GASolver(populationSize, individualSize, newIndividual, ajust, fitness, 0.2, 0.9, maximization)
    generateFirstPopulation!(solver)

    while solver.generation != maxGeneration
        solver.generation += 1
        rank!(solver)
        m = metrics(solver)
        if shouldStop(metrics(solver))
            if DEBUG
                println("Geração: ", solver.generation, " min ", m[1], " max ", m[2], " avg ", m[3])
            end
            break
        end

        if solver.generation % 10 == 0 && DEBUG
            println("Geração: ", solver.generation, " min ", m[1], " max ", m[2], " avg ", m[3])
        end
        generateNewPopulation!(solver)
    end

    println(getFitnessest(solver).fitness)
    println(getFitnessest(solver).index)
    println(solver.fitness(solver.population[getFitnessest(solver).index, :]))
    solver.solution = collect(solver.population[getFitnessest(solver).index, :])
    return (solver.solution, solver.generation)
end

end
