%{
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdarg.h>
#include <iostream>
#include <stdio.h>
#include <set>
#include <stdlib.h>
#include <sstream>
#include "types.h"

int yylex(void);
void yyerror(const char *);
int yydebug = 1;
TMyFunctionList allFunctions;
extern int yylineno;

//#define DEBUG

string getStringType(int type);
string getStringNode(int type);
string getStringNode2(TNode *node);
string declarationToString(TNode *node);
string assignmentToString(TNode *node);
string expressionToString(TMyExpression *expr);

TMyProgram* mainProgram;
%}

%union {
    int intValue;
    char* stringValue;
    bool booleanValue; 
    double doubleValue;
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
    TMyFunctionList * functionList;
}

%token INTEGER BOOLEAN VOID STRING DOUBLE
%token VARIABLE
%token WHILE THEN IF RETURN
%token PRIVATE PUBLIC CLASS STATIC MAIN BEGIN_BRACKET END_BRACKET
%nonassoc IF
%nonassoc ELSE

%left OR
%left AND
%left GE LE GT LT EQ NE
%left NOT
%left '+' '-'
%left '*' '/'

%type <stringValue> VARIABLE STRING
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
%type <functionList> method_list
%type <doubleValue> DOUBLE

%%

class : 
	PUBLIC CLASS VARIABLE BEGIN_BRACKET method_list END_BRACKET {
	    string name($3);
	    mainProgram = new TMyProgram();
	    mainProgram->name = name;
	    mainProgram->functions = $5; 
	}
method_list:
	method {
	    TMyFunctionList* list = new TMyFunctionList();
	    list->data.push_back($1);
	    $$ = list;
	} |
	method_list method {
	    $1->data.push_back($2);
  	    $$ = $1;
	}
method : 
	modificator STATIC type VARIABLE '(' argument_list ')' BEGIN_BRACKET statement_list END_BRACKET {
            string name($4);
	    TMyFunction* func = new TMyFunction($4, $6, $9, $3);
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
	} |
	DOUBLE {
	    $$ = DOUBLE_TYPE;	
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
	RETURN expression';' {
	    TNode* node = new TNode();
            node->type = RETURN_NODE;
	    node->returnExpr = $2;
	    $$ = node;	
	} |
	RETURN ';' {
	    TNode* node = new TNode();
            node->type = RETURN_NODE;
	    node->returnExpr = NULL;
	    $$ = node;
	} |
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
	WHILE '(' expression ')' BEGIN_BRACKET statement_list END_BRACKET {
	    TNode* node = new TNode();
	    node->type = WHILE_NODE;
	    TMyWhileStatement* x = new TMyWhileStatement();
	    x->expression = $3;
	    x->body = $6;
	    node->whileStatement = x;
	    $$ = node;
	} |
	VARIABLE '(' expression_list ')' ';' {
	    TNode* node = new TNode();
	    node->type = FUNCTION_CALL_NODE;
	    TMyFunctionCall* call = new TMyFunctionCall();
	    string name($1);
	    call->name = name;
	    call->expressions = $3;
	    node->function = call;
	    $$ = node;
	} |
	BEGIN_BRACKET statement_list END_BRACKET {
	    TNode* node = new TNode();
	    node->type = NODELIST_NODE;
	    node->nodeList = $2;
	    $$ = node;	
	} |
	IF '(' expression ')' BEGIN_BRACKET statement_list END_BRACKET ELSE BEGIN_BRACKET statement_list END_BRACKET {
	    TNode* y = new TNode();
	    y->type = IF_NODE;
	    TMyIfStatement * x = new TMyIfStatement();
	    x->expression = $3;
	    x->then_ = $6;
	    x->else_ = $10;
	    y->ifStatement = x;	
	    $$ = y;
	} |
	IF '(' expression ')' BEGIN_BRACKET statement_list END_BRACKET {
	    TNode* y = new TNode();
	    y->type = IF_NODE;
	    TMyIfStatement * x = new TMyIfStatement();
	    x->expression = $3;
	    x->then_ = $6;
	    x->else_ = NULL;	
	    y->ifStatement = x;	
	    $$ = y;
	} /*|
	IF '(' expression ')' statement {
	    TNode* y = new TNode();
	    y->type = IF_NODE;
	    TNodeList* list = new TNodeList();
	    TMyIfStatement * x = new TMyIfStatement();
	    x->expression = $3;
	    list->data.push_back($5);
	    x->then_ = list;
	    x->else_ = NULL;	
	    y->ifStatement = x;	
	    $$ = y;
	} |
	IF '(' expression ')' statement ELSE BEGIN_BRACKET statement_list END_BRACKET {
	    TNode* y = new TNode();
	    y->type = IF_NODE;
	    TNodeList* list = new TNodeList();
	    TMyIfStatement * x = new TMyIfStatement();
	    x->expression = $3;
	    list->data.push_back($5);
	    x->then_ = list;
	    x->else_ = $8;	
	    y->ifStatement = x;	
	    $$ = y;
	} |
	IF '(' expression ')' statement ELSE statement {
	    TNode* y = new TNode();
	    y->type = IF_NODE;
	    TNodeList* list1 = new TNodeList();
     	    TNodeList* list2 = new TNodeList();
	    TMyIfStatement * x = new TMyIfStatement();
	    x->expression = $3;
	    list1->data.push_back($5);
	    list2->data.push_back($7);
	    x->then_ = list1;
	    x->else_ = list2;	
	    y->ifStatement = x;	
	    $$ = y;
	} |
        IF '(' expression ')' ELSE statement {
	    TNode* y = new TNode();
	    y->type = IF_NODE;
	    TNodeList* list2 = new TNodeList();
	    TMyIfStatement * x = new TMyIfStatement();
	    x->expression = $3;
	    list2->data.push_back($6);
	    x->then_ = NULL;
	    x->else_ = list2;	
	    y->ifStatement = x;	
	    $$ = y;
	} */

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
            TMyDeclaration* var = new TMyDeclaration(name, type, $4);
	    $$ = var; 	
	}	

