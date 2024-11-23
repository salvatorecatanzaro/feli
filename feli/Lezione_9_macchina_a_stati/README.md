# Lezione 9 - Macchina a stati

Per gestire eventi come il salto o le animazioni, è necessario conoscere in ogni istante lo stato del personaggio. Ad esempio, se il personaggio è in aria, non potrà eseguire un nuovo salto fino a quando non tocca terra oppure se sta eseguendo un movimento verso sinistra dobbiamo cambiare l’attributo che gira lo sprite verso sinistra. Per monitorare lo stato corrente del giocatore utilizziamo la variabile *player_state*. Introduciamo quindi nella WRAM tutte le variabili che andremo ad utilizzare.

---
*file: utils/wram.asm*
```
SECTION "Player_state", WRAM0
; Questa sezione viene utilizzata per definire le variabili che riguardano
; lo stato dei giocatori

player_state: ds 1
player2_state: ds 1
; le variabili state_<nome_stato>_count vengono utilizzate per definire quale 
; frame dell'animazione è necessario utilizzare
; eg. L’ultimo frame nello stato running era 0, il prossimo frame sarà 1
state_idle_count: ds 1
state_running_count: ds 1
state_running_count_player2: ds 1
state_jmp_count: ds 1
state_jmp_count_player2: ds 1
state_3_count: ds 1            ; 
state_4_count: ds 1            ; Per sviluppi futuri …
state_5_count: ds 1            ;
state_6_count: ds 1            ;
jp_max_count: ds 1
holding_jump: ds 1
falling_speed: ds 1
SECTION "Counter", WRAM0
player_animation_frame_counter: ds 1 ; Utilizzato per rallentare l’animazione del 
                                     ; giocatore (Senza l’animazione sarebbe 
                                     ; velocissima)
player2_animation_frame_counter: ds 1 
food_counter: ds 1
frame_counter: ds 1                 ; Contatore dei frame
time_frame_based: ds 1              ; Ogni N frame_counter questo valore è incrementato  
                                    ; di uno
food_xy_position_counter: ds 1      ; Questo valore viene utilizzato per ottenere 
                                    ; ogni volta una nuova posizione sullo schermo 
                                    ; per il cibo
player2_climbing_counter: ds 1
player2_climb_max_count: ds 1
water_animation_counter: ds 1
water_animation_frame_counter: ds 1
platform_y_old: ds 1            ; Usato per sapere su quale piattaforma si trova 
                                ; il giocatore 2
state_swimming_count: ds 1      ; Per il movimento sott’acqua
state_swimming_count_p2: ds 1          
presentation_screen_flicker_counter: ds 1
sound_length: ds 1
```
---

Le variabili che abbiamo definito devono essere inizializzate, lo facciamo subito prima di eseguire il main loop

---
*file: main.asm*
```
file: main.asm

    xor a
    ld [player_state], a  ; setting player state to IDLE
    ld [player2_state], a  ; setting player2 state to IDLE
    ld [player_animation_frame_counter], a
    ld [water_animation_frame_counter], a   
    ld [player2_animation_frame_counter], a
    ld [food_xy_position_counter], a
    ; init all states to 1
    ld a, 1
    ld [state_idle_count], a
    ld [state_running_count], a
    ld [state_running_count_player2], a
    ld [state_swimming_count], a
    ld [state_swimming_count_p2], a
    ld [state_jmp_count], a 
    ld [state_jmp_count_player2], a
    ld [state_3_count], a
    ld [state_4_count], a 
    ld [state_5_count], a
    ld [state_6_count], a
    ld [falling_speed], a 
    ld [food_counter], a
    ld [frame_counter], a
    ld [water_animation_counter], a  
    ld [player2_climbing_counter], a
    ld [time_frame_based], a
    ld a, $15
    ld [jp_max_count], a
    ld a, $80
    ld [player2_climb_max_count], a
    xor a
    ld [holding_jump], a
```
---

All'interno del main loop, invece, andiamo a richiamare subito dopo la *update_player_position* la routine *player_animation* che implementiamo nel file player.

---
*file: main.asm*
```
call update_player_position
call player_animation
```
---

