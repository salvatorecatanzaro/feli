SECTION "CONTROLS", rom0

get_buttons_state:
    ;    7/6      5                4                3               2          1           0
    ; P1      Select buttons  Select d-pad    Start / Down    Select / Up   B / Left    A / Right
    ; Select buttons: If this bit is 0, then buttons (SsBA) can be read from the lower nibble.
    ; Select d-pad: If this bit is 0, then directional keys can be read from the lower nibble.
    ; The lower nibble is Read-only. Note that, rather unconventionally for the Game Boy, a button being pressed is seen as the corresponding bit being 0, not 1.
    ; Buttons will contain button state
    ; buttons will contain ab start select rlud
    ; The lower nibble is Read-only. Note that, rather unconventionally for the Game Boy, a button being pressed is seen as the corresponding bit being 0, not 1.
    ld a, %00010000 ; ff00 contains input bits
    ld [$ff00], a ; a b start select with 5
    nop
    ld a, [$ff00]
    ld a, [$ff00] ; do it twice to make sure
    ld b, a

    sla b ; shift left 4 bit a 
    sla b
    sla b
    sla b
    ld a, %00100000 ; r l u d
    ld [$ff00], a
    nop
    ld a, [$ff00]
    ld a, [$ff00]
    ld c, %00001111
    and c
    or b
    ld [buttons], a
    ret