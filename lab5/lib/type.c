#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "type.h"

static const char* TYPE_STRING[] = {
    "int",
    "real",
    "bool",
    "str",
    "notype"
};

static const char* OP_STRING[] = {
    "+",
    "-",
    "*",
    "/",
    "<",
    "=",
    ":="
};

const char* op2text(Op op){
    return OP_STRING[op];
}

const char* type2text(Type type) {
    return TYPE_STRING[type];
}

const Type text2type(char* typeStr){
    int i;
    for(i=0; i<5; i++){
        if(strcmp(typeStr, TYPE_STRING[i]) != -1){
            return i;
        }
    }
    printf("Type '%s' does not exist\n", typeStr);
    exit(1);
}
