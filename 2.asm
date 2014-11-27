	.model  small
	.code

	cnt dw ?
	y dw 40

	mov	ax,4h
	int	10h

	mov ah,0Bh
	mov bh,01h
	mov bl,00h
	int 10h

	mov ah,0
	mov bh,0
	mov bl,0

	mov	ax, 0B800h
	mov es, ax

	mov ax, y
	mov bx, 80
	mul bx

	mov cnt, 0

render:
	mov cx, ax
	add cx, cnt
	mov bx, cx
	mov dx, 0AAh
	mov es:[bx], dx
	add cnt, 1
	cmp cnt, 20
	jl render

	xor	ax,ax
	int	16h

	mov ax,3h
	int 10h

	mov	ax,4c00h
	int	21h

	end
