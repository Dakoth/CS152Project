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
%token <num_val> NUMBER

%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD
/* %right SUB */
%left L_SQUARE_BRACKET R_SQUARE_BRACKET
%left L_PAREN R_PAREN


%%

prog_start: functions { printf("prog_start -> funtions\n");}

functions:
            /*empty*/{printf("functions -> epsilon\n");}
            | function functions {printf("functions -> function functions\n");}
            ;

function:
            FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS
            BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements
            END_BODY {printf("function -> ...\n");}
            ;

declarations:
            /*empty*/ {printf("declarations -> epsilon\n");}
            | declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");}
            ;

declaration:
            identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
            | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers : array [number] of integer\n");}
            | identifiers COLON ENUM L_PAREN identifiers R_PAREN {printf("declaration -> identifiers : enum (identifiers)\n");}
            ;

identifiers:
            IDENT COMMA identifiers {printf("identifiers -> ident, identifiers\n");}
            | IDENT {printf("identifiers -> ident\n");}
            ;

statements:
            statement SEMICOLON statements {printf("statements -> statement; statements\n");}
            | statement SEMICOLON {printf("statements -> statement;\n");}
            ;

statement:
            variable ASSIGN expression {printf("statement -> variable := expression\n");}
            | IF bool_expr THEN statements ENDIF {printf("statement -> if bool_expr then statements endif\n");}
            | IF bool_expr THEN statements ELSE statements ENDIF {printf("statement -> if bool_expr then statements else statements endif\n");}
            | WHILE bool_expr BEGINLOOP statements ENDLOOP {printf("statement -> while bool_expr beginloop statements endloop\n");}
            | DO BEGINLOOP statements ENDLOOP WHILE bool_expr {printf("statement -> do beginloop statements endloop while bool_expr\n");}
            | READ variables {printf("statement -> read variables\n");}
            | WRITE variables {printf("statement -> write variables\n");}
            | CONTINUE {printf("statement -> continue\n");}
            | RETURN expression {printf("statement -> return expression\n");}
            ;

variables:
            variable COMMA variables {printf("variables -> variable, variables\n");}
            | variable {printf("variables -> variable\n");}
            ;

variable:
            IDENT {printf("variable -> ident\n");}
            | IDENT R_SQUARE_BRACKET expression L_SQUARE_BRACKET {printf("variable -> ident[expression]\n");}
            ;

bool_expr:
            mult_rel_and_expr {printf("bool_expr -> multiple-relation-and-expression\n");}
            ;

mult_rel_and_expr:
            rel_and_expr OR mult_rel_and_expr {printf("multiple-relation-and-expression -> relation-and-expression or multiple-relation-and-expression\n");}
            | rel_and_expr {printf("multiple-relation-and-expression -> relation-and-expression\n");}
            ;

rel_and_expr:
            mult_rel_expr {printf("relation-and-expression -> multiple-relation-expression\n");}
            ;

mult_rel_expr:
            relation_expr AND mult_rel_expr {printf("multiple-relation-expression -> relation-expression and multiple-relation-expression\n");}
            | relation_expr {printf("multiple-relation-expression -> relation-expression\n");}
            ;

relation_expr:
            expression comp expression {printf("relation-expression -> expression comp expression\n");}
            | TRUE {printf("relation-expression -> true\n");}
            | FALSE {printf("relation-expression -> false\n");}
            | L_PAREN bool_expr R_PAREN {printf("relation-expression -> (bool_expr)\n");}
            | NOT expression comp expression {printf("relation-expression -> not expression comp expression\n");}
            | NOT TRUE {printf("relation-expression -> not true\n");}
            | NOT FALSE {printf("relation-expression -> not false\n");}
            | NOT L_PAREN bool_expr R_PAREN {printf("relation-expression -> not (bool_expr)\n");}
            ;

comp:
            EQ {printf("comp -> equal to\n");}
            | NEQ {printf("comp -> not-equal-to\n");}
            | LT {printf("comp -> less-than\n");}
            | LTE {printf("comp -> less-than-or-equal-to\n");}
            | GT {printf("comp -> greater-than\n");}
            | GTE {printf("comp -> greater-than-or-equal-to\n");}
            ;

expressions:
            /*empty*/ {printf("expressions -> epsilon\n");}
            | expression COMMA expressions {printf("expressions -> expression, expressions\n");}
            | expression {printf("expressions -> expression\n");}
            ;

expression:
            multiplicative_expression multiplicative_expressions {printf("expression -> multiplicative_expression multiplicative_expressions\n");}
            ;

multiplicative_expressions:
            /*empty*/ {printf("multiplicative_expressions -> epsilon\n");}
            | ADD multiplicative_expression multiplicative_expressions {printf("multiplicative_expressions -> + multiplicative_expression multiplicative_expressions\n");}
            | SUB multiplicative_expression multiplicative_expressions {printf("multiplicative_expressions -> - multiplicative_expression multiplicative_expressions\n");}
            ;

multiplicative_expression:
            term terms {printf("multiplicative_expression -> term terms\n");}
            ;

terms:
            /*empty*/ {printf("terms -> epsilon\n");}
            | MULT term terms {printf("terms -> * term terms\n");}
            | DIV term terms {printf("terms -> / term terms\n");}
            | MOD term terms {printf("terms -> % term terms\n");}
            ;

term:
            variable {printf("term -> variable\n");}
            | NUMBER {printf("term -> number\n");}
            | L_PAREN expression R_PAREN {printf("term -> (expression)\n");}
            | SUB variable {printf("term -> negative variable\n");}
            | SUB NUMBER {printf("term -> negative number\n");}
            | SUB L_PAREN expression R_PAREN {printf("term -> negative (expression)\n");}
            | IDENT L_PAREN expressions R_PAREN {printf("term -> identifier (expressions)\n");}
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
        yylex();
        return 0;

}

void yyerror(const char *msg) {
    
}