from PIL import Image
import os
from IDEA import IDEA


def read_bmp(filename):
    with open(filename, 'rb') as f:
        bmp_header = f.read(54)
        pixel_data = f.read()
    return bmp_header, bytearray(pixel_data)


def write_bmp(filename, bmp_header, pixel_data):
    with open(filename, 'wb') as f:
        f.write(bmp_header)
        f.write(pixel_data)


def pad_data(data, block_size=8):
    padding_len = (block_size - len(data) % block_size) % block_size
    return data + bytes([0] * padding_len), len(data)


def unpad_data(data, original_length):
    return data[:original_length]


def encrypt_bmp(input_file, output_file, key):
    bmp_header, pixel_data = read_bmp(input_file)
    cipher = IDEA(key)
    padded_data, original_length = pad_data(pixel_data)

    encrypted_data = bytearray()
    for i in range(0, len(padded_data), 8):
        block = int.from_bytes(padded_data[i:i + 8], byteorder='big')
        encrypted_block = cipher.encrypt(block)
        encrypted_data.extend(encrypted_block.to_bytes(8, byteorder='big'))

    write_bmp(output_file, bmp_header, encrypted_data)
    print(f"[+] Encrypted BMP saved as {output_file}")


def decrypt_bmp(input_file, output_file, key):
    bmp_header, encrypted_data = read_bmp(input_file)
    cipher = IDEA(key)

    decrypted_data = bytearray()
    for i in range(0, len(encrypted_data), 8):
        block = int.from_bytes(encrypted_data[i:i + 8], byteorder='big')
        decrypted_block = cipher.decrypt(block)
        decrypted_data.extend(decrypted_block.to_bytes(8, byteorder='big'))

    decrypted_data = unpad_data(decrypted_data, len(encrypted_data))
    write_bmp(output_file, bmp_header, decrypted_data)
    print(f"[+] Decrypted BMP saved as {output_file}")


if __name__ == "__main__":
    input_path = "input.bmp"
    enc_path = "encrypted_ecb.bmp"
    dec_path = "decrypted_ecb.bmp"

    # Można ustawić własny klucz dla reprodukowalnych wyników
    key = int.from_bytes(b"1234567890abcdef", byteorder='big')  # 16 bajtów = 128 bitów

    print("[*] Encrypting...")
    encrypt_bmp(input_path, enc_path, key)

    print("[*] Decrypting...")
    decrypt_bmp(enc_path, dec_path, key)
