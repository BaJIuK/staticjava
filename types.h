
#include <vector>
#include <string>
#include <map>

using namespace std;


struct TMyExpression;

// объявление переменной
const int BOOLEAN_TYPE = 1;
const int INTEGER_TYPE = 2;
const int VOID_TYPE = 3;
const int STRING_TYPE = 4;
struct TMyVariable {
    string name;      // имя
    int type;         // тип
    bool declarated;  // задекларирована (всегда true)
    bool initialized; // инициализирована?
    bool local;       // является ли локальной?! (пока не знаю зачем)
 
    union {
	int int_value;        // целое значение
	bool bool_value;      // булево
	char* string_value;   // строковое	
    };

    // конструктор
    TMyVariable(string name_, int type_, bool declarated_, bool initialized_, bool local_) {
	name = name_;
	type = type_;
	declarated = declarated_;
	initialized = initialized_;
	local = local_;
    }
};

struct TMyArgumentList {
    vector <TMyVariable> data;
};

struct TMyVariableList {
    map<string, TMyVariable> data;
};


// вызов функции
struct TMyFunctionCall {
    string name;                // имя
    TMyArgumentList* arguments; // список значений аргументов
};

// декларирование переменной
struct TMyDeclaration {
    string name; 		// name - имя переменной
    int type;			// type - ее тип
    TMyExpression* expression;  // expression - вычисление начального значения
    TMyDeclaration(string name_, int type_, TMyExpression* expression_) { 
	name = name_;
	type = type_;
	expression = expression_;
    }
};

// тело
const int DECLARATION_TYPE = 1; // декларация
const int FUNCTION_TYPE = 2;    // вызов функции
struct TMyBody {
    int type;
    //union {
        //TMyDeclaration* declaration; // оператор декларации
	//TMyFunctionCall* function;   // вызов функции
	//оператор цикла и вывода
	//parseInt ...
    //};
   // TMyNode * next; //следующее звено
};

struct TNode;
// функция
struct TMyFunction {
    string name;            // имя
    TMyArgumentList* args;  // аргументы
    TNode* start;           // тело функции
    int returnType;         // возвращаемое значение     

    TMyFunction(string newName, TMyArgumentList* newArgs, TNode* newNode, int type) {
        name = newName;
        args = newArgs;
        start = newNode;
        returnType = type;
    }
};

// присвоение значения переменной
struct TMyDefinition {
    string name;               // имя
    TMyExpression* expression; // значение
};

struct TNode;
// звено (одна команда)
const int DECLARATION_NODE = 1;
const int FUNCTION_CALL_NODE = 2;
const int DEFINITION_NODE = 3;
const int FINAL_NODE = 4;

struct TNode {
    int type;
    union {
        TMyDeclaration * declaration; // объявление переменной
        TMyFunctionCall * function;   // вызов функции 
        TMyDefinition * definition;
    };
};

//тело программы цикла итд
struct TNodeList {
   vector<TNode*> data;
};

// все методы в главном классе
struct TMyFunctionList {
    vector<TMyFunction> functions;
};

// выражение
const int EXPR_PLUS = 1;
const int EXPR_MINUS = 2;
const int EXPR_MUL = 3;
const int EXPR_DIV = 4;
const int EXPR_INTEGER = 5;
const int EXPR_BOOLEAN = 6;
const int EXPR_AND = 7;
const int EXPR_OR = 8;
const int EXPR_NOT = 9;
const int EXPR_VARIABLE = 10;
const int EXPR_FUNCTION_CALL = 11;

struct TMyExpression {
    int type;
    union {
	int intValue;
	bool booleanValue;
	string* name;
	TMyFunctionCall* function;
    };
    TMyExpression* left;
    TMyExpression* right;

    TMyExpression() {
	left = NULL;
        right = NULL;
    };
};
