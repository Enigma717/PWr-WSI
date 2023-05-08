##########################################
# Marek Traczyński (261748)              #
# Wprowadzenie do Sztucznej Inteligencji #
# Lista 2                                #
##########################################
# Start the client                       #
##########################################


include("./TTTPlayer.jl")
using .TTTPlayer

function start()
    startclient(ARGS)
end


start()
