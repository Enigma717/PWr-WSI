# Marek Traczyński (261748)
# Wprowadzenie do Sztucznej Inteligencji
# Lista 1


module TilePuzzle

export Board, TestData
export GOALTHREE, GOALFOUR
export hamming, manhattan, astarsolver
export printboard, printmoves, backtrackgen, randomboard


using DataStructures
using Random
import Base


##############
# Structures #
##############

mutable struct Board
    state::Matrix{Int8}
    banned::Matrix{Int8}
    moves::Vector{CartesianIndex}
    size::Int8
    eval::Int8


    function Board(state::Matrix{T}) where T <: Integer
        new(state, state, [], size(state)[1], 0)
    end

    function Board(state::Matrix{T}, moves::Vector{CartesianIndex}) where T <: Integer
        new(state, state, moves, size(state)[1], 0)
    end
end

function Base.:(==)(board1::Board, board2::Board)
    return board1.state == board2.state
end

function Base.isless(board1::Board, board2::Board)
    return board1.eval < board2.eval
end

############################

struct TestData
    createdstates::Int64
    visitedstates::Int64
end

function Base.:(+)(data1::TestData, data2::TestData)
    createdsum::Int64 = data1.createdstates + data2.createdstates
    visitedsum::Int64 = data1.visitedstates + data2.visitedstates

    return TestData(createdsum, visitedsum)
end

function Base.:(/)(data::TestData, divisor::Integer)
    createdres::Int64 = div(data.createdstates, divisor)
    visitedres::Int64 = div(data.visitedstates, divisor)

    return TestData(createdres, visitedres)
end

####################
# Global constants #
####################

const GOALTHREE::Board = Board([1 2 3
                                4 5 6
                                7 8 0]) 
                                
const GOALFOUR::Board = Board([ 1  2  3  4
                                5  6  7  8
                                9 10 11 12
                                13 14 15  0])

const MOVE_UP::CartesianIndex    = CartesianIndex(-1, 0)
const MOVE_DOWN::CartesianIndex  = CartesianIndex(1, 0)
const MOVE_LEFT::CartesianIndex  = CartesianIndex(0, -1)
const MOVE_RIGHT::CartesianIndex = CartesianIndex(0, 1)
const MOVES::Vector{CartesianIndex} = [MOVE_UP, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT]


###################
# Moves functions #
###################

findblank(board::Board) = findfirst(x -> x == 0, board.state)
getneighbours(board::Board) = map(x -> movetile(x, board), getvalidmoves(board))

ismovevalid(tile::CartesianIndex, size::Integer) = (1 <= tile[1] <= size) && (1 <= tile[2] <= size)

restrictneighbours!(boards::Vector{Board}, prevboard::Board) = filter!(x -> x != prevboard, boards)

function getvalidmoves(board::Board)
    blank::CartesianIndex = findblank(board)

    return [move for move in MOVES if ismovevalid(blank + move, board.size)] 
end

function movetile(move::CartesianIndex, board::Board)
    boardcopy::Matrix{Int8} = copy(board.state)
    movescopy::Vector{CartesianIndex} = copy(board.moves)
    blank::CartesianIndex = findblank(board)

    boardcopy[blank], boardcopy[blank + move] = boardcopy[blank + move], boardcopy[blank] 
    push!(movescopy, blank + move)

    return Board(boardcopy, movescopy)
end


##############
# Heuristics #
##############

hamming(x::CartesianIndex, y::CartesianIndex) = x != y
manhattan(x::CartesianIndex, y::CartesianIndex) = sum(abs.((x - y).I))

function useheuristic(board::Board, heuristic::Function)
    iterations::Int8 = (board.size ^ 2) - 1
    result::Int8 = 0

    goal::Vector{CartesianIndex} = Vector{CartesianIndex}(undef, iterations)
    
    actualindex::CartesianIndex = CartesianIndex(0, 0)
    goalindex::CartesianIndex   = CartesianIndex(0, 0)


    if board.size == 3
        goal = [findfirst(x -> x == i, GOALTHREE.state) for i = 1:iterations]
    elseif board.size == 4
        goal = [findfirst(x -> x == i, GOALFOUR.state) for i = 1:iterations]
    end

    for i in 1:iterations
        actualindex = findfirst(x -> x == i, board.state)
        goalindex = goal[i]

        result += heuristic(actualindex, goalindex)
    end

    return result
end


#############
# A* solver #
#############

function inversions(board::Board)
    counter::Int8 = 0
    iterations::Int8 = board.size ^ 2
    boardvec::Vector{Int8} = vec((board.state)')
    
    for i in 1:iterations
        for j in (i + 1):iterations
            if boardvec[i] > 0 && boardvec[j] > 0 && boardvec[i] > boardvec[j]
                counter += 1
            end
        end
    end

    return counter
end

function issolvable(board::Board)
    invcount::Int8 = inversions(board)
    blankindex::CartesianIndex = findblank(board)

    if board.size == 3
        return invcount % 2 == 0
    elseif board.size == 4
        if blankindex[1] % 2 == 0
            return invcount % 2 == 0
        else
            return invcount % 2 == 1
        end
    end
end


function astarsolver(start::Board, goal::Board, heurisitic::Function)
    if issolvable(start) == false
        println("Board is not solvable!")
        return TestData(0, 0)
    end

    heap::BinaryMinHeap    = BinaryMinHeap{Board}()
    distances::DefaultDict = DefaultDict{Matrix{Int8}, Int64}(typemax(Int64))

    bestboard::Board = Board(start.state)

    createdcount::Int64 = 0
    visitedcount::Int64 = 0
    tempdist::Int64    = 0


    distances[start.state] = 0;    
    start.banned = start.state

    push!(heap, start)


    while(!isempty(heap))
        bestboard = pop!(heap)

        # if visitedcount % 1000 == 0
        #     println("Eval: $(bestboard.eval) || visits: $visitedcount")
        # end

        if bestboard == goal
            return TestData(createdcount, visitedcount)
        end

        neighbours = getneighbours(bestboard)
        restrictneighbours!(neighbours, Board(bestboard.banned))

        tempdist = distances[bestboard.state] + 1

        for neigh in neighbours
            if tempdist < distances[neigh.state]
                createdcount += 1
                distances[neigh.state] = tempdist

                neigh.banned = bestboard.state
                neigh.eval   = tempdist + useheuristic(neigh, heurisitic)
                
                push!(heap, neigh)
            end
        end

        visitedcount += 1
    end

    return TestData(createdcount, visitedcount)
end


#################
# Miscellaneous #
#################

function printboard(board::Board)
    display(board.state)
end

function printmoves(board::Board)
    print("\n[ ")
    for move in board.moves
        print("$(move.I) ")
    end
    println("]")
end


function randomboard(size::Integer)
    if size == 3
        return Board(shuffle(GOALTHREE.state))
    elseif size == 4
        return Board(shuffle(GOALFOUR.state))
    end
end

function backtrackgen(size::Integer, movescount::Integer)
    if size == 3
        generated = Board(GOALTHREE.state)
    elseif size == 4
        generated = Board(GOALFOUR.state)
    end

    prev::Board = generated

    for _ in 1:movescount
        neighbours::Vector{Board} = getneighbours(generated)
        restrictneighbours!(neighbours, prev)
        randneighbour::Board = rand(neighbours)

        prev = generated
        generated = randneighbour
    end

    return generated
end


end     ##### module TilePuzzle #####
