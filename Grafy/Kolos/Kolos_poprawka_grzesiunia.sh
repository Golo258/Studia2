
Zadania:
    Zestaw 1 - 9 chyba też, 12,13 - ciag liczbowy / czy ciag graficzny
    Zestaw 2 - 1 - lemat uścisków dłoni 
    Zestaw 3 - 8,9,10 - 
    Zestaw 4 - 1  - sprawdzić czy jest grafem i narysować cykl
    Zestaw 5 - 4,5,6 - prufer, kirchow 
    Zestaw 6 -3 - 


Zestaw 1:
    Lemat o sumie stopni wierzchołków:
        w każdym grafie prostym suma stopni wszystkich wierzchołków jest równa 2 razy liczba krawędzi

        Zad 9 example:
            Mamy graf prosty o 2 wierzchołkach stopnia 2, 4 wierzchołkach stopnia 3 oraz 5 wierzchołkach stopnia 4. 
            Ile krawędzi ma graf?

        Liczymy sume stopni wierzchołków:
            2 wierzch stopnia 2 = 2 * 2 = 4
            4 wierzch stopnia 3 = 4 * 3 = 12
            5 wierzch stopnia 4 = 5 * 4 = 20

        Suma = 20 + 12 + 4 = 36 
            Ile krawędzi?
            
            2 * krawedzi  = suma stopni wierzchołków
            2 * krawedzi = 36 / 2
            krawedzi = 18


        Zad 11- kolos:
            Mamy graf prosty o 17 krawędziach, który ma po 3 wierzchołki stopnia 1, 2 i 3. Pozostałe wierzchołki są stopnia 4. 
            Ile wierzchołków ma graf?

            czyli tak z lematu wynosi:
                2 kraw = suma stopni wierzchołków
                17 * 2 = x 
                34 = x

                3 wierzch stopnia 1 = 3 * 1 = 3
                3 wierzch stopnia 2 = 3 * 2 = 6
                3 wierzch stopnia 3 = 3 * 3 = 9
                    Suma: 9 + 6 + 3 = 18 + x stopnia 4 
                
                4x + 18 = 34
                4x = 34 - 18 
                4x = 16
                x = 4 
                Wiec ma 4 wierzchołki stopnia 4 
                Ile wierzchołków 4 + 3 + 3 + 3 = 9 + 4 = 13 

    Zad 12:
        Algorytm Havel-Hakami - szkielet
            1. posortuj malejąco
            2. zdejmuj najwiekszy element d, reszta to lista L
            3. odejmuj 1 od pierwszy d elementów w L
                jeżeli nei możesz (chcesz odjąc 1 od zera) - ciag niedozwolony
            
            4. wróć do kroku 1 z nowym ciagiem (pomniejszonym i posortowanym)
            5. jeżeli skonczysz z samym zerami - graf istnieje

        Ciąg prosty:
            jeśli mamy n wierzchołków np 5 wierzchołków, to nie możęby być wierzchołka z stopniemy wiekszym niż 5 np 6
            Suma wierzchołków musi być parzysta

        Przykład:
            Zad 12:Czy istnieje graf prosty o wierzchołkach 
                A) 6 4 3 2 1
                  6 - najwieskszy, ten wierzhołek chce by połączony z 6 innymi 
                  ale mamy tylko 4 wierzchołki
                  -- nie możliwe do zrealizowania / taki graf nie istnieje
                B) 8 6 5 5 3 3 2
                    8 - najwiekszy 
                    ma tylko 6 możliwych połączeń
                    -- graf nie istnieje

                X)
                    ciąg 5 3 3 2 2 1 
                    5 - najwiekszy odejmujemy
                    _5 2 2 1 1 0 - sort  (2 2 1 1 0)
                     2 - najwiekszy odejmujemy
                    _2 1 1 0 1 0 - sort ( 1 1 0 0)
                     1- najwieksze odejmujemy
                    _1 0 0 0 (0 0 0) - same zera jest git, możę być taki graf

                Y)
                    4 4 3 2 2 1 
                    4- najwiekszy odejmujemy go (4 3 2 2 1)
                    -1 kazdy sąsiadów (3 2 1 1 1)
                    3 -największe - odejmujemy go ( 2 1 1 1)
                    -1 kazdy sąsiadów (1 0 0 1) - sort (1 1 0 0)
                    1 najwieksze - odejmujemy go (1 0 0)
                    -1 sasiad (0 0 0) - koniec 


    Zadanie 13:
        Ciąg graficzny:
            czy istnieje graf prosty, który ma takie stopnie wierzchołków?
            b) 5 4 4 3 2 1 =  5 + 4 + 4 + 3 + 2 +1 = 13 + 5 + 1 = 19 - nie moze byc
                5 4 4 3 2 1 - 
                -5 4 4 3 2 1 - 3 3 2 1 0
                -3 3 2 1 0 - 2 1 0 0 
                -2 1 0 0 - 1 -1 0 - źle
            c)  (7, 4, 4, 3, 2, 2, 2, 1 ,1) = 7 + 8 + 5 +5 + 1 = 15 + 10 + 1 = 26
                -7 4 4 3 2 2 2 1 1 - 3 3 2 1 1 1 0 1 ( sort)
                -3 3 2 1 1 1 1 0 - 2 1 0 1 1 1 0 - sort
                -2 1 1 1 1 0 - 0 0 1 1 0 - sort
                -1 1 0 0 - 0 0 0 - git jest 

        Jak konstruować graf:
            4 3 2 1 1 - wiesz żę jest graficzny
            nazywamy wierzchołki
            A B C D E
            wybieramy najwyższy stopein A - 4 i podłączamy go do 4 innych
            - bez petli ani wielokrotnych krawedzi

