SECTION "Player", rom0

reset_positions:
    ld a, [oam_buffer]
    ld [main_player_y], a
    ld a, [oam_buffer+1]
    ld [main_player_x], a
    ret

update_player_position:
    ;Updates player position based on inputs and gravity
    ld bc, oam_buffer                 ; BC Contains now Y position 
    ld a, [oam_buffer]
    ld [main_player_y], a
    ld a, [oam_buffer+1]
    ld [main_player_x], a
    ; Apply gravity on character
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
    ; No collision, update position
    ld bc, oam_buffer ; y pos
    ld a, [bc]
    add a, 1
    ld [bc], a
    .no_down
    ; Apply gravity on character
    ;test left bit
    ld a, [buttons]
    bit 1, a
    jr nz, .no_left
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
    ; set x flip to 0
    ld a, %00100000
    ld [oam_buffer + 3], a

    ; No collision, update position
    ld bc, oam_buffer + 1  ; x pos
    ld a, [bc]
    sub a, 1
    ld [bc], a
.no_left
    call reset_positions

    ;test right bit
    ld a, [buttons]
    bit 0, a
    jr nz, .no_right
    ; set x flip to 0
    ld a, %00000000
    ld [oam_buffer + 3], a
    ld a, [main_player_y]
    add a, 4  ; don t check collision from the top left of the sprite, but from a more mid position
    sub a, 16 ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes this difference
    ld c, a
    ld a, [main_player_x]
    add a, 4 ; dont start checking from the top left
    sub a, 8-1
    ld b, a
    call get_tile_by_pixel ; Returns tile address in hl
    ld a, [hl]
    call is_wall_tile
    jr nz, .no_right
    ; No collision, update position
    ld bc, oam_buffer + 1 ; x pos
    ld a, [bc]
    add a, 1
    ld [bc], a
.no_right

    ret


increase_register_20:
    ld de, $20
    add hl, de
    ret   


get_row:
;This will turn OAM sprite y value into a row Y
; the method is based on 9c00 screen, not moving.
 
    ld b, a   ; put y in b
    ld hl, $0000
    cp a, 0
    jr z, .zero
    ld a,  $00
.mulu_loop
    push de
    call increase_register_20
    pop de
    dec b
    ld a, b
    or $00
    jr nz, .mulu_loop
.zero
    ret

get_player_position_in_overworld:
    ; hl will contain the tile
    ld de, main_player_y

    ld a, [de] ; Y OAM sprite
    inc de
    sub 8
    srl a
    srl a
    srl a ; a contiene la y del bg
    call get_row ;
    ;;;;
    push de
    ld de, $9c00
    add hl, de
    pop de
    ;;;; 
    ld a, [de] ; X
    sub 8
    srl a
    srl a
    srl a ; a contiene x del bg
    ld d, $00
    ld e, a
    add hl, de
    ret


; Convert a pixel position to a tilemap address
; hl = $9800 + X + Y * 32
; @param b: X
; @param c: Y
; @return hl: tile address
; 
; Calcola il valore della tile per esempio 98EB
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
    ld bc, $9800
    add hl, bc
    ret

; @param a: tile ID
; @return z: set if a is a wall.
is_wall_tile:
    or a, $00
    ret

player_animation:
    ld a, [wFrameCounter]
    inc a
    ld [wFrameCounter], a
    cp a, 10 ; Every 10 frames (a tenth of a second), run the following code
    jp nz, .endstatecheck

    ; Reset the frame counter back to 0
    ld a, 0
    ld [wFrameCounter], a


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
    ld de, player ; Starting address
    ld bc, __player - player ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheck

    .gotostate1 ; running
    ld a, 0
    ld [player_state], a
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player_state_1 ; Starting address
    ld bc, __player_state_1 - player_state_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheck

    .gotostate2 ; jumping
    ld a, 0
    ld [player_state], a
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player_state_1 ; Starting address
    ld bc, __player_state_1 - player_state_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheck

    .gotostate3 ; dead
    ld a, 0
    ld [player_state], a
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player_state_1 ; Starting address
    ld bc, __player_state_1 - player_state_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheck

    .gotostate4 ; hurt
    ld a, 0 
    ld [player_state], a
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player_state_1 ; Starting address
    ld bc, __player_state_1 - player_state_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheck

    .gotostate5 ; joy
    ld a, 0
    ld [player_state], a
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player_state_1 ; Starting address
    ld bc, __player_state_1 - player_state_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheck

    .gotostate6 ; powerup
    ld a, 0
    ld [player_state], a
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player_state_1 ; Starting address
    ld bc, __player_state_1 - player_state_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheck


    .endstatecheck
    ret