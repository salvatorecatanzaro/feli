SECTION "Player", rom0

update_player_position:
    ;Updates player position based on inputs and gravity
    ld hl, oam_buffer ; HL Contains now Y position 

    ;test down bit
    ld a, [buttons]
    bit 3, a
    jr nz, .no_down
    ld a, [hl]
    add 1
    ld [hl], a
    .no_down

    ;test up bit
    ld a, [buttons]
    bit 2, a
    jr nz, .no_up
    ld a, [hl]
    sub 1
    ld [hl], a
    .no_up
    
    inc hl ; increment OAM BUFFER cursor to match X 

    ;test left bit
    ld a, [buttons]
    bit 1, a
    jr nz, .no_left
    ld a, [hl]
    sub 1
    ld [hl], a
    .no_left

    ;test right bit
    ld a, [buttons]
    bit 0, a
    jr nz, .no_right
    ld a, [hl]
    add 1
    ld [hl], a
    .no_right
    ret

increase_register_20:
    ld c, $20
.increase_loop
    inc hl
    dec c
    ld a, c
    or $00
    jr nz, .increase_loop
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
    call increase_register_20
    dec b
    ld a, b
    or $00
    jr nz, .mulu_loop
.zero
    ret

get_player_position_in_overworld:
    ld de, oam_buffer
    ld a, [de] ; Y OAM sprite
    inc de
    sub 8
    sra a
    sra a
    sra a ; a contiene la y del bg
    call get_row ;
    ;;;;
    push de
    ld de, $9c00
    add hl, de
    pop de
    ;;;; 
    ld a, [de] ; X
    sub 8
    sra a
    sra a
    sra a ; a contiene x del bg
    ld d, $00
    ld e, a
    add hl, de    
    ret

