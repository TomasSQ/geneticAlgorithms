push!(LOAD_PATH, string(pwd(), "/.."))

#using PyPlot

using GeneticAlgorithmSolver: GASolver, solve

const VERTEXS = 80
const EDGES = VERTEXS * 4
const PROBLEMAN_SIZE = VERTEXS::Int
const POPULATION_SIZE = 200::Int
const MAX_GENERATION = 100000::Int
const EQUALS_GENERATIONS = 5000::Int
const MAX_COLOR = VERTEXS

type Vertex
    id::Int
    x::Float64
    y::Float64
    adjacents::AbstractArray{Int}
    color::Int
end

function randomGraph()
    graph = Array{Vertex}(VERTEXS)
    for i = 1:length(graph)
        graph[i] = Vertex(i, rand() * VERTEXS ^ 2, rand() * VERTEXS ^ 2, [], 0)
    end

    for i = 1:EDGES
        u = 1
        v = 1
        while u == v || findfirst(graph[v].adjacents, u) != 0
            u = round(Int, ceil(rand() * VERTEXS))
            v = round(Int, ceil(rand() * VERTEXS))
        end
        push!(graph[v].adjacents, u)
        push!(graph[u].adjacents, v)
    end

    return graph
end

function petersenGraph()
    return [Vertex(1, 0, 7, [2, 5, 6], 0);
        Vertex(2, 10, 2, [1, 3, 7], 0);
        Vertex(3, 6, -6, [2, 4, 8], 0);
        Vertex(4, -6, -6, [3, 5, 9], 0);
        Vertex(5, -10, 2, [1, 4, 10], 0);
        Vertex(6, 0, 5, [1, 8, 9], 0);
        Vertex(7, 7, 1.5, [2, 9, 10], 0);
        Vertex(8, 5, -4, [3, 6, 10], 0);
        Vertex(9, -5, -4, [4, 6, 7], 0);
        Vertex(10, -7, 1.5, [5, 7, 8], 0)]
end

graph = randomGraph()

maxVertexDegree = 0
for v in graph
    if length(v.adjacents) > maxVertexDegree
        maxVertexDegree = length(v.adjacents)
    end
end

function plotVertexs(colors)
    avaibleColors = ["green" "red" "cyan" "orange" "magenta" "yellow" "black" "blue"]

    xs = []
    ys = []
	for i = 1:avaibleColors
		push!(xs, [])
		push!(ys, [])
	end
    for i = 1:length(graph)
        push!(xs[graph[i].color], graph[i].x)
        push!(ys[graph[i].color], graph[i].y)
    end
    for i in eachindex(avaibleColors)
        if length(xs[i]) > 0
            scatter(xs[i], ys[i], alpha=1,s=120,c=avaibleColors[i], edgecolors="face")
        end
    end
end

function plotEdges()
    xs = [0.0, 0.0]
    ys = [0.0, 0.0]
    for i = 1:length(graph)
        xs[1] = graph[i].x
        ys[1] = graph[i].y
        for j = 1:length(graph[i].adjacents)
            xs[2] = graph[graph[i].adjacents[j]].x
            ys[2] = graph[graph[i].adjacents[j]].y
            plot(xs, ys, c="blue")
        end
    end
end

function imprimeSolucao(solucao, shouldPlot=false)
    println("Solution: ", solucao)
    println("Fitness: ", fitness(solucao))
    println("Max Vertex Degree: ", maxVertexDegree)
    println("Colors: ", countColors(solucao))
    println("Mistakes: ", countMistakes(solucao))
    if shouldPlot
        plotEdges()
        plotVertexs(colors)

        savefig("colored.png")
    end
end

function countColors(solucao)
    colors = []
    for i = 1:length(solucao)
        color = round(Int, solucao[i])
        if findfirst(colors, color) == 0
            push!(colors, color)
        end
        graph[i].color = color
    end

    return length(colors)
end

function countMistakes(solucao)
    mistakes = 0

    for v in graph
        for u in v.adjacents
            if v.color == graph[u].color
                mistakes += 1
            end
        end
    end

    return mistakes
end

function fitness(solucao)
    return abs(countColors(solucao) - maxVertexDegree) * 2 + countMistakes(solucao)
end

function newIndividual()
    return ceil(rand(length(graph)) * MAX_COLOR)
end

metrics = []

function shouldStop(m)
    if m[1] == 0
        return true
    end
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

function color!()
    solved = solve(POPULATION_SIZE, PROBLEMAN_SIZE, newIndividual, fitness, shouldStop, MAX_GENERATION)
    println("Solução encontrada na geração ", solved[2])
    imprimeSolucao(solved[1])
end
color!()
