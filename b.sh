flex b.l
yacc -d b.y
g++ y.tab.c lex.yy.c
./a.out input
