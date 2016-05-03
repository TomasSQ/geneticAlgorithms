push!(LOAD_PATH, string(pwd(), "/.."))

using GeneticAlgorithmSolver: GASolver, solve

const INDIVIDUAL_SIZE = 1000
const POPULATION_SIZE = 100
const MAX_GENERATION = 1000
const EQUALS_GENERATIONS = 200000
const PENALITY = 1
const GET_BACK_PENALITY = 1
const FAR_PENALITY = 10
const UP = 1
const DOWN = 2
const LEFT = 3
const RIGHT = 4
const MAZE = """
#####################F###################
# #                   #   #           # #
# # ####### ######### # # # ### ##### # #
# # #   #   #       #   # # #   #   #   #
# # # # # ### ##### ####### # ### # ### #
# # # # # #   #   #         #     #   # #
# # ### # # ### ##################### # #
# #     # # #         #         #     # #
# ### ### # ##### ### # ####### # ##### #
#   # #   #   #   # # # # #     # #   # #
# ### # ##### # ### # # # # ##### ### # #
# #   # #     # #     # #       #   #   #
# # ### # ##### ####### ####### ### #####
# #   #   #   #   #   #     # #   #     #
# ### ##### # ### # # ##### # ### ##### #
# #   #     # #   # # #   # #   #       #
# # ### ##### # # # # # # # # ######### #
# # #   #     # # # #   #   #         # #
# # ### ##### # # # ################# # #
# # #   #   #   # # #   #   #       #   #
# # # ### # ##### # # # # # # ##### #####
# # #     #     # # # #   # # #   #     #
# # ########### # # # ##### # # # #######
# #     #       # # #     # #   #   #   #
# ##### # ##### ### ##### # ####### ### #
#     # #   #   #   #     #     #   #   #
# ### # ### # ### # # ####### ### ### ###
# # # # #   # #   # # #   # #     # #   #
# # # # # ##### ### # # # # ####### # # #
# # #   #   #   #   #   #   #     #   # #
# # ####### # ############# ### # ##### #
#       #   # #   #       # #   #     # #
####### # ### # # # ### # # # # ##### # #
#     # #   #   #   #   # # # # #   #   #
# ### # ### ######### ##### # ### # #####
#   # # #   #   #   # #     #     #     #
# # ### # # # ### # # # ######### ##### #
# #   # # # #   # #   #         #   #   #
# ### # # # ### # ############# ##### # #
#   #     #     #                     # #
#####################S###################"""
solucao = [UP, UP, UP, LEFT, LEFT, UP, UP, LEFT, LEFT, UP, UP, UP, UP, RIGHT, RIGHT, RIGHT, RIGHT, UP]

type Point
    wall::Bool
    path::Bool
    Point() = new(false, false)
    Point(wall::Bool) = new(wall, false)
    Point(point::Point) = new(point.wall, point.path)
end

type Maze
    board::AbstractArray{Point,2}
    width::Int
    height::Int
    start::Tuple{Int, Int}
    finish::Tuple{Int, Int}
    Maze(width::Int, height::Int) = new(Array{Point,2}(height, width), width, height, (0, 0), (0, 0))
end

mazeArray = split(MAZE, '\n')
maze = Maze(length(mazeArray[1]), length(mazeArray))
for y = 1:maze.height
    for x = 1:maze.width
        maze.board[y, x] = Point(mazeArray[y][x] == '#')
        if mazeArray[y][x] == 'F'
            maze.finish = (x, y)
        elseif mazeArray[y][x] == 'S'
            maze.start = (x, y)
        end
    end
end

function walk(solucao)
    x = maze.start[1]
    y = maze.start[2]
    steps = 0
    penalities = 0
    maze.board[y, x].path = true
    visitedX = []
    visitedY = []
    for i = 1:length(solucao)
        steps += 1
        oldX = x
        oldY = y
        if solucao[i] == UP
            y -= 1
        elseif solucao[i] == DOWN
            y += 1
        elseif solucao[i] == LEFT
            x -= 1
        elseif solucao[i] == RIGHT
            x += 1
        end
        if x == maze.finish[1] && y == maze.finish[2]
            return (x, y, 0, 0)
        end
        if 1 <= x && x <= maze.width && 1 <= y && y <= maze.height && !maze.board[y, x].wall
            if findfirst(visitedX, x) >= 1 && findfirst(visitedY, y) >= 1
                penalities += GET_BACK_PENALITY
            else
                push!(visitedX, x)
                push!(visitedY, y)
            end
        else
            x = oldX
            y = oldY
            penalities += 1#distanceToEnd(x, y)
        end
    end

    return (x, y, steps, penalities)
end

function printMaze()
    for i = 1:maze.height
        for j = 1:maze.width
            if maze.board[i, j].path
                print("+")
            elseif maze.board[i, j].wall
                print("#")
            else
                print(" ")
            end
        end
        println()
    end
end

function ehViavel(solucao)
    return fitness(solucao) == 0
end

function distanceToEnd(x::Int, y::Int)
    d = abs(x - maze.finish[1]) + abs(y - maze.finish[2])
    return d
end

function fitness(solucao,position=false)
    (x, y, steps, penalities) = walk(solucao)
    if position
        println(penalities)
        println((x, y))
    end
    distance = distanceToEnd(x, y)
    return (penalities * PENALITY) + steps + distance * FAR_PENALITY
end

function newIndividual()
    route = []
    x = maze.start[1]
    y = maze.start[2]
    i = 0
    while i < INDIVIDUAL_SIZE
        oldX = x
        oldY = y
        dir = ceil(rand() * 4)
        if dir == UP
            y -= 1
        elseif dir == DOWN
            y += 1
        elseif dir == LEFT
            x -= 1
        elseif dir == RIGHT
            x += 1
        end
        if 1 <= x && x <= maze.width && 1 <= y && y <= maze.height && !maze.board[y, x].wall
            push!(route, dir)
            i += 1
        else
            x = oldX
            y = oldY
        end
    end

    return route
end

metrics = []

function shouldStop(m)
    return m[1] == 0
end

function imprimeSolucao(solucao, step=false)
    x = maze.start[1]
    y = maze.start[2]
    maze.board[y, x].path = true
    for i = 1:length(solucao)
        oldX = x
        oldY = y
        if solucao[i] == UP
            y -= 1
        elseif solucao[i] == DOWN
            y += 1
        elseif solucao[i] == LEFT
            x -= 1
        elseif solucao[i] == RIGHT
            x += 1
        end
        if 1 <= x && x <= maze.width && 1 <= y && y <= maze.height && !maze.board[y, x].wall
            maze.board[y, x].path = true
        else
            x = oldX
            y = oldY
        end
        if step
            printMaze()
        end
    end

    printMaze()
end

function mazeIt()
    solved = solve(POPULATION_SIZE, INDIVIDUAL_SIZE, newIndividual, fitness, shouldStop, MAX_GENERATION,
        0.5, singleCrossover=false, mutateSwap=false, newGene=()->ceil(rand() * 4))
    println("Solução encontrada na geração ", solved[2])
    println(solved[1])
    imprimeSolucao(solved[1])
    println(fitness(solved[1], true))
    println(ehViavel(solved[1]))
end
mazeIt()
#solucao = [1.0,3.0,4.0,3.0,4.0,3.0,4.0,3.0,3.0,4.0,4.0,2.0,1.0,3.0,4.0,2.0,1.0,4.0,4.0,3.0,3.0,4.0,3.0,3.0,3.0,3.0,4.0,3.0,3.0,1.0]
#imprimeSolucao(solucao)
#println(fitness(solucao, true))
