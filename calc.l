/* scientific calculate */

%{
    #include "calc.tab.h"
%}

%%
"("     {return OP;}
")"     {return CP;}
"+"     {return ADD;}
"-"     {return SUB;}
"*"     {return MUL;}
"/"     {return DIV;}
"|"     {return ABS;}
([0-9]+|[0-9]*\.[0-9]+) {yylval.dval = atof(yytext); return NUM; }
\n { return EOL; }
[ \t]* { /* ignore whitespace */ }
. { printf("Mystery character %c\n", *yytext); return EOL;}
%%