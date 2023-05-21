##########################################
# Marek Traczyński (261748)              #
# Wprowadzenie do Sztucznej Inteligencji #
# Lista 2                                #
##########################################
# Start the client                       #
##########################################



include("./module/TTTPlayer.jl")
using .TTTPlayer


###  Start game with client  ###
function start()
    startclient(ARGS)
end


start()