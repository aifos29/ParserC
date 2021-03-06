%{
	#include <stdio.h>
 	extern int yylineno; 
 	extern int yyerrork;

 	#define YYLTYPE YYLTYPE
	  typedef struct YYLTYPE
	  {
	    int first_line;
	    int first_column;
	    int last_line;
	    int last_column;
	    char *filename;
	  } YYLTYPE;

 	void yyerror(const char *s);
 	void lyyerror(YYLTYPE t, char *s);
 	int beamer=0;
 	void beamer_print(int error);
 	FILE * tmp;
 	FILE * beamerFile;
%}
%locations
%token	IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL FUNC_NAME SIZEOF
%token	PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token	AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token	SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token	XOR_ASSIGN OR_ASSIGN
%token	TYPEDEF_NAME ENUMERATION_CONSTANT

%token	TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token	CONST RESTRICT VOLATILE
%token	BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token	COMPLEX IMAGINARY 
%token	STRUCT UNION ENUM ELLIPSIS

%token	CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN
%token	ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL

%start translation_unit


%%
primary_expression
	: IDENTIFIER  
	| constant 
	| string 
	| '(' expression ')' 
	| generic_selection 
	;  


constant
	: I_CONSTANT		/* includes character_constant */
	| F_CONSTANT
	| ENUMERATION_CONSTANT	/* after it has been defined as such */
	;

enumeration_constant		/* before it has been defined as such */
	: IDENTIFIER 
	;

string
	: STRING_LITERAL  
	| FUNC_NAME 
	;

generic_selection
	: GENERIC '(' assignment_expression ',' generic_assoc_list ')'  
	| GENERIC  assignment_expression ',' generic_assoc_list ')' 
	|GENERIC '(' assignment_expression ',' generic_assoc_list  
	|GENERIC '(' assignment_expression ')'						
	|GENERIC '(' assignment_expression  generic_assoc_list ')'	
	|GENERIC '('generic_assoc_list ')'	
	|GENERIC error {lyyerror(@1,"Expresión incomplenta, falta parentesis");yyerror;}						

	;

generic_assoc_list
	: generic_association 
	| generic_assoc_list ',' generic_association 
	| generic_assoc_list error {lyyerror(@1,"Falta una coma");yyerror;}
	
	;

generic_association
	: type_name ':' assignment_expression 
	| DEFAULT ':' assignment_expression 
	|error  {lyyerror(@1,"Falta dos puntos en la declaración");yyerror;}
	;

postfix_expression
	: primary_expression 
	| postfix_expression '[' expression ']' 
	| postfix_expression '(' ')' 
	| postfix_expression '(' argument_expression_list ')' 
	| postfix_expression '.' IDENTIFIER 
	| postfix_expression PTR_OP IDENTIFIER 
	| postfix_expression INC_OP 
	| postfix_expression DEC_OP 
	| '(' type_name ')' '{' initializer_list '}' 
	| '(' type_name ')' '{' initializer_list ',' '}' 
	| error {lyyerror(@1,"Falta parentesis o llaves");}
	;

argument_expression_list
	: assignment_expression 
	| argument_expression_list ',' assignment_expression
	
	;

unary_expression
	: postfix_expression 
	| INC_OP unary_expression 
	| DEC_OP unary_expression 
	| unary_operator cast_expression 
	| SIZEOF unary_expression 
	| SIZEOF '(' type_name ')' 
	| ALIGNOF '(' type_name ')' 
	
	;

unary_operator
	: '&'  
	| '*'   
	| '+'  
	| '-'  
	| '~'  
	| '!'  
	;

cast_expression
	: unary_expression  
	| '(' type_name ')' cast_expression 

	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression
	| multiplicative_expression '/' cast_expression
	| multiplicative_expression '%' cast_expression

	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression

	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression
	| shift_expression RIGHT_OP additive_expression

	;

relational_expression
	: shift_expression
	| relational_expression '<' shift_expression
	| relational_expression '>' shift_expression
	| relational_expression LE_OP shift_expression
	| relational_expression GE_OP shift_expression

	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression

	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression

	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression

	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression

	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression

	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression

	;

assignment_operator
	: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
	| XOR_ASSIGN
	| OR_ASSIGN
	;

expression
	: assignment_expression
	| expression ',' assignment_expression

	;

constant_expression
	: conditional_expression	/* with constraints */

	;

declaration
	: declaration_specifiers ';'
	| declaration_specifiers init_declarator_list ';'
	| static_assert_declaration
	|error {lyyerror(@1,"Falta ; al finalizar declaracion");}
	;

declaration_specifiers
	: storage_class_specifier declaration_specifiers
	| storage_class_specifier
	| type_specifier declaration_specifiers
	| type_specifier
	| type_qualifier declaration_specifiers
	| type_qualifier
	| function_specifier declaration_specifiers
	| function_specifier
	| alignment_specifier declaration_specifiers
	| alignment_specifier
	|error {lyyerror(@1,"La declaración no ha sido correcta");yyerror;}
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	|error {lyyerror(@1,"Falta , al separar los argumentos");yyerror;}
	;

