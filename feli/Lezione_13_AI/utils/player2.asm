; vedi player1_got_food
player2_got_food:
    ld a, [oam_buffer_player2_y]
    ld c, a
    ld a, [oam_buffer_player2_x]
    ld b, a  ; x
    call get_tile_by_pixel
    ld e, l                   
    ld d, h                    

    ld a, [oam_buffer_food_y]
    ld c, a
    ld a, [oam_buffer_food_x]
    ld b, a  ; x
    call get_tile_by_pixel   

    ld a, h
    cp a, d
    jr nz, .not_equal_player2
    ld a, l
    cp a, e
    jr nz, .not_equal_player2
    .equal_player_2 
    halt    
    nop     
    ; increase score
    ld hl, $9813       
    ld a, [hl]
    sub a, $40            
    cp a, $9
    jr nz, .modify_second_digit_player2
    ld a, $40
    ld hl, $9813
    ld [hl], a 
    ld hl, $9812
    ld a, [hl]
    add a, $1
    ld [hl], a
    jp .modified_digits_player2
    .modify_second_digit_player2
    ld hl, $9813
    ld a, [hl]
    add a, $1
    ld [hl], a
    .modified_digits_player2
    ld a, [win_points]    
    ld b, a               
    ld hl, $9812          
    ld a, [hl]              
    cp a, b               
    jr z, .player2_win     
    call spawn_food    
    ; Play sound
    ;call eat_food_sound  per ora commentato
    .not_equal_player2 
    xor a      
    ret
    .player2_win
    ld a, $ff
    ret

reset_positions_player2:
    ld a, [oam_buffer_player2_y]
    ld [player_2_y], a
    ld a, [oam_buffer_player2_x]
    ld [player_2_x], a
    ret

