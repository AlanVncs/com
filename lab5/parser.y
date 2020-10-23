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

AST* aux = NULL;

int ast_stack_levels[100] = {0};
int asl_index = 0;

AST* ast_stack[100];
int ast_stack_len = 0;

int varDecl(char* id, Type type);
Type varType(char* id);
AST* exprAST(NodeKind kind, Op op, AST* l_ast, AST* r_ast);
void checkBool(char* cmd, AST* ast);
void newStackLevel();
void pushAST(AST* ast);
AST* unstackAST(NodeKind kind);

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

program: PROGRAM ID SEMI vars_sect stmt_sect {$$ = new_subtree(NO_TYPE, PROGRAM_NODE, 2, $4, $5); print_dot($$);};

vars_sect: VAR opt_var_decl {$$ = $2;};

opt_var_decl: 
  %empty        {$$ = unstackAST(VAR_LIST_NODE);}
| var_decl_list
;

var_decl_list:
    var_decl_list_body {$$ = unstackAST(VAR_LIST_NODE);}
;

var_decl_list_body:
    var_decl_list_body var_decl {pushAST($2);}
  | var_decl                    {newStackLevel(); pushAST($1);}
;

var_decl:
      BOOL ID   {aux = new_node(BOOL_TYPE, VAR_DECL_NODE, varDecl(yytext, BOOL_TYPE));} SEMI {$$ = aux;}
    | INT ID    {aux = new_node(INT_TYPE, VAR_DECL_NODE, varDecl(yytext, INT_TYPE));}   SEMI {$$ = aux;}
    | REAL ID   {aux = new_node(REAL_TYPE, VAR_DECL_NODE, varDecl(yytext, REAL_TYPE));} SEMI {$$ = aux;}
    | STRING ID {aux = new_node(STR_TYPE, VAR_DECL_NODE, varDecl(yytext, STR_TYPE));}   SEMI {$$ = aux;}
;

stmt_sect:
    BGN stmt_list END {$$ = $2;}
;

stmt_list:
    stmt_list_body {$$ = unstackAST(BLOCK_NODE);}
;

stmt_list_body:
    stmt_list_body stmt {pushAST($2);}
  | stmt                {newStackLevel(); pushAST($1);}
;

stmt: 
    if_stmt
  | repeat_stmt
  | assign_stmt
  | read_stmt
  | write_stmt
;

if_stmt:
    IF expr THEN stmt_list END                {checkBool("if", $2); $$ = new_subtree(NO_TYPE, IF_NODE, 2, $2, $4);};
  | IF expr THEN stmt_list ELSE stmt_list END {checkBool("if", $2); $$ = new_subtree(NO_TYPE, IF_NODE, 3, $2, $4, $6);}
;

repeat_stmt:
    REPEAT stmt_list UNTIL expr {checkBool("repeat", $4); $$ = new_subtree(NO_TYPE, REPEAT_NODE, 2, $2, $4);}
;

assign_stmt:
    var_use ASSIGN expr SEMI {$$ = exprAST(ASSIGN_NODE, ASSIGN_OP, $1, $3);}
;

read_stmt:
    READ var_use SEMI {$$ = new_subtree(NO_TYPE, READ_NODE, 1, $2);}
;

write_stmt:
    WRITE expr SEMI {$$ = new_subtree(NO_TYPE, WRITE_NODE, 1, $2);}
;

expr:
    LPAR expr RPAR  {$$ = $2;}
  | expr PLUS expr  {$$ = exprAST(PLUS_NODE, PLUS_OP, $1, $3);}
  | expr MINUS expr {$$ = exprAST(MINUS_NODE, MINUS_OP, $1, $3);}
  | expr TIMES expr {$$ = exprAST(TIMES_NODE, TIMES_OP, $1, $3);}
  | expr OVER expr  {$$ = exprAST(OVER_NODE, OVER_OP, $1, $3);}
  | expr LT expr    {$$ = exprAST(LT_NODE, LT_OP, $1, $3);}
  | expr EQ expr    {$$ = exprAST(EQ_NODE, EQ_OP, $1, $3);}
  | TRUE            {$$ = new_node(BOOL_TYPE, BOOL_VAL_NODE, 1);}
  | FALSE           {$$ = new_node(BOOL_TYPE, BOOL_VAL_NODE, 0);}
  | INT_VAL         {$$ = new_node(INT_TYPE, INT_VAL_NODE, atoi(yytext));}
  | REAL_VAL        {$$ = new_node(REAL_TYPE, REAL_VAL_NODE, atof(yytext));}
  | STR_VAL         {$$ = new_node(STR_TYPE, STR_VAL_NODE, add_string(st, yytext));}
  | var_use
;

var_use:
    ID {$$ = new_node(varType(yytext), VAR_USE_NODE, lookup_var(vt, yytext));}
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

int varDecl(char* id, Type type){
    int varIndex = lookup_var(vt, id);
    if(varIndex != -1){
        int declLine = get_line(vt, varIndex);
        printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n", yylineno, id, declLine);
        exit(EXIT_FAILURE);
    }
    return add_var(vt, id, yylineno, type);
}

Type varType(char* id){
    int index = lookup_var(vt, id);
    if(index == -1){
        printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n", yylineno, id);
        exit(EXIT_FAILURE);
    }
    return get_type(vt, index);
}

AST* exprAST(NodeKind kind, Op op, AST* l_ast, AST* r_ast){
    Unif unif = get_kinds(op, l_ast->type, r_ast->type);
    if(unif.type == ERR_TYPE){
        printf("SEMANTIC ERROR (%d): incompatible types for operator '%s', LHS is '%s' and RHS is '%s'.\n", yylineno, op2text(op), type2text(l_ast->type), type2text(r_ast->type));
        exit(EXIT_FAILURE);
    }

    // Adiciona nós de conversão quando necessário
    l_ast = (unif.lnk != NONE) ? new_subtree(unif.type, unif.lnk, 1, l_ast) : l_ast;
    r_ast = (unif.rnk != NONE) ? new_subtree(unif.type, unif.rnk, 1, r_ast) : r_ast;

    return new_subtree(unif.type, kind, 2, l_ast, r_ast);
}

void checkBool(char* cmd, AST* ast){
    if(ast->type != BOOL_TYPE){
        printf("SEMANTIC ERROR (%d): conditional expression in '%s' is '%s' instead of 'bool'.\n", yylineno, cmd, type2text(ast->type));
        exit(EXIT_FAILURE);
    }
}

void newStackLevel(){
    ast_stack_levels[asl_index] = ast_stack_len;
    asl_index++;
}

void pushAST(AST* ast){
    ast_stack[ast_stack_len] = ast;
    ast_stack_len++;
}

AST* unstackAST(NodeKind kind){
    AST* ast = new_node(NO_TYPE, kind, 0);
    if(asl_index == 0) return ast;
    asl_index--;
    int i;
    for(i=ast_stack_levels[asl_index]; i<ast_stack_len; i++){
        add_child(ast, ast_stack[i]);
    }
    ast_stack_len = ast_stack_levels[asl_index];

    return ast;
}