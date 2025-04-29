
-- DataBase Creation


--select
1: Znajdź autorów [authors] których imię zaczyna się na M a kończy na R

2: Znajdź tytuły [titles] które kończą się znakiem zapytania

3: Znajdź sprzedaże [Sales] których data zamówienia jest pomiędzy 06.1993 a 10.1994

4: Znajdź sklepy [stores] których kod pocztowy znajduje się w przedziale 80000 a 95000

5: Napisz zapytanie które zwróci inicjały wszystkich autorów [authors]

6: Napisz zapytanie które wyświetli numery telefonów autorów [authors] jako numeryczne (bez spacji oraz myślnika: 

7: Napisz Zapytanie które wyświetli w jednym wyniku imię oraz nazwisko autorów oraz pracowników  [authors, employee]

8: Napisz zapytanie które zwróci ilość publikacji z podziałem na lata [titles.pubdate]

9: Znajdź które kategorie książek [titles.type] posiada średnią cenę powyżej 15

10: Napisz zapytanie które zwróci imię, nazwisko, stanowisko pracownika oraz stan w jakim działa jego wydawnictwo [publishers, employee, jobs]
              -dla pracowników zatrudnionych przed 1994 rokiem
              -jeśli stan [publishers.state] nie jest podany należy wyświetlić „NA”
              -wynik posegreguj po nazwie wydawnictwa oraz stanowisku

--create table
11:  W bazie danych [pubs] jest tabela z listą książek [titles]. Należy utworzyć nową tabelę z referencją (do titles:  w której będzie możliwość przechowywania recenzji od użytkowników.

Tabela powinna zawierać takie informacje jak:
- tekst recenzji
- datę dodania recenzji - gdy nie podana powinna być "teraz"
- imię oraz nazwisko recenzenta - może nie być podane
- ocene użytkownika w skali 1 do 5
powinna być możliwość dodania wielu recenzji do jednej książki, uzupełnij tabele o przynajmniej 5 rekordów.

--views
12:    widok podsumowania przychodów poszczególnych autorów[authors, titleauthor, titles, sales]

13:    przychody wydawców z podziałem na miesiące[publishers, titles, sales]

--stored procedures
14:    Napisz funkcje skalarną która oblicza całkowitą sprzedaż książki na podstawie title_id.[sales.qty]

15:    Napisz funkcje skalarną która oblicza średnią cenę książek wydawcy[publisher] na podstawie pub_id [titles.price].

16:    Napisz procedurę która dodaje nowego autora do bazy danych, sprawdzając najpierw, czy autor o podanym imieniu oraz nazwisku już istnieje. Jeśli tak, zwraca błąd. Zwróć uwagę że id nie jest autoinkrementowalne i należy zapewnić w jakiś sposób unikatowy ciąg np czas

17:    Napisz procedure która usuwa książkę dla przekazanego w parametrze id [titles.title_id](prawdopodobnie trzeba więcej delete niż jedna tabela: . Jeśli rekord o danym id nie istnieje należy zwrócić błąd z odpowiednim komunikatem. Spróbować dla title_id = 'BU1032', jeśli potrafisz użyj transakcji.

18:    Napisz procedure która wyświetli podsumowanie sprzedaży(sume z sales.qty:  książek danego autora na podstawie przekazanego id [titleauthor.au_id]. jeśli autor nie istnieje lub nie ma żadnych tytułów nalezy zwrócić błąd z odpowiednim komunikatem.