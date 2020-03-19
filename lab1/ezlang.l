%{
    #include <stdio.h>
    #include <stdlib.h>
%}

%option yylineno

cotes \"

digit   [0-9]
letter  [a-zA-Z]
integer {digit}+
real    {integer}\.{integer}
string  \"[^\"\n]*\"
id      {letter}+
comment \{[^}]*\}
bypass  [ \n\t]+

%%

begin   { printf("%d: %s -> BEGIN\n",   yylineno, yytext); }
bool    { printf("%d: %s -> BOOL\n",    yylineno, yytext); }
else    { printf("%d: %s -> ELSE\n",    yylineno, yytext); }
end     { printf("%d: %s -> END\n",     yylineno, yytext); }
false   { printf("%d: %s -> FALSE\n",   yylineno, yytext); }
if      { printf("%d: %s -> IF\n",      yylineno, yytext); }
int     { printf("%d: %s -> INT\n",     yylineno, yytext); }
program { printf("%d: %s -> PROGRAM\n", yylineno, yytext); }
read    { printf("%d: %s -> READ\n",    yylineno, yytext); }
real    { printf("%d: %s -> REAL\n",    yylineno, yytext); }
repeat  { printf("%d: %s -> REPEAT\n",  yylineno, yytext); }
string  { printf("%d: %s -> STRING\n",  yylineno, yytext); }
then    { printf("%d: %s -> THEN\n",    yylineno, yytext); }
true    { printf("%d: %s -> TRUE\n",    yylineno, yytext); }
until   { printf("%d: %s -> UNTIL\n",   yylineno, yytext); }
var     { printf("%d: %s -> VAR\n",     yylineno, yytext); }
write   { printf("%d: %s -> WRITE\n",   yylineno, yytext); }

":=" { printf("%d: %s -> ASSIGN\n", yylineno, yytext); }
"="  { printf("%d: %s -> EQ\n",     yylineno, yytext); }
"<"  { printf("%d: %s -> LT\n",     yylineno, yytext); }
"+"  { printf("%d: %s -> PLUS\n",   yylineno, yytext); }
"-"  { printf("%d: %s -> MINUS\n",  yylineno, yytext); }
"*"  { printf("%d: %s -> TIMES\n",  yylineno, yytext); }
"/"  { printf("%d: %s -> OVER\n",   yylineno, yytext); }
"("  { printf("%d: %s -> LPAR\n",   yylineno, yytext); }
")"  { printf("%d: %s -> RPAR\n",   yylineno, yytext); }
";"  { printf("%d: %s -> SEMI\n",   yylineno, yytext); }

{integer} { printf("%d: %s -> INT_VAL\n",  yylineno, yytext); }
{real}    { printf("%d: %s -> REAL_VAL\n", yylineno, yytext); }
{string}  { printf("%d: %s -> STR_VAL\n",  yylineno, yytext); }
{id}      { printf("%d: %s -> ID\n",       yylineno, yytext); }

{comment} {} /*{ *printf("----- COMMENT -----\n"); }*/
{bypass}  {} /*{ *printf("----- BYPASS -----\n"); }*/

. { printf("LEXICAL ERROR (%d): Unknown symbol %s", yylineno, yytext); exit(1); }

%%