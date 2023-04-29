# Marek Traczyński (261748)
# Wprowadzenie do Sztucznej Inteligencji
# Lista 1


include("./puzzle.jl")
using Plots
using .TilePuzzle


###########
# Testing #
###########

function simpletest()
    ###### I ######
    # board = Board([5 1 2 3; 9 7 4 11; 13 6 10 8; 14 15 12 0])
    # board = Board([9 5 4 2; 13 1 10 3; 14 7 11 12; 6 8 15 0])
    # board = Board([9 5 10 4; 14 13 12 2; 6 1 3 11; 15 8 7 0])

    ###### II ######
    # board = Board([13 2 10 3; 1 12 8 4; 5 0 9 6; 15 14 11 7])
    # board = Board([12 1 2 15; 11 6 5 8; 7 10 9 4; 0 13 14 3])
    # board = Board([1 7 5 12; 4 6 0 8; 9 11 13 3; 10 14 15 2])


    ###### III ######
    # board = Board([1 2 3 4; 5 7 11 8; 9 6 0 12; 13 10 14 15])
    # board = Board([5 1 3 6; 0 2 8 4; 9 14 7 11; 10 13 15 12])
    # board = Board([1 8 2; 0 4 3; 7 6 5])
    board = Board([13 2 10 3; 1 12 8 4; 5 0 9 6; 15 14 11 7])

    ###### IV ######
    # board = backtrackgen(3, 80)
    # board = randomboard(3)

    board.moves = []

    # time = @elapsed astarsolver(board, GOALTHREE, manhattan)
    # time = @elapsed astarsolver(board, GOALTHREE, hamming)
    # time = @elapsed testdata::TestData = astarsolver(board, GOALFOUR, manhattan)
    time = @elapsed testdata::TestData = astarsolver(board, GOALFOUR, manhattan)

    println("\nSTARTING BOARD:")
    printboard(board)
    print("\nMOVES:")
    printmoves(testdata.finishedboard)
    println("CREATED STATES: $(testdata.createdstates)")
    println("VISITED STATES: $(testdata.visitedstates)")
    println("TIME ELAPSED: $(time)s\n")
end

function testsizethree()
    time::Float64    = 0.0
    iterations::Int8 = 25

    backtracks::Vector{Int8}   = collect(10:80)

    hammingtimes::Vector{Float64}   = Float64[]
    manhattantimes::Vector{Float64} = Float64[]
    hammingdata::Vector{TestData}   = TestData[]
    manhattandata::Vector{TestData} = TestData[]
    datacumulator::Vector{TestData} = TestData[]
    hammingc::Vector{Int64}         = Int64[]
    hammingv::Vector{Int64}         = Int64[]
    manhattanc::Vector{Int64}       = Int64[]
    manhattanv::Vector{Int64}       = Int64[]
    
    astarsolver(GOALTHREE, GOALTHREE, hamming)
    astarsolver(GOALTHREE, GOALTHREE, manhattan)


    ##### Hamming #####
    for backtrack in backtracks
        time = 0.0

        for i in 1:iterations
            println("BACKTRACK: $backtrack || ITERATION: $i")

            # if backtrack <= 60
                startboard = backtrackgen(3, backtrack)
                time += @elapsed data = astarsolver(startboard, GOALTHREE, hamming)

                push!(datacumulator, data)
            # end
        end
        
        push!(hammingtimes, (time / iterations))
        # if backtrack <= 60
            push!(hammingdata, sum(datacumulator) / iterations)
        # else
            # push!(hammingdata, TestData(GOALTHREE, 0, 0))
        # end
    end

    for data in hammingdata
        push!(hammingc, data.createdstates)
        push!(hammingv, data.visitedstates)
    end

    ##### Manhattan #####
    for backtrack in backtracks
        time = 0.0
        empty!(datacumulator)

        for i in 1:iterations
            println("BACKTRACK: $backtrack || ITERATION: $i")

            startboard = backtrackgen(3, backtrack)
            time += @elapsed data = astarsolver(startboard, GOALTHREE, manhattan)

            push!(datacumulator, data)
        end
        
        push!(manhattantimes, (time / iterations))
        push!(manhattandata, sum(datacumulator) / iterations)
    end

    for data in manhattandata
        push!(manhattanc, data.createdstates)
        push!(manhattanv, data.visitedstates)
    end

    ##### Plots #####
    println("SAVING PLOTS")

    timeplot = plot(backtracks,
                    [hammingtimes, manhattantimes],
                    plot_title = "Czas działania dla cofania ruchów [s]",
                    label = ["Hamming" "Manhattan"],
                    legend_position = :topleft,
                    linewidth = 2,
                    size = (800, 600),
                    dpi = 300)

    cplot = plot(backtracks,
                 [hammingc, manhattanc],
                 plot_title = "Liczba utworzonych stanów dla cofania ruchów",
                 label = ["Hamming" "Manhattan"],
                 legend_position = :topleft,
                 linewidth = 2,
                 size = (800, 600),
                 dpi = 300)

    vplot = plot(backtracks,
                 [hammingv, manhattanv],
                 plot_title = "Liczba odwiedzonych dla cofania ruchów",
                 label = ["Hamming" "Manhattan"],
                 legend_position = :topleft,
                 linewidth = 2,
                 size = (800, 600),
                 dpi = 300)
                    
    Plots.png(timeplot, "./threepuzzle/timeplot.png")
    Plots.png(cplot,    "./threepuzzle/cplot.png")
    Plots.png(vplot,    "./threepuzzle/vplot.png")
