;=================================AREA GRAFICA=======================================================
PintarBloques macro filas 		;reccibira como parametro las filas, esto dependera de cada nivel 
	LOCAL anchoBloque,Bloque,Fin,sumo,sigo
	
	mov dl,14 	;color de los bloques
	xor di,di 	;inicio de bloques
	xor cx,cx	;ancho de bloque
	xor si,si 	;cantidad de bloques realizados
	xor bx,bx	;cantidad de filas realizadas
	mov bx,filas
	xor ax,ax 	;numero de filas realizadas

	;margen empieza en la fila 20, loa bloques empezaran en la linea 25 y columna 50
	mov di,8050 ;(25*320)+50 = 8050 inicio de los bloques

	anchoBloque:
		mov cx,40 	;ancho del bloque
	Bloque:
		mov es:[di],dl ;color de los cubos
		mov es:[di+320],dl
		mov es:[di+640],dl
		mov es:[di+960],dl
		mov es:[di+1280],dl
		inc di 	;pintara de ancho de 3 filas cada bloque
		loop Bloque

	;cuando termine de dibujar un bloque verifico si a esa fila le caben mas bloques
	inc si
	add di,0ah 	;una separacion de 10 pixeles horizontalmente	 	
	cmp si,05h	;si ya complete los 5 bloques por fila paso a la siguiente filaa
	jne anchoBloque

	inc ax 			;incremento las filas realizadas
	cmp bx,1
	je Fin  		;comparo si es la ultima linea de lo contrario mando a hacer otra linea
	dec bx
	mov di,8050		;regreso a la posicion inicial y debo bajar: el tamaño del bloque = 5 mas 10 filas de separacion

	push ax 	;guardo la cantidad de filas que llevo
	;AJUSTO LA NUEVA POSICION EN LA LINEA DE ABAJO
	sumo:
		;sumo 4800 por cada linea que llevo
		cmp ax,0
		je sigo
		add di,4800 	;le sumo las 5 filas ocupadas por el bloque anterior mas 10 FILAS de esapacio vertical
		dec ax
		jmp sumo

	sigo:
		pop ax 	;retomo el valor de lineas que llevo
		xor si,si
		jmp anchoBloque 	;inicio a dibujar la nueva fila

	Fin:
endm

PintarMargen macro color
	local Primera,Segunda,Tercera,Cuarta
	mov dl, color

	;empieza en pixel (i,j) = (20,0) = 20*320+0 = 6400
	;barra horizontal superior
	mov di,6405
	Primera:
	mov es:[di],dl
	inc di
	cmp di,6714
	jne Primera

	;barra horizontal inferior
	;empieza en pixel (i,j) = (190,0) = 190 * 320 + 0 = 60800
	mov di,60805
	Segunda:
	mov es:[di],dl
	inc di
	cmp di, 61114
	jne Segunda

	;barra vertical izquierda
	mov di, 6405
	Tercera:
	mov es:[di], dl
	add di,320
	cmp di,60805
	jne Tercera

	;barra vertical derecha
	mov di,6714
	Cuarta:
	mov es:[di], dl
	add di,320
	cmp di,61114
	jne Cuarta
endm

PintarBarra macro
	
	LOCAL Largo
	push dx
	;push di
	mov dl,11
	;empieza en pixel (i,j) = (186,130) = 187*320+130=59650
	mov di,InicioPosActualBarra
	mov FinBarra,0
	mov FinBarra,di
	add FinBarra,50

	Largo:
	mov es:[di],dl
	mov es:[di+320],dl
	inc di
	cmp di,FinBarra	;daremos un ancho de 50 pixeles
	jne Largo
	;pop di
	pop dx
endm

borrarBarra macro

	LOCAL Largo
	push dx
	;push di
	mov dl,0
	;empieza en pixel (i,j) = (187,130) = 187*320+130=59970
	mov di,InicioPosActualBarra
	mov FinBarra,di
	add FinBarra,50

	Largo:
	mov es:[di],dl
	mov es:[di+320],dl
	inc di
	cmp di,FinBarra	;daremos un ancho de 50 pixeles
	jne Largo
	;pop di
	pop dx
endm

pintarPelota macro pos, color
	push dx
	mov di,pos
	mov dl,color

	mov es:[di],dl
	mov es:[di+1], dl
	mov es:[di+2], dl

	mov es:[di+320], dl
	mov es:[di+321], dl
	mov es:[di+322], dl

	mov es:[di+640], dl
	mov es:[di+641], dl
	mov es:[di+642], dl

	pop dx
endm

MostrarEncabezado macro
	LOCAL Seguir,Otro,SaltoLineaar,SaltoLineaar2,pri,noes,niv1,niv2,imprimir

	ImpresionCaracter 32 	;imprimimos un espacio
	printGrafico name_ 		;nombre de usuario actual

	ImpresionCaracter 32 ;imprimimos un espacio
 	ImpresionCaracter 32 ;imprimimos un espacio

	ImpresionCaracter 78 ;letra N de Nivel
	push ax
	xor ax,ax
	mov ax,NivelActual
	add ax,30h
	ImpresionCaracter al ;numero de nivel
	pop ax

	ImpresionCaracter 32 ;imprimimos un espacio
	ImpresionCaracter 32 ;imprimimos un espacio
	
	ConvertirBCD punetoActual

	;ImpresionCaracter centena
	ImpresionCaracter decena
	ImpresionCaracter unidad
	
	ImpresionCaracter 32 ;imprimimos un espacio
	ImpresionCaracter 32 ;imprimimos un espacio

	;tiempo----
	;capturo el tiempo actual
	push ax
	push cx
	push bx
	push dx

	mov ah,2ch
	int 21h

	mov segundosActual,dh  ;dh =segundos
	mov minutosActual,cl 	;cl=minutos
	xor ax,ax
	xor bx,bx
	mov al,minutosActual
	mov bx,60
	mul bx
	xor bx,bx
	mov bl,segundosActual
	add ax,bx
	sub ax,segundostotalesInicio 	;resto el tiempo en el que inicie asi encuantro la diferencia de segundos 
	mov tiempoTotalSegundos,ax
	mov timepoParaRegistro,ax 	;voy guardando en el registro el tiempo acumulado

	ConvertirBCD tiempoTotalSegundos
	ImpresionCaracter centena
	ImpresionCaracter decena
	ImpresionCaracter unidad

	ImpresionCaracter 13 	;retorno de carro para que siempre me escriba en la misma linea
	pop dx
	pop bx
	pop cx
	pop ax
endm

parsear macro resultado, cadena
        LOCAL DIVISION, FIN
        push cx 
        push dx
        push ax
        push si

        xor si,si
        xor cx,cx
        xor ax,ax
        xor dx,dx

        mov ax,resultado        ; pasar a ax el valor que se quiere dividir
        mov dl,0Ah              ; pasar a dl el valor que quiero diviri
        jmp DIVISION
        DIVISION:
            div dl
            inc cx              ; Para saber cuantos digitos son
            push ax             ; guardar el residuo
            cmp al,00h          ;si ya dio 0 en el cociente dejar de dividir
            je FIN
            xor ah,ah           ; limpiar el residuo
            jmp DIVISION
        FIN:
            pop ax
            add ah,30h
            mov dl,ah
            ;ImpresionCaracter dl
            mov cadena[si],ah
            ;ImpresionCaracter ah
            inc si
            loop FIN 

            mov ah,24h ;ascii del $
			mov cadena[si],ah

        pop si  
        pop ax
        pop dx 
        pop cx
endm

ConvertirBCD macro numero
	LOCAL REALIZAR,HEXA_DECIMAL,BCDCOMPLETO
	push di
	push ax
	push dx
	push cx

	mov ax,numero
	REALIZAR:
		xor dx,dx
		; ImpresionCaracter al
		; mov bl,ah
		; ImpresionCaracter bl
		; ;leercaracter

		;limpio las variables
		 mov centena,0
		 mov decena,0
		 mov unidad,0

		 xor cx,cx
		 mov cx,0ah
		 HEXA_DECIMAL:

			div cx  ;RESIDUO DX Y COCIENTE EN AX
			mov unidad,dl

			cmp ax,00h
			je BCDCOMPLETO

			xor dx,dx

			div cx  ;RESIDUO DX Y COCIENTE EN AX
			mov decena,dl

			cmp ax,00h
			je BCDCOMPLETO

			xor dx,dx

			div cx  ;RESIDUO DX Y COCIENTE EN AX
			mov centena,dl

			cmp ax,00h
			je BCDCOMPLETO

			xor dx,dx

			BCDCOMPLETO:
				 add centena,30h  	;le sumamos 30h para mostrar ek numero real en pantalla 
				 add decena,30h
				 add unidad,30h

				 pop cx
				 pop dx
				 pop ax
				 pop di
endm

;===================SECCION DE IMPRESION EN MODO GRAFICO=================
printGrafico macro cadena
	push ds 	;ahora debo guardar es
	mov ah,09h
	mov dx,@data
	mov ds,dx
	mov dx, offset cadena
	int 21h
	pop ds
endm

ImpresionCaracter macro caracter
	push dx
	push ax
	mov ah,02h
	mov dl,caracter
	int 21h
	pop ax
	pop dx
endm

;==========================FIN AREA GRAFICA=======================================================

;=========================GESTION DE ARCHIVOS=============================================
tamnaotexto macro buffer,numerocaracteres
	
	LOCAL Repetir,dolar
	push cx
	xor si,si
	mov cx,numerocaracteres
	Repetir:
		cmp buffer[si],36
		je dolar
		inc si
		Loop Repetir
	dolar:
	pop cx
endm

Abrir macro buffer,handler 
	mov ah,3dh
	mov al,02h
	lea dx,buffer
	int 21h
	jc Error1
	mov handler,ax
endm 

Cerrar macro handler
	mov ah,3eh
	mov bx,handler
	int 21h
	jc Error2
endm

Leer macro handler,buffer,numeroBytes
	mov ah,3fh
	mov bx,handler
	mov cx,numeroBytes
	lea dx,buffer
	int 21h
	jc Error3
endm

Crear macro buffer,handler
	mov ah,3ch
	mov cx,00h
	lea dx,buffer
	int 21h
	jc Error4
	mov handler,ax
endm

Escribir macro handle , numBytes ,buffer
	push cx
	mov ah,40h
	mov bx,handle
	mov cx,numBytes
	lea dx,buffer
	int 21h
	pop cx
	jc Error5
endm
;=============================================================================================

