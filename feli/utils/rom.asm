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

player_1_palettes:
	db $bf, $66, $09, $89, $EE, $C5, $09, $89        ; The color selection for player one
__player_1_palettes:

player:
	INCBIN "sprites/cat.chr"                         ; Idle player 1 sprite                    
__player:

player_state_running_1:
	INCBIN "sprites/run_1.chr"                       ; Running state sprite 1
__player_state_running_1:

player_state_running_2:
	INCBIN "sprites/run_2.chr"                       ; Running state sprite 2
__player_state_running_2:

player_state_jmp_1_1:
	INCBIN "sprites/cat_jmp_1.chr"                   ; Jumping state sprite 1
__player_state_jmp_1_1:

player_state_jmp_1_2:
	INCBIN "sprites/cat_jmp_2.chr"                   ; Jumping state sprite 2
__player_state_jmp_1_2:

food:
	INCBIN "sprites/p2.chr"                   ; Jumping state sprite 2
__food:


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

food_x_coords: db $3f, 131, 70        ; The possible x coordinates of the food
food_y_coords: db $3f, 100, 120       ; The possible y coordinates of the food  
food_array_len: db $3                 ; 