nasm -f elf32 ProductoEscalar.asm -o ProductoEscalar.o;
gcc -m32 ProductoEscalar.o -o ejecutableProductoEscalar;
./ejecutableProductoEscalar;