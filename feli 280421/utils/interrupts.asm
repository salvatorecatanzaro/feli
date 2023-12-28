; Interrupt handlers
SECTION "Vblank interrupt", ROM0[$0040]
    ; Fires when the screen finishes drawing the last physical
    ; row of pixels
    push hl
    ld hl, vblank_flag
    ld [hl], 1
    pop hl
    reti

SECTION "LCD controller status interrupt", ROM0[$0048]
    ; Fires on a handful of selectable LCD conditions, e.g.
    ; after repainting a specific row on the screen
    reti

SECTION "Timer overflow interrupt", ROM0[$0050]
    ; Fires at a configurable fixed interval
    reti

SECTION "Serial transfer completion interrupt", ROM0[$0058]
    ; Fires when the serial cable is done?
    reti

SECTION "P10-P13 signal low edge interrupt", ROM0[$0060]
    ; Fires when a button is released?
    reti

