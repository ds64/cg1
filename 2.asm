.model  small

.data
		bitmask db 170,42,10,2
		x1 dw 4
		x2 dw 234
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

		mov ax,x1
		mov count,ax

		jmp maincycle

addax4:
		add ax,4
		jmp comparer

maincycle:
		mov ax,0B800h
		mov es,ax

		mov bx, count
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
		sal ax, cl ;ax=(y/2)*2^6, bx=x/4 + (y/2)*2^4
		add bx, ax

		xor ax,ax
		mov si,dx
		mov al,bitmask+[si]  ; в al - маска

		mov cx,ax
		mov es:[bx],ax

		mov ax,count
		cmp dx,0
		je addax4
		add ax,dx
comparer:
		cmp ax,x2
		jg endrender
		mov count,ax
		jmp maincycle

endrender:
		mov dx,x2
		and dx,03h
		cmp dx,3
		je keywait
		mov ax,cx
		mov cx,6
		sub cx,dx
		sub cx,dx
		mov ch,0
		sal ax,cl
		mov ah,0
		mov es:[bx],ax
		jmp keywait

keywait:
		xor	ax, ax
		int	16h

		mov ax, 3h
		int 10h

		mov ax,4c00h
		int 21h

		mov	ax, 4c00h
		int	21h

end
