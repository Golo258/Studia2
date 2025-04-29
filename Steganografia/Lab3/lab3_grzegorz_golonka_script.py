import numpy as np
from PIL import Image
import random

def text_to_bits(text):
    return ''.join(f'{ord(c):08b}' for c in text)

def bits_to_text(bits):
    chars = [bits[i:i+8] for i in range(0, len(bits), 8)]
    return ''.join([chr(int(b, 2)) for b in chars])

def int_to_bits(value, length):
    return f'{value:0{length}b}'

def bits_to_int(bits):
    return int(bits, 2)

def prepare_image(image_path):
    img = Image.open(image_path).convert("RGBA")
    return img.convert("RGB")

def hide_message(image_path, output_path, message, key):
    image = prepare_image(image_path)
    pixels = np.array(image).astype(np.uint8)
    h, w, c = pixels.shape
    total = h * w * c

    message_bits = text_to_bits(message)
    length_bits = int_to_bits(len(message), 16)
    full_bits = length_bits + message_bits

    if len(full_bits) > total:
        raise ValueError("Message is too long for this image")

    indices = list(range(total))
    random.seed(key)
    random.shuffle(indices)

    flat = pixels.flatten()
    for i, bit in enumerate(full_bits):
        idx = indices[i]
        val = int(flat[idx])
        flat[idx] = np.uint8((val & ~1) | int(bit))
        # flat[idx] = (flat[idx] & ~1) | int(bit)

    new_pixels = flat.reshape((h, w, c))
    Image.fromarray(new_pixels, 'RGB').save(output_path)
    print(f"Message hidden in image: {output_path}")

def extract_message(image_path, key):
    image = prepare_image(image_path)
    pixels = np.array(image).astype(np.uint8)
    h, w, c = pixels.shape
    total = h * w * c

    indices = list(range(total))
    random.seed(key)
    random.shuffle(indices)

    flat = pixels.flatten()
    length_bits = ''.join(str(flat[indices[i]] & 1) for i in range(16))
    msg_length = bits_to_int(length_bits)
    bits_needed = msg_length * 8

    if 16 + bits_needed > total:
        raise ValueError("Invalid message length or corrupted image")

    msg_bits = ''.join(str(flat[indices[i]] & 1) for i in range(16, 16 + bits_needed))
    message = bits_to_text(msg_bits)
    print("Extracted message:", message)

# Przykład użycia
# Ukrycie:
hide_message("input.png", "output.png", "Hello, steganography!", 12345)

# Odczyt:
extract_message("output.png", 12345)
