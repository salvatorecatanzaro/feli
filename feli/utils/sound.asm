
turn_off_sound:
	xor a
	; Shut sound down
	ld [rNR52], a
	ret
