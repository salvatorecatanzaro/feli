SECTION "Game graphics", ROM0

; Creates the score labels for the player
; no input params needed
presentation_screen:
    xor a                                         ;  Init variable to 0
    ld [presentation_screen_flicker_counter], a   ;
    ; color writing background
    ld a, %10000000                  ;
    ld hl, palettes                  ; Load background palettes into memory
    ld bc, __palettes - palettes     ;
    call set_palettes_bg             ;
    ld hl, $99c4                     ;
    ld de, P_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, R_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, E_                        ;
    ld a, [de]                       ;     ADD SCORE LABEL
    ld [hli], a                      ;     TO THE SCREEN
    ld de, S_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, S_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    inc hl                           ;
    inc hl                           ;
    ld de, S_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, T_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, A_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ; 
    ld de, R_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, T_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    
    ; Turn on the screen
    ; bit 4 select from which bank of vram you want to take tiles: 0 8800 based, 1 8000 based
    ; bit 2 object sprite size 0 = 8x8; 1 = 8x16
    ; bit 1 sprite enabled
    ; Turn on LCD
    ld a, %10000011 ;bg will start from 9800
    ld [rLCDC], a

    ld a, %00000001          ; set vram bank to 1
    ld [rVBK], a             ;
    .start_loop
    halt
    nop
    ld a, [pres_screen_sound_counter]
    add a, $1
    ld [pres_screen_sound_counter], a
    cp a, $1
    jr nz, .dont_play_note 
    call pres_screen_audio
    xor a
    ld [pres_screen_sound_counter], a
    .dont_play_note                                 
    ;Change bg palette every 5 loop                    ;
    ld a, [presentation_screen_flicker_counter]        ;     Every 20 iterations, change the screen
    add a, $1                                          ;     label PRESS START with a new color
    ld [presentation_screen_flicker_counter], a        ;
    cp a, $20                                          ;
    jr nc, .black_press_start                          ;
    .white_press_start
    ld hl, $99c4                                       ;
    ld a, %00000011                                    ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;     PRESS START White color
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    inc hl                                             ;
    inc hl                                             ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    jp .end_presentation_screen_palette_assignation
    .black_press_start
    ld hl, $99c4                                       ;
    ld a, %00000000                                    ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;      PRESS START Black color
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    inc hl                                             ;
    inc hl                                             ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    .end_presentation_screen_palette_assignation
    ld a, [presentation_screen_flicker_counter]        ;
    cp a, $30                                          ;   When the presentation_screen_flicker_counter is $30
    jr nz, .dont_reset_counter                         ;   reset it to 0.
    xor a                                              ;
    ld [presentation_screen_flicker_counter], a        ;
    .dont_reset_counter
    ;Change bg palette every 5 loop

    call get_buttons_state                             ;
    ld a, [buttons]                                    ;
    bit 7, a                                           ;
    jr nz, .start_loop                                 ;
    ld a, %00000000          ; set vram bank to 0      ; 
    ld [rVBK], a             ;                         ;


    ld hl, $5FFF                                       ;
    .bwait                                             ;
    dec HL                                             ;  Busy wait for some instants
    ld a, h                                            ;  fter the user has press start button before
    or l                                               ;  starting the game
    jr nz, .bwait                                      ;

    ; turn off the screen again and wait some seconds
    xor a
    ld [rLCDC], a
    ret


background_presentation_screen:
; The last tile ids of feli_pres_screen are in the adventures_pres_screen file to make 
; the distance between the two sprites smaller
    ld hl, $8800
    ld bc, __adventures_pres_screen - adventures_pres_screen
    ld de, adventures_pres_screen
    call copy_data_to_destination

    ld bc, __adventures_pres_screen_tile_map - adventures_pres_screen_tile_map
    ld hl, $9880
    ld de, adventures_pres_screen_tile_map
    call copy_data_to_destination

    ld hl, $8d40
    ld bc, __feli_pres_screen - feli_pres_screen
    ld de, feli_pres_screen
    call copy_data_to_destination

    ld bc, __feli_pres_screen_tile_map - feli_pres_screen_tile_map
    ld hl, $9800
    ld de, feli_pres_screen_tile_map
    call copy_data_to_destination

    ret

    
