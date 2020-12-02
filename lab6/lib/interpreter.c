
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "interpreter.h"

// ----------------------------------------------------------------------------

extern StrTable *st;
extern VarTable *vt;

typedef union {
    int   as_int;
    float as_float;
} Word;

// ----------------------------------------------------------------------------

// Data stack -----------------------------------------------------------------

#define STACK_SIZE 100

Word stack[STACK_SIZE];
int sp; // stack pointer

// All these ops should have a boundary check, buuuut... X_X

void pushi(int x) {
    stack[++sp].as_int = x;
}

int popi() {
    return stack[sp--].as_int;
}

void pushf(float x) {
    stack[++sp].as_float = x;
}

float popf() {
    return stack[sp--].as_float;
}

void init_stack() {
    for (int i = 0; i < STACK_SIZE; i++) {
        stack[i].as_int = 0;
    }
    sp = -1;
}

void print_stack() {
    printf("*** STACK: ");
    for (int i = 0; i <= sp; i++) {
        printf("%d ", stack[i].as_int);
    }
    printf("\n");
}

// ----------------------------------------------------------------------------

// Variables memory -----------------------------------------------------------

#define MEM_SIZE 100

Word mem[MEM_SIZE];

void storei(int addr, int val) {
    mem[addr].as_int = val;
}

int loadi(int addr) {
    return mem[addr].as_int;
}

void storef(int addr, float val) {
    mem[addr].as_float = val;
}

float loadf(int addr) {
    return mem[addr].as_float;
}

void init_mem() {
    for (int addr = 0; addr < MEM_SIZE; addr++) {
        mem[addr].as_int = 0;
    }
}

// ----------------------------------------------------------------------------

// make trace = #define TRACE
#ifdef TRACE
#define trace() printf("TRACE: %s\n", __FUNC__)
#else
#define trace()
#endif

#define MAX_STR_SIZE 128
static char str_buf[MAX_STR_SIZE];
#define clear_str_buf() str_buf[0] = '\0'

void rec_run_ast(AST *ast);

void read_int(int var_idx) {
    int x;
    printf("read (int): ");
    scanf("%d", &x);
    storei(var_idx, x);
}

void read_real(int var_idx) {
    float x;
    printf("read (real): ");
    scanf("%f", &x);
    storef(var_idx, x);
}

void read_bool(int var_idx) {
    int x;
    do {
        printf("read (bool - 0 = false, 1 = true): ");
        scanf("%d", &x);
    } while (x != 0 && x != 1);
    storei(var_idx, x);
}

void read_str(int var_idx) {
    printf("read (str): ");
    clear_str_buf();
    scanf("%s", str_buf);   // Did anyone say Buffer Overflow..? ;P
    storei(var_idx, add_table_str(st, str_buf));
}

void write_int() {
    printf("%d\n", popi());
}

void write_real() {
    printf("%f\n", popf());
}

void write_bool() {
    popi() == 0 ? printf("false\n") : printf("true\n");
}

// Helper function to write strings.
void escape_str(const char* s, char *n) {
    int i = 0, j = 0;
    char c;
    while ((c = s[i++]) != '\0') {
        if (c == '"') { continue; }
        else if (c == '\\' && s[i] == 'n') {
            n[j++] = '\n';
            i++;
        } else {
            n[j++] = c;
        }
    }
    n[j] = '\0';
}

void write_str() {
    int s = popi(); // String pointer
    clear_str_buf();
    escape_str(get_table_str(st, s), str_buf);
    printf("%s", str_buf); // Weird language semantics, if printing a string, no new line.
}

// ----------------------------------------------------------------------------

// DONE
void run_assign(AST *ast) {
    trace();
    AST* var_use = get_ast_child(ast, 0);
    rec_run_ast(get_ast_child(ast, 1));
    if(get_ast_type(var_use)==REAL_TYPE) storef(get_ast_data(var_use), popf());
    else                                 storei(get_ast_data(var_use), popi());
}

// DONE
void run_stmt_list(AST *ast) {
    trace();
    for(int i=0; i<get_ast_length(ast); i++){
        rec_run_ast(get_ast_child(ast, i));
    }
}

// DONE
void run_bool_val(AST *ast) {
    trace();
    pushi(get_ast_data(ast));
}

