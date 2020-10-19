
#ifndef TYPES_H
#define TYPES_H

typedef enum {
    BOOL_TYPE,
    INT_TYPE,
    REAL_TYPE,
    STR_TYPE
} Type;

const char* typeText(Type type);
const Type textType(char* typeStr);

#endif // TYPES_H
