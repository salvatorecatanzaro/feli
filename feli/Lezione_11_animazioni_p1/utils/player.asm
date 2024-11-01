SECTION "Player", ROM0

try_jump:
    ld a, [buttons]        ; if button A is not pressed, it can not be in hold state
    bit 4, a               ;
    jr z, .holding         ; 
    xor a                  ; reset holding_jump to 0
    ld [holding_jump], a   ;
    .holding
    ; If jumping state, keep on going up
    ld a, [player_state]
    bit 2, a
    jp nz, .jumping
    ; test jump bit
    ld a, [buttons]           
    bit 4, a                  ;  If button A is pressed and 
    jr nz, .not_jumping   
    ld b, $0
    ld a, [holding_jump]
    or b
    jr nz, .not_jumping       ; If A button is not the same press as last loop being hold 
    ld a, $1
    ld [holding_jump], a      ; new A press
    ld a, %00001000           ;  
    ld b, a                   ;
    ld a, [player_state]      ;
    and b                     ;  If Player is falling dont go up
    jr nz, .not_jumping       ; 

    ;JUMP!
    ; when jumping the player can still move left or right
    ; also the gravity will be affecting his position
    .jumping 
    ld a, %00000100
    ld [player_state], a
    ld a, [main_player_y]
    sub a, 16+1 ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes this difference
    ld c, a
    ld a, [main_player_x]
    sub a, 8
    ld b, a
    call get_tile_by_pixel ; Returns tile address in hl
    ld a, [hl]
    call is_wall_tile
    jr nz, .start_falling
    ld a, [state_jmp_count]
    ld b, $8
    cp b
    jr c, .up_by_three           ;
    .up_by_one                   ;
    ld bc, oam_buffer_player_y
    ld a, [bc]                   ;
    sub a, 1                     ;  The player will go up by 3 positions at start
    ld [bc], a                   ;  at the before falling, it will slow down
    jp .__up_by                  ;  and it will go up just by 2
    .up_by_three                 ;
    ld bc, oam_buffer_player_y   ;
    ld a, [bc]                   ;
    sub a, 3                     ;
    ld [bc], a                   ;
    .__up_by
    ; increment by 1 state counter
    ld a, [state_jmp_count]
    add a, 1
    ld [state_jmp_count], a
    ld a, [jp_max_count]
    ld b, a
    ld a, [state_jmp_count]
    cp a, b
    jr z, .start_falling
    jp .no_up
    .start_falling             
    ld a, $1
    ld [state_jmp_count], a
    ld a, %00001000
    ld [player_state], a
    .no_up
    .not_jumping
    call reset_positions
    ret     


try_move_left:
    ld a, [buttons]                   ; carico lo stato dei bottoni nell’accumulatore
    bit 1, a                          ; testo il bit 1 (Dpad a sinistra) 
    jr nz, .no_left                   ; se il valore non è zero il tasto non è stato
    ld b, %00000010                   ; bit per il player state running in b
    ld a, [player_state]              ; carico il player state in a
    or b                              ; aggiungo il bit running al player state
    ld [player_state], a              ; lo ricarico in a
    ; set x flip to 0
    ld a, %00100000                   ; Set del bit xflip
    ld [oam_buffer_player_attrs], a   ; lo inserisco nel byte degli attributi
    ld a, [main_player_y]             ; le coordinate x e y trovate sono un delta che 
    add a, 4                          ; non viene applicato ancora, utilizzato solo per
    sub a, 16                         ; controllare se ci sono collisioni
    ld c, a                           ; Salvo delta y nel registro c
    ld a, [main_player_x]
    sub a, 8+1
    ld b, a                           ; Salvo delta x nel registro b
    call get_tile_by_pixel            ; controllo in quale tile finirebbe il personaggio
    ld a, [hl]                        ; sposto l’output delle subroutine in a
    call is_wall_tile                 ; controllo se quel tile è attraversabile
    jr nz, .no_left                   ; se in a viene salvato zero, non è 
                                      ; attraversabile, salto a .no_left
    ld bc, oam_buffer_player_x
    ld a, [bc]                        ; Aggiorno la posizione perché non ci son state 
    sub a, 1
    ld [bc], a
    .no_left
    call reset_positions
    ret


