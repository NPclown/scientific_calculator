/* calculator with AST */
%{
# include <stdio.h>
# include <stdlib.h>
# include "calc.h"
int check;
%}

%define parse.error verbose

%union {
 struct ast *a;
 double d;
 struct symbol *s; /* which symbol */
 struct symlist *sl;
}

/* declare tokens */
%token <d> NUMBER
%token <s> NAME
%token EOL

%token LET RUN

%right '='
%left '+' '-'
%left '*' '/'
%nonassoc '|' UMINUS UPLUS

%type <a> exp stmt list explist
%type <sl> symlist

%start calclist
%%
calclist: /* nothing */
    | calclist exp RUN{
        check = 1;
        double result = eval($2, &check);
        if (check == 1){
            printf("= %4.4g ",result);
        }
        treefree($2);
        printf("\n>");
    }
    | calclist LET NAME '=' exp RUN{ eval(newasgn($3, $5), &check); printf("Defined\n> "); }
    | calclist error RUN{ yyerrok; printf("\n> "); }
 ;

exp:  exp '+' exp { $$ = newast('+', $1,$3); }
    | exp '-' exp { $$ = newast('-', $1,$3);}
    | exp '*' exp { $$ = newast('*', $1,$3); }
    | exp '/' exp { $$ = newast('/', $1,$3); }
    | '|' exp { $$ = newast('|', $2, NULL); }
    | '(' exp ')' { $$ = $2; }
    | '-' exp %prec UMINUS { $$ = newast('M', $2, NULL); }
    | '+' exp %prec UPLUS { $$ = newast('P', $2, NULL); }
    | NUMBER { $$ = newnum($1); }
    | NAME { $$ = newref($1);}
    | NAME '=' exp { $$ = newasgn($1, $3); }
;
%%