; example.asm - пример простейших начальных установок входа
		;в графический режим
	.model  small
	.stack 100

	x1 equ 0	; координата точки по x
	y1 equ 50		; координа точки по y

	color equ 2		; цвет точки.

	.data
	delt dw ?
	y dw ?
	x dw ?
	y_draw dw ?
	x_draw dw ?
	deltx dw ?
	delty dw ?
	y2 dw ?
	x2 dw ?
	y_line dw ?
	x_line dw ?
	y2_line dw ?
	x2_line dw ?
	.code
	jmp main

	draw_point:
	;pop di
	;push di
	mov di, y_draw		; если нечетная строка - то начальный адрес 2000h
	and di, 1
	mov cl, 13
	shl di, cl

	;s = (y/2)*80 + x/4
	;pop ax
	mov ax, y_draw
	mov cl, 1
	shr ax, cl ; y/2
	mov bx, ax
	mov cl, 4
	shl ax, cl	; y/2 * 16
	mov cl, 6
	shl bx, cl	; y/2 * 64
	add ax, bx	; y/2 * 16 + y/2 * 64 = y/2 * 80
	add di, ax		; добавляем к смещению смещение к заданной строке

	;x/4
	;pop ax
	;push ax
	mov ax, x_draw
	mov cl, 2
	shr ax, cl
	add di, ax		; находим адрес нужного байта
	;в di храниться смещение

	mov al, color
	mov cl, 2
	ror al, cl

	;pop cx
	mov cx, x_draw
	and cl, 3
	ror al, cl
	ror al, cl

	or al, es:[di]
	mov  es:[di],al
	ret


	faind_point:
	mov di, y_draw		; если нечетная строка - то начальный адрес 2000h
	and di, 1
	mov cl, 13
	shl di, cl

	;s = (y/2)*80 + x/4
	;pop ax
	mov ax, y_draw
	mov cl, 1
	shr ax, cl ; y/2
	mov bx, ax
	mov cl, 4
	shl ax, cl	; y/2 * 16
	mov cl, 6
	shl bx, cl	; y/2 * 64
	add ax, bx	; y/2 * 16 + y/2 * 64 = y/2 * 80
	add di, ax		; добавляем к смещению смещение к заданной строке

	;x/4
	;pop ax
	;push ax
	mov ax, x_draw
	mov cl, 2
	shr ax, cl
	add di, ax		; находим адрес нужного байта
	;в di храниться смещение
	ret


;---------------------------------------------------

	main:
	mov	ax, 4h	;инициализация графического
	int	10h				;режима
	mov     ah,0bh          ;установить палитру
    mov     bh,01           ;передний план
    mov     bl,00           ;0 (зеленый, красный, корич.)
    int     10h
;---------------------------------------------------

	mov	ax, 0b800h	;загрузка адреса начала
	mov es,ax				;видеопамяти в

	mov y, y1
	mov x, x1
	mov delt, 0

;---------------------------------------------------
;--------------начало рисования дуги----------------
;---------------------------------------------------
	mov y_draw, y1
	mov x_draw, x1
	jmp draw_arc
	;jmp draw_point

	myif_arc:
	mov ax, x
	mov bx, y1
	shr bx, 1
	add bx, 10
	cmp ax, bx
	jge next


	inc x
	mov ax, delt
	add ax, x
	mov delt, ax

	mov ax, delt
	mov bx, y
	shr bx, 1
	cmp ax, bx
	jl draw_arc

	mov ax, delt
	sub ax, y
	mov delt, ax
	dec y


	draw_arc:
	;рисуются сразу 4 дуги
	mov ax, x
	add ax, 100
	mov x_draw, ax
	mov ax, 60
	sub ax, y
	mov y_draw, ax
	call draw_point

	mov ax, 38
	add ax, y
	mov y_draw, ax
	call draw_point

	mov ax, 100
	sub ax, x
	mov x_draw, ax
	call draw_point

	mov ax, 60
	sub ax, y
	mov y_draw, ax
	call draw_point
	jmp myif_arc


;---------------------------------------------------
;------------рисование линий------------------------
;---------------------------------------------------
	next:
	mov ax, y_draw
	mov y, ax
	mov y_line, ax
	add ax, 14
	mov y2, ax
	mov ax, x_draw
	mov x, ax
	mov x_line, ax
	add ax, 33
	mov x2, ax



	mov ax, x2
	sub ax, x
	and ax, 0ffffh
	mov deltx, ax

	mov ax, y2
	sub ax, y
	and ax, 0ffffh
	mov delty, ax
	;d0 = 2dy - dx
	mov ax, delty
	mov cl, 1
	shl ax, cl
	sub ax, deltx
	mov delt, ax
	mov ax, x
	mov x_draw, ax
	mov ax, y
	mov y_draw, ax
	call draw_point

	mov ax, y2
	sub ax, y
	add ax, 20
	mov bx, y2
	add bx, ax
	mov y_draw, bx
	call draw_point

	my_if_line:
	mov ax, x
	cmp ax, x2
	jge next_line


	mov ax, x
	inc ax
	mov x, ax


	;if(di-1 >= 0)
	mov ax, delt
	cmp ax, 00
	jl else_point

	;yi = yi-1 + 1
	mov ax, y
	inc ax
	mov [y], ax
	;di = di-1 +2(dy - dx)
	mov ax, delty
	sub ax, deltx
	mov cl, 1
	shl ax, cl
	add ax, delt
	mov delt, ax

	mov ax, x
	mov x_draw, ax
	mov ax, y
	mov y_draw, ax
	call draw_point

	mov ax, y2
	sub ax, y
	add ax, 20
	mov bx, y2
	add bx, ax
	mov y_draw, bx
	call draw_point

	else_point:
	;di = di-1 + 2dy
	mov ax, delty
	mov cl, 1
	shl ax, cl
	add ax, delt
	mov delt, ax

	mov ax, x
	mov x_draw, ax
	mov ax, y
	mov y_draw, ax
	call draw_point

	mov ax, y2
	sub ax, y
	add ax, 20
	mov bx, y2
	add bx, ax
	mov y_draw, bx
	call draw_point

	jmp my_if_line