wait_vblank:         
  .notvblank           ; definita la label notvblank
  ld a, [$ff44]        ; salviamo in a la coordinata y (la linea che 
                       ; sta disegnando al momento il Game Boy)
                       ; 144 - 153 VBlank area
  cp 144               ; Operazione aritmetica a - 144
  jr c, .notvblank     ; Se c’è un carry non siamo in vblank, ripetiamo 
                       ; il ciclo
  ret


background_assign_attributes:
    ; Il background puo iniziare da $9800 o $9c00 a seconda del valore inserito nel registro rLCDC
    ld a, [rLCDC]              ; Spostiamo il valore di rLCDC in a
    ld b, a                         ; Lo salviamo in b
    ld a, LCDCF_BG9C00          ; carichiamo LCDCF_BG9C00 in a 
    cp a, b                                     ; effettuiamo una sottrazione
    jr z, .bg_start_from_9c00   ; se il valore è zero lo sfondo in utilizzo è $9c00
    .bg_start_from_9800          ; Altrimenti il valore è $9800
    ld de, $9800                          ;
    jp .__bg_start_from            ;
    .bg_start_from_9c00          ;
    ld de, $9c00                          ;
    .__bg_start_from                ;
    ; 0 is the first idx
    ; 3ff is the last idx
    ld hl, $1
    .bg_tile_loop
    ld a, %00000000          ; settiamo la vram bank 0 (Quella dove sono conservati i tiles)
    ld [rVBK], a                   ;
    ld a, [de]                       ; 

    cp a, $0                        ; se l’id dell’indirizzo di memoria corrente è zero
    jr z, .sky_tile               ; allora questo è un tile del cielo, saltiamo alla parte di codice che se          
                                         ; ne occupa
    cp a, $4                      ; l’id 4 rappresenta una zolla di fango
    jr z, .mud_tile           ; saltiamo alla parte di codice che se ne occupa

    cp a, $1                     ; l’id 4 rappresenta una zolla di fango
    jr z, .grass_tile         ; saltiamo alla parte di codice che se ne occupa

    cp a, $2                     ; l’id 4 rappresenta una zolla di fango
    jr z, .water_tile        ; saltiamo alla parte di codice che se ne occupa

    cp a, $3                     ; l’id 4 rappresenta una zolla di fango
    jr z, .water_tile        ; saltiamo alla parte di codice che se ne occupa

    cp a, $5                       ; l’id 4 rappresenta una zolla di fango
    jr z, .grass_mud_tile ; saltiamo alla parte di codice che se ne occupa

    cp a, $6                    ; l’id 4 rappresenta una zolla di fango
    jr z, .cloud_tile        ; saltiamo alla parte di codice che se ne occupa

    .grass_tile
    ld a, %00000001          ; seleziono il bank 1 (Quello destinato agli attributi)
    ld [rVBK], a                   ; inserendo 1 nel registro rVBK
    ld a, %00000001         ; inseriamo in a il valore 1 (Palette 1)
    ld [de], a                       ; lo assegniamo all’indirizzo corrente
    jp .assigned
    .grass_mud_tile
    ld a, %00000001          ; seleziono il bank 1 (Quello destinato agli attributi)
    ld [rVBK], a                    ; inserendo 1 nel registro rVBK
    ld a, %00000101         ; inseriamo in a il valore 5 (Palette 5)
    ld [de], a
    jp .assigned
    .mud_tile
    ld a, %00000001     ; seleziono il bank 1 (Quello destinato agli attributi)
    ld [rVBK], a              ;  inserendo 1 nel registro rVBK
    ld a, %00000010    ; inseriamo in a il valore 2 (Palette 2)
    ld [de], a
    jp .assigned
    .water_tile
    ld a, %00000001       ; seleziono il bank 1 (Quello destinato agli attributi)
    ld [rVBK], a                 ; inserendo 1 nel registro rVBK
    ld a, %10000011       ; inseriamo la palette 3 per l’acqua e il valore 1 in alto sta ad indicare la priorità: Se il personaggio passera in questa tile passera da dietro
    ld [de], a
    jp .assigned
    .cloud_tile
    ld a, %00000001   ; seleziono il bank 1 (Quello destinato agli attributi)
    ld [rVBK], a              ; inserendo 1 nel registro rVBK
    ld a, %00000110   ; inseriamo la palette 6 per le nuvole
    ld [de], a
    jp .assigned
    .sky_tile
    ld a, %00000001    ; seleziono il bank 1 (Quello destinato agli attributi)
    ld [rVBK], a              ; inserendo 1 nel registro rVBK
    ld a, %00000111    ; inseriamo la palette 7 per il cielo
    ld [de], a
    .assigned
    ld a, %00000001          ; seleziono il bank 1 (Quello destinato agli attributi)
    ld [rVBK], a                 ; inserendo 1 nel registro rVBK
    inc de
    inc hl
    ld a, $3                         ;
    cp a, h                          ;
    jr nz, .bg_tile_loop    ;  Continuiamo il ciclo fino a quando non avremo
    ld a, $ff                        ; assegnato un attributo ad ogni tile del bg
    cp a, l                           ;
    jr nz, .bg_tile_loop    ;

    xor a                    ; resettiamo la vram bank a zero
    ld [rVBK], a         ;
    ret

