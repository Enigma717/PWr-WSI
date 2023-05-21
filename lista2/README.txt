Projekt: Sztuczna inteligencja do gry w kółko i krzyżyk
Autor: Marek Traczyński (261748)

----------------------------------
Użyte narzędzia:
    - Julia 1.8.5
    - Julia Sockets

----------------------------------
Uruchamianie programu:
    - Program nie wymaga kompilacji.
    - W celu uruchomienia programu należy wywołać komendę:
        $ julia startgame.jl <adres ip> <numer portu> <numer gracza> <głębokość>
        
    - Numer gracza musi być wartością 1 (X) lub 2 (O).
    - Głębokość musi być wartością z przedziału [1; 10].
    - W przypadku podania błędnego parametru program przerywa działanie, nie próbując łączyć się z serwerem. 

----------------------------------
Dołączone pliki:
    - module/
        - client.jl     ->  klient z parserem komunikatów uzyskiwanych z serwera
        - aiplayer.jl   ->  sztuczna inteligencja z użyciem algorytmu minimax z alfa-beta cięciami
        - heuristic.jl  ->  implementacja heurystyki używanej w algorytmie minimax z pliku aiplayer.jl 
        - utils.jl      ->  dodatkowe stałe, struktury oraz funkcje używane w całym module (głównie w pliku heuristic.jl)
        - TTTPlayer.jl  ->  moduł spinający powyższe pliki w jedną całość
    - startgame.jl  ->  plik rozruchowy odpowiadający za włączenie klienta z podanymi parametrami
    - README.txt

----------------------------------
Dodatkowe uwagi:
    - Każda napisana funkcja jest wyjaśniona w poprzedzającym ją komentarzu (szczególnie te w plikach heuristic.jl oraz utils.jl).
    - W programie używane są typowane globalne stałe, do których wymagana jest wersja Julii 1.8 lub nowsza.