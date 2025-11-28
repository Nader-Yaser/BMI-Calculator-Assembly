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
            DB 'Underweight: < 18.5',13,10
            DB 'Normal: 18.5 - 24.9',13,10
            DB 'Overweight: 25 - 29.9',13,10
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
    JE exitProgram

    JMP mainMenu 


calcBMI:
    LEA DX,weightMsg
    MOV AH,9
    INT 21H
    CALL readNumber
    MOV BX,AX    

    LEA DX,heightMsg
    MOV AH,9
    INT 21H
    CALL readNumber
    MOV CX,AX   

    MOV AX,CX
    MOV DX,0
    MOV SI,100
    DIV SI      

    MOV AX,BX
    MOV DX,0
    MOV SI,10000
    MUL SI      

    MOV SI,CX
    MUL SI       

    MOV DX,0
    DIV SI       

    PUSH AX     

    LEA DX,bmiMsg
    MOV AH,9
    INT 21H

    CALL printNumber

    POP AX

    CMP AX,185
    JL underwt
    CMP AX,250
    JL normalwt
    CMP AX,300
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
    JMP mainMenu

exitProgram:
    MOV AH,4CH
    INT 21H

readNumber PROC
    MOV AX,0

read_loop:
    MOV AH,1
    INT 21H

    CMP AL,13
    JE doneRead

    SUB AL,'0'
    MOV BL,AL

    MOV AL,AH
    MOV AH,0
    MOV CX,10
    MUL CX
    ADD AX,BX

    JMP read_loop

doneRead:
    RET
readNumber ENDP

printNumber PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX,0

convert_loop:
    MOV DX,0
    MOV BX,10
    DIV BX
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

    POP DX
    POP CX
    POP BX
    POP AX
    RET
printNumber ENDP

END MAIN
