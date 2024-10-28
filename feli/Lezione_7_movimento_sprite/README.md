# Lezione 7 - movimento sprites

In questo capitolo cattureremo gli input che il giocatore da al Game Boy tramite la pressione dei tasti. In particolare abiliteremo i movimenti a destra e a sinistra del personaggio principale.  
Per farlo ci spostiamo nel main loop e in ogni ciclo, prima di eseguire le operazioni di halt e nop, andremo a leggere gli input dell’utente.

*file: main.asm*
```
.main_loop:
    call get_buttons_state
    halt
    nop
    call water_animation
    call $ff80
    jp .main_loop
```

Definiamo la subroutine get_buttons_state nel file controls

*file: utils/controls.asm*
```
SECTION “CONTROLS”, ROM0[$0000]
get_buttons_state:
;   REGISTRO $FF00 - 
    ;    7/6      5                4                3               2          1           0
    ; P1      Select buttons  Select d-pad    Start / Down    Select / Up   B / Left    A / Right
    ; Select buttons: Quanto questo bit è uguale a zero, I tasti start, select, B ed A possono esser letti nella parte inferiore del byte.
    ; Select d-pad: Se questo bit è uguale a zero, Le direzioni del dpad possono esser lette nella parte inferiore del byte.
    ; La parte bassa del byte è destinate alla sola lettura e in maniera non convenzionale un tasto premuto equivale ad uno 0 e non ad un 1.
    ; la variabile buttons conterrà lo stato dei tasti
    
    ld a, %00010000 ; imposto il bit 6 a 1
    ld [$ff00], a   ; e lo carico in $ff00
    nop
    ld a, [$ff00] ; Leggo due volte il valore
    ld a, [$ff00] ; per sicurezza (Operazione ripetuta due volte sotto consiglio della community)
    ld b, a       ; il valore dei tasti letto lo inseriamo in b
    
    ; sla fa uno shift dei bit a sinistra, lo facciamo 4 volte così nella parte alta del byte avremo a, b, select, start
    sla b 
    sla b
    sla b
    sla b
    ld a, %00100000 ; ora selezioniamo il dpad
    ld [$ff00], a
    nop
    ld a, [$ff00]
    ld a, [$ff00]
    ld c, %00001111  ; Questa volta carichiamo lo stato del dpad in c
    and c            ; facciamo un and con a per confermare il valore ottenuto
    or b             ; Facciamo un or con b, così in a avremo nella parte alta del 
                     ;registro tutti a b start, select e nella parte bassa i 
                     ; valori del dpad
    ld [buttons], a  ; carico il valore ottenuto nell’ indirizzo puntato dalla 
                     ; variabile buttons
    ret
```

La routine precedente inserisce nella variabile buttons lo stato dei tasti che quindi sarà disponibile ad ogni iterazione.
Una volta ottenuto lo stato dei pulsanti, andiamo ad aggiornare la posizione del giocatore 

```
.main_loop:
    call get_buttons_state
    halt
    nop
    call water_animation
    call update_player_position
    call $ff80
    jp .main_loop
```

La subroutine update_player_position la implementiamo nel file denominato player


*file: utils/player.asm*
```
update_player_position:
    call try_move_left
    call try_move_right
    .end_update_player_position
    Ret

try_move_left:
    ld a, [buttons]                     ; inseriamo il contenuto di buttons in a
    bit 1, a                            ; bit 1 testa il bit uno
    jr nz, .no_left                     ; se non è zero, la freccia direzionale 
                                        ; sinistra non è stata premuta, saltiamo 
                                        ; alla label .no_left
    
    ld bc, oam_buffer_player_x          ; carico la posizione x attuale
    ld a, [bc]                          ; sottraggo 1 per spostare lo sprite a 
                                        ; sinistra
    sub a, 1
    ld [bc], a                          ; aggiorno la posizione
    .no_left
    call reset_positions
    ret

; vedi descrizione try move left
try_move_right:
    ld a, [buttons]
    bit 0, a
    jr nz, .no_right
    ld bc, oam_buffer_player_x
    ld a, [bc]
    add a, 1
    ld [bc], a
    .no_right
    call reset_positions
    ret


reset_positions:
    ld a, [oam_buffer_player_y]
    ld [main_player_y], a
    ld a, [oam_buffer_player_x]
    ld [main_player_x], a
    ret

```

Ora con le frecce direzionali potremo muovere il nostro personaggio a destra e a sinistra.

Andiamo a compilare ed eseguire il nostro codice per poter testare le nuove funzionalità aggiunte

```
# cd /<directory_del_progetto/feli/
# ./run_program.<estensione>
# java -jar Emulicius/Emulicius.jar feli.gbc
```
