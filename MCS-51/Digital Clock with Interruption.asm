;====================================================================
; Digital Clock using Interruption for MCS-51
;
; Processor: 80C51
; Compiler:  ASEM-51
;====================================================================

$NOMOD51
$INCLUDE (8051.MCU)

;====================================================================
; Código
;====================================================================

; ----------- Variáveis ------------
Milisegundos	equ	30h
Segundos	equ	31h
Minutos		equ	32h
Horas		equ	33h

; ----------- Vetores ------------
         org   0000h
	 JMP   Init
	 org   000Bh
	 JMP   Clock

; ----------- Inicializações ------------
Init:	 MOV   IE, #10000010b
	 MOV   TMOD, #01h
	 MOV   TL0, #LOW(65535 - 50000)
	 MOV   TH0, #HIGH(65535 - 50000)
	 SETB  TR0

	 MOV   Milisegundos, #20
	 MOV   Segundos, #40h
	 MOV   Minutos, #59h
	 MOV   Horas, #23h
	 	 
; ----------- Programa Principal ------------
Start:   CALL  DisplaySeg
	 CALL  DisplayMin
	 CALL  DisplayHr
	 JMP   Start
	 
; ----------- Subrotinas ------------
; Atualiza o Display dos Segundos
DisplaySeg:
	 MOV   A, Segundos
	 CALL  Convert
	 SETB  P2.5
	 MOV   P0, A
	 CALL  Delay
	 CLR   P2.5
	 MOV   A, Segundos
	 SWAP  A
	 CALL  Convert
	 SETB  P2.4
	 MOV   P0, A
	 CALL  Delay
	 CLR   P2.4
	 RET

; Atualiza o display dos Minutos	 
DisplayMin:
	 MOV   A, Minutos
	 CALL  Convert
	 SETB  P2.3
	 MOV   P0, A
	 CALL  Delay
	 CLR   P2.3
	 MOV   A, Minutos
	 SWAP  A
	 CALL  Convert
	 SETB  P2.2
	 MOV   P0, A
	 CALL  Delay
	 CLR   P2.2
	 RET

; Atualiza o display das Horas	 
DisplayHr:
	 MOV   A, Horas
	 CALL  Convert
	 SETB  P2.1
	 MOV   P0, A
	 CALL  Delay
	 CLR   P2.1
	 MOV   A, Horas
	 SWAP  A
	 CALL  Convert
	 SETB  P2.0
	 MOV   P0, A
	 CALL  Delay
	 CLR   P2.0
	 RET	 
	 
; Converte o valor do Acumulador para o Display de 7-Segmentos
Convert: ANL   A, #0Fh
	 MOV   DPTR, #Table
	 MOVC  A, @A+DPTR
	 CPL   A
	 RET
	 
; Gera um delay de alguns Microssegundos
Delay:   MOV   R7, #255
	 DJNZ  R7, $
	 RET
	 
; ----------- Tabelas ------------	 
Table:   ;      gfedcba
	 DB    00111111b ; 0
	 DB    00000110b ; 1
	 DB    01011011b ; 2
	 DB    01001111b ; 3
	 DB    01100110b ; 4
	 DB    01101101b ; 5
	 DB    01111101b ; 6
	 DB    00100111b ; 7
	 DB    01111111b ; 8
	 DB    01101111b ; 9
	 
; ----------- Interrupções ------------
; Gera 1s utilizando o Timer 0 e atualiza o Relógio
Clock:
	 PUSH  ACC
	 
	 MOV   TL0, #LOW(65535 - 50000)
	 MOV   TH0, #HIGH(65535 - 50000)
	 DJNZ  Milisegundos, Exit
	 MOV   Milisegundos, #20
	 
	 ; Atualiza os segundos
	 MOV   A, Segundos
	 ADD   A, #01
	 DA    A
	 MOV   Segundos, A
	 CJNE  A, #60h, Exit
	 MOV   Segundos, #0
	 
	 ; Atualiza os minutos
	 MOV   A, Minutos
	 ADD   A, #01
	 DA    A
	 MOV   Minutos, A
	 CJNE  A, #60h, Exit
	 MOV   Minutos, #0
	 
	 ; Atualiza as horas
	 MOV   A, Horas
	 ADD   A, #01
	 DA    A
	 MOV   Horas, A
	 CJNE  A, #24h, Exit
	 MOV   Horas, #0
	 
Exit:    POP   ACC
	 RETI
	 
;====================================================================
      END	;)