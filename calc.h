#pragma once
/* interface to the lexer */
extern int yylineno; /* from lexer */
void yyerror(char *s, ...);
/* node types
 * + - * / |
 * 0-7 comparison ops, bit coded 04 equal, 02 less, 01 greater
 * M unary minus
 * L expression or statement list
 * I IF statement
 * W WHILE statement
 * N symbol ref
 * = assignment
 * S list of symbols
 * F built in function call
 * C user function call
 */ 
/* nodes in the abstract syntax tree */
/* all have common initial nodetype */
struct ast {
    int nodetype;
    struct ast *l;
    struct ast *r;
};
struct numval {
    int nodetype; /* type K */
    double number;
};
struct symref {
    int nodetype; /* type N */
    struct symbol *s;
};
struct symasgn {
    int nodetype; /* type = */
    struct symbol *s;
    struct ast *v; /* value */
};

/* symbol table */
struct symbol { /* a variable name */
    char *name;
    double value;
    int use;
    struct ast *func; /* stmt for the function */
    struct symlist *syms; /* list of dummy args */
};

/* list of symbols, for an argument list */
struct symlist {
    struct symbol *sym;
    struct symlist *next;
};

/* simple symtab of fixed size */
struct symbol *lookup(char*);

/* build an AST */
struct ast *newast(int nodetype, struct ast *l, struct ast *r);
struct ast *newref(struct symbol *s);
struct ast *newasgn(struct symbol *s, struct ast *v);
struct ast *newnum(double d);

/* evaluate an AST */
double eval(struct ast *);
/* delete and free an AST */
void treefree(struct ast *);