Zestaw 2:
    Jaka jest najmniejsza liczba wierzchołków w grafie prostym o 54 krawędziach,
        jeśli stopnie wierzchołków są nie większe niż 4?

    krawędzie = 54
        lemat o sumie stopni
            Suma stopni wierzchołków  = 2 * krawędzie
            x  = 2  * 54 = 108

        Maksymalny możliwy stopień to 4 
        Czyli zakłądamy że każdy wierzchołek ma stopień 4 - bo chcemy zminimalizować ilość wierzchołków
        108/ 4 = 27

        Czyli wzór 2 * liczba krawędzi / max stopień = minimalna liczba wierzchołków
        Zaokrąglamy do góy jak jest float


Zestaw 4:
    Graf Eulera:
        graf spójny - przechodzisz każdą krawędź dokłądnie raz i wracasz do startu
            że nie ma takich odłączonych fragmentów tylko sie tworzy takie koło
        każdy wierzchołek ma patrzy stopień

        1. Sprawdź stopnie - czy parzyste
        2. Czy jest sojny - czy da sie dojść z każdego do każdego
        3. Jeśli tak to znajdz cykle proste - zamkniete trasy
        4. Znajdz cykl Erulera - pełna trasa przez każdą krawędź dokłądnie raz 


    B) 
        1. sprawdzamy parzystość
        i tutaj jest wszystko git jest parzyście wszedzie, środek ma 8 krawędzi wiec tez git 
        2. czy jest spójny, tak, da sie przejsc z każdego do każdego
        3. teraz jakieś cykle proste 
        to se musimy przyjąć jakieś literki drugi screen
        1. A -> K -> C
        2 A-> C -> K -> G -> H -> K -> A 
        i wystarczy
        4. teraz cykl Eulera
        K  A C K E F K G H K E B K

    C)
        Od razu z literkami
            1. Parzystość  wszystkie mają po 2, albo 4 wiec jest git 
            2.  czy spójny, da sie przejsc na przykłąd z D do E, jest takie zamkniete koło wiec jest spójny
            3.  Cykle proste:
            D F B  D 
            E G C E 
            B C A B 
            H F G H
            4. cykl Eulera
              B C G F B A C E G H F D B
            Najpierw to w środku a potem z zewnątrz 

    Zadanie 2 
        A nie wiem pojebane
        B: C A B C D B G H D G E C F G C 