create_score_labels:
    ld hl, $9800
    ld de, S_
    ld a, [de]
    ld [hli], a
    ld de, C_
    ld a, [de]
    ld [hli], a
    ld de, O_
    ld a, [de]
    ld [hli], a
    ld de, R_
    ld a, [de]
    ld [hli], a
    ld de, E_
    ld a, [de]
    ld [hli], a
    inc hl
    ld de, _0
    ld a, [de]
    ld [hli], a
    ld de, _0
    ld a, [de]
    ld [hli], a

    inc hl
    inc hl
    inc hl
    inc hl

    ld de, S_
    ld a, [de]
    ld [hli], a
    ld de, C_
    ld a, [de]
    ld [hli], a
    ld de, O_
    ld a, [de]
    ld [hli], a
    ld de, R_
    ld a, [de]
    ld [hli], a
    ld de, E_
    ld a, [de]
    ld [hli], a
    inc hl
    ld de, _0
    ld a, [de]
    ld [hli], a
    ld de, _0
    ld a, [de]
    ld [hli], a
    ret


water_animation:
    ld a, [water_animation_frame_counter]  ; Carico il valore corrente del     
                                           ; water frame counter
    inc a                                  ; Lo incremento di uno
    ld [water_animation_frame_counter], a  ; Aggiorno la variabile
    cp a, $20                              ; Ogni 20 frame eseguiamo il codice che 
                                           ; segue
    jp nz, .__water_tile_animation         ; Se non son trascorsi 20 frame, non  
                                           ; eseguire il codice

    
    xor a                                  ; accumulatore impostato a zero
    ld [water_animation_frame_counter], a  ; carico zero nel frame counter, 
                                           ; resettandolo

    ld a, [water_animation_counter] ;      ; ora prendo il valore da 
                                           ; water_animation_counter e lo metto 
                                           ; nell’accumulatore
    and $1                                 ; se il numero è dispari (and 1 jr nz)
    jr nz, .water_tile_animation_2         ; disegnamo l’animazione 2
    .water_tile_animation_1                ; Altrimenti disegnamo l’animazione 1
    ld hl, $9a07                           ;
    ld [hl], $3                            ;
    ld hl, $9a08                           ;
    ld [hl], $3                            ;
    ld hl, $9a09                           ;
    ld [hl], $3                            ; 
    ld hl, $9a0a                           ;
    ld [hl], $3                            ; DISEGNO ANIMAZIONE 1 (ID $3)
    ld hl, $9a0b                           ;
    ld [hl], $3                            ;
    ld hl, $9a27                           ;
    ld [hl], $3                            ;
    ld hl, $9a28                           ;
    ld [hl], $3                            ;
    ld hl, $9a29                           ;
    ld [hl], $3                            ;
    ld hl, $9a2a                           ;
    ld [hl], $3                            ;
    ld hl, $9a2b                           ;
    ld [hl], $3                            ;
    
    ld a, [water_animation_counter]
    add $1
    ld [water_animation_counter], a
    jp .__water_tile_animation
    .water_tile_animation_2              ; animazione 2
    ld hl, $9a07                         ;
    ld [hl], $2                          ;
    ld hl, $9a08                         ;
    ld [hl], $2                          ;
    ld hl, $9a09                         ;
    ld [hl], $2                          ;
    ld hl, $9a0a                         ;
    ld [hl], $2                          ;
    ld hl, $9a0b                         ; DISEGNO ANIMAZIONE 2 (ID $2)
    ld [hl], $2                          ;
    ld hl, $9a27                         ;
    ld [hl], $2                          ;
    ld hl, $9a28                         ;
    ld [hl], $2                          ;
    ld hl, $9a29                         ;
    ld [hl], $2                          ;
    ld hl, $9a2a                         ;
    ld [hl], $2                          ;
    ld hl, $9a2b                         ;
    ld [hl], $2                          ;
    xor a                                ;
    ld [water_animation_counter], a      ; resetto a 0 water_animation_counter
    .__water_tile_animation
    
    ret  


