%option outfile="scanner.c"
%option yylineno
%option noyywrap
%option nounput
%option noinput

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "parser.h"
    #include "table/tables.h"

    extern StrTable* strTable;
    extern VarTable* varTable;

    char* cloneString(char* source);
%}

digit   [0-9]
letter  [a-zA-Z]
integer {digit}+
real    {integer}\.{integer}
string  \"[^\"\n]*\"
id      {letter}+
comment \{[^}]*\}
enter   \n
space   [ \t]

%%

"begin"   { return BGN; }
"else"    { return ELSE; }
"end"     { return END; }
"if"      { return IF; }
"program" { return PROGRAM; }
"read"    { return READ; }
"repeat"  { return REPEAT; }
"then"    { return THEN; }
"until"   { return UNTIL; }
"var"     { return VAR; }
"write"   { return WRITE; }

"bool"    { yylval.type = BOOL_TYPE; return BOOL; }
"int"     { yylval.type = INT_TYPE; return INT; }
"real"    { yylval.type = REAL_TYPE; return REAL; }
"string"  { yylval.type = STR_TYPE; return STRING; }

"<"  { yylval.op = LT_OP; return LT; }
"="  { yylval.op = EQ_OP; return EQ; }
"+"  { yylval.op = PLUS_OP; return PLUS; }
"-"  { yylval.op = MINUS_OP; return MINUS; }
"*"  { yylval.op = TIMES_OP; return TIMES; }
"/"  { yylval.op = OVER_OP; return OVER; }
":=" { yylval.op = ASSIGN_OP; return ASSIGN; }

"("  { return LPAR; }
")"  { return RPAR; }
";"  { return SEMI; }

"true"    { yylval.type = BOOL_TYPE; return TRUE; }
"false"   { yylval.type = BOOL_TYPE; return FALSE; }
{integer} { yylval.type = INT_TYPE;  return INT_VAL; }
{real}    { yylval.type = REAL_TYPE; return REAL_VAL; }
{string}  { yylval.type = STR_TYPE;  add_string(strTable, yytext); return STR_VAL; }
{id}      { yylval.str = cloneString(yytext); return ID; }

{enter}   { }
{comment} { }
{space}   { }

. { printf("LEXICAL ERROR (%d): Unknown symbol %s", yylineno, yytext); exit(EXIT_FAILURE); }

%%

char* cloneString(char* source){
    int len = strlen(source);
    char* dest = malloc((len+1)*sizeof(char));
    strcpy(dest, source);
    return dest;
}

void yyerror (char const *s) {
    printf("SYNTAX ERROR (%d): %s\n", yylineno, s);
    exit(EXIT_FAILURE);
}

