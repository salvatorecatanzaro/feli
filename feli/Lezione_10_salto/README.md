# Lezione 10 - Salto

La prossima meccanica che andiamo ad implementare è quella del salto e lo facciamo inserendo la direttiva try_jump prima di eseguire try_move_left nel file player

*file: utils/player.asm*
```
update_player_position:
    ; Inizializziamo ad ogni iterazione lo stato ad idle, se non dovesse essere corretto
    ; sarebbe sovrascritto dalle istruzioni che seguono
    ld b , %00011100                    ; mascheriamo tutti gli stati 
    ld a, [player_state]                ; tranne salto, caduta, e in acqua
    and b                               ;
    ld [player_state], a                ;
    
    call try_move_left
    call try_move_right
    call try_jump
    
    ld a, [player_state]                ;
    ld b, %00000100                     ;  Se il giocatore sta saltando 
    and b                               ;  Non applichiamo la gravità
    jp nz, .end_update_player_position  ;  
    call try_apply_gravity              ;
    .end_update_player_position         ;
    ret

```

*file: utils/player.asm*
```
try_jump:
    ld a, [buttons]              ; Se il tasto A è stato appena premuto 
    bit 4, a                     ; significa che non è in holding
    jr z, .holding               ; 
    xor a                        ; Resettiamo holding_jump a zero
    ld [holding_jump], a         ;
    .holding
    
    ld a, [player_state]         ;
    bit 2, a                     ; Se siamo nello stato jumping 
    jp nz, .jumping              ; continuiamo a salire
                                 ;
    ld a, [buttons]              ; Se il tasto viene premuto mentre siamo in aria
    bit 4, a                     ; non rieseguamo il codice per il salto
    jr nz, .not_jumping          ;
    ld b, $0                     ; 
    ld a, [holding_jump]         ; 
    or b                         ; Se il tasto premuto è ancora quello del loop precedente
    jr nz, .not_jumping          ; non saltiamo
    ld a, $1
    ld [holding_jump], a         ; Siamo nel caso in cui il tasto è stato premuto per la prima
    ld a, %00001000              ; volta mentre il giocatore è a terra
    ld b, a                      ;
    ld a, [player_state]         ;
    and b                        ; Se il player è nello stato falling, infine, 
    jr nz, .not_jumping          ; non rieseguiamo il salto

    ; JUMP
    .jumping 
    ld a, %00000100              ; Settiamo il player state in jumping
    ld [player_state], a         ; in modo da far disegnare la nuova animazione e per i controlli visti in 
                                 ; precedenza
    ld a, [main_player_y]
    sub a, 16+1                  ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes
                                 ; this difference
    ld c, a                      ; 
    ld a, [main_player_x]        ; Calcoliamo il delta per controllare in quale tile 
    sub a, 8                     ; Andrebbe a finire il player
    ld b, a                      ;
    call get_tile_by_pixel       ; Ritorna il tile della posizione in cui si trova il player in HL
    ld a, [hl]                   ; carichiamo hl in a
    call is_wall_tile            ; Controlliamo se il tile è un muro
    jr nz, .start_falling        ; Se il tile è un muro abbiamo toccato un blocco in alto, iniziamo la caduta
    ld a, [state_jmp_count]      ; Controlliamo da quanti frame stiamo saltando
    ld b, $8                     ; per determinare a che velocità andare
    cp b                         ;
    jr c, .up_by_three           ;
    .up_by_one                   ;
    ld bc, oam_buffer_player_y
    ld a, [bc]                   ;
    sub a, 1                     ; Il player andrà a velocità 3 inizialmente
    ld [bc], a                   ; Per poi rallentare prima di iniziare la discesa
    jp .__up_by                  ; Salendo soltanto quindi di 2
    .up_by_three                 ;
    ld bc, oam_buffer_player_y   ;
    ld a, [bc]                   ;
    sub a, 3                     ; Spostiamo il player di 3 verso l'alto
    ld [bc], a                   ;
    .__up_by
    ld a, [state_jmp_count]      ; Incrementiamo il numero di frame del salto
    add a, 1                     ;
    ld [state_jmp_count], a      ;
    ld a, [jp_max_count]         ; Quando arriviamo a jp_max_count
    ld b, a                      ; Iniziamo la discesa (start_falling)
    ld a, [state_jmp_count]      ;
    cp a, b                      ;
    jr z, .start_falling         ;
    jp .no_up                    ;
    .start_falling               ;
    ld a, $1                     ; Resettiamo state_jmp_count a 1
    ld [state_jmp_count], a      ;
    ld a, %00001000              ; Modifichiamo a jumping il player_state
    ld [player_state], a         ;
    .no_up                       ;
    .not_jumping          
    call reset_positions
    ret     

```

La subroutine precedente permette al player di saltare e, grazie all'utilizzo della variabile player_state inoltre ci consentirà di far saltare il player alla pressione del tasto A.
Aggiornando la routine try_apply_gravity invece aggiorniamo lo stato del player da falling a idle ogni volta che questo tocca terra e aggiorniamo la velocità con cui il giocatore scende verso il terreno al passare del tempo

```
try_apply_gravity:
    ld a, [falling_speed]
    ld b, $12
    cp a, b
    jr c, .fall_slow
    .fall_fast
    ld a, [main_player_y]
    add a, 4 ; The check starts from upleft, lets add 4 pixel distance to make it more centered
    sub a, 16-2 ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes this difference
    ld c, a
    ld a, [main_player_x]
    sub a, 8
    ld b, a
    call get_tile_by_pixel ; Returns tile address in hl
    ld a, [hl]
    call is_wall_tile
    jr nz, .no_down 
    ld bc, oam_buffer_player_y
    ld a, [bc]
    add a, $2
    ld [bc], a
    jp .__fall_by
    .fall_slow
    ; No collision, update position
    ld a, [main_player_y]
    add a, 4 ; The check starts from upleft, lets add 4 pixel distance to make it more centered
    sub a, 16-1 ; the sprite y is not aligned with tile position (0, 0), removing 16 bit removes this difference
    ld c, a
    ld a, [main_player_x]
    sub a, 8
    ld b, a
    call get_tile_by_pixel ; Returns tile address in hl
    ld a, [hl]
    call is_wall_tile
    jr nz, .no_down 
    ld bc, oam_buffer_player_y
    ld a, [bc]
    add a, $1
    ld [bc], a
    ld a, [falling_speed]
    add 1
    ld [falling_speed], a
    .__fall_by

    ; When the player is falling will go in the state falling
    ld a, %00001000
    ld [player_state], a
    ret  ; end_update_player_position
    .no_down
    ld a, $1
    ld [falling_speed], a
    ; If no down condition is met, we are not falling anymore
    ld b , %11110111 ; Mask to reset falling bit
    ld a, [player_state]
    and b 
    ld [player_state], a
    ret
```

Andiamo a compilare ed eseguire il nostro codice per poter testare il salto del personaggio e le sue nuove animaizoni

```
# cd /<directory_del_progetto/feli/
# ./run_program.<estensione>
# java -jar Emulicius/Emulicius.jar feli.gbc
```