SECTION "Overworld", rom0

apply_gravity:
    ld hl, oam_buffer ; HL Contains now Y position
    ;apply gravity
    ld a, [hl]
    add 1
    ld [hl], a