assignment :
	VARIABLE '=' expression {
	    string name($1);
            TMyDefinition* var = new TMyDefinition();
            var->name = name;
            var->expression = $3;
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
	STRING {
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_STRING; 
	    string name($1);
            expr->name = new string(name);
	    $$ = expr;	
	} |
	DOUBLE {
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_DOUBLE; 
            expr->doubleValue = $1;
	    $$ = expr;		
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
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_FUNCTION_CALL;
	    TMyFunctionCall* call = new TMyFunctionCall();
	    string name($1);
	    call->name = name;
	    call->expressions = $3;
	    expr->function = call;
	    $$ = expr;
	    //cout << "FUNCTION CALL" << endl;		
	} |
	VARIABLE {
	    //cout << "VARIABLE" << endl;			
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_VARIABLE; 
	    string* name = new string($1);
	    expr->name = name;
	    $$ = expr;
	} |
	expression OR expression {
	    //cout << " OR " << endl;			
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_OR; 
	    expr->left = $1;
	    expr->right = $3;
	    $$ = expr;
	} |
	expression AND expression {
	    //cout << " AND " << endl;			
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_AND; 
	    expr->left = $1;
	    expr->right = $3;
	    $$ = expr;
	} |
	expression EQ expression {
	    //cout << " == " << endl;			
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_EQ; 
	    expr->left = $1;
	    expr->right = $3;
	    $$ = expr;
	} |
	expression NE expression {
	    //cout << " != " << endl;				
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_NE; 
	    expr->left = $1;
	    expr->right = $3;
	    $$ = expr;
	} |
	expression GT expression {
	    //cout << " > " << endl;			
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_GT; 
	    expr->left = $1;
	    expr->right = $3;
	    $$ = expr;
	} |
	expression LT expression {
	    //cout << " < " << endl;			
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_LT; 
	    expr->left = $1;
	    expr->right = $3;
	    $$ = expr;
	} |
	expression GE expression {
	    //cout << " >= " << endl;			
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_GE; 
	    expr->left = $1;
	    expr->right = $3;
	    $$ = expr;
	} |
	expression LE expression {
	    //cout << " <= " << endl;				
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_LE; 
	    expr->left = $1;
	    expr->right = $3;
	    $$ = expr;
	} |
	NOT expression {
	    TMyExpression* expr = new TMyExpression();
            expr->type = EXPR_NOT; 
	    expr->left = $2;
	    $$ = expr;	
	}



expression_list: /* empty */ {
	    $$ = new TMyExpressionList();	
	} |
	expression_list ',' expression {
	    $1->data.push_back($3);
	    $$ = $1; 
	} |
  	expression {
	    TMyExpressionList* list = new TMyExpressionList();
	    list->data.push_back($1);
	    $$ = list;
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
    if (node->type == NODELIST_NODE) return string("node list");	
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

string expressionToString(TMyExpression *expr) {
   string result("");
   if (expr->type == EXPR_PLUS) {
   	result.append(expressionToString(expr->left));
	result.append("+");
	result.append(expressionToString(expr->right));
	return result;
   } 
   if (expr->type == EXPR_MINUS) {
   	result.append(expressionToString(expr->left));
	result.append("-");
	result.append(expressionToString(expr->right));
	return result;
   } 
   if (expr->type == EXPR_MUL) {
   	result.append(expressionToString(expr->left));
	result.append("*");
	result.append(expressionToString(expr->right));
	return result;
   } 
   if (expr->type == EXPR_DIV) {
   	result.append(expressionToString(expr->left));
	result.append("/");
	result.append(expressionToString(expr->right));
	return result;
   } 
   if (expr->type == EXPR_AND) {
   	result.append(expressionToString(expr->left));
	result.append(" AND ");
	result.append(expressionToString(expr->right));
	return result;
   } 
   if (expr->type == EXPR_OR) {
   	result.append(expressionToString(expr->left));
	result.append(" OR ");
	result.append(expressionToString(expr->right));
	return result;
   } 
   if (expr->type == EXPR_NOT) {
	result.append("!");
	result.append(expressionToString(expr->left));
	return result;
   } 
   if (expr->type == EXPR_EQ) {
   	result.append(expressionToString(expr->left));
	result.append("==");
	result.append(expressionToString(expr->right));
	return result;
   } 
   if (expr->type == EXPR_NE) {
   	result.append(expressionToString(expr->left));
	result.append("!=");
	result.append(expressionToString(expr->right));
	return result;
   } 
   if (expr->type == EXPR_GE) {
   	result.append(expressionToString(expr->left));
	result.append(">=");
	result.append(expressionToString(expr->right));
	return result;
   } 
   if (expr->type == EXPR_LE) {
   	result.append(expressionToString(expr->left));
	result.append("<=");
	result.append(expressionToString(expr->right));
	return result;
   } 
   if (expr->type == EXPR_GT) {
   	result.append(expressionToString(expr->left));
	result.append(">");
	result.append(expressionToString(expr->right));
	return result;
   } 
   if (expr->type == EXPR_LT) {
   	result.append(expressionToString(expr->left));
	result.append("<");
	result.append(expressionToString(expr->right));
	return result;
   } 
   if (expr->type == EXPR_INTEGER) {
   	result.append("INTEGER");
        return result;
   }
   if (expr->type == EXPR_BOOLEAN) {
   	result.append("BOOLEAN");
        return result;
   }
   if (expr->type == EXPR_VARIABLE) {
   	result.append("VARIABLE");
        return result;
   }
   if (expr->type == EXPR_FUNCTION_CALL) {
   	result.append("FUNCTION_CALL");
        return result;
   }
}
// DEBUG END ^^

// WORK WITH VARIABLES

void addVariable(TMyVariable* x, set<string> &local, map<string, vector<TMyVariable*> > &var) {
    if (local.count(x->name) != 0) {
	cout << "Duplicate declaration: " << x->name << endl;
	exit(0);
    }
    local.insert(x->name);
    var[x->name].push_back(x);
}

TMyVariable* getVariable(string name, map<string, vector<TMyVariable*> > &var) {
    if (var.count(name) == 0) {
	cout << name << " is not declared!" << endl;
	exit(0);
    }
    return var[name][var[name].size() - 1];
}

void deleteVariable(string name, map<string, vector<TMyVariable*> > &var) {
    if (var.count(name) == 0) {
	cout << name << " cannot delete!" << endl;
	exit(0);
    }
    var[name].pop_back();
    if (var[name].size() == 0) {
	var.erase(name);
    }
}

void deleteSetVariables(set<string> &local, map<string, vector<TMyVariable*> > &var) {
    set<string>::iterator ik;
    for(ik = local.begin(); ik != local.end(); ++ik)
        deleteVariable(*ik, var);
}

// processor!)

// +IMPORTANT
TMyFunctionList* functions;
// -IMPORTANT

TMyVariable* runFunction(TMyFunction* func, map<string, vector<TMyVariable*> > &var);
TMyVariable* processFunctionCall(TMyFunctionCall* x, map<string, vector<TMyVariable*> > &var);

TMyVariable* processExpression(TMyExpression* expr, map<string, vector<TMyVariable*> > &var) {
    TMyVariable * result = new TMyVariable();

    if (expr->type == EXPR_INTEGER) {
    	result->type = INTEGER_TYPE;    
	result->int_value = expr->intValue;
	return result;
    }

    if (expr->type == EXPR_DOUBLE) {
    	result->type = DOUBLE_TYPE;    
	result->double_value = expr->doubleValue;
	return result;
    }

    if (expr->type == EXPR_STRING) {
    	result->type = STRING_TYPE;    
	result->string_value = expr->name;
	return result;
    }

    if (expr->type == EXPR_BOOLEAN) {
    	result->type = BOOLEAN_TYPE;    
	result->bool_value = expr->booleanValue;
	return result;
    }

    if (expr->type == EXPR_VARIABLE) {
	TMyVariable* variable = getVariable(*expr->name, var);
    	result->type = variable->type;
	if (variable->initialized == false) {
	    cout << endl;
	    cout << "Variable " << variable->name << " isn't initialized!" << endl;
	    exit(0);	
	}
        if (variable->type == INTEGER_TYPE) {
       	    result->int_value = variable->int_value;
        } else if (variable->type == BOOLEAN_TYPE) {
       	    result->bool_value = variable->bool_value;
        } else if (variable->type == STRING_TYPE) {
       	    result->string_value = new string(*variable->string_value);
        } else if (variable->type == DOUBLE_TYPE) {
       	    result->double_value = variable->double_value;
        }
	return result;
    }

    //function call
    if (expr->type == EXPR_FUNCTION_CALL) { 
	result = processFunctionCall(expr->function, var);
	if (result == NULL) {
	    cout << "Invalid function call in expression " << expr->function->name << endl;
	    exit(0);	
	}
	return result;
    }

    if (expr->type == EXPR_NOT) {
        TMyVariable * left = processExpression(expr->left,var);
        if (left->type != BOOLEAN_TYPE) {
	    cout << "Wrong types in expression." << endl;
	    exit(0);
	}
        result->type = BOOLEAN_TYPE;
	result->bool_value = !(left->bool_value);
        return result;
    }

    TMyVariable * left = processExpression(expr->left,var);
    TMyVariable * right = processExpression(expr->right,var);

    
    if (expr->type == EXPR_PLUS) {
		if (left->type == INTEGER_TYPE && right->type == DOUBLE_TYPE) {
		 	result->type = INTEGER_TYPE;
		 	result->int_value = left->int_value + right->double_value;
		        return result;
		}
		if (left->type == INTEGER_TYPE && right->type == INTEGER_TYPE) {
		 	result->type = INTEGER_TYPE;
		 	result->int_value = left->int_value + right->int_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == DOUBLE_TYPE) {
		 	result->type = DOUBLE_TYPE;
		 	result->double_value = left->double_value + right->double_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == INTEGER_TYPE) {
		 	result->type = DOUBLE_TYPE;
		 	result->double_value = left->double_value + right->int_value;
		        return result;
		}
		if (left->type == STRING_TYPE && right->type == STRING_TYPE) {
		 	result->type = STRING_TYPE;
	                string *name = new string(*left->string_value);
	 		name->append(*right->string_value);
		 	result->string_value = name;
		        return result;
		}
	cout << "Can't plus diffrent types or boolean ones." << endl;	
	exit(0);
    }
    
    if (expr->type == EXPR_MINUS) {
		if (left->type == INTEGER_TYPE && right->type == DOUBLE_TYPE) {
		 	result->type = INTEGER_TYPE;
		 	result->int_value = left->int_value - right->double_value;
		        return result;
		}
		if (left->type == INTEGER_TYPE && right->type == INTEGER_TYPE) {
		 	result->type = INTEGER_TYPE;
		 	result->int_value = left->int_value - right->int_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == DOUBLE_TYPE) {
		 	result->type = DOUBLE_TYPE;
		 	result->double_value = left->double_value - right->double_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == INTEGER_TYPE) {
		 	result->type = DOUBLE_TYPE;
		 	result->double_value = left->double_value - right->int_value;
		        return result;
		}
	cout << "Can't minus diffrent types or boolean ones." << endl;	
	exit(0);	
    }
    
    if (expr->type == EXPR_MUL) {
       		if (left->type == INTEGER_TYPE && right->type == DOUBLE_TYPE) {
		 	result->type = INTEGER_TYPE;
		 	result->int_value = left->int_value * right->double_value;
		        return result;
		}
		if (left->type == INTEGER_TYPE && right->type == INTEGER_TYPE) {
		 	result->type = INTEGER_TYPE;
		 	result->int_value = left->int_value * right->int_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == DOUBLE_TYPE) {
		 	result->type = DOUBLE_TYPE;
		 	result->double_value = left->double_value * right->double_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == INTEGER_TYPE) {
		 	result->type = DOUBLE_TYPE;
		 	result->double_value = left->double_value * right->int_value;
		        return result;
		}
	cout << "Can't mul diffrent types or boolean ones." << endl;	
	exit(0);	
    }
    
    if (expr->type == EXPR_DIV) {
       		if (left->type == INTEGER_TYPE && right->type == DOUBLE_TYPE) {
		 	result->type = INTEGER_TYPE;
		 	result->int_value = left->int_value / right->double_value;
		        return result;
		}
		if (left->type == INTEGER_TYPE && right->type == INTEGER_TYPE) {
		 	result->type = INTEGER_TYPE;
		 	result->int_value = left->int_value / right->int_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == DOUBLE_TYPE) {
		 	result->type = DOUBLE_TYPE;
		 	result->double_value = left->double_value / right->double_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == INTEGER_TYPE) {
		 	result->type = DOUBLE_TYPE;
		 	result->double_value = left->double_value / right->int_value;
		        return result;
		}
	cout << "Can't div diffrent types or boolean ones." << endl;	
	exit(0);	
    }

    if (expr->type == EXPR_OR) {
        if (left->type != BOOLEAN_TYPE || right->type != BOOLEAN_TYPE) {
	    cout << "Wrong types in OR expression!" << endl;
	    exit(0);	
	}
	result->type = BOOLEAN_TYPE;
	result->bool_value = left->bool_value | right->bool_value;
	return result;	
    }

    if (expr->type == EXPR_AND) {
        if (left->type != BOOLEAN_TYPE || right->type != BOOLEAN_TYPE) {
	    cout << "Wrong types in AND expression!" << endl;
	    exit(0);	
	}
	result->type = BOOLEAN_TYPE;
	result->bool_value = left->bool_value & right->bool_value;
	return result;	
    }

    if (expr->type == EXPR_GE) {
	result->type = BOOLEAN_TYPE;
		if (left->type == INTEGER_TYPE && right->type == DOUBLE_TYPE) {
		 	result->bool_value = left->int_value >= right->double_value;
		        return result;
		}
		if (left->type == INTEGER_TYPE && right->type == INTEGER_TYPE) {
		 	result->bool_value = left->int_value >= right->int_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == DOUBLE_TYPE) {
		 	result->bool_value = left->double_value >= right->double_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == INTEGER_TYPE) {
		 	result->bool_value = left->double_value >= right->int_value;
		        return result;
		}
		if (left->type == STRING_TYPE && right->type == STRING_TYPE) {
		 	result->bool_value = (*left->string_value >= *right->string_value);
		        return result;
		}
	cout << "Can't >= diffrent types or boolean ones." << endl;	
	exit(0);
    }

    if (expr->type == EXPR_LE) {
	result->type = BOOLEAN_TYPE;
		if (left->type == INTEGER_TYPE && right->type == DOUBLE_TYPE) {
		 	result->bool_value = left->int_value <= right->double_value;
		        return result;
		}
		if (left->type == INTEGER_TYPE && right->type == INTEGER_TYPE) {
		 	result->bool_value = left->int_value <= right->int_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == DOUBLE_TYPE) {
		 	result->bool_value = left->double_value <= right->double_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == INTEGER_TYPE) {
		 	result->bool_value = left->double_value <= right->int_value;
		        return result;
		}
		if (left->type == STRING_TYPE && right->type == STRING_TYPE) {
		 	result->bool_value = (*left->string_value <= *right->string_value);
		        return result;
		}
	cout << "Can't <= diffrent types or boolean ones." << endl;	
	exit(0);
    }

    if (expr->type == EXPR_GT) {
	result->type = BOOLEAN_TYPE;
		if (left->type == INTEGER_TYPE && right->type == DOUBLE_TYPE) {
		 	result->bool_value = left->int_value > right->double_value;
		        return result;
		}
		if (left->type == INTEGER_TYPE && right->type == INTEGER_TYPE) {
		 	result->bool_value = left->int_value > right->int_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == DOUBLE_TYPE) {
		 	result->bool_value = left->double_value > right->double_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == INTEGER_TYPE) {
		 	result->bool_value = left->double_value > right->int_value;
		        return result;
		}
		if (left->type == STRING_TYPE && right->type == STRING_TYPE) {
		 	result->bool_value = (*left->string_value > *right->string_value);
		        return result;
		}
	cout << "Can't > diffrent types or boolean ones." << endl;	
	exit(0);
    }

    if (expr->type == EXPR_LT) {
  	result->type = BOOLEAN_TYPE;
		if (left->type == INTEGER_TYPE && right->type == DOUBLE_TYPE) {
		 	result->bool_value = left->int_value < right->double_value;
		        return result;
		}
		if (left->type == INTEGER_TYPE && right->type == INTEGER_TYPE) {
		 	result->bool_value = left->int_value < right->int_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == DOUBLE_TYPE) {
		 	result->bool_value = left->double_value < right->double_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == INTEGER_TYPE) {
		 	result->bool_value = left->double_value < right->int_value;
		        return result;
		}
		if (left->type == STRING_TYPE && right->type == STRING_TYPE) {
		 	result->bool_value = (*left->string_value < *right->string_value);
		        return result;
		}
	cout << "Can't < diffrent types or boolean ones." << endl;	
	exit(0);
    }

    if (expr->type == EXPR_EQ) {
        result->type = BOOLEAN_TYPE;
		if (left->type == INTEGER_TYPE && right->type == DOUBLE_TYPE) {
		 	result->bool_value = left->int_value == right->double_value;
		        return result;
		}
		if (left->type == INTEGER_TYPE && right->type == INTEGER_TYPE) {
		 	result->bool_value = left->int_value == right->int_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == DOUBLE_TYPE) {
		 	result->bool_value = left->double_value == right->double_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == INTEGER_TYPE) {
		 	result->bool_value = left->double_value == right->int_value;
		        return result;
		}
		if (left->type == STRING_TYPE && right->type == STRING_TYPE) {
		 	result->bool_value = (*left->string_value == *right->string_value);
		        return result;
		}
		if (left->type == BOOLEAN_TYPE && right->type == BOOLEAN_TYPE) {
		 	result->bool_value = (left->bool_value == right->bool_value);
		        return result;
		}
		
	cout << "Can't == diffrent types or boolean ones." << endl;	
	exit(0);
    }

    if (expr->type == EXPR_NE) {
         result->type = BOOLEAN_TYPE;
		if (left->type == INTEGER_TYPE && right->type == DOUBLE_TYPE) {
		 	result->bool_value = left->int_value != right->double_value;
		        return result;
		}
		if (left->type == INTEGER_TYPE && right->type == INTEGER_TYPE) {
		 	result->bool_value = left->int_value != right->int_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == DOUBLE_TYPE) {
		 	result->bool_value = left->double_value != right->double_value;
		        return result;
		}
		if (left->type == DOUBLE_TYPE && right->type == INTEGER_TYPE) {
		 	result->bool_value = left->double_value != right->int_value;
		        return result;
		}
		if (left->type == STRING_TYPE && right->type == STRING_TYPE) {
		 	result->bool_value = (*left->string_value != *right->string_value);
		        return result;
		}
		if (left->type == BOOLEAN_TYPE && right->type == BOOLEAN_TYPE) {
		 	result->bool_value = (left->bool_value != right->bool_value);
		        return result;
		}
		
	cout << "Can't != diffrent types or boolean ones." << endl;	
	exit(0);	
    }

    cout << "Failed to calculate expression!" << endl; 
    exit(0);
    return NULL;
}

void processDeclaration(TMyDeclaration* declaration,  set<string> &local, map<string, vector<TMyVariable*> > &var) {
	TMyVariable* newVar = new TMyVariable;
	newVar->name = declaration->name;
	newVar->type = declaration->type;
	if (declaration->expression != NULL) {
	    newVar->initialized = true;
	    TMyVariable* expr = processExpression(declaration->expression, var);
	    if (newVar->type == INTEGER_TYPE) {
		newVar->int_value = expr->int_value; 
	    }
	    if (newVar->type == BOOLEAN_TYPE) {
		newVar->bool_value = expr->bool_value; 
	    }
	    if (newVar->type == DOUBLE_TYPE) {
		newVar->double_value = expr->double_value; 
	    }
	    if (newVar->type == STRING_TYPE) {
		newVar->string_value = new string(*expr->string_value); 
	    }
	} else {
	    newVar->initialized = false;
	}
	addVariable(newVar,local,var);
}

void processSYSTEMOUTPRINTLN(TMyExpressionList* x, map<string, vector<TMyVariable*> > &var) {
    for(int i = 0; i < x->data.size(); ++i) {
        TMyVariable* expr = processExpression(x->data[i], var);
	if (expr->type == INTEGER_TYPE) {
	    cout << expr->int_value;
	    continue;
	} 
	if (expr->type == BOOLEAN_TYPE) {
	    if (expr->bool_value) 
               cout << "true"; else cout << "false";
	    continue;
	} 
	if (expr->type == DOUBLE_TYPE) {
	    cout.precision(12);
	    cout << fixed << expr->double_value;
	    continue;
	} 
	if (expr->type == STRING_TYPE) {
	    cout << *expr->string_value;
	    continue;
	} 
    }
    cout << endl;
}


void processSYSTEMOUTPRINT(TMyExpressionList* x, map<string, vector<TMyVariable*> > &var) {
    for(int i = 0; i < x->data.size(); ++i) {
        TMyVariable* expr = processExpression(x->data[i], var);
	if (expr->type == INTEGER_TYPE) {
	    cout << expr->int_value;
	    continue;
	} 
	if (expr->type == BOOLEAN_TYPE) {
	    if (expr->bool_value) 
               cout << "true"; else cout << "false";
	    continue;
	} 
	if (expr->type == DOUBLE_TYPE) {
	    cout.precision(12);
	    cout << expr->double_value;
	    continue;
	} 
	if (expr->type == STRING_TYPE) {
	    cout << *expr->string_value;
	    continue;
	} 
    }
}


TMyVariable* processDefinition(TMyDefinition* x, map<string, vector<TMyVariable*> > &var) {
    TMyVariable* expr = getVariable(x->name, var);
    TMyVariable* cool = processExpression(x->expression, var);
    if (expr->type == INTEGER_TYPE) {
	if (cool->type != INTEGER_TYPE) {
	    cout << "Wrong expression type!" << endl;
	    exit(0);
	}
        expr->int_value = cool->int_value;
    }
    if (expr->type == BOOLEAN_TYPE) {
    	if (cool->type != BOOLEAN_TYPE) {
	    cout << "Wrong expression type!" << endl;
	    exit(0);
	}
	expr->bool_value = cool->bool_value;
    }
    return NULL;  
}



TMyVariable* callMyFunction(TMyFunctionCall* xx, TMyFunction* y, map<string, vector<TMyVariable*> > &var) {
    if (xx->expressions->data.size() != y->args->data.size()) {
	cout << "Invalid number of arguments in function " << y->name << endl;
	exit(0);
    }
    TMyArgumentList* args = y->args;
    TMyExpressionList* list = xx->expressions;

    set<string> local;
    map<string, vector<TMyVariable*> > var2;

    for (int i = 0; i < xx->expressions->data.size(); ++i) {
    	TMyVariable* x = new TMyVariable();	
	x->name = args->data[i].name;
	x->type = args->data[i].type; 
	x->initialized = true;
	if (args->data[i].type == INTEGER_TYPE) {
	    TMyVariable* expr = processExpression(list->data[i], var); 
	    if (expr->type != INTEGER_TYPE) {
	    	cout << "Invalid expression type!" << endl;
	        exit(0);
	    }
	    x->int_value = expr->int_value;
	}
	if (args->data[i].type == BOOLEAN_TYPE) {
	    TMyVariable* expr = processExpression(list->data[i], var); 
	    if (expr->type != BOOLEAN_TYPE) {
	    	cout << "Invalid expression type!" << endl;
	        exit(0);
	    }
	    x->bool_value = expr->bool_value;
	}
	addVariable(x,local,var2);
    }

   return runFunction(y,var2);
}

TMyVariable* processINTEGERPARSE(TMyExpressionList* x, map<string, vector<TMyVariable*> > &var) {
     if (x->data.size() != 1) {
	cout << "Wrong number of args in parseInteger." << endl;
	exit(0);
     }
     TMyVariable* expr = processExpression(x->data[0], var);
     
     if (expr->type != STRING_TYPE) {
	cout << "Wrong argument type in parseInteger." << endl;
	exit(0);
     }
     expr->type = INTEGER_TYPE;
     expr->int_value = atoi((*expr->string_value).c_str()); 
     return expr;
}


TMyVariable* processDOUBLEPARSE(TMyExpressionList* x, map<string, vector<TMyVariable*> > &var) {
     if (x->data.size() != 1) {
	cout << "Wrong number of args in parseInteger." << endl;
	exit(0);
     }
     TMyVariable* expr = processExpression(x->data[0], var);
     if (expr->type != STRING_TYPE) {
	cout << "Wrong argument type in parseInteger." << endl;
	exit(0);
     }
     expr->type = DOUBLE_TYPE;
     expr->double_value = atof((*expr->string_value).c_str()); 
     return expr;
}

string ConvertF (float number){
    std::ostringstream buff;
    buff<<number;
    return buff.str();   
}

string ConvertI (int number){
    std::ostringstream buff;
    buff<<number;
    return buff.str();   
}

TMyVariable* processDOUBLETOSTRING(TMyExpressionList* x, map<string, vector<TMyVariable*> > &var) {
     if (x->data.size() != 1) {
	cout << "Wrong number of args in Double to string." << endl;
	exit(0);
     }
     TMyVariable* expr = processExpression(x->data[0], var);
     if (expr->type != DOUBLE_TYPE) {
	cout << "Wrong argument type in Double to string." << endl;
	exit(0);
     }
     expr->type = STRING_TYPE;
     expr->string_value = new string(ConvertF(expr->double_value)); 
     return expr;
}

TMyVariable* processINTEGERTOSTRING(TMyExpressionList* x, map<string, vector<TMyVariable*> > &var) {
     if (x->data.size() != 1) {
	cout << "Wrong number of args in Integer to string." << endl;
	exit(0);
     }
     TMyVariable* expr = processExpression(x->data[0], var);
     if (expr->type != INTEGER_TYPE) {
	cout << "Wrong argument type in Integer to string." << endl;
	exit(0);
     }
     expr->type = STRING_TYPE;
     expr->string_value = new string(ConvertI(expr->int_value)); 
     return expr;
}

TMyVariable* processFunctionCall(TMyFunctionCall* x, map<string, vector<TMyVariable*> > &var) {
    if (x->name == "System.out.println") {
	    processSYSTEMOUTPRINTLN(x->expressions,var);
	    return NULL;      	
	}	
    if (x->name == "System.out.print") {
	    processSYSTEMOUTPRINT(x->expressions,var);
	    return NULL;      	
	}
    if (x->name == "Integer.parse") {
	    return processINTEGERPARSE(x->expressions,var);	
	}
    if (x->name == "Double.parse") {
	    return processDOUBLEPARSE(x->expressions,var);	
	}
    if (x->name == "Integer.toString") {
	    return processINTEGERTOSTRING(x->expressions,var);	
	}
    if (x->name == "Double.toString") {
	    return processDOUBLETOSTRING(x->expressions,var);	
	}

    for(int i = 0; i < functions->data.size(); ++i) {
	if (functions->data[i]->name == x->name) {
	    return callMyFunction(x, functions->data[i], var);	
	}
    } 	
}

TMyVariable* processNodes(TNodeList* algo, map<string, vector<TMyVariable*> > &var);

TMyVariable* processIfNode(TMyIfStatement* x, map<string, vector<TMyVariable*> > &var) {
    TMyVariable* expr = processExpression(x->expression, var);
    if (expr->type != BOOLEAN_TYPE) {
	cout << "If statement has not boolean type!" << endl;
	exit(0);
    }   
    if (expr->bool_value == true) {
        return processNodes(x->then_, var);
    } else {
	    return processNodes(x->else_, var);
	}
}

TMyVariable* processWhileNode(TMyWhileStatement* x, map<string, vector<TMyVariable*> > &var) {
    while (true) {
    	TMyVariable* expr = processExpression(x->expression, var);
	if (expr->type != BOOLEAN_TYPE) {
		cout << "While statement has not boolean type!" << endl;
		exit(0);
        }
        if (expr->bool_value == true) {
            TMyVariable* res = processNodes(x->body, var);
	    if (res != NULL) return res;
        } else {
	    return NULL;
	}
	  
    }
}

TMyVariable* processNode(TNode* x,  set<string> &local, map<string, vector<TMyVariable*> > &var) {
    if (x->type == DECLARATION_NODE) {
	processDeclaration(x->declaration, local, var);
	return NULL;
    }
    if (x->type == FUNCTION_CALL_NODE) {
        processFunctionCall(x->function, var);
	return NULL;
    }	
    if (x->type == DEFINITION_NODE) {
        processDefinition(x->definition, var);
	return NULL;
    }
    if (x->type == NODELIST_NODE) {
  	return processNodes(x->nodeList, var);  
    }
    if (x->type == RETURN_NODE) {
       return processExpression(x->returnExpr, var);  
    }
    if (x->type == IF_NODE) {
       return processIfNode(x->ifStatement, var);
    }
    if (x->type == WHILE_NODE) {
       return processWhileNode(x->whileStatement, var);
    }
    return NULL;
}

TMyVariable* processNodes(TNodeList* algo, map<string, vector<TMyVariable*> > &var) {
    if (algo == NULL) {
    	return NULL;
    }

    set<string> local;
    TMyVariable* returnValue;
    for(int i = 0; i < algo->data.size(); ++i) {
        if ((returnValue = processNode(algo->data[i], local, var)) != NULL) {
	   deleteSetVariables(local, var);
	   return returnValue;	
	}	
    }
    deleteSetVariables(local,var); 
    return NULL;
}

TMyVariable* runFunction(TMyFunction* func, map<string, vector<TMyVariable*> > &var) {
    TNodeList* algo = func->list;
    TMyVariable* v = processNodes(algo, var);
    if (v != NULL) {
	if (func->returnType != v->type) {
	    cout << "Invalid return type in function " << func->name << endl;
	    exit(0);
	}
	return v;
    }
    if (func->returnType != VOID_TYPE) {
    	cout << "No return statement in function " << func->name << endl;
	exit(0);
    }
    return NULL;
}

void runTheProgramm(TMyProgram* prog) {
    functions = prog->functions;
    for (int i = 0; i < functions->data.size(); ++i) {
        if (functions->data[i]->name == "main") {
	    map<string, vector<TMyVariable*> > var;
	    runFunction(functions->data[i], var);
	    return;	
	}
    }
    cout << "No method 'main' found!" << endl;
}


void yyerror(const char *s) 
{
   fprintf(stderr, "%s line: %d\n", s, yylineno);
}

// инициализация перед парсингом всего
void init() {
    mainProgram = NULL;
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
    if (mainProgram != NULL)printf("The build was successfull!\nRunning the programm...\n\n\n");
    if (mainProgram != NULL) runTheProgramm(mainProgram);
    return 0;
}

