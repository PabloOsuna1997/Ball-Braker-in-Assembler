;=================================AREA GRAFICA=======================================================
PintarBloques macro filas 		;reccibira como parametro las filas, esto dependera de cada nivel 
	LOCAL anchoBloque,Bloque,Fin
	
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
		mov [di],dl ;color de los cubos
		mov [di+320],dl
		mov [di+640],dl
		mov [di+960],dl
		mov [di+1280],dl
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
	mov di,8050

	push ax
	sumo:
		cmp ax,0
		je sigo
		add di,4800 	;le sumo las 5 filas ocupadas por el bloque anterior mas 10 pixeles de esapacio vertical
		dec ax
		jmp sumo

	sigo:
		pop ax
		xor si,si
		jmp anchoBloque

	Fin:
endm

PintarMargen macro color
	mov dl, color

	;empieza en pixel (i,j) = (20,0) = 20*320+0 = 6400
	;barra horizontal superior
	mov di,6405
	Primera:
	mov [di],dl
	inc di
	cmp di,6714
	jne Primera

	;barra horizontal inferior
	;empieza en pixel (i,j) = (190,0) = 190 * 320 + 0 = 60800
	mov di,60805
	Segunda:
	mov [di],dl
	inc di
	cmp di, 61114
	jne Segunda

	;barra vertical izquierda
	mov di, 6405
	Tercera:
	mov [di], dl
	add di,320
	cmp di,60805
	jne Tercera

	;barra vertical derecha
	mov di,6714
	Cuarta:
	mov [di], dl
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
	mov FinBarra,di
	add FinBarra,50

	Largo:
	mov [di],dl
	mov [di+320],dl
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
	mov [di],dl
	mov [di+320],dl
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

	mov [di],dl
	mov [di+1], dl
	mov [di+2], dl

	mov [di+320], dl
	mov [di+321], dl
	mov [di+322], dl

	mov [di+640], dl
	mov [di+641], dl
	mov [di+642], dl

	pop dx
endm

printGrafico macro cadena
	push ds
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

MostrarEncabezado macro
	LOCAL Seguir,Otro,Saltar,Saltar2,pri,noes

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
	;capturo el tiempo en el que se actual
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
	sub ax,segundostotalesInicio
	mov tiempoTotalSegundos,ax

	;ConvertToString2 tiempo
	ConvertirBCD tiempoTotalSegundos
	ImpresionCaracter centena
	ImpresionCaracter decena
	ImpresionCaracter unidad

	ImpresionCaracter 13
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

;==========================FIN AREA GRAFICA=======================================================

tamnaotexto macro buffer,numerocaracteres
	LOCAL Repetir,dolar
	xor si,si
	mov cx,numerocaracteres
	Repetir:
		cmp buffer[si],36
		je dolar
		inc si
		Loop Repetir
	dolar:
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
	mov ah,40h
	mov bx,handle
	mov cx,numBytes
	lea dx,buffer
	int 21h
	jc Error5
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

ModoVideo macro
	mov ah,00h
	mov al,13h
	int 10h
	mov ax, 0A000h
	mov ds, ax  ; DS = A000h (memoria de graficos).
endm

ModoTexto macro
	mov ah,00h
	mov al,03h
	int 10h
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

ImpresionCaracter macro caracter
	push dx
	push ax
	mov ah,02h
	mov dl,caracter
	int 21h
	pop ax
	pop dx
endm

