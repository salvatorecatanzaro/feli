# Lezione 1 - Prerequisiti
Per sviluppare un gioco per il Game Boy Color avremo bisogno dei seguenti strumenti:
*	*RGBDS* Il nostro assembler, viene utilizzato per convertire tutte le istruzioni del programma in linguaggio macchina.
*	*Emulatore* Emula l'hardware reale e ci consente di testare velocemente il codice implementato.
*	*Un IDE o un editor di testo* Necessario per scrivere e per organizzare il codice.

## 1.1 Struttura del progetto
Prima di iniziare a programmare, definiamo la struttura del nostro progetto. L’immagine che segue mostra l’orgranizzazione delle directory:

<div align="center">
  <img src="img/alberatura_progetto.png" title="Alberatura progetto" width="300" height="300">
</div>

Di seguito descriviamo quanto mostrato nell'immagine
*	*artifacts* Contiene le rom generate durante lo sviluppo del progetto.
*	*backgrounds* Raccoglie tutti gli sfondi utilizzati nel gioco
*	*Emulicius* Contiene il progetto dell'emulatore che utilizzeremo per i test
*	*Sprites* Contiene tutti gli sprite del gioco
*	*utils* include i file con estensione .asm che verranno importati nel file main

La cartella utils è fondamentale poiché contiene la logica aggiuntiva che viene usata dal file main. Nei capitoli successivi, discuteremo in dettaglio il codice presente all'interno di questi file.

Per completare la configurazione, copiamo le seguenti directory nella root del progetto:
* *Emulicius*
* *hardware.inc*
* *backgrounds*
* *sprites*

Aggiungiamo infine i due script necessari per la compilazione del progetto

---
*file: run_program.bat*
```
rgbasm -o feli.o main.asm
if %errorlevel% neq 0 exit 1
rgblink -o feli.gbc feli.o
rgbfix -C -v -p 0 feli.gbc
```
---
*file: run_program.sh*
```
#!/bin/bash

rgbasm -o main.o main.asm

if [[ $? != 0 ]]; then
  echo "Error while compiling rgbasm"
  exit 1
fi
rgblink -o feli.gbc main.o
rgbfix -C -v -p 0 feli.gbc
```
---

Se ci troviamo su un sistema operativo Unix-like, eseguiamo il seguente comando per rendere lo script eseguibile

```
# chmod +x run_program.sh
```



## 1.2 Il main loop
Il primo passo è quello di creare il file main.asm nella stessa directory dell’immagine "Alberatura progetto".
Il processore del Game Boy e del Game Boy color inizia ad eseguire le istruzioni a partire dall’indirizzo di memoria $100, in questa area di memoria, però, c’è spazio sufficiente solo per due comandi. il primo sarà nop (No operation), il secondo comando sarà un'istruzione di salto all’indirizzo di memoria dove risiede il nostro codice. l’istruzione 'jp' farà in modo che la prossima riga di codice ad essere eseguita dal program counter sarà quella che corrisponde all’indirizzo di memoria dove risiede la label Start.
Una label è un’etichetta che associa un indirizzo specifico all'inizio di un blocco di istruzioni.

---
*file: main.asm*
```
SECTION "Header", ROM0[$100]
EntryPoint: 
nop 
jp Start
    
REPT $150 - $104 ;
    db 0         ; riservo lo spazio tra $104 e $150 all' header
ENDR             ;
```
---

Definiamo una nuova sezione del codice, che partirà dall’indirizzo di memoria $150. è convenzione utilizzare questo indirizzo per il codice principale nei giochi per Game Boy, è quì che inseriremo il main loop, la struttura centrale che gestirà il flusso del gioco.

Ogni istruzione presente all'interno del main loop viene ripetuta ciclicamente durante la partita. Esso si occupa di gestire gli input dell'utente, controllare gli eventi e aggiornare la grafica 

---
```
SECTION "Header", ROM0[$100]
EntryPoint: 
nop 
jp Start ; Leave this tiny space

REPT $150 - $104 ;
    db 0         ; riservo lo spazio tra $104 e $150 all' header
ENDR             ;

SECTION "Game code", ROM0[$150]
Start:
.main_loop:
jp .main_loop
```
---
## 1.3 Inizializzazione della memoria

Ogni volta che avviamo la console, le aree di memoria potrebbero contenere valori casuali e non essere inizializzate a zero. Per evitare comportamenti inaspettati durante l’esecuzione del gioco, è importante azzerare tutte le aree di memoria. Lo facciamo aggiungendo il codice che segue:

---
*file: utils/vram.asm*
```
SECTION "vRAM code", ROM0
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
---

La subroutine è molto semplice: imposta a zero tutti gli indirizzi di memoria dall’ indirizzo contenuto nella coppia di registri hl e quello indicato nella coppia di registri de. Il codice lo salveremo nella cartella utils, in un file denominato vram.asm. Per includerlo nel nostro programma sarà sufficiente inserire la direttiva INCLUDE come prima istruzione del file main. Includeremo inoltre anche il file hardware.inc, che contiene tutte le costanti associati agli indirizzi dei registri, semplificando la gestione degli indirizzi di memoria hardware nel codice. 

---
*file: main.asm*
```
INCLUDE "utils/vram.asm"
INCLUDE "hardware.inc"
```
---

L’operazione di pulizia della memoria la verrà effettuata una sola volta, prima di entrare nel loop del gioco, subito dopo la label start.
---
*file: main.asm*
```
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
---

## 1.4 Esecuzione del codice
Ora che abbiamo definito lo scheletro di base del nostro codice, possiamo compilarlo ed eseguire il codice nell'emulatore. Anche se al momento lo schermo è bianco, abbiamo di fatto generato la nostra prima ROM funzionante, pronta per i prossimi sviluppi.

Comandi per compilare il codice:

```
# cd /<directory_del_progetto/feli/
# ./run_program.<estensione>
# java -jar Emulicius/Emulicius.jar feli.gbc
```

<div align="center">
  <img src="img/output_lezione_1.png" title="Output lezione 1" width="300" height="300">
</div>