; vedi commenti try_move_left
try_move_right:
    ld a, [buttons]
    bit 0, a
    jr nz, .no_right
    ; set player animation to running
    ld b, %00000010
    ld a, [player_state]
    or b
    ld [player_state], a
    ; set x flip to 0
    ld a, %00000000
    ld [oam_buffer_player_attrs], a
    ld a, [main_player_y]
    add a, 4  ; don t check collision from the top left of the sprite, but from a more mid position
    sub a, 16 ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes this difference
    ld c, a
    ld a, [main_player_x]
    add a, 4 ; dont start checking from the top left
    sub a, 8-4
    ld b, a
    call get_tile_by_pixel ; Returns tile address in hl
    ld a, [hl]
    call is_wall_tile
    jr nz, .no_right
    ; No collision, update position
    ld bc, oam_buffer_player_x
    ld a, [bc]
    add a, 1
    ld [bc], a
    .no_right
    call reset_positions
    ret


try_apply_gravity:
    ld a, [falling_speed]
    ld b, $12
    cp a, b
    jr c, .fall_slow
    .fall_fast
    ld a, [main_player_y]
    add a, 4 ; The check starts from upleft, lets add 4 pixel distance to make it more centered
    sub a, 16-2 ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes this difference
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
    add a, $2
    ld [bc], a
    jp .__fall_by
    .fall_slow
    ; No collision, update position
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
    ld a, [falling_speed]
    add 1
    ld [falling_speed], a
    .__fall_by

    ; When the player is falling will go in the state falling
    ld a, %00001000
    ld [player_state], a
    ret  ; end_update_player_position
    .no_down
    ld a, $1
    ld [falling_speed], a
    ; If no down condition is met, we are not falling anymore
    ld b , %11110111 ; Mask to reset falling bit
    ld a, [player_state]
    and b 
    ld [player_state], a
    ret
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
    cp a, $02                ; Controlliamo se in a c'è il valore $02
    jr nz, .not_water_tile   ; Se cosi non fosse non è una tile con l'acqua
    ld a, %00010000          ; Se è una tile con l'acqua settiamo il bit 4 a 1
    ld [player_state], a     ; e lo carichiamo in player_state
    ret
    .not_water_tile
    or a, $00              
    ret


reset_positions:
    ld a, [oam_buffer_player_y]
    ld [main_player_y], a
    ld a, [oam_buffer_player_x]
    ld [main_player_x], a
    ret


