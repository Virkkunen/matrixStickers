#!/bin/bash

# --- ImageMagick Approach ---

# Usage: ./script.sh input.webp output.webp
# Replace input.webp with your file name.

INPUT_WEBP="$1"
OUTPUT_WEBP_MAGICK="$2"

# Check if both input and output filenames are provided
if [ -z "$INPUT_WEBP" ] || [ -z "$OUTPUT_WEBP_MAGICK" ]; then
  echo "Usage: $0 <input.webp> <output.webp>"
  exit 1
fi

echo "Processing with ImageMagick..."

# Get dimensions (e.g., "640x480") of the first frame
# Using magick identify for compatibility with ImageMagick 7+
dims=$(magick identify -format '%wx%h' "${INPUT_WEBP}[0]")
if [ $? -ne 0 ]; then
    echo "Error: Failed to get dimensions from $INPUT_WEBP. Is it a valid WebP file?"
    exit 1
fi


# Extract width and height
width=$(echo "$dims" | cut -d'x' -f1)
height=$(echo "$dims" | cut -d'x' -f2)

# Determine the maximum dimension (width or height)
max_dim=$(( width > height ? width : height ))

echo "Input dimensions: ${width}x${height}. Target square size: ${max_dim}x${max_dim}."

# Create the square canvas and center the image using ImageMagick
# -coalesce: Necessary for handling animation frames properly.
# -gravity center: Place the original image in the middle of the new canvas.
# -background none: Use a transparent background for the padding area.
#                   Change to 'white', 'black', or a hex color (e.g., '#FF0000') if needed.
# -extent ${max_dim}x${max_dim}: Define the new square canvas size based on the max dimension.
magick "$INPUT_WEBP" -coalesce -gravity center -background none -extent "${max_dim}x${max_dim}" "$OUTPUT_WEBP_MAGICK"

# Check if the magick command was successful
if [ $? -eq 0 ]; then
  echo "ImageMagick processing complete: $OUTPUT_WEBP_MAGICK created successfully."
else
  echo "ImageMagick processing failed. Please check the input file and ImageMagick installation."
  exit 1 # Exit with an error status
fi

exit 0 # Exit successfully

