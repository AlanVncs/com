#ifndef TYPES_H
#define TYPES_H

#include "debug.h"

typedef enum {
    BOOL_TYPE,
    INT_TYPE,
    REAL_TYPE,
    STR_TYPE,
    NO_TYPE,
    ERR_TYPE
} Type;

char* get_type_str(Type type);

#endif // TYPES_H

