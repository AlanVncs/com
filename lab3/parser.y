%output "parser.c"          // File name of generated parser.
%defines "parser.h"         // Produces a 'parser.h'
%define parse.error verbose // Give proper messages when a syntax error is found.
%define parse.lac full      // Enable LAC to improve syntax error handling.

%{
#include <stdio.h>
#include <stdlib.h>
#include "table/tables.h"

int yylex(void);
void yyerror(char const *s);
void varDecl(char* id, Type type);
void varCheck(char* id);

extern int yylineno;
extern char* yytext;

StrTable* strTable = NULL;
VarTable* varTable = NULL;
%}

%union {
    int type;
    char* str;
}

%token BOOL INT REAL STRING;
%token BGN ELSE END FALSE IF PROGRAM READ REPEAT THEN TRUE UNTIL VAR WRITE;
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
var-decl: type-spec ID SEMI { varDecl($<str>2, $<type>1); };
type-spec: BOOL | INT | REAL | STRING;
stmt-sect: BGN stmt-list END;
stmt-list: stmt-list stmt | stmt;
stmt: if-stmt | repeat-stmt | assign-stmt | read-stmt | write-stmt;
if-stmt: IF expr THEN stmt-list END | IF expr THEN stmt-list ELSE stmt-list END;
repeat-stmt: REPEAT stmt-list UNTIL expr;
assign-stmt: ID ASSIGN expr SEMI { varCheck($<str>1); };
read-stmt: READ ID SEMI  { varCheck($<str>2); };
write-stmt: WRITE expr SEMI;
expr: val | ID { varCheck($<str>1); } | LPAR expr RPAR;
expr: expr LT expr | expr EQ expr | expr PLUS expr | expr MINUS expr | expr TIMES expr | expr OVER expr;
val: TRUE | FALSE | INT_VAL | REAL_VAL | STR_VAL;
%%

int main(void) {

    strTable = create_str_table();
    varTable = create_var_table();

    if(yyparse() == 0){
        printf("PARSE SUCCESSFUL!\n");
        printf("\n\n");
        print_str_table(strTable);
        printf("\n\n");
        print_var_table(varTable);
        printf("\n\n");

        free_str_table(strTable);
        free_var_table(varTable);
    }
    else{
        printf("PARSE FAILED!\n");
        exit(EXIT_FAILURE);
    }

    return 0;
}

void varDecl(char* id, Type type){
    int varIndex = lookup_var(varTable, id);
    if(varIndex != -1){
        int declLine = get_line(varTable, varIndex);
        printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n", yylineno, id, declLine);
        exit(EXIT_FAILURE);
    }
    else{
        add_var(varTable, id, yylineno, type);
    }
}

void varCheck(char* id){
    int declLine = lookup_var(varTable, id);
    if(declLine == -1){
        
        printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n", yylineno, id);
        exit(EXIT_FAILURE);
    }
}