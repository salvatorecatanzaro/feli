SECTION "Palettes code", ROM0
; -- this subroutine populates color palette for BG
; -- a : starting palette (Usually 0?) | bit 7 must be 1 in order to increment automagically
; -- hl: source start
; -- bc: palette len
set_background_palette:
    ; ff69 writing the colours in this address will populate bg palette at address (ff68)
    ; ff68 from which address the palette will start populating if bit 7 is set, auto increment is used
    ld [$ff68], a

.palette_loop
    ld a, [hli]
    ld [$ff69], a ; white
    dec bc
    ld a, c
    or b
    jr nz, .palette_loop
ret
; -- this subroutine populates color palette for OBJ
; -- a : starting palette (Usually 0?) | bit 7 must be 1 in order to increment automagically
; -- hl: white
; -- de: med
; -- bc: dark
set_object_palette:
    ; ff6b writing the colours in this address will populate obj palette at address (ff6a)
    ; ff6a from which address the palette will start populating if bit 7 is set, auto increment is used
    ld [$ff6a], a

    ; Save bc input to fill first palette with transparent---
    push bc
    ld bc, %0000000000000000  ; transparent
    ld a, c
    ld [$ff6b], a
    ld a, b
    ld [$ff6b], a
    pop bc
    ;--------------------------------------------------------

    ld a, c
    ld [$ff6b], a
    ld a, b
    ld [$ff6b], a ; dark

    ld a, e
    ld [$ff6b], a
    ld a, d
    ld [$ff6b], a ; med

    ld a, l
    ld [$ff6b], a
    ld a, h
    ld [$ff6b], a ; white


; -- hl contains the destination address
; -- attribute_byte contains the palette attributes:
; 0 - 2 color palette
; 3 specifies character bank ?
; 4 / not used
; 5 left - right flip flag
; 6 up  - down flip flag
; 7 Display Priority Flag
;   0: Display according to OBJ display priority flag
;   1: Highest priority to BG
select_palette_attribute_for_tile:
    ld de, rVBK
    ld a, $01
    ld [de], a
    ld a, [attribute_byte]
    ld [hl], a ; Place it at the destination, incrementing hl
    xor a
    ld [de], a ;reset screen to tile map
ret

