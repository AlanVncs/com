
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

struct ast {
    int id;
    NodeKind kind;
    char* name;
    int line;
    Type type;
    double data; // or address
    struct ast** children;
    int children_length;
};

int ast_id = 1;

// Create
AST* new_ast(NodeKind kind, char* name, int line, Type type, double data) {
    AST* new_ast = malloc(sizeof(AST));
    new_ast->id = ast_id++;
    new_ast->kind = kind;
    new_ast->name = NULL;
    set_ast_name(new_ast, name);
    new_ast->line = line;
    new_ast->type = type;
    new_ast->data = data;
    new_ast->children = NULL;
    new_ast->children_length = 0;
    return new_ast;
}

AST* new_ast_subtree(NodeKind kind, char* name, int line, Type type, int child_count, ...){

    AST* parent = new_ast(kind, name, line, type, 0);

    va_list ap;
    va_start(ap, child_count);
    for (int i=0; i<child_count; i++) {
        add_ast_child(parent, va_arg(ap, AST*));
    }
    va_end(ap);

    return parent;
}


// Modify
AST* set_ast_type(AST* ast, Type type){
    CHECK_PTR(ast);
    ast->type = type;
    return ast;
}

AST* add_ast_child(AST* parent, AST* child){
    CHECK_PTR(parent);
    CHECK_PTR(child);

    // Aloca mais espaço quando necessário
    if (parent->children_length%AST_CHILDREN_BLOCK_SIZE == 0) {
        int new_size = AST_CHILDREN_BLOCK_SIZE + parent->children_length;
        parent->children = realloc(parent->children, new_size*sizeof(AST*));
        CHECK_PTR_MSG(parent->children, "Could not reallocate memory");
    }

    parent->children[parent->children_length++] = child;
    return parent;
}

AST* set_ast_name(AST* ast, char* name){
    CHECK_PTR(ast);
    if(name && !ast->name){
        ast->name = malloc(sizeof(char)*strlen(name));
        strcpy(ast->name, name);
    }
    return ast;
}

AST* set_ast_child(AST* ast, int i, AST* child){
    CHECK_PTR(ast);
    CHECK_PTR(child);
    CHECK_BOUNDS(i, ast->children_length);

    ast->children[i] = child;
    return ast;
}


// Output
void print_ast(AST* ast){

    CHECK_PTR(ast);
    NodeKind kind = get_ast_kind(ast);

    printf("-----------  AST  -----------\n");
    printf("ID: %d\n", get_ast_id(ast));
    printf("Kind: %s\n", get_kind_str(kind));
    printf("Type: %s\n", get_type_str(get_ast_type(ast)));
    printf("Name: %s\n", get_ast_name(ast));
    printf("Line: %d\n", get_ast_line(ast));
    printf("Children length: %d\n", get_ast_length(ast));

    printf("Data: ");
    switch(kind){
        case BOOL_VAL_NODE:
            printf("%s (bool)\n", get_ast_data(ast)?"true":"false");
            break;
        
        case INT_VAL_NODE:
            printf("%d (int)\n", (int) get_ast_data(ast));
            break;
        
        case REAL_VAL_NODE:
            printf("%f (real)\n", get_ast_data(ast));
            break;
        
        case STR_VAL_NODE: 
            printf("@%d (string)\n", (int) get_ast_data(ast));
            break;

        default: printf("No data\n");
    }
    printf("-----------------------------\n\n");
}


void gen_ast_dot(AST* ast){
    CHECK_PTR(ast);
    FILE* ast_file = fopen("ast.dot", "w");
    fprintf(ast_file, "digraph {\ngraph [ordering=\"out\"];\n");
    gen_ast_node_dot(ast, ast_file);
    fprintf(ast_file, "}\n");
    fclose(ast_file);
}

