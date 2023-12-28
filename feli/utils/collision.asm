check_player_collision:
    ; Checks the projection of the player into the overworld to see if there is any collision
    ; Collision is tile based

    ; rect1.x < rect2.x + rect2.width &&
    ld hl, collision_rectangles      ; x pos in hl
    ld a, [hli]                      ; x pos in a (increment hl)
    add [hl]                         ; add x and x width
    ld [rectangle_x_plus_width], a   ; put calculated value in rectangle_x_width
    ld a, [main_player_x]            ; player x pos in a
    ld hl, rectangle_x_plus_width    ; rectangle x plus width in hl 
    cp [hl]                          ; player x - rectangle x plus width
    jr nc, .no_collision             ; if it's minus value then rect1.x < rect2.x + rect2.width
    ; rect1.x + rect1.width > rect2.x &&
    ld a, [main_player_x]            ; x pos in a
    add $06 ;default player width    ; add 5 to get x plus player width
    ld [player_x_plus_width], a   ; put value in collision box
    ld hl, player_x_plus_width    ; put value in hl
    ld a, [collision_rectangles]     ; put object x in a
    cp [hl]                          ; object rectangle - (player x + width)
    jr nc, .no_collision
    ; rect1.y < rect2.y + rect2.height &&
    ld hl, collision_rectangles + 2  
    ld a, [hli]
    add [hl]
    ld [rectangle_y_plus_width], a
    ld a, [main_player_y]
    ld hl, rectangle_y_plus_width  
    cp [hl]                        ; player y - (rect y + rect y width)                          
    jr nc, .no_collision
    ; rect1.y + rect1.height > rect2.y
    ld a, [main_player_y]
    add $03 ; default player y len
    ld [player_y_plus_width], a
    ld hl, player_y_plus_width
    ld a, collision_rectangles + 2 
    cp [hl]
    jr nc, .no_collision
    
.collision_detected
    scf 

.no_collision
    ;check if new position goes in a new tile
    ret