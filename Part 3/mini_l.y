%{
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include <string.h>
#include <set> 

int tempCount = 0;
int labelCount = 0;
extern char* yytext; 
extern int currPos; 

std::map<std::string, std::string> varTemp;
std::map<std::string, int> arrSize;
bool main Func = false; 
std::set<std::string> funcs;
std::set<std::string> reserved {"NUMBER", "IDENT", "RETURN", "FUNCTION", "SEMICOLON", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS", "BEGIN_BODY,
    "END_BODY", "BEGINLOOP", "ENDLOOP", "COLON", "INTEGER", "COMMA", "ARRAY", "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "L_PAREN" "R_PAREN", "IF", "ELSE", "THEN", 
    "CONTINUE", "ENDIF", "OF", "READ", "WRITE", "DO", "WHILE", "FOR", "TRUE", "FALSE", "ASSIGN", "EQ", "NEQ", "LT", "LTE", "GT", "GTE", "ADD", "SUB", "MULT", "DIV",
    "MOD", "AND", "OR", "NOT", "Function", "Declarations", "Vars", "Var", "Expressions", "Expression", "Idents", "Ident", "Bool-Expr",
    "Relation-And-Expr", "Relation-Expr-Inv", "Relation-Expr", "Comp", "Multiplicative-Expr", "Term", "Statements", "Statement"};


void yyerror(const char *s);
int yylex();
std::string new_temp();
std::string new_label(); 

/*
extern int curLine;
extern int currPos;
FILE *yyin;
*/
%}

%union{
    int num;
    char* ident;

    struct 5 { 
        char* code; 
    }   statement;
    struct E {
        char* place;
        char* code;
        bool arr;
    }   expression; 
}


/*
%error-verbose
*/
%start Program 
%token <num> NUMBER
%token <ident> IDENT

%type <expression> Function FuncIdent Declarations Declaration Vars Var Expressions Expressions Idents Id... [FINISH ME]
%type <expression> Bool-Expr Relation-And-Expr Relation-Expr-Inv Relation-Expr Comp Multiplicative-Express... [FIXME]
%type <statement> Statements Statement 

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS
BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE FOR DO BEGINLOOP
ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN
L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN RETURN ENUM




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

Program: %empty 
    {
        if (!mainFunc) {
            printf("No main function declared!\n");
        }
    }
    | Function Program
    {
    }
    ;

Function: FUNCTION FuncIdent SEMICOLON BEGIN_PARAMS Declarations END_PARAMS BEGIN_LOCALS Declarations END_LOCALS BEGIN_BODY Statements END_BODY
    { 
        std::string temp = "func ";
        temp.append($2.place);
        temp.append("\n");
        std::string s = $2.place; 
        if(s = "main") {
            mainFunc = true; 
        }

        temp.append($5.code);
        std::string decs = $5.code; 
        int decNum = 0; 
        while(decs.find(".") != std::string::npos) {
            int pos = decs.find(".");
            decs.replace(pos, 1, "=");
            std::string part = ", $" + std::to_string(decNum) + "\n";
            decNum++;
            decs.replace(decs.find("\n", pos), 1, part);
        }
        temp.append(decs);

        temp.append($8.code);
        std::string statements = $11.code; 

        if (statements.find("continue") != std::string::npos) {
            printf("ERROR: Continue outside loop in function %s\n", $2.place);
        }

        temp.append(statements);
        temp.append("endfunc\n\n");
        printf(temp.c_str());
    }
    ;
        

Declarations: Declaration SEMICOLON Declarations 
    {
        std::string temp;
        temp.append($1.code);
        temp.append($3.code);
        $$.code = strdup(temp.c_str());
        $$.place = strdup("");
    }
    | %empty 
    {
        $$.place = strdup("");
        $$.code = strdup("");
    }
    ;

