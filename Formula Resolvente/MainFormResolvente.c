#include <stdio.h>
#include <stdlib.h>

extern void calcularFormulaResolvente(float a, float b, float c);

int main(){
    /*Declaracion de variables */
    float a;
    float b;
    float c;

    /*Solicitud de parametros para realizar el calculo */
    printf("Bienvenido a la calculadora de raices de una funcion cuadratica\n\n");
    printf("El calculo se realiza a traves de la formula resolvente\n\n");
    printf("A continuación se solicitará que ingrese los 3 coeficientes de la funcion\n\n");

    printf("Ingrese el coeficiente a: ");
    scanf("%f", &a);

    printf("\nIngrese el coeficiente b: ");
    scanf("%f", &b);

    printf("\nIngrese el coeficiente c: ");
    scanf("%f", &c);
    printf("\n");

    /*Llamada a la función que realiza el calculo en el archivo asm */
    calcularFormulaResolvente(a, b, c);

    return 0;
}
