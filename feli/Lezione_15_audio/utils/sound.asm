turn_off_sound:
    ld a, %0000000        ;
    ; Shut sound down
    ld [rNR52], a         ; Settando a 0 rNR52 possiamo rimuovere l'audio
    ret                   ;


; Subroutine utilizzata per inizializzare i registri audio
init_audio:
    xor a                                       ;  poniamo a = 0
    ;ld [pres_screen_sound_counter], a           ;  pres_screen_sound_counter = 0
    ld [note_tick], a                           ;  note_tick = 0
    ld [sound_length], a                        ;  sound_length = 0
    ld [sound_pointer], a                       ;  sound_pointer = 0
    ld a, AUDENA_ON                             ;  a = AUDENA_ON
    ld [rNR52], a                               ;  Audio attivato
    ld a, %00111000                             ;  volume iniziale settato 
    ld [rNR12], a          ;                    ;  su medio
    ld a, %10000000                             ;  canale 1 abilitato
    ld [rNR14], a                               ;
    ld a, %01000010                             ; duty cycle 50% 
    ld [rNR21], a                               ;
    ld a, %00110000                             ; volume massimo per canale 2
    ld [rNR22], a                               ;
    ld a, %11000000        
    ld [rNR24], a
    ret


; Questo metodo aggiungera l'indirizzo base di sound_melody alla nota corrente di sound_pointer
; of sound pointer
; @return hl current note
get_current_note:
    ld de, sound_melody             ;
    ld a, [sound_pointer]           ;  Aggiungi l'offset sound_pointer a sound_melody
    add a, e                        ;

    ld e, a 
    jr nc, .no_carry_current_note   ; 
    ld a, d                         ; Controlla se c'è un carry dopo l'addizione
    add a, $1                       ;
    ld d, a                         ;
    .no_carry_current_note
    ld a, [de]                      ;
    ld l, a                         ; salva il valore in hl
    inc de                          ; 
    ld a, [de]                      ;
    ld h, a                         ; 
    ret 



; @param hl l'indirizzo base di una melodia
; @return in l the length of the current note
get_current_sound_length:
    xor a                           ; 
    ld d, a                         ; Ogni indirizzo all'interno di una melodia conterrà
    ld e, a                         ; 
    ld a, $2                        ; 0) 1 byte H nota, 1) 1 byte L nota, 2) 1 byte lunghezza nota
    ld e, a                         ;
    add hl, de                      ; spostiamoci di 2 per ottenere la lunghezza della nota
    ld a, [sound_pointer]           ;
    add a, l                        ; L'indirizzo base dipende dalla variabile sound_pointer
    ld l, a                         ; lo aggiungiamo ad HL per arrivare alla nostra nota corrente
    jr nc, .no_carry_sound_pointer  ; 
    ld a, h                         ;
    add a, $1                       ;
    ld h, a                         ;
    .no_carry_sound_pointer

    ld a, [hl]                      ; ritorna in l la lunghezza della nota corrente
    ld l, a                         ; 
    ret


update_audio:
    ld a, [note_tick]                    ;
    or a, %00000000                      ;  se note_tick è zero, facciamo partire il nuovo suono
    jr z, .play_new_note                 ;  

    ld hl, sound_melody
    call get_current_sound_length        ; Inseriamo in l il sound length
    ld a, [note_tick]                    ; Otteniamo il numero di cicli che attenderemo 
    cp a, l                              ; Controlliamo se son passati tutti
    jr nz, .end_update_note_tick         ; Se non son passati tutti, continua a suonare lo stesso 
                                         ; suono

    ld a, [sound_pointer]                ;
    add a, $4                            ; Se il risultato del cp precedente è zero, passiamo alla 
                                         ; prossima nota
    ld [sound_pointer], a                ; spostiamo sound pointer di 4 (Prossima nota)
    xor a                                ; 
    ld [note_tick], a                    ; Resettiamo note_tick
    ld a, [sound_pointer]                ;
    ld b, a                              ; se sound pointer è lo stesso di sound_melody_n_of_notes
                                         ; ripartiamo dall'inizio
    ld a, [sound_melody_n_of_notes]      ;  
    cp a, b                              ;
    jr nz, .end_update_audio             ; Se invece non è zero, continuiamo con la melodia
    xor a                                ;
    ld [sound_pointer], a                ;
    jp .end_update_audio                 ;
    .play_new_note                       ; NUOVA NOTA
    call get_current_note                ; Inseriamo la nuova nota in hl
    ld a, l                              ;
    ld [rNR13], a                        ; Inseriamo la parte bassa in rNR13
    ld a, h
    ld [rNR14], a                        ; Inseriamo la parte alta in rNR14
    .end_update_note_tick
    ld a, [note_tick]                    ;
    inc a                                ;  Incrementiamo note_tick
    ld [note_tick], a                    ;  aggiorniamolo
    .end_update_audio
    ret


 jump_sound:
    ld hl, G2
    ld a, l
    ld [rNR23], a         ; Load lower part to 13
    ld a, h
    or a, %11000000       ; bit 7 - Channel enabled. 
    ld [rNR24], a         ; bit 6 - Period enabled (Or the sound will play forever). Period depends on nr21
    inc hl
    ret


eat_food_sound:
    ld hl, $06fa
    ld a, l
    ld [rNR23], a         ; Load lower part to 13
    ld a, h
    or a, %11000000       ; bit 7 - Channel enabled. 
    ld [rNR24], a         ; bit 6 - Period enabled (Or the sound will play forever). Period depends on nr21
    inc hl
    ret
