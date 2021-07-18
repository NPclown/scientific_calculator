CC = gcc

calc : calc.l calc.y
	bison -d calc.y
	flex calc.l
	gcc -o calc calc.tab.c lex.yy.c -lfl

clean :
	rm -rf calc lex.yy.c calc.tab.*