update_player2_position:
    ; Iniziamo settando il bit iniziale del player2_state ad idle
    ld b , %01111100 ; Mascherando tutti i bit tranne 'salto', 'vai giu di una piattaforma', 'falling', 'swimming' e 'arrampicata'
    ld a, [player2_state]
    and b 
    ld [player2_state], a

    
    ld a, [player2_state]      ; Controllo player2_state
    bit 4, a                   ; Se il bit 4 (Underwater) è popolato
    jr z, .not_underwater_p2   ; Se non lo è salto la parte di codice che riguarda underwater
    ld a, %11110111            ; -
    ld b, a                    ; Rimuovo il falling bit se si trova sott'acqua
    ld a, [player2_state]      ; mascherandolo con i bit %11110111 
    and a, b                   ; 
    ld [player2_state], a      ; -
    ld a, $8d                          ;
    ld [oam_buffer_player2_y], a       ;
    jp .not_climbing           ; se è sott'acqua non puo trovarsi nello stato climbing
    .not_underwater_p2         ; 

    bit 5, a                           ;
    jr z, .not_climbing                ; 
    ld a, [player2_climbing_counter]   ; se il giocatore 2 si sta arrampicando aggiorna il 
    ld b, a                            ; player2_climbing_counter 
    ld a, [player2_climb_max_count]    ; fino a quando non arriva a player2_climb_max_count
    cp a, b                            ;
    jr z, .stop_climbing_animation     ;
    ld a, [player2_climbing_counter]   ;
    add $1                             ;
    ld [player2_climbing_counter], a   ;
    jp .end_p2_position_update         ; Fino a quel momento non aggiorniamo la posizione

    .stop_climbing_animation
    ld b, %11011111                   ;  -
    ld a, [player2_state]             ;  Rimuoviamo il climbing state dal giocatore mettendo
    and a, b                          ;  player2_state in and con %11011111
    ld [player2_state], a             ;  -
    xor a                             ;  Reset a 0
    ld [player2_climbing_counter], a  ;  del player2_climbing_counter

    ld bc, oam_buffer_player2_y
    ld a, [bc]                        ;  Quando rimuoviamo lo stato climbing dal player2
    sub a, 6                          ;  Lo posizioniamo sopra all'ostacolo
    ld [bc], a                        ;  
    .not_climbing 
    call reset_positions_player2

    ld a, [player2_state]             ; Se il bit 6 del giocatore 2 è settato, il cibo si trova
    bit 6, a                          ; In una piattaforma sottostante
    jr nz, .go_down_one_platform      ; saltiamo al codice che gestisce questa situazione

    ld a, [player_2_y]                ; ottengo la y del player2 
    ld b, a                           ; la salvo in b
    ld a, [oam_buffer_food_y]         ; ottengo la y del cibo e la salvo in a
    cp a, b                           ; a - b = ?
    jr c, .food_is_up                 ; se c'è un carry, il cibo si trova sopra
    ld a, [oam_buffer_food_x]         ; IL CIBO SI TROVA SOTTO!, prendo la x del cibo
    ld h, a                           ; salvo in h 
    ld a, [player_2_x]                ; prendo la x del player
    cp a, h                           ; a - h = ?
    jr c, .move_right                 ; se h > a, salto al codice per andare a destra
    ld a, [player2_state]             ; VAI A SINISTRA
    bit 3, a                          ; Se il bit falling è settato, non abbiamo bisogno di muoverci
    jp nz, .gravity_check_player2     ; Siamo già in caduta!!!
    ld a, [player_2_x]                ; prendo la x del player2
    cp a, h                           ; la confronto con la x del cibo
    jp z, .go_down_one_platform_status_set ; Se sono uguali salto al codice che setta a lo stato
                                           ; go down one platform
    jp .move_left                          ; altrimenti devo saltare al codice che sposta verso 
                                           ; sinistra il player2
    .go_down_one_platform_status_set
    ld a, [player_2_y]        ; Prendo la y corrente del player2
    ld [platform_y_old], a    ; La salvo in platform_y_old 
    ld a, [player2_state]     ; prendo lo stato corrente
    ld b, a                   ; 
    ld a, %01000000           ;
    or a, b                   ; Con un or gli aggiungo il bit per indicare hce dobbiamo andare
    ld [player2_state], a     ; giu di una piattaforma
    .go_down_one_platform 
    ld a, [oam_buffer_player_x] ; prendo la x del player 1
    ld h, a                     ; la salvo in h
    ld a, [player_2_x]          ; prendo la x del player 2
    cp a, $53                   ; la confronto con il centro dello schermo 
    jr c, .move_left            ; Confronto la posizione del player2 e il centro dello schermo ($53) 
    jp .move_right              ; Se player2 è alla sinistra dello schermo, va a destra, altrimenti a 
                                ; sinistra
    .food_is_up
    ld a, [oam_buffer_food_x]
    ld h, a
    ld a, [player_2_x]
    cp a, h
    jr z, .jump             ; Se il player 2 si trova al di sotto del cibo, salta 
    cp a, h
    jr c, .move_right       ; Se player 2 si trova alla sinistra del cibo, va a destra

    .move_left              ; In tutti gli altri casi, va a sinistra
    ; set player animation to running 
    ld b, %00000010         ; DA QUI IL CODICE è identico a try_move_left di player1
    ld a, [player2_state]
    or b
    ld [player2_state], a
    ; set x flip to 1
    ld a, %00100111
    ld [oam_buffer_player2_attrs], a
    ld a, [player_2_y]
    add a, 4  ; don t check collision from the top left of the sprite, but from a more mid position
    sub a, 16 ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes this difference
    ld c, a
    ld a, [player_2_x]
    sub a, 8+1
    ld b, a
    call get_tile_by_pixel ; Returns tile address in hl
    ld a, [hl]
    call is_wall_tile_player2
    jr nz, .no_left_p2
    ld a, [oam_buffer_player2_x]
    sub a, 1
    ld [oam_buffer_player2_x], a
    jp .gravity_check_player2 
    .no_left_p2
    jp .jump

    .move_right ; CODICE IDENTICO A try_move_right
    ; set player animation to running
    ld b, %00000010
    ld a, [player2_state]
    or b
    ld [player2_state], a
    ; set x flip to 0
    ld a, %00000111
    ld [oam_buffer_player2_attrs], a
    ld a, [player_2_y]
    add a, 4  ; don t check collision from the top left of the sprite, but from a more mid position
    sub a, 16 ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes this difference
    ld c, a
    ld a, [player_2_x]
    add a, 4 ; dont start checking from the top left
    sub a, 8-4
    ld b, a
    call get_tile_by_pixel ; Returns tile address in hl
    ld a, [hl]
    call is_wall_tile_player2
    jr nz, .no_right_p2
    ld a, [oam_buffer_player2_x]
    add a, 1
    ld [oam_buffer_player2_x], a
    jp .gravity_check_player2
    .no_right_p2
    jp .jump

    .jump
    ;call jump_sound          ; per ora ocmmentato
    ld a, %00001000           ;  
    ld b, a                   ;
    ld a, [player2_state]     ;
    and b                     ;  If Player is falling dont go up
    jr nz, .p2_not_jumping    ;
    ld a, %00000100
    ld [player2_state], a
    ld a, [player_2_y]
    sub a, 16+1 ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes this difference
    ld c, a
    ld a, [player_2_x]
    sub a, 8
    ld b, a
    call get_tile_by_pixel ; Returns tile address in hl
    ld a, [hl]
    call is_wall_tile_player2
    jr z, .go_up_normally_player2
    ; Update state with climbing animation
    ld a, %00100000              ; Se incontra un ostacolo mentre salta, deve andare     
    ld [player2_state], a        ; nello stato climbing
    ld bc, oam_buffer_player2_y  ; prendo la y del player 2
    ld a, [bc]                   ; aggiorno la y per metterlo 
    sub a, 4                     ; nella stessa posizione
                                 ; dell'ostacolo
    ld [bc], a                   ; 
    jp .end_p2_position_update   ; e termino l'aggiornamneto nel ciclo
    .go_up_normally_player2             ; Non ci sono ostacoli, sali normalmente
    ld a, [state_jmp_count_player2]     ; 
    ld b, $8                            ;
    cp b                                ;
    jr c, .up_by_three_player2          ;
    .up_by_one_player2                  ; sale di 1
    ld bc, oam_buffer_player2_y         ;
    ld a, [bc]                          ;
    sub a, 2                            ;  Inizialmente sale di 4
    ld [bc], a                          ;  prima di entrare nello stato falling, sale di 2
    jp .__up_by                         ;  
    .up_by_three_player2                ;
    ld bc, oam_buffer_player2_y
    ld a, [bc]                          ;
    sub a, 4                            ; Sali di 4
    ld [bc], a                          ;
    .__up_by
    ld a, [state_jmp_count_player2]     ; Carico il counter del salto in a
    add a, 1                            ; gli aggiungo 1
    ld [state_jmp_count_player2], a     ; aggiorno state_jmp_count_player2 
    ld a, [jp_max_count]                ; carico in a jp_max_count
    ld b, a                             ; poi lo sposto in b
    ld a, [state_jmp_count_player2]     ; carico in a state_jmp_count_player2
    cp a, b                             ; a - b = ?
    jr z, .start_falling_player2        ; se il risultato è zero, esegui il codice per la caduta
    jp .no_up_p2                        ; altrimenti salta a no_up_p2
    
    .start_falling_player2        
    ld a, $1                            ; carico 1 in a
    ld [state_jmp_count_player2], a     ; resetto a 1 state_jmp_count_player2
    ld a, %00001000                     ;
    ld [player2_state], a               ; Imposto lo stato a falling
    .no_up_p2                           
    call reset_positions_player2        
    .p2_not_jumping

    ld a, [player2_state]               ;
    ld b, %00000100                     ;  se lo stato è jumping
    and b                               ;  non applichiamo la gravità
    jp nz, .end_p2_position_update      ;  
    
    .gravity_check_player2
    ld a, [player_2_y]                  ;
    add a, 4                            ;
    sub a, 16-1                         ;
    ld c, a                             ;
    ld a, [player_2_x]                  ;
    sub a, 8                            ;
    ld b, a                             ;
    call get_tile_by_pixel              ; vedi try_apply_gravity
    ld a, [hl]                          ;
    call is_wall_tile_player2           ;
    jr nz, .no_down_2                   ;
    ld bc, oam_buffer_player2_y         ;
    ld a, [bc]                          ;
    add a, $1                           ;
    ld [bc], a                          ;
    ; Quando player 2 è nello stato falling (Sto applicando la gravitò) resetta tutto tranne go down 
    ; one platform e swimming
    ld a, [player2_state]               ; prendo player state
    and a, %01010000                    ; resetto tutto tranne gli stati sopra citati
    ld [player2_state], a               ;
    ld b, a                             ;
    ld a, %00001000                     ;
    or a, b                             ;
    ld [player2_state], a               ; aggiorno player2_state

    bit 6, a                            ;
    jp z, .end_p2_position_update       ; se il bit go down one platform è settato finisci 
                                        ; l'aggiornamneto
    
    ld a, [platform_y_old]                                   ;
    ld b, a                                                  ;  Se la vecchia y
    ld a, [player_2_y]                                       ;  è maggiore della nuova y
    sub a, b                                                 ;  siamo in volo per scendere di una
    cp a, $5                                                 ;  piattaforma, aspettiamo $5 cicli
    jr nz, .end_p2_position_update                           ;  per poi resettare
    ld b , %10111111                                         ;  il bit vai giu di una piattaforma
    ld a, [player2_state]                                    ;
    and b                                                    ;
    ld [player2_state], a                                    ;
    jp .end_p2_position_update                               ;
    .no_down_2
    ; Se nessuna condizione sopra è stata trovata
    ld b , %11110111         ; maschera per falling bit

    ; Se player_2_y e platform_y_old sono uguali, stiamo ancora provando a scendere
    ; Aggiungiamo il bit scendi di una piattaforma
    ld a, [platform_y_old]
    ld c, a 
    ld a, [player_2_y]
    cp a, c                  ; Se platform_y_old == player_2_y
    jr z, .dont_update_mask  ; non aggiorniamo la maschera
    ld b, %10110111          ; Se platform_y_old != player_2_y aggiorniamo la maschera
    .dont_update_mask
    ld a, [player2_state]    ;
    and b                    ;
    ld [player2_state], a    ; applichiamo la maschera a player2_state

    .end_p2_position_update
    ret

