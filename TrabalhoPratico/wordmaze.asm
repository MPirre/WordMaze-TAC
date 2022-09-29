;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2020/2021
;--------------------------------------------------------------
; Demostração da navegação do Ecran com um avatar
;
;		arrow keys to move 
;		press ESC to exit
;
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'


		STR12	 		DB 		"            "	; String para 12 digitos
		DDMMAAAA 		db		"                     "
		
		Horas			dw		0				; Vai guardar a HORA actual
		Minutos			dw		0				; Vai guardar os minutos actuais
		Segundos		dw		0				; Vai guardar os segundos actuais
		Old_seg			dw		0				; Guarda os últimos segundos que foram lidos
		Tempo_init		dw		99				; Guarda O Tempo de inicio do jogo
		Tempo_j			dw		99				; Guarda O Tempo que decorre o  jogo
		Tempo_limite	dw		0				; tempo de fim do jogo
		Segundos_ant	dw		?				;segundo anterior para ajudar na contagem do tempo
		Segundos_reais  dw		?				;segundo real
		Str_Segundos    db      "    "			; string para guardar os segundos do jogo
		
		String_num 		db 		"  0 $"
		Pontuacao		dw		0000
		Str_Pontucao	db      "0000 $"
        
		nivel			db		1
		palavra1	  	db	    "AGUA          $"
		palavra2	  	db	    "ISEC          $"
		palavra3	  	db	    "GARRAFAO      $"
		palavra4	  	db	    "BENFICA       $"
		palavra5	  	db	    "LINGUARUDO    $"		
		palavra_atual	db		"AGUA          $"
		
		Construir_palavra	db	    "              $"	
		
		Dim_nome		db		14		; Comprimento do Nome
		PalavraCompleta db		0		;palavra igual: valor 1. Palavra diferente: valor 0
		
		Fim_Ganhou		db	    " Ganhou $"	
		Fim_Perdeu		db	    " Perdeu $"	

        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'labi.TXT',0
		menuFich        db      'menu.TXT',0
		ajudaFich		db		'ajuda.TXT',0
        HandleFich      dw      0
        car_fich        db      ?


		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	4	; a linha pode ir de [1 .. 25]
		POSx			db	3	; POSx pode ir [1..80]	
		POSya			db	3	; Posição anterior de y
		POSxa			db	3	; Posição anterior de x
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg



;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;########################################################################
; MOSTRA - Faz o display de uma string terminada em $

MOSTRA MACRO STR 
MOV AH,09H
LEA DX,STR 
INT 21H
ENDM

; FIM DAS MACROS



;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80
		
apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			
			goto_xy 0,0
			ret
apaga_ecran	endp


;########################################################################
; IMP_FICH

IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        ;lea     dx,Fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET
		
IMP_FICH	endp		


;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC
		
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		
		mov		ah, 08h
		int		21h
		mov		ah,1

SAI_TECLA:	RET
LE_TECLA	endp

ProximoNivel proc
	pushf
	push ax
	push bx
	push cx
	push dx
	
	xor ax,ax
	;Aumenta a pontuação
	mov ax, Tempo_j
	add ax, Pontuacao
	mov Pontuacao,ax
	
	;Reset ao tempo de jogo
	mov ax,Tempo_init
	mov Tempo_j,ax


	
	;limpar a palavra a construir
	mov ah, 32
	mov cl,Dim_nome
	xor si,si
loop_reset_pal:
	mov Construir_palavra[si],ah
	inc si
	loop loop_reset_pal

				
	xor ax,ax
	mov ah,nivel
	inc ah				;passa ao proximo nivel
	mov nivel,ah
	
	cmp ah,2
	jne	copiarpal3
	
copiarpal2:						
	xor si,si
	mov cl, Dim_nome
loopcopiar2:
	mov bl,palavra2[si]
	mov palavra_atual[si],bl	
	inc si
	loop loopcopiar2
	jmp fim_copiar_palavra	
	
copiarpal3:		
	cmp ah,3
	jne	copiarpal4			
			
	xor si,si
	mov cl, Dim_nome
loopcopiar3:
	mov bl,palavra3[si]
	mov palavra_atual[si],bl	
	inc si
	loop loopcopiar3
	jmp fim_copiar_palavra	
	
	
copiarpal4:		

	cmp ah,4
	jne	copiarpal5
	
	xor si,si
	mov cl, Dim_nome
loopcopiar4:
	mov bl,palavra4[si]
	mov palavra_atual[si],bl	
	inc si
	loop loopcopiar4
	jmp fim_copiar_palavra
	
	
copiarpal5:						
	xor si,si
	mov cl, Dim_nome