update_player_position:
    ld b , %00011100 
    ld a, [player_state]
    and b 
    ld [player_state], a

    ld a, [player_state]            ; Carico player_state in a
    bit 4, a                        ; Controllo se il bit 4 è settato
    jr z, .not_underwater           ; se non è settato non siamo sott'acqua
    ld a, $8d                       ; Carico $8d in a 
    ld [oam_buffer_player_y], a     ; lo inserisco nella y del player ($8d è una altezza che 
                                    ; assegnamo al player in modo da far uscire solo la sua testa 
                                    ; dall'acqua) 
    .less_then_d                    ;
    call try_jump                   ; quando siamo sott'acqua
    call try_move_left              ; possiamo avere solo questi tre
    call try_move_right             ; movimenti abilitati

    jp .end_update_player_position
    .not_underwater
    
    call try_move_left
    call try_move_right
    call try_jump
    
    ld a, [player_state]                
    ld b, %00000100                     
    and b                                 
    jp nz, .end_update_player_position  

    

    call try_apply_gravity

    .end_update_player_position
    ret


player_animation:
    ld a, [player_animation_frame_counter]  ;
    inc a                                   ; Il codice che segue viene eseguito 
    ld [player_animation_frame_counter], a  ; ogni 10 frame
    cp a, 10                                ;
    jp nz, .endstatecheck                   ;

    xor a                                   ; Resetto il frame counter a zero
    ld [player_animation_frame_counter], a  ;
    ld a, [player_state]                    ;
    or a                                    ; Se player state è 0, oppure il bit 0
    jp z, .gotostate0                       ; è settato allora saltiamo allo stato 
    bit 0, a                                ; 0 (Idle)
    jp nz, .gotostate0                      ;
    bit 1, a                                ; Se il bit 1 è settato, saltiamo
    jp nz, .gotostate1                      ; allo stato 1
    bit 2, a                                ; se il bit 2 è settato, saltiamo
    jp nz, .gotostate2                      ; allo stato 2
    bit 3, a                                ; …
    jp nz, .gotostate3                      ; …
    bit 4, a                                ; …
    jp nz, .gotostate4                      ; …
    bit 5, a                                ; …
    jp nz, .gotostate5                      ; …
    bit 6, a                                ; Se il bit 6 è settato, saltiamo
    jp nz, .gotostate6                      ; allo stato 6

    .gotostate0 ; idle
    ld a, 1                                 ;
    ld [player_state], a                    ;
    ; Copy the bin data to video ram        ;
    ld hl, $8800                            ; Disegna Il giocatore nello stato 
    ld de, player_1_idle ; Starting address ; IDLE
    ld bc, __player_1_idle - player_1_idle  ; 
    call copy_data_to_destination           ;
    jp .endstatecheck                       ; Salta alla fine della routine

    .gotostate1 ; running                   ;
    ; Copy the bin data to video ram        ;
    ld hl, $8800                            ;
    ld a, [state_running_count]             ;
    ld b, $1                                ;
    cp a, b                                 ;
    jr nz, .state_running_frame_2           ;
    ; draw frame 1                          ;
    ld de, player1_state_running_1          ; Starting address
    ld bc, __player1_state_running_1 - player1_state_running_1
    call copy_data_to_destination           ;
    ld a, $2                                ;
    ld [state_running_count], a             ;
    jp .endstatecheck                       ;
    ; draw frame 2
    .state_running_frame_2
    ld de, player1_state_running_2 ; Starting address
    ld bc, __player1_state_running_2 - player1_state_running_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; reset state to 1
    ld a, $1
    ld [state_running_count], a
    jp .endstatecheck

    .gotostate2 ; jumping
    ld a, [state_jmp_count]
    ld b, $4
    cp a, b
    jr nz, .state_2_frame_2
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player1_state_jmp_1_1 ; Starting address
    ld bc, __player1_state_jmp_1_1 - player1_state_jmp_1_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; increment by 1 state counter
    ld a, [state_jmp_count]
    add a, 1
    ld [state_jmp_count], a
    jp .endstatecheck
    .state_2_frame_2
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player1_state_jmp_1_2 ; Starting address
    ld bc, __player1_state_jmp_1_2 - player1_state_jmp_1_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    

    .gotostate3 ; falling
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player1_state_jmp_1_2 ; Starting address
    ld bc, __player1_state_jmp_1_2 - player1_state_jmp_1_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; increment by 1 state counter
    jp .endstatecheck

    .gotostate4 ; swimming
    ; Copy the bin data to video ram
    ld hl, $8800
    ld a, [state_swimming_count]
    ld b, $1
    cp a, b
    jr nz, .state_swimming_frame_2
    ; draw frame 1
    ld de, player1_state_swimming_2 ; Starting address
    ld bc, __player1_state_swimming_2 - player1_state_swimming_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ld a, $2
    ld [state_swimming_count], a
    jp .endstatecheck
    ; draw frame 2
    .state_swimming_frame_2
    ld de, player1_state_swimming_1 ; Starting address
    ld bc, __player1_state_swimming_1 - player1_state_swimming_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; reset state to 1
    ld a, $1
    ld [state_swimming_count], a
    jp .endstatecheck

    .gotostate5 ; joy
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player ; Starting address
    ld bc, __player - player ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheck

    .gotostate6 ; powerup
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player ; Starting address
    ld bc, __player - player ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheck


    .endstatecheck
    ret