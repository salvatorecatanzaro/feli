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



; -- Questa subroutine stabilisce le palettes per OBJ
; -- a : palette iniziale (Solitamente 0) | Il bit 7 deve essere impostato a 1 così ad ogni colore 
;        aggiunto automaticamente il puntatore passerà alla prossima palette
; -- hl: indirizzo base delle palette da aggiungere 
; -- bc: lunghezza
set_palettes_obj:
    ld [$ff6a], a      ; Inserisco (solitamente 0) in $ff6a per indicare la prima palette
    .palette_loop_o    
        ld a, [hli]    ; inserisco il contenuto dell'indirizzo hl in a, incremento hl di 1
        ld [$ff6b], a  ; inserisco il valore puntato da hl in $ff6b
        dec bc         ; diminuisco di uno la lunghezza bc
        ld a, c        ; carico c in a
        or b           ; controllo se l'operazione or tra b e c da zero
        jr nz, .palette_loop_o ; se non da zero, non ho finito
    ret