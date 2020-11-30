%output "parser.c"          // File name of generated parser.
%defines "parser.h"         // Produces a 'parser.h'
%define parse.error verbose // Give proper messages when a syntax error is found.
%define parse.lac full      // Enable LAC to improve syntax error handling.

%{
#include <stdio.h>
#include <stdlib.h>
#include "lib/debug.h"
#include "lib/type.h"
#include "lib/table.h"
#include "lib/ast.h"

int yylex(void);
void yyerror(char const *s);
char* yytext;
int yylineno;

char last_id[VARIABLE_MAX_SIZE+1];


VarTable* var_table = NULL;
StrTable* str_table = NULL;
AST* root_ast = NULL;

void decl_var(AST* var_decl);
void check_var(AST* var_use);
void check_bool(AST* expr);
Type eval_expr(AST* expr);
Type eval_operation(AST* operation);

// Semantic error
void already_declared(int line, char* name, int prev_line);
void not_declared(int line, char* name);
void incompatible_types(int line, char* operator, char* l_type, char* r_type);
void not_bool(int line, char* cmd, char* wrong_type);

%}

%define api.value.type {AST*}

%token BGN END PROGRAM VAR;
%token IF THEN ELSE REPEAT UNTIL READ WRITE 
%token BOOL INT REAL STRING;
%token ASSIGN '=' '<' '+' '-' '*' '/' '(' ')' ';';
%token TRUE FALSE INT_VAL REAL_VAL STR_VAL ID;

%%

program:
    PROGRAM ID ';' vars_sect stmt_sect { root_ast=new_ast_subtree(PROGRAM_NODE, NULL, 0, NO_TYPE, 2, $4, $5); }
;

vars_sect:
    VAR opt_var_decl { $$=$2; }
;

opt_var_decl:
    %empty        { $$=new_ast_subtree(VAR_DECL_LIST_NODE, NULL, 0, NO_TYPE, 0); }
  | var_decl_list
;

var_decl_list:
    var_decl_list var_decl { $$=add_ast_child($1, $2); }
  | var_decl               { $$=new_ast_subtree(VAR_DECL_LIST_NODE, NULL, 0, NO_TYPE, 1, $1); }
;

var_decl:
      BOOL ID ';'   { $$=new_ast(VAR_DECL_NODE, last_id, yylineno, BOOL_TYPE, 0); decl_var($$); }
    | INT ID ';'    { $$=new_ast(VAR_DECL_NODE, last_id, yylineno, INT_TYPE, 0); decl_var($$); }
    | REAL ID ';'   { $$=new_ast(VAR_DECL_NODE, last_id, yylineno, REAL_TYPE, 0); decl_var($$); }
    | STRING ID ';' { $$=new_ast(VAR_DECL_NODE, last_id, yylineno, STR_TYPE, 0); decl_var($$); }
;

stmt_sect:
    BGN stmt_list END { $$=$2; }
;

stmt_list:
    stmt_list stmt { $$=add_ast_child($1, $2); }
  | stmt           { $$=new_ast_subtree(STMT_LIST_NODE, NULL, 0, NO_TYPE, 1, $1); }
;

stmt: 
    if_stmt
  | repeat_stmt
  | read_stmt
  | write_stmt
  | assign_stmt
;

if_stmt:
    IF expr THEN stmt_list END                { $$=new_ast_subtree(IF_NODE, NULL, get_ast_line($2), NO_TYPE, 2, $2, $4); check_bool($$); }
  | IF expr THEN stmt_list ELSE stmt_list END { $$=new_ast_subtree(IF_NODE, NULL, get_ast_line($2), NO_TYPE, 2, $2, $4, $6); check_bool($$); }
;

repeat_stmt:
    REPEAT stmt_list UNTIL expr { $$=new_ast_subtree(REPEAT_NODE, NULL, get_ast_line($2), NO_TYPE, 2, $2, $4); check_bool($$); }
;

read_stmt:
    READ var_use ';' { $$=new_ast_subtree(READ_NODE, NULL, get_ast_line($2), NO_TYPE, 1, $2); }
;

write_stmt:
    WRITE expr ';' { $$=new_ast_subtree(WRITE_NODE, NULL, get_ast_line($2), NO_TYPE, 1, $2); }
;

assign_stmt:
    var_use ASSIGN expr ';' { $$=new_ast_subtree(ASSIGN_NODE, NULL, get_ast_line($1), NO_TYPE, 2, $1, $3); eval_operation($$); }
;

expr:
    logical_expr { eval_expr($$); }
