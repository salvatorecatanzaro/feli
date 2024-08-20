INCLUDE "hardware.inc"
INCLUDE "utils/graphics.asm"
INCLUDE "utils/interrupts.asm"
INCLUDE "utils/oam_dma.asm"
INCLUDE "utils/vram.asm"
INCLUDE "utils/wram.asm"
INCLUDE "utils/palettes.asm"
INCLUDE "utils/controls.asm"
INCLUDE "utils/player.asm"
INCLUDE "utils/rom.asm"
INCLUDE "utils/player2.asm"
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
	; Enable interrupts (Only vblank)
    di
    ld a, IEF_VBLANK ; Only vblank interrupt bit put in 'a'register
    ldh [rIE], a     ; Only vblank interrupt selected
    ei
	; LCD memory location, if 0 LCD is off
	call wait_vblank
	xor a
	ld [rLCDC], a  ; Turn off the LCD by putting zero in the rLCDC register

; let's clear the screen
    ld hl, $9800
    ld de, $9bff
    call clear_mem_area
; let's clear vram 0:8800
    ld hl, $8800
    ld de, $8ff0
    call clear_mem_area
; let's clear vram 1:8800
    ld a, %00000001
    ld [rVBK], a
    ld hl, $8800
    ld de, $8ff0
    call clear_mem_area
    ;set again vram 0
    xor a
    ld [rVBK], a
; let's clear the ram 
    ld hl, $C000
    ld de, $DFFF
    call clear_mem_area
    
    ; PRESENTATION SCREEN
    ; copying characters into vram 
    ld hl, $9300
    ld bc, __char_bin - char_bin
    ld de, char_bin
    call copy_data_to_destination
    call presentation_screen
    ; PRESENTATION SCREEN

    ; let's clear the screen
    ld hl, $9800
    ld de, $9bff
    call clear_mem_area
; let's clear vram 0:8800
    ld hl, $8800
    ld de, $8ff0
    call clear_mem_area
; let's clear vram 1:8800
    ld a, %00000001
    ld [rVBK], a
    ld hl, $8800
    ld de, $8ff0
    call clear_mem_area
    ;set again vram 0
    xor a
    ld [rVBK], a
; let's clear the ram 
    ld hl, $C000
    ld de, $DFFF
    call clear_mem_area
    ; Copy the bin data to video ram
    ld hl, $8800
	ld de, player_1_idle ; Starting address
	ld bc, __player_1_idle - player_1_idle ; Length -> it's a subtraciton
	call copy_data_to_destination

    ld hl, $8810
    ld de, food ; Starting address
    ld bc, __food - food ; Length -> it's a subtraciton
    call copy_data_to_destination

    ld hl, $8820
    ld de, player ; Starting address
    ld bc, __player - player ; Length -> it's a subtraciton
    call copy_data_to_destination

    ; copying map into vram
    ld hl, $9040
    ld bc, __mud - mud
    ld de, mud
    call copy_data_to_destination ; copying characters into vram 
    
    ld hl, $9010
    ld bc, __grass - grass
    ld de, grass
    call copy_data_to_destination ; copying characters into vram 
    
    ld hl, $9020
    ld bc, __water_1 - water_1
    ld de, water_1
    call copy_data_to_destination ;

    ld hl, $9030
    ld bc, __water_2 - water_2
    ld de, water_2
    call copy_data_to_destination ;

    ld hl, $9050
    ld bc, __grass_mud - grass_mud
    ld de, grass_mud
    call copy_data_to_destination ;

    ld hl, $9300
    ld bc, __char_bin - char_bin
    ld de, char_bin
    call copy_data_to_destination

    ; color writing background
    ld a, %10000000
    ld hl, palettes
    ld bc, __palettes - palettes
    call set_palettes_bg

    ; color writing obj
    ld a, %10000000
    ld hl, obj_palettes
    ld bc, __obj_palettes - obj_palettes
    call set_palettes_obj


    ; Adding map to screen----------------------
    ; Copying the tile map to the screen starting from $9800
    ; gravity_tile_map contains a list of the ids of the tile that has to be copyied. 
    ; 2 number at time are loaded into memory from the gravity_tile_map file (Spaces not included)
    ld bc, __gravity_tile_map - gravity_tile_map
    ld hl, $9800
    ld de, gravity_tile_map
    call copy_data_to_destination
    ; now adding attributes to that map
    call background_assign_attributes


    call create_score_labels

    
    xor a
    ld [rVBK], a
    ;---------------------------------------------

    ; copy dma transfer routine into high ram
    ; because only high ram can be accessed during dma transfer
    ld bc, dma_copy
    ld hl, $ff80
	ld de, dma_copy_end - dma_copy
    call copy_in_high_ram
    
    ld bc, sprite_count
    ld a, $03
    ld [bc], a
    ld a, $80 ; 80 tile id
    ld hl, sprite_ids
    ld [hl+], a
    ld a, $81 ; 81 tile id
    ld [hl+], a
    ld a, $82 ; 81 tile id
    ld [hl+], a

    call copy_oam_sprites

	; bit 4 select from which bank of vram you want to take tiles: 0 8800 based, 1 8000 based
	; bit 2 object sprite size 0 = 8x8; 1 = 8x16
	; bit 1 sprite enabled
    ; Turn on LCD
	ld a, %10000011 ;bg will start from 9800

	ld [rLCDC], a
	
	ld b, 0
	ld c, 0

    xor a
    ld [player_state], a  ; setting player state to IDLE
    ld [player2_state], a  ; setting player2 state to IDLE
    ld [player_animation_frame_counter], a
    ld [water_animation_frame_counter], a        ; this value is used to wait n frames before changing water frame
    ld [player2_animation_frame_counter], a
    ld [food_xy_position_counter], a
    ; init all states to 1
    ld a, 1
    ld [state_idle_count], a
    ld [state_running_count], a
    ld [state_running_count_player2], a
    ld [state_swimming_count], a
    ld [state_jmp_count], a 
    ld [state_jmp_count_player2], a
    ld [state_3_count], a
    ld [state_4_count], a 
    ld [state_5_count], a
    ld [state_6_count], a
    ld [falling_speed], a 
    ld [food_counter], a
    ld [frame_counter], a
    ld [water_animation_counter], a   ; This value is used to know which is the current water frame to display
    ld [player2_climbing_counter], a
    ld [time_frame_based], a
    ld a, $15
    ld [jp_max_count], a
    ld a, $80
    ld [player2_climb_max_count], a
    xor a
    ld [holding_jump], a



.main_loop:
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

    call water_animation
    call get_buttons_state
    call update_player_position
    call update_player2_position
    call player_animation
    call player_2_animation
    call player_got_food
    call player2_got_food
    call food_position_handler
    call $ff80 ; refresh oam

    jp .main_loop


