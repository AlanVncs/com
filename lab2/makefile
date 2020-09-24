all: compile test

compile: clean
	@bison parser.y
	@flex scanner.l
	@gcc -Wall scanner.c parser.c -o ezlang.bin

test:
	@./diff.sh

clean:
	@rm -rf parser.c parser.h scanner.c ezlang.bin