/* scientific calculate */
%{
#include <stdio.h>
%}

%union{ 
    double dval; 
}

/* declare tokens */
%token OP CP
%token <dval>NUM
%token ADD SUB MUL DIV ABS
%token EOL

%type<dval> exp factor term //bison 규칙의 자료형

%%
calclist : {}
         | calclist exp EOL {printf("= %lf\n", $2);}
;

exp : factor
    | exp ADD factor {$$ = $1 + $3;}
    | exp SUB factor {$$ = $1 - $3;}
;

factor : term 
        | factor MUL term {$$ = $1 * $3;}
        | factor DIV term {$$ = $1 / $3;}
;

term : NUM
     | ABS NUM { $$ = $2 > 0 ? $2 : -$2;}
     | OP exp CP {$$ = $2;}
;

%% 

int main(int argc, char ** argv){
    yyparse();
}

yyerror(char *s)
{
 fprintf(stderr, "error: %s\n", s);
}
