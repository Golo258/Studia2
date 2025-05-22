import numpy as np
import cv2


# cos za alfa i smiesznym czyms jak to jest zapisywane 
#  kanale niebieskim jest zapisywana, losowany seed 

def read_txt(path='message.txt'):
    with open(path, 'r', encoding='utf-8') as f:
        txt = f.read()

    bin_txt = [list(map(int, format(ord(char), '08b'))) for char in txt]
    # Konwersja listy list do macierzy NumPy
    bin_array = np.array(bin_txt, dtype=np.uint8)

    return txt, bin_array



def kjb_write(rgb_img, bin_txt, L=0.15, r=11):
    h, w, _ = rgb_img.shape
    s = bin_txt.shape

    coord_y = np.random.randint(4, h - 3, size=(s[0], s[1], r))
    coord_x = np.random.randint(4, w - 3, size=(s[0], s[1], r))
    coords = np.stack((coord_y, coord_x), axis=3)  # shape: (row, column, r, 2)

    img_with_data = rgb_img.copy().astype(np.float32)

    for i in range(s[0]):
        for j in range(s[1]):
            for k in range(r):
                y, x = coords[i, j, k]

                # Oblicz luminancję Y
                R = rgb_img[y, x, 2]
                G = rgb_img[y, x, 1]
                B = rgb_img[y, x, 0]
                Y = 0.298 * R + 0.586 * G + 0.114 * B
                if Y == 0:
                    Y = 5 / L

                delta = L * Y
                if bin_txt[i, j] == 1:
                    img_with_data[y, x, 0] += delta  # increase blue canal
                else:
                    img_with_data[y, x, 0] -= delta  # decrease blue canal

                img_with_data[y, x, 0] = np.clip(img_with_data[y, x, 0], 0, 255)

    img_with_data = img_with_data.astype(np.uint8)

    return img_with_data, s, coords

def kjb_pull_out(rgb_img_txt, s, coords, sigma=4, r=11):
    txt_new_bin = np.zeros((s[0], s[1]), dtype=np.uint8)

    for i in range(s[0]):
        for j in range(s[1]):
            kat = []
            for k in range(r):
                y, x = coords[i, j, k]
                top = float(np.sum(rgb_img_txt[y - sigma:y + sigma + 1, x, 0]))
                left = float(np.sum(rgb_img_txt[y, x - sigma:x + sigma + 1, 0]))
                center = float(rgb_img_txt[y, x, 0])
                pred = (top + left - 2 * center) / (4 * sigma)
                del_val = float(center) - pred

                if del_val == 0 and pred == 255:
                    del_val = 0.5
                elif del_val == 0 and pred == 0:
                    del_val = -0.5

                kat.append(1 if del_val > 0 else 0)

            txt_new_bin[i, j] = round(sum(kat) / r)

    txt_new = ""
    for row in txt_new_bin:
        val = int("".join(str(bit) for bit in row), 2)
        if 32 <= val <= 126:
            txt_new += chr(val)
        else:
            txt_new += '?'

    return txt_new


def main():
    rgb_img = cv2.imread('BMW-e36.bmp')
    txt, bin_txt = read_txt('message.txt')
    print(txt)

    img_with_data, s, coords = kjb_write(rgb_img, bin_txt)
    cv2.imwrite('encoded_image.bmp', img_with_data)

    txt_new = kjb_pull_out(img_with_data, s, coords)
    print(txt_new)

if __name__ == '__main__':
    main()