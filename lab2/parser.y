%output "parser.c"          // File name of generated parser.
%defines "parser.h"         // Produces a 'parser.h'
%define parse.error verbose // Give proper messages when a syntax error is found.
%define parse.lac full      // Enable LAC to improve syntax error handling.

%{
#include <stdio.h>
int yylex(void);
void yyerror(char const *s);
%}

%token BGN BOOL ELSE END FALSE IF INT PROGRAM READ REAL REPEAT STRING THEN TRUE UNTIL VAR WRITE;
%token ASSIGN EQ LT PLUS MINUS TIMES OVER LPAR RPAR SEMI;
%token INT_VAL REAL_VAL STR_VAL ID;

%left EQ LT;
%left PLUS MINUS;
%left TIMES OVER;

%%

program: PROGRAM ID SEMI vars-sect stmt-sect;
vars-sect: VAR opt-var-decl;
opt-var-decl: %empty | var-decl-list;
var-decl-list: var-decl-list var-decl | var-decl;
var-decl: type-spec ID SEMI;
type-spec: BOOL | INT | REAL | STRING;
stmt-sect: BGN stmt-list END;
stmt-list: stmt-list stmt | stmt;
stmt: if-stmt | repeat-stmt | assign-stmt | read-stmt | write-stmt;
if-stmt: IF expr THEN stmt-list END | IF expr THEN stmt-list ELSE stmt-list END;
repeat-stmt: REPEAT stmt-list UNTIL expr;
assign-stmt: ID ASSIGN expr SEMI;
read-stmt: READ ID SEMI;
write-stmt: WRITE expr SEMI;
expr: val | ID | expr op expr | LPAR expr RPAR;
val: TRUE | FALSE | INT_VAL | REAL_VAL | STR_VAL;
op: LT | EQ | PLUS | MINUS | TIMES | OVER;
%%

int main(void) {
    if (yyparse() == 0) printf("PARSE SUCCESSFUL!\n");
    else printf("PARSE FAILED!\n");
    return 0;
}