; ogni 60 frame incremento time_frame_based di 1
; ogni 60 time_frame_based sposto il cibo nella prossima posizione
food_position_handler:
    ld a, [frame_counter]      ;
    add $1                     ; incremento il frame_counter di uno
    ld [frame_counter], a      ;
    cp a, $1E                  ; controllo se sono passati $1E frame             
    jr nz, .less_then_sixty
    ld a, $1                   ; Se sono passati, resetto il valore a uno
    ld [frame_counter], a      ;
    ld a, [time_frame_based]   ;
    add $1                     ; sono passati n frame, aggiungo uno a time_frame_based
    ld [time_frame_based], a   ;
    cp a, $1E                  ; Se sono passati $1E time_frame_based, sposto il cibo in un'altra 
                               ; posizione sullo schermo
    jr nz, .less_then_sixty    ; 
    ld a, $1                   ;
    ld [time_frame_based], a   ; resetto time_frame_based a 1
    call spawn_food            ; sposto il cibo
    .less_then_sixty
    ret


spawn_food:
    ; food_y_coords e food_y_coords sono gli array delle possibili posizioni del cibo
    ; che abbiamo salvato nella wram

    ld hl, oam_buffer_food_y  ; Prendo la posizione attuale del cibo
    ld de, $81                ; carico $81 in de
    ld bc, food_y_coords      ; carico in bc l'indirizzo dell'array food_y_coords
    call get_new_xy_coords    ; ottengo il nuovo indirizzo (Risultato in bc)
    ld a, [bc]                ; salvo in a
    ld [hl+], a ; y           ; modifico la y del cibo

    ld bc, food_x_coords      ; vedi logica per y
    call get_new_xy_coords
    ld a, [bc]
    ld [hl+], a ; x

    ld a, $81
    ld [hl+], a

    inc hl
    
    ld a, [food_xy_position_counter]  ; incremento il contatore che ci muove negli array delle 
    add $1                            ; possibli posizioni di 1
    ld [food_xy_position_counter], a  ; aggiorno il valore della variabile
    ld b, a                           ; carico in b il valore del contatore
    ld a, [food_array_len]            ; carico la lunghezza dell'array in a
    cp a, b                           ; a - b = ?
    jr nz, .skip_reset                ; non è zero? Non resetto
    xor a                             ; Altrimenti resetto
    ld [food_xy_position_counter], a  ; food_xy_position_counter = 0
    .skip_reset
    ret


; Ottieni la nuova posizione dagli array food_y_coords oppure food_x_coords 
; @params bc uno tra food_y_coords e food_y_coords
; @return bc la nuova x o la nuova y
get_new_xy_coords:
    ld a, [food_xy_position_counter]      ;    Prendi il valore corrente del contatore
    add a, c                              ;    Aggiungi al bit meno significativo la c
    ld c, a                               ;    ricaricalo in c aggiornato

    jr nc, .__end_new_xy_coords           ;    se non c'è stato un carry abbiamo finito
    ld a, b                               ;    Se c'è un carry incrementiamo b di 1
    add a, $1                             ;
    ld b, a                               ;
    .__end_new_xy_coords
    ret