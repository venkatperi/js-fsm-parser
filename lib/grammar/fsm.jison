%{
var actions = require('./fsmActions');
var child = actions.child;
var node = actions.node;
var option = actions.option;
var list = actions.list;
%}

/* FSM: lexical grammar */
%lex
%%

"//".*                /* ignore comment */
\s+                   /* skip whitespace */
"initial"             return 'INITIAL'
"transitions"         return 'TRANSITIONS'
"state"               return 'STATE'
"outputs"             return 'OUTPUTS'
[a-zA-Z0-9_]+\b       return 'ID'
"{"                   return 'LBRACE'
"}"                   return 'RBRACE'
","                   return 'COMMA'
"!"                   return 'BANG'
":"                   return 'COLON'
";"                   return 'SEMICOLON'
"->"                  return 'ARROW'
"#"                   return 'HASH'
"^"                   return 'CARET'
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex

/* operator associations and precedence */

%right  BANG
%left   COMMA
%nonassoc  COLON ARROW

%start expressions

%% /* language grammar */

expressions
    : initial transitions outputs EOF
        { $$ = node('FSM', {initial: $initial, transitions: $transitions, outputs: $outputs}); return $$; }
    ;

initial
    : INITIAL LBRACE initl RBRACE
        { $$ = $initl; }
    ;

initl
    : init SEMICOLON initl
        { $$ = child($initl, $init); }
    | init SEMICOLON
        { $$ = list($init); }
    ;

init
    : init_state
        { $$ = node('InitExpr', {expr: $1}); }
    ;

init_state
    : STATE COLON id
        { $$ = node('InitialState', {id: $id}); }
    ;

outputs
    : OUTPUTS LBRACE sol RBRACE
        { $$ = $sol; }
    ;

sol
    : so SEMICOLON sol
        { $$ = child($sol, $so); }
    | so SEMICOLON
        { $$ = list($so); }
    ;

so
    : mod_stl COLON outl
        { $$ = node('StateOutput', {states: $mod_stl, outputs: $outl}); }
    ;

transitions
    : TRANSITIONS LBRACE trl RBRACE
        { $$ = $trl; }
    ;

trl
    : tr SEMICOLON trl
        { $$ = child($trl, $tr); }
    | tr SEMICOLON
        { $$ = list($tr); }
    ;

tr
    : stl ARROW st COLON inl
        { $$ = node('Transition', {from: $stl, to: $st, inputs: $inl}); }
    ;

mod_stl
    : BANG stl
        { $$ = option($stl, 'invert', 'true'); }
    | CARET stl
        { $$ = option($stl, 'iff', 'true'); }
    | stl
    ;

stl
    : st COMMA stl
        { $$ = child($stl, $st); }
    | st
        { $$ = list($st); }
    ;

st
    : id
        { $$ = node('State', {id: $id}); }
    ;

outl
    : out COMMA outl
        { $$ = child($outl, $out); }
    | out
        { $$ = list($out); }
    ;

out
    : BANG out
        { $$ = option($out, 'invert', 'true'); }
    | id
        { $$ = node('Output', {id: $id}); }
    ;

inl
    : in COMMA inl
        { $$ = child($inl, $in); }
    | in
        { $$ = list($in); }
    ;

in
    : BANG in
        { $$ = option($in, 'invert', 'true'); }
    | id
        { $$ = node('Input', {id: $id}); }
    ;

id
    : ID
        { $$ = node('Id', {name: yytext}); }
    ;
