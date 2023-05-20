###############################################
# Marek Traczyński (261748)                   #
# Wprowadzenie do Sztucznej Inteligencji      #
# Lista 2                                     #
###############################################
# AI's implementation using minimax algorithm #
###############################################



######################
# AI core as minimax #
######################

#=
    Determine best next move on board using minimax for given depth and player. 
=#
function nextmove(gameboard::Gameboard{Int8}, boardshashes::Dict{Int64, Int64}, 
                  depth::Integer, player::Integer)
    curreval::Int64 = 0
    besteval::Int64 = typemin(Int64)
    bestmove::Move{Int8} = Move(Int8(-1), Int8(-1))

    boardhash::Int64 = 0


    for i in 1:gameboard.size
        for j in 1:gameboard.size
            if gameboard.board[i, j] == 0
                gameboard.board[i, j] = player
                gameboard.movesdone += 1

                boardhash = boardtohash(gameboard)
                
                curreval = minimax(gameboard, boardshashes, depth, typemin(Int64), typemax(Int64), false, player)
                
                gameboard.board[i, j] = 0
                gameboard.movesdone -= 1
                
                boardshashes[boardhash] = curreval

                if curreval > besteval
                    besteval = curreval
                    bestmove.row = i
                    bestmove.col = j
                end
                println("CURREVAL: $curreval")
                println("BESTEVAL: $besteval")
            end
        end

        print(" $(20 * i)%...")
    end

    println("EVALUATION: $besteval")
    return bestmove
end

#=
    Minimax algorithm with alpha-beta pruning. 
=#
function minimax(gameboard::Gameboard{Int8}, boardshashes::Dict{Int64, Int64}, 
                 depth::Integer, alpha::Integer, beta::Integer, maximizing::Bool, player::Integer)
    boardhash::Int64 = boardtohash(gameboard)
    curreval::Int64 = 0


    if gameboard.movesdone == 25
        boardshashes[boardhash] = NEUTRAL_EVAL

        global counter += 1

        return NEUTRAL_EVAL
    end


    if haskey(boardshashes, boardhash) == true
        return boardshashes[boardhash]
    else
        curreval = heuristiceval(gameboard, depth, player)
    end


    if depth == 1 || curreval > WIN_EVAL || curreval < LOSS_EVAL
        boardshashes[boardhash] = curreval

        global counter += 1
        
        return curreval
    end
    

    besteval::Int64 = NEUTRAL_EVAL
    prune::Bool = false

    if maximizing == true
        besteval = typemin(Int64)

        for i in 1:gameboard.size
            for j in 1:gameboard.size
                if gameboard.board[i, j] == 0
                    global counter += 1
                    
                    gameboard.board[i, j] = player
                    gameboard.movesdone += 1

                    besteval = max(besteval, minimax(gameboard, boardshashes, depth - 1, alpha, beta, !maximizing, player))
                    
                    gameboard.board[i, j] = 0
                    gameboard.movesdone -= 1


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

        for i in 1:gameboard.size
            for j in 1:gameboard.size
                if gameboard.board[i, j] == 0
                    global counter += 1

                    gameboard.board[i, j] = 3 - player
                    gameboard.movesdone += 1

                    besteval = min(besteval, minimax(gameboard, boardshashes, depth - 1, alpha, beta, !maximizing, player))
                    
                    gameboard.board[i, j] = 0
                    gameboard.movesdone -= 1


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
