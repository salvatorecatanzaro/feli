INCLUDE "hardware.inc"
INCLUDE "utils/graphics.asm"
INCLUDE "utils/interrupts.asm"
INCLUDE "utils/hram.asm"
INCLUDE "utils/oam_dma.asm"
INCLUDE "utils/vram.asm"
INCLUDE "utils/wram.asm"
INCLUDE "utils/palettes.asm"
INCLUDE "utils/controls.asm"
INCLUDE "utils/player.asm"
INCLUDE "utils/overworld.asm"
INCLUDE "utils/rom.asm"
INCLUDE "utils/collision.asm"

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
	
    ld hl, $8800
	ld de, player ; Starting address
	ld bc, __player - player ; Length -> it's a subtraciton
	call copy_bin_to_vram

    ld hl, $8810
	ld de, player_2 ; Starting address
	ld bc, __player_2 - player_2 ; Length -> it's a subtraciton
	call copy_bin_to_vram

    ; copying map to vram
    ld hl, $9000
    ld bc, __gravity_bin - gravity_bin
    ld de, gravity_bin
    call copy_bin_to_vram ;
    
    ;color writing
    ld a, %10000000
    ld hl, gravity_palettes
    ld bc, __gravity_palettes - gravity_palettes
    call set_background_palette
    
    ; Adding map to screen----------------------
    ld bc, __gravity_tile_map - gravity_tile_map
    ld hl, gravity_tile_map
    ld de, $9c00
    call draw_map
    ; now adding attributes to that map
    ld a, $01
    ld [$FF4F], a
    ld bc, __gravity_attr_map - gravity_attr_map
    ld hl, gravity_attr_map
    ld de, $9c00
    call draw_map
    ;restore background bank to 0
    xor a
    ld [$FF4F], a
    ;---------------------------------------------

    ld bc, dma_copy
    ld hl, $ff80
	ld de, dma_copy_end - dma_copy
    call copy_in_high_ram
    
    ld bc, sprite_count
    ld a, $02
    ld [bc], a
    ld a, $80 ; 80 tile id
    ld hl, sprite_ids
    ld [hl+], a
    ld a, $81 ; 81 tile id
    ld [hl+], a

    call copy_oam_sprites

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
    xor a
    ld [main_player_direction_x_y], a ;reset direction
	call get_buttons_state
    call update_player_position
    call $ff80 ; refresh oam

    jp .vblank_loop

