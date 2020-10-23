all: compile test

compile: clean
	@bison parser.y -v
	@flex scanner.l
	@gcc -Wall scanner.c parser.c lib/table.c lib/type.c lib/ast.c -o ezlang.bin

test:
	@./diff.sh

boo: compile
	@./ezlang.bin < in/c10.ezl

pdf: compile
	@./ezlang.bin < in/c10.ezl 2> out.dot
	@dot -Tpdf out.dot -o out.pdf
	@rm -rf out.dot

clean:
	@rm -rf parser.c parser.h scanner.c ezlang.bin parser.output out.pdf