; This method will be used to check if player and food are on the same tile, if this is 
; the case the player gets the food
player2_got_food:
    ld a, [oam_buffer_player2_y] ; y
    ld c, a
    ld a, [oam_buffer_player2_x]
    ld b, a  ; x
    call get_tile_by_pixel
    ld e, l                   ;   de contains the tile position of the player
    ld d, h                   ; 

    ld a, [oam_buffer_food_y] ; y
    ld c, a
    ld a, [oam_buffer_food_x]
    ld b, a  ; x
    call get_tile_by_pixel   ; hl contains tile food position

    ; now let's see if hl and de contains the same value
    ld a, h
    cp a, d
    jr nz, .not_equal_player2
    ld a, l
    cp a, e
    jr nz, .not_equal_player2
    .equal_player_2 ; eat the food and update the score
    ;xor a
    ;ld [time_frame_based], a
    ; increase score
    ld hl, $9813       ; 9806 is the second digit of the first player
    ld a, [hl]
    sub $40            ; idx 0 for digits is 40, this way we are normalizing the number, eg. id 42 is 2 minus 40 we have now 2 
    cp a, $9
    jr nz, .modify_second_digit_player2
    ;modify_first_digit and put second digit to 0 which corresponds to $40
    ld a, $40
    ld [hl], a ; second digit set to 0
    ld hl, $9812
    ld a, [hl]
    add $1
    ld [hl], a
    jp .modified_digits_player2
    .modify_second_digit_player2
    ld a, [hl]
    add $1
    ld [hl], a
    .modified_digits_player2
    call spawn_food    
    ; Play animation
    ;call joy_animation_player2
    ld a, [win_points]    ;
    ld b, a               ;
    ld hl, $9812          ; 
    ld a, [hl]            ; If the player has win_points, he W   
    cp a, b               ; 
    jr z, .player2_win     ;
    ; Play sound
    call eat_food_sound
    .not_equal_player2 ; do nothing
    xor a      ; not win
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
    ; Start by setting the state to idle, if it's not the correct state it will be
    ; overwritten by the next instructions
    ld b , %01111100 ; Mask to reset every state but jmp, go down one platfor, falling, swimming and climbing bit
    ld a, [player2_state]
    and b 
    ld [player2_state], a

    ; check if player is underwater
    ld a, [player2_state]
    bit 4, a
    jr z, .not_underwater_p2
    ; if the player is underwater, remove the falling bit
    ld a, %11110111
    ld b, a
    ld a, [player2_state]
    and a, b
    ld [player2_state], a
    ld a, $8d                          ;
    ld [oam_buffer_player2_y], a       ;
    jp .not_climbing
    .not_underwater_p2

    bit 5, a                           ;
    jr z, .not_climbing                ; 
    ld a, [player2_climbing_counter]   ; if player is climbing update the player2_climbing_counter 
    ld b, a                            ; until it hits the player2_climb_max_count
    ld a, [player2_climb_max_count]    ;
    cp a, b                            ;
    jr z, .stop_climbing_animation     ;
    ld a, [player2_climbing_counter]   ;
    add $1                             ;
    ld [player2_climbing_counter], a   ;
    jp .end_p2_position_update         ; until then, don't update player position

    .stop_climbing_animation
    ld b, %11011111                   ;
    ld a, [player2_state]             ; Remove climbing from player state
    and a, b                          ;
    ld [player2_state], a             ;
    xor a                             ;  Reset to 0
    ld [player2_climbing_counter], a  ;  player2_climbing_counter

    ld bc, oam_buffer_player2_y
    ld a, [bc]                        ;  After removing the climbing status from player2 state
    sub a, 6                          ;  Go on top of the obstacle
    ld [bc], a                        ;  
    .not_climbing 
    call reset_positions_player2

    ld a, [player2_state]             ;
    bit 6, a                          ; If bit 6 of player state is set, we want to go down one platform
    jr nz, .go_down_one_platform      ;

    ld a, [player_2_y]
    ld b, a
    ld a, [oam_buffer_food_y]
    cp a, b                   ;  If food is up compared with player2
    jr c, .food_is_up         ;
    ld a, [oam_buffer_food_x]
    ld h, a                 ;  
    ld a, [player_2_x]      ;   If food is down remove the possibility
    cp a, h                 ;   of performing jumps
    jr c, .move_right       ;
    ld a, [player2_state]
    bit 3, a                             ;  If bit falling is set we do not need to go down one platform,
    jp nz, .gravity_check_player2        ;  we are falling already!!
    ld a, [player_2_x]
    cp a, h
    jp z, .go_down_one_platform_status_set
    jp .move_left
    .go_down_one_platform_status_set
    ld a, [player_2_y]     ; Save platform before moving
    ld [platform_y_old], a ; save player2 y + 5 in y old. 
    ld a, [player2_state]     ;
    ld b, a                   ;
    ld a, %01000000           ;
    or a, b                   ; Set the state for going down one platform
    ld [player2_state], a     ;
    .go_down_one_platform 
    ld a, [oam_buffer_player_x]
    ld h, a                 ;
    ld a, [player_2_x]      ;
    cp a, h                 ; 
    jr c, .move_right       ;  Compare the position of player 2 and player 1 and go in player1 
    jp .move_left           ;  direction in order to try and fall down one platform
    .food_is_up
    ld a, [oam_buffer_food_x]
    ld h, a
    ld a, [player_2_x]
    cp a, h
    jr z, .jump             ; if Player2 position is the same as the food, jump
    cp a, h
    jr c, .move_right       ; if the Player2 position is on the left of the food, go right

    .move_left
    ; set player animation to running
    ld b, %00000010
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

    .move_right
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
    call jump_sound
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
    ld a, %00100000                  
    ld [player2_state], a          
    ld bc, oam_buffer_player2_y
    ld a, [bc]                   ;
    sub a, 4                     ;  Put the sprite on the obstacle so it can play the climbing animation
    ld [bc], a                   ;  
    jp .end_p2_position_update
    .go_up_normally_player2
    ld a, [state_jmp_count_player2]
    ld b, $8
    cp b
    jr c, .up_by_three_player2          ;
    .up_by_one_player2                   ;
    ld bc, oam_buffer_player2_y
    ld a, [bc]                   ;
    sub a, 2                     ;  The player will go up by 3 positions at start
    ld [bc], a                   ;  at the before falling, it will slow down
    jp .__up_by                  ;  and it will go up just by 2
    .up_by_three_player2                 ;
    ld bc, oam_buffer_player2_y
    ld a, [bc]                   ;
    sub a, 4                     ;
    ld [bc], a                   ;
    .__up_by
    ; increment by 1 state counter
    ld a, [state_jmp_count_player2]
    add a, 1
    ld [state_jmp_count_player2], a
    ld a, [jp_max_count]
    ld b, a
    ld a, [state_jmp_count_player2]
    cp a, b
    jr z, .start_falling_player2
    jp .no_up_p2
    .start_falling_player2        
    ; Apply gravity on character
    ; No collision, update position
    ld a, $1
    ld [state_jmp_count_player2], a
    ld a, %00001000
    ld [player2_state], a
    .no_up_p2
    call reset_positions_player2
    .p2_not_jumping

    ld a, [player2_state]                ;
    ld b, %00000100                     ;  If player state is jumping 
    and b                               ;  we don't want  
    jp nz, .end_p2_position_update  ;  to apply gravity
    
    .gravity_check_player2
    ld a, [player_2_y]
    add a, 4 ; The check starts from upleft, lets add 4 pixel distance to make it more centered
    sub a, 16-1 ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes this difference
    ld c, a
    ld a, [player_2_x]
    sub a, 8
    ld b, a
    call get_tile_by_pixel ; Returns tile address in hl
    ld a, [hl]
    call is_wall_tile_player2
    jr nz, .no_down_2 
    ld bc, oam_buffer_player2_y
    ld a, [bc]
    add a, $1
    ld [bc], a
    ; When the player is falling will go in the state falling, reset everything but go down one platform and swimming
    ld a, [player2_state]
    and a, %01010000
    ld [player2_state], a
    ld b, a
    ld a, %00001000
    or a, b
    ld [player2_state], a

    bit 6, a
    jp z, .end_p2_position_update
    ; if we went down one platform, remove status go down one platform
    ld a, [platform_y_old]                                   ;
    ld b, a                                                  ;  if old position is 
    ld a, [player_2_y]                                       ;  greater then new y
    sub a, b                                                  ;  we are falling, we can reset
    cp a, $5 
    jr nz, .end_p2_position_update                           ;  our go down state to 0
    ld b , %10111111                                         ; Mask to reset go down one platform bit
    ld a, [player2_state]                 
    and b 
    ld [player2_state], a
    jp .end_p2_position_update
    .no_down_2
    ; If no down condition is met, we are not falling anymore
    ld b , %11110111 ; Mask to reset falling bit

    ; if playery and playeryold are not equal it means that the player2 has hit a new ground,
    ; lets add to the mask the go down one platform
    ld a, [platform_y_old]
    ld c, a 
    ld a, [player_2_y]
    cp a, c
    jr z, .dont_update_mask
    ld b, %10110111
    .dont_update_mask
    ld a, [player2_state]
    and b 
    ld [player2_state], a

    .end_p2_position_update
    ret

