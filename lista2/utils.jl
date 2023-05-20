################################################
# Marek Traczyński (261748)                    #
# Wprowadzenie do Sztucznej Inteligencji       #
# Lista 2                                      #
################################################
# Utility functions used throughout the module #
################################################



###############################
# Constants used in heuristic #
###############################

const NEUTRAL_EVAL = 0
const WIN_EVAL     = 1000000
const LOSS_EVAL    = -1000000

const BLOCK_EVAL = 100000

const ATK_MULTIPLIER = 144
const DEF_MULTIPLIER = 12
const END_MULTIPLIER = 100000


##############
# Structures #
##############

mutable struct Gameboard{T}
    board::Matrix{T}
    movesdone::T
    size::T

    function Gameboard(x::Matrix{T}, y::T, z::T) where T <: Integer
        new{T}(x, y, z)
    end
end


mutable struct Move{T}
    row::T
    col::T

    function Move(x::T, y::T) where T <: Integer
        new{T}(x, y)
    end
end


################################
# Evaluations helper functions #
################################

#=
    Look for at least one given player symbol in given board line.
=#
function issymbolinline(boardline::Vector{Int8}, player::Integer)
    return any(symbol -> symbol == player, boardline)
end


#=
    Check for three consecutive symbols (loss condition) in given board line.
=#
function check_losingsymbols(boardline::Vector{Int8})
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
function check_winningsymbols(boardline::Vector{Int8})
    for i in 1:(length(boardline) - 3)
        strip = boardline[i:(i + 3)]

        if all(symbol -> symbol == strip[1] && symbol != 0, strip) == true
            return true
        end
    end

    return false
end


#=
    Check for situations where we block opponent by directly placing
    our symbol between theirs'.

    I fathom how ugly these two functions below are but it works relatively fast.

    Examples of direct blocks (for player = 1):
        > [2, 2, 1, 2]
        > [2, 0, 1, 2]


    PS. We don't really care about [0, 2, 1, 2] because it revolves around 
        [0, 2, 0, 2] position, which isn't dangerous if opponent doesn't place
        his symbol there: [2, 2, 0, 2], but then it derives to case of [2, 2, 1, 2].
=#
function check_directblock(boardline::Vector{Int8}, player::Integer)
    opponent::Int8 = 3 - player
    
    for i in 1:(length(boardline) - 3)
        strip = boardline[i:(i + 3)]

        if (count(symbol -> symbol == opponent, strip) == 3 && issymbolinline(strip, player)
            || strip[1] == opponent && strip[4] == opponent && issymbolinline(strip[2:3], player))
            return true
        end
    end

    return false
end

#=
    Check for situations where we block opponent by forcing him to place 
    three consecutive symbols in given line.

    Two cases of indirect blocks (for player = 1):
        > [1, 0, 2, 2, 0]
        > [0, 2, 2, 0, 1]
=#
function check_indirectblock(boardline::Vector{Int8}, player::Integer)
    opponent::Int8 = 3 - player
    
    if ((boardline[1] == 0 && boardline[2] == opponent && boardline[3] == opponent && boardline[4] == 0 && boardline[5] == player)) 
        || (boardline[1] == player && boardline[2] == 0 && boardline[3] == opponent && boardline[4] == opponent && boardline[5] == 0))
        return true
    end

    return false
end


#=
    Return vector of diagonals and subdiagonals of size 4.

    If optional parameter is set to true, also subdiagonals
    of size 3 are returned.
=#
function getdiagonals(gameboard::Gameboard{Int8}, smalldiags::Bool = false)
    boardsize::Int8 = gameboard.size
    diags::Vector{Vector{Int8}} = Vector{Vector{Int8}}(undef, 6)


    diags[1]  = collect(gameboard.board[i, i]                   for i in 1:boardsize)
    diags[2]  = collect(gameboard.board[i, (boardsize + 1) - i] for i in 1:boardsize)
    
    diags[3]  = collect(gameboard.board[i, i + 1]               for i in 1:(boardsize - 1))
    diags[4]  = collect(gameboard.board[i + 1, i]               for i in 1:(boardsize - 1))
    diags[5]  = collect(gameboard.board[i, boardsize - i]       for i in 1:(boardsize - 1))
    diags[6]  = collect(gameboard.board[i, (boardsize + 2) - i] for i in 2:boardsize)

    if smalldiags == true
        push!(diags, collect(gameboard.board[i, i + 2]               for i in 1:(boardsize - 2)))
        push!(diags, collect(gameboard.board[i + 2, i]               for i in 1:(boardsize - 2)))
        push!(diags, collect(gameboard.board[i, (boardsize - 1) - i] for i in 1:(boardsize - 2)))
        push!(diags, collect(gameboard.board[i, (boardsize + 3) - i] for i in 3:boardsize))
    end

    return diags
end


###################
# Board functions #
###################

#=
    Print given board.
=#
function printboard(gameboard::Gameboard{Int8})
    println("Current board:")
    println("  1 2 3 4 5")

    for i in 1:gameboard.size
        print(i)

        for j in 1:gameboard.size
            if gameboard.board[i, j] == 0
                print(" -")
            elseif gameboard.board[i, j] == 1
                print(" X")
            elseif gameboard.board[i, j] == 2
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
function boardtohash(gameboard::Gameboard{Int8})
    iterator::Int8 = length(gameboard.board)
    hash::Int64 = 0


    for i in 1:gameboard.size
        for j in 1:gameboard.size
            hash += (gameboard.board[i, j] * (3 ^ (25 - iterator)))
            iterator -= 1
        end
    end

    return hash
end