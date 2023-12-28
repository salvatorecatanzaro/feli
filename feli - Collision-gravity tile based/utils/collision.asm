check_player_collision:
    ; Checks the projection of the player into the overworld to see if there is any collision
    ; Collision is tile based
    
    call get_player_position_in_overworld

    ; This piece of code works, when the player gets to new tile it stops. Now there must be a new check:
    ; If the player goes in a tile in which the id is of a tile in a collection of collision tiles, it will not move
    ; else it will move normally.
    ld bc, tile_collision
    .collision_tiles_r
    ld a, [bc]
    or $00
    jr z, .no_collision
    inc bc

    xor a, [hl] ; Compare the current tile collision with the actual tyle to see if there is a collision detected
    jr z, .collision_detected

    or $00
    jr nz, .collision_tiles_r
    jp .no_collision

.collision_detected
    scf 

.no_collision
    ;check if new position goes in a new tile
    ret