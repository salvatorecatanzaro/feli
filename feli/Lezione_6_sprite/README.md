# Inserimento Sprite
In questo capitolo descriviamo il processo di visualizzazione degli sprite dei personaggi su schermo. I protagonisti sono due gatti che, durante il gioco, si contendono dei pezzi di cibo. Ogni volta che un gatto raccoglie il cibo, quest’ultimo appare in una nuova posizione e il punteggio aumenta di un punto.

Includiamo nella ROM gli sprite che andremo ad utilizzare.

*file: utils/rom.asm*
```
player_1_idle:
	INCBIN "sprites/player_1_idle.chr"
__player_1_idle:

food:
	INCBIN "sprites/food.chr"                  
__food:

player:
	INCBIN "sprites/cat.chr"                                             
__player:
```

Copiamo i byte inclusi nella ROM all'interno della VRAM con il codice che segue, il codice va inserito prima di eseguire l’operazione dell’accensione dello schermo

*file: main.asm*
```
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
```

Ogni volta che vogliamo copiare gli sprites dalla VRAM allo schermo, o se vogliamo aggiornarne lo stato, dobbiamo effettuare un’operazione detta direct memory access (DMA). La CPU del Game Boy durante un DMA può accedere solo la HRAM (Memoria che va da $FF80 a $FFFE). Per questo motivo dobbiamo copiare una piccola subroutine nella HRAM ed eseguirla mentre si trova in questa area di memoria. Il trasferimento ha bisogno di 160 cicli macchina, attesa che andremo a implementare nella subroutine dma_copy.

*file: utils/oam_dma.asm*
```
SECTION "OAM-DMA code", ROM0[$0061]

; -- bc: indirizzo base
; -- hl: destinazione da $ff80 to $FFFE
; -- de: lunghezza del codice
copy_in_high_ram:
    ; Questo metodo copia il codice che ha indirizzo che parte da 'bc' e finisce in  'de' Nella high ram
    
    .hram_loop
        ld a, [bc]
        inc bc
        ld [hl+], a
        dec de
        ld a, e
        or d
        jr nz, .hram_loop 
    ret


; definiamo anche il metodo che andremo poi a copiare
; -- Questo metodo attiva un trasferimento DMA 
; -- verso la memoria OAM di tutto ciò che si trova a partire dall’indirizzo $C100
; -- Viene copiato nell hram perchè la cpu puo accedere solo alla hram quando effettua un DMA transfer
dma_copy:
    di
    ld a, $c1
    ld [$ff46], a
    ld a, 40             ; 4 cicli macchina impegnati sotto x 40 = 160 cicli macchina
.loop:
    dec a                ; 1 Ciclo di CPU
    jr nz, .loop         ; 3 Cicli di CPU
    ei
    ret
dma_copy_end:
    nop
```

nel file main, dopo le operazioni di copia degli sprite nella VRAM, andiamo a copiare la routine dma_copy nella HRAM invocando il metodo copy_in_high_ram

*file: main.asm*
```
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
```

La subroutine copy_oam_sprites, che inseriamo nel file oam_dma, serve ad assegnare gli attributi a tutti gli sprite