;

logical_expr:
    additive_expr
  | logical_expr '<' additive_expr { $$=new_ast_subtree(LT_NODE, NULL, get_ast_line($1), NO_TYPE, 2, $1, $3); }
  | logical_expr '=' additive_expr { $$=new_ast_subtree(EQ_NODE, NULL, get_ast_line($1), NO_TYPE, 2, $1, $3); }
;

additive_expr:
    multiplicative_expr
  | additive_expr '+' multiplicative_expr { $$=new_ast_subtree(PLUS_NODE, NULL, get_ast_line($1), NO_TYPE, 2, $1, $3); }
  | additive_expr '-' multiplicative_expr { $$=new_ast_subtree(MINUS_NODE, NULL, get_ast_line($1), NO_TYPE, 2, $1, $3); }
;

multiplicative_expr:
    primary_expr
  | multiplicative_expr '*' primary_expr { $$=new_ast_subtree(TIMES_NODE, NULL, get_ast_line($1), NO_TYPE, 2, $1, $3); }
  | multiplicative_expr '/' primary_expr { $$=new_ast_subtree(OVER_NODE, NULL, get_ast_line($1), NO_TYPE, 2, $1, $3); }
;

primary_expr:
    var_use
  | constant_expr
  | '(' expr ')'  { $$=$2; }
;

var_use:
    ID   { $$=new_ast(VAR_USE_NODE, last_id, yylineno, NO_TYPE, 0); check_var($$); }
;

constant_expr:
    TRUE        { $$=new_ast(BOOL_VAL_NODE, NULL, yylineno, BOOL_TYPE, 1); }
  | FALSE       { $$=new_ast(BOOL_VAL_NODE, NULL, yylineno, BOOL_TYPE, 0); }
  | INT_VAL     { $$=new_ast(INT_VAL_NODE, NULL, yylineno, INT_TYPE, atoi(yytext)); }
  | REAL_VAL    { $$=new_ast(REAL_VAL_NODE, NULL, yylineno, REAL_TYPE, atof(yytext)); }
  | STR_VAL     { $$=new_ast(STR_VAL_NODE, NULL, yylineno, STR_TYPE, add_table_str(str_table, yytext)); }
;

%%


int main(void) {

    var_table = new_var_table();
    str_table = new_str_table();

    yyparse();
    print_str_table(str_table);
    print_var_table(var_table);
    gen_ast_dot(root_ast);
    free_str_table(str_table);
    free_var_table(var_table);


    return 0;
}

void decl_var(AST* var_decl){

    AST* found_ast = lookup_table_var(var_table, var_decl);

    // Variável já existe
    if(found_ast) already_declared(get_ast_line(var_decl), get_ast_name(var_decl), get_ast_line(found_ast));

    add_table_var(var_table, var_decl);
    
}

void check_var(AST* var_use){

    AST* found_ast = lookup_table_var(var_table, var_use);

    // Variável não existe
    if(!found_ast) not_declared(get_ast_line(var_use), get_ast_name(var_use));

    set_ast_type(var_use, get_ast_type(found_ast));
}

void check_bool(AST* expr){
    Type expr_type = get_ast_type(expr);
    if(expr_type != BOOL_TYPE){
        int test = get_ast_kind(expr) == IF_NODE;
        not_bool(get_ast_line(expr), test?"if":"repeat", get_type_str(expr_type));
    }
}

Type eval_expr(AST* expr){
    int expr_type = get_ast_type(expr);

    if(get_ast_length(expr) == 2 && expr_type == NO_TYPE){
        // Operarion * / + - < =
        return eval_operation(expr);
    }
    else{
        // Primary expression
        return expr_type;
    }
}

