# 🔐 Steganografia z losową permutacją i LSB – wyjaśnienie działania programu

## 🎯 Cel programu

Program pozwala **ukryć wiadomość tekstową w obrazku** (RGB), modyfikując tylko najmłodsze bity kolorów.  
Dzięki **losowej permutacji** (tasowaniu kolejności pikseli), dane są **rozproszone**, 
trudniejsze do wykrycia i możliwe do odczytania tylko z użyciem poprawnego klucza (`key`).

---

## 🧠 Czym jest LSB?

LSB = Least Significant Bit = **najmniej znaczący bit**.
Każdy kanał koloru (Red, Green, Blue) to liczba od 0 do 255 – czyli 8 bitów.

Przykład:
    Kolor czerwony = 200 = 11001000
    Ostatni bit (`0`) to najmłodszy bit. Jeśli zmienimy go na `1` → mamy:
    11001001 = 201


Zmiana jest tak mała, że **ludzkie oko tego nie zauważy**, ale komputer to rozpozna.

---

## 🧱 Struktura programu

Plik zawiera dwie główne funkcje:
- `hide_message(...)` – ukrywa wiadomość
- `extract_message(...)` – odczytuje wiadomość

Używane są też pomocnicze funkcje do konwersji między tekstem i bitami.

---

## 🔧 Ukrywanie wiadomości – `hide_message(...)`

def hide_message(image_path, output_path, message, key):

1. Wczytanie i przygotowanie obrazu
    img = Image.open(image_path).convert("RGBA")
    return img.convert("RGB")

        Otwieramy obraz jako RGB.
        Dane będą zmieniane tylko w kanałach RGB (bez przezroczystości).

2. Zamiana wiadomości na bity
    message_bits = text_to_bits(message)
    length_bits = int_to_bits(len(message), 16)
    full_bits = length_bits + message_bits
        text_to_bits() zamienia każdy znak na 8 bitów.
        Dodajemy długość wiadomości jako pierwsze 16 bitów, żeby wiedzieć później ile znaków odczytać.
            Przykład: "Hi"
            → length = 2 = 0000000000000010 (16 bitów)
            → "H" = 01001000, "i" = 01101001
            → full_bits = 00000000000000100100100001101001


3. Permutacja – tasowanie kolejności bitów
    indices = list(range(total))
    random.seed(key)
    random.shuffle(indices)

        Tworzymy listę wszystkich możliwych pozycji w tablicy pikseli.
        seed(key) oznacza, że ta sama liczba klucza zawsze da ten sam układ.
        shuffle() tasuje kolejność – i to jest nasza losowa permutacja.


4. Wstawianie bitów do pikseli
    flat = pixels.flatten()
    for i, bit in enumerate(full_bits):
        idx = indices[i]
        val = int(flat[idx])
        flat[idx] = np.uint8((val & ~1) | int(bit))

        Dla każdego bitu wiadomości:
            val & ~1 – usuwa najmłodszy bit (czyli ustawia go na 0),

            | int(bit) – wstawia nasz nowy bit (0 lub 1),

            np.uint8(...) – zachowujemy poprawny format (0–255).

            Po modyfikacji zapisujemy nowy obraz.

1. Wczytanie obrazu i wygenerowanie tej samej permutacji
    random.seed(key)
    random.shuffle(indices)

        Musimy użyć dokładnie tego samego key, żeby permutacja się zgadzała.
        Inaczej odczytamy bzdury.


2. Odczyt długości wiadomości
    length_bits = ''.join(str(flat[indices[i]] & 1) for i in range(16))
    msg_length = bits_to_int(length_bits)
        Odczytujemy pierwsze 16 bitów – one mówią, ile znaków ukryto.
        flat[indices[i]] & 1 wyciąga najmłodszy bit z danego koloru.


3. Odczyt właściwej wiadomości
    msg_bits = ''.join(str(flat[indices[i]] & 1) for i in range(16, 16 + bits_needed))
    message = bits_to_text(msg_bits)
        Odczytujemy dokładnie msg_length * 8 bitów.
        Składamy bity w znaki i wypisujemy tekst.

