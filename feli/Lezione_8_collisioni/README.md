# Lezione 8 - Collisioni

Ogni qual volta il nostro personaggio si sposta sullo schermo è necessario controllare se questa operazione è possibile. Il controllo delle collisioni del personaggio con la mappa può essere effettuato in diversi modi, nel caso di questo gioco è stata creata insieme alla mappa dei tile una mappa delle collisioni che definiamo nella ROM

*file: utils/rom.asm*
```
collision_map:
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
    db $01, $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $01, $01, $01, $01, $01, $01, $01, $01, 1,1,1,1,1,1,1,1,1,1,1,1
    db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, 1,1,1,1,1,1,1,1,1,1,1,1
__collision_map:

```

Descriviamo brevemente la mappa delle collisioni
•   $00 Il personaggio può passare
•   $01 Il personaggio non può passare è un muro
•   $02 Il personaggio può passare ma ci sono condizioni particolari da gestire perché si trova in acqua

Per ognuno dei movimenti descritti nei capitoli precedenti aggiungeremo della logica, in particolare ci sono due subroutine che controlleranno in quale tile si trova il personaggio dopo aver modificato la propria posizione e se quel tile è attraversabile

Nel file player modifichiamo le subroutine try_move_left, try_move_right e try_apply_gravity 

*file: utils/player.asm*
```
try_move_left:
    ld a, [buttons]              ; carico lo stato dei bottoni nell’accumulatore
    bit 1, a                     ; testo il bit 1 (Dpad a sinistra)
    jr nz, .no_left              ; se il valore non è zero il tasto non è stato 
                                 ; premuto
    ld a, [main_player_y]        ;
    add a, 4                     ; 
    sub a, 16                    ; le coordinate x e y trovate sono un delta che 
                                 ; non viene applicato ancora, utilizzato solo per     
                                 ; controllare se ci sono collisioni
    ld c, a                      ; Salvo delta y nel registro c
    ld a, [main_player_x]        ; 
    sub a, 8+1                   ;
    ld b, a                      ; Salvo delta x nel registro b
    call get_tile_by_pixel ;     ; controllo in quale tile finirebbe il 
                                 ; personaggio
    ld a, [hl]                   ; sposto l’output delle subroutine in a
    call is_wall_tile            ; controllo se quel tile è attraversabile
    jr nz, .no_left              ; se in a viene salvato zero, non è 
                                 ; attraversabile, salto a .no_left
    ld bc, oam_buffer_player_x   ;
    ld a, [bc]                   ; Aggiorno la posizione perché non ci son state 
                                 ; collisioni
    sub a, 1                     ;
    ld [bc], a                   ;
    .no_left                     ;
    call reset_positions
    ret


; vedi commenti try_move_left
try_move_right:
    ld a, [buttons]
    bit 0, a
    jr nz, .no_right
    ld a, [main_player_y]
    add a, 4 
    sub a, 16
    ld c, a
    ld a, [main_player_x]
    add a, 4
    sub a, 8-4
    ld b, a
    call get_tile_by_pixel
    ld a, [hl]
    call is_wall_tile
    jr nz, .no_right
    
    ld bc, oam_buffer_player_x
    ld a, [bc]
    add a, 1
    ld [bc], a
    .no_right
    call reset_positions
    ret


try_apply_gravity:
    ld a, [main_player_y]
    add a, 4 ; The check starts from upleft, lets add 4 pixel distance to make it more centered
    sub a, 16-1 ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes this difference
    ld c, a
    ld a, [main_player_x]
    sub a, 8
    ld b, a
    call get_tile_by_pixel ; Returns tile address in hl
    ld a, [hl]
    call is_wall_tile
    jr nz, .no_down 
    ld bc, oam_buffer_player_y
    ld a, [bc]
    add a, $1
    ld [bc], a 
    ret

```

Andiamo quindi ad aggiungere le subroutine get_tile_by_pixel e is_wall_tile utilizzate per la gestione delle collisioni.

*file utils/player.asm*
```
; Converte le coordinate in pixel in un indirizzo della tilemap
; hl = $9800 + X + Y * 32
; @param b: X
; @param c: Y
; @return hl: tile address
; 
get_tile_by_pixel:
    ; Prima di tutto dividiamo per 8 per convertire la posizione di un pixel nella 
    ; posizione di un tile.
    ; Successivamente moltiplichiamo la posizione y per 32
    ld a, c               ; carico la y nel registro a             
    srl a                 ; 
    srl a                 ; effettuo 3 shift dei bit a sinistra
    srl a ;  y / 8        ; ovvero una divisione per 8
    ld l, a               ; salvo il risultato in l
    ld h, 0               ; inserisco 0 in h

    add hl, hl            ; posizione * 2
    add hl, hl            ; ..
    add hl, hl            ; ..
    add hl, hl            ; ..
    add hl, hl            ; posizione * 32

    ld a, b         ; carico la x nel registro a
    srl a ; a / 2   ; divido per 8
    srl a ; a / 4   ;
    srl a ; a / 8   ;
    add a, l        ; sommo la a con l
    ld l, a         ; carico il risultato in l
    ld a, 0         ; 
    adc a, h        ; 
    ld h, a         ; 
    
    ld bc, collision_map ;
    add hl, bc           ; sommo l’indirizzo ottenuto a collision map
    ret                  ; per ottenere in hl il valore del tile nel quale il 
                         ; personaggio si sta spostando


; @param a: tile ID
; @return z: ritorna 0 in a se il tile è un muro.
is_wall_tile:
    or a, $00              ;
    ret
```
Compiliamo il codice e ora il personaggio dovrebbe collidere
