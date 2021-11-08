;%include "io.inc" ;Eliminar el comentario para ejecutar en NASM
extern printf

section .data

puntero dq 25.0,2.0,4.0,6.0,8.0,10.0,12.0,14.0
resultado dq 0.0
msg db "Posicion %d del vector: %.2f * %.2f es %.2f", 10, 13, 0
r dq 2.0
limite db 8
multiplicador dq 0.0
numeroDelVector dq 0.0

section .text
global main
main:
    mov ebp, esp    ; for correct debugging
    
    ;Apilo puntero del vector y el multiplicador
    push puntero
    mov edx, [r + 4]
    push edx
    mov edx, [r]
    push edx

    ;Llamo a subrutina que contiene la logica
    call producto_rvf 
    add esp, 12

    ret
    
global producto_rvf
producto_rvf:
        enter 0,0

        mov esi, 0              ; Contador
        mov ecx, [limite]       ; Limite
        mov ebx, [ebp + 16]     ; Guardo el puntero en ebx
        
        fld qword[ebp + 8]
        fst qword[multiplicador] ; Guardo el multiplicador
        
        calcular:
        fld qword[ebx + esi * 8] ; Apilo el numero actual del vector
        fst qword[numeroDelVector] ; Guardo el numero actual del vector
        fld qword[multiplicador] ; Apilo el multiplicador
        fmul 			; Calculo el producto
        fst qword[resultado]	; Guardo el resultado

	;Cargo los datos en pila y muestro los resultados en pantalla
        push dword[resultado + 4]
        push dword[resultado] 
        
        push dword[multiplicador + 4]
        push dword[multiplicador]
        
        push dword[numeroDelVector + 4]        
        push dword[numeroDelVector]
        
        push esi
        
        push msg
        call printf
        add esp, 12
        
	;Incrementa el contador
        inc esi
        
        ;Compara si se llegó al limite para saber si seguir o terminar
        cmp esi, [limite]
        jl calcular
    
        leave
        ret