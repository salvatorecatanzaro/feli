SECTION "Palettes code", ROM0
; -- this subroutine populates color palette for BG
; -- a : starting palette (Usually 0?) | bit 7 must be 1 in order to increment automagically
; -- hl: source start
; -- bc: palette len
set_palettes_bg:
    ; ff69 writing the colours in this address will populate bg palette at address (ff68)
    ; ff68 from which address the palette will start populating if bit 7 is set, auto increment is used
    ld [$ff68], a
    .palette_loop
        ld a, [hli]
        ld [$ff69], a
        dec bc
        ld a, c
        or b
        jr nz, .palette_loop
    ret

; -- this subroutine populates color palette for BG
; -- a : starting palette (Usually 0?) | bit 7 must be 1 in order to increment automagically
; -- hl: source start
; -- bc: palette len
set_palettes_obj:
    ; ff69 writing the colours in this address will populate bg palette at address (ff68)
    ; ff68 from which address the palette will start populating if bit 7 is set, auto increment is used
    ld [$ff6a], a
    .palette_loop_o
        ld a, [hli]
        ld [$ff6b], a
        dec bc
        ld a, c
        or b
        jr nz, .palette_loop_o
    ret