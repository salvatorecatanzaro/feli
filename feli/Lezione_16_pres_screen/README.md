# Lezione 16 - Pres screen

Il nostro gioco è ormai completamente giocabile, ma manca una parte fondamentale, la schermata con la presentazione che ci chiede di premere il tasto start per iniziare la pratita

Subito dopo l'operazione di pulizia della memoria inseriamo questo codice, per poi ripulire ancora la memoria prima di cominciare ad importare i nostri asset nella VRAM
*file: main.asm*
```
ld hl, $8000          ;  let's clear the vRAM
ld de, $9fff          ;  Clear memory area from 0:$8000 to 0:$9fff
call clear_mem_area   ;

ld hl, $fe00          ;  let's clear OAM 
ld de, $fe9f          ;  Clear memory area from 0:$fe00 to 0:$fe9f
call clear_mem_area   ;

; let's clear vram 1:8800
ld a, %00000001       ;  Select vRAM bank 1
ld [rVBK], a          ;
ld hl, $8000          ;  Clear memory area from 1:$8000 1:$9fff 
ld de, $9fff          ;
call clear_mem_area   ; 

xor a                 ;  Select again vRAM bank 0
ld [rVBK], a          ;

ld hl, $C000          ;
ld de, $DFFF          ;  Clear the ram from $C000 to $DFFF
call clear_mem_area   ;

; PRESENTATION SCREEN
call init_audio
call background_presentation_screen

ld hl, $9300                    ;
ld bc, __char_bin - char_bin    ; Copying characters into vram 
ld de, char_bin                 ;
call copy_data_to_destination   ;
call presentation_screen        ;
; PRESENTATION SCREEN

ld hl, $8000                    ; let's clear the vRAM 
ld de, $9fff                    ; Clear memory area from 0:$8000 to 0:$9fff
call clear_mem_area             ;

ld a, %00000001                 ;
ld [rVBK], a                    ; Select vRAM bank 1
ld hl, $8000                    ;
ld de, $9fff                    ; Clear memory area from 1:$8000 1:$9fff 
call clear_mem_area             ;

xor a                           ; Select again vRAM bank 0
ld [rVBK], a                    ;

ld hl, $C000                    ; Clear the ram from $C000 to $DFFF
ld de, $DFFF                    ;
call clear_mem_area             ;

ld hl, $fe00                    ; let's clear OAM 
ld de, $fe9f                    ; Clear oam from $fe00 to $fe9f
call clear_mem_area             ;

```

*file: utils/graphics.asm*
```
; Creates the score labels for the player
; no input params needed
presentation_screen:
    xor a                                         ;  Init variable to 0
    ld [presentation_screen_flicker_counter], a   ;
    ; color writing background
    ld a, %10000000                  ;
    ld hl, palettes                  ; Load background palettes into memory
    ld bc, __palettes - palettes     ;
    call set_palettes_bg             ;
    ld hl, $99c4                     ;
    ld de, P_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, R_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, E_                        ;
    ld a, [de]                       ;     ADD SCORE LABEL
    ld [hli], a                      ;     TO THE SCREEN
    ld de, S_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, S_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    inc hl                           ;
    inc hl                           ;
    ld de, S_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, T_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, A_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ; 
    ld de, R_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    ld de, T_                        ;
    ld a, [de]                       ;
    ld [hli], a                      ;
    
    ; Turn on the screen
    ; bit 4 select from which bank of vram you want to take tiles: 0 8800 based, 1 8000 based
    ; bit 2 object sprite size 0 = 8x8; 1 = 8x16
    ; bit 1 sprite enabled
    ; Turn on LCD
    ld a, %10000011 ;bg will start from 9800
    ld [rLCDC], a

    ld a, %00000001          ; set vram bank to 1
    ld [rVBK], a             ;
    .start_loop
    halt
    nop
    ld a, [pres_screen_sound_counter]
    add a, $1
    ld [pres_screen_sound_counter], a
    cp a, $1
    jr nz, .dont_play_note 
    call pres_screen_audio
    xor a
    ld [pres_screen_sound_counter], a
    .dont_play_note                                 
    ;Change bg palette every 5 loop                    ;
    ld a, [presentation_screen_flicker_counter]        ;     Every 20 iterations, change the screen
    add a, $1                                          ;     label PRESS START with a new color
    ld [presentation_screen_flicker_counter], a        ;
    cp a, $20                                          ;
    jr nc, .black_press_start                          ;
    .white_press_start
    ld hl, $99c4                                       ;
    ld a, %00000011                                    ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;     PRESS START White color
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    inc hl                                             ;
    inc hl                                             ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    jp .end_presentation_screen_palette_assignation
    .black_press_start
    ld hl, $99c4                                       ;
    ld a, %00000000                                    ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;      PRESS START Black color
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    inc hl                                             ;
    inc hl                                             ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    ld [hli], a                                        ;
    .end_presentation_screen_palette_assignation
    ld a, [presentation_screen_flicker_counter]        ;
    cp a, $30                                          ;   When the presentation_screen_flicker_counter is $30
    jr nz, .dont_reset_counter                         ;   reset it to 0.
    xor a                                              ;
    ld [presentation_screen_flicker_counter], a        ;
    .dont_reset_counter
    ;Change bg palette every 5 loop

    call get_buttons_state                             ;
    ld a, [buttons]                                    ;
    bit 7, a                                           ;
    jr nz, .start_loop                                 ;
    ld a, %00000000          ; set vram bank to 0      ; 
    ld [rVBK], a             ;                         ;


    ld hl, $5FFF                                       ;
    .bwait                                             ;
    dec HL                                             ;  Busy wait for some instants
    ld a, h                                            ;  fter the user has press start button before
    or l                                               ;  starting the game
    jr nz, .bwait                                      ;

    ; turn off the screen again and wait some seconds
    xor a
    ld [rLCDC], a
    ret


background_presentation_screen:
; The last tile ids of feli_pres_screen are in the adventures_pres_screen file to make 
; the distance between the two sprites smaller
    ld hl, $8800
    ld bc, __adventures_pres_screen - adventures_pres_screen
    ld de, adventures_pres_screen
    call copy_data_to_destination

    ld bc, __adventures_pres_screen_tile_map - adventures_pres_screen_tile_map
    ld hl, $9880
    ld de, adventures_pres_screen_tile_map
    call copy_data_to_destination

    ld hl, $8d40
    ld bc, __feli_pres_screen - feli_pres_screen
    ld de, feli_pres_screen
    call copy_data_to_destination

    ld bc, __feli_pres_screen_tile_map - feli_pres_screen_tile_map
    ld hl, $9800
    ld de, feli_pres_screen_tile_map
    call copy_data_to_destination

    ret
```

