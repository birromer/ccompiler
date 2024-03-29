/** lexer.l - Lexer specification definition
 *
 * @author Henrique Silva <hcpsilva@inf.ufrgs.br>
 * @author Bernardo Hummes <bhflores@inf.ufrgs.br>
 */

%{
#include "lexer/scanner.h"
%}

/* no need to use the default flex main */
%option noyywrap yylineno

/* helpful character classes */
WHITE [[:blank:]]
GRAPH [[:graph:]]
ALNUM [[:alnum:]_]
ALPHA [[:alpha:]_]

/* to handle escape sequences require the modification of the matched
 * string, which is not a good idea to do with yytext, as it points
 * directly to the input stream */
ESC_SEQ [abfnrtv\\\"\']

/* reserved keywords */
RK_INT "int"
RK_FLOAT "float"
RK_BOOL "bool"
RK_CHAR "char"
RK_STRING "string"
RK_IF "if"
RK_THEN "then"
RK_ELSE "else"
RK_WHILE "while"
RK_DO "do"
RK_INPUT "input"
RK_OUTPUT "output"
RK_RETURN "return"
RK_CONST "const"
RK_STATIC "static"
RK_FOREACH "foreach"
RK_FOR "for"
RK_SWITCH "switch"
RK_CASE "case"
RK_BREAK "break"
RK_CONTINUE "continue"
RK_CLASS "class"
RK_PRIVATE "private"
RK_PUBLIC "public"
RK_PROTECTED "protected"
RK_END "end"
RK_DEFAULT "default"

/* special punctuation characters */
SPC_CHAR [[:punct:]]{-}[\'\"\`_~\\]

/* delimiters, which are either whitespace or special punctuation
 * characters */
DELIM [[:punct:][:space:]]{-}[_\\~]

/* composite operators */
OP_LE "<="
OP_GE ">="
OP_EQ "=="
OP_NE "!="
OP_AND "&&"
OP_OR "||"
OP_SL "<<"
OP_SR ">>"

/* decimals */
NUMBER [[:digit:]]
SCI_NOT [eE][+\-]?{NUMBER}+

/* boolean literals */
BOOL_T "true"
BOOL_F "false"

/* states */
%x COMMENT
%x WORD
%x STRING
%x QUOTE
%x ID
%x DECIMAL

%%

    /* ----------  comments section ----------  */

    /* block comment*/
"/*"                                   { BEGIN(COMMENT); V_LOG_LEXER("COMMENT STATE"); }

    /* comment state */
<COMMENT>{

"*"+"/"                                { BEGIN(INITIAL); V_LOG_LEXER("INITIAL STATE"); }
[^*\n]*
"*"+[^*/\n]*
\n
<<EOF>>                                { return TOKEN_ERRO; }

}

    /* line comments */
"//".*\n


    /* ----------  words section ----------  */

{ALPHA}/{ALNUM}*                       { BEGIN(WORD); V_LOG_LEXER("WORD STATE"); yyless(0); }


    /* word state */
<WORD>{

    /* reserved keywords */
{RK_INT}                               { V_LOG_LEXER("RK_INT"); return TK_PR_INT; }
{RK_FLOAT}                             { V_LOG_LEXER("RK_FLOAT"); return TK_PR_FLOAT; }
{RK_BOOL}                              { V_LOG_LEXER("RK_BOOL"); return TK_PR_BOOL; }
{RK_CHAR}                              { V_LOG_LEXER("RK_CHAR"); return TK_PR_CHAR; }
{RK_STRING}                            { V_LOG_LEXER("RK_STRING"); return TK_PR_STRING; }
{RK_IF}                                { V_LOG_LEXER("RK_IF"); return TK_PR_IF; }
{RK_THEN}                              { V_LOG_LEXER("RK_THEN"); return TK_PR_THEN; }
{RK_ELSE}                              { V_LOG_LEXER("RK_ELSE"); return TK_PR_ELSE; }
{RK_WHILE}                             { V_LOG_LEXER("RK_WHILE"); return TK_PR_WHILE; }
{RK_DO}                                { V_LOG_LEXER("RK_DO"); return TK_PR_DO; }
{RK_INPUT}                             { V_LOG_LEXER("RK_INPUT"); return TK_PR_INPUT; }
{RK_OUTPUT}                            { V_LOG_LEXER("RK_OUTPUT"); return TK_PR_OUTPUT; }
{RK_RETURN}                            { V_LOG_LEXER("RK_RETURN"); return TK_PR_RETURN; }
{RK_CONST}                             { V_LOG_LEXER("RK_CONST"); return TK_PR_CONST; }
{RK_STATIC}                            { V_LOG_LEXER("RK_STATIC"); return TK_PR_STATIC; }
{RK_FOREACH}                           { V_LOG_LEXER("RK_FOREACH"); return TK_PR_FOREACH; }
{RK_FOR}                               { V_LOG_LEXER("RK_FOR"); return TK_PR_FOR; }
{RK_SWITCH}                            { V_LOG_LEXER("RK_SWITCH"); return TK_PR_SWITCH; }
{RK_CASE}                              { V_LOG_LEXER("RK_CASE"); return TK_PR_CASE; }
{RK_BREAK}                             { V_LOG_LEXER("RK_BREAK"); return TK_PR_BREAK; }
{RK_CONTINUE}                          { V_LOG_LEXER("RK_CONTINUE"); return TK_PR_CONTINUE; }
{RK_CLASS}                             { V_LOG_LEXER("RK_CLASS"); return TK_PR_CLASS; }
{RK_PRIVATE}                           { V_LOG_LEXER("RK_PRIVATE"); return TK_PR_PRIVATE; }
{RK_PUBLIC}                            { V_LOG_LEXER("RK_PUBLIC"); return TK_PR_PUBLIC; }
{RK_PROTECTED}                         { V_LOG_LEXER("RK_PROTECTED"); return TK_PR_PROTECTED; }
{RK_END}                               { V_LOG_LEXER("RK_END"); return TK_PR_END; }
{RK_DEFAULT}                           { V_LOG_LEXER("RK_DEFAULT"); return TK_PR_DEFAULT; }

    /* boolean literals */
{BOOL_T}                               { V_LOG_LEXER("TRUE"); return TK_LIT_TRUE; }
{BOOL_F}                               { V_LOG_LEXER("FALSE"); return TK_LIT_FALSE; }

    /* identifiers */
{ALPHA}{ALNUM}*                        { V_LOG_LEXER("IDENTIFIER"); return TK_IDENTIFICADOR; }

    /* end word */
{DELIM}                                { BEGIN(INITIAL); V_LOG_LEXER("INITIAL STATE"); yyless(0); }

}


    /* ---------- special characters section ----------  */

    /* composite operators */
{OP_LE}                                { V_LOG_LEXER("OP_LE"); return TK_OC_LE; }
{OP_GE}                                { V_LOG_LEXER("OP_GE"); return TK_OC_GE; }
{OP_EQ}                                { V_LOG_LEXER("OP_EQ"); return TK_OC_EQ; }
{OP_NE}                                { V_LOG_LEXER("OP_NE"); return TK_OC_NE; }
{OP_AND}                               { V_LOG_LEXER("OP_AND"); return TK_OC_AND; }
{OP_OR}                                { V_LOG_LEXER("OP_OR"); return TK_OC_OR; }
{OP_SL}                                { V_LOG_LEXER("OP_SL"); return TK_OC_SL; }
{OP_SR}                                { V_LOG_LEXER("OP_SR"); return TK_OC_SR; }

    /* special characters */
{SPC_CHAR}/{WHITE}?                    { V_LOG_LEXER("SPECIAL"); return (int)*yytext; }


    /* ---------- literals section ----------  */

    /* string literals */
"\""                                   { BEGIN(STRING); yymore(); V_LOG_LEXER("STRING STATE"); }
<STRING>("\\".|[^\"\n\\])*"\""         {
    BEGIN(INITIAL);
    V_LOG_LEXER("QUOTED STRING");
    return TK_LIT_STRING;
    }
<STRING>{GRAPH}                        {
    yyless(1);
    BEGIN(INITIAL);
    V_LOG_LEXER("MALFORMED STRING");
    return TOKEN_ERRO;
    }

    /* character literals */
"\'"                                   { BEGIN(QUOTE); yymore(); V_LOG_LEXER("CHAR STATE"); }
<QUOTE>("\\".|[^\'\n\\])"\'"           {
    BEGIN(INITIAL);
    V_LOG_LEXER("QUOTED CHARACTER");
    return TK_LIT_CHAR;
    }
<QUOTE>{GRAPH}                         {
    yyless(1);
    BEGIN(INITIAL);
    V_LOG_LEXER("MALFORMED QUOTE");
    return TOKEN_ERRO;
    }

    /* number literals */
{NUMBER}/{ALNUM}*                      {
    BEGIN(DECIMAL);
    V_LOG_LEXER("DECIMAL STATE");
    yyless(0);
    }

    /* decimal state */
<DECIMAL>{

    /* float */
{NUMBER}+"."{NUMBER}+{SCI_NOT}?        {
    BEGIN(INITIAL);
    V_LOG_LEXER("FLOATING POINT");
    return TK_LIT_FLOAT;
    }

    /* malformed float */
{NUMBER}+"."{ALNUM}+                   {
    BEGIN(INITIAL);
    V_LOG_LEXER("MALFORMED FLOATING POINT");
    return TOKEN_ERRO;
    }

    /* integer */
{NUMBER}+                              {
    BEGIN(INITIAL);
    V_LOG_LEXER("INTEGER");
    return TK_LIT_INT;
    }

    /* malformed decimal */
{ALNUM}+                               {
    BEGIN(INITIAL);
    V_LOG_LEXER("MALFORMED DECIMAL");
    return TOKEN_ERRO;
    }

}


    /* ---------- misc section ----------  */

    /* whitespace or newlines between tokens */
({WHITE}|\n)+                          { }

    /* error catch-all */
<*>.                                   { V_LOG_LEXER("UNKNOWN"); return TOKEN_ERRO; }

%%
