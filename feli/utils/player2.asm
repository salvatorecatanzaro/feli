; This method will be used to check if player and food are on the same tile, if this is 
; the case the player gets the food
player2_got_food:
    ret

reset_positions_player2:
    ld a, [oam_buffer + 8]
    ld [player_2_y], a
    ld a, [oam_buffer + 9]
    ld [player_2_x], a
    ret

update_player2_position:
    ; Start by setting the state to idle, if it's not the correct state it will be
    ; overwritten by the next instructions
    ld b , %00001100 ; Mask to reset every state but jmp and falling bit
    ld a, [player2_state]
    and b 
    ld [player2_state], a

    call reset_positions_player2

    ld a, [oam_buffer + 5]  ; x position of the food
    ld h, a
    ld a, [player_2_x]
    cp a, h
    jr z, .jump
    cp a, h
    jr c, .move_right
    .move_left
    ; set player animation to running
    ld b, %00000010
    ld a, [player2_state]
    or b
    ld [player2_state], a
    ; set x flip to 1
    ld a, %00100001
    ld [oam_buffer + 11], a  ; oam buffer +11 contains player 2 attributes
    ld a, [oam_buffer + 9] ; x pos
    sub a, 1
    ld [oam_buffer + 9], a
    jp .gravity_check_player2   
    .move_right
    ; set player animation to running
    ld b, %00000010
    ld a, [player2_state]
    or b
    ld [player2_state], a
    ; set x flip to 0
    ld a, %00000001
    ld [oam_buffer + 11], a  ; oam buffer +11 contains player 2 attributes
    ld a, [oam_buffer + 9] ; x pos
    add a, 1
    ld [oam_buffer + 9], a
    jp .gravity_check_player2
    .jump
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
    call is_wall_tile
    jr z, .go_up_normally
    ; Update state with climbing animation
    ld a, %00100000
    ld [player2_state], a
    jp .end_p2_position_update
    .go_up_normally
    ld a, [state_jmp_count]
    ld b, $8
    cp b
    jr c, .up_by_three           ;
    .up_by_one                   ;
    ld bc, oam_buffer            ; y pos  
    ld a, [bc]                   ;
    sub a, 1                     ;  The player will go up by 3 positions at start
    ld [bc], a                   ;  at the before falling, it will slow down
    jp .__up_by                  ;  and it will go up just by 2
    .up_by_three                 ;
    ld bc, oam_buffer ; y pos    ;
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
    ; Apply gravity on character
    ; No collision, update position
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
    call is_wall_tile
    jr nz, .no_down_2 
    ld bc, oam_buffer + 8 ; y pos
    ld a, [bc]
    add a, $1
    ld [bc], a
    .no_down_2
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
    ld a, [state_jmp_count]
    ld b, $4
    cp a, b
    jr nz, .state_2_frame_2
    ; Copy the bin data to video ram
    ld hl, $8820
    ld de, player_state_jmp_1_1 ; Starting address
    ld bc, __player_state_jmp_1_1 - player_state_jmp_1_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; increment by 1 state counter
    ld a, [state_jmp_count]
    add a, 1
    ld [state_jmp_count], a
    jp .endstatecheckplayer2
    .state_2_frame_2
    ; Copy the bin data to video ram
    ld hl, $8820
    ld de, player_state_jmp_1_2 ; Starting address
    ld bc, __player_state_jmp_1_2 - player_state_jmp_1_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    

    .gotoplayer2state3 ; falling
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player_state_jmp_1_2 ; Starting address
    ld bc, __player_state_jmp_1_2 - player_state_jmp_1_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; increment by 1 state counter
    jp .endstatecheckplayer2

    .gotoplayer2state4 ; hurt
    ; Copy the bin data to video ram
    ld hl, $8820
    ld de, player ; Starting address
    ld bc, __player - player ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheckplayer2

    .gotoplayer2state5 ; climbing
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player ; Starting address
    ld bc, __player - player ; Length -> it's a subtraciton
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