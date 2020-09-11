%{ /* Reconhece os artigos em ingles a, an, the */
  #include <stdio.h>
%}
%%
[ \t\n]+  { printf("Some space\n"); } /* pula espaco em branco - acao: fazer nada. */
a|an|the  { printf("%s É um artigo\n", yytext); }
[a-zA-Z]+ { printf("%s: ???\n", yytext); }
.         { printf("%s não reconhecido\n", yytext); }
%%
