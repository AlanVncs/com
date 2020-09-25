%option outfile="scanner.c"
%option yylineno
%option noyywrap
%option nounput
%option noinput

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "parser.h"
%}

%option yylineno

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
"bool"    { return BOOL; }
"else"    { return ELSE; }
"end"     { return END; }
"false"   { return FALSE; }
"if"      { return IF; }
"int"     { return INT; }
"program" { return PROGRAM; }
"read"    { return READ; }
"real"    { return REAL; }
"repeat"  { return REPEAT; }
"string"  { return STRING; }
"then"    { return THEN; }
"true"    { return TRUE; }
"until"   { return UNTIL; }
"var"     { return VAR; }
"write"   { return WRITE; }

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
{string}  { return STR_VAL; }
{id}      { return ID; }

{enter}   { }
{comment} { }
{space}   { }

. { printf("LEXICAL ERROR (%d): Unknown symbol %s", yylineno, yytext); exit(1); }

%%

void yyerror (char const *s) {
    printf("SYNTAX ERROR (%d): %s\n", yylineno, s);
    exit(EXIT_FAILURE);
}