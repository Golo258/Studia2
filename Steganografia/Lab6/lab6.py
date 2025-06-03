import wave
import numpy as np
import matplotlib.pyplot as plt
import struct

def generate_wav(filename, duration_sec=5, frequency_hz=440, sample_rate=44100, amplitude=32767):
    t = np.linspace(0, duration_sec, int(sample_rate * duration_sec), endpoint=False)
    waveform = amplitude * np.sin(2 * np.pi * frequency_hz * t)
    waveform_integers = waveform.astype(np.int16)

    with wave.open(filename, 'w') as wav_file:
        wav_file.setparams((1, 2, sample_rate, 0, 'NONE', 'not compressed'))
        for sample in waveform_integers:
            wav_file.writeframes(struct.pack('<h', sample))

    print(f"{filename} successfully generated.")

def text_to_bits(text):
    return ''.join(f'{ord(char):08b}' for char in text)

def bits_to_text(bits):
    chars = [chr(int(bits[i:i+8], 2)) for i in range(0, len(bits), 8)]
    return ''.join(chars)

def embed_message(input_wav_path, output_wav_path, message):
    with wave.open(input_wav_path, mode='rb') as input_wav:
        params = input_wav.getparams()
        raw_frames = bytearray(input_wav.readframes(input_wav.getnframes()))

    original_audio = np.array(raw_frames, dtype=np.uint8)

    message_bits = text_to_bits(message) + '1111111111111110'  # End marker

    if len(message_bits) > len(raw_frames):
        raise ValueError("Message is too long for the audio file.")

    for i, bit in enumerate(message_bits):
        raw_frames[i] = (raw_frames[i] & 0b11111110) | int(bit)

    with wave.open(output_wav_path, mode='wb') as output_wav:
        output_wav.setparams(params)
        output_wav.writeframes(raw_frames)

    modified_audio = np.array(raw_frames, dtype=np.uint8)
    analyze_audio_quality(original_audio, modified_audio)

def extract_message(encoded_wav_path):
    with wave.open(encoded_wav_path, mode='rb') as encoded_wav:
        raw_frames = bytearray(encoded_wav.readframes(encoded_wav.getnframes()))

    bits = ''.join([str(byte & 1) for byte in raw_frames])

    end_marker = '1111111111111110'
    end_index = bits.find(end_marker)
    if end_index == -1:
        raise ValueError("End marker not found in the encoded audio.")

    return bits_to_text(bits[:end_index])

def analyze_audio_quality(original, modified):
    def calculate_rms(signal):
        return np.sqrt(np.mean(signal.astype(float) ** 2))

    rms_original = calculate_rms(original)
    rms_modified = calculate_rms(modified)
    noise = modified.astype(float) - original.astype(float)
    rms_noise = calculate_rms(noise)
    snr = 20 * np.log10(rms_original / rms_noise) if rms_noise != 0 else float('inf')

    print(f"RMS (original): {rms_original:.2f}")
    print(f"RMS (modified): {rms_modified:.2f}")
    print(f"SNR: {snr:.2f} dB")

    # Plot comparison
    plt.figure(figsize=(10, 4))
    plt.plot(original[:1000], label='Original')
    plt.plot(modified[:1000], label='Modified', alpha=0.7)
    plt.title('Audio Signal Comparison (First 1000 Samples)')
    plt.xlabel('Sample Index')
    plt.ylabel('Amplitude')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig('comparison_plot.png')
    print("Plot saved as comparison_plot.png")



# Generate golonka1.wav
generate_wav('golonka1.wav')
# === USAGE EXAMPLE ===
embed_message('golonka1.wav', 'encoded.wav', 'This is a super secret message hidden in audio.')
print("Extracted message:", extract_message('encoded.wav'))
