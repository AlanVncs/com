
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "table.h"

// Strings Table
// ----------------------------------------------------------------------------

struct strTable {
    char** table;
    int table_length;
};



// Create
StrTable* new_str_table(){
    StrTable* str_table = malloc(sizeof(StrTable));
    str_table->table = NULL;
    str_table->table_length = 0;
    return str_table;
}

void free_str_table(StrTable* str_table){
    for (int i=0; i<str_table->table_length; i++) {
        free(get_table_str(str_table, i));
    }
    free(str_table->table);
    free(str_table);
}


// Modify
int add_table_str(StrTable* str_table, char* str){

    CHECK_PTR(str_table);
    CHECK_PTR(str);

    // Aloca mais espaço quando necessário
    if (str_table->table_length%STRING_BLOCK_SIZE == 0) {
        int new_size = STRING_BLOCK_SIZE + str_table->table_length;
        str_table->table = realloc(str_table->table, new_size*sizeof(char*));
        CHECK_PTR_MSG(str_table->table, "Could not reallocate memory");
    }

    int str_length = strlen(str);
    str_table->table[str_table->table_length] = malloc(sizeof(char)*(str_length+1));
    strcpy(str_table->table[str_table->table_length], str);
    return str_table->table_length++;
}


// Get
char* get_table_str(StrTable* str_table, int i){
    CHECK_PTR(str_table);
    CHECK_BOUNDS(i, str_table->table_length);
    return str_table->table[i];
}


// Output
void print_str_table(StrTable* str_table){
    printf("-------------------  Strings  -------------------\n");
    for (int i=0; i<str_table->table_length; i++) {
        printf("Entry %d -- %s\n", i, get_table_str(str_table, i));
    }
    printf("-------------------------------------------------\n\n");
}





// Variables Table
// ----------------------------------------------------------------------------

struct varTable {
    AST** table;
    int table_length;
};

// Create
VarTable* new_var_table(){
    VarTable* var_table = malloc(sizeof(VarTable));
    var_table->table = NULL;
    var_table->table_length = 0;
    return var_table;
}

void free_var_table(VarTable* var_table){
    free(var_table->table);
    free(var_table);
}


// Modify
int add_table_var(VarTable* var_table, AST* ast){

    CHECK_PTR(var_table);
    CHECK_PTR(ast);

    // Aloca mais espaço quando necessário
    if (var_table->table_length%VAR_BLOCK_SIZE == 0) {
        int new_size = VAR_BLOCK_SIZE + var_table->table_length;
        var_table->table = realloc(var_table->table, new_size*sizeof(AST*));
        CHECK_PTR_MSG(var_table->table, "Could not reallocate memory");
    }

    var_table->table[var_table->table_length++] = ast;
    
    return var_table->table_length-1;
}


// Output
void print_var_table(VarTable* var_table){
    printf("---------------------  Variables  ---------------------\n");
    for(int i=0; i<var_table->table_length; i++) {
        AST* ast = var_table->table[i];
        printf("Entry %d -- name: %s, line: %d, type: %s\n", i, get_ast_name(ast), get_ast_line(ast), get_type_str(get_ast_type(ast)));
    }
    printf("-------------------------------------------------------\n\n");
}



// Get
AST* get_table_var(VarTable* var_table, int i){
    CHECK_PTR(var_table);
    CHECK_BOUNDS(i, var_table->table_length);
    return var_table->table[i];
}

AST* lookup_table_var(VarTable* var_table, AST* ast){
    int ast_length = get_var_table_length(var_table);
    char* ast_name = get_ast_name(ast);
    for(int i=0; i<ast_length; i++){
        char* found_ast_name = get_ast_name(var_table->table[i]);
        if(strcmp(ast_name, found_ast_name) == 0) return var_table->table[i];
    }
    return NULL;
}

int get_var_table_length(VarTable* var_table){
    CHECK_PTR(var_table);
    return var_table->table_length;
}

//---------------------------------------------------------------------------------------------







