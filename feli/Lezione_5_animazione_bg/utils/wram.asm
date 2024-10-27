SECTION "Counter", WRAM0

water_animation_counter: ds 1         ; Definiamo lo spazio (Define Space) 
water_animation_frame_counter: ds 1   ; Per 1 Byte

SECTION "Important twiddles", WRAM0[$C000]
; Reserve a byte in working RAM to use as the vblank flag
vblank_flag: ds 1