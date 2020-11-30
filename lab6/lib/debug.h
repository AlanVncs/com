#ifndef DEBUG_H
#define DEBUG_H

// #include <stdio.h>
// #include <stdlib.h>

#define GENERIC_ERROR(format, ...) printf("%s (%d): "format"\n\n", __FILE__, __LINE__, __VA_ARGS__); exit(1)

#define SWITCH_ERROR(expr) GENERIC_ERROR("'%s' does not match any switch case", #expr);

#define CHECK_PTR(ptr); if(!ptr){GENERIC_ERROR("'%s' can't be a null pointer", #ptr);}

#define CHECK_PTR_MSG(ptr, msg); if(!ptr){GENERIC_ERROR("%s ('%s' can't be a null pointer)", msg, #ptr);}

#define CHECK_BOUNDS(idx, length); if(idx<0 || idx>=length){GENERIC_ERROR("Index out of bounds: [0 <= %s < %s]", #idx, #length);}


// DEBUG_H
#endif 