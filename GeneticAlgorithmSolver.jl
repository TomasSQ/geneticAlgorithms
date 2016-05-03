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
    generation::Int
    singleCrossover::Bool
    mutateSwap::Bool
    newGene::Function
    canRepetedGene::Bool

    GASolver(populationSize, individualSize, newIndividual, ajust, fitness, mutateRate, reproduceRate, singleCrossover, mutateSwap, newGene, canRepetedGene) = new(
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
        singleCrossover,
        mutateSwap,
        newGene,
        canRepetedGene
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
        if rand() < solver.reproduceRate
            firstIndividual = tournament(solver)
            secondIndividual = tournament(solver)

            population[i, :] = solver.ajust(crossover(firstIndividual, secondIndividual, solver.mutateRate, solver))
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

function singleCrossover(a::AbstractArray, b::AbstractArray, mutateRate::Float64, solver::GASolver)
    child = Array{Float64}(length(a))
    point = randomIndex(a)
    if solver.canRepetedGene
        child = [sub(a, 1:point); sub(b, (point + 1):length(b))]
    else
        for i = 1:point
            child[i] = a[i]
        end
        added = point
        for i = (point + 1):length(b)
            if findfirst(child, b[i]) == 0
                child[i] = b[i]
                added += 1
            end
        end
        if added != length(a)
            for i = 1:length(b)
                if findfirst(child, b[i]) == 0
                    child[i] = b[i]
                    added += 1
                end
            end
        end
        if added != length(a)
            error("Something went wrong")
        end
    end

    return child
end

function doubleCrossover(a::AbstractArray, b::AbstractArray, mutateRate::Float64, solver::GASolver)
    child = Array{Float64}(length(a))
    point1 = randomIndex(a)
    point2 = randomIndex(a)
    startI = min(point1, point2)
    endI = max(point1, point2)
    for i = startI:endI
        child[i] = a[i]
    end
    for j = 1:length(b)
        if j < startI || j > endI
            if solver.canRepetedGene
                child[j] = b[j]
            else
                for i = 1:length(b)

                    if findfirst(child, b[i]) == 0
                        child[j] = b[i]
                    end
                end
            end
        end
    end

    return child
end

function crossover(a::AbstractArray, b::AbstractArray, mutateRate::Float64, solver::GASolver)
    child = Array{Float64}(length(a))
    if solver.singleCrossover
        child = singleCrossover(a, b, mutateRate, solver)
    else
        child = doubleCrossover(a, b, mutateRate, solver)
    end

    return mutate(child, mutateRate, solver)
end

function mutate(a::AbstractArray, mutateRate, solver::GASolver)
    if rand() < mutateRate
        for i = 1:randomIndex(a)
            if solver.mutateSwap
                point1 = randomIndex(a)
                point2 = randomIndex(a)
                aux = a[point1]
                a[point1] = a[point2]
                a[point2] = aux
            else
                a[i] = solver.newGene()
            end
        end
    end

    return a
end

function rank!(solver::GASolver)
    for i = 1:solver.populationSize
        solver.ranking[i] = Ranking(solver.fitness(solver.population[i, :]), i)
    end

    normalize!(solver)
end

function normalize!(solver::GASolver)
    sorted = sort(solver.ranking, by = (x) -> x.fitness, rev=true)

    values = getValues(solver)
    worstFit = maximum(values)
    bestFit = minimum(values)
    factor = (bestFit - worstFit) / (solver.populationSize - 1)

    for i = 1:solver.populationSize
        solver.ranking[i] = Ranking(worstFit + factor * (i - 1), sorted[i].index)
    end
end

function getFitnessest(solver::GASolver)
    min = Inf
    minI = 0
    for i = 1:solver.populationSize
        if solver.ranking[i].fitness < min
            min  = solver.ranking[i].fitness
            minI = solver.ranking[i].index
        end
    end

    return Ranking(min, minI)
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

function solve(populationSize::Int, individualSize::Int,
        newIndividual::Function, fitness::Function, shouldStop::Function,
        maxGeneration::Int, mutateRate::Float64=0.05, reproduceRate::Float64=0.95
        ;ajust::Function=(x) -> x, singleCrossover::Bool=true, mutateSwap::Bool=true, newGene::Function=()->1, canRepetedGene::Bool=true)
    solver = GASolver(populationSize, individualSize, newIndividual, ajust, fitness, mutateRate, reproduceRate,
        singleCrossover, mutateSwap, newGene, canRepetedGene)
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
