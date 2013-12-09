%{
#include <stdio.h>
#include <stdlib.h>
#include "types.h"
#include "y.tab.h"


void yyerror(const char *);
//VarTableRecord * var_pointer;
%}
%option yylineno
%%

[0-9]+  {yylval.intValue = atoi(yytext);return INTEGER;}
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
true   	{yylval.booleanValue = true; return BOOLEAN;}
false  	{yylval.booleanValue = false; return BOOLEAN;}

public 	{return PUBLIC;}
private {return PRIVATE;}
class	{return CLASS;}
static  {return STATIC;}

void	{return VOID;}
int	{return INTEGER;}
boolean {return BOOLEAN;}
String  {return STRING;}
"return"  {return RETURN;}


"{"	{return BEGIN_BRACKET;}
"}"	{return END_BRACKET;}

[a-zA-Z_][a-zA-Z_0-9.]* { 
                           yylval.stringValue = strdup(yytext);//имя                     
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
