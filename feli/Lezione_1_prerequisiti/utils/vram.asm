SECTION "vRAM code", ROM0[$0029]

; -- Prima di richiamare questo metodo disabilita lo schermo
; -- Questa subroutine pulisce la memoria che parte dall'indirizzo contenuto in hl fino a quello contenuto in de
; -- hl: start
; -- de: end
clear_mem_area:         ; Nome della subroutine
	.clear_loop             ; Dichiarazione label .clear_loop
	xor a                   ; il registro a (Accumulatore) viene inizializzato a zero
	ld [hli], a             ; inserisce il valore di a all’indirizzo di memoria puntato da hl per poi far puntare 
	                        ; hl all’indirizzo di memoria successivo (HL Incement)
	 
	ld a, l                 ; Carica il valore del registro l nel registro a
	cp a, e                 ; Viene eseguita l’operazione aritmetica a - e
	jp nz, .clear_loop      ; Se il valore non è zero, viene rieseguito il codice a partire da .clear_loop
	ld a, h                 ; Carica il valore di h in a 
	cp a, d                 ; Viene eseguita l’operazione aritmetica a - d
	jp nz, .clear_loop      ; se il valore non è zero si riesegue il codice a partire da .clear_loop
	ret                     ; Ritorna dalla subroutine
