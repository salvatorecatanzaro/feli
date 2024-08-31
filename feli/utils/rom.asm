SECTION "textures", ROM0
gravity_tile_map:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $06, $00, $00, $00, $00, $00, $06, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $06, $06, $06, $06, $00, $00, $00, $06, $06, $06, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $06, $00, $00, $00, $05, $05, $05, $05, $05, $05, $05, $05, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $06, $06, $06, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $05, $05, $05, $05, $05, $05, $00, $00, $00, $00, $00, $00, $00, $00, $05, $05, $05, $05, $05, $05, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $06, $06, $06, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $06, $06, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $06, $06, $06, $06, $06, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $06, $06, $06, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $05, $05, $05, $06, $06, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $05, $05, $05, 1,1,1,1,1,1,1,1,1,1,1,1
	db $06, $06, $06, $06, $06, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $01, $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $01, $01, $01, $01, $01, $01, $01, $01, 1,1,1,1,1,1,1,1,1,1,1,1
	db $04, $04, $04, $04, $04, $04, $04, $02, $02, $02, $02, $02, $04, $04, $04, $04, $04, $04, $04, $04, 1,1,1,1,1,1,1,1,1,1,1,1
__gravity_tile_map:

water_tiles: db $9a,$07, $9a,$08, $9a,$09, $9a,$0a, $9a,$0b, $9a,$27, $9a,$28, $9a,$29, $9a,$2a, $9a,$2b
water_tile_n: db 20 

mud:
	INCBIN "backgrounds/mud.chr"
__mud:

grass:
	INCBIN "backgrounds/grass.chr"
__grass:
grass_mud:
	INCBIN "backgrounds/grass_mud.chr"
__grass_mud:
water_1:
	INCBIN "backgrounds/water_1.chr"
__water_1:
water_2:
	INCBIN "backgrounds/water_2.chr"
__water_2:

blu:
	INCBIN "backgrounds/blu.chr"
__blu:

palettes:
	db $bf, $66, $f7, $29, $00, $00, $00, $00   ; The color selection for the map
	db $87, $8e, $21, $11, $00, $00, $00, $00   ; green shades
	db $8f, $8d, $ee, $94, $00, $00, $00, $00   ; brown shades
	db $0f, $df, $43, $78, $ff, $ff, $ff, $ff   ; brown shades
	db $43, $78, $0f, $df, $43, $78, $43, $78   ; brown shades
	db $EE, $94, $00, $00, $87, $8E, $28, $13
	db $ff, $ff, $ff, $ff, $00, $00, $00, $00   ; brown shades
	db $ae, $6e, $ae, $6e, $00, $00, $00, $00   ; brown shades
__palettes: 

char_bin:
	; The syntax INCBIN <val>, startrange, endrange indicates how many bytes we are going to take from the source
 	INCBIN "backgrounds/char", 0,1024          ; The tiles that will be loaded into the vram
__char_bin:

char_tile_map:
	INCBIN "backgrounds/char_tilemap"   ; The map of all tiles with addresses that will be used to recreate the map on the screen
__char_tile_map:

char_attr_map:
	INCBIN "backgrounds/char_attrs"
__char_attr_map:

char_palettes:
	INCBIN "backgrounds/char_palettes"  ; The color selection for the map
__char_palettes:

climbing_1:
	INCBIN "sprites/climbing_1.chr"
__climbing_1:

climbing_2:
	INCBIN "sprites/climbing_2.chr"  
__climbing_2:

obj_palettes:
	db $5a, $5a, $5a, $8c, $8f, $89, $EE, $C5        ; The color selection for player one
	db $00, $00, $00, $00, $00, $00, $00, $00        ; The color selection for player two
	db $8f, $89, $00, $00, $19, $80, $8f, $89
__obj_palettes:

player:
	INCBIN "sprites/cat.chr"                         ; Idle player 1 sprite                    
__player:

player_1_idle:
	INCBIN "sprites/player_1_idle.chr"
__player_1_idle:

player_state_running_1:
	INCBIN "sprites/run_1.chr"                       ; Running state sprite 1
__player_state_running_1:

player_state_running_2:
	INCBIN "sprites/run_2.chr"                       ; Running state sprite 2
__player_state_running_2:

player1_state_running_1:
	INCBIN "sprites/player_1_running_1.chr"                       ; Running state sprite 1
__player1_state_running_1:

player1_state_running_2:
	INCBIN "sprites/player_1_running_2.chr"                       ; Running state sprite 2
__player1_state_running_2:

