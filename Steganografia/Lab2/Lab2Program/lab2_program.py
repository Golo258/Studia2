import os
import cv2
import numpy as np
import math
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('TkAgg')

BIT_DEPTH = 2
MASK_HIGH = 256 - (1 << BIT_DEPTH)
MASK_LOW = (1 << BIT_DEPTH) - 1
CHARS_PER_PIXEL = math.ceil(8 / BIT_DEPTH)
DELIMITER = '%'


# Czym jest lsb i gdzie jest to w kodzie 

def select_image(directory):
    """Displays available images in a directory and allows user to select one."""
    image_files = [f for f in os.listdir(directory) if f.lower().endswith(('.jpg', '.png', '.jpeg', '.bmp'))]
    
    if not image_files:
        print("No images available in the specified directory.")
        return None

    print("Available images:")
    for i, image in enumerate(image_files):
        print(f"{i + 1}. {image}")

    while True:
        try:
            choice = int(input("Select an image by number: ")) - 1
            if 0 <= choice < len(image_files):
                return os.path.join(directory, image_files[choice])
            print("Invalid selection. Try again.")
        except ValueError:
            print("Enter a valid number.")

def embed_message(image_path, message):
    """Embeds a given message into an image using LSB steganography."""
    try:
        image = cv2.imread(image_path, cv2.IMREAD_ANYCOLOR)
        if image is None:
            raise FileNotFoundError("Image not found. Verify the file path.")

        img_shape = image.shape
        max_capacity = img_shape[0] * img_shape[1] // CHARS_PER_PIXEL
        encoded_message = f"{len(message)}{DELIMITER}{message}"

        if len(encoded_message) > max_capacity:
            raise ValueError(f"Message too large. Maximum capacity: {max_capacity} characters.")

        pixel_data = np.reshape(image, -1)
        for index, char in enumerate(encoded_message):
            encode_character(pixel_data[index * CHARS_PER_PIXEL: (index + 1) * CHARS_PER_PIXEL], char)

        encoded_image = np.reshape(pixel_data, img_shape)
        new_filename = os.path.splitext(image_path)[0] + '_encoded.png'
        cv2.imwrite(new_filename, encoded_image)
        print(f"Message successfully embedded in {new_filename}")
        return new_filename
    except Exception as error:
        print(f"Error: {error}")

def encode_character(pixel_block, character):
    """Encodes a single character into the least significant bits of a pixel block."""
    char_value = ord(character)
    for i in range(len(pixel_block)):
        pixel_block[i] &= MASK_HIGH
        pixel_block[i] |= (char_value >> (BIT_DEPTH * i)) & MASK_LOW

def retrieve_message(image_path):
    """Extracts a hidden message from an image."""
    try:
        image = cv2.imread(image_path, cv2.IMREAD_ANYCOLOR)
        if image is None:
            raise FileNotFoundError("Image not found. Verify the file path.")

        pixel_data = np.reshape(image, -1)
        extracted_text = ""
        index = 0

        while True:
            char_code = 0
            for i in range(CHARS_PER_PIXEL):
                char_code |= (pixel_data[index] & MASK_LOW) << (BIT_DEPTH * i)
                index += 1
            char = chr(char_code)
            if char == DELIMITER:
                break
            extracted_text += char

        message_length = int(extracted_text)
        decoded_message = ""

        for _ in range(message_length):
            char_code = 0
            for i in range(CHARS_PER_PIXEL):
                char_code |= (pixel_data[index] & MASK_LOW) << (BIT_DEPTH * i)
                index += 1
            decoded_message += chr(char_code)

        print("Extracted message:", decoded_message)
        return decoded_message
    except Exception as error:
        print(f"Error: {error}")


def generate_color_matrix(image_path):
    """Generates a visualization of the least significant bits of each color channel."""
    image = cv2.imread(image_path, cv2.IMREAD_COLOR)
    if image is None:
        print("Error: Unable to load image.")
        return

    lsb_r = image[:, :, 2] & 1  # Extract LSB from Red channel
    lsb_g = image[:, :, 1] & 1  # Extract LSB from Green channel
    lsb_b = image[:, :, 0] & 1  # Extract LSB from Blue channel

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    axes[0].imshow(lsb_r * 255, cmap='gray')
    axes[0].set_title("Red Channel LSB")
    axes[1].imshow(lsb_g * 255, cmap='gray')
    axes[1].set_title("Green Channel LSB")
    axes[2].imshow(lsb_b * 255, cmap='gray')
    axes[2].set_title("Blue Channel LSB")

    for ax in axes:
        ax.axis("off")

    plt.show()
    plt.savefig("./assets/lsb_matrix.png")


if __name__ == '__main__':
    default_directory = "./assets"
    chosen_directory = input(
        f"Enter images directory (Enter to use '{default_directory}'): ").strip() or default_directory

    while True:
        print("\nChoose an option:")
        print("1. Hide a message in an image")
        print("2. Extract a message from an image")
        print("3. Generate LSB color matrix")
        print("4. Exit")
        user_choice = input("Enter your choice: ")

        if user_choice == '1':
            image_path = select_image(chosen_directory)
            if image_path:
                message = input("Enter the message to hide: ")
                embed_message(image_path, message)
        elif user_choice == '2':
            image_path = select_image(chosen_directory)
            if image_path:
                retrieve_message(image_path)
        elif user_choice == '3':
            image_path = select_image(chosen_directory)
            if image_path:
                generate_color_matrix(image_path)
        elif user_choice == '4':
            print("Exiting program...")
            break
        else:
            print("Invalid choice. Please try again.")