Declaration: identifiers COLON INTEGER 
    {
        int left = 0;
        int right = 0;
        std::string parse($1.place);
        std::string temp;
        bool ex = false;
        while(!ex) {
            right = parse.find("|", left);
            temp.append(". ");

            if (right == std::string::npos) {
                std::string ident = parse.substr(left, right);
                if (reserved.find(ident) != reserved.end()) {
                    printf("Identifier %s's name is a reserved word. \n", ident.c_str());
                }
                if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()) {
                    printf("Identifier %s is previously declared. \n", ident.c_str());
                } else {
                    varTemp[ident] = ident; 
                    arrSize[ident] = 1;
                }
            temp.append(ident);
            ex = true; 
        } else {
            std::string ident = parse.substr(left, right-left);
            if (reserved.find(ident) != reserved.end()) {
                printf("Identifier %s's name is a reserved word.\n", ident.c_str());
            }
            if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()) {
                printf("Identifier %s is previously declared.\n", ident.c_str());
            } else {
                varTemp[ident] = ident; 
                arrSize[ident] = 1;
            }
            temp.append(ident);
            left = right + 1;
        }
        temp.append("\n");
    }
    $$.code = strdup(temp.c_str());
    $$place = strdup("");
    }
    | Idents COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
    {
        size_t left = 0;
        size_t right = 0;
        std::string parse($1.place);
        std::string temp; 
        bool ex = false; 
        while(!ex) {
            right = parse.find("|", left);
            temp.append(".[] ");

            if (right == std::string::npos) { 
                std::string ident = parse.substr(left, right);
                if (reserved.find(ident) != reserved.end()) {
                    printf("Identifier %s's name is a reserved word. \n", ident.c_str());
                }
                if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()) {
                    printf("Identifier %s is previously declared. \n", ident.c_str());
                } else {
                    if ($5 <= 0) {
                        printf("Declaring array ident %s of size <= 0.\n", ident.c_str());
                    }
                    varTemp[ident] = ident;
                    arrSize[ident] = $5;
                }
                temp.append(ident);
                ex = true;
            } else {
                std::string ident = parse.substr(left, right-left);
                if (reserved.find(ident) != reserved.end()) {
                    printf("Identifier %s's name is a reserved word. \n", ident.c_str());
                }
                if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()) {
                    printf("Identifier %s is previously declared. \n", ident.c_str());
                } else {
                    if ($5 <= 0) {
                        printf("Declaring array ident %s of size <= 0.\n", ident.c_str());
                    }
                    varTemp[ident] = ident;
                    arrSize[ident] = $5;
                }
                temp.append(ident);
                left = right + 1; 
            }
            temp.append(", ");
            temp.append(std::to_string($5));
            temp.append("\n");   
        }
        $$.code = strdup(temp.c_str());
        $$.place = strdup("");   
    }
    ;
    /*
            | identifiers COLON ENUM L_PAREN identifiers R_PAREN {printf("declaration -> identifiers COLON ENUM L_PAREN identifiers R_PAREN\n");}
    
     ENUM IS EXTRA CREDIT 
     */
    

FuncIdent: IDENT 
    {
        if (funcs.find($1) != funcs.end()) {
            printf("function name %s already declared.\n", $1);
        }
        else {
            funcs.insert($1);
        }
    $$.place = strdup($1);
    $$.code = strdup(""); 
    }

Ident:      IDENT 
    {
        $$.place = strdup($1); 
        $$.code = strdup();
    }
    ;


Idents:     Ident 
    {
        $$.place = strdup($1.place);
        $$code = strdup("");
    }
    | Ident COMMA Idents 
    {
        std::string temp;
        temp.append($1.place);
        temp.append("|");
        temp.append($3.place);
        $$.place = strdup(temp.c_str());
        $$.code = strdup("");
    }
    ;


Statements: Statement SEMICOLON Statements 
    {
        std::string temp;
        temp.append($1.code);
        temp.append($3.code);
        $$.code = strdup(temp.c_str());
    }
    | Statement SEMICOLON 
    {
        $$.code = strdup($1.code);
    }
    ;

Statement: Var ASSIGN expression
    {
        std::string temp; 
        temp.append($1.code);
        temp.append($3.code);
        std::string middle = $3.place;

        if ($1.arr && $3.arr) {
            temp += "[]= ";
        }
        else if ($1.arr) {
            temp += "[]= ";
        }
        else if ($3.arr) {
            temp += "[]= ";
        }
        else { 

        }
    }

/*
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
*/
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
