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

copy_oam_sprites:
    ;Updates player position based on button pressed
    ld a, [sprite_count]
    ld b, a
    ld de, sprite_ids
    ld hl, oam_buffer
.oam_loop
    ld a, 63
    ld [hl+], a ; y
    ld [hl+], a ; x
    ld a, [de]
    inc de   ; chr
    ld [hl+], a
    ld a, %00000000   ;atts
    ld [hl+], a
    dec b
    ld a, b
    or b
    jr nz, .oam_loop
    ret