---
*file: utils/player.asm*
```
player_animation:
    ld a, [player_animation_frame_counter]  ;
    inc a                                   ; Il codice che segue viene eseguito 
    ld [player_animation_frame_counter], a  ; ogni 10 frame
    cp a, 10                                ;
    jp nz, .endstatecheck                   ;

    xor a                                   ; Resetto il frame counter a zero
    ld [player_animation_frame_counter], a  ;
    ld a, [player_state]                    ;
    or a                                    ; Se player state è 0, oppure il bit 0
    jp z, .gotostate0                       ; è settato allora saltiamo allo stato 
    bit 0, a                                ; 0 (Idle)
    jp nz, .gotostate0                      ;
    bit 1, a                                ; Se il bit 1 è settato, saltiamo
    jp nz, .gotostate1                      ; allo stato 1
    bit 2, a                                ; se il bit 2 è settato, saltiamo
    jp nz, .gotostate2                      ; allo stato 2
    bit 3, a                                ; …
    jp nz, .gotostate3                      ; …
    bit 4, a                                ; …
    jp nz, .gotostate4                      ; …
    bit 5, a                                ; …
    jp nz, .gotostate5                      ; …
    bit 6, a                                ; Se il bit 6 è settato, saltiamo
    jp nz, .gotostate6                      ; allo stato 6

    .gotostate0 ; idle
    ld a, 1                                 ;
    ld [player_state], a                    ;
    ; Copy the bin data to video ram        ;
    ld hl, $8800                            ; Disegna Il giocatore nello stato 
    ld de, player_1_idle ; Starting address ; IDLE
    ld bc, __player_1_idle - player_1_idle  ; 
    call copy_data_to_destination           ;
    jp .endstatecheck                       ; Salta alla fine della routine

    .gotostate1 ; running                   ;
    ; Copy the bin data to video ram        ;
    ld hl, $8800                            ;
    ld a, [state_running_count]             ;
    ld b, $1                                ;
    cp a, b                                 ;
    jr nz, .state_running_frame_2           ;
    ; draw frame 1                          ;
    ld de, player1_state_running_1          ; Starting address
    ld bc, __player1_state_running_1 - player1_state_running_1
    call copy_data_to_destination           ;
    ld a, $2                                ;
    ld [state_running_count], a             ;
    jp .endstatecheck                       ;
    ; draw frame 2
    .state_running_frame_2
    ld de, player1_state_running_2 ; Starting address
    ld bc, __player1_state_running_2 - player1_state_running_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; reset state to 1
    ld a, $1
    ld [state_running_count], a
    jp .endstatecheck

    .gotostate2 ; jumping
    ld a, [state_jmp_count]
    ld b, $4
    cp a, b
    jr nz, .state_2_frame_2
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player1_state_jmp_1_1 ; Starting address
    ld bc, __player1_state_jmp_1_1 - player1_state_jmp_1_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; increment by 1 state counter
    ld a, [state_jmp_count]
    add a, 1
    ld [state_jmp_count], a
    jp .endstatecheck
    .state_2_frame_2
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player1_state_jmp_1_2 ; Starting address
    ld bc, __player1_state_jmp_1_2 - player1_state_jmp_1_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    

    .gotostate3 ; falling
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player1_state_jmp_1_2 ; Starting address
    ld bc, __player1_state_jmp_1_2 - player1_state_jmp_1_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; increment by 1 state counter
    jp .endstatecheck

    .gotostate4 ; swimming
    ; Copy the bin data to video ram
    ld hl, $8800
    ld a, [state_swimming_count]
    ld b, $1
    cp a, b
    jr nz, .state_swimming_frame_2
    ; draw frame 1
    ld de, player1_state_swimming_2 ; Starting address
    ld bc, __player1_state_swimming_2 - player1_state_swimming_2 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ld a, $2
    ld [state_swimming_count], a
    jp .endstatecheck
    ; draw frame 2
    .state_swimming_frame_2
    ld de, player1_state_swimming_1 ; Starting address
    ld bc, __player1_state_swimming_1 - player1_state_swimming_1 ; Length -> it's a subtraciton
    call copy_data_to_destination
    ; reset state to 1
    ld a, $1
    ld [state_swimming_count], a
    jp .endstatecheck

    .gotostate5 ; joy
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player ; Starting address
    ld bc, __player - player ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheck

    .gotostate6 ; powerup
    ; Copy the bin data to video ram
    ld hl, $8800
    ld de, player ; Starting address
    ld bc, __player - player ; Length -> it's a subtraciton
    call copy_data_to_destination
    jp .endstatecheck


    .endstatecheck
    ret
```
---

Nella subroutine appena definita è possibile vedere come in base allo stato del player sarà disegnata a schermo una animazione diversa.

Includiamo nella ROM tutte le textures delle animazioni che utilizziamo nella subroutine *player_state*

---

*file utils/rom.asm*
```

player_state_running_1:
  INCBIN "sprites/run_1.chr"                       ; Running state sprite 1
__player_state_running_1:

player_state_running_2:
  INCBIN "sprites/run_2.chr"                       ; Running state sprite 2
__player_state_running_2:

player1_state_running_1:
  INCBIN "sprites/player_1_running_1.chr"                       ; Running state sprite 1
__player1_state_running_1:

player1_state_running_2:
  INCBIN "sprites/player_1_running_2.chr"                       ; Running state sprite 2
__player1_state_running_2:

player_state_jmp_1_1:
  INCBIN "sprites/cat_jmp_1.chr"                   ; Jumping state sprite 1
__player_state_jmp_1_1:

player_state_jmp_1_2:
  INCBIN "sprites/cat_jmp_2.chr"                   ; Jumping state sprite 2
__player_state_jmp_1_2:

player1_state_jmp_1_1:
  INCBIN "sprites/player_1_jumping_1.chr"                   ; Jumping state sprite 1
__player1_state_jmp_1_1:

player1_state_jmp_1_2:
  INCBIN "sprites/player_1_jumping_2.chr"                   ; Jumping state sprite 2
__player1_state_jmp_1_2:

joy:
  INCBIN "sprites/joy.chr"                                            
__joy:

player1_state_swimming_1:
  INCBIN "sprites/swimming_1.chr"
__player1_state_swimming_1:

player1_state_swimming_2:
  INCBIN "sprites/swimming_2.chr"
__player1_state_swimming_2:
```
---

In questo capitolo abbiamo soltanto aggiunto del nuovo codice per predisporci ai prossimi sviluppi, compilando non noteremo infatti alcuna differenza rispetto a ciò che è stato fatto in precedenza.
