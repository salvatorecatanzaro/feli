
SECTION "vRAM code", ROM0

; -- !!!Disable screen - ppu before calling this method
; -- this subroutine loads into the vram tiles
; -- hl: dest
; -- de: tile address destination
; -- bc: map len
copy_bin_to_vram:
.copy_bin_loop
    ld a, [de]  ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl
    inc de      ; Move to next byte  
    dec bc      ; Decrement count
    ld a, b
    or c
    jr nz, .copy_bin_loop ; if this value is 0 we finished copying the font into vram
ret 


copy_bin:
    .copy_bin_loop
        ld a, [de] ; Grab 1 byte from the source
        inc de
        ld [hli], a ; Place it at the destination, incrementing hl
        inc de ; Move to next byte  
        dec bc ; Decrement count
        ld a, b
        ; metà di b viene caricata nell'accumulatore e messo in or con c che contiene la seconda meta
        ;se il risultato è 0 entrambi sono 0
        or c
        jr nz, .copy_bin_loop ; if this value is 0 we finished copying the font into vram
    ret 
    

