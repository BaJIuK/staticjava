%{
#include <stdio.h>
#include <stdlib.h>
#include "types.h"
#include "y.tab.h"

void yyerror(const char *);
//VarTableRecord * var_pointer;
%}

%%

[0-9]+  {yylval.val = atoi(yytext);return INTEGER;}
print   {return PRINT;} // not nesessary
if      {return IF;}
else    {return ELSE;}
then    {return THEN;}
while   {return WHILE;}
"&&"    {return AND;}
"||"    {return OR;}
">="    {return GE;}
"=="    {return EQ;}
"<="   	{return LE;}
"<"   	{return LT;}
">"   	{return GT;}
!=     	{return NE;}
!      	{return NOT;}
true   	{yylval.val = 1; return BOOLEAN;}
false  	{yylval.val = 0; return BOOLEAN;}

public 	{return PUBLIC;}
private {return PRIVATE;}
class	{return CLASS;}
static  {return STATIC;}

void	{return VOID;}
int	{return INTEGER;}
boolean {return BOOLEAN;}

"{"	{return BEGIN_BRACKET;}
"}"	{return END_BRACKET;}

[a-zA-Z_][a-zA-Z_0-9]* { 
                       //add variable to the table or get it fom it!                      
                       return VARIABLE;
                       }
"," 	{ return *yytext;}
[+-/*()_=;] { return *yytext;}

[ \t\n] ;
. {printf ("%s ", yytext); yyerror("Unknown symbol\n");}

%%

int yywrap(void)
{
  return 1;
}
