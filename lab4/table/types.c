
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "types.h"

static const char* TYPE_STRING[] = {
    "bool",
    "int",
    "real",
    "str",
    "error_type"
};

static const char* OP_STRING[] = {
    "<",
    "=",
    "+",
    "-",
    "*",
    "/",
    ":="
};

const char* opText(Op op){
    return OP_STRING[op];
}

const char* typeText(Type type) {
    return TYPE_STRING[type];
}

const Type textType(char* typeStr){
    int i;
    for(i=0; i<4; i++){
        if(strcmp(typeStr, TYPE_STRING[i]) != -1){
            return i;
        }
    }
    printf("Type '%s' does not exists\n", typeStr);
    exit(1);
}

// +
static const Type typeTableA[][4] = {
                                                  //   b i r s
    {BOOL_TYPE,  INT_TYPE,  REAL_TYPE, STR_TYPE}, // b b i r s
    {INT_TYPE,   INT_TYPE,  REAL_TYPE, STR_TYPE}, // i i i r s
    {REAL_TYPE,  REAL_TYPE, REAL_TYPE, STR_TYPE}, // r r r r s
    {STR_TYPE,   STR_TYPE,  STR_TYPE,  STR_TYPE}  // s s s s s
};

// - * /
static const Type typeTableB[][4] = {
                                                //   b i r s
    {ERR_TYPE, ERR_TYPE,  ERR_TYPE,  ERR_TYPE}, // b e e e e
    {ERR_TYPE, INT_TYPE,  REAL_TYPE, ERR_TYPE}, // i e i r e
    {ERR_TYPE, REAL_TYPE, REAL_TYPE, ERR_TYPE}, // r e r r e
    {ERR_TYPE, ERR_TYPE,  ERR_TYPE,  ERR_TYPE}  // s e e e e
};

// <
static const Type typeTableC[][4] = {
                                                //   b i r s
    {ERR_TYPE, ERR_TYPE,  ERR_TYPE,  ERR_TYPE}, // b e e e e
    {ERR_TYPE, BOOL_TYPE, BOOL_TYPE, ERR_TYPE}, // i e b b e
    {ERR_TYPE, BOOL_TYPE, BOOL_TYPE, ERR_TYPE}, // r e b b e
    {ERR_TYPE, ERR_TYPE,  ERR_TYPE,  BOOL_TYPE} // s e e e b
};

// =
static const Type typeTableD[][4] = {
                                                 //   b i r s
    {BOOL_TYPE, ERR_TYPE,  ERR_TYPE,  ERR_TYPE}, // b b e e e
    {ERR_TYPE,  BOOL_TYPE, BOOL_TYPE, ERR_TYPE}, // i e b b e
    {ERR_TYPE,  BOOL_TYPE, BOOL_TYPE, ERR_TYPE}, // r e b b e
    {ERR_TYPE,  ERR_TYPE,  ERR_TYPE,  BOOL_TYPE} // s e e e b
};

// :=
static const Type typeTableE[][4] = {
                                                 //   b i r s
    {BOOL_TYPE, ERR_TYPE,  ERR_TYPE,  ERR_TYPE}, // b b e e e
    {ERR_TYPE,  INT_TYPE,  ERR_TYPE,  ERR_TYPE}, // i e i e e
    {ERR_TYPE,  REAL_TYPE, REAL_TYPE, ERR_TYPE}, // r e r r e
    {ERR_TYPE,  ERR_TYPE,  ERR_TYPE,  STR_TYPE}  // s e e e s
};

Type resultType(Type lt, Op op, Type rt){
    switch(op){
        case PLUS_OP: return typeTableA[lt][rt];

        case MINUS_OP:
        case TIMES_OP:
        case OVER_OP: return typeTableB[lt][rt];

        case LT_OP: return typeTableC[lt][rt];

        case EQ_OP: return typeTableD[lt][rt];

        case ASSIGN_OP: return typeTableE[lt][rt];

        default: return ERR_TYPE;
    }
}