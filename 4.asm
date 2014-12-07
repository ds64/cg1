.model small
.data
    bitmaskh db 170,42,12,2
    bitmaskv db 128,32,8,2
    y1 dw ?
    y2 dw ?
    x1 dw ?
    x2 dw ?
    beginx dw 2
    endx dw 30
    beginy dw 160
    endy dw 5
    dx1 dw ?
    dy1 dw ?
    dzero dw ?
    dx1next dw ?
    dy1next dw ?
    dzeronext dw ?
    count dw ?

.code
    jmp start

vert proc
    mov ax,y1
    mov count,ax

    init:

    mov ax,0B800h
    mov es,ax

    mov bx, x1
    mov ax, count

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
    mov al,bitmaskv+[si]  ; в al - маска

    mov es:[bx],ax

    inc count
    mov ax,count
    cmp ax,y2
    jg endrender
    jmp init

    endrender:

    ret

hor proc
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
    mov ax, y1

    mov dx, bx
    and dx, 03h
    mov cl, 2
    shr bx, cl ;bx = x/4

    mov cx, ax
    and cx, 01h
    cmp cx, 0
    jz renderh
    add bx, 2000h

    renderh:
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
    mov al,bitmaskh+[si]  ; в al - маска

    mov cx,ax
    mov es:[bx],ax

    mov ax,count
    cmp dx,0
    je addax4
    add ax,dx
    comparer:
    cmp ax,x2
    jg endrenderh
    mov count,ax
    jmp maincycle

    endrenderh:
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

    ret

start:
    mov ax,@data
    mov ds,ax

    mov ax, 4h
    int 10h

    mov ah,0Bh
    mov bh,01h
    mov bl,00h
    int 10h

    mov beginx,2
    mov endx,5
    mov beginy,3
    mov endy,10

    mov ax,beginx
    mov x2,ax
    mov ax,beginy
    mov y2,ax
    jmp cycle

    negative:
    mov ax,dx1
    sal ax,1
    add ax, dzero
    mov dzeronext,ax
    mov ax,x1
    mov x2,ax
    jmp nextiter

yabs:
    xor ax,0FFFFh
    inc ax
    jmp afteryabs

    xabs:
    xor ax,0FFFFh
    inc ax
    jmp afterxabs

cycle:
    mov ax,y2
    mov y1,ax
    add ax,1
    mov y2,ax
    mov ax,x2
    mov x1, ax
    mov x2, ax

    mov ax,y1
    sub ax,endy
    cmp ax,0
    jl yabs
    afteryabs:
    mov dy1, ax

    mov ax,endx
    sub ax,x1
    cmp ax,0
    jl xabs
afterxabs:
    mov dx1, ax

    sal ax,1
    sub ax,dy1
    mov dzero,ax
    cmp dzero,0
    jl negative
    mov ax,dx1
    sub ax,dy1
    sal ax,1
    mov dzeronext,ax
    mov ax,x1
    add ax,1
    mov x2,ax
    nextiter:
    call vert
    mov ax,y2
    cmp ax, endy
    jl cycle

    xor ax,ax
    int 16h

    mov ax, 3h
    int 10h

    mov ax,4c00h
    int 21h

    mov	ax, 4c00h
    int	21h
end
