%{
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdarg.h>
#include <iostream>
#include <stdio.h>

#include "types.h"

int yylex(void);
void yyerror(const char *);
int yydebug = 1;
TMyFunctionList allFunctions;

#define DEBUG

string getStringType(int type);
string getStringNode(int type);
string getStringNode2(TNode *node);
string declarationToString(TNode *node);
string assignmentToString(TNode *node);


%}

%union {
    int intValue;
    char* stringValue;
    bool booleanValue; 
    TMyFunction * function; // указатель на функцию
    TMyVariable * variable; // указатель на переменную \ константу
    TMyBody * body;         // указатель на тело (цикла, функции, чего угодно)
    TMyExpression * expression; // выражение (логическое, булево)
    TMyFunctionCall * callFunction; // вызов функции (не надо думаю)
    TMyDeclaration * declaration; // объявление переменной
    TMyVariableList * variableList; // объявление переменных итд (текущая память
    TMyArgumentList * argumentList; // аргумент лист для функций итд  
    TMyVariable * argument; // аргумент =)
    TNode * node; // звено
    TNodeList * nodeList; // тело
    TMyDefinition * definition; // присвоение
    TMyExpressionList * expressionList; // для вызова функций
}

%token INTEGER BOOLEAN VOID STRING
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

%type <stringValue> VARIABLE
%type <intValue> type
%type <argumentList> argument_list
%type <argument> argument
%type <function> method
%type <node> statement
%type <nodeList> statement_list
%type <declaration> declaration
%type <definition> assignment
%type <expression> expression
%type <intValue> INTEGER
%type <booleanValue> BOOLEAN
%type <expressionList> expression_list

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
            string name($4);
	    TMyFunction* func = new TMyFunction($4, $6, NULL, $3);
	    $$ = func;

#ifdef DEBUG
	    cout << "=========FUNCTION_DECLARATION=========" << endl;
            cout << "name : " << name << endl;
	    cout << "type : " << getStringType($3) << endl;
            cout << "arguments : " << $6->data.size() << endl;
            for (int i = 0; i < $6->data.size(); ++i) {
	         cout << getStringType($6->data[i].type) << " " << $6->data[i].name << endl;
	    }
	    TNodeList* nodeList = $9;
	    cout << "body :" << endl;
	    for (int i = 0; i < nodeList->data.size(); ++i) {
	    	cout << getStringNode2(nodeList->data[i]) << endl;
	    }
	    cout << "===============END====================" << endl;
#endif
           
	}
	
modificator :
	PUBLIC {

	} |
	PRIVATE {

	}

type : 
	BOOLEAN {
	    $$ = BOOLEAN_TYPE;
	} |
	INTEGER {
            $$ = INTEGER_TYPE;
	} |
	VOID {
	    $$ = VOID_TYPE;
	} |
        STRING {
            $$ = STRING_TYPE;
	}

argument_list : /* empty */ {
	    TMyArgumentList* list = new TMyArgumentList();
            $$ = list;   		
	} |
	argument_list ',' argument {
            $1->data.push_back(*$3); 
            $$ = $1;   	
	} |
	argument {
	    TMyArgumentList* list = new TMyArgumentList();
            list->data.push_back(*$1); 
            $$ = list;   
	}

statement_list : /* empty */ {
	    $$ = new TNodeList();
	} |
	statement_list statement {
	    $1->data.push_back($2);
            $$ = $1;	
	}

statement :
	declaration ';' {
	    TNode* node = new TNode();
            node->type = DECLARATION_NODE;
            node->declaration = $1;
	    $$ = node;
	} |
	assignment ';' {
	    TNode* node = new TNode();
	    node->type = DEFINITION_NODE;
            node->definition = $1;
	    $$ = node;
	} |
	WHILE '(' expression ')' BEGIN_BRACKET END_BRACKET {
	
	} |
	VARIABLE '(' argument_list ')' ';' {
	
	} 
	

