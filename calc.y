/* calculator with AST */
%{
# include <stdio.h>
# include <stdlib.h>
# include "calc.h"
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
%nonassoc '|' UMINUS

%type <a> exp stmt list explist
%type <sl> symlist

%start calclist
%%
calclist: /* nothing */
    | calclist exp RUN{
        printf("= %4.4g\n> ", eval($2));
        treefree($2);
    }
    | calclist error RUN{ yyerrok; printf("> "); }
 ;

exp:  exp '+' exp { $$ = newast('+', $1,$3); }
    | exp '-' exp { $$ = newast('-', $1,$3);}
    | exp '*' exp { $$ = newast('*', $1,$3); }
    | exp '/' exp { $$ = newast('/', $1,$3); }
    | '|' exp { $$ = newast('|', $2, NULL); }
    | '(' exp ')' { $$ = $2; }
    | '-' exp %prec UMINUS { $$ = newast('M', $2, NULL); }
    | NUMBER { $$ = newnum($1); }
    | NAME { $$ = newref($1); }
    | LET NAME '=' exp { $$ = newasgn($2, $4); }
;
%%