loopcopiar5:
	mov bl,palavra5[si]
	mov palavra_atual[si],bl	
	inc si
	loop loopcopiar5

	
fim_copiar_palavra:
	mov bh,0
	mov PalavraCompleta,bh

	pop dx
	pop cx
	pop bx
	pop ax
	popf

	ret
ProximoNivel endp
;##################################
;Imprime a palavra que é para completar no ecrã

IMPRIME_PALAVRA proc
	goto_xy 10,20
	MOSTRA palavra_atual

	ret
IMPRIME_PALAVRA endp

;##################################
;Imprime o nivel do jogo no ecrã
IMPRIME_NIVEL proc
	goto_xy 8,0
	
	mov     dl,nivel
	add 	dl,48
	mov     ah,02h
	int     21h

	ret
IMPRIME_NIVEL endp
;#########################################3
;Função auxiliar para o temporizador
;Lê os segundos reais e guarda-os

Ler_SEGUNDOS proc	 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSHF
		
		MOV AH, 2CH             	; Buscar a tempo atual real
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              	; segundos para al
		mov Segundos_reais, AX		; guarda segundos na variavel correspondente
	
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_SEGUNDOS   endp
;#####################################################
;Função que verifica sempre que passa um segundo e decrementa o tempo de jogo
TEMPORIZADOR proc
		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX	

		CALL 	Ler_SEGUNDOS				; Lê segundos do sistema
		
		MOV		AX, Segundos_reais
		cmp		AX, Segundos_ant			; VErifica se os segundos mudaram desde a ultima leitura
		je		fim_temporizador			; Se a hora não mudou desde a última leitura sai.
		mov		Segundos_ant, AX			; Se segundos são diferentes actualiza informação do tempo 
		mov ax, Tempo_j
		dec ax								;Diminui o tempo de jogo 1 segundo
		mov Tempo_j, ax						;guarda denovo o tempo decrementado
		
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h						; Caracter Correspondente às dezenas
		add		ah,	30h						; Caracter Correspondente às unidades
		MOV 	Str_Segundos[0],al			; 
		MOV 	Str_Segundos[1],ah
		MOV 	Str_Segundos[2],'$'
		
		goto_xy 55,0
		MOSTRA Str_Segundos

fim_temporizador:
		
		POP DX		
		POP CX
		POP BX
		POP AX
		POPF
		ret
TEMPORIZADOR endp

;#####################################################3
;Verificar se carater pertence à palavra

VERIFICA_CARATER proc
		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX	

		xor si,si
		mov ah,Car				;move carater do cursor 
		mov cl, Dim_nome
loop_verifica_car:
		mov bl, palavra_atual[si]
		cmp bl,ah
		jne caracter_diferente
		mov Construir_palavra[si],ah
		
caracter_diferente:		
		inc si
		loop loop_verifica_car

		goto_xy 10,21
		MOSTRA Construir_palavra

		
		POP DX		
		POP CX
		POP BX
		POP AX
		POPF
		ret
VERIFICA_CARATER endp

;######################################
;Verificar palavra completa

VERIFICA_PALAVRA proc
		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX	
		
		xor si,si
		mov cl,Dim_nome
loop_palavra:
		mov al,palavra_atual[si]
		mov ah,Construir_palavra[si]
		cmp al,ah
		jne palavras_diferentes
		inc si
		loop loop_palavra
		
		mov bl,1
		mov PalavraCompleta,bl
		
		
		jmp fim_verifica_palavras
		
palavras_diferentes:
		mov bl,0
		mov PalavraCompleta, bl
fim_verifica_palavras:
		
		POP DX		
		POP CX
		POP BX
		POP AX
		POPF
		ret
VERIFICA_PALAVRA endp

;##########################################
;Função que imprime a pontuação
IMPRIME_PONTUACAO proc
		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX	
		
		xor ax,ax
		xor bx,bx
		mov 	ax, Pontuacao
		MOV 	bl, 10     
		div 	bl
		add		ah,	30h						; Caracter Correspondente às unidades			 
		MOV 	Str_Pontucao[4],ah	
		mov 	ah,0
		div 	bl	
		add 	al, 30h		
		add 	ah, 30h
		MOV 	Str_Pontucao[3],ah
		mov     Str_Pontucao[2],al

	 
	
		
		goto_xy 51,20
		MOSTRA Str_Pontucao
		
		POP DX		
		POP CX
		POP BX
		POP AX
		POPF
		ret
IMPRIME_PONTUACAO endp

;########################################################################
; Avatar