ModoVideo macro
	mov ah,00h
	mov al,13h
	int 10h
	mov ax, 0A000h
	mov es, ax  ; ES = A000h (memoria de graficos).
endm

ModoTexto macro
	mov ah,00h
	mov al,03h
	int 10h
endm

getTexto macro buffer
	LOCAL INICIO,FIN
		push si
		push ax
		xor si,si
	INICIO:
		leercaracter
		cmp al,0dh
		je FIN
		mov buffer[si],al
		inc si
		jmp INICIO
	FIN:
		mov buffer[si],'$'
		pop ax
		pop si
endm

leercaracter macro
	mov ah,01h
	int 21h
	;guarda resultado en al
endm

Limpiar macro buffer, numBytes, caracter
	LOCAL Repetir
	push di
	push cx
	xor di,di
	xor cx,cx
	mov cx,numBytes
	Repetir:
	mov buffer[di],caracter
	inc di
	Loop Repetir
	xor di,di
	xor cx,cx
	pop cx
	pop di
endm

getChar macro
	mov ah,0dh
	int 21h
	mov ah,01h
	int 21h
endm

print macro cadena
	push ax
	push dx
	mov ax,@data
	mov ds,ax
	mov ah,09
	mov dx,offset cadena
	int 21h
	pop dx
	pop ax
endm

BuscarUsuario macro buffer,name,pass

	Limpiar name_reg,SIZEOF name_reg,024h
	Limpiar pass_reg,SIZEOF pass_reg,024h
	xor si,si
	xor di,di

	Buscando:
		cmp buffer[si],36
		je fincadena

		cmp buffer[si],44
		je verificarNombre_

		mov al,buffer[si]
		mov name_reg[di],al 	;copiamos del buffer de usuarios a la cadena a comparar
		inc di
		inc si
		jmp Buscando

		verificarNombre_:
			xor bx,bx
		verificarNombre:
			;actualmente el indice si esta en la coma
			cmp name_reg[bx],36
			je NombreCorrecto

			mov al,name_reg[bx]
			cmp name[bx],al
			jne Diferentes
			inc bx 
			jmp verificarNombre

			NombreCorrecto:
				inc si 	;como estabamos en la coma aumnetamos 1
				xor di,di
				CapturandoPass:
					cmp buffer[si],36
					je fincadena

					cmp buffer[si],10 	;si viene SaltoLineao de linea es que se acabo la password
					je verificarPassword_

					mov al,buffer[si]
					mov pass_reg[di],al 	;copiamos del buffer de usuarios a la cadena a comparar
					inc di
					inc si
					jmp CapturandoPass

					verificarPassword_:
						xor bx,bx
					verificarPassword:
						cmp pass_reg[bx],36
						je passCorrecta

						mov al,pass_reg[bx]
						cmp password[bx],al
						jne Diferentes
						inc bx 
						jmp verificarPassword


						passCorrecta:
							mov login,1
							jmp fincadena

			Diferentes:		;si es diferente SaltoLineaamos hasta el siguiente usuario
				;si son diferentes pasamos al siguientre usuario
				cmp buffer[si],10
				je SigUser

				inc si 
				jmp Diferentes

				SigUser:
					Limpiar name_reg,SIZEOF name_reg,024h
					Limpiar pass_reg,SIZEOF pass_reg,024h
					xor di,di
					xor bx,bx
					inc si
					jmp Buscando

		fincadena:
			cmp login,0
			je errorLogin
			jmp correcto

			errorLogin:
				print LoginError
				leercaracter
				jmp MenuPrincipal

			correcto:	;regresa ala ejecucion del juego
				mov login,0

				;verifico si es administrador o usuario normal
					xor si,si
					ADMINN:
						cmp name[si],36
						je finSIES

						mov al,name[si]
						cmp admin[si],al
						jne NOesadmin

						inc si
						jmp ADMINN

						finSIES:
							mov esAdmin,1
							jmp regreso

						NOesadmin:
							mov esAdmin,0
							jmp regreso

							regreso:
endm

;================================JUEGO=========================
leertecla macro 
	LOCAL pausa,off,VerificarTecla,Derecha,Izquierda,Nosepuede,Nosepuede1,pausa,Nivel2_,Nivel3_,estoyNiv3D,estoyNiv3I,yes,rep,rep1
	push ax
	;xor ax,ax
	mov ah,01h
	int 16h ;verificar si hay tecla lista para ser leida
	jz off
	mov ah,00h
	int 16h ;leer la tecla

	cmp ah,1 ;si es el boton ESC
	jne VerificarTecla

	pausa:
		mov ah,00h 	;haccemos que espere una tecla por ende el juego quedara congelado
		int 16h 

		cmp ah,1 ;si es otro ESC reanuda el juego
		je off

		cmp ah,57 ;espacio corresponde a 9 = 57, si viene espacio se regresara al menu principal
		je INSERTARUSUARIO 	;como se sale del juego mandamos a insertar la data que tenemos

		cmp al,50 ;a nivel 2
		je PASAMOSNIVEL2

		cmp al,51 ;a nivel 3
		je PASAMOSNIVEL3

	VerificarTecla:

		cmp ah,77
		je Derecha 	;la flecha derecha responde a la letra M 

		cmp ah,75
		je Izquierda 	;la flecha derecha responde a la letra K

		cmp ah,57 	;espacio
		je INSERTARUSUARIO

		Derecha:

			push di
			push dx
			mov di,InicioPosActualBarra

			mov cx,60
			rep:
				push di
				add di,cx
				mov dl,es:[di] 	;inicio de la barra las 50 de largo mas 10 de incrtemento
				cmp dl,5
				je Nosepuede1
				pop di
				loop rep

			pop dx
			pop di

			borrarBarra
			add InicioPosActualBarra,0ah
			PintarBarra
			jmp off

			Nosepuede1:
				pop di  	;ultimo push del ciclo que se quedo metido
				pop dx
				pop di
				jmp off

		Izquierda:
			;verifico si puedo moverla 
			push di
			push dx
			mov di,InicioPosActualBarra

			mov cx,10
			rep1:
				push di
				sub di,cx
				mov dl,es:[di] 	;inicio de la barra las 50 de largo mas 10 de incrtemento
				cmp dl,5
				je Nosepuede
				pop di
				loop rep1

			pop dx
			pop di

			borrarBarra
			sub InicioPosActualBarra,0ah 	;muevo de 5 en  5 cada vez que acciono la tecla
			PintarBarra
			jmp off

			Nosepuede:
				pop di  	;ultimo push del ciclo que se quedo metido
				pop dx
				pop di
	off:
	pop ax
endm

Delay macro constante
	LOCAL D1,D2,Fin
	push si
	push di

	mov si,constante
	D1:
	dec si
	jz Fin
	mov di,constante
	D2:
	dec di
	jnz D2
	jmp D1

	Fin:
	pop di
	pop si
endm

LimpiarModoGrafico macro
	LOCAL Limpiando,fin
	mov di,6400
	mov dl,0

	Limpiando:
		cmp di,64000
		je fin

		mov es:[di],dl ;color negro
		inc di
		jmp Limpiando

		fin:
endm

