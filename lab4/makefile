all: compile test

compile: clean
	@bison parser.y -v
	@flex scanner.l
	@gcc -Wall scanner.c parser.c table/tables.c table/types.c -o ezlang.bin

test:
	@./diff.sh

clean:
	@rm -rf parser.c parser.h scanner.c ezlang.bin parser.output