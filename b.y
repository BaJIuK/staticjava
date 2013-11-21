%{
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdarg.h>
#include <iostream>
#include <stdio.h>

int yylex(void);
void yyerror(const char *);
int yydebug = 1;

%}

%union {
  int val; /* äëÿ êîíñòàíò */
  //VarTableRecord * var_pointer; /* äëÿ ïåðåìåííûõ */
  //MyTreeNode * node_pointer; /* äëÿ âñåãî îñòàëüíîãî */ 
}

%token INTEGER BOOLEAN VOID
%token VARIABLE
%token WHILE PRINT THEN IF
%token PRIVATE PUBLIC CLASS STATIC MAIN BEGIN_BRACKET END_BRACKET
%nonassoc ELSE

%left OR
%left AND
%left GE LE GT LT EQ NE
%left NOT
%left '+' '-'
%left '*' '/'

%type <node_pointer> class method modificator method_list

%%
class : 
	PUBLIC CLASS VARIABLE BEGIN_BRACKET method_list END_BRACKET {
	
	}
method_list:
	method {

	} |
	method_list method {
	
	}
method : 
	modificator STATIC type VARIABLE '(' argument_list ')' BEGIN_BRACKET statement_list END_BRACKET {

	}
	
modificator :
	PUBLIC {

	} |
	PRIVATE {

	}

type : 
	BOOLEAN {

	} |
	INTEGER {

	}

argument_list : /* empty */ |
	argument_list "," argument {
	
	}
	argument {
	
	}

statement_list : /* empty */ |
	statement_list statement {
	
	}

statement :
	declaration ';' {
	
	} |
	assignment ';' {
	
	} |
	WHILE '(' expression ')' BEGIN_BRACKET END_BRACKET {
	
	} |
	VARIABLE '(' argument_list ')' ';' {
	
	} 
	

declaration :
	type VARIABLE {
	
	} |
	type VARIABLE '=' expression {
	
	}	

assignment :
	VARIABLE '=' expression {
	
	} 

argument : 
	type VARIABLE {

	}

expression : 
	INTEGER {
	
	} |
	BOOLEAN {
	
	} |
	VARIABLE '(' argument_list ')' {
	
	} |
	VARIABLE {
	
	}
	expression '+' expression {
	
	}
	expression '-' expression {
	
	}
	expression '*' expression {
	
	}
	expression '/' expression {
	
	}
	'(' expression ')' {
	
	}
%%

void yyerror(const char *s) 
{
  fprintf(stderr, "%s\n", s);
}

int main(int argc, char** argv)
{
    if (argc == 2) { 
	freopen(argv[1],"r",stdin);
	printf("Compile and running file %s\n", argv[1]);
    } else {
        printf("Compile and running from stdin!\n");
    }
    
    yyparse();
    
    printf("The build was successfull!\n");
    return 0;
}

