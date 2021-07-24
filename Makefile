CC = gcc

calc: calc.l calc.y calc.h
	bison -d calc.y
	flex -ocalc.lex.c calc.l
	cc -o $@ calc.tab.c calc.lex.c calcfuncs.c


clean :
	rm -rf calc calc.lex.c calc.tab.*