void gen_ast_node_dot(AST* node, FILE* ast_file){
    
    CHECK_PTR(node);

    fprintf(ast_file, "node%d[label=\"", node->id);
    switch (node->kind){
        case VAR_DECL_NODE: fprintf(ast_file, "%s %s", get_type_str(get_ast_type(node)), get_ast_name(node));
        break;

        case VAR_USE_NODE: fprintf(ast_file, "%s (%s)", get_ast_name(node), get_type_str(get_ast_type(node)));
        break;

        case BOOL_VAL_NODE: fprintf(ast_file, "%s (bool)", node->data?"true":"false");
        break;

        case INT_VAL_NODE: fprintf(ast_file, "%d (int)", (int) node->data);
        break;

        case REAL_VAL_NODE: fprintf(ast_file, "%0.2f (real)", node->data);
        break;

        case STR_VAL_NODE: fprintf(ast_file, "@%d (string)", (int) node->data);
        break;

        default: fprintf(ast_file, "%s", get_kind_str(node->kind));
        break;
    }
    fprintf(ast_file, "\"];\n");
    
    for (int i=0; i<node->children_length; i++) {
        AST* child = node->children[i];
        if(child){
            gen_ast_node_dot(child, ast_file);
            fprintf(ast_file, "node%d -> node%d;\n", node->id, child->id);
        }
    }
}


// Get
int get_ast_id(AST* ast){
    CHECK_PTR(ast);
    return ast->id;
}

int get_ast_line(AST* ast){
    CHECK_PTR(ast);
    return ast->line;
}

char* get_ast_name(AST* ast){
    CHECK_PTR(ast);
    return ast->name;
}

Type get_ast_type(AST* ast){
    CHECK_PTR(ast);
    return ast->type;
}

NodeKind get_ast_kind(AST* ast){
    CHECK_PTR(ast);
    return ast->kind;
}

double get_ast_data(AST* ast){
    CHECK_PTR(ast);
    return ast->data;
}

int get_ast_length(AST* ast){
    CHECK_PTR(ast);
    return ast->children_length;
}

AST* get_ast_child(AST* ast, int i){
    CHECK_PTR(ast);
    CHECK_BOUNDS(i, ast->children_length);
    return ast->children[i];
}

char* get_op_str(Op op){
    switch (op){
        case ASSIGN_OP:  return ":="; // :=
        case PLUS_OP:    return "+";  // +
        case MINUS_OP:   return "-";  // -
        case TIMES_OP:   return "/";  // /
        case OVER_OP:    return "*";  // *
        case LT_OP:      return "<";  // <
        case EQ_OP:      return "=";  // =
        
        default: SWITCH_ERROR(op);
    }
}

char* get_kind_str(NodeKind kind) {
    switch (kind) {
        case PROGRAM_NODE:       return "program";
        case VAR_DECL_LIST_NODE: return "var_decl_list";
        case VAR_DECL_NODE:      return "var_decl";
        case STMT_LIST_NODE:     return "stmt_list";
        case IF_NODE:            return "if";
        case REPEAT_NODE:        return "repeat";
        case READ_NODE:          return "read";
        case WRITE_NODE:         return "write";

        case ASSIGN_NODE:        return ":=";
        case LT_NODE:            return "<";
        case EQ_NODE:            return "=";
        case PLUS_NODE:          return "+";
        case MINUS_NODE:         return "-";
        case TIMES_NODE:         return "*";
        case OVER_NODE:          return "/";
        
        case VAR_USE_NODE:       return "var_use";
        case BOOL_VAL_NODE:      return "bool_val";
        case INT_VAL_NODE:       return "int_val";
        case REAL_VAL_NODE:      return "real_val";
        case STR_VAL_NODE:       return "str_val";
        case B2I_NODE:           return "bool -> int";
        case B2R_NODE:           return "bool -> real";
        case B2S_NODE:           return "bool -> string";
        case I2R_NODE:           return "int -> real";
        case I2S_NODE:           return "int -> string";
        case R2S_NODE:           return "r2s";
        case NONE:          return "none";
        default: SWITCH_ERROR(kind);
    }
}

