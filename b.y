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
	method method_list {
	
	}
method : 
	modificator STATIC type VARIABLE '(' argument_list ')' BEGIN_BRACKET END_BRACKET {

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
	argument argument_list {
	
	}

argument : 
	type VARIABLE {

	}
%%

void yyerror(const char *s) 
{
  fprintf(stderr, "%s\n", s);
}

int main(int argc, char** argv)
{
  freopen(argv[1],"r",stdin);
  yyparse();
  return 0;
}

