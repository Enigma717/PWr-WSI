#########################################################
# Marek Traczyński (261748)                             #
# Wprowadzenie do Sztucznej Inteligencji                #
# Lista 2                                               #
#########################################################
# Client's implementation for communication with server #
#########################################################



using Sockets



############################
# Server's response parser #
############################

#=
    Parse response sent from server.

    Possible responses:
        - length 3:
            > 700: Send player's number
            > 600: Send first move
            > 500: Loss due to my error
            > 400: Win due to opponent's error
            > 3xx: Tie caused by move "xx"
            > 2xx: Loss caused by move "xx"
            > 1xx: Win caused by move "xx"
        - length 2:
            > xx: Opponent's move 
=#
function responseparser(response::Vector{<:Integer}, board::Matrix{<:Integer}, 
                        boardshashes::Dict{<:Integer, <:Integer}, player::String, depth::Integer)
    if length(response) == 3
        code::UInt8 = response[1]

        if response[1] == 0x37
            println("\nSending my player's number: $player\n")
            return player
        end

        if code == 0x36
            println("\nI begin the game.\n")

            board[3, 3] = parse(Int64, player)

            return "33"
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
            return nothing
        end

        if code == 0x31
            println("\nI won. (yay!)\n")
            return nothing
        end
    else
        symbol::Int64 = parse(Int64, player)

        opprow::Int64 = response[1] - 0x30
        oppcol::Int64 = response[2] - 0x30

        board[opprow, oppcol] = 3 - symbol

        println("\n==============================\n")
        print("Calculating best move for depth $depth:")

        bestmove::Move{Int64} = nextmove(board, boardshashes, depth, symbol)
        movestring::String = string(bestmove.row, bestmove.col) 

        board[bestmove.row, bestmove.col] = symbol
        
        
        println("\n\nMy move: $movestring")
        println("Opponent's move: $opprow$oppcol\n")


        return movestring
    end
end


##########
# Client #
##########

function startclient(args::Vector{String})
    if length(args) < 4
        println("Wrong number of arguments provided")
        
        return nothing
    end


    board::Matrix{Int8} = zeros(Int8, 5, 5)
    boardshashes::Dict{Int64, Int64} = Dict{Int64, Int64}()

    response::Vector{UInt8} = Vector{UInt8}(undef, 3)
    movestring::Union{String, Nothing} = nothing


    address::IPv4  = IPv4(args[1]) 
    port::Int16    = parse(Int16, args[2]) 
    player::String = args[3]
    depth::Int8    = parse(Int8, args[4])



    connection = connect(address, port)

    while isopen(connection)
        response = readavailable(connection)

        movestring = responseparser(response, board, boardshashes, player, depth)

        if isnothing(movestring)
            break
        else
            write(connection, movestring)
        end

        printboard(board)
    end

    close(connection)
    println("Connection closed successfully.\n")
end
