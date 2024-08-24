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



background_presentation_screen:
; The last tile ids of feli_pres_screen are in the adventures_pres_screen file to make 
; the distance between the two sprites smaller
ld hl, $8800
ld bc, __adventures_pres_screen - adventures_pres_screen
ld de, adventures_pres_screen
call copy_data_to_destination

ld bc, __adventures_pres_screen_tile_map - adventures_pres_screen_tile_map
ld hl, $9880
ld de, adventures_pres_screen_tile_map
call copy_data_to_destination

ld hl, $8d40
ld bc, __feli_pres_screen - feli_pres_screen
ld de, feli_pres_screen
call copy_data_to_destination

ld bc, __feli_pres_screen_tile_map - feli_pres_screen_tile_map
ld hl, $9800
ld de, feli_pres_screen_tile_map
call copy_data_to_destination

ret
    
; Creates the score labels for the player
; no input params needed
presentation_screen:
    xor a                                         ;  Init variable to 0
    ld [presentation_screen_flicker_counter], a   ;
    ; color writing background
    ld a, %10000000                  ;
    ld hl, palettes                  ; Load background palettes into memory
    ld bc, __palettes - palettes     ;
    call set_palettes_bg             ;
    ld hl, $99c4                     ;
    ld de, P_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, R_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, E_                        ;
    ld a, [de]                       ;     ADD SCORE LABEL
    ld [hli], a                      ;     TO THE SCREEN
    ld de, S_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, S_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    inc hl                           ;
    inc hl                           ;
    ld de, S_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, T_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, A_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ; 
    ld de, R_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, T_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    
    ; Turn on the screen
    ; bit 4 select from which bank of vram you want to take tiles: 0 8800 based, 1 8000 based
    ; bit 2 object sprite size 0 = 8x8; 1 = 8x16
    ; bit 1 sprite enabled
    ; Turn on LCD
    ld a, %10000011 ;bg will start from 9800
    ld [rLCDC], a

    ld a, %00000001          ; set vram bank to 1
    ld [rVBK], a             ;
    .start_loop                                        ;
    ;Change bg palette every 5 loop                    ;
    ld a, [presentation_screen_flicker_counter]        ;     Every 20 iterations, change the screen
    add a, $1                                          ;     label PRESS START with a new color
    ld [presentation_screen_flicker_counter], a        ;
    cp a, $20                                          ;
    jr nc, .black_press_start                          ;
    .white_press_start                                 
    ld hl, $99c4                                       ;
    ld a, %00000011                                    ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;     PRESS START White color
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    inc hl                                             ;
    inc hl                                             ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    jp .end_presentation_screen_palette_assignation
    .black_press_start
    ld hl, $99c4                                       ;
    ld a, %00000000                                    ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;      PRESS START Black color
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    inc hl                                             ;
    inc hl                                             ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    .end_presentation_screen_palette_assignation
    ld a, [presentation_screen_flicker_counter]        ;
    cp a, $30                                          ;   When the presentation_screen_flicker_counter is $30
    jr nz, .dont_reset_counter                         ;   reset it to 0.
    xor a                                              ;
    ld [presentation_screen_flicker_counter], a        ;
    .dont_reset_counter
    ;Change bg palette every 5 loop

    call get_buttons_state                             ;
    ld a, [buttons]                                    ;
    bit 7, a                                           ;
    jr nz, .start_loop                                 ;
    ld a, %00000000          ; set vram bank to 0      ; 
    ld [rVBK], a             ;                         ;


    ld hl, $5FFF                                       ;
    .bwait                                             ;
    dec HL                                             ;  Busy wait for some instants
    ld a, h                                            ;  fter the user has press start button before
    or l                                               ;  starting the game
    jr nz, .bwait                                      ;

    ; turn off the screen again and wait some seconds
    xor a
    ld [rLCDC], a
    ret


