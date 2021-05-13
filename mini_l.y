%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char *msg);
extern int curLine;
extern int currPos;
FILE *yyin;
%}

%union{
    int num_val;
    char* id_val;
}

%error-verbose
%start prog_start
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS
BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE FOR DO BEGINLOOP
ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN
L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN RETURN ENUM


%token <id_val> IDENT
%token <num_val> NUMBER

%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD
/* %right SUB
%left L_SQUARE_BRACKET R_SQUARE_BRACKET
%left L_PAREN R_PAREN
*/

%%

prog_start: functions { printf("prog_start -> functions\n");}

functions:
            /*empty*/{printf("functions -> epsilon\n");}
            | function functions {printf("functions -> function functions\n");}
            ;

function:
            FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS
            BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements
            END_BODY {printf("function ->FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
            ;

declarations:
            /*empty*/ {printf("declarations -> epsilon\n");}
            | declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");}
            ;

declaration:
            identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
            | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
            | identifiers COLON ENUM L_PAREN identifiers R_PAREN {printf("declaration -> identifiers COLON ENUM L_PAREN identifiers R_PAREN\n");}
            ;

identifiers:
            ident COMMA identifiers {printf("identifiers -> ident COMMA identifiers\n");}
            | ident {printf("identifiers -> ident \n");}
            ;

ident:      IDENT {printf("ident -> IDENT %s\n", $1);}
        ;

statements:
            statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
            | statement SEMICOLON {printf("statements -> statement SEMICOLON\n");}
            ;

statement:
            variable ASSIGN expression {printf("statement -> variable ASSIGN expression\n");}
            | IF boolean_expression THEN statements ENDIF {printf("statement -> IF boolean_expression THEN statements ENDIF\n");}
            | IF boolean_expression THEN statements ELSE statements ENDIF {printf("statement -> IF boolean_expression THEN statements ELSE statements ENDIF\n");}
            | WHILE boolean_expression BEGINLOOP statements ENDLOOP {printf("statement -> WHILE boolean_expression BEGINLOOP statements ENDLOOP\n");}
            | DO BEGINLOOP statements ENDLOOP WHILE boolean_expression {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE boolean_expression\n");}
            | READ variables {printf("statement -> READ variables\n");}
            | WRITE variables {printf("statement -> WRITE variables\n");}
            | CONTINUE {printf("statement -> CONTINUE\n");}
            | RETURN expression {printf("statement -> RETURN expression\n");}
            ;

variables:
            variable COMMA variables {printf("variables -> variable COMMA variables\n");}
            | variable {printf("variables -> variable\n");}
            ;

variable:
            ident {printf("variable -> ident \n");}
            | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("variable -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
            ;



boolean_expression:
            multiple-relation-and-expression {printf("boolean_expression -> multiple-relation-and-expression\n");}
            ;

multiple-relation-and-expression:
            relation-and-expression OR multiple-relation-and-expression {printf("multiple-relation-and-expression -> relation-and-expression OR multiple-relation-and-expression\n");}
            | relation-and-expression {printf("multiple-relation-and-expression -> relation-and-expression\n");}
            ;

relation-and-expression:
            multiple-relation-expression {printf("relation-and-expression -> multiple-relation-expression\n");}
            ;

multiple-relation-expression:
            relation_expression AND multiple-relation-expression {printf("multiple-relation-expression -> relation_expression AND multiple-relation-expression\n");}
            | relation_expression {printf("multiple-relation-expression -> relation-expression\n");}
            ;

relation_expression:
            expression comp expression {printf("relation-expression -> expression comp expression\n");}
            | TRUE {printf("relation-expression -> TRUE\n");}
            | FALSE {printf("relation-expression -> FALSE\n");}
            | L_PAREN boolean_expression R_PAREN {printf("relation-expression -> L_PAREN boolean_expression R_PAREN\n");}
            | NOT expression comp expression {printf("relation-expression -> NOT expression comp expression\n");}
            | NOT TRUE {printf("relation-expression -> NOT TRUE\n");}
            | NOT FALSE {printf("relation-expression -> NOT FALSE\n");}
            | NOT L_PAREN boolean_expression R_PAREN {printf("relation-expression -> NOT L_PAREN boolean_expression R_PAREN\n");}
            ;

comp:
            EQ {printf("comp -> EQ\n");}
            | NEQ {printf("comp -> NEQ\n");}
            | LT {printf("comp -> LT\n");}
            | LTE {printf("comp -> LTE\n");}
            | GT {printf("comp -> GT\n");}
            | GTE {printf("comp -> GTE\n");}
            ;

expressions:
            /*empty*/ {printf("expressions -> epsilon\n");}
            | expression COMMA expressions {printf("expressions -> expression COMMA expressions\n");}
            | expression {printf("expressions -> expression\n");}
            ;

expression:
            multiplicative_expression multiplicative_expressions {printf("expression -> multiplicative_expression multiplicative_expressions\n");}
            ;

multiplicative_expressions:
            /*empty*/ {printf("multiplicative_expressions -> epsilon\n");}
            | ADD multiplicative_expression multiplicative_expressions {printf("multiplicative_expressions -> ADD multiplicative_expression multiplicative_expressions\n");}
            | SUB multiplicative_expression multiplicative_expressions {printf("multiplicative_expressions -> SUB multiplicative_expression multiplicative_expressions\n");}
            ;

multiplicative_expression:
            term terms {printf("multiplicative_expression -> term terms\n");}
            ;

terms:
            /*empty*/ {printf("terms -> epsilon\n");}
            | MULT term terms {printf("terms -> MULT term terms\n");}
            | DIV term terms {printf("terms -> DIV term terms\n");}
            | MOD term terms {printf("terms -> MOD term terms\n");}
            ;

term:
            variable {printf("term -> variable\n");}
            | NUMBER {printf("term -> NUMBER\n");}
            | L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n");}
            | SUB variable {printf("term -> SUB variable\n");}
            | SUB NUMBER {printf("term -> SUB NUMBER\n");}
            | SUB L_PAREN expression R_PAREN {printf("term -> SUB L_PAREN expression R_PAREN\n");}
            | ident L_PAREN expressions R_PAREN {printf("term -> ident L_PAREN expressions R_PAREN\n");}
            ;

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
        /*
        yylex();
        */
        yyparse();
        return 0;

}


void yyerror(const char *msg) {
    extern int curLine;
    extern int currPos;
    printf("error: %s in line %d, column %d\n", msg, curLine, currPos);
}
