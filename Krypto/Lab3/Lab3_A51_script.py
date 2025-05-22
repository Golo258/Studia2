import numpy as np
from PIL import Image
import sys
sys.stdout.reconfigure(encoding='utf-8')

def majority(a, b, c):
    return (a & b) | (a & c) | (b & c)

class A51:
    def __init__(self, key: int, frame_number: int = 0):
        self.key = key
        self.frame_number = frame_number
        self.R1 = np.zeros(19, dtype=np.uint8)
        self.R2 = np.zeros(22, dtype=np.uint8)
        self.R3 = np.zeros(23, dtype=np.uint8)
        self._initialize_registers()

    def _initialize_registers(self):
        self.R1[:] = 0
        self.R2[:] = 0
        self.R3[:] = 0

        for i in range(64):
            bit = (self.key >> i) & 1
            self._clock_all(bit)

        for i in range(22):
            bit = (self.frame_number >> i) & 1
            self._clock_all(bit)

        for _ in range(100):
            self._clock_majority()

    def _clock_all(self, input_bit):
        self.R1 = np.roll(self.R1, 1)
        self.R1[0] = self.R1[13] ^ self.R1[16] ^ self.R1[17] ^ self.R1[18] ^ input_bit

        self.R2 = np.roll(self.R2, 1)
        self.R2[0] = self.R2[20] ^ self.R2[21] ^ input_bit

        self.R3 = np.roll(self.R3, 1)
        self.R3[0] = self.R3[7] ^ self.R3[20] ^ self.R3[21] ^ self.R3[22] ^ input_bit

    def _clock_majority(self):
        m = majority(self.R1[8], self.R2[10], self.R3[10])
        if self.R1[8] == m:
            fb = self.R1[13] ^ self.R1[16] ^ self.R1[17] ^ self.R1[18]
            self.R1 = np.roll(self.R1, 1)
            self.R1[0] = fb
        if self.R2[10] == m:
            fb = self.R2[20] ^ self.R2[21]
            self.R2 = np.roll(self.R2, 1)
            self.R2[0] = fb
        if self.R3[10] == m:
            fb = self.R3[7] ^ self.R3[20] ^ self.R3[21] ^ self.R3[22]
            self.R3 = np.roll(self.R3, 1)
            self.R3[0] = fb

    def get_keystream(self, length: int) -> np.ndarray:
        keystream = np.zeros(length, dtype=np.uint8)
        for i in range(length):
            keystream[i] = (self.R1[18] ^ self.R2[21] ^ self.R3[22]) * 255
            self._clock_majority()
        return keystream

    def encrypt_decrypt(self, data: np.ndarray) -> np.ndarray:
        self._initialize_registers()
        flat_data = data.flatten()
        keystream = self.get_keystream(flat_data.size)
        return np.bitwise_xor(flat_data, keystream).reshape(data.shape)


def process_image(input_path, output_path, key, frame_number=0):
    img = Image.open(input_path).convert("RGB")
    img_data = np.array(img)

    cipher = A51(key, frame_number)
    result_data = cipher.encrypt_decrypt(img_data)

    Image.fromarray(result_data).save(output_path)

# Przykład użycia
process_image('input2.bmp', 'encrypted.bmp', 0x123456789ABCDEF)
process_image('encrypted.bmp', 'decrypted.bmp', 0x123456789ABCDEF)