init_declarator
	: declarator '=' initializer   	| declarator 
	|error {lyyerror(@1,"No se ha declarado correctamente");yyerror;}
	;




storage_class_specifier
	: TYPEDEF	/* identifiers must be flagged as TYPEDEF_NAME */
	| EXTERN
	| STATIC
	| THREAD_LOCAL
	| AUTO
	| REGISTER
	;

type_specifier
	: VOID
	| CHAR
	| SHORT
	| INT
	| LONG
	| FLOAT
	| DOUBLE
	| SIGNED
	| UNSIGNED
	| BOOL
	| COMPLEX
	| IMAGINARY	  	/* non-mandated extension */
	| atomic_type_specifier
	| struct_or_union_specifier
	| enum_specifier
	| TYPEDEF_NAME		/* after it has been defined as such */
	;

struct_or_union_specifier
	: struct_or_union '{' struct_declaration_list '}'
	| struct_or_union IDENTIFIER '{' struct_declaration_list '}'
	| struct_or_union IDENTIFIER
	|error {lyyerror(@1," Las llaves o parentesis no han sido cerradas correctamente ");yyerror;}
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	|error {lyyerror(@1,"Declaración incorrecta de lista ");yyerror;}
	;

struct_declaration
	: specifier_qualifier_list ';'	/* for anonymous struct/union */
	| specifier_qualifier_list struct_declarator_list ';'
	| static_assert_declaration
	|error {lyyerror(@1,"Falta ; al finalizar la declaración ");yyerror;}
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier

	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator
	|error {lyyerror(@1,"Falta ; al finalizar la declaración ");yyerror;}
	;

struct_declarator
	: ':' constant_expression
	| declarator ':' constant_expression
	| declarator
	|error {lyyerror(@1,"Estructura declarada de forma incorrecta ");yyerror;}
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER '{' enumerator_list '}'
	| ENUM IDENTIFIER '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER

	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	|error {lyyerror(@1,"Falta coma al separar los argumentos ");yyerror;}
	;

enumerator	/* identifiers must be flagged as ENUMERATION_CONSTANT */
	: enumeration_constant '=' constant_expression
	| enumeration_constant
	|error {lyyerror(@1," Declaración incorrecta ");yyerror;}
	;

atomic_type_specifier
	: ATOMIC '(' type_name ')'
	
	;

type_qualifier
	: CONST
	| RESTRICT
	| VOLATILE
	| ATOMIC
	;

function_specifier
	: INLINE
	| NORETURN
	;

alignment_specifier
	: ALIGNAS '(' type_name ')'
	| ALIGNAS '(' constant_expression ')'

	;

declarator
	: pointer direct_declarator
	| direct_declarator
	|error {lyyerror(@1,"Falta ; al terminar expresión");yyerror;}
	;

direct_declarator
	: IDENTIFIER
	| '(' declarator ')' {beamer_print(0);}
	| direct_declarator '[' ']'
	| direct_declarator '[' '*' ']'
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
	| direct_declarator '[' STATIC assignment_expression ']'
	| direct_declarator '[' type_qualifier_list '*' ']'
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
	| direct_declarator '[' type_qualifier_list assignment_expression ']'
	| direct_declarator '[' type_qualifier_list ']'
	| direct_declarator '[' assignment_expression ']'
	| direct_declarator '(' parameter_type_list ')'
	| direct_declarator '(' ')'
	| direct_declarator '(' identifier_list ')'
	|error {lyyerror(@1,"Faltan cerrar parentesis o llaves ");yyerror;}
	;

pointer
	: '*' type_qualifier_list pointer
	| '*' type_qualifier_list
	| '*' pointer
	| '*'
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	|error {lyyerror(@1,"Erro en la Declaración ");yyerror;}
	;


parameter_type_list
	: parameter_list ',' ELLIPSIS
	| parameter_list

	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration

	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers

	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER

	;

type_name
	: specifier_qualifier_list abstract_declarator
	| specifier_qualifier_list

	;

abstract_declarator
	: pointer direct_abstract_declarator
	| pointer
	| direct_abstract_declarator
	|error {lyyerror(@1,"Error en la declaracion ");yyerror;}
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' '*' ']'
	| '[' STATIC type_qualifier_list assignment_expression ']'
	| '[' STATIC assignment_expression ']'
	| '[' type_qualifier_list STATIC assignment_expression ']'
	| '[' type_qualifier_list assignment_expression ']'
	| '[' type_qualifier_list ']'
	| '[' assignment_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' '*' ']'
	| direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']'
	| direct_abstract_declarator '[' STATIC assignment_expression ']'
	| direct_abstract_declarator '[' type_qualifier_list assignment_expression ']'
	| direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']'
	| direct_abstract_declarator '[' type_qualifier_list ']'
	| direct_abstract_declarator '[' assignment_expression ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	|error {lyyerror(@1,"Declaración incorrecta o falta cerrar parentesis y/o llaves ");yyerror;}
	;

initializer
	: '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	| assignment_expression

	;

