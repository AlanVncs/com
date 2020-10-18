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
space   [ \t]+

%%

"begin"   { return BGN; }
"else"    { return ELSE; }
"end"     { return END; }
"false"   { return FALSE; }
"if"      { return IF; }
"program" { return PROGRAM; }
"read"    { return READ; }
"repeat"  { return REPEAT; }
"then"    { return THEN; }
"true"    { return TRUE; }
"until"   { return UNTIL; }
"var"     { return VAR; }
"write"   { return WRITE; }

"bool"    { yylval.type = BOOL_TYPE; return BOOL; }
"int"     { yylval.type = INT_TYPE; return INT; }
"real"    { yylval.type = REAL_TYPE; return REAL; }
"string"  { yylval.type = STR_TYPE; return STRING; }

":=" { return ASSIGN; }
"="  { return EQ; }
"<"  { return LT; }
"+"  { return PLUS; }
"-"  { return MINUS; }
"*"  { return TIMES; }
"/"  { return OVER; }
"("  { return LPAR; }
")"  { return RPAR; }
";"  { return SEMI; }

{integer} { return INT_VAL; }
{real}    { return REAL_VAL; }
{string}  { add_string(strTable, yytext); return STR_VAL; }
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