// DONE
void run_eq(AST *ast) {
    trace();
    AST* l_expr = get_ast_child(ast, 0);
    AST* r_expr = get_ast_child(ast, 1);
    rec_run_ast(r_expr);
    rec_run_ast(l_expr);
    Type type = get_ast_type(l_expr);
    if(type == STR_TYPE){
        char* l_str = get_table_str(st, popi());
        char* r_str = get_table_str(st, popi());
        pushi(!strcmp(l_str, r_str) ? 1 : 0);
    }
    else if(type == REAL_TYPE){
        pushi((popf()==popf()) ? 1 : 0);
    }
    else{
        pushi((popi()==popi()) ? 1 : 0);
    }
}

// DONE
void run_if(AST *ast) {
    trace();

    AST* expr = get_ast_child(ast, 0);
    AST* then_stmt = get_ast_child(ast, 1);
    AST* else_stmt = get_ast_child(ast, 2);

    rec_run_ast(expr);

    if(popi()) rec_run_ast(then_stmt);
    else       rec_run_ast(else_stmt);
}

// DONE
void run_int_val(AST *ast) {
    trace();
    pushi(get_ast_data(ast));
}

// DONE
void run_lt(AST *ast) {
    trace();
    AST* l_expr = get_ast_child(ast, 0);
    AST* r_expr = get_ast_child(ast, 1);
    rec_run_ast(r_expr);
    rec_run_ast(l_expr);
    Type type = get_ast_type(l_expr);
    if(type == STR_TYPE){
        char* l_str = get_table_str(st, popi());
        char* r_str = get_table_str(st, popi());
        pushi(strcmp(l_str, r_str)<0 ? 1 : 0);
    }
    else if(type == REAL_TYPE){
        pushi((popf()<popf()) ? 1 : 0);
    }
    else{
        pushi((popi()<popi()) ? 1 : 0);
    }
}

// DONE
void run_minus(AST *ast) {
    trace();
    AST* l_expr = get_ast_child(ast, 0);    
    AST* r_expr = get_ast_child(ast, 1);
    rec_run_ast(r_expr);
    rec_run_ast(l_expr);
    if(get_ast_type(l_expr) == REAL_TYPE) pushf(popf()-popf());
    else                                  pushi(popi()-popi());
}

// DONE
void run_over(AST *ast) {
    trace();
    AST* l_expr = get_ast_child(ast, 0);    
    AST* r_expr = get_ast_child(ast, 1);
    rec_run_ast(r_expr);
    rec_run_ast(l_expr);
    if(get_ast_type(l_expr) == REAL_TYPE) pushf(popf()/popf());
    else                                  pushi(popi()/popi());
}

// DONE
void run_plus(AST *ast) {
    trace();
    AST* l_expr = get_ast_child(ast, 0);    
    AST* r_expr = get_ast_child(ast, 1);
    Type type = get_ast_type(l_expr);
    rec_run_ast(r_expr);
    rec_run_ast(l_expr);
    if(type == STR_TYPE){
        char* l_str = get_table_str(st, popi());
        char* r_str = get_table_str(st, popi());
        clear_str_buf();
        sprintf(str_buf, "%s%s", l_str, r_str);
        pushi(add_table_str(st, str_buf));
    }
    else if(type == REAL_TYPE){
        pushf(popf()+popf());
    }
    else{
        pushi(popi()+popi());
    }
}

void run_program(AST *ast) {
    trace();
    rec_run_ast(get_ast_child(ast, 0)); // run var_list
    rec_run_ast(get_ast_child(ast, 1)); // run block
}

// DONE
void run_read(AST *ast) {
    trace();
    AST* var_use = get_ast_child(ast, 0);
    int var_use_addr = get_ast_data(var_use);
    switch (get_ast_type(var_use)){
        case BOOL_TYPE: read_bool(var_use_addr); break;
        case INT_TYPE:  read_int(var_use_addr); break;
        case REAL_TYPE: read_real(var_use_addr); break;
        case STR_TYPE:  read_str(var_use_addr); break;
        default:        SWITCH_ERROR(get_ast_type(var_use));
    }
}

// DONE
void run_real_val(AST *ast) {
    trace();
    pushf(get_ast_data(ast));
}

// DONE
void run_repeat(AST *ast) {
    trace();
    AST* stmt = get_ast_child(ast, 0);
    AST* expr = get_ast_child(ast, 1);
    do{
        rec_run_ast(stmt);
        rec_run_ast(expr);
    }
    while(popi());
}

void run_str_val(AST *ast) {
    trace();
    pushi(get_ast_data(ast));
}