Type eval_operation(AST* operation){

    // +
    static const Unif tableA[4][4] = {
        {{BOOL_TYPE, NONE, NONE},     {INT_TYPE, B2I_NODE, NONE},  {REAL_TYPE, B2R_NODE, NONE}, {STR_TYPE, B2S_NODE, NONE}},
        {{INT_TYPE, NONE, B2I_NODE},  {INT_TYPE, NONE, NONE},      {REAL_TYPE, I2R_NODE, NONE}, {STR_TYPE, I2S_NODE, NONE}},
        {{REAL_TYPE, NONE, B2R_NODE}, {REAL_TYPE, NONE, I2R_NODE}, {REAL_TYPE, NONE, NONE},     {STR_TYPE, R2S_NODE, NONE}},
        {{STR_TYPE, NONE, B2S_NODE},  {STR_TYPE, NONE, I2S_NODE},  {STR_TYPE, NONE, R2S_NODE},  {STR_TYPE, NONE, NONE}}
    };

    // - * /
    static const Unif tableB[4][4] = {
        {{ERR_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE}},
        {{ERR_TYPE, NONE, NONE}, {INT_TYPE, NONE, NONE},      {REAL_TYPE, I2R_NODE, NONE}, {ERR_TYPE, NONE, NONE}},
        {{ERR_TYPE, NONE, NONE}, {REAL_TYPE, NONE, I2R_NODE}, {REAL_TYPE, NONE, NONE},     {ERR_TYPE, NONE, NONE}},
        {{ERR_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE}}
    };

    // < =
    static const Unif tableC[4][4] = {
        {{ERR_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE}},
        {{ERR_TYPE, NONE, NONE}, {BOOL_TYPE, NONE, NONE},     {BOOL_TYPE, I2R_NODE, NONE}, {ERR_TYPE, NONE, NONE}},
        {{ERR_TYPE, NONE, NONE}, {BOOL_TYPE, NONE, I2R_NODE}, {BOOL_TYPE, NONE, NONE},     {ERR_TYPE, NONE, NONE}},
        {{ERR_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},      {BOOL_TYPE, NONE, NONE}}
    };

    // :=
    static const Unif tableD[4][4] = {
        {{BOOL_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},  {ERR_TYPE, NONE, NONE}},
        {{ERR_TYPE, NONE, NONE},  {INT_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},  {ERR_TYPE, NONE, NONE}},
        {{ERR_TYPE, NONE, NONE},  {REAL_TYPE, NONE, I2R_NODE}, {REAL_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE}},
        {{ERR_TYPE, NONE, NONE},  {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},  {STR_TYPE, NONE, NONE}}
    };

    AST* l_ast = get_ast_child(operation, 0);
    AST* r_ast = get_ast_child(operation, 1);
    
    Type l_type = eval_expr(l_ast);
    Type r_type = eval_expr(r_ast);

    NodeKind op_kind = get_ast_kind(operation);

    Unif unif;
    Op operator;
    
    switch(op_kind){
        case PLUS_NODE:
            operator = PLUS_OP;
            unif = tableA[l_type][r_type];
            break;

        case MINUS_NODE:
            operator = MINUS_OP;
            unif = tableB[l_type][r_type];
            break;

        case TIMES_NODE:
            operator = TIMES_OP;
            unif = tableB[l_type][r_type];
            break;

        case OVER_NODE:
            operator = OVER_OP;
            unif = tableB[l_type][r_type];
            break;

        case LT_NODE:
            operator = LT_OP;
            unif = tableC[l_type][r_type]; break;
            break;

        case EQ_NODE:
            operator = EQ_OP;
            unif = tableC[l_type][r_type];
            break;

        case ASSIGN_NODE:
            operator = ASSIGN_OP;
            unif = tableD[l_type][r_type];
            break;

        default: SWITCH_ERROR(op_kind);
    }

    if(unif.type == ERR_TYPE) incompatible_types(get_ast_line(operation), get_op_str(operator), get_type_str(l_type), get_type_str(r_type));

    set_ast_type(operation, unif.type);

    // Adiciona nós de conversão quando necessário
    l_ast = (unif.lnk == NONE) ? l_ast : new_ast_subtree(unif.lnk, get_ast_name(l_ast), get_ast_line(l_ast), get_ast_type(l_ast), 1, l_ast);
    r_ast = (unif.rnk == NONE) ? r_ast : new_ast_subtree(unif.rnk, get_ast_name(r_ast), get_ast_line(r_ast), get_ast_type(r_ast), 1, r_ast);


    set_ast_child(operation, 0, l_ast);
    set_ast_child(operation, 1, r_ast);

    return unif.type;
}


// Semantic error
void already_declared(int line, char* name, int prev_line){
    printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n", line, name, prev_line);
    exit(0);
}

void not_declared(int line, char* name){
    printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n", line, name);
    exit(0);
}

void incompatible_types(int line, char* operator, char* l_type, char* r_type){
    printf("SEMANTIC ERROR (%d): incompatible types for operator '%s', LHS is '%s' and RHS is '%s'.\n", line, operator, l_type, r_type);
    exit(0);
}

void not_bool(int line, char* cmd, char* wrong_type){
    printf("SEMANTIC ERROR (%d): conditional expression in '%s' is '%s' instead of 'bool'.\n",line, cmd, wrong_type);
    exit(0);
}