import string
import sys
sys.stdout.reconfigure(encoding='utf-8')

POLISH_ALPHABET_BASE = "AĄBCĆDEĘFGHIJKLŁMNŃOÓPRSŚTUWYZŹŻ"
POLISH_GRID_FILLERS = "VQX0"
POLISH_FULL_SET = POLISH_ALPHABET_BASE + POLISH_GRID_FILLERS
POLISH_GRID_SIZE = 6
PAD_CHAR_PL = "X"

ENGLISH_ALPHABET_BASE = string.ascii_uppercase.replace("J", "")
ENGLISH_FULL_SET = ENGLISH_ALPHABET_BASE
ENGLISH_GRID_SIZE = 5
PAD_CHAR_EN = "X"

class PlayfairCipher:
    def __init__(self, key, lang='PL'):
        if lang == 'PL':
            self.grid_size = POLISH_GRID_SIZE
            self.char_pool = POLISH_FULL_SET
            self.pad_char = PAD_CHAR_PL
            self.handle_j_like_i = False
        else:
            self.grid_size = ENGLISH_GRID_SIZE
            self.char_pool = ENGLISH_FULL_SET
            self.pad_char = PAD_CHAR_EN
            self.handle_j_like_i = True

        self.key = key.upper()
        self.table = self.create_table()

    def create_table(self):
        seen = set()
        processed_key = ""
        key = self.key.replace("J", "I") if self.handle_j_like_i else self.key
        for c in key:
            if c in self.char_pool and c not in seen:
                seen.add(c)
                processed_key += c
        table_content = list(processed_key) + [c for c in self.char_pool if c not in seen]
        return [table_content[i:i + self.grid_size] for i in range(0, len(table_content), self.grid_size)]

    def prepare_text(self, text):
        text = text.upper().replace("J", "I") if self.handle_j_like_i else text.upper()
        text = "".join(c for c in text if c in self.char_pool)
        if not text:
            return []
        pairs = []
        i = 0
        while i < len(text):
            a = text[i]
            b = text[i + 1] if i + 1 < len(text) else self.pad_char
            if a == b:
                pairs.append(a + self.pad_char)
                i += 1
            else:
                pairs.append(a + b)
                i += 2
        if len(pairs[-1]) == 1:
            pairs[-1] += self.pad_char
        return pairs

    def find_position(self, letter):
        for row_idx, row in enumerate(self.table):
            if letter in row:
                return row_idx, row.index(letter)
        return None

    def transform_pair(self, pair, encrypt=True):
        a, b = pair
        r1, c1 = self.find_position(a)
        r2, c2 = self.find_position(b)

        if r1 == r2:
            shift = 1 if encrypt else -1
            return self.table[r1][(c1 + shift) % self.grid_size] + self.table[r2][(c2 + shift) % self.grid_size]
        elif c1 == c2:
            shift = 1 if encrypt else -1
            return self.table[(r1 + shift) % self.grid_size][c1] + self.table[(r2 + shift) % self.grid_size][c2]
        else:
            return self.table[r1][c2] + self.table[r2][c1]

    def process(self, text, encrypt=True):
        pairs = self.prepare_text(text)
        return ''.join(self.transform_pair(pair, encrypt) for pair in pairs)

    def encrypt(self, text):
        return self.process(text, encrypt=True)

    def decrypt(self, text):
        return self.process(text, encrypt=False)

    def print_table(self):
        for row in self.table:
            print(" | ".join(row))
        print("-" * (self.grid_size * 4 - 1))


# --- Przykład użycia ---

cipher_pl = PlayfairCipher("Gęś", lang='PL')
text_pl = "grzegorz golonka"
print("Tabela PL:")
cipher_pl.print_table()
encrypted_pl = cipher_pl.encrypt(text_pl)
decrypted_pl = cipher_pl.decrypt(encrypted_pl)

print(f"PL: '{text_pl}' -> {encrypted_pl} -> {decrypted_pl}")

cipher_en = PlayfairCipher("START", lang='EN')
text_en = "Programm"
print("\nTabela EN:")
cipher_en.print_table()
encrypted_en = cipher_en.encrypt(text_en)
decrypted_en = cipher_en.decrypt(encrypted_en)

print(f"EN: '{text_en}' -> {encrypted_en} -> {decrypted_en}")
