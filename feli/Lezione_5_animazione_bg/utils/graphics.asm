SECTION "Game graphics", ROM0[$13c4]


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