; Creates the score labels for the player
; no input params needed
create_score_labels:
    ld hl, $9800
    ld de, S_
    ld a, [de]
    ld [hli], a
    ld de, C_
    ld a, [de]
    ld [hli], a
    ld de, O_
    ld a, [de]
    ld [hli], a
    ld de, R_
    ld a, [de]
    ld [hli], a
    ld de, E_
    ld a, [de]
    ld [hli], a
    inc hl
    ld de, _0
    ld a, [de]
    ld [hli], a
    ld de, _0
    ld a, [de]
    ld [hli], a

    inc hl
    inc hl
    inc hl
    inc hl

    ld de, S_
    ld a, [de]
    ld [hli], a
    ld de, C_
    ld a, [de]
    ld [hli], a
    ld de, O_
    ld a, [de]
    ld [hli], a
    ld de, R_
    ld a, [de]
    ld [hli], a
    ld de, E_
    ld a, [de]
    ld [hli], a
    inc hl
    ld de, _0
    ld a, [de]
    ld [hli], a
    ld de, _0
    ld a, [de]
    ld [hli], a
    ret


; Retrieve the new position from the array food_y_coords or food_x_coords
; @params bc should be either food_y_coords or food_y_coords
; @return bc contains the new position for x or y
get_new_xy_coords:
    ld a, [food_xy_position_counter]      ;    Take food xy position counter
    add a, c                              ;    add food position counter to the less significant part 
    ld c, a                               ;    of the bit

    jr nc, .__end_new_xy_coords
    ld a, b
    add a, $1
    ld b, a
    .__end_new_xy_coords
    ret


; Each oam sprite has the following bytes
; byte 0 - Y position
; byte 1 - X position
; byte 2 - Tile index (The tile id in the vram)
; byte 3 attributes/flags:
;              7         6       5            4       3       2   1   0
;Attributes  Priority    Y flip  X flip  DMG palette Bank    CGB palette
;
spawn_food:
    ; aggiungilo a un array composto da n posizioni x
    ; prendi la posizione corrente x e y a quell index
    ; aggiorna la posizione dell oam sprite
    ld hl, oam_buffer_food_y
    ld de, $81
    ld bc, food_y_coords
    call get_new_xy_coords
    ld a, [bc]
    ld [hl+], a ; y

    ld bc, food_x_coords
    call get_new_xy_coords
    ld a, [bc]
    ld [hl+], a ; x

    ld a, $81
    ld [hl+], a

    inc hl
    
    ld a, [food_xy_position_counter]
    add $1
    ld [food_xy_position_counter], a
    ld b, a
    ld a, [food_array_len]
    cp a, b
    jr nz, .skip_reset
    xor a                               ;    If food_array_len is reached, reset the counter to zero
    ld [food_xy_position_counter], a    ;    xor a = 0
    .skip_reset
	ret


; Every 60 frames increment time_frame_based by 1
; every 60 time_frame_based let's move our food on the screen
food_position_handler:
    ld a, [frame_counter]      ;
    add $1                     ; Increase the frame count by one
    ld [frame_counter], a      ;
    cp a, $1E                  ; let's see if n frames are passed              
    jr nz, .less_then_sixty
    ld a, $1                   ; Reset the count to 1
    ld [frame_counter], a      ;
    ld a, [time_frame_based]   ;
    add $1                     ; n frame passed, let s add one to our time_frame_based variable
    ld [time_frame_based], a   ;
    cp a, $1E                  ; If time_frame_based is equal to n lets move the food to another position on the screen
    jr nz, .less_then_sixty    ; and reset it's value to one
    ld a, $1                   ;
    ld [time_frame_based], a   ;
    call spawn_food            ;
    .less_then_sixty
    ret

