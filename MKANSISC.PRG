* MKANSISC - Make MakeANSI.PRG startup screen
activate screen
clear
set talk off
set sysmenu off
@     0,0 say replicate("А",80) color RB+/w
@ row(),0 say replicate("А",80) color RB/w
@ row(),0 say replicate("А",80) color B+/w
@ row(),0 say replicate("А",80) color B/w
@ row(),0 say replicate("А",80) color BG+/w
@ row(),0 say replicate("А",80) color BG/w
@ row(),0 say replicate("А",80) color G+/w
@ row(),0 say replicate("А",80) color G/w
@ row(),0 say replicate("А",80) color GR+/w
@ row(),0 say replicate("А",80) color GR/w
@ row(),0 say replicate("А",80) color R+/w
@ row(),0 say replicate("А",80) color R/w

@ row(),0 say replicate("Б",80) color RB/w
@ row(),0 say replicate("Б",80) color RB+/w
@ row(),0 say replicate("Б",80) color B/w
@ row(),0 say replicate("Б",80) color B+/w
@ row(),0 say replicate("Б",80) color BG+/w
@ row(),0 say replicate("Б",80) color BG/w
@ row(),0 say replicate("Б",80) color G+/w
@ row(),0 say replicate("Б",80) color G/w
@ row(),0 say replicate("Б",80) color GR+/w
@ row(),0 say replicate("Б",80) color GR/w
@ row(),0 say replicate("Б",80) color R/w
@ row(),0 say replicate("Б",80) color R+/w

@ 1,5 to 5,40 double
@ 6,7 FILL to 6,41 color N/N   && simulate drop-shadows
@ 2,41 FILL to 6,41 color N/N
@ 2,6 CLEAR TO 4,39
@ 2,7 SAY "ом мноппно мпоппноппнол оопп плп"
@ 3,7 SAY "о п номмнол  ом  оммно лоомм  л "
@ 4,7 SAY "о   но  но пмоммно  но  л ммнмлм"
@ 18,40 to 22,75 double
@ 23,42 FILL to 23,76 color N/N
@ 19,76 FILL to 23,76 color N/N
@ 19,41 CLEAR TO 21,74
@ 20,41 SAY "  Screen .MEM Э ANSI Text File  "
@ 21,41 SAY "          By Ted Roche          "
* Rem this out for .MEM file; use for .scr
@ 19,41 SAY "      Loading... Please Wait" color GR+*/B
*
set sysmenu on
return
* Return control to Command Window; save or 
* modify further from there
