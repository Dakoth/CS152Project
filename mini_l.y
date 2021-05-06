%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char *msg);
extern int currLine;
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
%type <num_val> NUMBER

%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD
%right SUB
%left L_SQUARE_BRACKET R_SQUARE_BRACKET
%left L_PAREN R_PAREN


%%

prog_start: functions { printf("prog_start -> funtions\n");}

functions: /*empty*/{printf("functions -> epsilon\n");}
    | function functions {printf("functions -> function functions\n");}
    ;

function:   FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS
            BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements
            END_BODY {printf("function -> ...\n");}
            ;

declarations:  /*empty*/ {printf("declarations -> epsilon\n");}
                | declaration SERMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");}
                ;

declaration: identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
            | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers : array [number] of integer\n");}
            | /*identifiers COLON ENUM L_PAREN identifiers R_PAREN {printf("declarations -> identifiers : enum (identifiers)\n");} */
            ;
