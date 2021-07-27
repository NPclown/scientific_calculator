/*
 * helper functions for fb3-2
 */
# include <stdio.h>
# include <stdlib.h>
# include <stdarg.h>
# include <string.h>
# include <math.h>
# include "calc.h"

#define NHASH 9997
struct symbol symtab[NHASH];

/* symbol table */
/* hash a symbol */
static unsigned symhash(char *sym){
    unsigned int hash = 0;
    unsigned c;
    while(c = *sym++) hash = hash*9 ^ c;
    return hash;
}

struct symbol * lookup(char* sym){ 
    struct symbol *sp = &symtab[symhash(sym)%NHASH];
    int scount = NHASH; /* how many have we looked at */
    while(--scount >= 0) {
        if(sp->name && !strcmp(sp->name, sym)) { return sp; }
        if(!sp->name) { /* new entry */
            sp->name = strdup(sym);
            sp->value = 0;
            sp->use = -1;
            sp->func = NULL;
            sp->syms = NULL;
            return sp;
        }
        if(++sp >= symtab+NHASH) sp = symtab; /* try the next entry */
    }
    yyerror("symbol table overflow\n");
    abort(); /* tried them all, table is full */
}

struct ast * newast(int nodetype, struct ast *l, struct ast *r){
    struct ast *a = malloc(sizeof(struct ast));

    if(!a) {
        yyerror("out of space");
        exit(0);
    }

    a->nodetype = nodetype;
    a->l = l;
    a->r = r;
    return a;
}

struct ast * newnum(double d){
    struct numval *a = malloc(sizeof(struct numval));

    if(!a) {
        yyerror("out of space");
        exit(0);
    }

    a->nodetype = 'K';
    a->number = d;
    return (struct ast *)a;
}

struct ast * newref(struct symbol *s){
    struct symref *a = malloc(sizeof(struct symref));
    if(!a) {
        yyerror("out of space");
        exit(0);
    }
    a->nodetype = 'N';
    a->s = s;
    return (struct ast *)a;
}

struct ast * newasgn(struct symbol *s, struct ast *v){
    struct symasgn *a = malloc(sizeof(struct symasgn));

    if(!a) {
        yyerror("out of space");
        exit(0);
    }
    a->nodetype = '=';
    a->s = s;
    a->v = v;
    return (struct ast *)a;
}

/* free a tree of ASTs */
void treefree(struct ast *a){
    switch(a->nodetype) {
        /* two subtrees */
        case '+':
        case '-':
        case '*':
        case '/':
        case '1': case '2': case '3': case '4': case '5': case '6':
            treefree(a->r);
        /* one subtree */
        case '|':
        case 'M':
            treefree(a->l);
        /* no subtree */
        case 'K': case 'N':
            break;
        case '=':
            free( ((struct symasgn *)a)->v);
            break;
        /* up to three subtrees */
        default: printf("internal error: free bad node %c\n", a->nodetype);
    } 

    free(a); /* always free the node itself */
}

double eval(struct ast *a) {
    double v;
    if(!a) {
        yyerror("internal error, null eval");
        return 0.0;
    }
    switch(a->nodetype) {
        /* constant */
        case 'K': v = ((struct numval *)a)->number; break;
        /* name reference */
        case 'N': 
        
            if(((struct symref *)a)->s->use == -1) {
               yyerror("undefined variablese %s", ((struct symref *)a)->s->name);
            }
            v = ((struct symref *)a)->s->value; 
            break;
        /* assignment */
        case '=': 
            v = ((struct symasgn *)a)->s->value = eval(((struct symasgn *)a)->v); 
            ((struct symasgn *)a)->s->use = 1;
            break;
        /* expressions */
        case '+': v = eval(a->l) + eval(a->r); break;
        case '-': v = eval(a->l) - eval(a->r); break;
        case '*': v = eval(a->l) * eval(a->r); break;
        case '/': v = eval(a->l) / eval(a->r); break;
        case '|': v = fabs(eval(a->l)); break;
        case 'M': v = -eval(a->l); break;
        default: printf("internal error: bad node %c\n", a->nodetype);
    }

    return v;
}

void yyerror(char *s, ...){
 va_list ap;
 va_start(ap, s);
 fprintf(stderr, "%d: error: ", yylineno);
 vfprintf(stderr, s, ap);
 fprintf(stderr, "\n");
}

int main(){
 printf("> "); 
 return yyparse();
}