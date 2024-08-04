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

; Creates the score labels for the player
; no input params needed
presentation_screen:
    ; color writing background
    ld a, %10000000
    ld hl, palettes
    ld bc, __palettes - palettes
    call set_palettes_bg
    ld hl, $9984
    ld de, P_
    ld a, [de]
    ld [hli], a
    ld de, R_
    ld a, [de]
    ld [hli], a
    ld de, E_
    ld a, [de]
    ld [hli], a
    ld de, S_
    ld a, [de]
    ld [hli], a
    ld de, S_
    ld a, [de]
    ld [hli], a
    inc hl
    inc hl
    ld de, S_
    ld a, [de]
    ld [hli], a
    ld de, T_
    ld a, [de]
    ld [hli], a
    ld de, A_
    ld a, [de]
    ld [hli], a
    ld de, R_
    ld a, [de]
    ld [hli], a
    ld de, T_
    ld a, [de]
    ld [hli], a
    
    ; Turn on the screen
    ; bit 4 select from which bank of vram you want to take tiles: 0 8800 based, 1 8000 based
    ; bit 2 object sprite size 0 = 8x8; 1 = 8x16
    ; bit 1 sprite enabled
    ; Turn on LCD
    ld a, %10000011 ;bg will start from 9800
    ld [rLCDC], a
    ;se non preme nulla rimani su questa schermata

    .start_loop
    call get_buttons_state
    ld a, [buttons]
    bit 7, a
    jr nz, .start_loop

    ld hl, $5FFF          ;
    .bwait                ;
    dec HL                ;  Busy wait for some instants
    ld a, h               ;
    or l                  ;
    jr nz, .bwait         ;

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
    ld bc, food_y_coords                  ;    sum it to c, TODO Probebly we will have to handle carry
    add a, c                              ;    add food position counter to the less significant part 
    ld c, a                               ;    of the bit
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
    ld hl, oam_buffer  + 4
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