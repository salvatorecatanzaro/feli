SECTION "Game graphics", ROM0

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

