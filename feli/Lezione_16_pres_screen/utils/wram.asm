

SECTION "Important twiddles", WRAM0[$C000]
; Reserve a byte in working RAM to use as the vblank flag
vblank_flag: ds 1
buttons: ds 1

SECTION "Player coordinates", WRAM0
main_player_y: ds 1
main_player_x: ds 1
player_2_y: ds 1
player_2_x: ds 1

SECTION "OAM Buffer", WRAM0[$C100]
oam_buffer:  ds 4 * 40 ; to move to fe04  space necessary to store 40 sprites

; let's define some labels to make the code easier to read
def oam_buffer_player_y equ oam_buffer
def oam_buffer_player_x equ oam_buffer + 1
def oam_buffer_player_idx equ oam_buffer + 2
def oam_buffer_player_attrs equ oam_buffer + 3
def oam_buffer_food_y equ oam_buffer + 4
def oam_buffer_food_x equ oam_buffer + 5
def oam_buffer_food_idx equ oam_buffer + 6
def oam_buffer_food_attrs equ oam_buffer + 7
def oam_buffer_player2_y equ oam_buffer + 8
def oam_buffer_player2_x equ oam_buffer + 9
def oam_buffer_player2_idx equ oam_buffer + 10
def oam_buffer_player2_attrs equ oam_buffer + 11

sprite_count: ds 1     ; the number of sprites
sprite_ids: ds 20      ; each byte contains 2 sprite id

SECTION "Player_state", WRAM0
; Questa sezione viene utilizzata per definire le variabili che riguardano
; lo stato dei giocatori
note_tick: ds 1
sound_pointer: ds 2
current_note: ds 2
current_note_length: ds 2
win_points: ds 1
player_state: ds 1
player2_state: ds 1
; le variabili state_<nome_stato>_count vengono utilizzate per definire quale 
; frame è necessario utilizzare
; eg. L’ultimo frame nello stato running era 0, il prossimo frame sarà 1
state_idle_count: ds 1
state_running_count: ds 1
state_running_count_player2: ds 1
state_jmp_count: ds 1
state_jmp_count_player2: ds 1
state_3_count: ds 1            ; 
state_4_count: ds 1            ; Per sviluppi futuri …
state_5_count: ds 1            ;
state_6_count: ds 1            ;
jp_max_count: ds 1
holding_jump: ds 1
falling_speed: ds 1

SECTION "Counter", WRAM0
player_animation_frame_counter: ds 1 ; Utilizzato per rallentare l’animazione del 
                                     ; giocatore (Senza l’animazione sarebbe 
                                     ; velocissima)
player2_animation_frame_counter: ds 1 
food_counter: ds 1
frame_counter: ds 1            ; Contatore dei frame
time_frame_based: ds 1         ; Ogni N frame_counter questo valore è incrementato  
                               ; di uno
food_xy_position_counter: ds 1      ; Questo valore viene utilizzato per ottenere 
                                    ; ogni volta una nuova posizione sullo schermo 
                                    ; per il cibo
player2_climbing_counter: ds 1
player2_climb_max_count: ds 1
water_animation_counter: ds 1
water_animation_frame_counter: ds 1
platform_y_old: ds 1            ; Usato per sapere su quale piattaforma si trova 
                                ; il giocatore 2
state_swimming_count: ds 1      ; Per il movimento sott’acqua
state_swimming_count_p2: ds 1          
presentation_screen_flicker_counter: ds 1
pres_screen_sound_counter: ds 1

sound_length: ds 1
; Notes list
def C0 EQU 44
def Cd0 EQU 156
def D0 EQU 262
def Dd0 EQU 363
def E0 EQU 457
def F0 EQU 547
def Fd0 EQU 631
def G0 EQU 710
def Gd0 EQU 786
def A0 EQU 854
def Ad0 EQU 923
def B0 EQU 986
def C1 EQU 1046
def Cd1 EQU 1102
def D1 EQU 1155
def Dd1 EQU 1205
def E1 EQU 1253
def F1 EQU 1297
def Fd1 EQU 1339
def G1 EQU 1379
def Gd1 EQU 1417
def A1 EQU 1452
def Ad1 EQU 1486
def B1 EQU 1517
def C2 EQU 1546
def Cd2 EQU 1575
def D2 EQU 1602 
def Dd2 EQU 1627
def E2 EQU 1650
def F2 EQU 1673
def Fd2 EQU 1694
def G2 EQU 1714
def Gd2 EQU 1732
def A2 EQU 1767
def B2 EQU 1783
def C3 EQU 1798
def Cd3 EQU 1812
def D3 EQU 1825
def Dd3 EQU 1837
def E3 EQU 1849
def F3 EQU 1860
def Fd3 EQU 1871
def G3 EQU 1881
def Gd3 EQU 1890
def A3 EQU 1899
def Ad3 EQU 1907
def B3 EQU 1915
def C4 EQU 1923
def Cd4 EQU 1930
def D4 EQU 1936
def Dd4 EQU 1943
def E4 EQU 1949
def F4 EQU 1954
def Fd4 EQU 1959
def G4 EQU 1964
def Gd4 EQU 1969
def A4 EQU 1974
def Ad4 EQU 1978
def B4 EQU 1982
def C5 EQU 1985
def Cd5 EQU 1988
def D5 EQU 1992
def Dd5 EQU 1995
def E5 EQU 1998
def F5 EQU 2001
def Fd5 EQU 2004
def G5 EQU 2009
def A5 EQU 2011
def Ad5 EQU 2013 
def B5 EQU 2015
def FREQ4 EQU 1627
def FREQ5 EQU 1627
def NO_SOUND EQU $0fff