compile: clear
	bison parser.y
	flex scanner.l
	gcc -Wall scanner.c parser.c -ly

test:
	./out

clear:
	rm -rf parser.c parser.h scanner.c a.out