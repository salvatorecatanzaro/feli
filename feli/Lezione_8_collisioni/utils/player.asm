SECTION "Player", ROM0

try_apply_gravity:
    ; Apply gravity on character
    ld bc, oam_buffer_player_y
    ld a, [bc]
    add a, $1
    ld [bc], a
    ret

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


update_player_position:
    call try_move_left
    call try_move_right
    call try_apply_gravity
    .end_update_player_position
    ret   
