%option outfile="scanner.c"
%option yylineno
%option noyywrap
%option nounput
%option noinput

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "parser.h"
    #include "lib/table.h"

    // extern StrTable* st;
    // extern VarTable* vt;

    // char* cloneString(char* source);
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

"bool"    { return BOOL; }
"int"     { return INT; }
"real"    { return REAL; }
"string"  { return STRING; }

"<"  { return LT; }
"="  { return EQ; }
"+"  { return PLUS; }
"-"  { return MINUS; }
"*"  { return TIMES; }
"/"  { return OVER; }
":=" { return ASSIGN; }

"("  { return LPAR; }
")"  { return RPAR; }
";"  { return SEMI; }

"true"    { return TRUE; }
"false"   { return FALSE; }
{integer} { return INT_VAL; }
{real}    { return REAL_VAL; }
{string}  { return STR_VAL; }
{id}      { return ID; }

{enter}   { }
{comment} { }
{space}   { }

. { printf("LEXICAL ERROR (%d): Unknown symbol %s", yylineno, yytext); exit(EXIT_FAILURE); }

%%

// char* cloneString(char* source){
//     int len = strlen(source);
//     char* dest = malloc((len+1)*sizeof(char));
//     strcpy(dest, source);
//     return dest;
// }

void yyerror (char const *s) {
    printf("SYNTAX ERROR (%d): %s\n", yylineno, s);
    exit(EXIT_FAILURE);
}