*file: utils/oam_dma.asm*
```
;sprite_count Il numero di sprites
;sprite_ids   ogni byte contiene 2 sprite id
; ogni OAM sprite è caratterizzato da questi valori
; byte 0 - Y position
; byte 1 - X position
; byte 2 - Tile index (The tile id in the vram)
; byte 3 attributes/flags:
;              7         6       5            4       3       2   1   0
;Attributes  Priority    Y flip  X flip  DMG palette Bank    CGB palette
;
copy_oam_sprites:
    ld a, [sprite_count]        ; copio sprite_count nell’accumulatore
    ld b, a                     ; copio sprite_count in b
    ld de, sprite_ids           ; inserisco sprite_ids in de
    ld hl, oam_buffer_player_y  ; carico l’indirizzo base in hl
.oam_loop
    ld a, [de]
    ld c, $81            ; controllo se in c c’è il valore $81             
    cp a, c              ; se a - e è uguale a zero aggiungiamo gli attributi del 
                         ; cibo
    jr z, .food_attrs    ;

    ld c, $82               ; $82 è l’id del player 2 (La CPU)
    cp a, c                 ; se a - e è 0 inseriamo gli attribute del player 2
    jr z, .player2_attrs    ;

    .player1attrs        ; Se nessuna delle due cond. Precedenti si è verificata,              
                         ; allora è il player 1
    ld a, $55            ; inseriamo $55(sarà la coordinate delle y) in a
    ld [hl+], a ; y      ; carichiamolo nell’indirizzo puntato da hl
    ld a, $0E            ; inseriamo $0E (coordinata x)  
    ld [hl+], a ; x      ;   
    ld a, [de]           ;
    ld [hl+], a          ;
    ld a, %00000000      ; assegniamo 0 a tutti gli attributi
    jp .endattrs
    
    .player2_attrs
    ld a, $55            ; inseriamo $55(sarà la coordinate delle y) in a
    ld [hl+], a ; y      ; carichiamolo all’indirizzo puntato da hl
    ld a, $9A            ; inseriamo $9A in a (Coordinata x)
    ld [hl+], a ; x      ; per poi spostarlo nell’indirizzo puntato da hl
    ld a, [de]
    ld [hl+], a
    ld a, %00000111   ; palette 7 per player 2
    jp .endattrs 
    
    .food_attrs
    ; Vedi descrizione player 1 e player 2

    ld a, $55      
    ld [hl+], a ; y
    ld a, $50
    ld [hl+], a ; x
    ld a, [de]
    ld [hl+], a
    ld a, %00000010

    .endattrs
    ld [hl+], a         ;
    dec b               ; Se ci sono ancora sprite da elaborare, ripeti il ciclo 
    ld a, b             ;
    or b                ;
    inc de   ; chr      ;
    jr nz, .oam_loop    ;
    ret
```

Definiamo le variabili utilizzate per la gestione degli sprites nella WRAM

*file: utils/wram.asm*
```
SECTION "OAM Buffer", WRAM0[$C100]
oam_buffer:  ds 4 * 40 ; to move to fe04  space necessary to store 40 sprites

; let's define some labels to make the code easier to read
def oam_buffer_player_y equ oam_buffer
def oam_buffer_player_x equ oam_buffer + 1
def oam_buffer_player_idx equ oam_buffer + 2
def oam_buffer_player_attrs equ oam_buffer + 3
def oam_buffer_food_y equ oam_buffer + 4
def oam_buffer_food_x equ oam_buffer + 5
def oam_buffer_food_idx equ oam_buffer + 6
def oam_buffer_food_attrs equ oam_buffer + 7
def oam_buffer_player2_y equ oam_buffer + 8
def oam_buffer_player2_x equ oam_buffer + 9
def oam_buffer_player2_idx equ oam_buffer + 10
def oam_buffer_player2_attrs equ oam_buffer + 11

sprite_count: ds 1     ; the number of sprites
sprite_ids: ds 20      ; each byte contains 2 sprite id
```


Aggiorniamo il main loop con la chiamata alla subroutine all’indirizzo $ff80 che è l’indirizzo di memoria dove abbiamo salvato la routine dma_copy

```
.main_loop:
    halt
    nop
    call water_animation
    call $ff80
    jp .main_loop
```

includiamo nel file main il file oam_dma
*file: main.asm*
```
INCLUDE "utils/vram.asm"
INCLUDE "hardware.inc"
INCLUDE "utils/interrupts.asm"
INCLUDE "utils/rom.asm"
INCLUDE "utils/palettes.asm"
INCLUDE "utils/wram.asm"
INCLUDE "utils/graphics.asm"
INCLUDE "utils/oam_dma.asm"
```
Ora gli sprite dovrebbero essere visibili sullo schermo! Compiliamo ed eseguiamo il codice per verificarlo

```
# cd /<directory_del_progetto/feli/
# ./run_program.<estensione>
# java -jar Emulicius/Emulicius.jar feli.gbc
```
