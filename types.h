
#include <vector>
#include <string>
#include <map>

using namespace std;

// объявление переменной
const int BOOLEAN_TYPE = 1;
const int INTEGER_TYPE = 2;
const int VOID_TYPE = 3;
const int STRING_TYPE = 4;
struct TMyVariable {
    string* name;     // имя
    int type;         // тип
    bool declarated;  // задекларирована (всегда true)
    bool initialized; // инициализирована?
    bool local;       // является ли локальной?! (пока не знаю зачем)
 
    union {
	int int_value;        // целое значение
	bool bool_value;      // булево
	string* string_value; // строковое	
    };

    // конструктор
    TMyVariable(string* name_, int type_, bool declarated_, bool initialized_, bool local_) {
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


// выражение
const int BOOLEAN_EXPR = 1;   // звено - булевское значение
const int INTEGER_EXPR = 2;   // целое
const int OPERATION_EXPR = 3; // если это операция (+ - *)
const int FUNCTION_EXPR = 4;  // если это вызов функции
struct TMyExpression {
    int type;
    union {
        int int_value;
        bool bool_value;
        int operation_type;
        TMyFunctionCall* function_call;
    };
    TMyExpression* left;  // левый аргумент
    TMyExpression* right; // правый аргумент
};

// декларирование переменной
// name - имя переменной
// type - ее тип
// expression - вычисление начального значения
struct TMyDeclaration {
    string name;
    int type;
    TMyExpression* expression; 
};

// тело
const int DECLARATION_TYPE = 1; // деккларация
const int FUNCTION_TYPE = 2;    // вызов функции
struct TMyBody {
    int type;
    union {
        TMyDeclaration* declaration; // оператор декларации
	TMyFunctionCall* function;   // вызов функции
    };
};

// функция
struct TMyFunction {
    string name;            // имя
    TMyArgumentList* args;  // аргументы
    TMyBody* body;          // тело функции
};

