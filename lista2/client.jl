# Marek Traczyński (261748)
# Wprowadzenie do Sztucznej Inteligencji
# Lista 2


using Sockets
using Observables


counter = 0


#################
# Miscellaneous #
#################

function printboard(board::Matrix{<:Integer})
    boardize::Int8 = size(board, 1)
    
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


#################
# Miscellaneous #
#################

function responseparser(response::Vector{<:Integer}, board::Matrix{<:Integer}, 
                        boardshashes::Dict{<:Integer, <:Integer}, player::String)
    if length(response) == 3
        code::UInt8 = response[1]

        if response[1] == 0x37
            println("Odpowiadam numer: $player")
            return player
        end

        if code == 0x36
            println("Zaczynam")

            board[3, 3] = parse(Int64, player)

            return "33"
        end

        if code == 0x35
            println("Przegrana z mojego błędu")
            return nothing
        end

        if code == 0x34
            println("Wygrałem przez błąd przeciwnika")
            return nothing
        end

        if code == 0x33
            println("Remis")
            return nothing
        end

        if code == 0x32
            println("Przegrałem")
            return nothing
        end

        if code == 0x31
            println("Wygrałem")
            return nothing
        end
    else
        symbol::Int64 = parse(Int64, player)

        oprow::Int64 = response[1] - 0x30
        opcol::Int64 = response[2] - 0x30

        board[oprow, opcol] = 3 - symbol

        global counter = 0

        time = @elapsed bestmove::Move{Int64} = nextmove(board, boardshashes, 9, symbol)
        movestring::String = string(bestmove.row, bestmove.col) 

        board[bestmove.row, bestmove.col] = symbol
        
        
        println("Ruch przeciwnika: $oprow$opcol")
        println("Mój ruch: $movestring")
        println("DICTSIZE: $(length(boardshashes))")
        println("COUNTER: $counter")
        println("TIME: $time")


        return movestring
    end
end

function startclient(args::Vector{String})
    if length(args) < 3
        println("Wrong number of arguments provided")
        
        return nothing
    end

    board::Matrix{Int8} = zeros(Int8, 5, 5)
    boardshashes::Dict{Int64, Int64} = Dict{Int64, Int64}()

    response::Vector{UInt8} = Vector{UInt8}(undef, 3)
    movestring::Union{String, Nothing} = nothing


    println("Test: $(args[1]) | $(args[2]) | $(args[3])")

    address::IPv4  = IPv4(args[1]) 
    port::Int16    = parse(Int16, args[2]) 
    player::String = args[3]



    connection = connect(address, port)

    while isopen(connection)
        response = readavailable(connection)

        display(response)

        movestring = responseparser(response, board, boardshashes, player)

        if isnothing(movestring)
            break
        else
            write(connection, movestring)
        end

        printboard(board)
    end

    println("KONIEC DZIAŁANIA")
    close(connection)
end


