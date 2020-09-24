%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput
%{
#include "parser.h" // For the token types from bison.
%}

digit   [0-9]
natural {digit}+
number  {natural}(\.{natural})?

%%

{number}    { return NUMBER; }
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return TIMES; }
"/"         { return OVER; }
"("         { return LPAR; }
")"         { return RPAR; }
"\n"        { return ENTER; }
[ \t]       { /* ignore spaces */ }
.           { printf("LEXICAL ERROR: Unknown symbol %s\n", yytext); exit(EXIT_FAILURE); }
%%