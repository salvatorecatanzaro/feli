SECTION "textures", ROM0

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

climbing_1:
    INCBIN "sprites/climbing_1.chr"
__climbing_1:

climbing_2:
    INCBIN "sprites/climbing_2.chr"  
__climbing_2:


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

palettes:
  db $bf, $66, $f7, $29, $00, $00, $00, $00   ; The color selection for the map
  db $87, $8e, $21, $11, $00, $00, $00, $00   ; 
  db $8f, $8d, $ee, $94, $00, $00, $00, $00   ; 
  db $0f, $df, $43, $78, $ff, $ff, $ff, $ff   ; 
  db $43, $78, $0f, $df, $43, $78, $43, $78   ; 
  db $EE, $94, $00, $00, $87, $8E, $28, $13
  db $ff, $ff, $ff, $ff, $00, $00, $00, $00   ; 
  db $ae, $6e, $ae, $6e, $00, $00, $00, $00   ; 
__palettes:

obj_palettes:
    db $5a, $5a, $5a, $8c, $8f, $89, $EE, $C5        ; The color selection for player one
    db $00, $00, $00, $00, $00, $00, $00, $00        ; The color selection for player two
    db $8f, $89, $00, $00, $19, $80, $8f, $89
__obj_palettes:

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

food_x_coords: db $9B, $70, $3D, $97, $5A, $17, $50, $2E         ; The possible x coordinates of the food
food_y_coords: db $73, $8B, $5B, $43, $2B, $43, $5B, $8B   ; The possible y coordinates of the food  
food_array_len: db $8                 ; 

char_bin:
  ; Questa è l’unica volta in cui useremo questa sintassi, dice al compilatore di prendere soltanto I primi 1024 byte, questo lo facciamo perche nel file usato come input ci sono caratteri che non andiamo ad utilizzare che riempirebbero inutilmente la vram
  INCBIN "backgrounds/char", 0,1024          ; The tiles that will be loaded into the vram
__char_bin:

player_1_idle:
  INCBIN "sprites/player_1_idle.chr"
__player_1_idle:

food:
  INCBIN "sprites/food.chr"                  
__food:

player:
  INCBIN "sprites/cat.chr"                                             
__player:

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

joy:
  INCBIN "sprites/joy.chr"                                            
__joy:

player1_state_swimming_1:
  INCBIN "sprites/swimming_1.chr"
__player1_state_swimming_1:

player1_state_swimming_2:
  INCBIN "sprites/swimming_2.chr"
__player1_state_swimming_2:

sound_melody_n_of_notes: db 51 * 4    ; il n delle note x 4. Ogni campo contiene 4 byte (2 word)
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

pres_screen_n_of_notes: db 18 * 4    ; il n delle note x 4. Ogni campo contiene 4 byte (2 word)
; same length as sound_melody
sound_melody_pres_screen:
dw D2, $06
dw B2, $10
dw D2, $10
dw G2, $10
dw D2, $10
dw A2, $10
dw C2, $10
dw F2, $10
dw G2, $06
dw D2, $10
dw B2, $10
dw D2, $10
dw G2, $06
dw D2, $10
dw A2, $10
dw C2, $10
dw F2, $10
dw NO_SOUND,$20 

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