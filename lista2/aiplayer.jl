###############################################
# Marek Traczyński (261748)                   #
# Wprowadzenie do Sztucznej Inteligencji      #
# Lista 2                                     #
###############################################
# AI's implementation using minimax algorithm #
###############################################



##################
# Move structure #
##################

mutable struct Move{T}
    row::T
    col::T

    function Move(x::T, y::T) where T <: Integer
        new{T}(x, y)
    end
end


######################
# AI core as minimax #
######################

#=
    Determine best next move on board using minimax for given depth and player. 
=#
function nextmove(board::Matrix{<:Integer}, boardshashes::Dict{<:Integer, <:Integer}, 
                  depth::Integer, player::Integer)
    boardsize::Int8 = size(board, 1)

    curreval::Int64 = 0
    besteval::Int64 = typemin(Int64)
    bestmove::Move{Int64} = Move(-1, -1)

    boardhash::Int64 = 0


    for i in 1:boardsize
        for j in 1:boardsize
            if board[i, j] == 0
                global counter += 1

                board[i, j] = player

                boardhash = boardtohash(board)
                
                curreval = minimax(board, boardshashes, depth, typemin(Int64), typemax(Int64), false, player)
                board[i, j] = 0
                
                boardshashes[boardhash] = curreval

                if curreval > besteval
                    besteval = curreval
                    bestmove.row = i
                    bestmove.col = j
                end
            end
        end

        print(" $(20 * i)%...")
    end

    return bestmove
end

#=
    Minimax algorithm with alpha-beta pruning. 
=#
function minimax(board::Matrix{<:Integer}, boardshashes::Dict{<:Integer, <:Integer}, 
                 depth::Integer, alpha::Integer, beta::Integer, maximizing::Bool, player::Integer)
    boardsize::Int8 = size(board, 1)
    boardhash::Int64 = boardtohash(board)


    if haskey(boardshashes, boardhash) == true
        return boardshashes[boardhash]
    end


    if anymovesleft(board) == false
        boardshashes[boardhash] = NEUTRAL_EVAL

        return NEUTRAL_EVAL
    end


    curreval = heuristiceval(board, depth, player)

    if depth == 1 || curreval > WIN_EVAL || curreval < LOSS_EVAL
        boardshashes[boardhash] = curreval

        return curreval
    end
    

    besteval::Int64 = NEUTRAL_EVAL
    prune::Bool = false

    if maximizing == true
        besteval = typemin(Int64)

        for i in 1:boardsize
            for j in 1:boardsize
                if board[i, j] == 0
                    global counter += 1

                    board[i, j] = player
                    besteval = max(besteval, minimax(board, boardshashes, depth - 1, alpha, beta, !maximizing, player))
                    board[i, j] = 0

                    boardshashes[boardhash] = besteval

                    alpha = max(alpha, besteval)

                    if besteval >= beta
                        prune = true
                        break
                    end
                end

                if prune == true
                    break
                end
            end
        end

        return besteval
    else
        besteval = typemax(Int64)

        for i in 1:boardsize
            for j in 1:boardsize
                if board[i, j] == 0
                    global counter += 1

                    board[i, j] = 3 - player
                    besteval = min(besteval, minimax(board, boardshashes, depth - 1, alpha, beta, !maximizing, player))
                    board[i, j] = 0

                    boardshashes[boardhash] = besteval
                    
                    beta = min(beta, besteval)

                    if besteval <= alpha
                        prune = true
                        break
                    end
                end
                
                if prune == true
                    break
                end
            end
        end

        return besteval
    end
end 