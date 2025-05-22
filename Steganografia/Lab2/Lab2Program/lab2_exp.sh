# 🕵️‍♂️ Steganografia LSB – pełne zrozumienie działania programu

## 🎯 Co to jest steganografia?

Steganografia to technika **ukrywania wiadomości w innej informacji**, np. w obrazku, tak aby **nikt się nie domyślił, że coś jest ukryte**.

W przeciwieństwie do kryptografii (gdzie zaszyfrowana wiadomość jest widoczna), w steganografii **sam fakt istnienia wiadomości ma pozostać tajemnicą**.

---

## 🧠 Czym są najmłodsze bity (LSB)?

Każdy kolor (np. czerwony, zielony, niebieski) w obrazie jest reprezentowany przez **liczbę z zakresu 0–255**,
 co oznacza 8 bitów (np. `10011100`).

Najmłodsze bity to te **najbardziej na prawo** – np. ostatni 1 lub 2 bity:
10011100 → najmłodszy bit to 0

Jeśli zmienimy ten bit z `0` na `1`, mamy:
10011101
olor prawie się nie zmienia – ludzkie oko tego nie zauważy.  
**Dlatego możemy tam ukryć wiadomość, bit po bicie.**

---

## 🏗️ Struktura programu

Program umożliwia:
1. Ukrycie wiadomości w obrazku (`embed_message`)
2. Odczytanie wiadomości z obrazka (`retrieve_message`)
3. Wizualizację najmłodszych bitów koloru (`generate_color_matrix`)

Działa na plikach graficznych: PNG, JPG, BMP.

---

## 🔧 Funkcja: `embed_message(image_path, message)`

### Co robi?
Ukrywa wiadomość tekstową w pikselach obrazka.

### Jak działa krok po kroku:
1. Wczytuje obrazek jako macierz kolorów.
2. Liczy, ile znaków można ukryć w obrazie (w zależności od liczby pikseli).
3. Do wiadomości dokleja informację o długości i znak `%` jako separator, np. `"5%TAJNE"`.
4. Każdy znak zamienia na kod ASCII (np. `"A"` → `65` → `01000001` w bitach).
5. Każde 2 bity z tego znaku zapisuje do końców 4 kolorów pikseli.
6. Tworzy nowy obrazek z ukrytą wiadomością (np. `kot_encoded.png`).

---

## 🔧 Funkcja: `encode_character(pixel_block, character)`

### Co robi?
Ukrywa jeden znak (np. `"A"`) w 4 kolorach (czyli np. wartościach RGB czterech pikseli).

### Jak?
1. Zamienia znak na liczbę (np. `"A"` → 65).
2. Wyciąga z tej liczby po 2 bity:
   - pierwsze 2 bity do 1. koloru,
   - kolejne 2 bity do 2. koloru itd.
3. Wkleja te bity na końcu każdej liczby (czyli w **najmłodsze bity**) – bez zmiany reszty koloru.

### Dlaczego 4 kolory?
Bo każdy znak to 8 bitów, a każdy kolor pomieści 2 bity.  
**4 kolory × 2 bity = 8 bitów = 1 znak**

---

## 🕵️‍♂️ Funkcja: `retrieve_message(image_path)`

### Co robi?
Odczytuje ukrytą wiadomość z najmłodszych bitów obrazka.

### Jak działa krok po kroku:
1. Wczytuje obrazek.
2. Odczytuje po 2 bity z kolejnych kolorów → 4 kolory = 1 znak.
3. Odczytuje znaki aż do znaku `%` – to znaczy, że wcześniej zakodowana była długość wiadomości (np. `"5%"`).
4. Po `%` odczytuje dokładnie tyle znaków, ile wcześniej było zakodowane.
5. Składa znaki i pokazuje wiadomość użytkownikowi.

---

## 🎨 Funkcja: `generate_color_matrix(image_path)`

### Co robi?
Tworzy 3 obrazki (R, G, B), pokazujące najmłodsze bity kolorów.

### Jak wygląda wynik?
- 0 (czyli bit najmłodszy = 0) → kolor biały
- 1 (czyli bit najmłodszy = 1) → kolor czarny

Dzięki temu można wizualnie zobaczyć, gdzie coś było zmienione / ukryte.

---

## 🧮 Zmienna `BIT_DEPTH = 2` – co to znaczy?

To informacja, ile najmłodszych bitów modyfikujemy w każdym kolorze.  
W tym programie są to **2 bity**, co daje:
- więcej miejsca na wiadomość,
- ale też większe ryzyko wykrycia (jeśli ktoś będzie analizował obraz).

---

## ✅ Podsumowanie – dlaczego to działa i dlaczego jest fajne?

- Obrazki zawierają **miliony kolorów**, a każdy kolor ma **8 bitów**.
- Człowiek **nie zauważy zmiany jednego czy dwóch bitów** – ale komputer tak.
- Dlatego można schować tekst, który "siedzi cicho" w pikselach obrazka.
- Program pokazuje cały ten proces – od ukrywania, przez wydobycie, aż po wizualizację najmłodszych bitów.

---

## 📌 Przykład użycia

```bash
$ python lab2_program.py

Choose an option:
1. Hide a message in an image
2. Extract a message from an image
3. Generate LSB color matrix
4. Exit