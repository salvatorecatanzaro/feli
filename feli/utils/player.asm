SECTION "Player", rom0

reset_positions:
    ld a, [oam_buffer_player_y]
    ld [main_player_y], a
    ld a, [oam_buffer_player_x]
    ld [main_player_x], a
    ret

try_move_left:
    ld a, [buttons]
    bit 1, a
    jr nz, .no_left
    ; set player animation to running
    ld b, %00000010
    ld a, [player_state]
    or b
    ld [player_state], a
    ; set x flip to 0
    ld a, %00100000
    ld [oam_buffer_player_attrs], a
    ld a, [main_player_y]
    add a, 4  ; don t check collision from the top left of the sprite, but from a more mid position
    sub a, 16 ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes this difference
    ld c, a
    ld a, [main_player_x]
    sub a, 8+1
    ld b, a
    call get_tile_by_pixel ; Returns tile address in hl
    ld a, [hl]
    call is_wall_tile
    jr nz, .no_left
    ; No collision, update position
    ld bc, oam_buffer_player_x
    ld a, [bc]
    sub a, 1
    ld [bc], a
    .no_left
    call reset_positions
    ret

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
    call jump_sound
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


try_apply_gravity:
    ; Apply gravity on character
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

update_player_position:
    ; Start by setting the state to idle, if it's not the correct state it will be
    ; overwritten by the next instructions
    ld b , %00011100 ; Mask to reset every state but jmp, falling, and in water bit
    ld a, [player_state]
    and b 
    ld [player_state], a

    ; check if player is underwater
    ld a, [player_state]
    bit 4, a
    jr z, .not_underwater
    ld a, $8d                             ;
    ld [oam_buffer_player_y], a        ;
    .less_then_d
    call try_jump                      ; Always allowed to jump out of water
    call try_move_left              ;
    call try_move_right             ;

    jp .end_update_player_position
    .not_underwater
    
    call try_move_left
    call try_move_right
    call try_jump
    
    ld a, [player_state]                ;
    ld b, %00000100                     ;  If player state is jumping 
    and b                               ;  we don't want  
    jp nz, .end_update_player_position  ;  to apply gravity

    

    call try_apply_gravity

    .end_update_player_position
    ret


; Convert a pixel position to a tilemap address
; hl = $9800 + X + Y * 32
; @param b: X
; @param c: Y
; @return hl: tile address
; 
; Calculates the tile value based on x,y coordinates 98EB
get_tile_by_pixel:
    ; First, we need to divide by 8 to convert a pixel position to a tile position.
    ; After this we want to multiply the Y position by 32.
    ; These operations effectively cancel out so we only need to mask the Y value.
    ld a, c
    srl a
    srl a 
    srl a ;  y / 8
    ld l, a
    ld h, 0
    ; Now we have the position * 8 in hl
    add hl, hl ; position * 2
    add hl, hl ; 
    add hl, hl ; 
    add hl, hl ; 
    add hl, hl ; position * 32
    ; Convert the X position to an offset.
    ld a, b
    srl a ; a / 2
    srl a ; a / 4
    srl a ; a / 8
    ; Add the two offsets together.
    add a, l
    ld l, a
    ld a, 0
    adc a, h
    ld h, a
    ; Add the offset to the tilemap's base address, and we are done!
    ld bc, collision_map
    add hl, bc
    ret

; @param a: tile ID
; @return z: set if a is a wall.
is_wall_tile:
    cp a, $02
    jr nz, .not_water_tile
    ld a, %00010000
    ld [player_state], a
    ret
    .not_water_tile
    or a, $00              ;
    ret

player_animation:
    ld a, [player_animation_frame_counter]
    inc a
    ld [player_animation_frame_counter], a
    cp a, 10 ; Every 10 frames (a tenth of a second), run the following code
    jp nz, .endstatecheck

    ; Reset the frame counter back to 0
    xor a
    ld [player_animation_frame_counter], a


    ; if no state is set idle animation will be executed
    ld a, [player_state]
    or a
    jp z, .gotostate0
    bit 0, a
    jp nz, .gotostate0
    bit 1, a
    jp nz, .gotostate1
    bit 2, a
    jp nz, .gotostate2
    bit 3, a
    jp nz, .gotostate3
    bit 4, a
    jp nz, .gotostate4
    bit 5, a
    jp nz, .gotostate5
    bit 6, a
    jp nz, .gotostate6

    .gotostate0 ; idle
    ld a, 1
    ld [player_state], a
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player_1_idle ; Starting address
    ld bc, __player_1_idle - player_1_idle ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheck

    .gotostate1 ; running
    ; Copy the bin data to video ram
    ld hl, $8800
    ld a, [state_running_count]
    ld b, $1
    cp a, b
    jr nz, .state_running_frame_2
    ; draw frame 1
    ld de, player1_state_running_1 ; Starting address
    ld bc, __player1_state_running_1 - player1_state_running_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ld a, $2
    ld [state_running_count], a
    jp .endstatecheck
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


; This method will use busy wait to play the joy animation of the player
; It is not in the state machine because it is an instant status
joy_animation:
    ld hl, $8800
    ld de, joy ; Starting address
    ld bc, __joy - joy ; Length -> it's a subtraciton
    call copy_data_to_destination
    ld hl, $6FFF
    .keep_joying
    ld a, l
    sub a, $1
    ld l, a
    or l
    jr nz, .keep_joying
    ld a, h
    sub a, $1
    ld h, a
    or h
    jr nz, .keep_joying
    ret


; This method will be used to check if player and food are on the same tile, if this is 
; the case the player gets the food
player_got_food:
ld a, [oam_buffer_player_y]
ld c, a
ld a, [oam_buffer_player_x]
ld b, a  ; x
call get_tile_by_pixel
ld e, l                            ;   de contains the tile position of the player
ld d, h                            ; 

ld a, [oam_buffer_food_y]
ld c, a                            
ld a, [oam_buffer_food_x]          
ld b, a  ; x
call get_tile_by_pixel             ;   hl  contains the tile position of the food

; now let's see if hl and de contains the same value
ld a, h
cp a, d
jr nz, .not_equal
ld a, l
cp a, e
jr nz, .not_equal
.equal ; eat the food and update the score
; increase score
ld hl, $9807       ; 9806 is the second digit of the first player
ld a, [hl]
sub a, $40            ; idx 0 for digits is 40, this way we are normalizing the number, eg. id 42 is 2 minus 40 we have now 2 
cp a, $9           ; second digit minus 9 to check if we need to modify the second digit
jr nz, .modify_second_digit
; modify_first_digit and put second digit to 0 which corresponds to $40
ld a, $40
ld hl, $9807
ld [hl], a          ; second digit set to 0
ld hl, $9806
ld a, [hl]
add a, $1
ld [hl], a
jp .modified_digits
.modify_second_digit
ld hl, $9807
ld a, [hl]
add a, $1
ld [hl], a
.modified_digits
ld a, [win_points]    ;
ld b, a               ;
ld hl, $9806          ; 
ld a, [hl]            ; If the player has win_points, he W   
cp a, b               ; 
jr z, .player_win     ;
call spawn_food
; Play animation
call joy_animation
; Play sound
call eat_food_sound 
.not_equal ; do nothing
xor a      ; not win
ret 
.player_win
ld a, $ff  ; win
ret