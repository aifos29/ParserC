bison: 
	bison -d parser.y
	flex parser.l
	gcc -o parser lex.yy.c parser.tab.h
	gcc preprocesador.c -o pre
	

