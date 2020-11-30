#ifndef AST_H
#define AST_H

#include "debug.h"
#include "type.h"

#define AST_CHILDREN_BLOCK_SIZE 10

typedef enum {

    PROGRAM_NODE,
    VAR_DECL_LIST_NODE,
    VAR_DECL_NODE,
    STMT_LIST_NODE,
    IF_NODE,
    REPEAT_NODE,
    READ_NODE,
    WRITE_NODE,
    ASSIGN_NODE, // :=
    LT_NODE,     // <
    EQ_NODE,     // =
    PLUS_NODE,   // +
    MINUS_NODE,  // -
    TIMES_NODE,  // *
    OVER_NODE,   // /
    VAR_USE_NODE,
    BOOL_VAL_NODE,
    INT_VAL_NODE,
    REAL_VAL_NODE,
    STR_VAL_NODE,
    B2I_NODE,
    B2R_NODE,
    B2S_NODE,
    I2R_NODE,
    I2S_NODE,
    R2S_NODE,
    NONE
} NodeKind;

typedef enum {
    ASSIGN_OP, // :=
    PLUS_OP,  // +
    MINUS_OP, // -
    TIMES_OP, // /
    OVER_OP,  // *
    LT_OP,    // <
    EQ_OP     // =
} Op;

typedef struct {
    Type type;
    NodeKind lnk;
    NodeKind rnk;
} Unif;

typedef struct ast AST;

// Create
AST* new_ast(NodeKind kind, char* name, int line, Type type, double data);
AST* new_ast_subtree(NodeKind kind, char* name, int line, Type type, int child_count, ...);

// Modify
AST* set_ast_type(AST* ast, Type type);
AST* add_ast_child(AST* parent, AST* child);
AST* set_ast_name(AST* ast, char* name);
AST* set_ast_child(AST* ast, int i, AST* child);


// Output
void print_ast(AST* ast);
void gen_ast_dot(AST* ast);
void gen_ast_node_dot(AST* node, FILE* ast_file);

// Get
int get_ast_id(AST* ast);
int get_ast_line(AST* ast);
char* get_ast_name(AST* ast);
Type get_ast_type(AST* ast);
NodeKind get_ast_kind(AST* ast);
double get_ast_data(AST* ast);
int get_ast_length(AST* ast);
AST* get_ast_child(AST* ast, int i);
char* get_op_str(Op op);
char* get_kind_str(NodeKind kind);

#endif
