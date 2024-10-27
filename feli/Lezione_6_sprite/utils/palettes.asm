SECTION "Palettes code", ROM0

set_palettes_bg:
ld [$ff68], a                       ; inseriamo %10000000 in $ff68, questo 
                                    ; significa che popoliamo a partire dalla 
                                    ; palette 0 e che ad ogni colore  
                                    ; inserito incrementiamo di 1 
                                    ; l’indirizzamento andando a popolare il            
                                    ; prossimo colore della palette
.palette_loop
ld a, [hli]                         ; Carico l’indirizzo della prima palette 
ld [$ff69], a                       ; inserisco il colore in $ff69
dec bc
ld a, c
or b
jr nz, .palette_loop                ; ripeto il ciclo fino a quando non 
                                    ; abbiamo inserito tutti i colori
ret