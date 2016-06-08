%{
    #include <stdio.h>
    #include "parser.tab.c"
    extern int sym_type(const char *);  
    extern int yylineno;
    #define sym_type(identifier) IDENTIFIER
    static void comment(void);
    static int check_type(void);
    int yyparse(void);

    #define YY_USER_ACTION update_loc();
    static void update_loc(){
      static int curr_line = 1;
      static int curr_col  = 1;

      yylloc.first_line   = curr_line;
      yylloc.first_column = curr_col;

      {char * s; for(s = yytext; *s != '\0'; s++){
        if(*s == '\n'){
          curr_line++;
          curr_col = 1;
        }else{
          curr_col++;
        }
      }}

      yylloc.last_line   = curr_line;
      yylloc.last_column = curr_col-1; }

%}
%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117
O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\([\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\f]


%%
\n { }
"/*"                                    { comment(); }
"//".*                                    { /* consume //-comment */ }

"auto"					{beamer_print(0);return(AUTO);  }
"break"					{beamer_print(0);return(BREAK); }
"case"					{beamer_print(0);return(CASE); }
"char"					{beamer_print(0);return(CHAR); }
"const"					{beamer_print(0);return(CONST); }
"continue"				{beamer_print(0);return(CONTINUE); }
"default"				{beamer_print(0);return(DEFAULT); }
"do"					{beamer_print(0);return(DO); }
"double"				{beamer_print(0);return(DOUBLE); }
"else"					{beamer_print(0);return(ELSE); }
"enum"					{beamer_print(0);return(ENUM); }
"extern"				{beamer_print(0);return(EXTERN); }
"float"					{beamer_print(0);return(FLOAT); }
"for"					{beamer_print(0);return(FOR); }
"goto"					{beamer_print(0);return(GOTO); }
"if"					{beamer_print(0);return(IF); }
"inline"				{beamer_print(0);return(INLINE); }
"int"					{beamer_print(0);return(INT); }
"long"					{beamer_print(0);return(LONG); }
"register"				{beamer_print(0);return(REGISTER); }
"restrict"				{beamer_print(0);return(RESTRICT); }
"return"				{beamer_print(0);return(RETURN); }
"short"					{beamer_print(0);return(SHORT); }
"signed"				{beamer_print(0);return(SIGNED); }
"sizeof"				{beamer_print(0);return(SIZEOF); }
"static"				{beamer_print(0);return(STATIC); }
"struct"				{beamer_print(0);return(STRUCT); }
"switch"				{beamer_print(0);return(SWITCH); }
"typedef"				{beamer_print(0);return(TYPEDEF); }
"union"					{beamer_print(0);return(UNION); }
"unsigned"				{beamer_print(0);return(UNSIGNED); }
"void"					{beamer_print(0);return(VOID); }
"volatile"				{beamer_print(0);return(VOLATILE); }
"while"					{beamer_print(0);return(WHILE); }

{L}{A}*					{beamer_print(0);return check_type(); }

{HP}{H}+{IS}?				{beamer_print(0);return I_CONSTANT; }
{NZ}{D}*{IS}?				{beamer_print(0);return I_CONSTANT; }
"0"{O}*{IS}?				{beamer_print(0);return I_CONSTANT; }
{CP}?"'"([^'\\\n]|{ES})+"'"		{beamer_print(0);return I_CONSTANT; }

{D}+{E}{FS}?				{beamer_print(0);return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?			{beamer_print(0);return F_CONSTANT; }
{D}+"."{E}?{FS}?			{beamer_print(0);return F_CONSTANT; }
{HP}{H}+{P}{FS}?			{beamer_print(0);return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?			{beamer_print(0);return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?			{beamer_print(0);return F_CONSTANT; }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{beamer_print(0);return STRING_LITERAL; }

"..."					{beamer_print(0);return ELLIPSIS; }
">>="					{beamer_print(0);return RIGHT_ASSIGN; }
"<<="					{beamer_print(0);return LEFT_ASSIGN; }
"+="					{beamer_print(0);return ADD_ASSIGN; }
"-="					{beamer_print(0);return SUB_ASSIGN; }
"*="					{beamer_print(0);return MUL_ASSIGN; }
"/="					{beamer_print(0);return DIV_ASSIGN; }
"%="					{beamer_print(0);return MOD_ASSIGN; }
"&="					{beamer_print(0);return AND_ASSIGN; }
"^="					{beamer_print(0);return XOR_ASSIGN; }
"|="					{beamer_print(0);return OR_ASSIGN; }
">>"					{beamer_print(0);return RIGHT_OP; }
"<<"					{beamer_print(0);return LEFT_OP; }
"++"					{beamer_print(0);return INC_OP; }
"--"					{beamer_print(0);return DEC_OP; }
"->"					{beamer_print(0);return PTR_OP; }
"&&"					{beamer_print(0);return AND_OP; }
"||"					{beamer_print(0);return OR_OP; }
"<="					{beamer_print(0);return LE_OP; }
">="					{beamer_print(0);return GE_OP; }
"=="					{beamer_print(0);return EQ_OP; }
"!="					{beamer_print(0);return NE_OP; }
";"					{beamer_print(0);return ';'; }
("{"|"<%")				{beamer_print(0);return '{'; }
("}"|"%>")				{beamer_print(0);return '}'; }
","					{beamer_print(0);return ','; }
":"					{beamer_print(0);return ':'; }
"="					{beamer_print(0);return '='; }
"("					{beamer_print(0);return '('; }
")"					{beamer_print(0);return ')'; }
("["|"<:")				{beamer_print(0);return '['; }
("]"|":>")				{beamer_print(0);return ']'; }
"."					{beamer_print(0);return '.'; }
"&"					{beamer_print(0);return '&'; }
"!"					{beamer_print(0);return '!'; }
"~"					{beamer_print(0);return '~'; }
"-"					{beamer_print(0);return '-'; }
"+"					{beamer_print(0);return '+'; }
"*"					{beamer_print(0);return '*'; }
"/"					{beamer_print(0);return '/'; }
"%"					{beamer_print(0);return '%'; }
"<"					{beamer_print(0);return '<'; }
">"					{beamer_print(0);return '>'; }
"^"					{beamer_print(0);return '^'; }
"|"					{beamer_print(0);return '|'; }
"?"					{beamer_print(0);return '?'; }

{WS}+					{ /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }

%%



int yywrap(void)        /* called at end of input */
{
               /* terminate now */
}

static void comment(void)
{
    int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;

            if (c == '/')
                return;

            if (c == 0)
                break;
        }
    yyerror("unterminated comment");
}

extern void beamer_print(int x);
extern int beamer;
extern FILE * tmp;

static int check_type(void)
{
    switch (sym_type(yytext))
    {
    case TYPEDEF_NAME:                /* previously defined */
        return TYPEDEF_NAME;
    case ENUMERATION_CONSTANT:        /* previously defined */
        return ENUMERATION_CONSTANT;
    default:                          /* includes undefined */
        return IDENTIFIER;
    }
}

int  main(int  num_args , char** args) {
    if(num_args  != 3) {printf("usage: ./ parser1  filename\n"); exit (0);}
        FILE* file = fopen(args[1],"r");
        if (strcmp(args[2],"-B")){
            tmp = fopen("errores.txt","w+");
            beamer=1;
        }
    if(file == NULL) {printf("couldn 't open %s\n", args [1]);  exit (0);}
        yyin = file;   // now  flex  reads  from  file
        yyparse();
        fclose(file);

        
}


