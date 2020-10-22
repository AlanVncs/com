#ifndef AST_H
#define AST_H

#include "type.h"

#define CHILDREN_LIMIT 20 // Don't try this at home, kids... :P

typedef enum {
    ASSIGN_NODE,
    EQ_NODE,
    BLOCK_NODE,
    BOOL_VAL_NODE,
    IF_NODE,
    INT_VAL_NODE,
    LT_NODE,
    MINUS_NODE,
    OVER_NODE,
    PLUS_NODE,
    PROGRAM_NODE,
    READ_NODE,
    REAL_VAL_NODE,
    REPEAT_NODE,
    STR_VAL_NODE,
    TIMES_NODE,
    VAR_DECL_NODE,
    VAR_LIST_NODE,
    VAR_USE_NODE,
    WRITE_NODE,
    B2I_NODE,
    B2R_NODE,
    B2S_NODE,
    I2R_NODE,
    I2S_NODE,
    R2S_NODE,
    NONE
} NodeKind;

typedef struct {
    Type type;
    NodeKind lnk;
    NodeKind rnk;
} Unif;

struct ast {
    NodeKind kind;
    union {
        int as_int;
        double as_float;
    } data;
    Type type;
    int count;
    struct ast* child[CHILDREN_LIMIT];
};

typedef struct ast AST;

Unif get_kinds(Op op, Type lt, Type rt);

AST* new_node(Type type, NodeKind kind, ...);

AST* add_child(AST* parent, AST* child);
AST* get_child(AST* parent, int idx);

AST* new_subtree(NodeKind kind, Type type, int child_count, ...);

NodeKind get_kind(AST* node);
char* kind2str(NodeKind kind);

int get_data(AST* node);
AST* set_float_data(AST* node, float data);
float get_float_data(AST* node);

Type get_node_type(AST* node);
int get_child_count(AST* node);

void print_tree(AST* ast);
AST* print_dot(AST* ast);

void free_tree(AST* ast);

#endif
