##################################################
# Marek Traczyński (261748)                      #
# Wprowadzenie do Sztucznej Inteligencji         #
# Lista 2                                        #
##################################################
# Heuristic implementation for minimax algorithm #
##################################################



const NEUTRAL_EVAL = 0
const WIN_EVAL     = 100000
const LOSS_EVAL    = -100000

const END_MULTIPLIER = 10000


########################
# Evaluation functions #
########################

#=
    Evaluate board for win condition (four consecutive symbols)
    and returns positive or negative evaluation depending on our symbol.

    If the condition is not met, function returns 0 as evaluation.
=#
function check_forwinning(board::Matrix{<:Integer}, player::Integer)
    boardsize::Int8 = size(board, 1)
    diagonals::Vector{Vector{Int8}} = getdiagonals(board)


    for i in 1:boardsize
        row::Vector{Int8} = board[i, :]
        
        if check_winningsymbols(row) == true
            if row[3] == player
                return WIN_EVAL
            else
                return LOSS_EVAL
            end
        end
    end

    for j in 1:boardsize
        col::Vector{Int8} = board[:, j]

        if check_winningsymbols(col) == true
            if col[3] == player
                return WIN_EVAL
            else
                return LOSS_EVAL
            end
        end
    end
    
    for diag in diagonals
        if check_winningsymbols(diag) == true
            if diag[3] == player
                return WIN_EVAL
            else
                return LOSS_EVAL
            end
        end
    end

    return NEUTRAL_EVAL
end


#=
    Evaluate board for loss condition (three consecutive symbols)
    and returns positive or negative evaluation depending on our symbol.

    If the condition is not met, function returns 0 as evaluation.
=#
function check_forlosing(board::Matrix{<:Integer}, player::Integer)
    boardsize::Int8 = size(board, 1)
    diagonals::Vector{Vector{Int8}} = getdiagonals(board, true)


    for i in 1:boardsize
        row::Vector{Int8} = board[i, :]
        
        if check_losingsymbols(row) == true
            if row[3] == player
                return LOSS_EVAL
            else
                return WIN_EVAL
            end
        end
    end

    for j in 1:boardsize
        col::Vector{Int8} = board[:, j]

        if check_losingsymbols(col) == true
            if col[3] == player
                return LOSS_EVAL
            else
                return WIN_EVAL
            end
        end
    end
    
    for diag in diagonals
        if check_losingsymbols(diag) == true
            if diag[3] == player
                return LOSS_EVAL
            else
                return WIN_EVAL
            end
        end
    end

    return NEUTRAL_EVAL
end


#= 
    Calculate potential of the board for given player.

    Potential is evaluated by checking every possible strips of four 
    consecutive symbols in each row, column and diagonal.
    If currently checked strip contains opponent's symbol, it is skipped.
    Otherwise function counts number of player's symbols and adds its 
    square plus depth to final evaluation.
    
    Evaluation examples (for player = 1):
        > [0, 0, 0, 1] = 1 
        > [1, 1, 0, 1] = 9
        > [0, 2, 0, 1] = skipped
=#
function evaluate_potential(board::Matrix{<:Integer}, depth::Integer, player::Integer)
    boardsize::Int8 = size(board, 1)
    potential::Int64 = 0
    oppsymbol::Int8 = 3 - player
    diagonals::Vector{Vector{Int8}} = getdiagonals(board)


    ###  Check strips in all rows  ###
    for i in 1:boardsize
        row::Vector{Int8} = board[i, :]
        
        for l in 1:2
            strip = row[l:(l + 3)]
            
            if issymbolinline(strip, oppsymbol) == false
                potential += (count(symbol -> symbol == player, strip) ^ 2) + depth
            end
        end
    end


    ###  Check strips in all columns  ###
    for j in 1:boardsize
        col::Vector{Int8} = board[:, j]
        
        for l in 1:2
            strip = col[l:(l + 3)]
            
            if issymbolinline(strip, oppsymbol) == false
                potential += (count(symbol -> symbol == player, strip) ^ 2) + depth
            end
        end
    end
    

    ###  Check strips in all diagonals  ###
    for diag in diagonals
        if length(diag) == 5
            for l in 1:2
                strip = diag[l:(l + 3)]
                
                if issymbolinline(strip, oppsymbol) == false
                    potential += (count(symbol -> symbol == player, strip) ^ 2) + depth
                end
            end
        else
            if issymbolinline(diag, oppsymbol) == false
                potential += (count(symbol -> symbol == player, diag) ^ 2) + depth
            end
        end
    end

    return potential
end


##################
# Main heuristic #
##################

#=
    Evaluate given board with heuristic:

    Firstly check if any player has won already (four consecutive symbols).
    Then check if any player has lost (three consecutive symbols).
    
    If none of the above passes, then calculate potential of the board 
    for player (check evaluate_potential() function comment above for details)
    and add count of their symbols in center 3x3 square.
    After that calculate potential of the enemy position and subtract 
    that number from current evaluation.

    IMPORTANT: function evaluate_potential() simply counts number of 
    player's symbol occurences without checking for board "correctness".
    Thus it is important to check for winners/losers first, as it excludes
    possibility of pointless evaluating position that would finish the game.
=#
function heuristiceval(board::Matrix{<:Integer}, depth::Integer, player::Integer)
    evaluation::Int64 = NEUTRAL_EVAL

    ###  Check if any player has won  ###
    evaluation = check_forwinning(board, player)

    if evaluation > NEUTRAL_EVAL
        return evaluation + (END_MULTIPLIER * depth)
    elseif evaluation < NEUTRAL_EVAL
        return evaluation - (END_MULTIPLIER * depth)
    end


    ###  Check if any player has lost  ###
    evaluation = check_forlosing(board, player)

    if evaluation > NEUTRAL_EVAL
        return evaluation + (END_MULTIPLIER * depth)
    elseif evaluation < NEUTRAL_EVAL
        return evaluation - (END_MULTIPLIER * depth)
    end


    ###  Calculate potential of the player  ###
    evaluation = evaluate_potential(board, depth, player) 

    ###  Add count of player's symbols in the center  ###
    evaluation += countcenter(board, player)

    ###  Calculate and subtract potential of the opponent  ###
    evaluation -= evaluate_potential(board, depth, 3 - player)


    return evaluation
end

