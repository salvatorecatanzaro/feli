SECTION "CONTROLS", rom0

get_buttons_state:
    ; Buttons will contain button state
    ; buttons will contain ab start select rlud
    
    ld a, %00010000 ; ff00 contains input bits
    ld [$ff00], a ; a b start select with 5
    ld a, [$ff00]
    ld a, [$ff00] ; do it twice to make sure
    ld b, a

    sla b ; shift left 4 bit a 
    sla b
    sla b
    sla b
    ld a, %00001000 ; r l u d
    ld [$ff00], a
    ld a, [$ff00]
    ld a, [$ff00]
    ld c, %00001111
    and c
    or b
    ld [buttons], a
    ret