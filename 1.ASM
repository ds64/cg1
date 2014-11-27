; EXAMPLE.ASM - пример простейших начальных установок входа 
		;в графический режим
	.model  small
	.code

	mov	ax,4h	;инициализация графического
	int	10h				;режима

	mov	ax, 0BA00h
	mov 	es,ax				;видеопамяти в

	mov ah,0Bh
	mov bh,01h
	mov bl,00h
	int 10h	

	mov bx,3945

	mov es:[bx], 02h

	xor	ax,ax				;ожидание нажатия клавиши
	int	16h

	mov ax,3h
	int 10h

	mov	ax,4c00h			;выход из графики с возвратом
	int	21h				;в предыдущий режим

	end