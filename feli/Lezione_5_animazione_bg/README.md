# Lezione 5 - Animazione Background

## Animazione acqua
Le operazioni effettuate finora riguardano la parte di background statica, ovvero quella che non è animata. Le operazioni di aggiornamento sullo schermo sono conseguenza di ciò che avviene nel main loop che è quella porzione di codice che si ripete di continuo durante l’esecuzione del gioco.
La struttura che seguiremo è la seguente:

```
.main_loop:
    halt
    nop
    <chiamata a subroutine>
    <chiamata a subroutine>
    …
    …
    <chiamata a subroutine>

    jp .main_loop
```

In questo modo riusciremo a dividere il codice in diverse porzioni leggibili e soprattutto più semplici da manutenere.
L’istruzione halt mette la CPU in uno stato di sospensione fino a quando non si verifica una qualsiasi interrupt, ma è possibile fare in modo che questo comando ne aspetti soltanto alcune o come nel nostro caso, soltanto quella del VBlank.
Inseriamo quindi nel file main, subito dopo la label Start il seguente codice per poi inserire nel main loop la nostra prima subroutine

*file: main.asm*

```
Start:
    di                    ;  disabilito le interrupt
    ld a, IEF_VBLANK      ;  carico il bit dell’interrupt vblank in a
    ldh [rIE], a          ;  lo carico in rIE, in modo da abilitare solo vblank
    ei                    ;  riabilito le interrupt
```

*file: main.asm*
```
.main_loop:
    halt
    nop
    call water_animation
    jp .main_loop
```

La subroutine water_animation la definiamo nel file graphics

*file: utils/graphics.asm*
```
water_animation:
    ld a, [water_animation_frame_counter]  ; Carico il valore corrente del     
                                           ; water frame counter
    inc a                                  ; Lo incremento di uno
    ld [water_animation_frame_counter], a  ; Aggiorno la variabile
    cp a, $20                              ; Ogni 20 frame eseguiamo il codice che 
                                           ; segue
    jp nz, .__water_tile_animation         ; Se non son trascorsi 20 frame, non  
                                           ; eseguire il codice

    
    xor a                                  ; accumulatore impostato a zero
    ld [water_animation_frame_counter], a  ; carico zero nel frame counter, 
                                           ; resettandolo

    ld a, [water_animation_counter] ;      ; ora prendo il valore da 
                                           ; water_animation_counter e lo metto 
                                           ; nell’accumulatore
    and $1                                 ; se il numero è dispari (and 1 jr nz)
    jr nz, .water_tile_animation_2         ; disegnamo l’animazione 2
    .water_tile_animation_1                ; Altrimenti disegnamo l’animazione 1
    ld hl, $9a07                           ;
    ld [hl], $3                            ;
    ld hl, $9a08                           ;
    ld [hl], $3                            ;
    ld hl, $9a09                           ;
    ld [hl], $3                            ; 
    ld hl, $9a0a                           ;
    ld [hl], $3                            ; DISEGNO ANIMAZIONE 1 (ID $3)
    ld hl, $9a0b                           ;
    ld [hl], $3                            ;
    ld hl, $9a27                           ;
    ld [hl], $3                            ;
    ld hl, $9a28                           ;
    ld [hl], $3                            ;
    ld hl, $9a29                           ;
    ld [hl], $3                            ;
    ld hl, $9a2a                           ;
    ld [hl], $3                            ;
    ld hl, $9a2b                           ;
    ld [hl], $3                            ;
    
    ld a, [water_animation_counter]
    add $1
    ld [water_animation_counter], a
    jp .__water_tile_animation
    .water_tile_animation_2              ; animazione 2
    ld hl, $9a07                         ;
    ld [hl], $2                          ;
    ld hl, $9a08                         ;
    ld [hl], $2                          ;
    ld hl, $9a09                         ;
    ld [hl], $2                          ;
    ld hl, $9a0a                         ;
    ld [hl], $2                          ;
    ld hl, $9a0b                         ; DISEGNO ANIMAZIONE 2 (ID $2)
    ld [hl], $2                          ;
    ld hl, $9a27                         ;
    ld [hl], $2                          ;
    ld hl, $9a28                         ;
    ld [hl], $2                          ;
    ld hl, $9a29                         ;
    ld [hl], $2                          ;
    ld hl, $9a2a                         ;
    ld [hl], $2                          ;
    ld hl, $9a2b                         ;
    ld [hl], $2                          ;
    xor a                                ;
    ld [water_animation_counter], a      ; resetto a 0 water_animation_counter
    .__water_tile_animation
    
    ret
```

Ci sono due variabili che necessitano di un approfondimento:
*	water_animation_counter questo contatore ci aiuterà a capire di volta in volta quale dei due disegni dell’acqua andremo a rappresentare, creando di fatto il movimento delle onde
*	water_animation_frame_counter tiene il conto dei frame e ci permette di regolare la velocità con cui avviene il cambio del disegno in memoria

A differenza di tutti gli altri valori definiti finora nella ROM queste due variabili vanno definite nella WRAM poiché il loro stato muta durante l’esecuzione del codice. Andiamo quindi a creare un nuovo file

*file: utils/wram.asm*
```
SECTION "Counter", WRAM0
water_animation_counter: ds 1         ; Definiamo lo spazio (Define Space) 
water_animation_frame_counter: ds 1   ; Per 1 Byte
```

Prima di eseguire il main loop le inizializziamo e includiamo il file wram

*file: main.asm*
```
INCLUDE "utils/wram.asm"  ; questo include va prima dell’include di graphics.asm

xor a
ld [water_animation_frame_counter], a
ld a, $1
ld [water_animation_counter], a
```
 Compiliamo ed eseguiamo il codice per vedere il risultato

```
# cd /<directory_del_progetto/feli/
# ./run_program.<estensione>
# java -jar Emulicius/Emulicius.jar feli.gbc
```

In questo momento l'acqua si muove ad una velocità altissima, ma l'inserimento di nuovi comandi nelle lezioni successive renderà questa animazione più lenta e armoniosa.
