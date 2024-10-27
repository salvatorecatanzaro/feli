SECTION "OAM-DMA code", ROM0[$0061]

; -- bc: indirizzo base
; -- hl: destinazione da $ff80 to $FFFE
; -- de: lunghezza del codice
copy_in_high_ram:
    ; Questo metodo copia il codice che ha indirizzo che parte da 'bc' e finisce in  'de' Nella high ram
    
    .hram_loop
        ld a, [bc]
        inc bc
        ld [hl+], a
        dec de
        ld a, e
        or d
        jr nz, .hram_loop 
    ret


; definiamo anche il metodo che andremo poi a copiare
; -- Questo metodo attiva un trasferimento DMA 
; -- verso la memoria OAM di tutto ciò che si trova a partire dall’indirizzo $C100
; -- Viene copiato nell hram perchè la cpu puo accedere solo alla hram quando effettua un DMA transfer
dma_copy:
    di
    ld a, $c1
    ld [$ff46], a
    ld a, 40             ; 4 cicli macchina impegnati sotto x 40 = 160 cicli macchina
.loop:
    dec a                ; 1 Ciclo di CPU
    jr nz, .loop         ; 3 Cicli di CPU
    ei
    ret
dma_copy_end:
    nop


 ;sprite_count Il numero di sprites
;sprite_ids   ogni byte contiene 2 sprite id
; ogni OAM sprite è caratterizzato da questi valori
; byte 0 - Y position
; byte 1 - X position
; byte 2 - Tile index (The tile id in the vram)
; byte 3 attributes/flags:
;              7         6       5            4       3       2   1   0
;Attributes  Priority    Y flip  X flip  DMG palette Bank    CGB palette
;
copy_oam_sprites:
    ld a, [sprite_count]        ; copio sprite_count nell’accumulatore
    ld b, a                     ; copio sprite_count in b
    ld de, sprite_ids           ; inserisco sprite_ids in de
    ld hl, oam_buffer_player_y  ; carico l’indirizzo base in hl
.oam_loop
    ld a, [de]
    ld c, $81            ; controllo se in c c’è il valore $81             
    cp a, c              ; se a - e è uguale a zero aggiungiamo gli attributi del 
                         ; cibo
    jr z, .food_attrs    ;

    ld c, $82               ; $82 è l’id del player 2 (La CPU)
    cp a, c                 ; se a - e è 0 inseriamo gli attribute del player 2
    jr z, .player2_attrs    ;

    .player1attrs        ; Se nessuna delle due cond. Precedenti si è verificata,              
                         ; allora è il player 1
    ld a, $55            ; inseriamo $55(sarà la coordinate delle y) in a
    ld [hl+], a ; y      ; carichiamolo nell’indirizzo puntato da hl
    ld a, $0E            ; inseriamo $0E (coordinata x)  
    ld [hl+], a ; x      ;   
    ld a, [de]           ;
    ld [hl+], a          ;
    ld a, %00000000      ; assegniamo 0 a tutti gli attributi
    jp .endattrs
    
    .player2_attrs
    ld a, $55            ; inseriamo $55(sarà la coordinate delle y) in a
    ld [hl+], a ; y      ; carichiamolo all’indirizzo puntato da hl
    ld a, $9A            ; inseriamo $9A in a (Coordinata x)
    ld [hl+], a ; x      ; per poi spostarlo nell’indirizzo puntato da hl
    ld a, [de]
    ld [hl+], a
    ld a, %00000111   ; palette 7 per player 2
    jp .endattrs 
    
    .food_attrs
    ; Vedi descrizione player 1 e player 2

    ld a, $55      
    ld [hl+], a ; y
    ld a, $50
    ld [hl+], a ; x
    ld a, [de]
    ld [hl+], a
    ld a, %00000010

    .endattrs
    ld [hl+], a         ;
    dec b               ; Se ci sono ancora sprite da elaborare, ripeti il ciclo 
    ld a, b             ;
    or b                ;
    inc de   ; chr      ;
    jr nz, .oam_loop    ;
    ret