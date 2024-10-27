SECTION "Counter", WRAM0

water_animation_counter: ds 1         ; Definiamo lo spazio (Define Space) 
water_animation_frame_counter: ds 1   ; Per 1 Byte

SECTION "Important twiddles", WRAM0[$C000]
; Reserve a byte in working RAM to use as the vblank flag
vblank_flag: ds 1

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