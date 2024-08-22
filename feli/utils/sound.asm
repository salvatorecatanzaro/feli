

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
	ld a, AUDENA_ON
	ld [rNR52], a
	ld a, %10000001  ; Duty cycle 12.5% The sound starts immediatly
	ld [rNR10], a
	ld a, %01111111  ; Starting volume set to max
	ld [rNR12], a
	ld a, %10000000  ; Enable channel 1
	ld [rNR14], a          


	ld a, %00000000 ; duty cycle 12.5 
	ld [rNR21], a
	ld a, %00011111 ; init volume to max for channel 2
	ld [rNR22], a
	ld a, %00000000 ; turn the channel off, turn it on just for playing player sounds
	ld [rNR24], a

    ret


get_current_note:
	ld de, sound_melody
	ld a, [sound_counter]
	add a, e
	ld e, a 
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a


	ld a, [sound_note_n]   ;
	ld b, a                ;   sound counter - sound_note_n
	ld a, [sound_counter]  ;   if the result is not 0 return
	add a, $2             ;   Increment sound_counter by 1
	ld [sound_counter], a  ;
	cp a, b                ;   else reset the counter to 0
	jr z, .reset_count     ;
	ret                    ;
	.reset_count           ;
	xor a                  ;
	ld [sound_counter], a  ;
	ret                    ;


update_audio:
	ld a, [sound_length]
    inc a
    ld [sound_length], a
    cp a, $1c ; Every 10 frames (a tenth of a second), run the following code
    jp nz, .end_update_audio

    ; Reset the frame counter back to 0
    xor a
    ld [sound_length], a

	call get_current_note ; current note will be put in hl
 	ld a, l
 	ld [rNR13], a   ; Load lower part to 13
 	ld a, h
 	ld [rNR14], a   ; Load High bit to 14
 	.end_update_audio
    ret

 jump_sound:
 	.reproduce_another_freq
 	ld hl, $0700
 	ld a, l
 	ld [rNR23], a   ; Load lower part to 13
 	ld a, h
 	ld [rNR24], a   ; Load High bit to 14
 	ret