; @param de: Starting position 9800/9c00 
; This method will assign different at attributes based on tile id
background_assign_attributes:
    ;get current bg starting position 9800 or 9c00
    ld a, [rLCDC]
    ld b, a
    ld a, [LCDCF_BG9C00]
    cp a, b
    jr z, .bg_start_from_9c00
    .bg_start_from_9800
    ld de, $9800
    jp .__bg_start_from
    .bg_start_from_9c00
    ld de, $9c00
    .__bg_start_from
    ; 0 is the first idx
    ; 3ff is the last idx
    ld hl, $1
    .bg_tile_loop
    ld a, %00000000          ; set vram bank to 1
    ld [rVBK], a             ;
    ld a, [de]

    cp a, $0
    jr z, .sky_tile
    cp a, $4
    jr z, .mud_tile

    cp a, $1
    jr z, .grass_tile

    cp a, $2
    jr z, .water_tile

    cp a, $3
    jr z, .water_tile

    cp a, $5
    jr z, .grass_mud_tile

    cp a, $6
    jr z, .cloud_tile

    .grass_tile
    ld a, %00000001          ; set vram bank to 1
    ld [rVBK], a             ;
    ld a, %00000001
    ld [de], a
    jp .assigned
    .grass_mud_tile
    ld a, %00000001          ; set vram bank to 1
    ld [rVBK], a             ;
    ld a, %00000101
    ld [de], a
    jp .assigned
    .mud_tile
    ld a, %00000001          ; set vram bank to 1
    ld [rVBK], a             ;
    ld a, %00000010
    ld [de], a
    jp .assigned
    .water_tile
    ld a, %00000001          ; set vram bank to 1
    ld [rVBK], a             ;
    ld a, %10000011
    ld [de], a
    jp .assigned
    .cloud_tile
    ld a, %00000001          ; set vram bank to 1
    ld [rVBK], a             ;
    ld a, %00000110
    ld [de], a
    jp .assigned
    .sky_tile
    ld a, %00000001          ; set vram bank to 1
    ld [rVBK], a             ;
    ld a, %00000111
    ld [de], a
    .assigned
    ld a, %00000001          ; set vram bank to 1
    ld [rVBK], a             ;
    inc de
    inc hl
    ld a, $3                 ;
    cp a, h                  ;
    jr nz, .bg_tile_loop     ;  Keep looping until hl contains 3ff *All bg tiles has been processed*
    ld a, $ff                ;
    cp a, l                  ;
    jr nz, .bg_tile_loop     ;

    xor a                    ; reset vram bank to 0
    ld [rVBK], a             ;
    ret


; this method will animate all water tiles 
water_animation:
    ld a, [water_animation_frame_counter]
    inc a
    ld [water_animation_frame_counter], a
    cp a, $20 ; Every 10 frames (a tenth of a second), run the following code
    jp nz, .__water_tile_animation

    ; Reset the frame counter back to 0
    xor a
    ld [water_animation_frame_counter], a

    ld a, [water_animation_counter] ; 
    and $1                           ; if odd execute climbing 2
    jr nz, .water_tile_animation_2               ;
    .water_tile_animation_1
    ; TODO Put the logic here
    ld hl, $9a07
    ld [hl], $3
    ld hl, $9a08
    ld [hl], $3
    ld hl, $9a09
    ld [hl], $3
    ld hl, $9a0a
    ld [hl], $3
    ld hl, $9a0b
    ld [hl], $3
    ld hl, $9a27
    ld [hl], $3
    ld hl, $9a28
    ld [hl], $3
    ld hl, $9a29
    ld [hl], $3
    ld hl, $9a2a
    ld [hl], $3
    ld hl, $9a2b
    ld [hl], $3
    
    ld a, [water_animation_counter]
    add $1
    ld [water_animation_counter], a
    jp .__water_tile_animation
    .water_tile_animation_2
    ; TODO Put the logic here
    ld hl, $9a07
    ld [hl], $2
    ld hl, $9a08
    ld [hl], $2
    ld hl, $9a09
    ld [hl], $2
    ld hl, $9a0a
    ld [hl], $2
    ld hl, $9a0b
    ld [hl], $2
    ld hl, $9a27
    ld [hl], $2
    ld hl, $9a28
    ld [hl], $2
    ld hl, $9a29
    ld [hl], $2
    ld hl, $9a2a
    ld [hl], $2
    ld hl, $9a2b
    ld [hl], $2
    xor a
    ld [water_animation_counter], a
    .__water_tile_animation
    
    ret


