CFLAGS = -g -Wall -ansi -pedantic

phase3: mini_l.lex min_l.y
	bison -d -v mini_l.y 
	flex mini_l.lex
	g++ $(CFLAGS) -std=c++11 lex.yy.c phase3.tab.c -lfl -o phase3 
	rm -f lex.yy.c *.output *.tab.c *.tab.h 

