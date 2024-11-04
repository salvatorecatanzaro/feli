# Lezione 11 - Risorse

In questo gioco l'obiettivo è quello di collezionare risorse. Inseriamo pertanto la possibilità di collezionarle aggiungendo nel main loop le subroutine *player_got_food* e *food_position_handler*

---
*file: main.asm*
```
.main_loop:
    call get_buttons_state
    halt
    nop
    call water_animation
    call update_player_position
    call player_animation
    call player_got_food
    cp a, $ff    ; Se viene ritornato $FF il player 1 ha vinto
    jp z, Start  ; Resettiamo il gioco

    call food_position_handler
    call $ff80
    jp .main_loop
```
---

Implementiamo le due subroutine invocate nel main loop

---
*file: utils/player.asm*
```
player_got_food:
    ld a, [oam_buffer_player_y]        ; Carico la y del player in a
    ld c, a                            ; Carico la y del player in c
    ld a, [oam_buffer_player_x]        ; Carico la x del player in a 
    ld b, a  ; x                       ; Carico la x del player in b
    call get_tile_by_pixel             ; Controllo in quale tile si trova il player
    ld e, l                            ; 
    ld d, h                            ; Salvo in de la posizione del player

    ld a, [oam_buffer_food_y]          ; Carico la y del cibo in a
    ld c, a                            ; Carico la y del cibo in c
    ld a, [oam_buffer_food_x]          ; Carico la x del cibo in a
    ld b, a                            ; Carico la x del player in b
    call get_tile_by_pixel             ; Salvo in hl la posizione del cibo

    ; Controlliamo se de ed hl coincidono
    ld a, h                            ; Carico h in a
    cp a, d                            ; Confronto d e a
    jr nz, .not_equal                  ; Se non sono uguali saltiamo a not_equal
    ld a, l                            ; Carico l in a
    cp a, e                            ; Confronto e ed a    
    jr nz, .not_equal                  ; Se non sono uguali saltiamo a not_equal
    .equal                             ; SONO UGUALI! Mangiamo il cibo e aggiorniamo lo score
    halt                               ; Prima di mangiare il cibo e aggiornare lo score 
    nop                                ; Aspettiamo un VBlank in modo da non incorrere in glitch 
                                       ; grafici
    
    ld hl, $9807          ; $9807 è la seconda cifra del player 1
    ld a, [hl]            ; carico il valore in a
    sub a, $40            ; l'indice 0 delle digits corrisponde a $40. Se sottraggo $40 normalizzo il 
                          ; valore. Eg. id $42 disegna il carattere 2, se tolgo $40 ottengo $2

    cp a, $9              ; Sottraggo al valore precedente 9 perchè se fa 0 siamo a 9 e dobbiamo 
                          ; modificare la prima cifra
    
    jr nz, .modify_second_digit  ; Se non è zero modifico la seconda cifra
    
    ; modifichiamo la prima cifra e settiamo la seconda a zero
    ld a, $40
    ld hl, $9807        ; Indirizzo della 
    ld [hl], a          ; second digit impostata a 0
    ld hl, $9806        ; indirizzo della prima digit
    ld a, [hl]          ; salvo il valore corrente in a
    add a, $1           ; incremento di uno
    ld [hl], a          ; disegno a schermo la nuova cifra
    jp .modified_digits ; salto a modified_digits, abbiamo finito.
    
    .modify_second_digit ; MODIFICO SECONDA DIGIT
    ld hl, $9807         ; carico l'indirizzo della seconda cifra in hl
    ld a, [hl]           ; Prendo il valore a cui punta l'indirizzo e lo salvo in a
    add a, $1            ; aggiungo 1
    ld [hl], a           ; Disegno la nuova cifra
    .modified_digits     ; 
    ld a, [win_points]   ; Carico il valore di win_points in a
    ld b, a              ; lo salvo poi in b
    ld hl, $9806         ; carico il valore della pirma cifra in hl
    ld a, [hl]           ; lo salvo in a   
    cp a, b              ; sottraggo a e b
    jr z, .player_win    ; se il valore è 0, il giocatore 1 ha vinto
    call spawn_food      ; chiamo la subroutine per spostare la posizione del cibo (Il giocatore non 
                         ; ha ancora vinto)
    ; Play animation
    call joy_animation   ; disegno l'animazione di gioia per quando il giocatore prende il cibo
    ; Play sound
    ;call eat_food_sound ; per ora lasciamo commentato il suono
    .not_equal           ; 
    xor a                ; ritorno zero perchè il player non ha vinto
    ret 
    .player_win
    ld a, $ff  ; win     ; ritorno $ff perche il player ha vinto
    ret


; Implementiamo la subroutine per la joy_animation
; Questo metodo sarà l'unico a gestire una animazione al di fuori di player_animation. 
; Per farlo, utilizza una busy wait per rallentare di qualche secondo e mostrare l'animazione
; Non si trova all'interno della nostra macchina a stati perchè è una animazione istantanea
joy_animation:
    ld hl, $8800                        ; 
    ld de, joy                          ; Carico l'animazione joy all'indirizzo
    ld bc, __joy - joy                  ; della VRAM $8800
    call copy_data_to_destination       ;
    ld hl, $1f00                        ; $1F00 è semplicemente un valore alto 
    .keep_joying                        ; al quale sottraiamo 1 ogni volta fino ad arrivare a 0
    ld a, l                             ; carico l in a
    sub a, $1                           ; sottraggo 1
    ld l, a                             ; carico a in l
    or l                                ; or tra a e l
    jr nz, .keep_joying                 ; il risultato non è zero? Ripeti il ciclo
    ld a, h                             ;
    sub a, $1                           ;
    ld h, a                             ; vedi controllo precedente
    or h                                ;
    jr nz, .keep_joying                 ;
    ret
```
---

