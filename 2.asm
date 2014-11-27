; EXAMPLE.ASM - пример простейших начальных установок входа 
		;в графический режим
	.model  small
	.code

	cnt dw ?

	mov	ax,4h	;инициализация графического
	int	10h				;режима

	mov ah,0Bh
	mov bh,01h
	mov bl,00h
	int 10h	

	mov ah,0
	mov bh,0
	mov bl,0

	mov	ax, 0BA00h
	mov es,ax				;видеопамяти в
	mov bx,3920
	mov cnt, 0

render:
	mov bx, 3920
	mov cx, bx
	add cx, cnt
	mov bx,cx
	mov es:[bx], 0AAh
	add cnt, 1
	cmp cnt, 20
	jl render

	xor	ax,ax				;ожидание нажатия клавиши
	int	16h

	mov ax,3h
	int 10h

	mov	ax,4c00h			;выход из графики с возвратом
	int	21h				;в предыдущий режим

	end