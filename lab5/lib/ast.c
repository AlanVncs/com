
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "table.h"

// +
static const Unif tableA[4][4] = {
    {{INT_TYPE, NONE, NONE},      {REAL_TYPE, I2R_NODE, NONE}, {INT_TYPE, NONE, B2I_NODE},  {STR_TYPE, I2S_NODE, NONE}},
    {{REAL_TYPE, NONE, I2R_NODE}, {REAL_TYPE, NONE, NONE},     {REAL_TYPE, NONE, B2R_NODE}, {STR_TYPE, R2S_NODE, NONE}},
    {{INT_TYPE, B2I_NODE, NONE},  {REAL_TYPE, B2R_NODE, NONE}, {BOOL_TYPE, NONE, NONE},     {STR_TYPE, B2S_NODE, NONE}},
    {{STR_TYPE, NONE, I2S_NODE},  {STR_TYPE, NONE, R2S_NODE},  {STR_TYPE, NONE, B2S_NODE},  {STR_TYPE, NONE, NONE}}
};

// - * /
static const Unif tableB[4][4] = {
    {{INT_TYPE, NONE, NONE},      {REAL_TYPE, I2R_NODE, NONE}, {ERR_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE}},
    {{REAL_TYPE, NONE, I2R_NODE}, {REAL_TYPE, NONE, NONE},     {ERR_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE}},
    {{ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE}},
    {{ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE}}
};

// < =
static const Unif tableC[4][4] = {
    {{BOOL_TYPE, NONE, NONE},     {BOOL_TYPE, I2R_NODE, NONE}, {ERR_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE}},
    {{BOOL_TYPE, NONE, I2R_NODE}, {BOOL_TYPE, NONE, NONE},     {ERR_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE}},
    {{ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE}},
    {{ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE}, {BOOL_TYPE, NONE, NONE}}
};

// :=
static const Unif tableD[4][4] = {
    {{INT_TYPE, NONE, NONE},      {ERR_TYPE, I2R_NODE, NONE}, {ERR_TYPE, NONE, NONE},  {ERR_TYPE, NONE, NONE}},
    {{REAL_TYPE, NONE, I2R_NODE}, {REAL_TYPE, NONE, NONE},    {ERR_TYPE, NONE, NONE},  {ERR_TYPE, NONE, NONE}},
    {{ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},     {BOOL_TYPE, NONE, NONE}, {ERR_TYPE, NONE, NONE}},
    {{ERR_TYPE, NONE, NONE},      {ERR_TYPE, NONE, NONE},     {ERR_TYPE, NONE, NONE},  {STR_TYPE, NONE, NONE}}
};


Unif get_kinds(Op op, Type lt, Type rt){
    switch(op){
        case PLUS_OP: return tableA[lt][rt];

        case MINUS_OP:
        case TIMES_OP:
        case OVER_OP: return tableB[lt][rt];

        case LT_OP:
        case EQ_OP: return tableC[lt][rt];

        case ASSIGN_OP: return tableD[lt][rt];

        default:
            printf("Error - Unknown operator %s\n", op2text(op));
            exit(EXIT_FAILURE);
    }
}



AST* new_node(Type type, NodeKind kind, ...) {
    AST* node = malloc(sizeof * node);
    node->type = type;
    node->kind = kind;
    node->count = 0;

    va_list ap;
    va_start(ap, kind);

    switch (kind) {
        case BOOL_VAL_NODE:
        case INT_VAL_NODE:
        case STR_VAL_NODE:
        case VAR_DECL_NODE:
        case VAR_USE_NODE: node->data.as_int = va_arg(ap, int); break;

        case REAL_VAL_NODE: node->data.as_float = va_arg(ap, double); break;

        default: break;
    }   

    va_end(ap);
    
    
    for (int i = 0; i < CHILDREN_LIMIT; i++) {
        node->child[i] = NULL;
    }
    return node;
}

AST* add_child(AST* parent, AST* child) {
    if (parent->count == CHILDREN_LIMIT) {
        fprintf(stderr, "Cannot add another child!\n");
        exit(1);
    }
    parent->child[parent->count] = child;
    parent->count++;
    return parent;
}

