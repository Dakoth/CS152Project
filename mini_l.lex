%{
    int curLine=1, currPos=1;
	int numIntegers = 0;
	int numOperators = 0;
	int numParens = 0;
	int numEquals = 0;
%}

DIGIT [0-9]
ID [a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]
CHAR [a-zA-Z]
E_ID_1 [0-9][a-zA-Z0-9_]*
E_ID_2 [a-zA-Z][a-zA-Z0-9_]*[_]

%%


"##"[^\n]*"\n"  curLine++; currPos = 1; 

function    {printf("FUNCTION\n"); currPos += yyleng;}
beginparams {printf("BEGIN_PARAMS\n"); currPos += yyleng;}
endparams   {printf("END_PARAMS\n"); currPos += yyleng;}
beginlocals {printf("BEGIN_LOCALS\n"); currPos += yyleng;}
endlocals   {printf("END_LOCALS\n"); currPos += yyleng;}
beginbody   {printf("BEGIN_BODY\n"); currPos += yyleng;}
endbody     {printf("END_BODY\n"); currPos += yyleng;}
integer     {printf("INTEGER\n"); currPos += yyleng;}
array       {printf("ARRAY\n"); currPos += yyleng;}
enum        {printf("ENUM\n"); currPos += yyleng;}
of          {printf("OF\n"); currPos += yyleng;}
if          {printf("IF\n"); currPos += yyleng;}
then        {printf("THEN\n"); currPos += yyleng;}
endif       {printf("ENDIF\n"); currPos += yyleng;}
else        {printf("ELSE\n"); currPos += yyleng;}
while       {printf("WHILE\n"); currPos += yyleng;}
do          {printf("DO\n"); currPos += yyleng;}
beginloop   {printf("BEGINLOOP\n"); currPos += yyleng;}
endloop     {printf("ENDLOOP\n"); currPos += yyleng;}
continue    {printf("CONTINUE\n"); currPos += yyleng;}
read        {printf("READ\n"); currPos += yyleng;}
write       {printf("WRITE\n"); currPos += yyleng;}
or          {printf("OR\n"); currPos += yyleng;}
not         {printf("NOT\n"); currPos += yyleng;}
true        {printf("TRUE\n"); currPos += yyleng;}
false       {printf("FALSE\n"); currPos += yyleng;}
return      {printf("RETURN\n"); currPos += yyleng;}


"-"         {printf("SUB\n"); currPos += yyleng; }
"+"         {printf("ADD\n"); currPos += yyleng;}
"*"         {printf("MULT\n"); currPos += yyleng;}
"/"         {printf("DIV\n"); currPos += yyleng;}
"%"         {printf("MOD\n"); currPos += yyleng; }

"=="        {printf("EQ\n"); currPos += yyleng; }
"<>"        {printf("NEQ\n"); currPos += yyleng; }
"<"         {printf("LT\n"); currPos += yyleng; }
">"         {printf("GT\n"); currPos += yyleng; }
"<="        {printf("LTE\n"); currPos += yyleng; }
">="        {printf("GTE\n"); currPos += yyleng; }



{DIGIT}+    {printf("NUMBER %s\n", yytext); currPos += yyleng;}
{ID}        {printf("IDENT %s\n", yytext);  currPos+= yyleng;}
{CHAR}      {printf("IDENT %s\n", yytext);  currPos+= yyleng;} /* for chars */

";"         {printf("SEMICOLON\n"); currPos += yyleng; }
":"         {printf("COLON\n"); currPos += yyleng; }
","         {printf("COMMA\n"); currPos += yyleng; }
"("         {printf("L_PAREN\n"); currPos += yyleng; }
")"         {printf("R_PAREN\n"); currPos += yyleng; }
"["         {printf("L_SQUARE_BRACKET\n"); currPos += yyleng; }
"]"         {printf("R_SQUARE_BRACKET\n"); currPos += yyleng; }
":="        {printf("ASSIGN\n"); currPos += yyleng; }


[ \t]+  {/* ignore spaces and comments*/ currPos+=yyleng;}
"\n" {curLine++; currPos=1;}

{E_ID_1} {printf("Error at line %d, column  %d: identifier, \"%s\" must begin with a letter\n",curLine, currPos, yytext); exit(0);}

{E_ID_2} {printf("Error at line %d, column  %d: identifier, \"%s\" cannot end with an underscore\n",curLine, currPos, yytext); exit(0);}

. {printf("Error at line %d, column  %d; unrecognized symbol \"%s\"\n",curLine, currPos, yytext); exit(0);}
%%

int main(int argc, char** argv){
        if(argc>=2)
        {
        yyin=fopen(argv[1], "r");
        if(yyin==NULL){
        yyin=stdin;
        }
        }
        else
        {
        yyin=stdin;
        }
        yylex();

    /*
	printf("# Integers: %d\n", numIntegers);
	printf("# Operators: %d\n", numOperators);
	printf("# Parentheses: %d\n", numParens);
	printf("# Equal Sign: %d\n", numEquals);
    */

}

