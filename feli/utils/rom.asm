SECTION "textures", ROM0
gravity_bin:
 	INCBIN "backgrounds/gravity_map"          ; The tiles that will be loaded into the vram
__gravity_bin:

gravity_tile_map:
	INCBIN "backgrounds/gravity_tilemap"   ; The map of all tiles with addresses that will be used to recreate the map on the screen
__gravity_tile_map:

gravity_attr_map:
	INCBIN "backgrounds/gravity_map_attributes"
__gravity_attr_map:

gravity_palettes:
	INCBIN "backgrounds/gravity_map_palettes"  ; The color selection for the map
__gravity_palettes:

player_1_palettes:
	db $bf, $66, $09, $89, $EE, $C5, $09, $89        ; The color selection for player one
__player_1_palettes:

player:
	INCBIN "sprites/cat.chr"                         ; Idle player 1 sprite                    
__player:

player_state_1_1:
	INCBIN "sprites/run_1.chr"                       ; Running state sprite 1
__player_state_1_1:

player_state_1_2:
	INCBIN "sprites/run_2.chr"                       ; Running state sprite 2
__player_state_1_2:

jmp_state_1_1:
	INCBIN "sprites/cat_jmp_1.chr"                   ; Jumping state sprite 1
__jmp_state_1_1:

jmp_state_1_2:
	INCBIN "sprites/cat_jmp_2.chr"                   ; Jumping state sprite 2
__jmp_state_1_2:
