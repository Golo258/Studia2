import sys
sys.stdout.reconfigure(encoding='utf-8')

class IDEA:
    def __init__(self, key: int):
        self.subkeys_enc = []
        self.subkeys_dec = []
        self._generate_encryption_keys(key)
        self._generate_decryption_keys()

    @staticmethod
    def _mul_mod(a, b):
        if a == 0: a = 0x10000
        if b == 0: b = 0x10000
        product = (a * b) % 0x10001
        return product & 0xFFFF if product != 0x10000 else 0

    @staticmethod
    def _add_mod(a, b):
        return (a + b) % 0x10000

    @staticmethod
    def _add_inv(x):
        return (-x) % 0x10000

    @staticmethod
    def _mul_inv(x):
        if x <= 1:
            return x
        t0, t1 = 0, 1
        r0, r1 = 0x10001, x
        while r1:
            q = r0 // r1
            r0, r1 = r1, r0 - q * r1
            t0, t1 = t1, t0 - q * t1
        return t0 % 0x10001

    def _generate_encryption_keys(self, key: int):
        for i in range(52):
            shift = (128 - 16 * (i % 8 + 1)) % 128
            subkey = (key >> shift) & 0xFFFF
            self.subkeys_enc.append(subkey)
            if (i + 1) % 8 == 0:
                key = ((key << 25) | (key >> (128 - 25))) & ((1 << 128) - 1)

    def _generate_decryption_keys(self):
        self.subkeys_dec = []

        self.subkeys_dec += [
            self._mul_inv(self.subkeys_enc[48]),
            self._add_inv(self.subkeys_enc[49]),
            self._add_inv(self.subkeys_enc[50]),
            self._mul_inv(self.subkeys_enc[51]),
        ]

        for i in range(7, -1, -1):
            base = i * 6
            self.subkeys_dec += [
                self._mul_inv(self.subkeys_enc[base]),
                self._add_inv(self.subkeys_enc[base + 2]),
                self._add_inv(self.subkeys_enc[base + 1]),
                self._mul_inv(self.subkeys_enc[base + 3]),
                self.subkeys_enc[base + 4],
                self.subkeys_enc[base + 5],
        ]


    def _round(self, X, subkeys):
        x1, x2, x3, x4 = X
        k1, k2, k3, k4, k5, k6 = subkeys
        y1 = self._mul_mod(x1, k1)
        y2 = self._add_mod(x2, k2)
        y3 = self._add_mod(x3, k3)
        y4 = self._mul_mod(x4, k4)
        t0 = self._mul_mod(y1 ^ y3, k5)
        t1 = self._mul_mod(self._add_mod(y2 ^ y4, t0), k6)
        t2 = self._add_mod(t0, t1)
        return [
            y1 ^ t1,
            y3 ^ t1,
            y2 ^ t2,
            y4 ^ t2,
        ]

    def encrypt_block(self, block: int) -> int:
        X = [
            (block >> 48) & 0xFFFF,
            (block >> 32) & 0xFFFF,
            (block >> 16) & 0xFFFF,
            block & 0xFFFF
        ]
        for i in range(8):
            X = self._round(X, self.subkeys_enc[i * 6:(i + 1) * 6])
            if i != 7:
                X[1], X[2] = X[2], X[1]
        final_keys = self.subkeys_enc[48:]
        Y = [
            self._mul_mod(X[0], final_keys[0]),
            self._add_mod(X[2], final_keys[1]),
            self._add_mod(X[1], final_keys[2]),
            self._mul_mod(X[3], final_keys[3])
        ]
        return (Y[0] << 48) | (Y[1] << 32) | (Y[2] << 16) | Y[3]

    def decrypt_block(self, block: int) -> int:
        X = [
            (block >> 48) & 0xFFFF,
            (block >> 32) & 0xFFFF,
            (block >> 16) & 0xFFFF,
            block & 0xFFFF
        ]

        for i in range(8):
            X = self._round(X, self.subkeys_dec[i * 6:(i + 1) * 6])
            if i != 7:
                X[1], X[2] = X[2], X[1]

        # Ostatnie 4 klucze
        Y = [
            self._mul_mod(X[0], self.subkeys_dec[48]),
            self._add_mod(X[2], self.subkeys_dec[49]),
            self._add_mod(X[1], self.subkeys_dec[50]),
            self._mul_mod(X[3], self.subkeys_dec[51])
        ]
        return (Y[0] << 48) | (Y[1] << 32) | (Y[2] << 16) | Y[3]


# Test example
if __name__ == "__main__":
    key_bin = '0' * 127 + '1'
    plaintext_bin = '0' * 63 + '1'

    key = int(key_bin, 2)
    plaintext = int(plaintext_bin, 2)

    cipher = IDEA(key)
    encrypted = cipher.encrypt_block(plaintext)
    decrypted = cipher.decrypt_block(encrypted)

    print(f"Klucz (bin):      {key:0128b}")
    print(f"Tekst jawny:      {plaintext:064b}")
    print(f"Szyfrogram:       {encrypted:064b}")
    print(f"Odszyfrowany:     {decrypted:064b}")
