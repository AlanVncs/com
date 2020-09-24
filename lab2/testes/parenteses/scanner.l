%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput
%{
#include "parser.h" // For the token types from bison.
%}
%%
"a" { return LETTER; }
"(" { return LPAR; }
")" { return RPAR; }
[ \n\t] { /* ignore spaces */ }
. { printf("LEXICAL ERROR: Unknown symbol %s\n", yytext); exit(EXIT_FAILURE); }
%%