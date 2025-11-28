.MODEL SMALL
.STACK 100H
.DATA
    MSG1 DB 'Enter weight in kg (integer): $'
    MSG2 DB 'Enter height in meters (integer, e.g., 1 for 1.70m): $'
    MSG3 DB 'BMI (scaled by 100, e.g., 2500 = 25.00): $'
    MSG4 DB 'Category: $'
    OVER DB '1 - Overweight$'
    NORM DB '2 - Normal$'
    UNDER DB '3 - Underweight$'
    WEIGHT DW ?
    HEIGHT DW ?
    BMI DW ?

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Prompt for weight
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H

    ; Read weight
    CALL READ_NUM
    MOV WEIGHT, AX

    ; Prompt for height
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H

    ; Read height
    CALL READ_NUM
    MOV HEIGHT, AX

    ; Calculate BMI = (weight * 10000) / (height * height)
    MOV AX, WEIGHT
    MOV BX, 10000
    MUL BX          ; AX = weight * 10000
    MOV CX, AX      ; Store in CX

    MOV AX, HEIGHT
    MUL AX          ; AX = height * height
    MOV BX, AX      ; BX = height^2

    MOV AX, CX      ; AX = weight * 10000
    DIV BX          ; AX = (weight * 10000) / (height^2)
    MOV BMI, AX

    ; Display BMI
    LEA DX, MSG3
    MOV AH, 09H
    INT 21H

    MOV AX, BMI
    CALL PRINT_NUM

    ; New line
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H

    ; Display category
    LEA DX, MSG4
    MOV AH, 09H
    INT 21H

    ; Categorize BMI (compare scaled values)
    MOV AX, BMI
    CMP AX, 2500   ; 25.00 * 100
    JGE OVERWEIGHT

    CMP AX, 1850   ; 18.50 * 100
    JGE NORMAL

    ; Underweight
    LEA DX, UNDER
    JMP DISPLAY

OVERWEIGHT:
    LEA DX, OVER
    JMP DISPLAY

NORMAL:
    LEA DX, NORM

DISPLAY:
    MOV AH, 09H
    INT 21H

    ; Exit
    MOV AH, 4CH
    INT 21H

MAIN ENDP

; Subroutine to read a number from input
READ_NUM PROC
    PUSH BX
    PUSH CX
    MOV BX, 0
    MOV CX, 0

READ_LOOP:
    MOV AH, 01H
    INT 21H
    CMP AL, 0DH  ; Enter key
    JE END_READ
    SUB AL, 30H  ; Convert ASCII to digit
    MOV CL, AL
    MOV AX, BX
    MOV BX, 10
    MUL BX
    ADD AX, CX
    MOV BX, AX
    JMP READ_LOOP

END_READ:
    MOV AX, BX
    POP CX
    POP BX
    RET
READ_NUM ENDP

; Subroutine to print a number
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, 0
    MOV BX, 10

PRINT_LOOP:
    MOV DX, 0
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE PRINT_LOOP

PRINT_DIGITS:
    POP DX
    ADD DL, 30H
    MOV AH, 02H
    INT 21H
    LOOP PRINT_DIGITS

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN