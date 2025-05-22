import cv2
import numpy as np

def load_color_image_aligned(path):
    image = cv2.imread(path)
    if image is None:
        raise FileNotFoundError(f"[ERROR] Cannot load image: {path}")
    h, w = image.shape[:2]
    h -= h % 8
    w -= w % 8
    resized = cv2.resize(image, (w, h))
    print(f"[INFO] Loaded color image '{path}' resized to {w}x{h}")
    return resized

def apply_dct_blocks(channel):
    h, w = channel.shape
    result = np.zeros_like(channel, dtype=np.float32)
    for y in range(0, h, 8):
        for x in range(0, w, 8):
            block = channel[y:y+8, x:x+8]
            result[y:y+8, x:x+8] = cv2.dct(np.float32(block))
    return result

def apply_idct_blocks(dct_channel):
    h, w = dct_channel.shape
    result = np.zeros_like(dct_channel, dtype=np.uint8)
    for y in range(0, h, 8):
        for x in range(0, w, 8):
            block = dct_channel[y:y+8, x:x+8]
            idct_block = cv2.idct(block)
            result[y:y+8, x:x+8] = np.clip(idct_block, 0, 255)
    return result

def text_to_bits(text):
    return [int(b) for char in text.encode('utf-8') for b in format(char, '08b')]

def bits_to_text(bits):
    chars = []
    for b in range(0, len(bits), 8):
        byte = bits[b:b+8]
        if len(byte) < 8:
            break
        chars.append(chr(int(''.join(map(str, byte)), 2)))
    return ''.join(chars)

def embed_bits_in_channel(dct_channel, bits, coeff_pair=(3, 4), delta=25.0):
    h, w = dct_channel.shape
    idx = 0
    print(f"[INFO] Embedding {len(bits)} bits with delta={delta}")
    for y in range(0, h, 8):
        for x in range(0, w, 8):
            if idx >= len(bits):
                break
            block = dct_channel[y:y+8, x:x+8]
            c1, c2 = coeff_pair
            bit = bits[idx]
            ref = block.flat[c2]
            if bit == 1:
                block.flat[c1] = ref + delta
            else:
                block.flat[c1] = ref - delta
            dct_channel[y:y+8, x:x+8] = block
            print(f"[EMBED] Bit {bit} in block {idx}: c1={block.flat[c1]:.2f}, c2={ref:.2f}")
            idx += 1
    return dct_channel

def extract_bits_from_channel(dct_channel, bit_count, coeff_pair=(3, 4)):
    extracted = []
    h, w = dct_channel.shape
    idx = 0
    print(f"[INFO] Extracting {bit_count} bits")
    for y in range(0, h, 8):
        for x in range(0, w, 8):
            if idx >= bit_count:
                break
            block = dct_channel[y:y+8, x:x+8]
            c1, c2 = coeff_pair
            bit = 1 if block.flat[c1] > block.flat[c2] else 0
            extracted.append(bit)
            print(f"[EXTRACT] Block {idx}: c1={block.flat[c1]:.2f}, c2={block.flat[c2]:.2f} -> bit={bit}")
            idx += 1
    return extracted

# === MAIN ===

image_path = "landscape.jpeg" 
message_text = "Grzegorz"   # default text
bits = text_to_bits(message_text)

color_image = load_color_image_aligned(image_path)
b, g, r = cv2.split(color_image)

dct_b = apply_dct_blocks(b)
dct_b_modified = embed_bits_in_channel(dct_b, bits, delta=5.0)
b_stego = apply_idct_blocks(dct_b_modified)

stego_image = cv2.merge([b_stego, g, r])
cv2.imwrite("landscape_encodee.jpeg", stego_image)
print(f"[INFO] Saved stego image to 'landscape_encodee.png'")

dct_b_extracted = apply_dct_blocks(b_stego)
recovered_bits = extract_bits_from_channel(dct_b_extracted, len(bits))
recovered_message = bits_to_text(recovered_bits)

print(f"\n[RESULT] Original text:   {message_text}")
print(f"[RESULT] Recovered text: {recovered_message}")
