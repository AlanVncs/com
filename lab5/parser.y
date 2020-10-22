%output "parser.c"          // File name of generated parser.
%defines "parser.h"         // Produces a 'parser.h'
%define parse.error verbose // Give proper messages when a syntax error is found.
%define parse.lac full      // Enable LAC to improve syntax error handling.

%code requires {
    #include "lib/ast.h"
}

%{
#include <stdio.h>
#include <stdlib.h>
#include "lib/table.h"
#include "lib/ast.h"

int yylex(void);
void yyerror(char const *s);

extern int yylineno;
extern char* yytext;

StrTable* st = NULL;
VarTable* vt = NULL;

// Op last_expr_op;

void varDecl(char* id, Type type);
Type varType(char* id);
AST* exprAST(NodeKind kind, Op op, AST* l_ast, AST* r_ast);

%}

%define api.value.type {AST*}

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

opt-var-decl: 
  %empty
| var-decl-list
;

var-decl-list: var-decl-list var-decl | var-decl;

var-decl:
      BOOL ID {varDecl(yytext, BOOL_TYPE);} SEMI 
    | INT ID {varDecl(yytext, INT_TYPE);} SEMI
    | REAL ID {varDecl(yytext, REAL_TYPE);} SEMI
    | STRING ID {varDecl(yytext, STR_TYPE);} SEMI
;

stmt-sect: BGN stmt-list END;

stmt-list:
  stmt-list stmt
| stmt
;

stmt: 
  if-stmt
| repeat-stmt
| assign-stmt
| read-stmt
| write-stmt
;

if-stmt:
  IF expr THEN stmt-list END;
| IF expr THEN stmt-list ELSE stmt-list END
;

repeat-stmt: REPEAT stmt-list UNTIL expr;

assign-stmt: ID {varType(yytext);} ASSIGN expr SEMI;

read-stmt: READ ID {varType(yytext);} SEMI;

write-stmt: WRITE expr SEMI;

expr:
  expr PLUS expr  {$$ = (AST*) 0;}
| expr MINUS expr {$$ = (AST*) 0;}
| expr TIMES expr {$$ = (AST*) 0;}
| expr OVER expr  {$$ = (AST*) 0;}
| expr LT expr    {$$ = exprAST(LT_NODE, LT_OP, $1, $3);}
| expr EQ expr    {$$ = (AST*) 0;}
| LPAR expr RPAR  {$$ = $2;}
| TRUE            {$$ = new_node(BOOL_TYPE, BOOL_VAL_NODE, 1);}
| FALSE           {$$ = new_node(BOOL_TYPE, BOOL_VAL_NODE, 0);}
| INT_VAL         {$$ = new_node(INT_TYPE, INT_VAL_NODE, atoi(yytext));}
| REAL_VAL        {$$ = new_node(REAL_TYPE, REAL_VAL_NODE, atof(yytext));}
| STR_VAL         {$$ = new_node(STR_TYPE, STR_VAL_NODE, add_string(st, yytext));}
| ID              {$$ = new_node(varType(yytext), VAR_USE_NODE, lookup_var(vt, yytext));}
;

%%

int main(void) {

    st = create_str_table();
    vt = create_var_table();

    if(yyparse() == 0){
        printf("PARSE SUCCESSFUL!\n");
        printf("\n\n");
        print_str_table(st);
        printf("\n\n");
        print_var_table(vt);
        printf("\n\n");

        free_str_table(st);
        free_var_table(vt);
    }
    else{
        printf("PARSE FAILED!\n");
        exit(EXIT_FAILURE);
    }

    return 0;
}

void varDecl(char* id, Type type){
    int varIndex = lookup_var(vt, id);
    if(varIndex != -1){
        int declLine = get_line(vt, varIndex);
        printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n", yylineno, id, declLine);
        exit(EXIT_FAILURE);
    }
    else{
        add_var(vt, id, yylineno, type);
    }
}

Type varType(char* id){
    int index = lookup_var(vt, id);
    if(index == -1){
        printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n", yylineno, id);
        exit(EXIT_FAILURE);
    }
    return get_type(vt, index);
}

// TODO Nó de conversão
AST* exprAST(NodeKind kind, Op op, AST* l_ast, AST* r_ast){
    Unif unif = get_kinds(op, l_ast->type, r_ast->type);
    if(unif.type == ERR_TYPE){
        printf("SEMANTIC ERROR (%d): incompatible types for operator '%s', LHS is '%s' and RHS is '%s'.\n", yylineno, op2text(op), type2text(l_ast->type), type2text(r_ast->type));
        exit(EXIT_FAILURE);
    }
    AST* a = new_subtree(kind, unif.type, 2, l_ast, r_ast);
    return a;
}

/*
void checkBool(char* cmd, Type type){
    if(type != BOOL_TYPE){
        printf("SEMANTIC ERROR (%d): conditional expression in '%s' is '%s' instead of 'bool'.\n", yylineno, cmd, typeText(type));
        exit(EXIT_FAILURE);
    }
}
*/

// ASSIGN_NODE,
// EQ_NODE,
// BLOCK_NODE,
// BOOL_VAL_NODE,
// IF_NODE,
// INT_VAL_NODE,
// LT_NODE,
// MINUS_NODE,
// OVER_NODE,
// PLUS_NODE,
// PROGRAM_NODE,
// READ_NODE,
// REAL_VAL_NODE,
// REPEAT_NODE,
// STR_VAL_NODE,
// TIMES_NODE,
// VAR_DECL_NODE,
// VAR_LIST_NODE,
// VAR_USE_NODE,
// WRITE_NODE,
// B2I_NODE,
// B2R_NODE,
// B2S_NODE,
// I2R_NODE,
// I2S_NODE,
// R2S_NODE,
// NONE