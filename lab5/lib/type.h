
#ifndef TYPES_H
#define TYPES_H

typedef enum {
    INT_TYPE,
    REAL_TYPE,
    BOOL_TYPE,
    STR_TYPE,
    NO_TYPE,
    ERR_TYPE
} Type;

typedef enum {
    PLUS_OP,  // +
    MINUS_OP, // -
    TIMES_OP, // /
    OVER_OP,  // *
    LT_OP,    // <
    EQ_OP,    // =
    ASSIGN_OP // :=
} Op;

const char* op2text(Op op);
const char* type2text(Type type);
const Type text2type(char* typeStr);

#endif // TYPES_H