;NIVEL 1
;FILAS 2-> 5 BLOQUES CADA FILA
;VELOCIDAD 200
;MOVIMINETO DE LA BARRA +- 5
NIVEL1 macro
	local Accion,auxdd,val,marg,DecrementoDerecha,Analisis_DecrementoDerecha,perdiodd,auxdi,val1,marg1,DecrementoIzquierda,Analisis_DecrementoIzquierda,perdiodi,auxii,val2,marg2,IncrementoIzquierda,Analisis_IncrementoIzquierda,auxid,val3,marg3,IncrementoDerecha,Analisis_IncrementoDerecha
	;LimpiarModoGrafico
	ModoVideo	
	;capturo el tiempo en el que se inicio el nivel1
	push cx
	push bx
	push dx

	mov ah,2ch
	int 21h
	mov segundosInicio,dh  ;dh =segundos
	mov minutosInicio,cl 	;cl=minutos

	xor ax,ax
	xor bx,bx
	mov al,minutosInicio	;guardo los minutos
	mov bx,60
	mul bx					;multiplico los minutos *60
	xor bx,bx
	mov bl,segundosInicio
	add ax,bx				;les sumo los segundos = total de tiempo en segundos 
	mov segundostotalesInicio,ax 	;timepo en segundos en el instante que empieza el nivel 1 
	ImpresionCaracter 10	;imprimo un SaltoLineao de linea nose porque si no hay instruccion despues no guarda el valor

	pop dx
	pop bx
	pop cx
	pop ax

	PintarMargen 5			
	mov NivelActual,1
	mov punetoActual,0
	MostrarEncabezado
	;verificar en que nivel voy para poder asignar la velocidad de la pelota y la ccnatidad de bloques
			
	mov lineas,2
	PintarBloques lineas
	mov InicioPosActualBarra,59650	;POSICION DE INICIO DE LA BARRA
	PintarBarra

	;hacemos que precione una tecla
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;saldra una posicion arriba de la barra
	mov dx,59330 ;inicio de la pelota

	Accion:
			push dx
			MostrarEncabezado
			pop dx
			leertecla
			pintarPelota dx, 0 
			sub dx,319		;incremento derecha

			;***
			;***
			;***
			xor bl,bl
			mov di,dx
			add di,02h		
			
			mov bl,es:[di]	;color del margen
			cmp bl,0
			jne auxdd
			
			sub di,02h
			pintarPelota dx, 2
			Delay 200
			jmp Accion

	auxdd:
			;verifico si fue el color de mis bloques
		
			cmp bl,14
			je val
			jmp marg

			val:
				pintarPelota dx, 2 
				;=====================
				ValidarChoque lineas
				pintarPelota dx, 0
				;MostrarEncabezado

			marg:
			add dx,321
	DecrementoDerecha:
			push dx
			MostrarEncabezado
			pop dx
			leertecla
			pintarPelota dx, 0 
			add dx,321

			;***
			;***
			;***

			;VALIDACIONES HACIA LA ESQUINA INFERIOR DERECHA

			xor bl,bl
			xor di,di
			mov di,dx
			
			add di,323
			mov bl,es:[di]	
			cmp bl,5 	
			je auxdi

			cmp bl,14
			je auxdi			
			sub di,323


			add di,643
			mov bl,es:[di]	
			cmp bl,5
			je auxdi

			cmp bl,14	
			je auxdi
			sub di,643

			add di,961
			mov bl,es:[di]	
			cmp bl,5  	
			je INSERTARUSUARIO

			cmp bl,11	
			je auxid

			cmp bl,14	
			je auxid
			sub di,961

			add di,962
			mov bl,es:[di]	
			cmp bl,5  	
			je INSERTARUSUARIO

			cmp bl,14	
			je auxdi

			cmp bl,11
			je auxid
			sub di,962

			add di,963
			mov bl,es:[di]	
			cmp bl,5  	
			je auxdi

			cmp bl,14	
			je auxdi
			sub di,963

			pintarPelota dx, 2
			Delay 200
			jmp DecrementoDerecha

			Analisis_DecrementoDerecha:   ;analisis porque perdio.  comparar cuantas vidas tiene
		
	auxdi:
			;verifico si fue el color de mis bloques 
			
			cmp bl,14
			je val1
			jmp marg1

			val1:
				pintarPelota dx, 2 
				;=====================
				ValidarChoque lineas
				pintarPelota dx, 0
				;MostrarEncabezado

			marg1:
			add dx,319
	DecrementoIzquierda:
			push dx
			MostrarEncabezado
			pop dx
			leertecla
			pintarPelota dx, 0 
			add dx,319

			;***
			;***
			;***
			xor bl,bl
			xor di,di
			mov di,dx

			;VALIDACIONES REFERENTES A LA ESQUINA INFERRIOR IZQUIERDA

				add di,319
				mov bl,es:[di]
				cmp bl,5 
				je auxdd
				cmp bl,14 
				je auxdd
				sub di,319

				add di,639
				mov bl,es:[di]
				cmp bl,5
				je auxdd
				cmp bl,14 
				je auxdd
				sub di,639

				add di,960
				mov bl,es:[di]
				cmp bl,5
				je INSERTARUSUARIO
				cmp bl,11
				je auxii
				cmp bl,14 
				je auxii
				sub di,960

				add di,961
				mov bl,es:[di]
				cmp bl,5
				je INSERTARUSUARIO
				cmp bl,11
				je auxii
				cmp bl,14 
				je auxii
				sub di,961

				add di,959
				mov bl,es:[di]
				cmp bl,5
				je auxdd
				cmp bl,11 
				je auxdd
				sub di,959
			

			pintarPelota dx, 2
			Delay 200
			jmp DecrementoIzquierda

			Analisis_DecrementoIzquierda:			 
		
	auxii:
			;verifico si fue el color de mis bloques 
		
			cmp bl,14
			je val2
			jmp marg2

			val2:
				pintarPelota dx, 2 
				;=====================
				ValidarChoque lineas
				pintarPelota dx, 0
				;MostrarEncabezado

			marg2:
			sub dx,321
	IncrementoIzquierda:
			push dx
			MostrarEncabezado
			pop dx
			leertecla
			pintarPelota dx, 0 
			sub dx,321

			;***
			;***
			;***

			;VALIDACIONES REFERENTES A LA ESQUINA SUPERIOR IZQUIERDA
			xor bl,bl
			xor di,di
			mov di,dx

			sub di,320
			mov bl,es:[di]
			cmp bl,5
			je auxdi
			cmp bl,14 
			je auxdi
			add di,320

			sub di,319
			mov bl,es:[di]
			cmp bl,5
			je auxdi
			cmp bl,14 
			je auxdi
			add di,319

			sub di,1
			mov bl,es:[di]
			cmp bl,5
			je auxid
			cmp bl,14 
			je auxid
			add di,1

			add di,319
			mov bl,es:[di]
			cmp bl,05h
			je auxid
			cmp bl,14 
			je auxid
			sub di,319

			sub di,321
			mov bl,es:[di]
			cmp bl,05h 
			je auxdi
			cmp bl,14
			je auxdi
			add di,321

			pintarPelota dx, 2
			Delay 200
			jmp IncrementoIzquierda

			Analisis_IncrementoIzquierda:			 

	auxid:
			;verifico si fue el color de mis bloques 
		
			cmp bl,14
			je val3
			jmp marg3

			val3:
				pintarPelota dx, 2 
				;=====================
				ValidarChoque lineas
				pintarPelota dx, 0
				;MostrarEncabezado

			marg3:
			sub dx,319
	IncrementoDerecha:
			push dx
			MostrarEncabezado
			pop dx
			leertecla
			pintarPelota dx, 0 
			sub dx,319

			;***
			;***
			;***
			; xor bl,bl
			; xor di,di
			; mov di,dx

			; sub di,320		;validacion para saber si era el limite superior ya que siempre que tocaba me borraba la linea
			; cmp di,6400
			; jb der


			; add di,322
			; der:			
			; add di,320
			; mov bl,[di]	;color del margen
			; cmp bl,0
			; jne Analisis_IncrementoDerecha

			xor bl,bl
			xor di,di
			mov di,dx

			;VALIDACIONES REFERENTES A LA ESQUINA SUPERIOR DERECHA
			
			sub di,319
			mov bl,es:[di]
			cmp bl,05h
			je auxdd
			cmp bl,14
			je auxdd
			add di,319

			sub di,318
			mov bl,es:[di]
			cmp bl,05h
			je auxdd
			cmp bl,14 
			je auxdd
			add di,318

			add di,3
			mov bl,es:[di]
			cmp bl,05h
			je auxii
			cmp bl,14 
			je auxii
			sub di,3

			add di,323
			mov bl,es:[di]
			cmp bl,05h
			je auxii
			cmp bl,14 
			je auxii
			sub di,323

			sub di,317
			mov bl,es:[di]
			cmp bl,05h
			je auxdd
			cmp bl,14 
			je auxdd
			add di,317
			pintarPelota dx, 2
			Delay 200
			jmp IncrementoDerecha

			Analisis_IncrementoDerecha:
endm

;NIVEL 2
;FILAS 3-> 5 BLOQUES CADA FILA
;VELOCIDAD 160
;MOVIMINETO DE LA BARRA +- 5
NIVEL2 macro
	local muriobola1,Accion,auxdd,val,marg,DecrementoDerecha,Analisis_DecrementoDerecha,perdiodd,auxdi,val1,marg1,DecrementoIzquierda,Analisis_DecrementoIzquierda,perdiodi,auxii,val2,marg2,IncrementoIzquierda,Analisis_IncrementoIzquierda,auxid,val3,marg3,IncrementoDerecha,Analisis_IncrementoDerecha
	LimpiarModoGrafico

	PintarMargen 5			
	mov NivelActual,2
	mov punetoActual,10	;si pasa al nivel 2 es porque tiene 10 de punteo
	MostrarEncabezado
	;verificar en que nivel voy para poder asignar la velocidad de la pelota y la ccnatidad de bloques
			
	mov lineas,3
	PintarBloques lineas
	mov InicioPosActualBarra,59650	;POSICION DE INICIO DE LA BARRA
	PintarBarra

	mov posicionPelota1,59330
	mov posicionPelota2,59300
	mov estadop1,1
	mov estadop2,0  ;se activara cuando vaya por 17 puntos
	mov moviminetoP1,1
	mov moviminetoP2,1
	mov vidas,1

	mov dx,posicionPelota1

	;;hacemos que precione una tecla
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;saldra una posicion arriba de la barra
	Pelota1:
		mov dx,posicionPelota1
		Accion:
				cmp estadop1,1
				jne muriobola1
				
				push dx
				MostrarEncabezado
				pop dx
				leertecla
				pintarPelota dx, 0 
				sub dx,319		;incremento derecha

				;***
				;***
				;***
				xor bl,bl
				mov di,dx
				add di,02h		
				
				mov bl,es:[di]	
				cmp bl,0
				jne auxdd
				
				sub di,02h
				pintarPelota dx, 2
				Delay 160

				;muriobola1:
				push dx
				moverPelotaExtra posicionPelota2,moviminetoP2
				pop dx
				jmp Accion

		auxdd:
				;verifico si fue el color de mis bloques
			
				cmp bl,14
				je val
				jmp marg

				val:
					pintarPelota dx, 2 
					;=====================
					ValidarChoque lineas
					pintarPelota dx, 0
					;MostrarEncabezado

				marg:
				add dx,321
		DecrementoDerecha:
				cmp estadop1,1
				jne muriobola1

				push dx
				MostrarEncabezado
				pop dx
				leertecla
				pintarPelota dx, 0 
				add dx,321

				;***
				;***
				;***

				;VALIDACIONES HACIA LA ESQUINA INFERIOR DERECHA

				xor bl,bl
				xor di,di
				mov di,dx
				
				add di,323
				mov bl,es:[di]
				cmp bl,5 
				je auxdi

				cmp bl,14
				je auxdi			
				sub di,323


				add di,643
				mov bl,es:[di]
				cmp bl,5
				je auxdi

				cmp bl,14
				je auxdi
				sub di,643

				add di,961
				mov bl,es:[di]
				cmp bl,5  	
				je muriobola1

				cmp bl,11	
				je auxid

				cmp bl,14	
				je auxid
				sub di,961

				add di,962
				mov bl,es:[di]	
				cmp bl,5  	
				je muriobola1

				cmp bl,14	
				je auxdi

				cmp bl,11
				je auxid
				sub di,962

				add di,963
				mov bl,es:[di]	
				cmp bl,5  	
				je auxdi

				cmp bl,14	
				je auxdi
				sub di,963

				pintarPelota dx, 2
				Delay 160
			
				push dx
				moverPelotaExtra posicionPelota2,moviminetoP2
				pop dx
				jmp DecrementoDerecha

				Analisis_DecrementoDerecha:   ;analisis porque perdio.  comparar cuantas vidas tiene
			
		auxdi:
				;verifico si fue el color de mis bloques 
				
				cmp bl,14
				je val1
				jmp marg1

				val1:
					pintarPelota dx, 2 
					;=====================
					ValidarChoque lineas
					pintarPelota dx, 0
					;MostrarEncabezado

				marg1:
				add dx,319
		DecrementoIzquierda:
				cmp estadop1,1
				jne muriobola1

				push dx
				MostrarEncabezado
				pop dx
				leertecla
				pintarPelota dx, 0 
				add dx,319

				;***
				;***
				;***
				xor bl,bl
				xor di,di
				mov di,dx

				;VALIDACIONES REFERENTES A LA ESQUINA INFERRIOR IZQUIERDA

					add di,319
					mov bl,es:[di]
					cmp bl,5 
					je auxdd
					cmp bl,14 
					je auxdd
					sub di,319

					add di,639
					mov bl,es:[di]
					cmp bl,5
					je auxdd
					cmp bl,14 
					je auxdd
					sub di,639

					add di,960
					mov bl,es:[di]
					cmp bl,5
					je muriobola1
					cmp bl,11
					je auxii
					cmp bl,14 
					je auxii
					sub di,960

					add di,961
					mov bl,es:[di]
					cmp bl,5
					je muriobola1
					cmp bl,11
					je auxii
					cmp bl,14 
					je auxii
					sub di,961

					add di,959
					mov bl,es:[di]
					cmp bl,5
					je auxdd
					cmp bl,11 
					je auxdd
					sub di,959
				

				pintarPelota dx, 2
				Delay 160
				push dx
				moverPelotaExtra posicionPelota2,moviminetoP2
				pop dx
				jmp DecrementoIzquierda

				Analisis_DecrementoIzquierda:			 
			
		auxii:
				;verifico si fue el color de mis bloques 
			
				cmp bl,14
				je val2
				jmp marg2

				val2:
					pintarPelota dx, 2 
					;=====================
					ValidarChoque lineas
					pintarPelota dx, 0
					;MostrarEncabezado

				marg2:
				sub dx,321
		IncrementoIzquierda:
				cmp estadop1,1
				jne muriobola1

				push dx
				MostrarEncabezado
				pop dx
				leertecla
				pintarPelota dx, 0 
				sub dx,321

				;***
				;***
				;***

				;VALIDACIONES REFERENTES A LA ESQUINA SUPERIOR IZQUIERDA
				xor bl,bl
				xor di,di
				mov di,dx

				sub di,320
				mov bl,es:[di]
				cmp bl,5
				je auxdi
				cmp bl,14 
				je auxdi
				add di,320

				sub di,319
				mov bl,es:[di]
				cmp bl,5
				je auxdi
				cmp bl,14 
				je auxdi
				add di,319

				sub di,1
				mov bl,es:[di]
				cmp bl,5
				je auxid
				cmp bl,14 
				je auxid
				add di,1

				add di,319
				mov bl,es:[di]
				cmp bl,05h
				je auxid
				cmp bl,14 
				je auxid
				sub di,319

				sub di,321
				mov bl,es:[di]
				cmp bl,05h 
				je auxdi
				cmp bl,14 
				je auxdi
				add di,321

				pintarPelota dx, 2
				Delay 160
				push dx
				moverPelotaExtra posicionPelota2,moviminetoP2
				pop dx
				jmp IncrementoIzquierda

				Analisis_IncrementoIzquierda:			 

		auxid:
				;verifico si fue el color de mis bloques 
			
				cmp bl,14
				je val3
				jmp marg3

				val3:
					pintarPelota dx, 2 
					;=====================
					ValidarChoque lineas
					pintarPelota dx, 0
					;MostrarEncabezado

				marg3:
				sub dx,319
		IncrementoDerecha:

				cmp estadop1,1
				jne muriobola1

				push dx
				MostrarEncabezado
				pop dx
				leertecla
				pintarPelota dx, 0 
				sub dx,319

				;***
				;***
				;***
				; xor bl,bl
				; xor di,di
				; mov di,dx

				; sub di,320		;validacion para saber si era el limite superior ya que siempre que tocaba me borraba la linea
				; cmp di,6400
				; jb der


				; add di,322
				; der:			
				; add di,320
				; mov bl,[di]	;color del margen
				; cmp bl,0
				; jne Analisis_IncrementoDerecha

				xor bl,bl
				xor di,di
				mov di,dx

				;VALIDACIONES REFERENTES A LA ESQUINA SUPERIOR DERECHA
				
				sub di,319
				mov bl,es:[di]
				cmp bl,05h 
				je auxdd
				cmp bl,14 
				je auxdd
				add di,319

				sub di,318
				mov bl,es:[di]
				cmp bl,05h
				je auxdd
				cmp bl,14 
				je auxdd
				add di,318

				add di,3
				mov bl,es:[di]
				cmp bl,05h
				je auxii
				cmp bl,14 
				je auxii
				sub di,3

				add di,323
				mov bl,es:[di]
				cmp bl,05h
				je auxii
				cmp bl,14 
				je auxii
				sub di,323

				sub di,317
				mov bl,es:[di]
				cmp bl,05h
				je auxdd
				cmp bl,14 
				je auxdd
				add di,317
				pintarPelota dx, 2
				Delay 160
				push dx
				moverPelotaExtra posicionPelota2,moviminetoP2
				pop dx
				jmp IncrementoDerecha

				Analisis_IncrementoDerecha:

		muriobola1:
			mov estadop1,0
			cmp estadop2,1
			jne INSERTARUSUARIO 	;perdio las dos vidas 

			push dx
			moverPelotaExtra posicionPelota2,moviminetoP2
			pop dx
			jmp Accion
