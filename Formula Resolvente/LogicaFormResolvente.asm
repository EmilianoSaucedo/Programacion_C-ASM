;%include "io.inc"
extern printf

section .data
    ;Parametros de entrada
    parametro1 dq 0.0
    parametro2 dq 0.0
    parametro3 dq 0.0

    ;Variables temporales
    valorNegativo dq 0.0
    valorRaiz dq 0.0
    valorDivision dq 0.0

    ;Resultados
    resultado1 dq 0.0
    resultado2 dq 0.0

    ;Formato
    msg db "El resultado de la formula resolvente es x1 = %.2f y x2 = %.2f",10,0
    
    ;Constantes
    cuatro dq 4.0
    dos dq 2.0
            
section .text
global calcularFormulaResolvente
calcularFormulaResolvente:
    
    ;Enter para acomodar la pila
    enter 0,0
;    mov ebp, esp
    
    ;Leer parametros de entrada
    fld dword[ebp+8]
    fstp qword[parametro1]
    
    fld dword[ebp+12]
    fstp qword[parametro2]
    
    fld dword[ebp+16]
    fstp qword[parametro3]
    
    ;Calcular la parte negativa
    fld qword[parametro2]
    fchs
    fstp qword[valorNegativo]
    
    ;Calcular la parte de la raiz
    ;------------B²------------
    fld qword[parametro2]
    fmul st0, st0
    
    ;------------4.a.c--------------------
    fld qword[cuatro]
    fld qword[parametro1]
    fld qword[parametro3]
    fmul
    fmul
    
    ;---------B²-4.a.c--------------------
    fsub
    
    ;---------√B²-4.a.c------------------
    fsqrt
    fstp qword[valorRaiz]
    
    ;Calcular 2.a
    fld qword[dos]
    fld qword[parametro1]
    fmul
    fstp qword[valorDivision]
    
    ;Calcular X1
    fld qword[valorNegativo]
    fld qword[valorRaiz]
    fadd
    fld qword[valorDivision]
    fdiv
    fstp qword[resultado1]
    
    ;Calcular X2
    fld qword[valorNegativo]
    fld qword[valorRaiz]
    fsub
    fld qword[valorDivision]
    fdiv
    fstp qword[resultado2]
    
    ;Cargo los resultados en pila y muestro el resultado en pantalla
    push dword[resultado2+4]
    push dword[resultado2]
    push dword[resultado1+4]
    push dword[resultado1]
    push msg
    call printf
    
    ;Devuelvo el ESP a su posición anterior
    add esp,20
    
    ;Leave para normalizar el estado de la pila
    leave
    
;    xor eax, eax
    ret