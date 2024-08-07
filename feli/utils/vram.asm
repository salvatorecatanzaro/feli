
SECTION "vRAM code", ROM0

; -- !!!Disable screen - ppu before calling this method!!!
; -- this subroutine is used to copy data from source to destination
; -- hl: destination
; -- de: source
; -- bc: map len
copy_data_to_destination:
.copy_bin_loop
    ld a, [de]  ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl
    inc de      ; Move to next byte  
    dec bc      ; Decrement count
    ld a, b
    or c
    jr nz, .copy_bin_loop ; if this value is 0 we finished copying the font into vram
ret 
    

; -- !!!Disable screen - ppu before calling this method!!!
; -- this subroutine is used to clear area memory
; -- hl: start
; -- de: end
clear_mem_area:
    .clear_loop
    xor a
    ld [hli], a
    ld a, l
    cp a, e
    jp nz, .clear_loop
    ld a, h
    cp a, d
    jp nz, .clear_loop
    ret

