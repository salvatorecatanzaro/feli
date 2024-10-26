INCLUDE "utils/vram.asm"
INCLUDE "hardware.inc"
SECTION "Header", ROM0[$100]

EntryPoint: 
nop 
jp Start ; Leave this tiny space

SECTION "Game code", ROM0[$150]
Start:

ld hl, $8000                   ; vRAM
ld de, $9fff                   ; dall’indirizzo 0:$8000 a 0:$9fff 
call clear_mem_area            ;
ld hl, $fe00                   ; OAM
ld de, $fe9f                   ; dall’indirizzo 0:$fe00 a 0:$fe9f
call clear_mem_area            ;
                               ;  
ld a, %00000001                ; vRAM bank 1
ld [rVBK], a                   ; Quando in questo registro inseriamo il valore 1, viene impostato il bank 1 
                               ; della vRAM
ld hl, $8000                   ; Impostiamo tutti I valori della 1:$8000 1:$9fff 
ld de, $9fff                   ;
call clear_mem_area            ;  
xor a                          ; Impostiamo tutti I valori della vRAM bank a 0
ld [rVBK], a                   ; 
ld hl, $C000                   ; WRAM
ld de, $DFFF                   ;  dall’indirizzo $C000 to $DFFF
call clear_mem_area            ;


.main_loop:
jp .main_loop