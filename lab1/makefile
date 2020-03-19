all: compile test

compile:
	@flex -o ezlang.c ezlang.l
	@gcc -o ezlang.bin -lfl ezlang.c

test:
	@./diff.sh