leertecla macro 
	LOCAL off,VerificarTecla,Derecha,Izquierda,Nosepuede,Nosepuede1
	push ax
	;xor ax,ax
	mov ah,01h
	int 16h ;verificar si hay tecla lista para ser leida
	jz off
	mov ah,00h
	int 16h ;leer la tecla

	cmp ah,1 ;si es el boton ESC
	jne VerificarTecla

	VerificarTecla:

		cmp ah,77
		je Derecha 	;la flecha derecha responde a la letra M 

		cmp ah,75
		je Izquierda 	;la flecha derecha responde a la letra K

		cmp al,51
		je MenuPrincipal

		cmp ah,1 ;si es otro ESC
		je off

		Derecha:
			push di
			push dx
			mov di,InicioPosActualBarra
			mov dl,[di+65] 	;inicio de la barra las 50 de largo mas 5 de incrtemento
			cmp dl,5
			je Nosepuede1
			pop dx
			pop di

			borrarBarra
			add InicioPosActualBarra,05h
			PintarBarra
			jmp off

			Nosepuede1:
				pop dx
				pop di
				jmp off
		Izquierda:
			;verifico si puedo moverla 
			push di
			push dx
			mov di,InicioPosActualBarra
			mov dl,[di-5]
			cmp dl,5
			je Nosepuede
			pop dx
			pop di

			borrarBarra
			sub InicioPosActualBarra,05h 	;muevo de 5 en  5 cada vez que acciono la tecla
			PintarBarra
			jmp off

			Nosepuede:
				pop dx
				pop di
	off:
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

					cmp buffer[si],10 	;si viene salto de linea es que se acabo la password
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

			Diferentes:		;si es diferente saltamos hasta el siguiente usuario
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
;NIVEL 1
NIVEL1 macro
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
	mov segundostotalesInicio,ax
	ImpresionCaracter 10	;imprimo un salto de linea nose porque si no hay instruccion despues no guarda el valor

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

	mov dx,35360	;(i,j) = (110,160) = 110*320 + 160 	;inicio de la pelota

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
		
		mov bl,[di]	;color del margen
		cmp bl,0
		jne auxdd
		
		sub di,02h
		pintarPelota dx, 2
		Delay 250
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
		xor bl,bl
		xor di,di
		mov di,dx
		add di,642
		mov bl,[di]	;color del margen
		cmp bl,0
		jne Analisis_DecrementoDerecha

		pintarPelota dx, 2
		Delay 250
		jmp DecrementoDerecha

		Analisis_DecrementoDerecha:

			cmp bl,11
			je marg3 	;color de la barra
			;analisis de que direccion debe tomar.
			add di,320 		; si al sumarle una linea es negro otravez es porque es la linea inferior
			cmp di,60800	;si es menor a la 60800 significa que topo en la cualquier otra linea menos la inferios
			ja perdiodd

			jmp auxdi

			perdiodd:
				;mostrar puntos y tiempo y actualizar
				jmp MenuPrincipal
			
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
		add di,640
		mov bl,[di]	;color del margen
		cmp bl,0
		jne Analisis_DecrementoIzquierda

		pintarPelota dx, 2
		Delay 250
		jmp DecrementoIzquierda

		Analisis_DecrementoIzquierda:
			 cmp bl,11
			 je marg2 	;color de la barra
			 ;analisis de que direccion debe tomar.
			 add di,320 ; si al sumarle una linea es negro otravez es porque es la linea inferior

			 cmp di,60800	;si es menor a la 60800 significa que topo en la linea superior
			 ja perdiodi

			 jmp auxdd
			
			perdiodi:
				;mostrar puntos y tiempo y actualizar
				jmp MenuPrincipal
	
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
		xor bl,bl
		xor di,di
		mov di,dx
		mov bl,[di]	;color del margen
		cmp bl,0
		jne Analisis_IncrementoIzquierda

		pintarPelota dx, 2
		Delay 250
		jmp IncrementoIzquierda

		Analisis_IncrementoIzquierda:
			 ;analisis de que direccion debe tomar.
			 sub di,320 ; si al restarle una linea es negro otravez es porque es la linea superior
			 cmp di,6400	;si es menor a la 6400 significa que topo en la linea superior
			 jb auxdi

			 jmp auxid

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
		mov di,dx
		add di,02h

		mov bl,[di]	;color del margen
		cmp bl,0
		jne Analisis_IncrementoDerecha
		
		sub di,02h

		pintarPelota dx, 2
		Delay 250
		jmp IncrementoDerecha

		Analisis_IncrementoDerecha:
			 ;analisis de que direccion debe tomar.
			 sub di,320 ; si al restarle una linea es negro otravez es porque es la linea superior
			 cmp di,6400	;si es menor a la 6400 significa que topo en la linea superior
			 jb auxdd

			 jmp auxii
endm

