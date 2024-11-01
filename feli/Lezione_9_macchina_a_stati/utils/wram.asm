

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
sound_length: ds 1