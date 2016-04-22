type GASolver
    emptyPopulation
    newIndividual
    fitness
    mutateRate
    reproduceRate
    population
    ranking
    solution
end

function generateFirstPopulation(emptyPopulation, newIndividual)
    population = emptyPopulation()
    for i = 1:size(population, 1)
        population[i, :] = newIndividual()
    end

    return population
end

function generateNewPopulation(emptyPopulation, oldPopulation, ranking)
    population = emptyPopulation()
    for i = 1:size(ranking, 1)
        if i % 2 == 0
            continue
        end
        firstIndividual = ranking[i, 2]
        secondIndividual = ranking[i + 1, 2]

        if rand() > 0.15
            newIndividuals = reproduce(oldPopulation[firstIndividual, :], oldPopulation[secondIndividual, :])
            population[firstIndividual, :] = newIndividuals[1]
            population[secondIndividual, :] = newIndividuals[2]
        else
            population[firstIndividual, :] = shuffle(collect(1:size(oldPopulation, 2)))
            population[secondIndividual, :] = shuffle(collect(1:size(oldPopulation, 2)))
        end
    end

    return population
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

function rank(population)
    populationSize = size(population, 1)
    ranking = zeros(Int32, populationSize, 2)

    for i in 1:populationSize
        ranking[i, :] = [fitness(population[i, :]), i]
    end

    return sortrows(ranking)
end

function foundSolution(ranking)
    return ranking[1, 1] == 0
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

function solve(populationSize, emptyPopulation, newIndividual)
    generation = 0
    population = generateFirstPopulation(emptyPopulation, newIndividual)
    ranking = zeros(Int32, size(population, 1), 2)

    while generation != 1000000
        generation += 1
        ranking = rank(population)

        if foundSolution(ranking)
            println("Geração: ", generation, " ", ranking[1, 1], " ", mean(ranking[:, 1]))
            break
        end
        if generation % 10 == 0
            println("Geração: ", generation, " ", ranking[1, 1], " ", mean(ranking[:, 1]))
        end
        population = generateNewPopulation(emptyPopulation, population, ranking)
    end

    return solucao = population[ranking[1, 2], :]
end
