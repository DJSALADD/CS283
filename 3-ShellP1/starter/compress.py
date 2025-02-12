def compress_rle(filename, output_bin):
    with open(filename, "r") as f:
        data = f.read()

    compressed = []
    count = 1

    for i in range(1, len(data)):
        if data[i] == data[i - 1]:
            count += 1
        else:
            compressed.append((data[i - 1], count))
            count = 1

    # Append the last sequence
    compressed.append((data[-1], count))

    # Write compressed data as bytes
    with open(output_bin, "wb") as f:
        for char, count in compressed:
            f.write(bytes([ord(char), count]))

    print("Compression complete. Saved to", output_bin)

# Run the compression
compress_rle("dragon.txt", "dragon_compressed.bin")
