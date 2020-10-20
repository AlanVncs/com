
#ifndef TYPES_H
#define TYPES_H

typedef enum {
    BOOL_TYPE,
    INT_TYPE,
    REAL_TYPE,
    STR_TYPE,
    ERR_TYPE
} Type;

typedef enum {
    LT_OP,    // <
    EQ_OP,    // =
    PLUS_OP,  // +
    MINUS_OP, // -
    TIMES_OP, // /
    OVER_OP,  // *
    ASSIGN_OP // :=
} Op;

const char* opText(Op op);
const char* typeText(Type type);
const Type textType(char* typeStr);
Type resultType(Type lt, Op op, Type rt);

#endif // TYPES_H
