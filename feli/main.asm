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
INCLUDE "utils/sound.asm"

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
    di                    ;
    ld a, IEF_VBLANK      ;  Only vblank interrupt bit put in 'a' register
    ldh [rIE], a          ;  Only vblank interrupt selected
    ei
	call wait_vblank
	xor a                 ;
	ld [rLCDC], a         ;  Turn off the LCD by putting zero in the rLCDC register

    ld hl, $8000          ;  let's clear the vRAM
    ld de, $9fff          ;  Clear memory area from 0:$8000 to 0:$9fff
    call clear_mem_area   ;

    ld hl, $fe00          ;  let's clear OAM 
    ld de, $fe9f          ;  Clear memory area from 0:$fe00 to 0:$fe9f
    call clear_mem_area   ;

    ; let's clear vram 1:8800
    ld a, %00000001       ;  Select vRAM bank 1
    ld [rVBK], a          ;
    ld hl, $8000          ;  Clear memory area from 1:$8000 1:$9fff 
    ld de, $9fff          ;
    call clear_mem_area   ; 

    xor a                 ;  Select again vRAM bank 0
    ld [rVBK], a          ;

    ld hl, $C000          ;
    ld de, $DFFF          ;  Clear the ram from $C000 to $DFFF
    call clear_mem_area   ;
    
    ; PRESENTATION SCREEN
    call init_audio
    call background_presentation_screen

    ld hl, $9300                    ;
    ld bc, __char_bin - char_bin    ; Copying characters into vram 
    ld de, char_bin                 ;
    call copy_data_to_destination   ;
    call presentation_screen        ;
    ; PRESENTATION SCREEN

    ld hl, $8000                    ; let's clear the vRAM 
    ld de, $9fff                    ; Clear memory area from 0:$8000 to 0:$9fff
    call clear_mem_area             ;

    ld a, %00000001                 ;
    ld [rVBK], a                    ; Select vRAM bank 1
    ld hl, $8000                    ;
    ld de, $9fff                    ; Clear memory area from 1:$8000 1:$9fff 
    call clear_mem_area             ;

    xor a                           ; Select again vRAM bank 0
    ld [rVBK], a                    ;

    ld hl, $C000                    ; Clear the ram from $C000 to $DFFF
    ld de, $DFFF                    ;
    call clear_mem_area             ;

    ld hl, $fe00                    ; let's clear OAM 
    ld de, $fe9f                    ; Clear oam from $fe00 to $fe9f
    call clear_mem_area             ;

    ld hl, $8800                                 ;
	ld de, player_1_idle                         ; Starting address
	ld bc, __player_1_idle - player_1_idle       ; Length -> it's a subtraciton
	call copy_data_to_destination                ; Copy the bin data to video ram

    ld hl, $8810                                 ; 
    ld de, food                                  ; Starting address
    ld bc, __food - food                         ; Length -> it's a subtraciton
    call copy_data_to_destination                ; Copy the bin data to video ram

    ld hl, $8820                                 ;
    ld de, player                                ; Starting address
    ld bc, __player - player                     ; Length -> it's a subtraciton
    call copy_data_to_destination                ; Copy the bin data to video ram

    ld hl, $9040                                 ;
    ld bc, __mud - mud                           ; 
    ld de, mud                                   ; Copy mud tile data to vram
    call copy_data_to_destination                ; 
    
    ld hl, $9010                                 ;
    ld bc, __grass - grass                       ;
    ld de, grass                                 ; Copy grass tile data to vram
    call copy_data_to_destination                ; 
    
    ld hl, $9020                                 ; 
    ld bc, __water_1 - water_1                   ;
    ld de, water_1                               ; Copy water tile data to vram
    call copy_data_to_destination                ;

    ld hl, $9030                                 ;
    ld bc, __water_2 - water_2                   ;
    ld de, water_2                               ; Copy water2 tile data to vram
    call copy_data_to_destination                ;        

    ld hl, $9050                                 ;
    ld bc, __grass_mud - grass_mud               ;
    ld de, grass_mud                             ; Copy grass mud tile data to vram
    call copy_data_to_destination                ;

    ld hl, $9300                                 ;
    ld bc, __char_bin - char_bin                 ;
    ld de, char_bin                              ; Copy characters to vram
    call copy_data_to_destination                ;

    ld a, %10000000                              ;
    ld hl, palettes                              ; Setup all the palettes
    ld bc, __palettes - palettes                 ;
    call set_palettes_bg                         ;

    ld a, %10000000                              ;
    ld hl, obj_palettes                          ; Select all the object palettes
    ld bc, __obj_palettes - obj_palettes         ;
    call set_palettes_obj                        ;


    ; Adding map to screen----------------------
    ; Copying the tile map to the screen starting from $9800
    ; gravity_tile_map contains a list of the ids of the tile that has to be copyied. 
    ; 2 byte at time are loaded into memory from the gravity_tile_map file (Spaces not included)
    ld bc, __gravity_tile_map - gravity_tile_map
    ld hl, $9800
    ld de, gravity_tile_map
    call copy_data_to_destination

    call background_assign_attributes             ; Adding attributes to each tile

    call create_score_labels

    xor a                                         ; Turn off the LCD
    ld [rVBK], a                                  ; 
    ;---------------------------------------------

    ld bc, dma_copy                 ;
    ld hl, $ff80                    ; Copy dma transfer routine into high ram
	ld de, dma_copy_end - dma_copy  ; because only high ram can be accessed during dma transfer
    call copy_in_high_ram           ;
    
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
    ld [state_swimming_count_p2], a
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
    ld a, $41
    ld [win_points], a    ; 
    xor a
    ld [holding_jump], a
    call init_audio       ; Reset all counters and variables coming from pres screen audio


.main_loop:
    ; Main loop: gett button pressed, halt, wait for a vblank, then do stuff

    call get_buttons_state

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

    call water_animation
    call update_player_position
    call update_player2_position
    call player_animation
    call player_2_animation
    call player_got_food
    ; if a contains FF player 1 has won
    cp a, $ff
    jp z, Start
    call player2_got_food
    ; if a contains FF player 1 has won
    cp a, $ff
    jp z, Start
    call food_position_handler
    call $ff80 ; refresh oam
    call update_audio

    jp .main_loop


