from PIL import Image
import sys
def remove_color(image_path, output_path, target_color, tolerance=0):
    """
    Rimuove un colore specifico dall'immagine e lo sostituisce con il colore di sostituzione.
    
    :param image_path: Percorso dell'immagine di input
    :param output_path: Percorso dell'immagine di output
    :param target_color: Colore da rimuovere (RGBA)
    :param tolerance: Tolleranza per la corrispondenza del colore
    """
    # Apri l'immagine e convertila in RGBA
    img = Image.open(image_path).convert('RGBA')
    pixels = img.load()

    # Converti il colore target in una tupla (RGBA)
    target_color_rgba = (target_color[0], target_color[1], target_color[2], target_color[3])

    def is_similar(color1, color2, tolerance):
        """
        Verifica se due colori sono simili basandosi sulla tolleranza.
        """
        r1, g1, b1, a1 = color1
        r2, g2, b2, a2 = color2
        return (abs(r1 - r2) <= tolerance and
                abs(g1 - g2) <= tolerance and
                abs(b1 - b2) <= tolerance and
                abs(a1 - a2) <= tolerance)

    # Modifica i pixel dell'immagine
    width, height = img.size
    for x in range(width):
        for y in range(height):
            rgba = pixels[x, y]
            if is_similar(rgba, target_color_rgba, tolerance):
                pixels[x, y] = (0, 0, 0, 0)  # Sostituisce con trasparente

    # Salva l'immagine modificata
    img.save(output_path)

# Colore da rimuovere (RGBA)
target_color = (138, 50, 9, 239)  # #8a3209ef

# Esempio di utilizzo
remove_color(sys.argv[1], 'output_image.png', target_color, tolerance=10)

