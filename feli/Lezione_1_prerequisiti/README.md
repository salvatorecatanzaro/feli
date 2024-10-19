# Lezione 1 - Prerequisiti
Per poter sviluppare un gioco per Game Boy Color avremo bisogno di alcuni strumenti
*	RGBDS il nostro assembler
*	Emulatore Utilzzato per testare il nostro gioco
*	Un IDE o un editor di testo per scrivere il nostro codice

## 1.1 Struttura del progetto
Prima di cominciare a programmare definiamo la struttura del nostro progetto, l’immagine che segue mostra l’alberatura scelta

![Testo alternativo](alberatura_progetto.png "Alberatura progetto")

Di seguito una breve descrizione delle varie directory e di quello che è l’utilizzo che ne viene fatto
*	*artifacts* Contiene le rom che produciamo per il nostro progetto
*	*backgrounds* Contiene gli sfondi
*	*Emulicius* Contiene il progetto dell’emulatore che andremo ad utilizzare
*	*Sprites* Contiene tutti gli sprite del progetto
*	*Utils* Contiene tutti i file .asm che includeremo nel main

La cartella utils è fondamentale e contiene molta della logica aggiuntiva che viene inclusa ed utilizzata dal file main.asm, il codice presente all’interno di essi sarà discusso nei prossimi capitoli.
Per ora lasceremo tutte le cartelle vuote, tranne Emulicious che non è altro che il progetto dell'emulatore, backgrounds e sprites.

## 1.2 Preparazione alberatura