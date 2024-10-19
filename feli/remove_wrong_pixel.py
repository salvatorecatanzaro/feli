from PIL import Image
import sys

def fix_png_alpha(input_file, output_file):
    image = Image.open(input_file).convert("RGBA")
    pixels = image.load()

    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if 0 < a < 240:
                # Se il pixel non è completamente trasparente o opaco, rendilo opaco
                pixels[x, y] = (r, g, b, 255)

    image.save(output_file, "PNG")

# Esempio di utilizzo
input_img = sys.argv[1]
fix_png_alpha(input_img, "output_fixed.png")

