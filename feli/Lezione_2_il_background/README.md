# Lezione 2 - Il Background

## Inizializzazione progetto

Ogni volta che avviamo la nostra console, le aree di memoria potrebbero essere sporche e non inizializzate a zero, per evitare qualsiasi tipo di comportamento inaspettato durante l’esecuzione del gioco, inizializzeremo tutte le aree di memoria a zero con la seguente subroutine

```
*file: utils/vram.asm*

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

```

La subroutine è molto semplice: essa non fa altro che impostare a zero tutti gli indirizzi di memoria che vanno dall’ indirizzo contenuto nella coppia di registri hl fino all’indirizzo che si trova nella coppia di registri de. Il codice lo salveremo nella cartella utils, in un file denominato vram.asm. Per includerlo nel nostro programma ci basterà inserire la direttiva INCLUDE come prima istruzione del file main.asm. Includeremo inoltre anche il file hardware.inc che contiene tutte quante le costanti associati agli indirizzi dei registri.
Quando utilizziamo la direttiva INCLUDE tutto il codice presente nel file indicato tra doppi apici viene incluso nel file dove è dichiarato il comando.

```
*file: main.asm*

INCLUDE "utils/vram.asm"
INCLUDE “utils/hardware.inc”
```

L’operazione di pulizia della memoria la verrà effettuata una sola volta, prima di entrare nel loop del gioco, quindi subito dopo la label start.

```
*file: main.asm*

ld hl, $8000                   ; vRAM
ld de, $9fff                   ; dall’indirizzo 0:$8000 a 0:$9fff 
call clear_mem_area            ;
ld hl, $fe00                   ; OAM
ld de, $fe9f                   ; dall’indirizzo 0:$fe00 a 0:$fe9f
call clear_mem_area            ;
                               ;  
ld a, %00000001                ; vRAM bank 1
ld [rVBK], a                   ; Quando in questo registro inseriamo il valore 1, viene impostato il bank 1 
                               ; della vRAM
ld hl, $8000                   ; Impostiamo tutti I valori della 1:$8000 1:$9fff 
ld de, $9fff                   ;
call clear_mem_area            ;  
xor a                          ; Impostiamo tutti I valori della vRAM bank a 0
ld [rVBK], a                   ; 
ld hl, $C000                   ; WRAM
ld de, $DFFF                   ;  dall’indirizzo $C000 to $DFFF
call clear_mem_area            ;
```  

## Gestione Background
Dopo aver pulito tutta la memoria ci occupiamo del background. Ci sono due momenti in cui è possibile disegnare sullo schermo:
* *VBlank* è il momento in cui il Game Boy non sta aggiornando i pixel sullo schermo perché si prepara a disegnare il prossimo frame.
* *Schermo spento* è possibile spegnere lo schermo (Questa operazione può essere effettuata solo durante un VBlank oppure si potrebbe danneggiare lo schermo) , aggiornare il suo contenuto per poi riaccenderlo.

Quindi definiamo la subroutine che ci permette di aspettare un periodo di VBlank e inseriamola in utils/graphics.asm

```
*file: utils/graphics.asm*

  SECTION "vRAM code", ROM0 ; In cima al nostro file definiamo una 
                            ; nuova sezione
  
  wait_vblank:         
  .notvblank           ; definita la label notvblank
  ld a, [$ff44]        ; salviamo in a la coordinata y (la linea che 
                       ; sta disegnando al momento il Game Boy)
                       ; 144 - 153 VBlank area
  cp 144               ; Operazione aritmetica a - 144
 jr c, .notvblank     ; Se c’è un carry non siamo in vblank, ripetiamo 
                      ; il ciclo
ret
```
definiamo anche la subroutine che si occupa della copia dei dati da una parte all’altra della memoria e inseriamola nel file utils/vram.asm

```
*file: utils/vram.asm*

1.  ; -- !!!Disable screen - ppu before calling this method!!!
2.  ; -- this subroutine is used to copy data from source to destination
3.  ; -- hl: destination
4.  ; -- de: source
5.  ; -- bc: map len
6.  copy_data_to_destination:
7.  .copy_bin_loop           ; definita la label copy_bin_loop
8.  ld a, [de]               ; Prendiamo un byte dall’indirizzo contenuto 
9.                           ; nella coppia di registri de
10. ld [hli], a              ; Lo inseriamo nell’indirizzo contenuto dalla 
11.                          ; coppia di registri hl e incrementiamo hl
12. inc de                   ; incrementiamo di uno de cosi puntiamo al 
13.                          ; prossimo indirizzo
14. dec bc                   ; Decrementiamo bc (La quantita di dati da 
15.                          ; copiare)
16. ld a, b
17. or c
18. jr nz, .copy_bin_loop    ; Cicliamo fin quando bc non diventa zero
19. ret

```