; vedi player_1_animation
player_2_animation:
    ld a, [player2_animation_frame_counter]
    inc a
    ld [player2_animation_frame_counter], a
    cp a, $9 
    jp nz, .endstatecheckplayer2

    ; Reset the frame counter back to 0
    ld a, 0
    ld [player2_animation_frame_counter], a

    ld a, [player2_state]
    or a
    jp z, .gotoplayer2state0
    bit 0, a
    jp nz, .gotoplayer2state0
    bit 1, a
    jp nz, .gotoplayer2state1
    bit 5, a
    jp nz, .gotoplayer2state5
    bit 2, a
    jp nz, .gotoplayer2state2
    bit 3, a
    jp nz, .gotoplayer2state3
    bit 4, a
    jp nz, .gotoplayer2state4
    bit 5, a
    jp nz, .gotoplayer2state5
    bit 6, a
    jp nz, .gotoplayer2state6

    .gotoplayer2state0
    ld a, 1
    ld [player2_state], a
    ld hl, $8820
    ld de, player 
    ld bc, __player - player
    call copy_data_to_destination
    jp .endstatecheckplayer2

    .gotoplayer2state1 ; running
    ld hl, $8820
    ld a, [state_running_count_player2]
    ld b, $1
    cp a, b
    jr nz, .state_running_frame_2
    ; draw frame 1
    ld de, player_state_running_1 
    ld bc, __player_state_running_1 - player_state_running_1 
    call copy_data_to_destination
    ld a, $2
    ld [state_running_count_player2], a
    jp .endstatecheckplayer2
    ; draw frame 2
    .state_running_frame_2
    ld de, player_state_running_2 
    ld bc, __player_state_running_2 - player_state_running_2 
    call copy_data_to_destination
    ; reset state to 1
    ld a, $1
    ld [state_running_count_player2], a
    jp .endstatecheckplayer2

    .gotoplayer2state2 ; jumping
    ld a, [state_jmp_count_player2]
    ld b, $4
    cp a, b
    jr nz, .p2_state_2_frame_2
    ; Copy the bin data to video ram
    ld hl, $8820
    ld de, player_state_jmp_1_1 
    ld bc, __player_state_jmp_1_1 - player_state_jmp_1_1 
    call copy_data_to_destination
    ld a, [state_jmp_count_player2]
    add a, 1
    ld [state_jmp_count_player2], a
    jp .endstatecheckplayer2
    .p2_state_2_frame_2
    ; Copy the bin data to video ram
    ld hl, $8820
    ld de, player_state_jmp_1_2 
    ld bc, __player_state_jmp_1_2 - player_state_jmp_1_2
    call copy_data_to_destination
    

    .gotoplayer2state3
    ld hl, $8820
    ld de, player_state_jmp_1_2 
    ld bc, __player_state_jmp_1_2 - player_state_jmp_1_2 
    call copy_data_to_destination
    jp .endstatecheckplayer2

    .gotoplayer2state4
    ld hl, $8820
    ld a, [state_swimming_count_p2]
    ld b, $1
    cp a, b
    jr nz, .state_swimming_frame_2_p2
    ; draw frame 1
    ld de, player1_state_swimming_2 
    ld bc, __player1_state_swimming_2 - player1_state_swimming_2
    call copy_data_to_destination
    ld a, $2
    ld [state_swimming_count_p2], a
    jp .endstatecheckplayer2
    ; draw frame 2
    .state_swimming_frame_2_p2
    ld de, player1_state_swimming_1
    ld bc, __player1_state_swimming_1 - player1_state_swimming_1 
    call copy_data_to_destination
    ld a, $1
    ld [state_swimming_count_p2], a
    jp .endstatecheckplayer2

    .gotoplayer2state5 ; climbing
    ld a, [player2_climbing_counter]  
    and $1                            
    jr nz, .climbing_2               
    .climbing_1
    ld hl, $8820
    ld de, climbing_1 ; Starting address
    ld bc, __climbing_1 - climbing_1 
    call copy_data_to_destination
    jp .endstatecheckplayer2
    .climbing_2
    ld hl, $8820
    ld de, climbing_2 ; Starting address
    ld bc, __climbing_2 - climbing_2 
    call copy_data_to_destination
    jp .endstatecheckplayer2

    .gotoplayer2state6 ; powerup
    ; Copy the bin data to video ram
    ld hl, $8820
    ld de, player ; Starting address
    ld bc, __player - player
    call copy_data_to_destination
    jp .endstatecheckplayer2


    .endstatecheckplayer2
    ret


; vedi is_wall_tile
is_wall_tile_player2:
    cp a, $02
    jr nz, .not_water_tile_p2
    ld a, %00010000
    ld [player2_state], a
    ret
    .not_water_tile_p2
    or a, $00              
    ret