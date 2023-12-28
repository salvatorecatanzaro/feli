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
main_player_direction_x_y: ds 1