AVATAR	PROC
			push ax
			xor ax,ax
			mov ax,Tempo_init		;dá reset ao tempo quando inicia o jogo
			mov Tempo_j,ax
			pop ax
			
			
			mov		ax,0B800h
			mov		es,ax

			mov 	ah, 08h			; Guarda o Caracter que está na posição do Cursor
			goto_xy	POSx,POSy		; Vai para nova possição

			mov		bh,0			; numero da página
			int		10h			
			mov		Car, al			; Guarda o Caracter que está na posição do Cursor
			mov		Cor, ah			; Guarda a cor que está na posição do Cursor	
	



CICLO:		
			
			push ax
			mov al,PalavraCompleta
			cmp al,1					;verifica fim do nivel
			jne NAO_AVANCA_NIVEL
			call ProximoNivel
NAO_AVANCA_NIVEL:
			pop ax
			
			call 	IMPRIME_NIVEL
			call	IMPRIME_PALAVRA
			call 	VERIFICA_CARATER
			call    VERIFICA_PALAVRA
			call    IMPRIME_PONTUACAO
			
			push ax
			mov ax,Tempo_j			;verifica se o tempo já acabou e termina o jogo
			cmp ax,0
			je fim
			pop ax
			
			goto_xy	POSxa,POSya		; Vai para a posição anterior do cursor
			mov		ah, 02h
			mov		dl, Car			; Repoe Caracter guardado 
			int		21H		
			
			goto_xy	POSx,POSy		; Vai para nova possição
			mov 	ah, 08h
			mov		bh,0			; numero da página
			int		10h		
			mov		Car, al			; Guarda o Caracter que está na posição do Cursor
			mov		Cor, ah			; Guarda a cor que está na posição do Cursor
		
			goto_xy	78,0			; Mostra o caractr que estava na posição do AVATAR
			mov		ah, 02h			; IMPRIME caracter da posição no canto
			mov		dl, Car	
			int		21H			
	
			goto_xy	POSx,POSy		; Vai para posição do cursor
IMPRIME:	mov		ah, 02h
			mov		dl, 190			; Coloca AVATAR
			int		21H	
			goto_xy	POSx,POSy		; Vai para posição do cursor
		
			mov		al, POSx		; Guarda a posição do cursor
			mov		POSxa, al
			mov		al, POSy		; Guarda a posição do cursor
			mov 	POSya, al
		
LER_SETA:	
			call TEMPORIZADOR
			call 	LE_TECLA
			
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27	; ESCAPE
			JE		FIM
			jmp		LER_SETA
		
ESTEND:		cmp 	al,48h
			jne		BAIXO
			dec		POSy		;cima
			jmp		CICLO

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			inc 	POSy		;Baixo
			jmp		CICLO

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			dec		POSx		;Esquerda
			jmp		CICLO

DIREITA:
			cmp		al,4Dh
			jne		LER_SETA 
			inc		POSx		;Direita
			jmp		CICLO

fim:			
			
			call NOVO_JOGO		;repõe o nivel e a palavra 1
			
			
			
			RET
AVATAR		endp

NOVO_JOGO proc

			PUSHF
			PUSH AX
			PUSH BX
			PUSH CX
			PUSH DX	
			
			mov al,1
			mov nivel,al		;Recolocar nivel a 1 e a palavra 1 
						
			xor si,si
			mov cl, Dim_nome
loopcopiar1:
			mov bl,palavra1[si]
			mov palavra_atual[si],bl		;coloca a palavra1 na palavra_atual
			inc si
			loop loopcopiar1
				
			POPF
			POP DX		
			POP CX
			POP BX
			POP AX


		ret
NOVO_JOGO endp




;########################################################################
Main  proc
		mov			ax, dseg
		mov			ds,ax
		
		mov			ax,0B800h
		mov			es,ax
		
menu_inicial:

		call		apaga_ecran
		lea    		dx,menuFich				;Abre o Menu
		call		IMP_FICH
		
		call 		LE_TECLA
		cmp 		al, 49					;tecla 1
		je			inicia_jogo
		cmp			al,50					;tecla 2
		;je			personalizar
		cmp			al,51					;tecla 3
		;je			top10
		cmp 		al,52					;tecla 4
		je			ajuda_menu
		cmp 		al,27					;tecla ESC
		je			fim_programa
		

ajuda_menu:		
		call		apaga_ecran
		lea    	dx,ajudaFich		;Abre a ajuda
		call		IMP_FICH
		
		call 		LE_TECLA
		cmp 		al,27
		je			menu_inicial

inicia_jogo:		
		call		apaga_ecran
		lea     	dx,Fich
									;Inicia o jogo
		
		call		IMP_FICH	
		call 		AVATAR
		
		jmp			menu_inicial		
fim_programa:
		call		apaga_ecran		;Fim do programa
		goto_xy		0,22
		
		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main


		