endm

moverPelotaExtra macro posicion,estadoactual
	local insert,fin_1,finfin,fin,Accion,auxdd,val,marg,DecrementoDerecha,Analisis_DecrementoDerecha,perdiodd,auxdi,val1,marg1,DecrementoIzquierda,Analisis_DecrementoIzquierda,perdiodi,auxii,val2,marg2,IncrementoIzquierda,Analisis_IncrementoIzquierda,auxid,val3,marg3,IncrementoDerecha,Analisis_IncrementoDerecha

	cmp estadop2,1
	jne finfin

	mov dx,posicion
	pintarPelota dx,0

	cmp estadoactual,1
	je auxid
	
	cmp estadoactual,2
	je auxii

	cmp estadoactual,3
	je auxdd

	cmp estadoactual,4
	je auxdi

	Accion:
		push dx
		MostrarEncabezado
		pop dx
		leertecla
		pintarPelota dx, 0 
		sub dx,319		;incremento derecha

		;***
		;***
		;***
		xor bl,bl
		mov di,dx
		add di,02h		
				
		mov bl,es:[di]	;color del margen
		cmp bl,0
		jne auxdd
				
		sub di,02h
		pintarPelota dx, 2
		Delay 180
		;mov id=1,ii=2,dd=3,di=4
		mov moviminetoP2,1
		jmp fin

		auxdd:
			;verifico si fue el color de mis bloques
			
			cmp bl,14
			je val
			jmp marg
			val:
				pintarPelota dx, 2 
				;=====================
				ValidarChoque lineas
				pintarPelota dx, 0
				;MostrarEncabezado

			marg:
				add dx,321
		DecrementoDerecha:
			push dx
			MostrarEncabezado
			pop dx
			leertecla
			pintarPelota dx, 0 
			add dx,321

			;***
			;***
			;***

			;VALIDACIONES HACIA LA ESQUINA INFERIOR DERECHA

			xor bl,bl
			xor di,di
			mov di,dx
				
			add di,322
			mov bl,es:[di]
			cmp bl,5 	
			je auxdi

			cmp bl,14	
			je auxdi			
			sub di,322


			add di,643
			mov bl,es:[di]
			cmp bl,5
			je auxdi

			cmp bl,14	
			je auxdi
			sub di,643

			add di,961
			mov bl,es:[di]
			cmp di,60805  	
			ja fin_1

			cmp bl,11	
			je auxid

			cmp bl,14	
			je auxid
			sub di,961

			add di,962
			mov bl,es:[di]
				cmp di,60805  	
			ja fin_1

			cmp bl,14	
			je auxdi

			cmp bl,11
			je auxid
			sub di,962

			add di,963
			mov bl,es:[di]	
			cmp bl,5  	
			je auxdi

			cmp bl,14	
			je auxdi
			sub di,963

			pintarPelota dx, 2
			Delay 180
			;mov id=1,ii=2,dd=3,di=4
			mov moviminetoP2,3
			jmp fin
			
		auxdi:
				;verifico si fue el color de mis bloques 
				
				cmp bl,14
				je val1
				jmp marg1

				val1:
					pintarPelota dx, 2 
					;=====================
					ValidarChoque lineas
					pintarPelota dx, 0
					;MostrarEncabezado

				marg1:
				add dx,319
		DecrementoIzquierda:
				push dx
				MostrarEncabezado
				pop dx
				leertecla
				pintarPelota dx, 0 
				add dx,319

				;***
				;***
				;***
				xor bl,bl
				xor di,di
				mov di,dx

				;VALIDACIONES REFERENTES A LA ESQUINA INFERRIOR IZQUIERDA

					add di,319
					mov bl,es:[di]
					cmp bl,5 ;choque marco
					je auxdd
					cmp bl,14 ;choque bloque
					je auxdd
					sub di,319

					add di,639
					mov bl,es:[di]
					cmp bl,5
					je auxdd
					cmp bl,14 ;choque bloque
					je auxdd
					sub di,639

					add di,960
					mov bl,es:[di]
						cmp di,60805  	;choca con el margen de abajo
					ja fin_1
					cmp bl,11
					je auxii
					cmp bl,14 ;choque bloque
					je auxii
					sub di,960

					add di,961
					mov bl,es:[di]
						cmp di,60805  	;choca con el margen de abajo
					ja fin_1
					cmp bl,11
					je auxii
					cmp bl,14 ;choque bloque
					je auxii
					sub di,961

					add di,959
					mov bl,es:[di]
					cmp bl,5
					je auxdd
					cmp bl,11 ;choque bloque
					je auxdd
					sub di,959
				

				pintarPelota dx, 2
				Delay 180
				;mov id=1,ii=2,dd=3,di=4
				mov moviminetoP2,4
				jmp fin
						 	
		auxii:
				;verifico si fue el color de mis bloques 
			
				cmp bl,14
				je val2
				jmp marg2

				val2:
					pintarPelota dx, 2 
					;=====================
					ValidarChoque lineas
					pintarPelota dx, 0
					;MostrarEncabezado

				marg2:
				sub dx,321
		IncrementoIzquierda:
				push dx
				MostrarEncabezado
				pop dx
				leertecla
				pintarPelota dx, 0 
				sub dx,321

				;***
				;***
				;***

				;VALIDACIONES REFERENTES A LA ESQUINA SUPERIOR IZQUIERDA
				xor bl,bl
				xor di,di
				mov di,dx

				sub di,320
				mov bl,es:[di]
				cmp bl,5
				je auxdi
				cmp bl,14 ;choque bloque
				je auxdi
				add di,320

				sub di,319
				mov bl,es:[di]
				cmp bl,5
				je auxdi
				cmp bl,14 ;choque bloque
				je auxdi
				add di,319

				sub di,1
				mov bl,es:[di]
				cmp bl,5
				je auxid
				cmp bl,14 ;choque bloque
				je auxid
				add di,1

				add di,319
				mov bl,es:[di]
				cmp bl,05h
				je auxid
				cmp bl,14 ;choque bloque
				je auxid
				sub di,319

				sub di,321
				mov bl,es:[di]
				cmp bl,05h ;choque marco
				je auxdi
				cmp bl,14 ;choque bloque
				je auxdi
				add di,321

				pintarPelota dx, 2
				Delay 180
				;mov id=1,ii=2,dd=3,di=4
				mov moviminetoP2,2
				jmp fin		 

		auxid:
				;verifico si fue el color de mis bloques 
			
				cmp bl,14
				je val3
				jmp marg3

				val3:
					pintarPelota dx, 2 
					;=====================
					ValidarChoque lineas
					pintarPelota dx, 0
					;MostrarEncabezado

				marg3:
				sub dx,319
		IncrementoDerecha:
				push dx
				MostrarEncabezado
				pop dx
				leertecla
				pintarPelota dx, 0 
				sub dx,319

				;***
				;***
				;***
				; xor bl,bl
				; xor di,di
				; mov di,dx

				; sub di,320		;validacion para saber si era el limite superior ya que siempre que tocaba me borraba la linea
				; cmp di,6400
				; jb der


				; add di,322
				; der:			
				; add di,320
				; mov bl,[di]	;color del margen
				; cmp bl,0
				; jne Analisis_IncrementoDerecha

				xor bl,bl
				xor di,di
				mov di,dx

				;VALIDACIONES REFERENTES A LA ESQUINA SUPERIOR DERECHA
				
				sub di,319
				mov bl,es:[di]
				cmp bl,05h ;choque marco
				je auxdd
				cmp bl,14 ;choque bloque
				je auxdd
				add di,319

				sub di,318
				mov bl,es:[di]
				cmp bl,05h
				je auxdd
				cmp bl,14 ;choque bloque
				je auxdd
				add di,318

				add di,3
				mov bl,es:[di]
				cmp bl,05h
				je auxii
				cmp bl,14 ;choque bloque
				je auxii
				sub di,3

				add di,323
				mov bl,es:[di]
				cmp bl,05h
				je auxii
				cmp bl,14 ;choque bloque
				je auxii
				sub di,323

				sub di,317
				mov bl,es:[di]
				cmp bl,05h
				je auxdd
				cmp bl,14 ;choque bloque
				je auxdd
				add di,317
				pintarPelota dx, 2
				Delay 180
				;mov id=1,ii=2,dd=3,di=4
				mov moviminetoP2,1
				jmp fin		

		fin_1:
			;verifico cuantas vidas tengo 
			sub vidas,01h
			cmp vidas,00h
			je INSERTARUSUARIO

			mov estadop2,0	 ;pelota 2 muere ya no se debe mostrar
			jmp finfin

		fin:
			mov posicionPelota2,dx

		finfin:
