;====================================================================
; Project: DC Motor Speed Control using PWM Modularization and
;	   Serial Communication.
;
; Authors: Otacílio Bezerra Leite Neto
;	   Felipe Matheus Paiva Carneiro Bede
; 
;====================================================================

$NOMOD51
$INCLUDE (8051.MCU)

;====================================================================
; Variáveis
;====================================================================
; Variávies para controle do PWM ------------------------------------
PWM_Pin		bit	P2.7
PWM_Flag	bit	20h.0

; Variáveis para manipular o DutyCycle do PWM -----------------------
OnHigh		equ	30h	; 8bits + 8bits = 16 bits
OnLow		equ	31h	; Período de sinal alto

OffHigh		equ	32h	; 8bits + 8bits = 16bits
OffLow		equ	33h	; Período de sinal baixo

;====================================================================
; Vetores
;====================================================================

	    ; Vetor para o Programa Principal
            org   0000h
	    SJMP  Init
	    ; Vetor para a Interrupção do T/C0
	    org   000Bh
	    JMP	  Timer

;====================================================================
; Código-Principal
;====================================================================	   
; Inicializações ----------------------------------------------------
Init:	    ; Inicialização do Modo de Funcionamento dos T/C
	    ; Time1 : Modo 2 (8 bits com recarga) / Timer0 : Modo 1 (16 bits) 
	    MOV   TMOD, #21h	; TMOD = 0010/0001
	    MOV 0A6h,#00h
	    MOV 0A2h,#00h
	    MOV 08Eh,#00011001b
	    MOV P2,#00h
	    ; Inicialização  da Pilha
	    MOV   SP, #(255-20)
	    MOV   OnHigh, #HIGH(65535 - 00000)
	    MOV   OnLow, #LOW(65535 -  00000)
	    MOV   OffHigh, #HIGH(65535 - 00000)
	    MOV   OffLow, #LOW(65535 -  00000)
	    
	    ; Inicialização do Modo da Interface Serial
	    MOV   SCON,#01010000b	; * Modo de 9bits programável
            MOV   TH1, #253		; * Valor de Baud Rate de
            MOV   TL1, #253		;   9600 baud 
	    ANL   PCON,#01111111b	; * Desligando o SMOD
	    
	    ; Inicialização dos Bits de Interrupção
	    MOV   IE, #10000010b	; Uso da Interrupção do T/C0
	    
	    ; Início da Contagem dos dois T/C
	    SETB  TR1
	    SETB  TR0 
	    
	    ; Imprime o Menu na Console
	    MOV   DPTR,#Menu
	    CALL  Text_Out
	    
; Programa Principal ------------------------------------------------
Start:     
	    CALL  Receive_Byte
	    CALL  Att_Display
            CJNE  A, #'0', ESP_1
            MOV   OnHigh, #HIGH(65535 - 0000)
	    MOV   OnLow, #LOW(65535 -  0000)
	    MOV   OffHigh, #HIGH(65535 - 10000)
	    MOV   OffLow, #LOW(65535 -  10000)
	    SJMP  Start
ESP_1:	    
            CJNE  A, #'1', ESP_2
            MOV   OnHigh, #HIGH(65535 - 1000)
	    MOV   OnLow, #LOW(65535 -  1000)
	    MOV   OffHigh, #HIGH(65535 - 9000)
	    MOV   OffLow, #LOW(65535 -  9000)
	    SJMP  Start
ESP_2:		
            CJNE  A, #'2', ESP_3
            MOV   OnHigh, #HIGH(65535 - 2000)
	    MOV   OnLow, #LOW(65535 -  2000)
	    MOV   OffHigh, #HIGH(65535 - 8000)
	    MOV   OffLow, #LOW(65535 -  8000)
            SJMP  Start
ESP_3:
            CJNE  A, #'3', ESP_4
            MOV   OnHigh, #HIGH(65535 - 3000)
	    MOV   OnLow, #LOW(65535 -  3000)
	    MOV   OffHigh, #HIGH(65535 - 7000)
	    MOV   OffLow, #LOW(65535 -  7000)
            SJMP  Start
ESP_4:
            CJNE  A, #'4', ESP_5
            MOV   OnHigh, #HIGH(65535 - 4000)
	    MOV   OnLow, #LOW(65535 -  4000)
	    MOV   OffHigh, #HIGH(65535 - 6000)
	    MOV   OffLow, #LOW(65535 -  6000)
            SJMP  Start
