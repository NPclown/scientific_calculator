%option noyywrap nodefault yylineno
%{
# include "calc.h"
# include "calc.tab.h"
%}

/* float exponent */
EXP ([Ee][-+]?[0-9]+)

%%
 /* single character ops */
"+" |
"-" |
"*" |
"/" |
"=" |
"|" |
"(" |
")" { return yytext[0]; }

 /* keywords */
(r|R)(u|U)(n|N) { return RUN;}
"let" { return LET;}

[a-zA-Z][a-zA-Z0-9]* { yylval.s = lookup(yytext); return NAME; }
[0-9]+"."[0-9]*{EXP}? |
"."?[0-9]+{EXP}? { yylval.d = atof(yytext); return NUMBER; }
"//".* 
[ \t] /* ignore whitespace */ 

\n { }
. { yyerror("Mystery character %c\n", *yytext);}
%%