
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "types.h"

static const char *TYPE_STRING[] = {
    "bool",
    "int",
    "real",
    "string"
};

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
