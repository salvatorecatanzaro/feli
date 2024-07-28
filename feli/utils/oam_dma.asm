SECTION "OAM-DMA code", ROM0

; -- bc: start address of code
; -- hl: destination -> high ram from $ff80 to $FFFE
; -- de: length of code
copy_in_high_ram:
    ; This method will copy the code that goes from 'bc' to 'de' into high ram which will
    ; be passed as parameter in the register hl
    ; DMA routine is 13 bytes long, copy it in the ram
    .hram_loop
        ld a, [bc]
        inc bc
        ld [hl+], a
        dec de
        ld a, e
        or d
        jr nz, .hram_loop 
    ret

; -- This method activates DMA transfer 
; -- to OAM memory of what is in $c1.
; -- it has to by copied in hram 'cause cpu can only
; -- access hram during dma tranfer.
dma_copy:
    di
    ld a, $c1
    ld [$ff46], a
    ld a, 40
.loop:
    dec a
    jr nz, .loop
    ei
    ret
dma_copy_end:
    nop

;oam_buffer to move to fe04
;sprite_count the number of sprites
;sprite_ids each byte contains 2 sprite id
; Each oam sprite has the following bytes
; byte 0 - Y position
; byte 1 - X position
; byte 2 - Tile index (The tile id in the vram)
; byte 3 attributes/flags:
;              7         6       5            4       3       2   1   0
;Attributes  Priority    Y flip  X flip  DMG palette Bank    CGB palette
;
copy_oam_sprites:
    ld a, [sprite_count]
    ld b, a
    ld de, sprite_ids
    ld hl, oam_buffer
.oam_loop
    ld a, 63
    ld [hl+], a ; y
    ld [hl+], a ; x
    ld a, [de]
    ld [hl+], a

    ld c, $82            ; $82 is the id of player 2
    ld a, [de]             
    cp a, c              ; if a - e is 0 this is the player 2 values
    jr z, .player2attrs  ;
    .player1attrs
    ld a, %00000000   ;atts
    jp .endattrs
    .player2attrs
    ld a, %00000001   ; palette 1 for player 2 
    .endattrs
    ld [hl+], a
    dec b
    ld a, b
    or b
    inc de   ; chr
    jr nz, .oam_loop
    ret