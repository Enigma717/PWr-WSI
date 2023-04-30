# Marek Traczyński (261748)
# Wprowadzenie do Sztucznej Inteligencji
# Lista 2


# const minmaxmodes::Dict{Bool, String} = Dict{Bool, String}(true => "Maximize", false => "Minimize")


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


####################
# Helper functions #
####################

#=
    Check if there are any possible moves on given board.
=#
function anymovesleft(board::Matrix{<:Integer})
    return any(symbol -> symbol == 0, board)
end


#=
    Check for three consecutive elements in given board line.
=#
function check_threesymbols(boardline::Vector{<:Integer})
    for i in 1:(length(boardline) - 2)
        strip = boardline[i:(i + 2)]

        if all(symbol -> symbol == strip[1] && symbol != 0, strip) == true
            return true
        end
    end

    return false
end

#=
    Check for four consecutive elements in given board line.
=#
function check_foursymbols(boardline::Vector{<:Integer})
    for i in 1:(length(boardline) - 3)
        strip = boardline[i:(i + 3)]

        if all(symbol -> symbol == strip[1] && symbol != 0, strip) == true
            return true
        end
    end

    return false
end


#=
    Return vector of diagonals and subdiagonals of size 4.

    If optional parameter is set to true, also subdiagonals
    of size 3 are returned..
=#
function getdiagonals(board::Matrix{<:Integer}, smalldiags = false)
    boardsize::Int8 = size(board, 1)
    diags::Vector{Vector{Int8}} = Vector{Vector{Int8}}(undef, 6)

    diags[1]  = collect(board[i, i]                   for i in 1:boardsize)
    diags[2]  = collect(board[i, (boardsize + 1) - i] for i in 1:boardsize)
    
    diags[3]  = collect(board[i, i + 1]               for i in 1:(boardsize - 1))
    diags[4]  = collect(board[i + 1, i]               for i in 1:(boardsize - 1))
    diags[5]  = collect(board[i, boardsize - i]       for i in 1:(boardsize - 1))
    diags[6]  = collect(board[i, (boardsize + 2) - i] for i in 2:boardsize)

    if smalldiags == true
        push!(diags, collect(board[i, i + 2]               for i in 1:(boardsize - 2)))
        push!(diags, collect(board[i + 2, i]               for i in 1:(boardsize - 2)))
        push!(diags, collect(board[i, (boardsize - 1) - i] for i in 1:(boardsize - 2)))
        push!(diags, collect(board[i, (boardsize + 3) - i] for i in 3:boardsize))
    end

    return diags
end


function boardtohash(board::Matrix{<:Integer}, depth::Integer)
    boardsize::Int8 = size(board, 1)
    iterator::Int8 = length(board)
    hash::Int64 = 0

    for i in 1:boardsize
        for j in 1:boardsize
            hash += (board[i, j] * (3 ^ (25 - iterator))) * depth
            iterator -= 1
        end
    end

    return hash
end


########################
# Evaluation functions #
########################

#=
    Evaluate board for win condition (four consecutive symbols)
    and returns positive or negative evaluation depending on our symbol.

    If the condition is not met, function returns 0 as evaluation.
=#
function evaluate_forwinning(board::Matrix{<:Integer}, player::Integer)
    boardsize::Int8 = size(board, 1)
    diagonals::Vector{Vector{Int8}} = getdiagonals(board)


    for i in 1:boardsize
        row::Vector{Int8} = board[i, :]
        
        if check_foursymbols(row) == true
            if row[3] == player
                return 100
            else
                return -100
            end
        end
    end

    for j in 1:boardsize
        col::Vector{Int8} = board[:, j]

        if check_foursymbols(col) == true
            if col[3] == player
                return 100
            else
                return -100
            end
        end
    end
    
    for diag in diagonals
        if check_foursymbols(diag) == true
            if diag[3] == player
                return 100
            else
                return -100
            end
        end
    end

    return 0
end

#=
    Evaluate board for loss condition (three consecutive symbols)
    and returns positive or negative evaluation depending on our symbol.

    If the condition is not met, function returns 0 as evaluation.
=#
function evaluate_forlosing(board::Matrix{<:Integer}, player::Integer)
    boardsize::Int8 = size(board, 1)
    diagonals::Vector{Vector{Int8}} = getdiagonals(board, true)


    for i in 1:boardsize
        row::Vector{Int8} = board[i, :]
        
        if check_threesymbols(row) == true
            if row[3] == player
                return -100
            else
                return 100
            end
        end
    end

    for j in 1:boardsize
        col::Vector{Int8} = board[:, j]

        if check_threesymbols(col) == true
            if col[3] == player
                return -100
            else
                return 100
            end
        end
    end
    
    for diag in diagonals
        if check_threesymbols(diag) == true
            if diag[3] == player
                return -100
            else
                return 100
            end
        end
    end

    return 0
end


function evaluate_potentials(board, depth, player)
    boardsize::Int8 = size(board, 1)

end


######################
# Minmax + heuristic #
######################

function heuristiceval(board::Matrix{<:Integer}, depth::Integer, player::Integer)
    evaluation::Int64 = 0
    evaluation += evaluate_forwinning(board, player) * (10 * depth)

    if evaluation > 0
        return evaluation
    end

    evaluation = 0
    evaluation += evaluate_forlosing(board, player) * (10 * depth)

    if evaluation < 0
        return evaluation
    end


    return evaluation
end

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

                boardhash = boardtohash(board, depth)
                println("boardhash[$i, $j] = $boardhash")
                # display(board)
                
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
    end


    println("Depth: $depth")
    println("Best evaluation: $besteval")
    println("Best move: $bestmove")

    return bestmove
end

function minimax(board::Matrix{<:Integer}, boardshashes::Dict{<:Integer, <:Integer}, depth::Integer, 
                 alpha::Integer, beta::Integer, maximizing::Bool, player::Integer)
    boardsize::Int8 = size(board, 1)
    boardhash::Int64 = boardtohash(board, depth)


    if haskey(boardshashes, boardhash) == true
        return boardshashes[boardhash]
    end


    winpreeval::Int64 = evaluate_forwinning(board, player) 
    if winpreeval != 0 
        boardshashes[boardhash] = winpreeval

        return winpreeval
    end
    
    losspreeval::Int64 = evaluate_forlosing(board, player)
    if losspreeval != 0
        boardshashes[boardhash] = losspreeval

        return losspreeval
    end

    if anymovesleft(board) == false
        boardshashes[boardhash] = 0

        return 0
    end


    curreval::Int64 = heuristiceval(board, depth, player)

    if depth == 1
        # println("MINMAX END:")
        # display(board)
        # println("EVAL: $curreval | ALPHA: $alpha | BETA: $beta")
        boardshashes[boardhash] = curreval

        return curreval
    end
    

    besteval::Int64 = 0
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