nel file sound inseriamo la logica per il presentation screen

*file: utils/sound.asm*
```
; This method will add to the base address of sound_melody_pres_screen the current value
; of sound pointer
; @return hl current note
get_current_note_pres_screen:
    ld de, sound_melody_pres_screen             ;
    ld a, [sound_pointer]           ; Add to sound melody the offset sound_pointer
    add a, e                        ;

    ld e, a 
    jr nc, .no_carry_current_noteps ; 
    ld a, d                         ; check if there is a carry after the addition
    add a, $1                       ;
    ld d, a                         ;
    .no_carry_current_noteps
    ld a, [de]                      ;
    ld l, a                         ; Load the value in hl
    inc de                          ; 
    ld a, [de]                      ;
    ld h, a                         ; 
    ret 


 pres_screen_audio:
    ld a, [note_tick]                    ;
    or a, %00000000                      ;  If the note tick is on zero it means that we are going to play
    jr z, .play_new_noteps               ;  a new note

    ld hl, sound_melody_pres_screen
    call get_current_sound_length        ; put sound length in l
    ld a, [note_tick]                    ; get the number of ticks 
    cp a, l                              ; check if all ticks have been played
    jr nz, .end_update_note_tickps       ; if not, keep playing the same sound 

    ld a, [sound_pointer]                ;
    add a, $4                            ; if the result of the previous cp is zero, it means that we have to move
    ld [sound_pointer], a                ; the sound_pointer to the next note
    xor a                                ; and we need to reset note_tick to zero in order
    ld [note_tick], a                    ; to play the new sound.
    ld a, [sound_pointer]                ;
    ld b, a                              ;  if sound pointer is the same length as sound_length, reset it 
    ld a, [pres_screen_n_of_notes]       ;  to zero and start the melody from the beginning
    cp a, b                              ;
    jr nz, .end_update_audiops           ;
    xor a                                ;
    ld [sound_pointer], a                ;
    jp .end_update_audiops

    .play_new_noteps
    call get_current_note_pres_screen ; current note will be put in hl
    ld a, l
    ld [rNR13], a   ; Load lower part to 13
    ld a, h
    ld [rNR14], a   ; Load High bit to 14
    .end_update_note_tickps
    ld a, [note_tick]                    ;
    inc a                                ;  Note tick will tell us how many cycles the note has been
    ld [note_tick], a                    ;  playing. if it is zero we are on a new note and we should just
    .end_update_audiops
    ret
```

Aggiungiamo nella ROM le costanti e i binari necessari

*file: utils/rom.asm*
```
SECTION "textures_2", ROMX[$4000]
adventures_pres_screen:
    INCBIN "backgrounds/adventures_pres_screen"
__adventures_pres_screen:
adventures_pres_screen_tile_map:
    INCBIN "backgrounds/adventures_pres_screen_tilemap"
__adventures_pres_screen_tile_map:
feli_pres_screen:
    INCBIN "backgrounds/feli_pres_screen"
__feli_pres_screen:
feli_pres_screen_tile_map:
    INCBIN "backgrounds/feli_pres_screen_tilemap"
__feli_pres_screen_tile_map:
```


Aggiungiamo nella WRAM le variabili utilizzate nel codice precedente

*file: utils/wram.asm*
```
pres_screen_sound_counter: ds 1
```

Compiliamo ed eseguiamo il codice per ammirare il nostro nuovo presentation screen
```
# cd /<directory_del_progetto/feli/
# ./run_program.<estensione>
# java -jar Emulicius/Emulicius.jar feli.gbc
```


Aggiungiamo il suono quando il player1 o player2 ottengono la risorsa

*file: utils/player.asm*
```
...subito dopo call joy_animation...
call eat_food_sound 

...subito dopo jumping...
call jump_sound
```

analogamente per il player2

*file: utils/player2.asm*
```
...subito dopo call call spawn_food...
call eat_food_sound 

...subito dopo .jump...
call jump_sound
```

Se non si trovano i punti corretti dove inserire il codice fare riferimento ai file in questa lezione.
Adesso il nostro gioco è completo ed è totalmente giocabile!
