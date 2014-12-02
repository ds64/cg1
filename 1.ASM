.model  small

.data
	bitmask db 128,32,8,2
	x dw 10
	y dw 11
	count dw ?

.code

	mov ax,@data
	mov ds,ax

	mov ax, 4h
	int 10h

	mov ah,0Bh
	mov bh,01h
	mov bl,00h
	int 10h

	mov ax,0B800h      ;указываем на видеобуфер
	mov es,ax          ;

	mov bx, x
	mov ax, y

	mov dx, bx
	and dx, 03h
	mov cl, 2
	shr bx, cl ;bx = x/4

	mov cx, ax
	and cx, 01h
	cmp cx, 0
	jz render
	add bx, 2000h

render:
	mov cl, 1
	shr ax, cl ;ax = y/2
	mov cl, 4
	sal ax, cl ;ax=(y/2)*2^4, bx=x/4
	add bx, ax
	mov cl, 2
	sal ax, cl ;ax=((y-1)/2)*2^6, bx=x/4 + ((y-1)/2)*2^4
	add bx, ax

	xor ax,ax
	mov si,dx
	mov al,bitmask+[si]  ; в al - маска

	mov es:[bx],ax     ;выводим точку

	xor ax,ax			;ожидание нажатия клавиши
	int 16h

	mov ax,3h
	int 10h

	mov ax,4c00h		;выход из графики с возвратом
	int 21h			;в предыдущий режим

end