// DONE
void run_times(AST *ast) {
    trace();
    AST* l_expr = get_ast_child(ast, 0);    
    AST* r_expr = get_ast_child(ast, 1);
    rec_run_ast(r_expr);
    rec_run_ast(l_expr);
    if(get_ast_type(l_expr) == REAL_TYPE) pushf(popf()*popf());
    else                                  pushi(popi()*popi());
}

void run_var_decl(AST *ast) {
    trace();
    // Nothing to do, memory was already cleared upon initialization.
}

void run_var_decl_list(AST *ast) {
    trace();
    // Nothing to do, memory was already cleared upon initialization.
}

// DONE
void run_var_use(AST *ast) {
    trace();
    if(get_ast_type(ast)==REAL_TYPE) pushf(loadf(get_ast_data(ast)));
    else                             pushi(loadi(get_ast_data(ast)));
}

// DONE
void run_write(AST *ast) {
    trace();
    AST* expr = get_ast_child(ast, 0);
    rec_run_ast(expr);
    switch (get_ast_type(expr)){
        case BOOL_TYPE: write_bool(); break;
        case INT_TYPE:  write_int(); break;
        case REAL_TYPE: write_real(); break;
        case STR_TYPE:  write_str(); break;
        default:        SWITCH_ERROR(get_ast_type(expr));
    }
}

// DONE
void run_b2i(AST* ast) {
    trace();
    rec_run_ast(get_ast_child(ast, 0));
}

// DONE
void run_b2r(AST* ast) {
    trace();
    rec_run_ast(get_ast_child(ast, 0));
    pushf(popi());
}

void run_b2s(AST* ast) {
    trace();
    rec_run_ast(get_ast_child(ast, 0));
    clear_str_buf();
    popi() == 0 ? sprintf(str_buf, "false") : sprintf(str_buf, "true");
    pushi(add_table_str(st, str_buf));
}

// DONE
void run_i2r(AST* ast) {
    trace();
    rec_run_ast(get_ast_child(ast, 0));
    pushf(popi());
}

void run_i2s(AST* ast) {
    trace();
    rec_run_ast(get_ast_child(ast, 0));
    clear_str_buf();
    sprintf(str_buf, "%d", popi());
    pushi(add_table_str(st, str_buf));
}

void run_r2s(AST* ast) {
    rec_run_ast(get_ast_child(ast, 0));
    clear_str_buf();
    sprintf(str_buf, "%f", popf());
    pushi(add_table_str(st, str_buf));
}

void rec_run_ast(AST *ast) {
    
    if(!ast) return;

    NodeKind kind = get_ast_kind(ast);
    switch(kind){
        case PROGRAM_NODE:       run_program(ast);       break;
        case VAR_DECL_LIST_NODE: run_var_decl_list(ast); break;
        case VAR_DECL_NODE:      run_var_decl(ast);      break;
        case STMT_LIST_NODE:     run_stmt_list(ast);     break;
        case IF_NODE:            run_if(ast);            break;
        case REPEAT_NODE:        run_repeat(ast);        break;
        case READ_NODE:          run_read(ast);          break;
        case WRITE_NODE:         run_write(ast);         break;
        case ASSIGN_NODE:        run_assign(ast);        break;
        case LT_NODE:            run_lt(ast);            break;
        case EQ_NODE:            run_eq(ast);            break;
        case PLUS_NODE:          run_plus(ast);          break;
        case MINUS_NODE:         run_minus(ast);         break;
        case TIMES_NODE:         run_times(ast);         break;
        case OVER_NODE:          run_over(ast);          break;
        case VAR_USE_NODE:       run_var_use(ast);       break;
        case BOOL_VAL_NODE:      run_bool_val(ast);      break;
        case INT_VAL_NODE:       run_int_val(ast);       break;
        case REAL_VAL_NODE:      run_real_val(ast);      break;
        case STR_VAL_NODE:       run_str_val(ast);       break;


        case B2I_NODE:           run_b2i(ast);           break;
        case B2R_NODE:           run_b2r(ast);           break;
        case B2S_NODE:           run_b2s(ast);           break;
        case I2R_NODE:           run_i2r(ast);           break;
        case I2S_NODE:           run_i2s(ast);           break;
        case R2S_NODE:           run_r2s(ast);           break;

        default:
            SWITCH_ERROR(kind);
    }
}

// ----------------------------------------------------------------------------

void run_ast(AST *ast) {
    init_stack();
    init_mem();
    rec_run_ast(ast);
}
