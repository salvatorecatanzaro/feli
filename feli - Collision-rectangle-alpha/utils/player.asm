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

    ; Controllo i 2 vertici inferiori del rettangolo immaginario per vedere se uno dei due collide

    ;test down bit
    ld a, [buttons]
    bit 3, a
    jr nz, .no_down
    ld a, [main_player_y]
    add $1
    ld [main_player_y], a ;Moving delta y by one to check if there would be a collision
    call check_player_collision
    jr c, .no_down
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;No collision, update position
    ld bc, oam_buffer ; y pos
    ld a, [bc]
    add 1
    ld [bc], a
.no_down
    call reset_positions

    ;test up bit
    ld a, [buttons]
    bit 2, a
    jr nz, .no_up
    ld a, [main_player_y]
    sub $1
    ld [main_player_y], a ;Moving delta y by one to check if there would be a collision
    call check_player_collision
    jr c, .no_up
    ld bc, oam_buffer ; y pos
    ld a, [bc]
    sub 1
    ld [bc], a
.no_up
    call reset_positions

    inc bc ; increment OAM BUFFER cursor to match X 

    ;test left bit
    ld a, [buttons]
    bit 1, a
    jr nz, .no_left
    ld a, [main_player_x]
    sub $1
    ld [main_player_x], a ;Moving delta y by one to check if there would be a collision
    call check_player_collision
    jr c, .no_left
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ld bc, oam_buffer + 1  ; x pos
        ld a, [bc]
        sub 1
        ld [bc], a
    .no_left
    call reset_positions

    ;test right bit
    ld a, [buttons]
    bit 0, a
    jr nz, .no_right
    ld a, [main_player_x]
    add $1
    ld [main_player_x], a ;Moving delta y by one to check if there would be a collision
    call check_player_collision
    jr c, .no_left
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ld bc, oam_buffer + 1 ; x pos

    ld a, [bc]
    add 1
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