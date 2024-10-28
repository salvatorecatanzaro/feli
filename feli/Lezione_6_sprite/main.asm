INCLUDE "utils/vram.asm"
INCLUDE "hardware.inc"
INCLUDE "utils/interrupts.asm"
INCLUDE "utils/rom.asm"
INCLUDE "utils/palettes.asm"
INCLUDE "utils/wram.asm"
INCLUDE "utils/graphics.asm"
INCLUDE "utils/oam_dma.asm"

SECTION "Header", ROM0[$100]

EntryPoint: 
nop 
jp Start ; Leave this tiny space
    
REPT $150 - $104
    db 0
ENDR

SECTION "Game code", ROM0[$150]
Start:
    di                    ;  disabilito le interrupt
    ld a, IEF_VBLANK      ;  carico il bit dell’interrupt vblank in a
    ldh [rIE], a          ;  lo carico in rIE, in modo da abilitare solo vblank
    ei                    ;  riabilito le interruptcall wait_vblank
call wait_vblank
xor a                 ;
ld [rLCDC], a         ;  Turn off the LCD by putting zero in the rLCDC register

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

ld hl, $9040                                 ; carichiamo il tile della zolla 
                                             ; di terreno nell’indirizzo 
                                             ; $9040 della vram
ld bc, __mud - mud                           ; 
ld de, mud                                   ; Copy mud tile data to vram
call copy_data_to_destination                ; 

ld hl, $9010                                 ;
ld bc, __grass - grass                       ;
ld de, grass                                 ; Copy grass tile data to vram
call copy_data_to_destination                ; 

ld hl, $9020                                 ; 
ld bc, __water_1 - water_1                   ;
ld de, water_1                               ; Copy water tile data to vram
call copy_data_to_destination                ;

ld hl, $9030                                 ;
ld bc, __water_2 - water_2                   ;
ld de, water_2                               ; Copy water2 tile data to vram
call copy_data_to_destination                ;        

ld hl, $9050                                 ;
ld bc, __grass_mud - grass_mud               ;
ld de, grass_mud                             ; Copy grass mud tile data to vram
call copy_data_to_destination                ;

ld bc, __gravity_tile_map - gravity_tile_map
ld hl, $9800
ld de, gravity_tile_map
call copy_data_to_destination

ld a, %10000000                              ;
ld hl, palettes                              ; Assegnazione palette di colori
ld bc, __palettes - palettes                 ;
call set_palettes_bg                         ;

call background_assign_attributes

ld hl, $9300                                 ;
ld bc, __char_bin - char_bin                 ;
ld de, char_bin                              ; Copy characters to vram
call copy_data_to_destination                ;
call create_score_labels

ld hl, $8800                                 ;
ld de, player_1_idle                         ; Starting address
ld bc, __player_1_idle - player_1_idle       ; Length -> it's a subtraciton
call copy_data_to_destination                ; Copy the bin data to video ram

ld hl, $8810                                 ; 
ld de, food                                  ; Starting address
ld bc, __food - food                         ; Length -> it's a subtraciton
call copy_data_to_destination                ; Copy the bin data to video ram

ld hl, $8820                                 ;
ld de, player                                ; Starting address
ld bc, __player - player                     ; Length -> it's a subtraciton
call copy_data_to_destination                ; Copy the bin data to video ram

ld bc, dma_copy                        ;
ld hl, $ff80                           ; Copio la routine di dma transfer nella hram
ld de, dma_copy_end - dma_copy      ; perche la cpu può accedere solo alla 
                                       ; hram durante dma access
call copy_in_high_ram                  ;

ld bc, sprite_count  
ld a, $03
ld [bc], a
ld a, $80                  ; id del primo sprite
ld hl, sprite_ids
ld [hl+], a
ld a, $81                  ; id del secondo sprite
ld [hl+], a
ld a, $82                  ; id del terzo sprite
ld [hl+], a

call copy_oam_sprites

ld a, %10000011 ;bg will start from 9800  ; Riaccendiamo lo schermo 
ld [rLCDC], a    

xor a
ld [water_animation_frame_counter], a
ld a, $1
ld [water_animation_counter], a

.main_loop:
    halt
    nop
    call water_animation
    call $ff80
    jp .main_loop