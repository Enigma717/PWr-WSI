##################################################
# Marek Traczyński (261748)                      #
# Wprowadzenie do Sztucznej Inteligencji         #
# Lista 2                                        #
##################################################
# Heuristic implementation for minimax algorithm #
##################################################



########################
# Evaluation functions #
########################

#=
    Evaluate board for win condition (four consecutive symbols)
    and returns positive or negative evaluation depending on our symbol.

    If the condition is not met, function returns 0 as evaluation.
=#
function check_forwinning(gameboard::Gameboard{Int8}, player::Integer)
    diagonals::Vector{Vector{Int8}} = getdiagonals(gameboard)


    for i in 1:gameboard.size
        row::Vector{Int8} = gameboard.board[i, :]
        
        if check_winningsymbols(row) == true
            if row[3] == player
                return WIN_EVAL
            else
                return LOSS_EVAL
            end
        end
    end

    for j in 1:gameboard.size
        col::Vector{Int8} = gameboard.board[:, j]

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
function check_forlosing(gameboard::Gameboard{Int8}, player::Integer)
    diagonals::Vector{Vector{Int8}} = getdiagonals(gameboard, true)


    for i in 1:gameboard.size
        row::Vector{Int8} = gameboard.board[i, :]
        
        if check_losingsymbols(row) == true
            if row[3] == player
                return LOSS_EVAL
            else
                return WIN_EVAL
            end
        end
    end

    for j in 1:gameboard.size
        col::Vector{Int8} = gameboard.board[:, j]

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
    Check blocks from given player.

    For more details on type of blocks, look at their comments
    in utils.jl file.

    Direct blocking is evaluated higher than indirect ones.
=#
function check_blocks(gameboard::Gameboard{Int8}, player::Integer)
    eval::Int64 = NEUTRAL_EVAL
    diagonals::Vector{Vector{Int8}} = getdiagonals(gameboard)

    for i in 1:gameboard.size
        row::Vector{Int8} = gameboard.board[i, :]
        
        if check_indirectblock(row, player) == true
            eval += BLOCK_EVAL
        end

        if check_directblock(row, player) == true
            eval += BLOCK_EVAL * 2
        end
    end

    for j in 1:gameboard.size
        col::Vector{Int8} = gameboard.board[:, j]

        if check_indirectblock(col, player) == true
            eval += BLOCK_EVAL
        end

        if check_directblock(col, player) == true
            eval += BLOCK_EVAL * 2
        end
    end
    
    for diag in diagonals[1:2]
        if check_indirectblock(diag, player) == true
            eval += BLOCK_EVAL
        end
    end

    for diag in diagonals
        if check_directblock(diag, player) == true
            eval += BLOCK_EVAL * 2
        end
    end


    return eval
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
function evaluate_potential(gameboard::Gameboard{Int8}, depth::Integer, player::Integer)
    potential::Int64 = NEUTRAL_EVAL
    oppsymbol::Int8 = 3 - player
    diagonals::Vector{Vector{Int8}} = getdiagonals(gameboard)


    ###  Check strips in all rows  ###
    for i in 1:gameboard.size
        row::Vector{Int8} = gameboard.board[i, :]
        
        for l in 1:2
            strip = row[l:(l + 3)]
            
            if issymbolinline(strip, oppsymbol) == false
                potential += (count(symbol -> symbol == player, strip) ^ 2) + depth
            end
        end
    end


    ###  Check strips in all columns  ###
    for j in 1:gameboard.size
        col::Vector{Int8} = gameboard.board[:, j]
        
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

    If the game is after beginning moves, function checks:
    Firstly, if any player has won already (four consecutive symbols).
    Secondly, if any player has lost (three consecutive symbols).
    
    If none of the above passes, then calculate potential of the board 
    for player (check evaluate_potential() function comment above for details)
    and add multiplier of their blocks.
    After that calculate potential of the enemy position and subtract 
    that number from current evaluation.

    IMPORTANT: function evaluate_potential() simply counts number of 
    player's symbol occurences without checking for board "correctness".
    Thus it is important to check for winners/losers first, as it excludes
    possibility of pointless evaluating position that would finish the game.
=#
function heuristiceval(gameboard::Gameboard{Int8}, depth::Integer, player::Integer)
    evaluation::Int64 = NEUTRAL_EVAL


    if gameboard.movesdone > 3
        ###  Check if any player has won  ###
        evaluation = check_forwinning(gameboard, player)
    
        if evaluation > NEUTRAL_EVAL
            return evaluation + (END_MULTIPLIER * depth)
        elseif evaluation < NEUTRAL_EVAL
            return evaluation - (END_MULTIPLIER * depth)
        end
    
    
        ###  Check if any player has lost  ###
        evaluation = check_forlosing(gameboard, player)
    
        if evaluation > NEUTRAL_EVAL
            return evaluation + (END_MULTIPLIER * depth)
        elseif evaluation < NEUTRAL_EVAL
            return evaluation - (END_MULTIPLIER * depth)
        end
    end
    
    
    ###  Calculate potential of the player  ###
    evaluation += evaluate_potential(gameboard, depth, player) * ATK_MULTIPLIER

    ###  Calculate blocks from the player  ###
    evaluation += check_blocks(gameboard, player)
    
    ###  Calculate and subtract potential of the opponent  ###
    evaluation -= evaluate_potential(gameboard, depth, 3 - player) * DEF_MULTIPLIER
    


    return evaluation
end

