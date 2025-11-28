; Corrected BMI calculator (16-bit DOS, TASM/MASM compatible)
; Assumptions: height (cm) < 256 so height^2 fits in 16-bit.
; Computes integer BMI = weight*10000 / (height*height)
; Menu-driven: 1-Calculate BMI, 2-Show Categories, 3-Exit

.MODEL SMALL
.STACK 100H
.DATA

menuMsg     DB 13,10,'===== BMI SYSTEM =====',13,10
            DB '1- Calculate BMI',13,10
            DB '2- Show BMI Categories',13,10
            DB '3- Exit',13,10
            DB 'Choose option: $'

weightMsg   DB 13,10,'Enter weight (kg): $'
heightMsg   DB 13,10,'Enter height (cm): $'
bmiMsg      DB 13,10,'Your BMI = $'

underMsg    DB 13,10,'Category: Underweight$'
normalMsg   DB 13,10,'Category: Normal weight$'
overMsg     DB 13,10,'Category: Overweight$'
obeseMsg    DB 13,10,'Category: Obese$'

catMsg      DB 13,10,'--- BMI Categories ---',13,10
            DB 'Underweight: < 18.5 (treated here as < 18)',13,10
            DB 'Normal: 18 - 24',13,10
            DB 'Overweight: 25 - 29',13,10
            DB 'Obese: >= 30',13,10,'$'

invalidMsg  DB 13,10,'Invalid input... try again!',13,10,'$'

buffer      DB 5,0,5 DUP('$')
num         DW ?

.CODE
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

mainMenu:
    LEA DX,menuMsg
    MOV AH,9
    INT 21H

    MOV AH,1
    INT 21H
    SUB AL,'0'

    CMP AL,1
    JE calcBMI

    CMP AL,2
    JE showCategories

        CMP AL,3
        JNE mainMenu
    
    exitProgram:
        MOV AH,4CH
        INT 21H

;--------------------------------------------------
; Calculate BMI: AX/BX/CX usage
; Input: BX = weight(kg), CX = height(cm)
; Output: AX = BMI (integer)
;--------------------------------------------------
calcBMI:
    LEA DX,weightMsg
    MOV AH,9
    INT 21H
    CALL readNumber     ; returns AX = number
    MOV BX,AX           ; BX = weight

    LEA DX,heightMsg
    MOV AH,9
    INT 21H
    CALL readNumber     ; returns AX = number
    MOV CX,AX           ; CX = height (cm)

    ; validate height not zero
    CMP CX,0
    JE showInvalid

    ; compute height^2 -> AX = height^2 (assumes DX=0 after MUL)
    MOV AX,CX
    MUL CX             ; DX:AX = CX * CX
    CMP DX,0
    JNE showInvalid    ; height^2 doesn't fit in 16-bit -> treat as invalid
    MOV SI,AX          ; SI = height^2

    ; compute numerator = weight * 10000 -> DX:AX (32-bit)
    MOV AX,BX          ; AX = weight
    MOV BX,10000       ; BX used temporarily for constant
    MUL BX             ; DX:AX = weight * 10000

    ; divide 32-bit DX:AX by 16-bit SI -> quotient in AX
    DIV SI             ; AX = BMI (integer)

    ; AX now BMI
    PUSH AX            ; preserve for printing

    LEA DX,bmiMsg
    MOV AH,9
    INT 21H

    POP AX             ; restore BMI
    CALL printNumber

    ; Compare BMI with integer thresholds: 18,25,30
    CMP AX,18
    JL underwt
    CMP AX,25
    JL normalwt
    CMP AX,30
    JL overweight
    JMP obese

underwt:
    LEA DX,underMsg
    JMP printCat

normalwt:
    LEA DX,normalMsg
    JMP printCat

overweight:
    LEA DX,overMsg
    JMP printCat

obese:
    LEA DX,obeseMsg

printCat:
    MOV AH,9
    INT 21H
    JMP mainMenu

showCategories:
    LEA DX,catMsg
    MOV AH,9
    INT 21H
showInvalid:
    LEA DX,invalidMsg
    MOV AH,9
    INT 21H
    JMP mainMenu
    MOV AH,4CH
    INT 21H

;--------------------------------------------------
; readNumber: reads decimal digits until Enter (CR)
; returns AX = parsed number
; uses: AX, BX, CX, DX
;--------------------------------------------------
readNumber PROC
    XOR DX,DX        ; DX will hold current number
read_loop:
    MOV AH,1
    INT 21H          ; AL = char
    CMP AL,13        ; Enter?
    JE doneRead
    SUB AL,'0'       ; convert char to digit
    ; save digit in BL (clear BH first)
    XOR BX,BX
    MOV BL,AL
    ; DX = DX * 10
    MOV AX,DX
    MOV CX,10
    MUL CX           ; DX:AX = AX * 10
    ; result in AX
    ADD AX,BX        ; AX = AX + digit
    MOV DX,AX        ; DX = new number
    JMP read_loop

doneRead:
    MOV AX,DX        ; return number in AX
    RET
readNumber ENDP

;--------------------------------------------------
; printNumber: prints unsigned integer in AX
;--------------------------------------------------
printNumber PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX,0
    CMP AX,0
    JNE convert_loop
    ; print single '0' if AX == 0
    MOV DL,'0'
    MOV AH,2
    INT 21H
    JMP print_done

convert_loop:
    XOR DX,DX
    MOV BX,10
    DIV BX           ; divide AX by 10 -> AX = AX/10, DX = remainder
    PUSH DX
    INC CX
    CMP AX,0
    JNE convert_loop

print_loop:
    POP DX
    ADD DL,'0'
    MOV AH,2
    INT 21H
    LOOP print_loop

print_done:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
printNumber ENDP

END MAIN
