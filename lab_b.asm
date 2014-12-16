	.model  small
	.stack 100

	x1 equ 0
	y1 equ 50

.data
	y dw ?
	x dw ?
	y_pixel dw ?
	x_pixel dw ?
	deltx dw ?
	delty dw ?
	y2 dw ?
	x2 dw ?
	y1_l dw ?
	x1_l dw ?
	y2_l dw ?
	x2_l dw ?
	delt dw ?

.code
	jmp main

	putpixel:
	; определение является строка четной или нечетной
	mov di, y_pixel
	and di, 1
	mov cl, 13		; для нечетной добавить 2000H к адресу
	shl di, cl

	;S = (Ydiv2)*80 + Xdiv4
	mov ax, y_pixel
	mov cl, 1
	shr ax, cl ; Ydiv2
	mov bx, ax
	mov cl, 4
	shl ax, cl	; Ydiv2 * 16
	mov cl, 6
	shl bx, cl	; Ydiv2 * 64
	add ax, bx	; Ydiv2 * 16 + Ydiv2 * 64 = Ydiv2 * 80
	add di, ax

	mov ax, x_pixel
	mov cl, 2
	shr ax, cl
	add di, ax		; Xdiv4

	mov al, 2	; цвет точки красный
	mov cl, 2
	ror al, cl

	mov cx, x_pixel	;битовое смещение
	and cl, 3
	ror al, cl
	ror al, cl

	or al, es:[di]	; загрузка старого значений в байте
	mov  es:[di],al ; помещение байта в память адаптера
	ret


	checkpixel:
	mov di, y_pixel
	and di, 1
	mov cl, 13
	shl di, cl

	mov ax, y_pixel
	mov cl, 1
	shr ax, cl
	mov bx, ax
	mov cl, 4
	shl ax, cl
	mov cl, 6
	shl bx, cl
	add ax, bx
	add di, ax

	mov ax, x_pixel
	mov cl, 2
	shr ax, cl
	add di, ax
	ret

	main:
	mov	ax, 4h	;режим CGA color 320x200
	int	10h
	mov ah,0Bh          ;смена палитры на
  mov bh,01           ;(зеленый, красный, корич.)
  mov bl,00
  int 10h

	mov	ax, 0B800h	;загрузка адреса начала видеопамяти
	mov es,ax

	mov y, y1
	mov x, x1
	mov delt, 0

	mov y_pixel, y1
	mov x_pixel, x1
	jmp draw_circle

	circle_cond:
	mov ax, x
	mov bx, y1
	shr bx, 1
	add bx, 10
	cmp ax, bx
	jge draw_line

	inc x
	mov ax, delt
	add ax, x
	mov delt, ax

	mov ax, delt
	mov bx, y
	shr bx, 1
	cmp ax, bx
	jl draw_circle

	mov ax, delt
	sub ax, y
	mov delt, ax
	dec y


	draw_circle:
	mov ax, x
	add ax, 100
	mov x_pixel, ax
	mov ax, 130
	sub ax, y
	mov y_pixel, ax
	call putpixel

	mov ax,y
  add ax,100
	mov x_pixel, ax
	mov ax,x
	add ax,130
	mov y_pixel, ax
	call putpixel

	mov ax,130
	sub ax,x
	mov y_pixel, ax
	call putpixel

	mov ax, x
	add ax, 100
	mov x_pixel, ax
	mov ax, 130
	add ax, y
	mov y_pixel, ax
	call putpixel

	mov ax, 100
	sub ax, x
	mov x_pixel, ax
  call putpixel

	mov ax, 58
	sub ax, x
	mov x_pixel, ax
	call putpixel

	mov ax, x
	add ax, 120
	mov x_pixel, ax
	mov ax, 80
	sub ax, y
	mov y_pixel, ax
	call putpixel

	mov ax, 190
	sub ax, x
	mov x_pixel, ax
	mov ax, 10
	add ax, y
	mov y_pixel, ax
	call putpixel

	jmp circle_cond

	draw_line:

	mov y1_l, 30
	mov y2_l, 180
	mov x1_l, 58
	mov x2_l, 103

	mov ax, x2_l
	sub ax, x1_l
	add ax, 0ffffh
	mov deltx, ax
	; dx = |x2-x1|

	mov ax, y2_l
	sub ax, y1_l
	add ax, 0ffffh
	mov delty, ax
	; dy = |y2-y1|

	;d0 = 2dx - dy
	mov ax, deltx
	mov cl, 1
	shl ax, cl
	sub ax, delty
	mov delt, ax

	mov ax, x1_l
	mov x_pixel, ax
	mov ax, y2_l
	mov y_pixel, ax
	call putpixel


	inc_cond:
	; если y1 = y1 конец линии
	mov ax, y2_l
	cmp ax, y1_l
	jle filling

  ; y2 - 1
	mov ax, y2_l
	dec ax
	mov y2_l, ax

	;d(i-1) < 0
	mov ax, delt
	cmp ax, 00
	jl noninc_cond

  ;иначе
	;x(i) = x(i-1) + 1
	mov ax, x1_l
	inc ax
	mov x1_l, ax
	;d(i) = d(i-1) +2(dx - dy)
	mov ax, deltx
	sub ax, delty
	mov cl, 1
	shl ax, cl
	add ax, delt
	mov delt, ax

	mov ax, x1_l
	mov x_pixel, ax
	mov ax, y2_l
	mov y_pixel, ax
	call putpixel

	noninc_cond:
	;d(i) = d(i-1) + 2dx
	mov ax, deltx
	mov cl, 1
	shl ax, cl
	add ax, delt
	mov delt, ax

	mov ax, x1_l
	mov x_pixel, ax
	mov ax, y2_l
	mov y_pixel, ax
	call putpixel

	jmp inc_cond

	filling:
	; строчная затравка
	mov y_pixel, 80

	filling_loop:
	mov x_pixel, 63
	inc y_pixel
	mov ax, y_pixel
	cmp ax, 195
	jg exit

	find_in_row:
	inc x_pixel
	mov ax, x_pixel
	cmp ax, 160
	jge filling_loop ; конец строки

	call checkpixel
	mov al, es:[di]
	cmp al, 0
	je find_in_row	; следующая итерация, если закрашенный пиксель не найден

	mov al, es:[di]
	and al, 11000000b
	cmp al, 0
	jne left4

	mov al, es:[di]
	and al, 110000b
	cmp al, 0
	jne left3

	mov al, es:[di]
	and al, 1100b
	cmp al, 0
	jne left2

	inc_row:
	mov ax, x_pixel
	add ax, 4
	mov x_pixel, ax

	check_next:
	call checkpixel
	mov al, 0AAh
	mov es:[di], al

	mov ax, x_pixel
	add ax, 4
	mov x_pixel, ax

	call checkpixel
	mov al, es:[di]
	cmp al, 0
	je check_next

	mov al, es:[di]
	and al, 11b
	cmp al, 0
	jne right4

	mov al, es:[di]
	and al, 1100b
	cmp al, 0
	jne right3

	mov al, es:[di]
	and al, 110000b
	cmp al, 0
	jne right2

	jmp filling_loop

	right4:
	mov al, 0AAh
	mov es:[di], al
	jmp filling_loop

	right3:
	mov al, 0A8h
	mov es:[di], al
	jmp filling_loop

	right2:
	mov al, 0A0h
	mov es:[di], al
	jmp filling_loop

	left4:
	mov al, 0AAh
	mov es:[di], al
	jmp inc_row

	left3:
	mov al, 02Ah
	mov es:[di], al
	jmp inc_row

	left2:
	mov al, 0Ah
	mov es:[di], al
	jmp inc_row

	exit:

	xor	ax, ax
	int	16h

	mov ax, 3h
	int 10h

	mov ax,4c00h
	int 21h

	end main
