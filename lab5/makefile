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
	@./ezlang.bin < in/c10.ezl 2> c10.dot
	@dot -Tpdf c10.dot -o c02.pdf
	# @rm -rf c10.dot

clean:
	@rm -rf parser.c parser.h scanner.c ezlang.bin parser.output c02.pdf