player_state_jmp_1_1:
	INCBIN "sprites/cat_jmp_1.chr"                   ; Jumping state sprite 1
__player_state_jmp_1_1:

player_state_jmp_1_2:
	INCBIN "sprites/cat_jmp_2.chr"                   ; Jumping state sprite 2
__player_state_jmp_1_2:

player1_state_jmp_1_1:
	INCBIN "sprites/player_1_jumping_1.chr"                   ; Jumping state sprite 1
__player1_state_jmp_1_1:

player1_state_jmp_1_2:
	INCBIN "sprites/player_1_jumping_2.chr"                   ; Jumping state sprite 2
__player1_state_jmp_1_2:

food:
	INCBIN "sprites/food.chr"                  
__food:

joy:
	INCBIN "sprites/joy.chr"                                            
__joy:


A_: db $51
B_: db $52
C_: db $53
D_: db $54
E_: db $55
F_: db $56
G_: db $57
H_: db $58
I_: db $59
J_: db $5A
K_: db $5B
L_: db $5C
M_: db $5D
N_: db $5E
O_: db $5F
P_: db $60
Q_: db $61
R_: db $62
S_: db $63
T_: db $64
U_: db $65
V_: db $66
X_: db $67
Y_: db $68
_0: db $40
_1: db $41
_2: db $42
_3: db $43
_4: db $44
_5: db $45
_6: db $46
_7: db $47
_8: db $48
_9: db $49

food_x_coords: db $9B, $70, $3D, $97, $5A, $17, $50, $2E         ; The possible x coordinates of the food
food_y_coords: db $73, $8B, $5B, $43, $2B, $43, $5B, $8B   ; The possible y coordinates of the food  
food_array_len: db $8                 ; 

collision_map:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 1,1,1,1,1,1,1,1,1,1,1,1
	db $01, $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $01, $01, $01, $01, $01, $01, $01, $01, 1,1,1,1,1,1,1,1,1,1,1,1
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, 1,1,1,1,1,1,1,1,1,1,1,1
__collision_map:


player1_state_swimming_1:
	INCBIN "sprites/swimming_1.chr"
__player1_state_swimming_1:

player1_state_swimming_2:
	INCBIN "sprites/swimming_2.chr"
__player1_state_swimming_2:
sound_melody_n_of_notes: db 51 * 4    ; note number x 4. Each field contains 4 bytes (two words)
sound_melody:
dw A3, 08 
dw A3, 08
dw A3, 08
dw A3, 08
dw G3, 08
dw F3, 08
dw E3, 08
dw F3, 08
dw G3, 08
dw A3, 08
dw A3, 08
dw A3, 08
dw A3, 08
dw C4, 08
dw A3, 08
dw A3, 08
dw F3, 08
dw E3, 08
dw D3, 08
dw A3, 08
dw G3, 08
dw A3, 08
dw A3, 08
dw G3, 08
dw F3, 08
dw G3, 08
dw A3, 08
dw A3, 08
dw C4, 08
dw A3, 08
dw A3, 08
dw G3, 08
dw F3, 08
dw D3, 08
dw F3, 08
dw D3, 08
dw F3, 08
dw D3, 08
dw F3, 08
dw D3, 08
dw E3, 08
dw F3, 08
dw E3, 08
dw F3, 08
dw G3, 08
dw A3, 08
dw G3, 08
dw A3, 08
dw A3, 08
dw C4, 08
dw D4, 08

pres_screen_n_of_notes: db 18 * 4    ; note number x 4. Each field contains 4 bytes (two words)
; same length as sound_melody
sound_melody_pres_screen:
dw D2, $05
dw B2, $55
dw D2, $55 
dw G2, $25
dw D2, $55
dw A2, $55
dw C2, $55
dw F2, $55
dw G2, $25
dw D2, $55
dw B2, $55
dw D2, $55 
dw G2, $25
dw D2, $55
dw A2, $55
dw C2, $55
dw F2, $55
dw NO_SOUND,$aa 


SECTION "textures_2", ROMX[$4000]
adventures_pres_screen:
	INCBIN "backgrounds/adventures_pres_screen"
__adventures_pres_screen:
adventures_pres_screen_tile_map:
	INCBIN "backgrounds/adventures_pres_screen_tilemap"
__adventures_pres_screen_tile_map:
feli_pres_screen:
	INCBIN "backgrounds/feli_pres_screen"
__feli_pres_screen:
feli_pres_screen_tile_map:
	INCBIN "backgrounds/feli_pres_screen_tilemap"
__feli_pres_screen_tile_map:

