##################################################
# Marek Traczyński (261748)                      #
# Wprowadzenie do Sztucznej Inteligencji         #
# Lista 2                                        #
##################################################
# Auxiliary functions used throughout the module #
##################################################



################################
# Evaluations helper functions #
################################

#=
    Check if there are any possible moves on given board.
=#
function anymovesleft(board::Matrix{<:Integer})
    return any(symbol -> symbol == 0, board)
end

#=
    Count how many symbols player has in the center.
=#
function countcenter(board::Matrix{<:Integer}, player::Integer)
    return count(symbol -> symbol == player, board[2:4, 2:4])
end

#=
    Look for at least one given player symbol in given board line.
=#
function issymbolinline(boardline::Vector{<:Integer}, player::Integer)
    return any(symbol -> symbol == player, boardline)
end


#=
    Check for three consecutive symbols (loss condition) in given board line.
=#
function check_losingsymbols(boardline::Vector{<:Integer})
    for i in 1:(length(boardline) - 2)
        strip = boardline[i:(i + 2)]

        if all(symbol -> symbol == strip[1] && symbol != 0, strip) == true
            return true
        end
    end

    return false
end

#=
    Check for four consecutive symbols (win condition) in given board line.
=#
function check_winningsymbols(boardline::Vector{<:Integer})
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
    of size 3 are returned.
=#
function getdiagonals(board::Matrix{<:Integer}, smalldiags::Bool = false)
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


###################
# Board functions #
###################

#=
    Print given board.
=#
function printboard(board::Matrix{<:Integer})
    boardize::Int8 = size(board, 1)
    
    println("Current board:")
    println("  1 2 3 4 5")

    for i in 1:boardize
        print(i)

        for j in 1:boardize
            if board[i, j] == 0
                print(" -")
            elseif board[i, j] == 1
                print(" X")
            elseif board[i, j] == 2
                print(" O")
            end
        end

        println()
    end

    println()
end

#=
    Return hash of the given board.
=#
function boardtohash(board::Matrix{<:Integer})
    boardsize::Int8 = size(board, 1)
    iterator::Int8 = length(board)
    hash::Int64 = 0


    for i in 1:boardsize
        for j in 1:boardsize
            hash += (board[i, j] * (3 ^ (25 - iterator)))
            iterator -= 1
        end
    end

    return hash
end
