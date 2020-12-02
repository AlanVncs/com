all: compile test

compile: clean
	@bison parser.y -v
	@flex scanner.l
	@gcc -Wall scanner.c parser.c lib/table.c lib/type.c lib/ast.c lib/interpreter.c -o ezlang.bin

trace: compile
	@gcc -D TRACE -Wall scanner.c parser.c lib/table.c lib/type.c lib/ast.c lib/interpreter.c -o ezlang.bin
	@./ezlang.bin < in/main.ezl

diff:
	@./diff.sh

run: compile
	@./ezlang.bin < in/main.ezl

pdf: compile
	@./ezlang.bin < in/main.ezl 2> out.dot
	@dot -Tpdf out.dot -o out.pdf
	@rm -rf out.dot

clean:
	@rm -rf parser.c parser.h scanner.c ezlang.bin parser.output out.pdf