ValidarChoque macro NoLineas

	local sumo,sigo,Comparo,RevisoBloque,Choco,SigBloque,NohayBloque_sig,finval,finval2,limpiaar
	push dx

	xor cx,cx
	xor si,si
	xor bx,bx
	xor ax,NoLineas

	mov di,8050	;posicion inicial de mis bloques

	Comparo:
		push di 	;guardo la posicion inicial del bloque
		
		mov dl,[di]
		cmp dl,0
		je NohayBloque_sig
		
		cmp dl,14
		jne finval 	;si es diferente al color de mis bloques es porque toco margen

		mov cx,40	;ancho de mis bloques 

		RevisoBloque:
			mov dl,[di-320] ;arriba
			cmp dl,2
			je Choco

			mov dl,[di-1] ;fila 0 izquierda
			cmp dl,2
			je Choco
			
			mov dl,[di+1] ;fila 0 derecha
			cmp dl,2
			je Choco

			mov dl,[di+319] ;fila 1 izquierda
			cmp dl,2
			je Choco

			mov dl,[di+321] ;fila 1 derecha
			cmp dl,2
			je Choco

			mov dl,[di+639] ;fila 2 izquierda
			cmp dl,2
			je Choco

			mov dl,[di+641] ;fila 2 derecha
			cmp dl,2
			je Choco

			mov dl,[di+959] ;fila 3 izquierda
			cmp dl,2 
			je Choco

			mov dl,[di+961] ;fila 3 derecha
			cmp dl,2 
			je Choco

			mov dl,[di+1279] ;fila 4 izquierda
			cmp dl,2
			je Choco

			mov dl,[di+1281] ;fila 4 derecha
			cmp dl,2
			je Choco

			mov dl,[di+1600] ;fila 5 abajo
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
					mov [di],dl
					mov [di+320],dl
					mov [di+640],dl
					mov [di+960],dl
					mov [di+1280],dl
					inc di
					Loop limpiaar
					add punetoActual,01h
					jmp finval2

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
			pop dx
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
salt db 10,13,'$'
enc0 db 10,13, '  UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',10,13,'  FACULTAD DE INGENIERIA', 10,13, '  ESCUELA DE CIENCIAS Y SISTEMAS',10,13, '  ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1 B',10,13, '  SEGUNDO SEMESTRE 2019',10,13, '  JUAN PABLO OSUNA DE LEON',10,13, '  201503911',10,13, '  TAREA PRACTICA 5','$'
enc1 db 10,13,10,13,'  ~~~~~~~~~~~~~~~~~',10,13,'  MENU PRINCIPAL ',10,13,'	',10,13,'  1. INGRESAR            ',10,13,'  2. REGISTRAR          ',10,13,'  3. SALIR             ',10,13,'$'
ingUser db 10,13,'  Ingrese Nombre de Usuario: ','$'
ingPass db 10,13,'  Ingrese Password: ','$'
userCreated db 10,13,'  Usuario creado Satisfactoriamente.',10,13,'$'
LoginError db 10,13,'Usuario o contrase',0a5h,'a incorrectos, intentelo de nuevo.',10,13,'$'
menuAdmin db 10,13,'  ~~~~~~~~~~~~~~~~~~~~~~~',10,13,'  BIENVENIDO ADMINISTRADOR',10,13,10,13,'  1) TOP 10 PUNTEOS',10,13,'  2) TOP 10 TIEMPOS',10,13,'  3) REGRESAR',10,13,'$'
time db 10,13,'Tiempo jugado: ','$'
puntos db 10,13,'puntos acumulados: ','$'

;---------------------------ARCHIVOS-----------------------------------------

;=======================VARIABLES PARA ARCHIVOS---------------------------
handlerUsuarios dw ?
fileUsuarios db 'regUsu.txt',0
bufferUsuarios db 500 dup('$')
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

primeravez db 0
;-------------------SEGMENTO DE CODIGO------------------------
.code
main proc

	Inicio:
		print salt		
		Abrir fileUsuarios,handlerUsuarios
		Leer handlerUsuarios,bufferUsuarios,SIZEOF bufferUsuarios	;lo leemos parea que el indice se quede en la ultima posicion
		
	MenuPrincipal:
		ModoTexto		
		;--------MOSTRANDO EL MENU PRINCIPAL--------------------------
		
		;AH = 2ch: Leer hora del sistema(CH=hora; CL=min; DH=seg)
	; mov ah,2ch
	; int 21h
	; mov segundos,dh
	; mov minutos,cl
	; xor ah,ah
	; mov al,minutos
	; mov cx,60
	; mul cx
	; mov cl,segundos
	; xor ch,ch
	; add ax,cx
	; mov segun,ax 	;guardamos los segundos en el que se inicio el nivel 1

	; ConvertirBCD segun
	; ImpresionCaracter centena
	; ImpresionCaracter decena
	; ImpresionCaracter unidad

		print enc0
		print enc1
		;print salt
		print optionn

		;--------OBTENIENDO EL NUMERO ESCOGIDO------------------------
		getChar
		print salt
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
		print salt
		;varificacion de usuario
		BuscarUsuario bufferUsuarios,name_,password
		;SI REGRESA ACA SIGNIFICA QUE EL USUARIO SI EXISTE Y SE LOGUEO DE MANERA CORRECTA, DE CASO CONTRARIO DE UNA VEZ SALTARA A MENU PRINCIPAL

		cmp esAdmin,1
		jne UserNormal

		MenuAdministrador:
			mov esAdmin,0	;regreso al estado cero
			print salt
			print menuAdmin
			print optionn

			getChar
			print salt
			cmp al,'1'; COMPARO CON EL ASCII DEL NUMERO 1 QUE ES 49 Y EN HEXA 31H
			je Top10Puntos
			cmp al,'2'; COMPARO CON EL ASCII DEL NUMERO 1 QUE ES 49 Y EN HEXA 31H
			je Top10Tiempos
			cmp al,'3'
			je MenuPrincipal

			Top10Tiempos:
			Top10Puntos:

		UserNormal:
			;DEBO VERIFICAR EN QUE NIVEL VA EL USUARIO
			NIVEL1

		getChar
		ModoTexto
		jmp MenuPrincipal

	Opcion2:
		print ingUser
		getTexto name_
		print ingPass
		getTexto password
		print salt

		tamnaotexto name_,SIZEOF name_
		Escribir handlerUsuarios,si,name_
		Escribir handlerUsuarios,1,coma
		tamnaotexto password,SIZEOF password
		Escribir handlerUsuarios,si,password
		Escribir handlerUsuarios,1,salt
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