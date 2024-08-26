

turn_off_sound:
	ld a, %1000000
	; Shut sound down
	ld [rNR52], a
	ret


; Funzione per suonare una nota
play_note:
    ld a, l          ; Carica la parte bassa della frequenza
    ldh [rNR13], a   ; Scrive la parte bassa nel registro NR13

    ld a, h          ; Carica la parte alta della frequenza
    ldh [rNR14], a   ; Scrive la parte alta nel registro NR14

    ; Delay per durata della nota
    call delay
    ret

 ; Funzione di delay per controllare la durata della nota
delay:
    ld bc, $ffff  ; Usa un ciclo lungo per il delay
delay_loop:
    dec bc
    ld a, b
    or c
    jr nz, delay_loop
    ret

delay_short:
    ld bc, $8000  ; Usa un ciclo lungo per il delay
delay_loop_short:
    dec bc
    ld a, b
    or c
    jr nz, delay_loop_short
    ret


delay_mid:
    ld bc, $8000  ; Usa un ciclo lungo per il delay
delay_loop_mid:
    dec bc
    ld a, b
    or c
    jr nz, delay_loop_mid
    ret

init_audio:
	xor a
	ld [note_tick], a
	ld [sound_length], a
	ld [sound_pointer], a      ;
	
	ld a, AUDENA_ON
	ld [rNR52], a
	ld a, %00111000  ; Starting volume set to medium
	ld [rNR12], a
	ld a, %10000000  ; Enable channel 1
	ld [rNR14], a          


	ld a, %01000010 ; duty cycle 50% 
	ld [rNR21], a
	ld a, %00110000 ; init volume to max for channel 2
	ld [rNR22], a
	ld a, %11000000 ; turn the channel off, turn it on just for playing player sounds
	ld [rNR24], a

    ret


get_current_note:
	ld de, sound_melody
	ld a, [sound_pointer]
	add a, e

	ld e, a 
	jr nc, .no_carry_current_note   ; 
	ld a, d                         ;
	add a, $1                       ;
	ld d, a                         ;
	.no_carry_current_note
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	ret                    ;


get_current_note_pres_screen:

	ret                    ;


; @param hl the base address of a melody
; @return in l the length of the current note
get_current_sound_length:
	xor a                           ; 
	ld d, a                         ; Each starting address for sound memory has
	ld e, a                         ; 
	ld a, $2                        ; 0) 1 byte H note, 1) 1 byte L note, 2) 1 byte Sound length
	ld e, a                         ;
	add hl, de                      ; lets move by a offset of 3 to get Sound length
	ld a, [sound_pointer]           ;
	add a, l                        ; The starting address depends on sound_pointer
	ld l, a                         ; lets add it to hl so we will have our note
	jr nc, .no_carry_sound_pointer  ; as base address in hl
	ld a, h                         ;
	add a, $1                       ;
	ld h, a                         ;
	.no_carry_sound_pointer

	ld a, [hl]                      ; get length value and put it in l
	ld l, a                         ; 
	ret


update_audio:
	ld a, [note_tick]                    ;
	or a, %00000000                      ;  If the note tick is on zero it means that we are going to play
	jr z, .play_new_note                 ;  a new note

	ld hl, sound_melody
	call get_current_sound_length        ; put sound length in l
    ld a, [note_tick]                    ; get the number of ticks 
    cp a, l                              ; check if all ticks have been played
    jr nz, .end_update_note_tick         ; if not, keep playing the same sound 

    ld a, [sound_pointer]                ;
    add a, $4                            ; if the result of the previous cp is zero, it means that we have to move
    ld [sound_pointer], a                ; the sound_pointer to the next note
    xor a                                ; and we need to reset note_tick to zero in order
    ld [note_tick], a                    ; to play the new sound.
    jp .end_update_audio

    .play_new_note
	call get_current_note ; current note will be put in hl
 	ld a, l
 	ld [rNR13], a   ; Load lower part to 13
 	ld a, h
 	ld [rNR14], a   ; Load High bit to 14
 	.end_update_note_tick
 	ld a, [note_tick]                    ;
	inc a                                ;  Note tick will tell us how many cycles the note has been
    ld [note_tick], a                    ;  playing. if it is zero we are on a new note and we should just
    ld a, [sound_pointer]                ;
    ld b, a                              ;  if sound pointer is the same length as sound_length, reset it 
    ld a, [sound_melody_n_of_notes]                 ;  to zero and start the melody from the beginning
    cp a, b                              ;
    jr nz, .end_update_audio             ;
    xor a                                ;
    ld [sound_pointer], a                ;
    .end_update_audio
    ret

 jump_sound:
 	ld hl, G2
 	ld a, l
 	ld [rNR23], a         ; Load lower part to 13
 	ld a, h
 	or a, %11000000       ; bit 7 - Channel enabled. 
 	ld [rNR24], a         ; bit 6 - Period enabled (Or the sound will play forever). Period depends on nr21
 	inc hl
 	ret

eat_food_sound:
 	ld hl, $06fa
 	ld a, l
 	ld [rNR23], a         ; Load lower part to 13
 	ld a, h
 	or a, %11000000       ; bit 7 - Channel enabled. 
 	ld [rNR24], a         ; bit 6 - Period enabled (Or the sound will play forever). Period depends on nr21
 	inc hl
 	ret

victory_sound:
	ld a, [sound_length]
    inc a
    ld [sound_length], a
    cp a, $FF ; Every 10 frames (a tenth of a second), run the following code
    jp nz, .end_update_audio_pres_screen

    ; Reset the frame counter back to 0
    xor a
    ld [sound_length], a

	call get_current_note_pres_screen ; current note will be put in hl
 	ld a, l
 	ld [rNR13], a   ; Load lower part to 13
 	ld a, h
 	ld [rNR14], a   ; Load High bit to 14
 	.end_update_audio_pres_screen
 	ret