endm

;NIVEL 3
;FILAS 4-> 5 BLOQUES CADA FILA
;VELOCIDAD 140
;MOVIMINETO DE LA BARRA +- 5
NIVEL3 macro
	local Accion,auxdd,val,marg,DecrementoDerecha,Analisis_DecrementoDerecha,perdiodd,auxdi,val1,marg1,DecrementoIzquierda,Analisis_DecrementoIzquierda,perdiodi,auxii,val2,marg2,IncrementoIzquierda,Analisis_IncrementoIzquierda,auxid,val3,marg3,IncrementoDerecha,Analisis_IncrementoDerecha
	LimpiarModoGrafico


	PintarMargen 5			
	mov NivelActual,3
	mov punetoActual,25	;si pasa al nivel 3 es porque tiene 25 de punteo
	MostrarEncabezado
	;verificar en que nivel voy para poder asignar la velocidad de la pelota y la ccnatidad de bloques
			
	mov lineas,4
	PintarBloques lineas
	mov InicioPosActualBarra,59650	;POSICION DE INICIO DE LA BARRA
	PintarBarra

	mov posicionPelota1,59300
	mov posicionPelota2,59300
	mov estadop1,1
	mov estadop2,0  ;se activara cuando vaya por 31 puntos
	mov estadop3,0  ;se acctivara cuando el puntaje sea 37
	mov moviminetoP1,1
	mov moviminetoP2,1
	mov movimientoP3,1
	mov vidas,1

	mov dx,posicionPelota1

	jmp auxii
	Accion:

			push dx
			MostrarEncabezado
			pop dx
			leertecla
			pintarPelota dx, 0 
			sub dx,319		;incremento derecha

			;***
			;***
			;***
			xor bl,bl
			mov di,dx
			add di,02h		
			
			mov bl,es:[di]	;color del margen
			cmp bl,0
			jne auxdd
			
			sub di,02h
			pintarPelota dx, 2
			Delay 140
			
			jmp Accion

	auxdd:
			;verifico si fue el color de mis bloques
		
			cmp bl,14
			je val
			jmp marg

			val:
				pintarPelota dx, 2 
				;=====================
				ValidarChoque lineas
				pintarPelota dx, 0
				;MostrarEncabezado

			marg:
			add dx,321
	DecrementoDerecha:
			push dx
			MostrarEncabezado
			pop dx
			leertecla
			pintarPelota dx, 0 
			add dx,321

			;***
			;***
			;***

			;VALIDACIONES HACIA LA ESQUINA INFERIOR DERECHA

			xor bl,bl
			xor di,di
			mov di,dx
			
			add di,323
			mov bl,es:[di]	
			cmp bl,5 	
			je auxdi

			cmp bl,14	
			je auxdi			
			sub di,323


			add di,643
			mov bl,es:[di]	
			cmp bl,5
			je auxdi

			cmp bl,14	
			je auxdi
			sub di,643

			add di,961
			mov bl,es:[di]	
			cmp bl,5  	
			je INSERTARUSUARIO

			cmp bl,11	
			je auxid

			cmp bl,14	
			je auxid
			sub di,961

			add di,962
			mov bl,es:[di]
			cmp bl,5  	
			je INSERTARUSUARIO

			cmp bl,14	
			je auxdi

			cmp bl,11
			je auxid
			sub di,962

			add di,963
			mov bl,es:[di]	
			cmp bl,5  	
			je auxdi

			cmp bl,14	
			je auxdi
			sub di,963

			pintarPelota dx, 2
			Delay 140
			jmp DecrementoDerecha

			Analisis_DecrementoDerecha:   ;analisis porque perdio.  comparar cuantas vidas tiene
		
	auxdi:
			;verifico si fue el color de mis bloques 
			
			cmp bl,14
			je val1
			jmp marg1

			val1:
				pintarPelota dx, 2 
				;=====================
				ValidarChoque lineas
				pintarPelota dx, 0
				;MostrarEncabezado

			marg1:
			add dx,319
	DecrementoIzquierda:
			push dx
			MostrarEncabezado
			pop dx
			leertecla
			pintarPelota dx, 0 
			add dx,319

			;***
			;***
			;***
			xor bl,bl
			xor di,di
			mov di,dx

			;VALIDACIONES REFERENTES A LA ESQUINA INFERRIOR IZQUIERDA

				add di,319
				mov bl,es:[di]
				cmp bl,5 
				je auxdd
				cmp bl,14 
				je auxdd
				sub di,319

				add di,639
				mov bl,es:[di]
				cmp bl,5
				je auxdd
				cmp bl,14 
				je auxdd
				sub di,639

				add di,960
				mov bl,es:[di]
				cmp bl,5
				je INSERTARUSUARIO
				cmp bl,11
				je auxii
				cmp bl,14 
				je auxii
				sub di,960

				add di,961
				mov bl,es:[di]
				cmp bl,5
				je INSERTARUSUARIO
				cmp bl,11
				je auxii
				cmp bl,14 
				je auxii
				sub di,961

				add di,959
				mov bl,es:[di]
				cmp bl,5
				je auxdd
				cmp bl,11 
				je auxdd
				sub di,959
			

			pintarPelota dx, 2
			Delay 140
			jmp DecrementoIzquierda

			Analisis_DecrementoIzquierda:
				 
	auxii:
			;verifico si fue el color de mis bloques 
		
			cmp bl,14
			je val2
			jmp marg2

			val2:
				pintarPelota dx, 2 
				;=====================
				ValidarChoque lineas
				pintarPelota dx, 0
				;MostrarEncabezado

			marg2:
			sub dx,321
	IncrementoIzquierda:
			push dx
			MostrarEncabezado
			pop dx
			leertecla
			pintarPelota dx, 0 
			sub dx,321

			;***
			;***
			;***

			;VALIDACIONES REFERENTES A LA ESQUINA SUPERIOR IZQUIERDA
			xor bl,bl
			xor di,di
			mov di,dx

			sub di,320
			mov bl,es:[di]
			cmp bl,5
			je auxdi
			cmp bl,14 
			je auxdi
			add di,320

			sub di,319
			mov bl,es:[di]
			cmp bl,5
			je auxdi
			cmp bl,14 
			je auxdi
			add di,319

			sub di,1
			mov bl,es:[di]
			cmp bl,5
			je auxid
			cmp bl,14 
			je auxid
			add di,1

			add di,319
			mov bl,es:[di]
			cmp bl,5
			je auxid
			cmp bl,14 
			je auxid
			sub di,319

			sub di,321
			mov bl,es:[di]
			cmp bl,5
			je auxdi
			cmp bl,14 
			je auxdi
			add di,321

			pintarPelota dx, 2
			Delay 140
			jmp IncrementoIzquierda

			Analisis_IncrementoIzquierda:
				 
	auxid:
			;verifico si fue el color de mis bloques 
		
			cmp bl,14
			je val3
			jmp marg3

			val3:
				pintarPelota dx, 2 
				;=====================
				ValidarChoque lineas
				pintarPelota dx, 0
				;MostrarEncabezado

			marg3:
			sub dx,319
	IncrementoDerecha:
			push dx
			MostrarEncabezado
			pop dx
			leertecla
			pintarPelota dx, 0 
			sub dx,319

			;***
			;***
			;***
			; xor bl,bl
			; xor di,di
			; mov di,dx

			; sub di,320		;validacion para saber si era el limite superior ya que siempre que tocaba me borraba la linea
			; cmp di,6400
			; jb der


			; add di,322
			; der:			
			; add di,320
			; mov bl,[di]	;color del margen
			; cmp bl,0
			; jne Analisis_IncrementoDerecha

			xor bl,bl
			xor di,di
			mov di,dx

			;VALIDACIONES REFERENTES A LA ESQUINA SUPERIOR DERECHA
			
			sub di,319
			mov bl,es:[di]
			cmp bl,5 
			je auxdd
			cmp bl,14 
			je auxdd
			add di,319

			sub di,318
			mov bl,es:[di]
			cmp bl,05h
			je auxdd
			cmp bl,14 
			je auxdd
			add di,318

			add di,3
			mov bl,es:[di]
			cmp bl,05h
			je auxii
			cmp bl,14 
			je auxii
			sub di,3

			add di,323
			mov bl,es:[di]
			cmp bl,05h
			je auxii
			cmp bl,14 
			je auxii
			sub di,323

			sub di,317
			mov bl,es:[di]
			cmp bl,05h
			je auxdd
			cmp bl,14 
			je auxdd
			add di,317
			pintarPelota dx, 2
			Delay 140
			jmp IncrementoDerecha

			Analisis_IncrementoDerecha:
