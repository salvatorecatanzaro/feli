SECTION "Game graphics", ROM0
 
; -- screen has to be disabled
; -- l: Tile id
; -- de: position on screen 9c00 based
draw_tile_to_screen_9c:
    ld a, l
    ld [de], a
    ld a, $01
    ld [rVBK], a
    xor a
    ld a, %00000001
    ld [de], a
    xor a
    ld [rVBK], a
    ret


; -- screen has to be disabled
; -- this subroutine draws a line formed by same tile repeated 'b' times
; -- l: Tile id
; -- bc: number of occourrencies
; -- de: Starting position on screen 9c00 based
draw_line_to_screen_9c:
	.loop
		ld a, l
		ld [de], a
		inc de
		dec b
		ld a, b
		or b
		jr nz, .loop
    ret


wait_vblank:
    .notvblank
        ld a, [$ff44] ;  144 - 153 VBlank area
        cp 144 ; Check if the LCD is past VBlank
        jr c, .notvblank
        ret

    	
scroll_x_register:
	xor a ;compare accumulator with itself which results always in a 0
	ld a, [rSCX]
	inc a
	ld [rSCX], a
	ret


skip_12_tiles_routine:
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    ld a, $14
    ld [map_counter], a 
    ret

draw_map:
    ld a, $14 
    ld [map_counter], a ; reset map counter
    jp .copy_bin_loop
        .skip_12_tiles
            call skip_12_tiles_routine
            jp .continue
        .copy_bin_loop 
            ld a, [hli] 
            ld [de], a
            inc de
            ld a, [map_counter]
            sub $01
            ld [map_counter], a
            cp $00
            jr z, .skip_12_tiles
    .continue
        dec bc ; Decrement count
        ld a, b
        or c
        jr nz, .copy_bin_loop
        ret


draw_tree_map:
    ld bc, 20*18
    ld hl, tree_map
    ld de, $9c00   
    jp .draw_loop
    .skip_12_tiles
        inc de
        inc de
        inc de
        inc de
        inc de
        inc de
        inc de
        inc de
        inc de
        inc de
        inc de
    .draw_loop  
        ld a, [hl+]
        
        ld [de], a
        ;select palette for current tile FF4F put this register to 1 and select background palette
        ;the first 3 bits of this register selects the palette id

        inc de
        xor a
        cp [hl]        
        jr z, .skip_12_tiles
        dec bc
        ld a, c
        or b
        jr nz, .draw_loop
    ret

tree_map:
    db  $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $03, $04, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $0a, $0b, $0c, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $03, $03, $03, $03, $03, $03, $07, $08, $09, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $00
    db  $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0f, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $00
    db  $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $00
    db  $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $00
