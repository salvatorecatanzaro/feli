SECTION "CONTROLS", ROM0[$0000]

get_buttons_state:
;   REGISTRO $FF00 - 
    ;    7/6      5                4                3               2          1           0
    ; P1      Select buttons  Select d-pad    Start / Down    Select / Up   B / Left    A / Right
    ; Select buttons: Quanto questo bit è uguale a zero, I tasti start, select, B ed A possono esser letti nella parte inferiore del byte.
    ; Select d-pad: Se questo bit è uguale a zero, Le direzioni del dpad possono esser lette nella parte inferiore del byte.
    ; La parte bassa del byte è destinate alla sola lettura e in maniera non convenzionale un tasto premuto equivale ad uno 0 e non ad un 1.
    ; la variabile buttons conterrà lo stato dei tasti
    
    ld a, %00010000 ; imposto il bit 6 a 1
    ld [$ff00], a   ; e lo carico in $ff00
    nop
    ld a, [$ff00] ; Leggo due volte il valore
    ld a, [$ff00] ; per sicurezza (Operazione ripetuta due volte sotto consiglio della community)
    ld b, a       ; il valore dei tasti letto lo inseriamo in b
    
    ; sla fa uno shift dei bit a sinistra, lo facciamo 4 volte così nella parte alta del byte avremo a, b, select, start
    sla b 
    sla b
    sla b
    sla b
    ld a, %00100000 ; ora selezioniamo il dpad
    ld [$ff00], a
    nop
    ld a, [$ff00]
    ld a, [$ff00]
    ld c, %00001111  ; Questa volta carichiamo lo stato del dpad in c
    and c            ; facciamo un and con a per confermare il valore ottenuto
    or b             ; Facciamo un or con b, così in a avremo nella parte alta del 
                     ;registro tutti a b start, select e nella parte bassa i 
                     ; valori del dpad
    ld [buttons], a  ; carico il valore ottenuto nell’ indirizzo puntato dalla 
                     ; variabile buttons
    ret