AST* get_child(AST* parent, int idx) {
    return parent->child[idx];
}

AST* new_subtree(NodeKind kind, Type type, int child_count, ...) {
    if (child_count > CHILDREN_LIMIT) {
        fprintf(stderr, "Too many children as arguments!\n");
        exit(1);
    }

    AST* node = new_node(type, kind, 0);
    va_list ap;
    va_start(ap, child_count);
    for (int i = 0; i < child_count; i++) {
        add_child(node, va_arg(ap, AST*));
    }
    va_end(ap);
    return node;
}

NodeKind get_kind(AST* node) {
    return node->kind;
}

int get_data(AST* node) {
    return node->data.as_int;
}

AST* set_float_data(AST* node, float data) {
    node->data.as_float = data;
    return node;
}

float get_float_data(AST* node) {
    return node->data.as_float;
}

Type get_node_type(AST* node) {
    return node->type;
}

int get_child_count(AST* node) {
    return node->count;
}

void free_tree(AST* tree) {
    if (tree == NULL) return;
    for (int i = 0; i < tree->count; i++) {
        free_tree(tree->child[i]);
    }
    free(tree);
}

// Dot output.

int nr;

extern VarTable* vt;

char* kind2str(NodeKind kind) {
    switch (kind) {
    case ASSIGN_NODE:   return ":=";
    case EQ_NODE:       return "=";
    case BLOCK_NODE:    return "block";
    case BOOL_VAL_NODE: return "";
    case IF_NODE:       return "if";
    case INT_VAL_NODE:  return "";
    case LT_NODE:       return "<";
    case MINUS_NODE:    return "-";
    case OVER_NODE:     return "/";
    case PLUS_NODE:     return "+";
    case PROGRAM_NODE:  return "program";
    case READ_NODE:     return "read";
    case REAL_VAL_NODE: return "";
    case REPEAT_NODE:   return "repeat";
    case STR_VAL_NODE:  return "";
    case TIMES_NODE:    return "*";
    case VAR_DECL_NODE: return "var_decl";
    case VAR_LIST_NODE: return "var_list";
    case VAR_USE_NODE:  return "var_use";
    case WRITE_NODE:    return "write";
    case B2I_NODE:      return "B2I";
    case B2R_NODE:      return "B2R";
    case B2S_NODE:      return "B2S";
    case I2R_NODE:      return "I2R";
    case I2S_NODE:      return "I2S";
    case R2S_NODE:      return "R2S";
    default:            return "ERROR!!";
    }
}

int has_data(NodeKind kind) {
    switch (kind) {
    case BOOL_VAL_NODE:
    case INT_VAL_NODE:
    case REAL_VAL_NODE:
    case STR_VAL_NODE:
    case VAR_DECL_NODE:
    case VAR_USE_NODE:
        return 1;
    default:
        return 0;
    }
}

int print_node_dot(AST* node) {
    int my_nr = nr++;

    fprintf(stderr, "node%d[label=\"", my_nr);
    if (node->type != NO_TYPE) {
        fprintf(stderr, "(%s) ", type2text(node->type));
    }
    if (node->kind == VAR_DECL_NODE || node->kind == VAR_USE_NODE) {
        fprintf(stderr, "%s@", get_name(vt, node->data.as_int));
    }
    else {
        fprintf(stderr, "%s", kind2str(node->kind));
    }
    if (has_data(node->kind)) {
        if (node->kind == REAL_VAL_NODE) {
            fprintf(stderr, "%.2f", node->data.as_float);
        }
        else if (node->kind == STR_VAL_NODE) {
            fprintf(stderr, "@%d", node->data.as_int);
        }
        else {
            fprintf(stderr, "%d", node->data.as_int);
        }
    }
    fprintf(stderr, "\"];\n");

    for (int i = 0; i < node->count; i++) {
        int child_nr = print_node_dot(node->child[i]);
        fprintf(stderr, "node%d -> node%d;\n", my_nr, child_nr);
    }
    return my_nr;
}

AST* print_dot(AST* tree) {
    nr = 0;
    fprintf(stderr, "digraph {\ngraph [ordering=\"out\"];\n");
    print_node_dot(tree);
    fprintf(stderr, "}\n");
    return tree;
}