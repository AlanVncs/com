%output "parser.c"          // File name of generated parser.
%defines "parser.h"         // Produces a 'parser.h'
%define parse.error verbose // Give proper messages when a syntax error is found.
%define parse.lac full      // Enable LAC to improve syntax error handling.

%code requires {
    #include "table/types.h"
    typedef struct {
        Type type;
        Op op;
        char* str;
    } Bundle;
}

%{
#include <stdio.h>
#include <stdlib.h>
#include "table/tables.h"

int yylex(void);
void yyerror(char const *s);
void varDecl(char* id, Type type);
int varCheck(char* id);
Type varType(char* id);
Type exprType(Type lt, Op op, Type rt);
void checkBool(char* cmd, Type type);

extern int yylineno;
extern char* yytext;

StrTable* strTable = NULL;
VarTable* varTable = NULL;
%}

%define api.value.type {Bundle}

%token BOOL INT REAL STRING;
%token BGN ELSE END FALSE IF PROGRAM READ REPEAT THEN TRUE UNTIL VAR WRITE;
%token ASSIGN EQ LT PLUS MINUS TIMES OVER LPAR RPAR SEMI;
%token INT_VAL REAL_VAL STR_VAL ID;


%left EQ LT;
%left PLUS MINUS;
%left TIMES OVER;

%precedence P

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
if-stmt: IF expr THEN stmt-list END { checkBool("if", $<type>2); };
if-stmt: IF expr THEN stmt-list ELSE stmt-list END { checkBool("repeat", $<type>2); };
repeat-stmt: REPEAT stmt-list UNTIL expr { checkBool("repeat", $<type>4); };
assign-stmt: ID ASSIGN expr SEMI { exprType(varType($<str>1), ASSIGN_OP, $<type>3); };
read-stmt: READ ID SEMI { varType($<str>2); };
write-stmt: WRITE expr SEMI;
expr: val | ID { $<type>$ = varType($<str>1); } | LPAR expr RPAR { $<type>$ = $<type>2; };
expr: expr op expr { $<type>$ = exprType($<type>1, $<op>2, $<type>3); } %prec P;
op: LT | EQ | PLUS | MINUS | TIMES | OVER;
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

Type varType(char* id){
    int index = lookup_var(varTable, id);
    if(index == -1){
        printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n", yylineno, id);
        exit(EXIT_FAILURE);
    }
    return get_type(varTable, index);
}

Type exprType(Type lt, Op op, Type rt){
    Type type = resultType(lt, op, rt);
    if(type == ERR_TYPE){
        printf("SEMANTIC ERROR (%d): incompatible types for operator '%s', LHS is '%s' and RHS is '%s'.\n", yylineno, opText(op), typeText(lt), typeText(rt));
        exit(EXIT_FAILURE);
    }
    return type;
}

void checkBool(char* cmd, Type type){
    if(type != BOOL_TYPE){
        printf("SEMANTIC ERROR (%d): conditional expression in '%s' is '%s' instead of 'bool'.\n", yylineno, cmd, typeText(type));
        exit(EXIT_FAILURE);
    }
}