player_2_animation:
    ld a, [player2_animation_frame_counter]
    inc a
    ld [player2_animation_frame_counter], a
    cp a, 15 ; Every 10 frames (a tenth of a second), run the following code
    jp nz, .endstatecheckplayer2

    ; Reset the frame counter back to 0
    ld a, 0
    ld [player2_animation_frame_counter], a


    ; if no state is set idle animation will be executed
    ld a, [player2_state]
    or a
    jp z, .gotoplayer2state0
    bit 0, a
    jp nz, .gotoplayer2state0
    bit 1, a
    jp nz, .gotoplayer2state1
    bit 5, a
    jp nz, .gotoplayer2state5   ; Check climbing before falling and jumping
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

    .gotoplayer2state0 ; idle
    ld a, 1
    ld [player2_state], a
    ; Copy the bin data to video ram
    ld hl, $8820
    ld de, player ; Starting address
    ld bc, __player - player ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheckplayer2

    .gotoplayer2state1 ; running
    ; Copy the bin data to video ram
    ld hl, $8820
    ld a, [state_running_count_player2]
    ld b, $1
    cp a, b
    jr nz, .state_running_frame_2
    ; draw frame 1
    ld de, player_state_running_1 ; Starting address
    ld bc, __player_state_running_1 - player_state_running_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ld a, $2
    ld [state_running_count_player2], a
    jp .endstatecheckplayer2
    ; draw frame 2
    .state_running_frame_2
    ld de, player_state_running_2 ; Starting address
    ld bc, __player_state_running_2 - player_state_running_2 ; Length -> it's a subtraciton
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
    ld de, player_state_jmp_1_1 ; Starting address
    ld bc, __player_state_jmp_1_1 - player_state_jmp_1_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; increment by 1 state counter
    ld a, [state_jmp_count_player2]
    add a, 1
    ld [state_jmp_count_player2], a
    jp .endstatecheckplayer2
    .p2_state_2_frame_2
    ; Copy the bin data to video ram
    ld hl, $8820
    ld de, player_state_jmp_1_2 ; Starting address
    ld bc, __player_state_jmp_1_2 - player_state_jmp_1_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    

    .gotoplayer2state3 ; falling
    ; Copy the bin data to video ram
    ld hl, $8820
    ld de, player_state_jmp_1_2 ; Starting address
    ld bc, __player_state_jmp_1_2 - player_state_jmp_1_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; increment by 1 state counter
    jp .endstatecheckplayer2

    .gotoplayer2state4 ; swimming
    ; Copy the bin data to video ram
    ld hl, $8820
    ld a, [state_swimming_count_p2]
    ld b, $1
    cp a, b
    jr nz, .state_swimming_frame_2_p2
    ; draw frame 1
    ld de, player1_state_swimming_2 ; Starting address
    ld bc, __player1_state_swimming_2 - player1_state_swimming_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ld a, $2
    ld [state_swimming_count_p2], a
    jp .endstatecheckplayer2
    ; draw frame 2
    .state_swimming_frame_2_p2
    ld de, player1_state_swimming_1 ; Starting address
    ld bc, __player1_state_swimming_1 - player1_state_swimming_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; reset state to 1
    ld a, $1
    ld [state_swimming_count_p2], a
    jp .endstatecheckplayer2

    .gotoplayer2state5 ; climbing
    ; Copy the bin data to video ram
    ld a, [player2_climbing_counter] ; 
    and $1                           ; if odd execute climbing 2
    jr nz, .climbing_2               ;
    .climbing_1
    ld hl, $8820
    ld de, climbing_1 ; Starting address
    ld bc, __climbing_1 - climbing_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheckplayer2
    .climbing_2
    ld hl, $8820
    ld de, climbing_2 ; Starting address
    ld bc, __climbing_2 - climbing_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheckplayer2

    .gotoplayer2state6 ; powerup
    ; Copy the bin data to video ram
    ld hl, $8820
    ld de, player ; Starting address
    ld bc, __player - player ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheckplayer2


    .endstatecheckplayer2
    ret


; @param a: tile ID
; @return z: set if a is a wall.
is_wall_tile_player2:
    cp a, $02
    jr nz, .not_water_tile_p2
    ld a, %00010000
    ld [player2_state], a
    ret
    .not_water_tile_p2
    or a, $00              ;
    ret
