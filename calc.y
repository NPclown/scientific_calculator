/* scientific calculate */
%{
#include <stdio.h>
%}

/* declare tokens */
%token NUM
%token ADD SUB MUL DIV ABS
%token EOL

%%
calclist : {}
         | calclist exp EOL {printf("= %d\n", $2);}
;

exp : factor
    | exp ADD factor {$$ = $1 + $3;}
    | exp DIV factor {$$ = $1 - $3;}
;

factor : term 
        | factor MUL term {$$ = $1 * $3;}
        | factor DIV term {$$ = $1 / $3;}
;

term : NUM 
     | ABS NUM {$2 > 0 ? $2 : -$2;}
;

%% 

int main(int argc, char ** argv){
    yyparse();
}

yyerror(char *s)
{
 fprintf(stderr, "error: %s\n", s);
}