;---------------------------------------------------
;-------------рисование линии-----------------------
;-------------пересекающей букву--------------------
;---------------------------------------------------
	next_line:

	mov ax, y_line
	add ax, 10
	mov y2_line, ax
	mov ax, x_line
	add ax, 75
	mov x2_line, ax

	mov ax, x2_line
	sub ax, x_line
	add ax, 0ffffh
	mov deltx, ax

	mov ax, y2_line
	sub ax, y_line
	add ax, 0ffffh
	mov delty, ax
	;d0 = 2dy - dx
	mov ax, delty
	mov cl, 1
	shl ax, cl
	sub ax, deltx
	mov delt, ax

	mov ax, 140
	sub ax, x_line
	add ax, 60
	mov x_draw, ax
	mov ax, y_line
	mov y_draw, ax
	call draw_point


	my_if_line2:
	mov ax, x_line
	cmp ax, x2_line
	jge filling


	mov ax, x_line
	inc ax
	mov x_line, ax


	;if(di-1 >= 0)
	mov ax, delt
	cmp ax, 00
	jl else_point2

	;yi = yi-1 + 1
	mov ax, y_line
	inc ax
	mov y_line, ax
	;di = di-1 +2(dy - dx)
	mov ax, delty
	sub ax, deltx
	mov cl, 1
	shl ax, cl
	add ax, delt
	mov delt, ax


	mov ax, 140
	sub ax, x_line
	add ax, 60
	mov x_draw, ax
	mov ax, y_line
	mov y_draw, ax
	call draw_point

	else_point2:
	;di = di-1 + 2dy
	mov ax, delty
	mov cl, 1
	shl ax, cl
	add ax, delt
	mov delt, ax

	mov ax, 140
	sub ax, x_line
	add ax, 60
	mov x_draw, ax
	mov ax, y_line
	mov y_draw, ax
	call draw_point

	jmp my_if_line2

;---------------------------------------------------
;---------------------------------------------------
;------------------закраска области-----------------
;---------------------------------------------------

	filling:
	mov y_draw, 0

	filling_loop1:
	mov x_draw, 0


	filling_loop:
	inc y_draw
	mov ax, y_draw
	cmp ax, 32
	jg exit
	;jmp filling_loop

	find_in_line:
	inc x_draw
	mov ax, x_draw
	cmp ax, 320
	jge filling_loop1

	call faind_point
	mov al, es:[di]
	cmp al, 0
	je find_in_line


	test1:
	mov al, es:[di]
	and al, 11000000b
	cmp al, 0
	jne draw1_left

	mov al, es:[di]
	and al, 110000b
	cmp al, 0
	jne draw2_left

	mov al, es:[di]
	and al, 1100b
	cmp al, 0
	jne draw3_left


	my_draw:
	mov ax, x_draw
	add ax, 4
	mov x_draw, ax

	my_draw_loop:
	call faind_point
	mov al, 0aah
	mov es:[di], al

	mov ax, x_draw
	add ax, 4
	mov x_draw, ax


	call faind_point
	mov al, es:[di]
	cmp al, 0
	je my_draw_loop


	mov al, es:[di]
	and al, 11b
	cmp al, 0
	jne draw1_right

	mov al, es:[di]
	and al, 1100b
	cmp al, 0
	jne draw2_right

	mov al, es:[di]
	and al, 110000b
	cmp al, 0
	jne draw3_right


	jmp filling_loop1



	draw1_right:
	mov al, 0aah
	mov es:[di], al
	jmp filling_loop1

	draw2_right:
	mov al, 0a8h
	mov es:[di], al
	jmp filling_loop1

	draw3_right:
	mov al, 0a0h
	mov es:[di], al
	jmp filling_loop1



	draw1_left:
	mov al, 0aah
	mov es:[di], al
	jmp my_draw

	draw2_left:
	mov al, 02ah
	mov es:[di], al
	jmp my_draw


	draw3_left:
	mov al, 0ah
	mov es:[di], al
	jmp my_draw

;---------------------------------------------------
	exit:

	xor	ax, ax
	int	16h

	mov ax, 3h
	int 10h

	mov ax,4c00h
	int 21h

	end main
