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
    newline   db 13,10,'$'

    height dw ?
    weight dw ?
    bmi dw ?
    numBuf db 6 dup(0)

.code

;---------------------------------------
print_str PROC
    mov ah,09
    int 21h
    ret
print_str ENDP

;---------------------------------------
read_num PROC
    xor cx,cx
read_loop:
    mov ah,01
    int 21h
    cmp al,13
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

    ; قراءة الطول
    mov dx,offset msgHeight
    call print_str
    call read_num
    mov height,ax

    ; قراءة الوزن
    mov dx,offset msgWeight
    call print_str
    call read_num
    mov weight,ax

    ; ===============================
    ; حساب BMI
    ; BMI = (weight * 10000) / (height*height)
    ; ===============================
    mov ax,weight
    mov bx,10000
    mul bx        ; DX:AX = weight*10000

    mov bx,height
    mul bx        ; DX:AX = weight*10000 * height

    ; نقسم على الطول
    mov bx,height
    div bx        ; AX = weight*10000 / height

    div bx        ; AX = BMI = weight*10000 / (height*height)
    mov bmi,ax
    sub bmi,20

    ; ===============================
    ; طباعة BMI
    ; ===============================
    mov dx,offset msgBMI
    call print_str
    mov ax,bmi
    call print_decimal
    mov dx,offset newline
    call print_str

    ; ===============================
    ; تصنيف BMI
    ; ===============================
    mov ax,bmi
    cmp ax,300      ; BMI >=30.00 ×100 → Obese
    jge obese
    cmp ax,250      ; BMI >=25.00 ×100 → Overweight
    jge overweight
    cmp ax,185      ; BMI >=18.50 ×100 → Normal
    jge normal
    cmp ax,0     ; BMI <18.50 ×100 → Underweight
    jge underweight
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
print_decimal PROC
    push ax
    push bx
    push cx
    push dx
    mov bx,10
    xor cx,cx
    lea si,numBuf
    add si,6
    dec si

    cmp ax,0
    jne pd_loop
    mov dl,'0'
    mov ah,2
    int 21h
    jmp pd_done

pd_loop:
    xor dx,dx
    div bx
    push dx
    inc cx
    cmp ax,0
    jne pd_loop

    inc si
    mov di,si
    mov bx,cx

pd_print:
    pop dx
    add dl,'0'
    mov ah,2
    int 21h
    dec bx
    jnz pd_print

pd_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_decimal ENDP

end start
