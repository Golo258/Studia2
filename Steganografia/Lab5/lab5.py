# Koch-Zhao image steganography (DCT-based, grayscale, block-wise)

import cv2
import numpy as np

def load_image_grayscale_aligned(path):
    image = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
    height, width = image.shape
    height -= height % 8
    width -= width % 8
    return cv2.resize(image, (width, height))

def apply_dct_blocks(image):
    h, w = image.shape
    dct_result = np.zeros_like(image, dtype=np.float32)
    for y in range(0, h, 8):
        for x in range(0, w, 8):
            block = image[y:y+8, x:x+8]
            dct_result[y:y+8, x:x+8] = cv2.dct(np.float32(block))
    return dct_result

def embed_message_koch_zhao(dct_image, bits, coeff_pair=(3, 4)):
    h, w = dct_image.shape
    idx = 0
    for y in range(0, h, 8):
        for x in range(0, w, 8):
            if idx >= len(bits):
                return dct_image
            block = dct_image[y:y+8, x:x+8]
            c1, c2 = coeff_pair
            bit = bits[idx]
            if bit == 1 and block.flat[c1] <= block.flat[c2]:
                block.flat[c1] += 1
            elif bit == 0 and block.flat[c1] >= block.flat[c2]:
                block.flat[c1] -= 1
            dct_image[y:y+8, x:x+8] = block
            idx += 1
    return dct_image

def apply_idct_blocks(dct_image):
    h, w = dct_image.shape
    result = np.zeros_like(dct_image, dtype=np.uint8)
    for y in range(0, h, 8):
        for x in range(0, w, 8):
            block = dct_image[y:y+8, x:x+8]
            idct_block = cv2.idct(block)
            result[y:y+8, x:x+8] = np.clip(idct_block, 0, 255)
    return result

def extract_embedded_bits(dct_image, bit_count, coeff_pair=(3, 4)):
    extracted = []
    h, w = dct_image.shape
    idx = 0
    for y in range(0, h, 8):
        for x in range(0, w, 8):
            if idx >= bit_count:
                break
            block = dct_image[y:y+8, x:x+8]
            c1, c2 = coeff_pair
            extracted.append(1 if block.flat[c1] > block.flat[c2] else 0)
            idx += 1
    return extracted

# === Example usage ===

image = load_image_grayscale_aligned("house_image.png")
bits_to_hide = [int(b) for b in "1011001110"]
dct = apply_dct_blocks(image)
dct_embedded = embed_message_koch_zhao(dct, bits_to_hide)
image_with_hidden = apply_idct_blocks(dct_embedded)
cv2.imwrite("stego_image.png", image_with_hidden)

dct_for_extraction = apply_dct_blocks(image_with_hidden)
recovered_bits = extract_embedded_bits(dct_for_extraction, len(bits_to_hide))
print("Recovered bits:", recovered_bits)
