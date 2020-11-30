#include <stdio.h>
#include <stdlib.h>
#include "type.h"

char* get_type_str(Type type){
    switch (type){
        case BOOL_TYPE: return "bool";
        case INT_TYPE:  return "int";
        case REAL_TYPE: return "real";
        case STR_TYPE:  return "string";
        case NO_TYPE:   return "no_type";
        case ERR_TYPE: return "err_type";
        
        default: SWITCH_ERROR(type);
    }
}