declaration :
	type VARIABLE {
	    string name($2);
	    int type = $1;
            TMyDeclaration* var = new TMyDeclaration(name, type, NULL);
	    $$ = var;     	
	} |
	type VARIABLE '=' expression {
	    string name($2);
	    int type = $1;
	    //TODO_EXPRESSION
            TMyDeclaration* var = new TMyDeclaration(name, type, NULL);
	    $$ = var; 	
	}	

assignment :
	VARIABLE '=' expression {
	    string name($1);
            TMyDefinition* var = new TMyDefinition();
            var->name = name;
	    //TODO -!-
            var->expression = NULL;
	    $$ = var;     	
	} 

argument : 
	type VARIABLE {
	    string name($2);
	    int type = $1;
            TMyVariable* var = new TMyVariable(name, type, false, false, false);
	    $$ = var;     
	} 

expression : 
	expression '+' expression {
	    //cout << " + " << endl;			
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_PLUS; 
	    expr->left = $1;
	    expr->right = $3;
	    $$ = expr;
	} |
	expression '-' expression {
	    //cout << " - " << endl;			
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_MINUS; 
	    expr->left = $1;
	    expr->right = $3;
	    $$ = expr;
	} |
	expression '*' expression {
	    //cout << " * " << endl;			
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_MUL; 
	    expr->left = $1;
	    expr->right = $3;
	    $$ = expr;
	} |
	expression '/' expression {
	    //cout << " / " << endl;				
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_DIV; 
	    expr->left = $1;
	    expr->right = $3;
	    $$ = expr;

	} |
	'(' expression ')' {
	    $$ = $2;	
	} |
	INTEGER {
	    //cout << "INTEGER" << endl;
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_INTEGER; 
	    expr->intValue = $1;
	    $$ = expr;
	} |
	BOOLEAN {
	    //cout << "BOOLEAN" << endl;	
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_BOOLEAN; 
	    expr->booleanValue = $1;
	    $$ = expr;
	} |
	VARIABLE '(' expression_list ')' {
	    //cout << "FUNCTION CALL" << endl;		
	} |
	VARIABLE {
	    //cout << "VARIABLE" << endl;			
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_VARIABLE; 
	    string* name = new string($1);
	    expr->name = name;
	    $$ = expr;
	}

expression_list: /* empty */ {
	    $$ = new TMyExpressionList();	
	} |
	expression_list expression {
	    $1->data.push_back($2);
	    $$ = $1; 
	}
        
       
%%

string getStringType(int type) {
    if (type == 1) return string("boolean");
    if (type == 2) return string("integer");
    if (type == 3) return string("void");
    if (type == 4) return string("string");
}

string getStringNode(int type) {
    if (type == 1) return string("declaration");
    if (type == 2) return string("function call");
    if (type == 3) return string("definition");
    return string("");
}

string getStringNode2(TNode *node) {
    string result("");
    if (node->type == 1) {
        result.append("declaration : ");
        result.append(declarationToString(node));  
        return result;
    }
    if (node->type == 3) {
        result.append("assignment : ");
        result.append(assignmentToString(node));  
        return result;
    }
    if (node->type == 2) return string("function call");
    if (node->type == 4) return string("nop");

    return string("");   
}

string declarationToString(TNode *node) {
    string result = getStringType(node->declaration->type);
    result.append(" ");
    result.append(node->declaration->name);
    return result;
}

string assignmentToString(TNode *node) {
    string result("");
    result.append(node->declaration->name);    
    return result;
}

void yyerror(const char *s) 
{
  fprintf(stderr, "%s\n", s);
}

// инициализация перед парсингом всего
void init() {
    
}

int main(int argc, char** argv)
{
    if (argc == 2) { 
	freopen(argv[1],"r",stdin);
	printf("Compile and running file %s\n", argv[1]);
    } else {
        printf("Compile and running from stdin!\n");
    }
    
    init();
    
    yyparse();
    
    printf("The build was successfull!\n");
    return 0;
}

