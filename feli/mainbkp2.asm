INCLUDE "hardware.inc"
INCLUDE "utils/graphics.asm"
INCLUDE "utils/interrupts.asm"

SECTION "Header", ROM0[$100]
    ; Our code here
EntryPoint: ; This is where execution begins
    nop ; Disable interrupts. That way we can avoid dealing with them, especially since we didn't talk about them yet :p
    jp Start ; Leave this tiny space
	
REPT $150 - $104
    db 0
ENDR

SECTION "Game code", ROM0[$150]

Start:
; GAME LOOP ################################################################
	; Enable interrupts
    ld a, IEF_VBLANK
    ldh [rIE], a
    ei
	; LCD memory location, if 0 LCD is off
	call wait_vblank
	xor a
	ld [rLCDC], a
	
	; copying map to vram
	ld hl, $9020
	ld de, map ; Starting address
	ld bc, __map - map ; Length -> it's a subtraciton
	call copy_bin_to_vram
    ld hl, $9020
    ld a, $01
    ld [hl], a ; Place it at the destination, incrementing hl
    ; copying map to vram
	ld hl, $8800
	ld de, player ; Starting address
	ld bc, __player - player ; Length -> it's a subtraciton
	call copy_bin_to_vram
    ld a, %10000000
	; color writing
    ld bc, $0188  ; dark
    ld de, $7db8  ; med
    ld hl, $1111  ; white
	call set_background_palette
    ld a, %10001001
	; color writing
    ld bc, $0188  ; dark
    ld de, $7db8  ; med
    ld hl, $1111  ; white
	call set_background_palette
    ; 355
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
        inc de
        xor a
        cp [hl]        
        jr z, .skip_12_tiles
        dec bc
        ld a, c
        or b
        jr nz, .draw_loop

        


	; setting last bit of ff6a to 1 means that after each palette
	; bit transfer there will be an increment and the next writing 
	; will be on another palette
	ld a, %10000000
	; color writing
    ld bc, $0188  ; dark
    ld de, %0100000111001101  ; med
    ld hl, %0100001000010001  ; white
    call set_object_palette
    
    

	; Put an object on the screen
    ld hl, oam_buffer
    ; y-coord
    ld a, 64
    ld [hl+], a
    ; x-coord
    ld [hl+], a
    ; tile index
    ld a, $80
    ld [hl+], a
    ; attributes, including palette, which are all zero
    ld a, %00000000
    ld [hl+], a
	
	ld bc, dma_copy
    ld hl, $ff80
	ld de, dma_copy_end - dma_copy
	call copy_in_high_ram

	call $ff80 ; call the method populated in hram

	;bit 4 select from which bank of vram you want to take tiles: 0 8800 based, 1 8000 based
	;bit 2 object sprite size 0 = 8x8; 1 = 8x16
	;bit 1 sprite enabled
	ld a, %10001011 ;bg will start from 9c00
	
	;ld a, %10000001 ;bg will start from 9800

	ld [rLCDC], a
	
	ld b, 0
	ld c, 0
.vblank_loop:
    ; Main loop: halt, wait for a vblank, then do stuff

    ; The halt instruction stops all CPU activity until the
    ; next interrupt, which saves on battery, or at least on
    ; CPU cycles on an emulator's host system.
    halt
    ; The Game Boy has some obscure hardware bug where the
    ; instruction after a halt is occasionally skipped over,
    ; so every halt should be followed by a nop.  This is so
    ; ubiquitous that rgbasm automatically adds a nop after
    ; every halt, so I don't even really need this here!
    nop

	; ld hl, oam_buffer + 1
    ; ld a, [hl]
    ; inc a
    ; ld [hl], a

	; Poll input
    ; It takes a moment to get a reliable read after requesting
    ; a particular set of buttons, so we need to wait a moment;
    ; this is based on the code from the manual, which stalls
    ; simply by reading multiple times

    ; Bit 5 means to read the dpad
    ; (Well, Actually: bit 4 being OFF means to read the d-pad)
    
    ld a, $20 ;bit 5 is 1
	ldh [rP1], a
    ; But it's unreliable, so do it twice
    ld a, [rP1]
    ld a, [rP1]
	; This is 'complement', and flips all the bits in a, so now
    ; set bits will mean a button is held down
    cpl
	; Store the lower four bits in b
	and a, $0f
	ld b, a
	; Bit 4 means to read the buttons
    ; (Same caveat; it's really that bit 5 is off)
    ld a, $10
    ldh [rP1], a
    ; Not sure why this needs more stalling?  Someone speculated
    ; that this circuitry might just be further away
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ; Again, complement and mask off the lower four bits
    cpl
    and a, $0f
    ; b already contains four bits, so I need to shift something
    ; left by four...  but the shift instructions only go one
    ; bit at a time, ugh!  Luckily there's swap, which swaps the
    ; high and low nybbles in any register
    swap a
    ; Combine b's lower nybble with a's high nybble
    or a, b
    ; And finally store it in RAM
    ld [buttons], a
	 ; Set b/c to the y/x coordinates
	 ld hl, oam_buffer
	 ld b, [hl]
	 inc hl
	 ld c, [hl]
 
	 ; This sets the z flag to match a particular bit in a
	 bit BUTTON_LEFT, a
	 ; If z, the bit is zero, so left isn't held down
	 jr z, .skip_left
	 ; Otherwise, left is held down, so decrement x
	 dec c
 .skip_left:
 
	 ; The other three directions work the same way
	 bit BUTTON_RIGHT, a
	 jr z, .skip_right
	 inc c
 .skip_right:
	 bit BUTTON_UP, a
	 jr z, .skip_up
	 dec b
 .skip_up:
	 bit BUTTON_DOWN, a
	 jr z, .skip_down
	 inc b
 .skip_down:
 
	 ; Finally, write the new coordinates back to the OAM
	 ; buffer, which hl is still pointing into
	 ld [hl], c
	 dec hl
	 ld [hl], b
    ; Check to see whether that was a vblank interrupt (since
    ; I might later use one of the other interrupts, all of
    ; which would also cancel the halt).
    ld a, [vblank_flag]
    ; This sets the zero flag iff a is zero
    and a
    jr z, .vblank_loop
    ; This always sets a to zero, and is shorter (and thus
    ; faster) than ld a, 0
    xor a, a
    ld [vblank_flag], a

    ; Use DMA to update object attribute memory.
    ; Do this FIRST to ensure that it happens before the screen starts to update again.
    call $FF80

    ; ... update everything ...

    jp .vblank_loop

SECTION "textures", ROM0

map_meta:
	INCBIN "textures/csv/level_1.csv"
__map_meta:
map:
	INCBIN "textures/level/1.chr"
__map:
player:

	INCBIN "textures/cat.chr"
__player:

map_palette:
	incbin	"textures/palettes/level_1.pal"
__map_palette:

turn_off_sound:
	xor a
	; Shut sound down
	ld [rNR52], a
	ret

lcd_wait:
	push af
	di
	.wait_again
		ld a, [$ff41]
		and %00000010   ; is VRAM available? if second bit is set we keep on waiting
		jr nz, .wait_again
	pop af
	ret


	
SECTION "OAM Buffer", WRAM0[$C100]
oam_buffer:
    ds 4 * 32


SECTION "Important twiddles", WRAM0[$C000]
; Reserve a byte in working RAM to use as the vblank flag
vblank_flag:
	ds 1
buttons:
	ds 1