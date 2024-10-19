from PIL import Image
import sys

def reduce_colors(input_file, output_file, num_colors=4):
    # Apri l'immagine e assicurati che sia in modalità RGBA
    image = Image.open(input_file).convert('RGBA')

    # Usa la funzione quantize per ridurre il numero di colori
    image = image.quantize(colors=num_colors)

    # Salva l'immagine risultante
    image.save(output_file)

# Esempio di utilizzo
reduce_colors(sys.argv[1], "output_fixed.png", num_colors=4)

