SECTION "Overworld", rom0

apply_gravity:
    ld bc, oam_buffer                 ; BC Contains now Y position 
    ld a, [oam_buffer]
    ld [main_player_y], a
    ld a, [oam_buffer+1]
    ld [main_player_x], a

    ld a, [main_player_y]
    add $1
    ld [main_player_y], a ;Moving delta y by one to check if there would be a collision
    call check_player_collision
    jr c, .no_gravity
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;No collision, update position
    ld bc, oam_buffer ; y pos
    ld a, [bc]
    add 1
    ld [bc], a
.no_gravity