Zestaw 5:
    Drzewo:
        graf spójny- da sie przejsc z kazdego do każdego innego
        acykliczny - nie ma cykli (kółek)
        jeśi ma x wierzchołkó to ma x -1 krawędzi
            10 wierzch -> 9 krawedzi
            liczba krawedzi = liczba wierzchołków - 1

    Zad 2:
        Ile wszystkich wierzchołków ma drzewo, które ma dwa wierzchołki stopnia 5, trzy wierzchołki stopnia 3 i dwa 
        wierzchołki stopnia 2, a reszta jest stopnia 1 

        ilosc krawedzi  = ilosc wierzchołków - 1

        2x krawdzi = suma stopni wierzhołków
        
            dwa wierzh stopnia 5 = 2 * 5 = 10
            trzy wierzch stopnia 3 = 9
            dwa stopnia 2 = 4 
            x stopnia 1 = x 
            10 + 9 + 4 = 23 suma wierzcholków
            2 * x = 23  + x

        Liczba wierzchołków:
            to jest suma danych wierzchołków ( nie patrzym sie na stopnie tylko ogólnie na dane wierzchołki)
                jest 2 wierzch 2 stopnia
                jest 3 wierzch 3 stopnia
                jest 2 wierzch 2 stopnia
                jest x wierzch 1 stopnia
                      czyli mamy 2 + 3 +2 + x = 7 +x = ilosc wierzchołków

        Liczba krawedzi: liczba wierzchołków - 1 
        czyli ( 7 + x) - 1 = 6 + X 

        Wzór: suma stopni = 2 * liczba krawedzi
        23 + x = 2 * ( 6 + x)
        23 + x = 12 + 2x
        23 - 12 = x
        11 = x
        czyli jest 11 wierzchołków stopnia 1 


    Zadanie treningowe:
        Drzewo ma 
        1 wierzchołek stopnia 4 
        4 wierzchołi stopnia 2 
        2 wsierzchołki stopnia 3 
        x wierzchołkó stopnia 1 

        Ile wynosi suma stopni w zaleznosci od x 
        ile jest wszystkich wierzchołków 

        Ilośc wierzchołków
            1 stopnia 4
            4 stopnia 2 
            2 stopnia 3  
            x stopnia 1 
            1 + 4 +2 + x = 7 + x - ilosc wierzchołków ( gdzie x to ilosc wierzchołków stopnia 1)
        
        Suma stopni:
            1 stopnia 4 = 4 
            4 stopnia 2 = 8 
            2 stopnia 3  = 6 
            x stopnia 1  = x
            12 + 6 + x = 18  + x = suma stopni = ilosc krawedzi * 2 
            ilosc krawedzi = ilosc wierzchołków  - 1 
            liczba krawedzi = 7 + x - 1 = 6 + x
            suma stopni = 2 * ilosc krawedzi
            18 + x = 2 * ( 6 + x)
            18 + x = 12 + 2x 
            6 = x 
            x = 6 
            jest 6 wierzchołków stopnia 1 
            wiec razem jest 7 + 6 = 13 wierzchołków
        

    Zadanie 4:
        Podaj kod prufera dla grafu 
            Sposób zakodowania drzewa - spójny acykliczny - jako ciągu lcizb całkowitych
                kod prufera dla x wierzchołków ma x - 2 długość

            1. Numerujemy wierzchołki, od 1 do n, nadajemy im wagi
            2. Wybieramy liść o najmniejszym numerze czyli wierzchołek stopnia 1 
            3. Dopisujemy jego sąsiada do kodu
            4. Usuwamy liść z drzewa
            5. Powtarzym 2- 4 az zostaną2 wierzcholki

        teraz taka bajerka, jest drzewo
        Przykłąd d 
            liczymy wagi
            1 2 5 9 10 to liście
            3  - stopnie 4 
            4, 7 i 8  - stopien 2 
            6 ma stopni 3 

            to liczymy 
            1 -> 3 [ 3 
            2 -> 3 [ 3 3 
            5 -> 3 [ 3 3 3 
            4 staje sie lisciem, 3 ma nadal 2 stopnie
            4-> 3 [ 3 3 3 3 
            3 staje sie lisciem
            3 -> 6 -> [ 3 3 3 3 6 
            9 ->6 [  3 3 3 3 6  6
            7 - 6  [  3 3 3 3 6  6 6 
            6 staje sie lisciem
            6 -> 8 [  3 3 3 3 6  6 6 8 
            i konczymy 
            Zostaja dwa wierzchołki


    Graf Kn - każdy jest połączono z każdym a n to liczba wierzchołków
        Ile dendrytów:
            Kn  = n ^ n - 2 
            K2 = 2 * 2 -2 = 2 * 0 =1 
            K3 = 3 * 3 -2 = 3 *1 = 3
            K4 = 4 * 2 = 16 itd
            