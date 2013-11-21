
#include <vector>
#include <string>

using namespace std;

const int BOOLEAN_TYPE = 1;
const int INTEGER_TYPE = 2;
const int VOID_TYPE = 3;
const int STRING_TYPE = 4;

struct TMyVariable {
    string* name;
    int type;
    bool declarated;
    bool initialized;
    bool local;
 
    union {
	int int_value;  
	bool bool_value;
	string* string_value;	
    };


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
};