endm

ValidarChoque macro NoLineas

	local sumo,sigo,Comparo,RevisoBloque,Choco,SigBloque,NohayBloque_sig,finval,finval2,limpiaar,Gano1erNivel,Gano2doNivel,Gano3erNivel,activoPelota2
	push dx
	push di

	xor cx,cx
	xor si,si
	xor bx,bx
	xor ax,NoLineas

	mov di,8050	;posicion inicial de mis bloques

	Comparo:
		push di 	;guardo la posicion inicial del bloque
		
		mov dl,es:[di]
		cmp dl,0
		je NohayBloque_sig  	;el bloque ya fue eliminado asi que pasamos al siguiente
		
		cmp dl,14
		jne finval 	;si es diferente al color de mis bloques es porque toco margen

		mov cx,40	;ancho de mis bloques 

		RevisoBloque:
			mov dl,es:[di-320] ;arriba
			cmp dl,2
			je Choco

			mov dl,es:[di-1] ;fila 0 izquierda
			cmp dl,2
			je Choco
			
			mov dl,es:[di+1] ;fila 0 derecha
			cmp dl,2
			je Choco

			mov dl,es:[di+319] ;fila 1 izquierda
			cmp dl,2
			je Choco

			mov dl,es:[di+321] ;fila 1 derecha
			cmp dl,2
			je Choco

			mov dl,es:[di+639] ;fila 2 izquierda
			cmp dl,2
			je Choco

			mov dl,es:[di+641] ;fila 2 derecha
			cmp dl,2
			je Choco

			mov dl,es:[di+959] ;fila 3 izquierda
			cmp dl,2 
			je Choco

			mov dl,es:[di+961] ;fila 3 derecha
			cmp dl,2 
			je Choco

			mov dl,es:[di+1279] ;fila 4 izquierda
			cmp dl,2
			je Choco

			mov dl,es:[di+1281] ;fila 4 derecha
			cmp dl,2
			je Choco

			mov dl,es:[di+1600] ;fila 5 abajo
			cmp dl,2 
			je Choco

			;si en nigun contorno de ese pixel existe el color de mi pelota paso al siguiente pixel
			inc di
			loop RevisoBloque
			;cuando se termine significa que tengoq ue pasar al otro bloque
			jmp SigBloque

			Choco:
				;printGrafico aqui
				pop di 		;inicio del bloque que colisiono
				mov dl,0 ;muevo el color negro
				mov cx,40 	;anccho del bloque
				limpiaar:
					mov es:[di],dl
					mov es:[di+320],dl
					mov es:[di+640],dl
					mov es:[di+960],dl
					mov es:[di+1280],dl
					inc di
					Loop limpiaar
					add punetoActual,01h		;si el punteo llega a 10, gano el primer nivel, si es 25 gano el 2 y si es 45 gano el 3er nivel

					cmp punetoActual,17
					je activoPelota2
					
					cmp punetoActual,0ah 		;nivel1 se gana con 10 puntos
					je Gano1erNivel

					cmp punetoActual,19h 		;nivel 2 se gana con 25 puntos
					je Gano2doNivel

					cmp punetoActual,2dh		;nivel 3 se gana con 45 puntos
					je Gano3erNivel

					jmp finval2

					activoPelota2:
						mov estadop2,1
						add vidas,01h
						jmp finval2

					Gano1erNivel:
						;NIVEL2
						;push ax
						;mov ax,tiempoTotalSegundos
						;mov tiempoNivel1,ax
						;pop ax
						jmp PASAMOSNIVEL2

					Gano2doNivel:
						;NIVEL2
						;push ax
						;mov ax,tiempoTotalSegundos
						;mov tiempoNivel1,ax
						;pop ax
					jmp PASAMOSNIVEL3

					Gano3erNivel:
						;NIVEL2
						;push ax
						;mov ax,tiempoTotalSegundos
						;mov tiempoNivel1,ax
						;pop ax
					jmp INSERTARUSUARIO

			SigBloque:
				;printGrafico aqui
				pop cx
				inc bx
				add di,0ah 	;separacion
				cmp bx,5	;verifico si ya vopy por el 5 cuadro de la fila
				jne Comparo
				;si ya termine esa fila paso a la siguiente

				inc si 	;incremento la cantidad de filas realizadas
				cmp ax,1
				je finval ;si esa fue la utlima linea termino
				dec ax

				mov di,8050	;inicio
				push si
				sumo:
					cmp si,0
					je sigo
					add di,4800 	;le sumo las 5 filas ocupadas por el bloque anterior mas 8 lineas de esapacio vertical
					dec si
					jmp sumo

				sigo:
					pop si
					xor bx,bx
					jmp Comparo

			NohayBloque_sig:
				;pasamos al siguienter bloque
				pop di
				add di,40	;ancho de mi bloque
				add di,0ah  ;separacion entrebloques
				inc bx 		;cantidad de bloques leidos
				jmp Comparo

			finval:
				pop cx
			finval2:
			pop di
			pop dx
endm

parseToInt macro number1,num1		;buffer en doinde viene el numero y numero donde se almacenara
	
	LOCAL CANTNUMERO1,FIN,CANT_3,CANT_2,CANT_1,final
	push si ;contador de cuantas posiciones tiene el numero
	push di
	push cx
	;push ax
	xor si,si
	xor di,di

	CANTNUMERO1:
		cmp number1[si],36
		je FIN

		inc si
		jmp CANTNUMERO1

		FIN:
			;ESTADOS UTILIZADOS PARA SABER SI HAY CENTENAS DECENAS O UNIDADES Y EN BASE A ESO SE LE APLICARA UN MULTIPLICADOR
			cmp si,03h
			je CANT_3

			cmp si,02h
			je CANT_2

			cmp si,01h
			je CANT_1

			CANT_3:
				xor ax,ax
				mov al,number1[0]
				sub al,30h 		;le resto 30h = 48 para obtener el numero real
				xor cl,cl
				mov cl,64h		;centena se multipliaca por 100
				mul cl 	;multiplica ax = cl*al
				
				;EL NUMERO ESTA ALAMACENADO EN AX = AH -AL 
				;mov bl,ah 	;almeceno la parte alta,muevo a otro registro porque ah se usa para imprimir y se modifica
				;ImpresionCaracter al
				;ImpresionCaracter bl

				xor cl,cl
				;hacemos lo mismo para la pocicion 2 solo que ahora es DECENA

				push ax ;guardamos el valor anterior
				xor ax,ax
				mov al,number1[1]
				sub al,30h 		;le resto 30h = 48 para obtener el numero real
				xor cl,cl
				mov cl,0ah		;decena se multipliaca por 10
				mul cl 	;multiplica ax = cl*al
				xor cl,cl
				mov num1,0	;limipiamos num1
				mov num1,ax 	;le pasamos el valor actual
				xor ax,ax
				pop ax

				add ax,num1 	;entonces al actualmente tiene la suma de los dos valores.	

				;hacemos lo mismo para la pocicion 2 solo que ahora es DECENA
				push ax ;guardamos el valor anterior
				xor ax,ax
				mov al,number1[2]
				sub al,30h 		;le resto 30h = 48 para obtener el numero real
				xor cl,cl
				mov cl,01h		;decena se multipliaca por 10
				mul cl 	;multiplica al = cl*al
				xor cl,cl
				mov num1,0	;limipiamos num1
				mov num1,ax 	;le pasamos el valor actual
				xor ax,ax
				pop ax

				add ax,num1 	;entonces al actualmente tiene la suma de los dos valores.	
				mov num1,ax 	;le pasamos el valor verdaderoi a num1
				
				;finalmente tengo el numero en num1
				;mov bl,ah
				;ImpresionCaracter al
				;ImpresionCaracter bl

				;leercaracter
				jmp final

			CANT_2:
				mov al,number1[0]				
				sub al,30h 		;le resto 30h = 48 para obtener el numero real

				xor cl,cl
				mov cl,0ah		;centena se multipliaca por 10
				mul cl 	;multiplica al = cl*al
				xor cl,cl

				;hacemos lo mismo para la pocicion 2 solo que ahora es DECENA
				push ax ;guardamos el valor anterior
				xor ax,ax
				mov al,number1[1]
				sub al,30h 		;le resto 30h = 48 para obtener el numero real
				xor cl,cl
				mov cl,01h		;decena se multipliaca por 1
				mul cl 	;multiplica al = cl*al
				xor cl,cl
				mov num1,0	;limipiamos num1
				mov num1,ax 	;le pasamos el valor actual
				xor ax,ax
				pop ax

				add ax,num1 	;entonces al actualmente tiene la suma de los dos valores.	
				mov num1,ax 	;le pasamos el valor verdaderoi a num1

				;ImpresionCaracter al
				;leercaracter
				jmp final

			CANT_1:
				mov al,number1[0]
				sub al,30h 		;le resto 30h = 48 para obtener el numero real
				xor cl,cl
				mov cl,01h		;centena se multipliaca por 100
				mul cl 	;multiplica al = cl*al
				xor cl,cl

				mov num1,ax 	;le pasamos el valor verdaderoi a num1
			
				jmp final

				final:	
				
				pop cx
				pop di
				pop si
endm