Implementiamo ora *food_position_handler* nel file graphics. Questa routine sposta il cibo dopo n frame se questo non viene collezionato da nessun giocatore.

---
*file: utils/graphics.asm*
```
; ogni 60 frame incremento time_frame_based di 1
; ogni 60 time_frame_based sposto il cibo nella prossima posizione
food_position_handler:
    ld a, [frame_counter]      ;
    add $1                     ; incremento il frame_counter di uno
    ld [frame_counter], a      ;
    cp a, $1E                  ; controllo se sono passati $1E frame             
    jr nz, .less_then_sixty
    ld a, $1                   ; Se sono passati, resetto il valore a uno
    ld [frame_counter], a      ;
    ld a, [time_frame_based]   ;
    add $1                     ; sono passati n frame, aggiungo uno a time_frame_based
    ld [time_frame_based], a   ;
    cp a, $1E                  ; Se sono passati $1E time_frame_based, sposto il cibo in un'altra 
                               ; posizione sullo schermo
    jr nz, .less_then_sixty    ; 
    ld a, $1                   ;
    ld [time_frame_based], a   ; resetto time_frame_based a 1
    call spawn_food            ; sposto il cibo
    .less_then_sixty
    ret


spawn_food:
    ; food_y_coords e food_y_coords sono gli array delle possibili posizioni del cibo
    ; che abbiamo salvato nella wram

    ld hl, oam_buffer_food_y  ; Prendo la posizione attuale del cibo
    ld de, $81                ; carico $81 in de
    ld bc, food_y_coords      ; carico in bc l'indirizzo dell'array food_y_coords
    call get_new_xy_coords    ; ottengo il nuovo indirizzo (Risultato in bc)
    ld a, [bc]                ; salvo in a
    ld [hl+], a ; y           ; modifico la y del cibo

    ld bc, food_x_coords      ; vedi logica per y
    call get_new_xy_coords
    ld a, [bc]
    ld [hl+], a ; x

    ld a, $81
    ld [hl+], a

    inc hl
    
    ld a, [food_xy_position_counter]  ; incremento il contatore che ci muove negli array delle 
    add $1                            ; possibli posizioni di 1
    ld [food_xy_position_counter], a  ; aggiorno il valore della variabile
    ld b, a                           ; carico in b il valore del contatore
    ld a, [food_array_len]            ; carico la lunghezza dell'array in a
    cp a, b                           ; a - b = ?
    jr nz, .skip_reset                ; non è zero? Non resetto
    xor a                             ; Altrimenti resetto
    ld [food_xy_position_counter], a  ; food_xy_position_counter = 0
    .skip_reset
    ret


; Ottieni la nuova posizione dagli array food_y_coords oppure food_x_coords 
; @params bc uno tra food_y_coords e food_y_coords
; @return bc la nuova x o la nuova y
get_new_xy_coords:
    ld a, [food_xy_position_counter]      ;    Prendi il valore corrente del contatore
    add a, c                              ;    Aggiungi al bit meno significativo la c
    ld c, a                               ;    ricaricalo in c aggiornato

    jr nc, .__end_new_xy_coords           ;    se non c'è stato un carry abbiamo finito
    ld a, b                               ;    Se c'è un carry incrementiamo b di 1
    add a, $1                             ;
    ld b, a                               ;
    .__end_new_xy_coords
    ret
```
---

Nelle subroutine precedenti utilizziamo *food_x_coords*, *food_y_cords* e *food_array_len* che inseriamo nella ROM sotto la sezione textures

---
*file: utils/rom.asm*
```
food_x_coords: db $9B, $70, $3D, $97, $5A, $17, $50, $2E   ; array di posizioni x
food_y_coords: db $73, $8B, $5B, $43, $2B, $43, $5B, $8B   ; array di posizioni y
food_array_len: db $8                                      ; lunghezza dei due array (DEVONO ESSERE 
                                                           ; UGUALI!!!!)
```
---

Infine è necessario dichiarare e inizializzare la variabile *win_points* che determina quale è il punteggio che ci consente di vincere la partita. La inseriamo nella sezione *Player_state*

---
*file: utils/wram.asm*
```
win_points: ds 1
```
---
*file: main.asm*
```
    ld a, $41             ; Il player vince quando ottiene 10 punti, se il valore fosse $42 
                          ; vincerebbe a 20 etc.
    ld [win_points], a    ; 
    xor a                 ;
```
---

Compiliamo ed eseguiamo il codice e proviamo a raccogliere il cibo per vedere se lo score aumenta e se, raggiunti i dieci punti, il gioco si resetta

```
# cd /<directory_del_progetto/feli/
# ./run_program.<estensione>
# java -jar Emulicius/Emulicius.jar feli.gbc
```
