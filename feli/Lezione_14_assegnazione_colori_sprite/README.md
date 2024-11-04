# Lezione 11 - Assegnazione colori sprite

Finora abbiamo assegnato gli attributi agli sprite, ma non abbiamo ancora generato la nostra selezione di palette dedicata ad essi.

Per farlo, nel file main, aggiungiamo subito dopo la chiamata alla subroutine il codice *set_palettes_obj*, che definiamo poi nel file palettes

---
*file: main.asm*
```
    ld a, %10000000                              ;
    ld hl, obj_palettes                          ; Assegnazione palette sprites
    ld bc, __obj_palettes - obj_palettes         ;
    call set_palettes_obj                        ;
```
*file: utils/palettes.asm*
```
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
```
---

Il pezzo mancante per l'assegnazione dei colori è l'aggiunta nella ROM di *obj_palettes*, che inseriremo subito dopo la definizione delle palette per il background.

---
*file: utils/rom.asm*
```
obj_palettes:
    db $5a, $5a, $5a, $8c, $8f, $89, $EE, $C5        ; la selezione dei colori degli sprite (OBJ)
    db $00, $00, $00, $00, $00, $00, $00, $00        ;
    db $8f, $89, $00, $00, $19, $80, $8f, $89        ;
__obj_palettes:
```
---

Compiliamo ed eseguiamo il codice.
```
# cd /<directory_del_progetto/feli/
# ./run_program.<estensione>
# java -jar Emulicius/Emulicius.jar feli.gbc
```

Noteremo che ad ogni partita il giocatore due cambia colore. Questo succede perche mentre per il background abbiamo definito tutte le palette, per gli oggetti ne abbiamo definite soltanto tre e nella subroutine *copy_oam_sprites* assegnamo la palette 0 al giocatore uno e la palette 1 al cibo, mentre per il giocatore due riserviamo la palette 7 che non essendo stata definita cambia ad ogni partita. Un possibile esercizio per il lettore potrebbe essere quello di provare ad aggiungere una palette fissa per il giocatore due.
