#########################################################
# Marek Traczyński (261748)                             #
# Wprowadzenie do Sztucznej Inteligencji                #
# Lista 2                                               #
#########################################################
# Client's implementation for communication with server #
#########################################################



using Sockets

counter = 0

############################
# Server's response parser #
############################

#=
    Parse response sent from server.

    Possible responses:
        -> length 2:
            > xx: Opponent's move 
        -> length 3:
            > 700: Send player's number
            > 600: Send first move
            > 500: Loss due to my error
            > 400: Win due to opponent's error
            > 3xx: Tie caused by move "xx"
            > 2xx: Loss caused by move "xx"
            > 1xx: Win caused by move "xx"
    
    If response was of length 2, or length 3 with code 600, then we
    deduce our next move with use of minimax algorithm and send back
    string with our move to the server.
=#
function responseparser(response::Vector{UInt8}, gameboard::Gameboard{Int8}, 
                        boardshashes::Dict{Int64, Int64}, player::String, depth::Integer)

    symbol::Int64 = parse(Int64, player)

    if length(response) == 2
        opprow::UInt8 = response[1] - 0x30
        oppcol::UInt8 = response[2] - 0x30

        gameboard.board[opprow, oppcol] = 3 - symbol
        gameboard.movesdone += 1
    elseif length(response) == 3
        code::UInt8 = response[1]

        if response[1] == 0x37
            println("\nSending my player's number: $player\n")
            return player
        end

        if code == 0x36
            println("\nI begin the game.\n")
        end

        if code == 0x35
            println("\nI lost due to my error.\n")
            return nothing
        end

        if code == 0x34
            println("\nI won due to my opponent's error.\n")
            return nothing
        end

        if code == 0x33
            println("\nTie.\n")
            return nothing
        end

        if code == 0x32
            println("\nI lost.\n")

            mvrow::UInt8 = response[2] - 0x30
            mvcol::UInt8 = response[3] - 0x30

            if mvrow != 0
                gameboard.board[mvrow, mvcol] = 3 - symbol
                gameboard.movesdone += 1
            end

            return nothing
        end

        if code == 0x31
            println("\nI won. (yay!)\n")
            return nothing
        end
    else
        println("\nWrong message from the server\n")
        return nothing
    end

    global counter = 0

    println("\n==============================\n")
    print("Calculating best move for depth $depth:")

    time = @elapsed bestmove::Move{Int8} = nextmove(gameboard, boardshashes, depth, symbol)
    movestring::String = string(bestmove.row, bestmove.col) 

    gameboard.board[bestmove.row, bestmove.col] = symbol
    gameboard.movesdone += 1
    
    
    println("\n\nMy move: $movestring")
    println("\nDICTSIZE: $(length(boardshashes))\n")
    println("COUNTER: $counter\n")
    println("TIME: $time\n")

    return movestring
end


##########
# Client #
##########

function startclient(args::Vector{String})
    if length(args) < 4
        println("Wrong number of arguments provided")
        
        return nothing
    end


    player::String = args[3]

    if player != "1" && player != "2" 
        println("\nWrong player parameter.") 
        println("Please enter correct number (1 or 2).\n")
        
        return nothing
    end


    depth::Int8 = parse(Int8, args[4])

    if depth < 1 || depth > 10
        println("\nWrong depth parameter.") 
        println("Please enter correct number (1 <= depth <= 10).\n")
        
        return nothing
    end


    address::IPv4  = IPv4(args[1]) 
    port::Int16    = parse(Int16, args[2]) 


    gameboard::Gameboard{Int8} = Gameboard(zeros(Int8, 5, 5), Int8(0), Int8(5))
    boardshashes::Dict{Int64, Int64} = Dict{Int64, Int64}()

    response::Vector{UInt8} = Vector{UInt8}(undef, 3)
    movestring::Union{String, Nothing} = nothing


    connection = connect(address, port)

    while isopen(connection)
        response = readavailable(connection)

        movestring = responseparser(response, gameboard, boardshashes, player, depth)

        if isnothing(movestring)
            printboard(gameboard)

            break
        else
            write(connection, movestring)
        end

        printboard(gameboard)
    end

    close(connection)
    println("Connection closed successfully.\n")
end
