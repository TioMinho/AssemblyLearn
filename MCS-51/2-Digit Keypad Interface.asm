;====================================================================
; 2 Digit Keypad Interface for MCS-51
;
; Created:   sáb set 26 2015
; Processor: 80C51
; Compiler:  ASEM-51
;====================================================================

;====================================================================
; Código
;====================================================================

; Variáveis
SearchOK	bit	20h.0	; Indica quando o teclado for pressionado
isToggle	bit	20h.1	; Faz a mudança Dezena-Unidade e Unidade-Dezena do Display

; Variáveis dos Dígitos do Display
FirstDigit	bit     P2.1	
SecondDigit	bit     P2.0

Counter		equ	0Eh
Unidade		equ	0Fh
Dezena		equ	10h

;-----------------------------
; Inicializações:
	 MOV    Unidade, #0C0h
	 MOV    Dezena, #0C0h
	 CLR	isToggle

;-----------------------------

;------------------------------
;------------Display-----------
;------------------------------

Start:	 CALL   Read_Key
	 CALL   Display		; Mesmo se não tiver pressionado o teclado, ele ainda atualiza o display
	 JNB    SearchOK, Start
	 MOV    A, B
	 CALL   Convert
	
         ; Se o "isToggle" for verdadeiro, a gente muda a "Dezena"
	 JB	isToggle, DoToggle	
	 MOV    Dezena, A
	 SETB	isToggle
	 SJMP   Start

	; Se o "isToggle" for falso, a gente muda a "Unidade"
DoToggle:
	 MOV    Unidade, A
	 CLR    isToggle
	 
	 SJMP   Start
;-----------------------------

Display: SETB	FirstDigit
	 MOV	P0, Unidade
	 CALL   Delay
	 CLR	FirstDigit

	 SETB	SecondDigit
	 MOV	P0, Dezena
	 CALL   Delay
	 CLR	SecondDigit

	 RET
;-----------------------------

Delay:	 MOV	R7, #255
	 DJNZ   R7, $
	 RET
;-----------------------------

Convert: ANL	A, #0Fh
	 MOV	DPTR, #Table
	 MOVC   A, @A+DPTR
	 CPL    A
	 RET
;-----------------------------
Table:	 ;     gfedcba
	 DB   00111111b	; 0
	 DB   00000110b	; 1
	 DB   01011011b	; 2
	 DB   01001111b	; 3
	 DB   01100110b	; 4
	 DB   01101101b	; 5
	 DB   01111101b	; 6
	 DB   00100111b	; 7
	 DB   01111111b	; 8
	 DB   01101111b	; 9
	 DB   01110111b	; A
	 DB   01111100b	; b
	 DB   00111001b	; C
	 DB   01011110b	; d
	 DB   01111001b	; E
	 DB   01110001b	; F

;------------------------------
;------------TECLADO-----------
;------------------------------
Read_Key:  CLR	 SearchOK
	   MOV   P1, #0FEh
	   MOV   A, P1
	   CJNE  A, #0FEh, Trigger
	   MOV   P1, #0FDh
	   MOV   A, P1
	   CJNE  A, #0FDh, Trigger
	   MOV   P1, #0FBh
	   MOV   A, P1
	   CJNE  A, #0FBh, Trigger
	   MOV   P1, #0F7h
	   MOV   A, P1
	   CJNE  A, #0F7h, Trigger
	   RET
;------------------------------

Trigger:   MOV   B, A
	   MOV   Counter, #0
	   MOV   DPTR, #CodeKey
	   
SearchCode:
	   CLR   A
	   MOVC  A, @A+DPTR
	   JZ    Out
	   CJNE  A, B, Next
SearchKey: MOV   DPTR, #KeyString
	   MOV   A, Counter
	   MOVC  A, @A+DPTR
	   SETB  SearchOK
	   MOV   B, A
	   CALL  ReleaseKey
Out:	   RET
;-------------------------------

Next:	   INC   DPTR
	   INC   Counter
	   SJMP  SearchCode
;-------------------------------

ReleaseKey:
	   MOV   P1, #0F0h
Wait:	   MOV	 A, P1
	   CJNE  A, #0F0h, Wait
	   RET
;-------------------------------

CodeKey:   DB	 0EEh, 0DEh, 0BEh, 7Eh
	   DB	 0EDh, 0DDh, 0BDh, 7Dh
	   DB	 0EBh, 0DBh, 0BBh, 7Bh
	   DB	 0E7h, 0D7h, 0B7h, 77h, 0

KeyString: DB	 '7', '8', '9', ':'
	   DB	 '4', '5', '6', ';'
	   DB	 '1', '2', '3', '<'
	   DB	 '?', '0', '>', '='	   
	   
;====================================================================
      END	;)