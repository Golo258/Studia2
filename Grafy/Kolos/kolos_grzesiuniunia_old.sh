Zestaw 1:
	12	- ciag liczbowy i czy to jest ciag graficzny 

	Czy istnieje graf prosty o tych stopniach wierzchołków:
		czyli czy ten ciag stopni jest graficzny 
			Sortujesz - malejąco
			Odejmujesz
			Sprawdzasz czy którykolwiek element < 0
			Jak nie – to istnieje graf prosty o takich wierzchołkach

Pattern:
	- Sortujesz malejąco – największy idzie pierwszy ("chce najwięcej kolegów").
	- Sprawdzasz, czy on w ogóle może mieć tylu znajomych:
	- Jak ma np. 6, to MUSI być przynajmniej 6 innych, z którymi się da go połączyć.
	- Jeśli nie ma → ❌ odpada.
	- Usuwasz go z listy – bo teraz się nim zajmujemy.
	- Zabierasz jego x "kolegów" i odejmujesz im po 1 – bo każdy z nich właśnie dostał jedno - połączenie.
	- Powtarzasz to samo z nową listą – znowu sort, znowu największy maruda, itd.

	Jeśli którykolwiek stopień < 0 → ❌ nie jest graficzny.

DONE pierwsze mniej wiecej
#-----------------------------------------------------------

Zestaw 2:
	1
	Minimalna liczba wierzchołkjów przy dane liczbie krawedzi i max stopniu
wzór: MIN_WIERZCHOŁKÓW = (2 × KRAWĘDZIE) ÷ MAX_STOPIEŃ
	np: 54 krawędzie
		max stopień = 4
			n≥ 2⋅54 / 4 = 108 / 4  =27

Zestaw 3:
	8,9,10 -- pojebane nie robie

Zestaw 4:
	1 = czy jest grafem Eulera, narysować cykl

	Graf Eulera:
		graf jest spójny kiedy
			1. da sie przejść z każdego wierzchołka do każdego innego
			- że nie ma takich odłączonych fragmentów tylko sie tworzy takie koło
		    2. każdy wierzchołek ma patrzystą ilośc krawędzi - ( parzysty stopień)

Zestaw 5:
	4, 5, 6

	Kod Prüfera:
		zapisywanie drzewa jako ciągu liczb
			Tylko dla drzew - grafów bez cykli i połączonych
				1. bez cykli - nie ma pętli - nie da się wrócić do startu inną drogą 
				2. spójny - wszystkie połączone, da sie przejsc z każdego do każdego
				3. Zawsze ma n-1 krawędzi przy n wierzchołkach
					np: 7 wierzchołków = 6 krawędzi

		Drzewo z n wierzchołkami -> kod prufera = n - 2 liczb

		Działa to tak:
			jeśli jest drzewem, numerujesz se randomowo, ale najlepiej od lewej do prawej 
			Zliczasz sobie ile jaki wierzchołek ma krawędzi - stopień wierzchołka
			I masz iteracje:
			
		1. znajdz najmniejszy lisc
		2. zapisz sąsiada
		3. usuń liść
		4. zmień stopnie -  bo sąsiad stracił ziomka
		5. Zakończ gdy zostaną 2 wierzchołki.

Wierzchołek	Stopień
		1	1
		2	3
		3	1
		4	1
		5	3
		6	2
		7	1
Iteracja 1:
	Najmniejszy liść: 1
	Jest połączony z 2
	Zapisz: 2
	Usuń 1
	Nowe stopnie:
		2 → 2, reszta bez zmian
Iteracja 2:
	Najmniejszy liść: 3
	Połączony z 2
	Zapisz: 2
	Usuń 3
	Nowe stopnie:
		2 → 1

I tak kurwa dalej, ma wyjśc kod który będzie miał len(ilosc wierzhołków - 2 )

Zadanie 6:
	denryt - wierzchołek o stopniu 1 
	   czyli ma tylko jedną krawędź, jeden sąsiadujący wierzchołek

	Jak obczaić w macierzy:
		policzyć sume każdego wiersza 
			jeśli suma wiersz = 1 - to masz dendryta

A =
	[0, 1, 1] -- suma 2 
	[1, 0, 0] -- suma 1
	[1, 0, 0] -- suma 1 
	odp: 2 dendryty

Zestaw 6:
	3 - wyznaczanie dendrytu minimalnego 

		Dendryty w MST - minmalnym drzewie rozpinajkącym:	
			Budowanie takiego drzewa ilość krawedzi to bedzie ilosc wierzchołków - 1
			Np: 5 wierzch -> 4 krawedzie

		Bierzemy wszystkie wagi miedzy wierzchołkami
		1. Wypisz wszystkie krawędzie z wagami.
		2. Sortujemy rosnąco
		3. I tworzymy takie drzewo z tych wag żeby nie było cykli i minimalny koszt
		potem liczymy stopnie pomiedzy danymi krawedziami i jeśli stopien to 1 to jest dedryt
		4 Kończ przy n - 1 krawędzi 
		5. Po zbudowaniu przelicz które wierzchołki mają stopień 1 - to są dendryty 

		