end

function testsizefour()
    time::Float64    = 0.0
    iterations::Int8 = 10

    backtracks::Vector{Int8}   = collect(10:40)

    hammingtimes::Vector{Float64}   = Float64[]
    manhattantimes::Vector{Float64} = Float64[]
    hammingdata::Vector{TestData}   = TestData[]
    manhattandata::Vector{TestData} = TestData[]
    datacumulator::Vector{TestData} = TestData[]
    hammingc::Vector{Int64}         = Int64[]
    hammingv::Vector{Int64}         = Int64[]
    manhattanc::Vector{Int64}       = Int64[]
    manhattanv::Vector{Int64}       = Int64[]
    
    astarsolver(GOALFOUR, GOALFOUR, hamming)
    astarsolver(GOALFOUR, GOALFOUR, manhattan)


    ##### Hamming #####
    for backtrack in backtracks
        time = 0.0

        for i in 1:iterations
            println("BACKTRACK: $backtrack || ITERATION: $i")

            # if backtrack <= 60
                startboard = backtrackgen(4, backtrack)
                time += @elapsed data = astarsolver(startboard, GOALFOUR, hamming)

                push!(datacumulator, data)
            # end
        end
        
        push!(hammingtimes, (time / iterations))
        # if backtrack <= 60
            push!(hammingdata, sum(datacumulator) / iterations)
        # else
            # push!(hammingdata, TestData(GOALTHREE, 0, 0))
        # end
    end

    for data in hammingdata
        push!(hammingc, data.createdstates)
        push!(hammingv, data.visitedstates)
    end

    ##### Manhattan #####
    for backtrack in backtracks
        time = 0.0
        empty!(datacumulator)

        for i in 1:iterations
            println("BACKTRACK: $backtrack || ITERATION: $i")

            startboard = backtrackgen(4, backtrack)
            time += @elapsed data = astarsolver(startboard, GOALFOUR, manhattan)

            push!(datacumulator, data)
        end
        
        push!(manhattantimes, (time / iterations))
        push!(manhattandata, sum(datacumulator) / iterations)
    end

    for data in manhattandata
        push!(manhattanc, data.createdstates)
        push!(manhattanv, data.visitedstates)
    end

    ##### Plots #####
    println("SAVING PLOTS")

    timeplot = plot(backtracks,
                    [hammingtimes, manhattantimes],
                    plot_title = "Czas działania dla cofania ruchów [s]",
                    label = ["Hamming" "Manhattan"],
                    legend_position = :topleft,
                    linewidth = 2,
                    size = (800, 600),
                    dpi = 300)

    cplot = plot(backtracks,
                 [hammingc, manhattanc],
                 plot_title = "Liczba utworzonych stanów dla cofania ruchów",
                 label = ["Hamming" "Manhattan"],
                 legend_position = :topleft,
                 linewidth = 2,
                 size = (800, 600),
                 dpi = 300)

    vplot = plot(backtracks,
                 [hammingv, manhattanv],
                 plot_title = "Liczba odwiedzonych dla cofania ruchów",
                 label = ["Hamming" "Manhattan"],
                 legend_position = :topleft,
                 linewidth = 2,
                 size = (800, 600),
                 dpi = 300)
                    
    Plots.png(timeplot, "./fourpuzzle/timeplot.png")
    Plots.png(cplot,    "./fourpuzzle/cplot.png")
    Plots.png(vplot,    "./fourpuzzle/vplot.png")
end

# simpletest()
# testsizethree()
testsizefour()