# Marek Traczyński (261748)
# Wprowadzenie do Sztucznej Inteligencji
# Lista 2


using Sockets
using Observables


#################
# Miscellaneous #
#################

function printboard(board::Matrix{<:Integer})
    println("  1 2 3 4 5")

    for i in 1:5
        print(i)

        for j in 1:5
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

function responseparser(response::Vector{<:Integer}, board::Matrix{<:Integer}, player::String)
    if length(response) == 3
        code::UInt8 = response[1]

        if response[1] == 0x37
            println("Odpowiadam numer: $player")
            return player
        end

        if code == 0x36
            println("Zaczynam")
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
        symbol::UInt8 = parse(UInt8, player)

        oprow::UInt8 = response[1] - 48
        opcol::UInt8 = response[2] - 48
        
        myrow::UInt8 = oprow + 1 < 6 ? oprow + 1 : 1
        mycol::UInt8 = opcol + 1 < 6 ? opcol + 1 : 1

        mymove::String = string(myrow, mycol) 
        

        board[oprow, opcol] = 3 - symbol
        board[myrow, mycol] = symbol
        
        
        println("Ruch przeciwnika: $oprow$opcol")
        println("Mój ruch: $mymove")


        return mymove
    end
end

function startclient(args::Vector{String})
    if length(args) < 3
        println("Wrong number of arguments provided")
        
        return nothing
    end

    board::Matrix{Int8} = zeros(Int8, 5, 5)

    println("Typeof: $(typeof(args))")
    println("Test: $(args[1]) | $(args[2]) | $(args[3])")

    address = IPv4(args[1]) 
    port = parse(Int16, args[2]) 
    player = args[3]

    connection = connect(address, port)


    while isopen(connection)
        response::Vector{UInt8} = readavailable(connection)

        mymove::Union{String, Nothing} = responseparser(response, board, player)

        if isnothing(mymove)
            break
        else
            write(connection, mymove)
        end

        printboard(board)
    end

    println("KONIEC DZIAŁANIA")
    close(connection)
end


