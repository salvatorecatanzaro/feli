SECTION "Palettes", WRAM0
attribute_byte: ds 1 ;  
SECTION "MAP Attributes", wram0
map_counter: ds  1
SECTION "OAM Buffer", WRAM0[$C100]
oam_buffer:  ds 4 * 40 ; to move to fe04
sprite_count: ds 1     ; the number of sprites
sprite_ids: ds 20      ; each byte contains 2 sprite id

SECTION "Important twiddles", WRAM0[$C000]
; Reserve a byte in working RAM to use as the vblank flag
vblank_flag: ds 1
buttons: ds 1

SECTION "Player coordinates", WRAM0
main_player_y: ds 1
main_player_x: ds 1

SECTION "Player_state", WRAM0[$CFF0]
;this area will be used to define player state variables
player_state: ds 1
; The state_n_count variables will be used to decide which frame of the animation should be picked
; eg. last frame for running (state 1) was 0, the next frame animation should be 1
state_idle_count: ds 1 ; idle
state_running_count: ds 1 ; running
state_jmp_count: ds 1 ; jumping
state_3_count: ds 1 ; falling
state_4_count: ds 1
state_5_count: ds 1
state_6_count: ds 1
jp_max_count: ds 1
holding_jump: ds 1 ; Used to check if button is on hold or a new click
falling_speed: ds 1 ; This value will increment by 1 for each falling frame
SECTION "Counter", WRAM0
wFrameCounter: ds 1