initializer_list
	: designation initializer
	| initializer
	| initializer_list ',' designation initializer
	| initializer_list ',' initializer
	
	;

designation
	: designator_list '='
	|error {lyyerror(@1,"Designacion incompleta ");yyerror;}
	;

designator_list
	: designator
	| designator_list designator

	;

designator
	: '[' constant_expression ']'
	| '.' IDENTIFIER
	|error {lyyerror(@1,"Designacion incorrecta");yyerror;}
	;

static_assert_declaration
	: STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';'

	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	|error {lyyerror(@1,"Sentencia incorrecta");yyerror;}
	;

labeled_statement
	: IDENTIFIER ':' statement
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement

	;

compound_statement
	: '{' '}'
	| '{'  block_item_list '}'
	|error {lyyerror(@1,"Las llaves no están correctamente posicionadas ");yyerror;}
	;

block_item_list
	: block_item
	| block_item_list block_item

	;

block_item
	: declaration
	| statement
	;

expression_statement
	: ';'
	| expression ';'
	|error {lyyerror(@1,"Falta ; al finalizar ");yyerror;}
	;

selection_statement
	: IF '(' expression ')' statement ELSE statement  
	| IF '(' expression ')' statement 
	| SWITCH '(' expression ')' statement 
	
	;

iteration_statement
	: WHILE '(' expression ')' statement 
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement
	| FOR '(' declaration expression_statement ')' statement
	| FOR '(' declaration expression_statement expression ')' statement


	;

jump_statement
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	
	;

external_declaration
	: function_definition
	| declaration
	
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement

	;

declaration_list
	: declaration
	| declaration_list declaration
	
	;



%%


void startBeamer(){
	beamerFile = fopen( "beamer.tex", "w+" );
	fprintf(beamerFile,"\\documentclass{beamer} \n");
	fprintf(beamerFile, "\\usetheme{Dresden} \n" );
	fprintf(beamerFile, "\\usecolortheme{beaver} \n" );
	fprintf(beamerFile, "\\usepackage{color} \n" );
	fprintf(beamerFile, "\\usepackage[T1]{fontenc} \n" );
	fprintf(beamerFile, "\\usepackage[utf8]{inputenc} \n" );
	fprintf(beamerFile, "\\let\\Tiny=\\tiny \n" );
	fprintf(beamerFile, "\\usepackage{hyperref}\n" );
	fprintf(beamerFile,"\\title{Primer Semestre - Proyecto 3 Analizador Sintáctico} \n");
	fprintf(beamerFile,"\\author { \\texttt { Amanda Solano Astorga } \\texttt { Yasiell Vallejos Gómez } } \n");
	fprintf(beamerFile,"\\date{\\today}\n");
	fprintf(beamerFile,"\\begin{document} \n");
	fprintf(beamerFile,"\\maketitle \n");
	fprintf(beamerFile,"\\begin{frame}[allowframebreaks] \n");
	fprintf(beamerFile,"\\frametitle{ Proceso de Parsing y Herramienta Bison} \n \n");
	fprintf(beamerFile,"El proceso de parsing,es el encargado de revisar que todos los códigos cumplan con la gramatica del lenguaje.");
	fprintf(beamerFile,"La gramatica del lenguaje, es la que dicta las reglas de como van organizados los tokens. \\newline \n");
	fprintf(beamerFile,"\\textbf{Bison} es una herramienta que genera un parse en lenguaje C.");
	fprintf(beamerFile,"Su funcionamiento consiste en declarar la gramatica valida en un lenguaje especifico y decirle que hacer cuando se cumpla con una regla y si no se cumple que se le informe al usuario.Bison puede ser configurado para que indique si desea que se acabe el programa al primer error encontrado o si continua a pesar de este. \n");
	fprintf(beamerFile,"\\end{frame} \n");
	fprintf(beamerFile,"\\begin{frame}[allowframebreaks] \n");
	fprintf(beamerFile,"\\frametitle{Programa Fuente} \n");
}

void endBeamer(){
	fprintf(beamerFile,"\\end{frame} \n");
  fprintf(beamerFile,"\\end{document} \n");
  fclose(beamerFile);
  system("pdflatex beamer.tex");
  remove("tmp.c");
  remove("listo.c");
  remove("errores.txt");
  system("evince beamer.pdf");
}

void writeBeamer(char *_color, char *_word){
  fprintf(beamerFile, "\\textcolor{%s}{ %s } \n", _color, _word);
}

void yyerror(const char *s)
{
	//printf("*** %s\n", s);
}

void lyyerror(YYLTYPE t, char *s)
{
	if (beamer==0){	
 		printf("Line %d:c%d . %s %s \n ", t.first_line, t.first_column, s, yytext);
 	}
	 else{
	 	fprintf(beamerFile,"Line %d:c%d . %s  \n ", t.first_line, t.first_column, s);
	 	beamer_print(1);
	 }
}

void beamer_print(int error){
	if (beamer==1){
		if (error==1 ){
			writeBeamer("red","\\textgreater -");
		}
		else{
			writeBeamer("black",yytext);
		}
	}
}