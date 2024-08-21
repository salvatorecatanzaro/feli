SECTION "Palettes", WRAM0
attribute_byte: ds 1 ;  
SECTION "MAP Attributes", wram0
map_counter: ds  1
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

SECTION "Important twiddles", WRAM0[$C000]
; Reserve a byte in working RAM to use as the vblank flag
vblank_flag: ds 1
buttons: ds 1

SECTION "Player coordinates", WRAM0
main_player_y: ds 1
main_player_x: ds 1
player_2_y: ds 1
player_2_x: ds 1

SECTION "Player_state", WRAM0[$CFF0]
;this area will be used to define player state variables
player_state: ds 1
player2_state: ds 1
; The state_n_count variables will be used to decide which frame of the animation should be picked
; eg. last frame for running (state 1) was 0, the next frame animation should be 1
state_idle_count: ds 1 ; idle
state_running_count: ds 1 ; running
state_running_count_player2: ds 1 ; running
state_jmp_count: ds 1 ; jumping
state_jmp_count_player2: ds 1 ; jumping
state_3_count: ds 1 ; falling
state_4_count: ds 1
state_5_count: ds 1
state_6_count: ds 1
jp_max_count: ds 1
holding_jump: ds 1 ; Used to check if button is on hold or a new click
falling_speed: ds 1 ; This value will increment by 1 for each falling frame
SECTION "Counter", WRAM0
player_animation_frame_counter: ds 1           ; Used to slow down player animation (Without this it would go super fast)
player2_animation_frame_counter: ds 1           ; Used to slow down player animation (Without this it would go super fast)
food_counter: ds 1
frame_counter: ds 1            ; Count each frame
time_frame_based: ds 1         ; Every N frames this value will be increased by one to get time
food_xy_position_counter: ds 1      ; This value will be used to get each time a new position for the food on the screen 
player2_climbing_counter: ds 1
player2_climb_max_count: ds 1
water_animation_counter: ds 1
water_animation_frame_counter: ds 1
platform_y_old: ds 1            ; used to keep track of the current platform
state_swimming_count: ds 1          ; move every swimming_counter 
state_swimming_count_p2: ds 1          ; move every swimming_counter 
presentation_screen_flicker_counter: ds 1