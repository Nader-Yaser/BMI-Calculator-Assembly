.model small
.stack 100h
.data
    msgHeight db "Enter height in cm: $"
    msgWeight db "Enter weight in kg: $"
    msgBMI    db 13,10,"Your BMI = $"
    msgUW     db 13,10,"Status: Underweight$"
    msgN      db 13,10,"Status: Normal$"
    msgOW     db 13,10,"Status: Overweight$"
    msgOB     db 13,10,"Status: Obese$"

    height dw ?
    weight dw ?
    bmi    dw ?
.code

;---------------------------------------
print_str PROC
    mov ah,09
    int 21h
    ret
print_str ENDP

;---------------------------------------
read_num PROC
    ; يقرأ رقم (2 digits max)
    xor cx,cx        ; cx = number
read_loop:
    mov ah,01
    int 21h
    cmp al,13        ; Enter?
    je end_read
    sub al,'0'
    mov bl,al
    mov ax,cx
    mov dx,10
    mul dx
    add ax,bx
    mov cx,ax
    jmp read_loop
end_read:
    mov ax,cx
    ret
read_num ENDP

;---------------------------------------
start:
    mov ax,@data
    mov ds,ax

    ; Get height
    mov dx,offset msgHeight
    call print_str
    call read_num
    mov height,ax

    ; Get weight
    mov dx,offset msgWeight
    call print_str
    call read_num
    mov weight,ax

    ; BMI = (weight * 10000) / (height * height)
    mov ax,weight
    mov bx,10000
    mul bx            ; dx:ax = weight*10000

    mov bx,height
    mul bx            ; dx:ax = weight*10000*height

    mov bx,height
    div bx            ; (weight*10000) / height

    mov bx,height
    div bx            ; /height second time → BMI
    mov bmi,ax
    sub bmi,20  ; Adjust for rounding


    ; Print BMI
    mov dx,offset msgBMI
    call print_str

    ; Print number
    mov ax,bmi
    call print_decimal

    ; Classification
    mov ax,bmi
    cmp ax,185
    jl underweight
    cmp ax,249
    jle normal
    cmp ax,299
    jle overweight
    jmp obese

underweight:
    mov dx,offset msgUW
    call print_str
    jmp exit

normal:
    mov dx,offset msgN
    call print_str
    jmp exit

overweight:
    mov dx,offset msgOW
    call print_str
    jmp exit

obese:
    mov dx,offset msgOB
    call print_str

exit:
    mov ah,4Ch
    int 21h

;---------------------------------------
; print_decimal → يطبع رقم من AX
;---------------------------------------
print_decimal PROC
    push ax
    push bx
    push cx
    push dx
    push di
    mov bx,10
    xor cx,cx
next_digit:
    xor dx,dx
    div bx
    push dx
    inc cx
    cmp ax,0
    jne next_digit
print_loop:
    pop dx
    add dl,'0'
    mov ah,02
    int 21h
    loop print_loop
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_decimal ENDP

end start


