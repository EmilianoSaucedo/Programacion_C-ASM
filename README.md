# Programacion_C-ASM

Trabajo práctico de programación en C y Assembler.

Estos ejercicios fueron desarrollados y testeado en Ubutu 16.04 utilizando Visual Studio Code para la parte de C, SASM para la parte de Assembler y la consola de Linux para linkear ambos archivos y ejecutar el ejecutable final.

**Formula Resolvente**

El problema consiste en calcular las raíces de una función cuadrática a través de la formula resolvente.

Para resolver esto se desarrollaron 2 archivos:

1 - MainFormResolvente.c

2 - LogicaFormResolvente.asm

Comenzamos por detallar el archivo programado en C

Este archivo se encarga de solicitar al usuario que ingrese los 3 coeficientes para realizar el calculo. Luego llama a la función de Assembler que se encarga de la logica para obtener los resultados y una vez finalizada la función, termina el código.

Veamos el detalle

Para comenzar, se incluyen las librerias necesarias y se declara que la implementación de la funcion "calcularFormulaResolvente" se encuentra en otro archivo que luego será linkeado (.asm).

![image](https://user-images.githubusercontent.com/21018256/140763372-95783623-a65d-4628-9eb0-ae84d8d7712a.png)

Luego comienza la funcion "main" que se encarga de ejecutar todo el programa. Allí encontramos la declaración de variables de tipo float, la solicitud por consola de los coeficientes (a traves del scanf, los valores son almacenados en las variables declaradas anteriormente) y la llamada a la función que encontraremos en el archivo .asm "CalcularFormulaResolvente" (la cual recibe como parametros de entrada los 3 coeficientes ingresados por el usuario). Para finalizar, "return 0" para avisar que el programa finalizó exitosamente.

![image](https://user-images.githubusercontent.com/21018256/140764216-c9b04799-6796-4dd1-9794-3f4785d124f6.png)

Ahora, veamos la función que se encarga de la lógica en el archivo "LogicaFormResolvente.asm"

En primer lugar, tenemos la linea comentada, es la biblioteca nativa de SASM que incluye distintas funciones y macros. 
Está comentada ya que solo funciona al correr el programa dentro de SASM. En este caso vamos a compilar y ejecutar el programa desde la consola y no necesitamos esa libreria.

En segundo lugar, tenemos la section .data donde declaramos e inicializamos las variables que vamos a utilizar en la funcion.

- Parametros de entrada: Almacenarán los valores que envía el programa en C

- Variables temporales: Almacenarán resultados temporales del calculo

- Resultados: Almacenarán los resultados de las raices

- Formato: Almacena el formato del mensaje que se mostrará al finalizar el calculo

- Constantes: Almacenan el 4 y el 2 que nos encontramos en la formula resolvente por definición

![image](https://user-images.githubusercontent.com/21018256/140768653-95552568-2835-4328-a48f-d8f2c3746ba9.png)

En tercer lugar, tenemos la section .text que contiene la función de la lógica.

Allí nos encontramos con "global calcularFormulaResolvente" para que esta funcion pueda ser llamada desde otros archivos.

Luego, comenzamos con la lógica:

- Realizamos un enter 0,0 para inicializar la pila

- Leemos los parametros de entrada que se encuentran en la pila. Para eso pedimos [ebp + 8] ya que en esa ubicación tenemos el primer parametro de entrada. Recordar que en ebp + 4 tenemos el EIP (direccion del programa al que debe retornar). Como cada registro tiene 32 bits, nos movemos de a 4 bytes para seguir capturando los otros 2 parametros. A cada uno de estos los apilamos en la pila de la FPU con el comando fld y lo almacenamos en nuestras variables a partir de un fstp (store y desapilar) utilizando qword ya que es el tamaño de las variables.

![image](https://user-images.githubusercontent.com/21018256/140770742-2954c659-7233-4c39-aad1-e13eee5bdf4f.png)

Una vez que ya tenemos las variables de entrada almacenadas en nuestras variables locales, comenzamos a calcular la formula resolvente utilizando la pila de la FPU

![image](https://user-images.githubusercontent.com/21018256/140770886-d9fe0a71-f1a2-4ede-9e39-63b81c53ee6a.png)

Paso 1: Apilamos el parametro B y con fchs obtenemos el cambio de signo. Almacenamos el resultado en la variable temporal "valorNegativo"---> -B

Paso 2: Apilamos el parametro B y con fmul st0, st0 lo multiplicamos por si mismo ---> B²

Paso 3: Apilamos el 4, el parametro A y el parametro C. Con el primer fmul, multiplicamos 4 y A, y con el segundo fmul, multiplicamos el resultado de la operacion anterior con C. ----> 4.a.c

Paso 4: Restamos con fsub el resultado del paso 2 con el resultado del paso 3 que quedaron guardados en el tope de la pila (st0 y st1) ----> B²-4.a.c

Paso 5: Al resultado del paso 4, que quedó en el tope de la pila, le aplicamos raiz cuadrada y almacenamos el resultado en la variable temporal de la raiz ----> √B²-4.a.c

![image](https://user-images.githubusercontent.com/21018256/140772187-daa31036-37a3-4f1e-b43d-88147f3666f9.png)

Paso 6: Cargamos en la pila el 2 y el parametro A. Con fmul los multiplicamos y guardamos el resultado en "valorDivision" ----> 2.a

Aquí nos encontramos con la división de casos para obtener x1 y x2 donde en un caso aplicamos la suma y en otro la resta.

Paso 7: Cargamos en pila el valor -B, el resultado de la raiz cuadrada, los sumamos con fadd y el resultado queda en el tope de la pila. Allí cargamos el divisor y con fdiv dividimos ambos valores de la pila. El resultado es X1 y lo almacenamos en la variable "resultado1"

Paso 8: Aplicamos lo mismo que el paso 7 pero en lugar de fadd, aplicamos fsub para restar -B y el resultado de la raiz cuadrada. Luego de la división, obtenemos X2 y lo almacenamos en la variable "resultado2".

![image](https://user-images.githubusercontent.com/21018256/140773528-bd79797a-4045-4498-abd8-2fd093444985.png)

Una vez que ya tenemos los resultados en nuestras variables, los cargamos en la pila (no en la pila de la FPU). Para esto usamos push y realizamos la carga de cada dato en 2 pasos ya que debemos cargarlos como dword (qword no entra en la pila por su tamaño). Es por esto que primero cargamos [esultado+4]y luego [esultado]. Realizamos esta operacion para ambos resultados y luego apilamos la variable "msg" que cuenta con %f en 2 ocasiones para reemplazar por los valores cargados en la pila anteriormente.

Luego llamamos a la funcion printf (funcion que detallamos como extern ya que su implementacion no esta en este archivo) para imprimir por pantalla lo que cargamos en la pila

![image](https://user-images.githubusercontent.com/21018256/140774339-9a39022d-c41f-45ad-95af-49c8ee92ccbd.png)

Luego, sumamos 20 al puntero de la pila ESP (4 por cada push que hicimos) y aplicamos un "leave" para dejar la pila como estaba antes del llamado a esta función. Finalizamos con un ret.


Y ahora que ya tenemos los códigos, cómo los vinculamos y ejecutamos?

Para esto, tenemos el archivo "FormulaResolvente.sh" que contiene los comando a ejecutar en la consola de Linux

Allí encontramos el comando "nasm -f elf32 LogicaFormResolvente.asm -o LogicaFormResolvente.o;" que se encarga de compilar el archivo asm generando un archivo objeto, el cual detallamos el nombre al final de la instrucción.

"gcc -m32 -o ejecutableFormResolvente LogicaFormResolvente.o MainFormResolvente.c;" para que el linker vincule el archivo objeto del .asm con el archivo .c y genere un ejecutable.

"/ejecutableFormResolvente;" para ejecutar nuestro programa que se verá de la siguiente manera...

![image](https://user-images.githubusercontent.com/21018256/140776200-e05ce31a-a953-48f8-98ae-935acc2c89cb.png)


-----------------------------------------------------------------------------------------------------------------------

**Producto Escalar**

El problema consiste en recibir un numero r y un puntero a un vector de numeros de punto flotante y, a partir de ahí, calcular el producto escalar. Se debe multiplicar cada elemento del vector por r.

Para la resolución de esto, se realizó un programa en asm que contiene la siguiente lógica:

-  comenta la primera linea que incluye una librería propia de SASM, la cual no necesitamos ya que ejecutaremos el programa desde la consola de Linux

- Declaramos como externa la funcion printf ya que la implementacion no se encuentra en este programa

- Tenemos la section .data donde declaramos e inicializamos las variables

  - puntero: Vector con numeros a multiplicar

  - resultado: Rsultado temporal de cada multiplicacion

  - msg: Mensaje que se va a mostrar en pantalla a medida que se realicen los calculos

  - r: Valor del multiplicador

  - limite: Cantidad de numeros que contiene el vector

  - multiplicador: variable que se usa como multiplicador en la funcion "producto_rvf" para almacenar el valor de r

  - numeroDelVector: Numero actual del vector al que se le aplica la multiplicacion. Irá cambiando a medida que se recorre el vector.

![image](https://user-images.githubusercontent.com/21018256/140778086-caf44f5c-4446-4a14-b35d-92f56d54d1ed.png)

Luego tenemos la section .text, donde declaramos como global la funcion main (la cual comenzará al ejecutar el ejecutable desde la consola). Y luego comenzamos con la lógica de dicha función

- mov ebp, esp para inicializar la pila

- Apilamos en pila con push el puntero que contiene la dirección al primer valor del vector. Además, apilamos r en 2 partes, ya que es de tamaño qword y no entra en el registro de pila. Por eso cargamos [r+4] y luego [r]

- Una vez que ya tenemos cargados el puntero del vector y el multiplicador, llamamos a la funcion "producto_rvf" la cual esta declarada como global.

![image](https://user-images.githubusercontent.com/21018256/140778752-85b504f0-4d6c-46ca-9261-031a93d7e33e.png)

Pasemos a ver en detalle la función "producto_rvf"

- Realizamos un enter 0,0 para inicializar la pila

- Cargamos en registros un contador, "limite" que contiene la cantidad de numeros del vector y el puntero al primer elemento del vector

- Cargamos en la pila de la FPU con fld el multiplicador y luego lo almaceno en la variable "multiplicador" con la instruccion fst

![image](https://user-images.githubusercontent.com/21018256/140779416-29f81341-9fff-4d60-ae0c-6afaf13219b9.png)

- Declaramos la etiqueta "calcular" que más adelante veremos para qué se usa

- Comenzamos a trabajar con la pila de la FPU para realizar los calculos de multiplicacion. En primer lugar, cargamos el numero actual del vector (que ira cambiando a lo largo de la funcion). Para esto, utilizamos el valor de EBX (que contiene la dirección del primer elemento del vector) y le sumamos "esi + 8". Por que? Porque el registro "esi" tiene guardado el contador y 8 es la cantidad de bytes que nos tenemos que mover para encontrar al proximo elemento del vector. Por lo tanto, con "esi + 8" podemos ir recorriendo el vector, siempre y cuando arranquemos en la primera posición utilizando "EBX".

- Almacenamos con fst el numero del vector actual en la variable "numeroDelVector"

- Cargamos en pila el multiplicador y con fmul realizamos la multiplicacion de los elementos que tenemos cargados en pila (multiplicador y valor actual del vector)

- El resultado lo almacenamos en la variable "resultado"

![image](https://user-images.githubusercontent.com/21018256/140780342-707ba975-aa83-4ddb-9c4b-9fe16ac75436.png)

Una vez que tenemos almacenado el resultado de la multiplicacion actual, debemos cargar en pila los datos e imprimir en pantalla

- Para esto, cargamos en 2 partes (ya que "resultado" es de tipo qword y no entra en los registros de la pila) el valor del resultado, del multiplicador, del valor actual del vector y del contador

- Luego apilamos "msg" que contiene caracteres como %f y %s para incluir los valores antes apilados

- Llamamos a la funcion printf y obtenemos en pantalla el mensaje con el resultado de la multiplicación

![image](https://user-images.githubusercontent.com/21018256/140781832-9af51c7f-ffb6-4b94-85eb-fa50bedba225.png)

![image](https://user-images.githubusercontent.com/21018256/140780808-b7fd2359-f7a0-4571-8f1a-49785a7425a3.png)

- Sumamos 12 al puntero ESP de la pila, ya que realizamos varios push y queremos deshacernos de esos datos (sumamos 4 por cada push realizado)

Pero... tenemos el producto de un solo elemento del vector, cómo hacemos para obtener el producto escalar del vector entero?

- Incrementamos el contador con "inc esi"

- Usamos la instruccion "cmp esi, [limite]" que compara si el "esi" es igual al "limite"

  - En caso negativo, realizamos un salto con jl a la etiqueta calcular. Allí realizamos la misma lógica pero con el contador incrementado, lo cual nos permite trabajar con el siguiente numero del vector.

  - En caso positivo, es decir, cuando ya recorrimos todo el vector y el contador es igual al limite, realizamos un leave para dejar la pila en orden y finalizamos con un ret. De esta forma volvemos a la funcion main y ya imprimimos en pantalla el producto escalar solicitado.

![image](https://user-images.githubusercontent.com/21018256/140781910-711472b0-b157-42e4-b52d-d4c17e744a3a.png)

Una vez que volvimos a la funcion main y ya imprimimos los resultados, nos queda sumar 12 al puntero de pila "ESP" ya que habíamos pusheado 3 veces apilando el puntero y el multiplicador en 2 partes (recordar que esto es para dejar la pila como al inicio del programa) y finalizamos con un ret.

![image](https://user-images.githubusercontent.com/21018256/140782128-2dfa1f87-cf2f-42a3-9120-85601c65e173.png)

Esto nos devuelve por pantalla el producto escalar del vector y el multiplicador inicializado

![image](https://user-images.githubusercontent.com/21018256/140782259-61972624-85af-441f-8ac8-6959ba25fbce.png)

Para ejecutarlo, tenemos comandos en el archivo "ProductoEscalar.sh" que debemos ejecutar en la consola de Linux.

- nasm -f elf32 ProductoEscalar.asm -o ProductoEscalar.o; Con este comando ingresamos el nombre del archivo .asm y nos genera el archivo objeto (.o) con el nombre que le detallamos al final del comando

- gcc -m32 ProductoEscalar.o -o ejecutableProductoEscalar; Con gcc generamos un ejecutable a partir del archivo .o que generamos en el paso anterior. Al final del comando ingresamos el nombre que deseamos para nuestro ejecutable.

- ./ejecutableProductoEscalar; Con este comando ejecutamos el ejecutable generado.

![image](https://user-images.githubusercontent.com/21018256/140783248-675db5ea-6d46-4ed7-a9a5-5200010d7608.png)

----------------------------------------------------------------------

**Referencias**

Intel 64 and IA-32 Architectures Software Developer's Manual - Volume 1 - Chapter 8 Programming with the x87 FPU