TopPuntos macro bufferRegistro,bufferPuntos
	local BuscandoNombre,fincadena,Ordenando,PrimeraComa,SegundaComa_,SegundaComa,TerceraComa_,TerceraComa,Finlinea,tope,siguiente,finalizo,menorque10,mayorque10,norm
	
	Crear filePuntos,handlerPuntos
	tamnaotexto encabezado,SIZEOF encabezado
	Escribir handlerPuntos,si,encabezado
	Escribir handlerPuntos,1,SaltoLinea
	Escribir handlerPuntos,1,SaltoLinea

	print encaPuntos
	tamnaotexto encaPuntos,SIZEOF encaPuntos
	Escribir handlerPuntos,si,encaPuntos
	;print bufferRegistro
	;leercaracter
	mov contadorTop,0
	xor si,si
	xor di,di
	xor cx,cx	;inicio del usuario1
	xor bx,bx	;inicio del usuario2

	Ordenando:
		mov cx,32h 	;punteo maximo por un jugardor
		
		BuscandoNombre:

			cmp bufferRegistro[si],36
			je fincadena

			cmp bufferRegistro[si],44
			je PrimeraComa

			mov al,bufferRegistro[si]
			mov Nombreaux1[di],al
			inc di
			inc si
			jmp BuscandoNombre


			PrimeraComa:

				inc si
				mov al,bufferRegistro[si] 	;aqui esta el nivel
				mov NivelAux1[0],al

				SegundaComa_:

					inc si
					inc si
					xor di,di
				SegundaComa:
					cmp bufferRegistro[si],44 	;coma
					je TerceraComa_

					mov al,bufferRegistro[si]
					mov PunteoAux1[di],al
					inc di
					inc si
					jmp SegundaComa

					TerceraComa_:
						inc si
						xor di,di

						TerceraComa:
							cmp bufferRegistro[si],10 
							je Finlinea

							cmp bufferRegistro[si],36
							je fincadena

							mov al,bufferRegistro[si]
							mov TiempoAux1[di],al
							inc di
							inc si
							jmp TerceraComa

							Finlinea:

								; print Nombreaux1
								; print SaltoLinea
								; print NivelAux1
								; print SaltoLinea
								; print PunteoAux1
								; print SaltoLinea
								; print TiempoAux1
								; leercaracter

							parseToInt PunteoAux1,PuntosJugador

							xor ax,ax
							mov ax,PuntosJugador
							
							;ImpresionCaracter al
							;leercaracter
							;ImpresionCaracter cl
							;leercaracter
							
							cmp ax,cx
							je tope
							jmp Siguiente


							tope:

								add contadorTop,01h								
								cmp contadorTop,0Bh								
								je finalizo

								cmp contadorTop,10
								jb menorque10
								JMP mayorque10

								menorque10:
								add contadorTop,30h
								ImpresionCaracter contadorTop
								Escribir handlerPuntos,1,contadorTop
							    sub contadorTop,30h
								jmp norm

								mayorque10:
								 print diez
								 Escribir handlerPuntos,2,diez

								 norm:
								print punto
								Escribir handlerPuntos,1,punto
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print Nombreaux1
								push si
								tamnaotexto Nombreaux1,SIZEOF Nombreaux1
								Escribir handlerPuntos,si,Nombreaux1
								pop si
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print NivelAux1
								push si
								tamnaotexto NivelAux1,SIZEOF NivelAux1
								Escribir handlerPuntos,si,NivelAux1
								pop si
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print PunteoAux1
								push si
								tamnaotexto PunteoAux1,SIZEOF PunteoAux1
								Escribir handlerPuntos,si,PunteoAux1
								pop si
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print espacio
								Escribir handlerPuntos,1,espacio
								print TiempoAux1
								push si
								tamnaotexto TiempoAux1,SIZEOF TiempoAux1
								Escribir handlerPuntos,si,TiempoAux1
								pop si
								print SaltoLinea
								Escribir handlerPuntos,1,SaltoLinea
								

							siguiente:
								Limpiar Nombreaux1,SIZEOF Nombreaux1,024h
							 	Limpiar NivelAux1,SIZEOF NivelAux1,024h
							 	Limpiar PunteoAux1,SIZEOF PunteoAux1,024h
							 	Limpiar TiempoAux1,SIZEOF TiempoAux1,024h
							 	inc si
							 	;ImpresionCaracter bufferRegistro[si]
							 	;leercaracter
							 	xor di,di
							 	jmp BuscandoNombre
		fincadena:
			Limpiar Nombreaux1,SIZEOF Nombreaux1,024h
			Limpiar NivelAux1,SIZEOF NivelAux1,024h
			Limpiar PunteoAux1,SIZEOF PunteoAux1,024h
			Limpiar TiempoAux1,SIZEOF TiempoAux1,024h
			xor si,si
			xor di,di

			sub cx,01h
			cmp cx,00h
			je finalizo
			jmp  BuscandoNombre

			finalizo:
				Cerrar handlerPuntos
				leercaracter
				jmp MenuAdministrador
endm

TopTiempos macro bufferRegistro,bufferTiempos
	local BuscandoNombre,fincadena,Ordenando,PrimeraComa,SegundaComa_,SegundaComa,TerceraComa_,TerceraComa,Finlinea,tope,siguiente,finalizo,menorque10,mayorque10,norm
	
	Crear fileTiempo,handlertiempo
	tamnaotexto encabezado,SIZEOF encabezado
	Escribir handlertiempo,si,encabezado
	Escribir handlertiempo,1,SaltoLinea
	Escribir handlertiempo,1,SaltoLinea

	print encaTiempos
	tamnaotexto encaTiempos,SIZEOF encaTiempos
	Escribir handlertiempo,si,encaTiempos
	;print bufferRegistro
	;leercaracter
	mov contadorTop,0
	xor si,si
	xor di,di
	xor cx,cx	;inicio del usuario1
	xor bx,bx	;inicio del usuario2

	Ordenando:
		mov cx,1f4h 	;punteo maximo por un jugardor
		
		BuscandoNombre:

			cmp bufferRegistro[si],36
			je fincadena

			cmp bufferRegistro[si],44
			je PrimeraComa

			mov al,bufferRegistro[si]
			mov Nombreaux1[di],al
			inc di
			inc si
			jmp BuscandoNombre


			PrimeraComa:

				inc si
				mov al,bufferRegistro[si] 	;aqui esta el nivel
				mov NivelAux1[0],al

				SegundaComa_:

					inc si
					inc si
					xor di,di
				SegundaComa:
					cmp bufferRegistro[si],44 	;coma
					je TerceraComa_

					mov al,bufferRegistro[si]
					mov PunteoAux1[di],al
					inc di
					inc si
					jmp SegundaComa

					TerceraComa_:
						inc si
						xor di,di

						TerceraComa:
							cmp bufferRegistro[si],10 
							je Finlinea

							cmp bufferRegistro[si],36
							je fincadena

							mov al,bufferRegistro[si]
							mov TiempoAux1[di],al
							inc di
							inc si
							jmp TerceraComa

							Finlinea:

								; print Nombreaux1
								; print SaltoLinea
								; print NivelAux1
								; print SaltoLinea
								; print PunteoAux1
								; print SaltoLinea
								; print TiempoAux1
								; leercaracter

							parseToInt TiempoAux1,PuntosJugador

							xor ax,ax
							mov ax,PuntosJugador
							
							;ImpresionCaracter al
							;leercaracter
							;ImpresionCaracter cl
							;leercaracter
							
							cmp ax,cx
							je tope
							jmp Siguiente


							tope:

								add contadorTop,01h								
								cmp contadorTop,0Bh								
								je finalizo

								cmp contadorTop,10
								jb menorque10
								JMP mayorque10

								menorque10:
								add contadorTop,30h
								ImpresionCaracter contadorTop
								Escribir handlertiempo,1,contadorTop
							    sub contadorTop,30h
								jmp norm

								mayorque10:
								 print diez
								 Escribir handlertiempo,2,diez

								 norm:
								print punto
								Escribir handlertiempo,1,punto
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print Nombreaux1
								push si
								tamnaotexto Nombreaux1,SIZEOF Nombreaux1
								Escribir handlertiempo,si,Nombreaux1
								pop si
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print NivelAux1
								push si
								tamnaotexto NivelAux1,SIZEOF NivelAux1
								Escribir handlertiempo,si,NivelAux1
								pop si
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print PunteoAux1
								push si
								tamnaotexto PunteoAux1,SIZEOF PunteoAux1
								Escribir handlertiempo,si,PunteoAux1
								pop si
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print espacio
								Escribir handlertiempo,1,espacio
								print TiempoAux1
								print segg
								push si
								tamnaotexto TiempoAux1,SIZEOF TiempoAux1
								Escribir handlertiempo,si,TiempoAux1
								pop si
								Escribir handlertiempo,3,segg
								print SaltoLinea
								Escribir handlertiempo,1,SaltoLinea
								

							siguiente:
								Limpiar Nombreaux1,SIZEOF Nombreaux1,024h
							 	Limpiar NivelAux1,SIZEOF NivelAux1,024h
							 	Limpiar PunteoAux1,SIZEOF PunteoAux1,024h
							 	Limpiar TiempoAux1,SIZEOF TiempoAux1,024h
							 	inc si
							 	;ImpresionCaracter bufferRegistro[si]
							 	;leercaracter
							 	xor di,di
							 	jmp BuscandoNombre
		fincadena:
			Limpiar Nombreaux1,SIZEOF Nombreaux1,024h
			Limpiar NivelAux1,SIZEOF NivelAux1,024h
			Limpiar PunteoAux1,SIZEOF PunteoAux1,024h
			Limpiar TiempoAux1,SIZEOF TiempoAux1,024h
			xor si,si
			xor di,di

			sub cx,01h
			cmp cx,00h
			je finalizo
			jmp  BuscandoNombre

			finalizo:
				Cerrar handlertiempo
				leercaracter
				jmp MenuAdministrador
endm

.model small
;-------------------SEGMENTO DE PILA--------------------------
.stack
;-------------------SEGMENTO DE DATO--------------------------
.data
;----------------------------MENSAJES---------------------------------------------------
aqui db 10,13,'choco','$'
ErrorAbrir db 10,13,'Error al tratar de abrir el archivo.',10,13,'$'
ErrorCerrar db 10,13,'Error al tratar de cerrar el archivo.',10,13,'$'
ErrorLeer db 10,13,'No ha sido posible leer el archivo',10,13,'$'
ErrorCrear db 10,13,'No ha sido posible crear el archivo',10,13,'$'
ErrorEscribir db 10,13,'No ha sido posible Escribir el archivo',10,13,'$'

