
SECTION "Header", ROM0[$100]
EntryPoint: 
nop 
jp Start ; Leave this tiny space

SECTION "Game code", ROM0[$150]
Start:
.main_loop:
jp .main_loop