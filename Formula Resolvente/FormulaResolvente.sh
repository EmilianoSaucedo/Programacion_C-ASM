nasm -f elf32 LogicaFormResolvente.asm -o LogicaFormResolvente.o;
gcc -m32 -o ejecutableFormResolvente LogicaFormResolvente.o MainFormResolvente.c;
./ejecutableFormResolvente;