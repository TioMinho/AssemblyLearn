;====================================================================
; 2 Digit 7-Segment Counter for MCS-51
;
; Created:   s�b set 26 2015
; Processor: 80C51
; Compiler:  ASEM-51
;====================================================================

$NOMOD51
$INCLUDE (8051.MCU)

;====================================================================
; C�digo
;====================================================================
; Vari�veis
Pulso		bit	P1.0	; Referente ao Push-Button
Contador	equ	0Eh	; Referente a um endere�o qualquer da RAM de uso geral

; C�digo Propriamente Dito
         org   0000h		; Ainda n�o sei para que isso serve
      
         MOV   Contador, #00	; Iniciamos o contador do 0
         MOV   A, #00		; Movemos o mesmo valor para o Acumulador
         CALL  Convert		; Chamamos o conversor (para transformar esse 0 em bin�rio)
         MOV   P0, A		; Passamos o 0 em bin�rio para a porta P0, ligando o Display
      
Start:	 JB    Pulso, $		; Se n�o pressionar o pushbutton, pula para essa mesma linha
	 JNB   Pulso, $		; Se estiver pressionado o pushbutton, pula para essa mesma linha
	 ; Depois que segurar e soltar o push-button, o c�digo come�a...
	 MOV   A, Contador	; Move-se o valor do contador para A, pois s� o A pode realizar soma
	 ADD   A, #01		; Soma-se uma unidade ao Acumulador
	 DA    A		; Transforma-se o valor hexadecimal em BCD
	 MOV   Contador, A	; Move-se o acumulador de volta para o contador (para a pr�xima contagem)

Loop:	 ; Segundo D�gito (Unidades)
	 MOV   A, Contador	; S� por garantia... :P
	 ANL   A, #0Fh		; Faz-se um AND l�gico com cada d�gito do A, para que nunca ultrapasse 9
	 CALL  Convert		; Chama-se a subrotina de convers�o para bin�rio
	 MOV   P0, A		; Ativa-se a porta P0 com os valores da tabela referente ao n�mero em A
	 SETB  P2.1		; Ativa-se o segundo d�gito no Display de 2 D�gitos
	 CLR   P2.1		; Fecha-se o segundo d�gito no Display (para n�o aparecer n�mero repetidos)
	 
	 ; Primeiro D�gito (Dezenas)
	 MOV   A, Contador	; Traz-se o valor do contador de volta para o A
	 SWAP  A		; Troca o que � dezena por unidade e vice-versa
	 ANL   A, #0Fh		; AND l�gico para termos apenas o d�gito das unidades (agora a dezena)
	 CALL  Convert		; Transforma-se esse valor em bin�rio...
	 MOV   P0, A		; Move-se para a porta P0 esse valor
	 SETB  P2.0		; Ativa-se o primeiro d�gito no display de 2 D�gitos
	 CLR   P2.0		; Fecha0se o primeiro d�gito no Display (para n�o aparecer n�meros repetidos)
	 
	 JB    Pulso, Loop	; Faz-se essa altern�ncia unidade/dezena enquanto n�o apertarmos novamente o pushbutton
	 SJMP  Start		; Volta-se para o in�cio (Loop)
	 
; Sub-rotina de Convers�o para Bin�rio
Convert: MOV   DPTR, #Table	; Inicia-se o DPTR com o primeiro �ndice da Tabela
	 MOVC  A, @A+DPTR	; Avan�a-se na tabela exatamente o valor de A (0 - 9)
	 CPL   A		; Troca-se tudo que � 1 (l�gica positiva) por 0 (l�gica negativa)
	 RET			; Finaliza-se a subrotina
	 
; Tabela dos numerais para o Diplay de 7-Segmentos
Table:   ;      gfedcba
	 DB    00111111b ; 0
	 DB    00000110b ; 1
	 DB    01011011b ; 2
	 DB    01001111b ; 3
	 DB    01100110b ; 4
	 DB    01101101b ; 5 
	 DB    01111101b ; 6
	 DB    00000111b ; 7
	 DB    01111111b ; 8
	 DB    01101111b ; 9
       
;====================================================================
      END	; :)