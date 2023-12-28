SECTION "textures", ROM0
gravity_bin:
 	INCBIN "textures/level/gravity_map"
__gravity_bin:
gravity_tile_map:
	INCBIN "textures/tile_map/gravity_tilemap"
__gravity_tile_map:
gravity_attr_map:
	INCBIN "textures/attribute_map/gravity_map_attributes"
__gravity_attr_map:
gravity_palettes:
	INCBIN "textures/palettes/gravity_map_palettes"
__gravity_palettes:
player:
	INCBIN "textures/cat.chr"
__player:
player_2:
	INCBIN "textures/level/cat_front.chr"
__player_2:

SECTION "Collision tiles", rom0

number_of_rectangles_gravity_map:
	db $02

;x, xlen, y, ylen
collision_rectangles: 
	db $37, $47, $65, $4
	db $72, $33, $41, $4
turn_off_sound:
	xor a
	; Shut sound down
	ld [rNR52], a
	ret

lcd_wait:
	push af
	di
	.wait_again
		ld a, [$ff41]
		and %00000010   ; is VRAM available? if second bit is set we keep on waiting
		jr nz, .wait_again
	pop af
	ret