ESP_5:
	    
            CJNE  A, #'5', ESP_6
            MOV   OnHigh, #HIGH(65535 - 5000)
	    MOV   OnLow, #LOW(65535 -  5000)
	    MOV   OffHigh, #HIGH(65535 - 5000)
	    MOV   OffLow, #LOW(65535 -  5000)
            SJMP  Start
ESP_6:
	   
            CJNE  A, #'6', ESP_7
            MOV   OnHigh, #HIGH(65535 - 6000)
	    MOV   OnLow, #LOW(65535 -  6000)
	    MOV   OffHigh, #HIGH(65535 - 4000)
	    MOV   OffLow, #LOW(65535 -  4000)
            LJMP  Start
ESP_7:
	   
            CJNE  A, #'7', ESP_8
            MOV   OnHigh, #HIGH(65535 - 7000)
	    MOV   OnLow, #LOW(65535 -  7000)
	    MOV   OffHigh, #HIGH(65535 - 3000)
	    MOV   OffLow, #LOW(65535 -  3000)
            JMP  Start
ESP_8:
            CJNE A, #'8', ESP_9
            MOV   OnHigh, #HIGH(65535 - 8000)
	    MOV   OnLow, #LOW(65535 -  8000)
	    MOV   OffHigh, #HIGH(65535 - 2000)
	    MOV   OffLow, #LOW(65535 -  2000)
            JMP Start
ESP_9:
            CJNE A, #'9', ESP_M
            MOV   OnHigh, #HIGH(65535 - 9000)
	    MOV   OnLow, #LOW(65535 -  9000)
	    MOV   OffHigh, #HIGH(65535 - 1000)
	    MOV   OffLow, #LOW(65535 -  1000)
            JMP Start
ESP_M:
            CJNE  A, #'m', Voltar
            MOV   OnHigh, #HIGH(65535 - 10000)
	    MOV   OnLow, #LOW(65535 -  10000)
	    MOV   OffHigh, #HIGH(65535 - 0000)
	    MOV   OffLow, #LOW(65535 -  0000)
Voltar:     JMP Start

;====================================================================
; Sub-rotinas
;====================================================================
; Sub-rotinas de Manipulação Serial ---------------------------------
Receive_Byte:	   
	    JNB	 RI,$
	    CLR  RI
            MOV  A, SBUF
	    RET

Send_Byte: 
            MOV  SBUF, B
	    JNB	 TI, $
            CLR  TI
            RET	    
	    
Text_Out:
            CLR  A
            MOVC A, @A+DPTR
            JZ   Exit
            MOV  B, A
            CALL Send_Byte
            INC  DPTR 
            SJMP Text_Out   
Exit:       RET	    
	    
; Sub-rotinas de Display de 7 Segmentos ------------------------------
Att_Display:
	    PUSH  ACC
	    CALL  Convert
	    MOV   P0, A
	    POP   ACC
	    RET

Convert:    ANL	  A, #0Fh
	    MOV	  DPTR, #Table
	    MOVC  A, @A+DPTR
	    CPL   A
	    RET   

;====================================================================
; Tabelas
;====================================================================
; Tabela de Conversão BCD para Display de 7-Segmentos ---------------
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
   
Menu:       
			DB   0DH,0AH, 'ENTRE A VELOCIDADE DESEJADA:'
            DB   0DH,0AH,'1 - 10%'
            DB   0DH,0AH,'2 - 20%'
            DB   0DH,0AH,'3 - 30%'
            DB   0DH,0AH,'4 - 40%'
            DB   0DH,0AH,'5 - 50%'
            DB   0DH,0AH,'6 - 60%'
            DB   0DH,0AH,'7 - 70%'
            DB   0DH,0AH,'8 - 80%'
            DB   0DH,0AH,'9 - 90%'
            DB   0DH,0AH,'M - 100%',0
Timer:
	    JB    PWM_Flag, EndHigh
	    
EndLow:	    SETB  PWM_Flag
	    SETB  PWM_Pin
	    MOV   TH0, OnHigh
	    MOV   TL0, OnLow
	    RETI
	    
EndHigh:    CLR   PWM_Flag
	    CLR   PWM_Pin
	    MOV   TH0, OffHigh
	    MOV   TL0, OffLow
	    RETI	    

;====================================================================
      END