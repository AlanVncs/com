
#ifndef TABLES_H
#define TABLES_H

#include "debug.h"
#include "type.h"
#include "ast.h"



// Strings Table -------------------------------------
#define STRING_BLOCK_SIZE 50

typedef struct strTable StrTable;

// Create
StrTable* new_str_table();
void free_str_table(StrTable* str_table);

// Modify
int add_table_str(StrTable* str_table, char* str);

// Get
char* get_table_str(StrTable* str_table, int i);

// Output
void print_str_table(StrTable* str_table);
//----------------------------------------------------




// Var Table -----------------------------------------
#define VAR_BLOCK_SIZE 10
#define VARIABLE_MAX_SIZE 128

typedef struct varTable VarTable;

// Create
VarTable* new_var_table();
void free_var_table(VarTable* var_table);

// Modify
int add_table_var(VarTable* var_table, AST* ast);

// Output
void print_var_table(VarTable* var_table);

// Get
AST* get_table_var(VarTable* var_table, int i);
AST* lookup_table_var(VarTable* var_table, AST* ast);
int get_var_table_length(VarTable* var_table);
//----------------------------------------------------

#endif // TABLES_H