optionn db 10,13,'  Ingrese una opcion: ','$'
SaltoLinea db 10,13,'$'
encabezado db 10,13, '  UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',10,13,'  FACULTAD DE INGENIERIA', 10,13, '  ESCUELA DE CIENCIAS Y SISTEMAS',10,13, '  ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1 B',10,13, '  SEGUNDO SEMESTRE 2019',10,13, '  JUAN PABLO OSUNA DE LEON',10,13, '  201503911',10,13, '  TAREA PRACTICA 5','$'
encabezado1 db 10,13,10,13,'  ~~~~~~~~~~~~~~~~~',10,13,'  MENU PRINCIPAL ',10,13,'	',10,13,'  1. INGRESAR            ',10,13,'  2. REGISTRAR          ',10,13,'  3. SALIR             ',10,13,'$'
ingUser db 10,13,'  Ingrese Nombre de Usuario: ','$'
ingPass db 10,13,'  Ingrese Password: ','$'
userCreated db 10,13,'  Usuario creado Satisfactoriamente.',10,13,'$'
LoginError db 10,13,'Usuario o contrase',0a5h,'a incorrectos, intentelo de nuevo.',10,13,'$'
menuAdmin db 10,13,'  ~~~~~~~~~~~~~~~~~~~~~~~',10,13,'  BIENVENIDO ADMINISTRADOR',10,13,10,13,'  1) TOP 10 PUNTEOS',10,13,'  2) TOP 10 TIEMPOS',10,13,'  3) REGRESAR',10,13,'$'
time db 10,13,'Tiempo jugado: ','$'
puntos db 10,13,'puntos acumulados: ','$'
espacio db ' ','$'
punto db '.','$'
diez db '10','$'
segg db 'seg','$'
encaPuntos db 10,13,10,13,'        Top 10 Mejores Punteos ',10,13,'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',10,13,'$'
encaTiempos db 10,13,10,13,'        Top 10 Mayores Tiempos ',10,13,'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',10,13,'$'



;---------------------------ARCHIVOS-----------------------------------------

;=======================VARIABLES PARA ARCHIVOS---------------------------
handlerUsuarios dw ?
fileUsuarios db 'regUsu.txt',0
bufferUsuarios db 500 dup('$')

handlerRegistro dw ?
fileRegistro db 'Registro.txt',0
bufferRegistro db 500 dup('$')
coma db 44

handlerEntrada dw ?
rutaEntrada db 'entrada.txt',0	;RUTA DE LA ENTRADA

;-------------------------	VARIABLES-----------------------------------------
;posicion de inicio actual de la barra 
InicioPosActualBarra dw 0
FinBarra dw 0

;buffer para capturar nombre de usuario y contraseña.
login db 0
name_ db 10 dup('$')
password db 10 dup('$')
;buffer para verificar el registro.
name_reg db 10 dup('$')
pass_reg db 10 dup('$')
esAdmin db 0
admin db 'adminBI$','$'

;----------------------------VARIABLES PARA DIBUJAR LOS BLOQUES 
lineas dw 0				;sera determinado por el nivel, nivel 1 = 2,nivel 2 = 3, nivel 3 = 4
velocidadPelota dw 0
NivelActual dw ?
punetoActual dw ?

;variables para el encabezadfo del juego
centena db 0
decena db 0
unidad db 0
Hora    db 5 dup('$'),'$'          
Minuto  db 5 dup('$'),'$'
minaux db 0           
Segundo db 5 dup('$'),'$'
segaux db 0
inicioSeg db 0
inicioMin db 0
Dia     db 5 dup('$'),'$'  

segundosInicio db 0
minutosInicio db 0
segundosActual db 0
minutosActual db 0

segundostotalesInicio dw 0
tiempoTotalSegundos dw 0
timepoParaRegistro dw 0
tiempoNivel1 dw 0
tiempoNivel2 dw 0
tiempoNivel3 dw 0

;variables para reportes
bufferTiempos db 1000 dup('$')
bufferPuntos db 1000 dup('$')

PunteoAux1 db 3 dup('$'),'$'
TiempoAux1 db 3 dup('$'),'$'
Nombreaux1 db 10 dup('$')
NivelAux1 db 1 dup('$')

PunteoAux2 db 3 dup('$'),'$'
TiempoAux2 db 3 dup('$'),'$'
Nombreaux2 db 10 dup('$')
NivelAux2 db 1 dup('$')

PunteoMaximo db 45	
PuntosJugador dw 0	;numero real de puntos que llevo en hexa
contadorTop db 0	;indice para saber cuantos usuarios eh mostrado

handlertiempo dw ?
fileTiempo db 'Tiempo.rep',0

handlerPuntos dw ?
filePuntos db 'Puntos.rep',0
;===========================

;variables para validaciones de multiples pelotas
pelotasJuego db 0	;cantidad de pelotas en juego
estadop1 db 0
estadop2 db 0
estadop3 db 0
posicionPelota1 dw 59330 ;inicio de la pelota
posicionPelota2 dw 58330 ;inicio de la pelota
posicionPelota3 dw 59330 ;inicio de la pelota
moviminetoP1 db 1		;movimiento en el que me quede ID= 1, II =2, DD=3, Di=4
moviminetoP2 db 1
movimientoP3 db 0

vidas db 0	;vidas de pelotas activas

;-------------------SEGMENTO DE CODIGO------------------------
.code
main proc

	Inicio:
		print SaltoLinea		
		Abrir fileUsuarios,handlerUsuarios
		Leer handlerUsuarios,bufferUsuarios,SIZEOF bufferUsuarios	;lo leemos parea que el indice se quede en la ultima posicion
		
	MenuPrincipal:
		ModoTexto	

		print encabezado
		print encabezado1
		print optionn

		;--------OBTENIENDO EL NUMERO ESCOGIDO------------------------
		getChar
		print SaltoLinea
		cmp al,'1'; COMPARO CON EL ASCII DEL NUMERO 1 QUE ES 49 Y EN HEXA 31H
		je Opcion1
		cmp al,'2'; COMPARO CON EL ASCII DEL NUMERO 1 QUE ES 49 Y EN HEXA 31H
		je Opcion2
		cmp al,'3'
		je Salir
		jmp MenuPrincipal

	Opcion1:
		Cerrar handlerUsuarios
		Abrir fileUsuarios,handlerUsuarios
		Leer handlerUsuarios,bufferUsuarios,SIZEOF bufferUsuarios
		;Cerrar handlerUsuarios

		; los usuarios estan almacenados en bufferUsuarios

		Limpiar name_,SIZEOF name_,024h
		Limpiar password,SIZEOF password,024h

		print ingUser
		getTexto name_
		print ingPass
		getTexto password
		print SaltoLinea
		;varificacion de usuario
		BuscarUsuario bufferUsuarios,name_,password
		;SI REGRESA ACA SIGNIFICA QUE EL USUARIO SI EXISTE Y SE LOGUEO DE MANERA CORRECTA, DE CASO CONTRARIO DE UNA VEZ SaltoLineaARA A MENU PRINCIPAL

		cmp esAdmin,1
		jne UserNormal

		MenuAdministrador:
			mov esAdmin,0	;regreso al estado cero
			print SaltoLinea
			print menuAdmin
			print optionn

			getChar
			print SaltoLinea
			cmp al,'1'; COMPARO CON EL ASCII DEL NUMERO 1 QUE ES 49 Y EN HEXA 31H
			je Top10Puntos
			cmp al,'2'; COMPARO CON EL ASCII DEL NUMERO 1 QUE ES 49 Y EN HEXA 31H
			je Top10Tiempos
			cmp al,'3'
			je MenuPrincipal

			Top10Tiempos:
				Abrir fileRegistro,handlerRegistro
				Leer handlerRegistro,bufferRegistro,SIZEOF bufferRegistro	;lo leemos parea que el indice se quede en la ultima posicion
				Cerrar handlerRegistro

				TopTiempos bufferRegistro,bufferTiempos
				jmp MenuPrincipal

			Top10Puntos:
				Abrir fileRegistro,handlerRegistro
				Leer handlerRegistro,bufferRegistro,SIZEOF bufferRegistro	;lo leemos parea que el indice se quede en la ultima posicion
				Cerrar handlerRegistro
				
				TopPuntos bufferRegistro,bufferPuntos
				jmp MenuPrincipal

		UserNormal:
			;los datos del usuario estan en name_ y password
			NIVEL1
			PASAMOSNIVEL2:
				NIVEL2
				PASAMOSNIVEL3:
					NIVEL3

			INSERTARUSUARIO:
				ModoTexto
				;aqui insertaremos el usuario-nivel-punteo-tiempo  de cada usuario que termine o pierda el 
				Abrir fileRegistro,handlerRegistro
				Leer handlerRegistro,bufferRegistro,SIZEOF bufferRegistro	;lo leemos parea que el indice se quede en la ultima posicion
				
				tamnaotexto name_,SIZEOF name_
				Escribir handlerRegistro,si,name_
				
				add NivelActual,30h 	;le sumo 30h para mostrar el contenido
				;add ax,30h
				Escribir handlerRegistro,1,coma
				Escribir handlerRegistro,1,NivelActual
				sub NivelActual,30h 	;regreso al valor real
				Escribir handlerRegistro,1,coma
				ConvertirBCD punetoActual
				Escribir handlerRegistro,1,centena
				Escribir handlerRegistro,1,decena
				Escribir handlerRegistro,1,unidad
				Escribir handlerRegistro,1,coma
				ConvertirBCD timepoParaRegistro 	;contiene el timempo acumulado
				Escribir handlerRegistro,1,centena
				Escribir handlerRegistro,1,decena
				Escribir handlerRegistro,1,unidad
				Escribir handlerRegistro,1,SaltoLinea

				;vacio registros
				mov timepoParaRegistro,0
				mov NivelActual,0
				mov punetoActual,0
				Limpiar name_,SIZEOF name_,024h
				Limpiar password,SIZEOF password,024h

				Cerrar handlerRegistro


		ModoTexto
		jmp MenuPrincipal

	Opcion2:
		print ingUser
		getTexto name_
		print ingPass
		getTexto password
		print SaltoLinea

		tamnaotexto name_,SIZEOF name_
		Escribir handlerUsuarios,si,name_
		Escribir handlerUsuarios,1,coma
		tamnaotexto password,SIZEOF password
		Escribir handlerUsuarios,si,password
		Escribir handlerUsuarios,1,SaltoLinea
		print userCreated 
		leercaracter

		jmp MenuPrincipal

	ERROR1:
		print ErrorAbrir
		leercaracter
		jmp MenuPrincipal
	ERROR2:
		print ErrorCerrar
		leercaracter
		jmp MenuPrincipal
	ERROR3:
		print ErrorLeer
		leercaracter
		jmp MenuPrincipal
	ERROR4:
		print ErrorCrear
		leercaracter
		jmp MenuPrincipal
	ERROR5:
		print ErrorEscribir 
		leercaracter
		jmp MenuPrincipal

	Salir:
		mov ah, 4ch
		mov al, 00h
		int 21h
main endp ;Termina proceso
end main