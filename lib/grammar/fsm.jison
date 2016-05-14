%{
    hasProp = {}.hasOwnProperty;

    function child(node, child) {
      list = node[node.children[0]];
      list.splice(0, 0, child);
      return node;
    }

    function option(node, name, value) {
      node[name] = value;
      node.children.push(name);
      return node;
    }

    function node(type, children) {
      var names = [];
      var v;
      obj = { type: type, children: [] };

      for (name in children) {
        if (!hasProp.call(children, name)) continue;
        v = children[name];
        obj.children.push(name);
        obj[name] = v;
      }

      return obj;
    }

%}

/* FSM: lexical grammar */
%lex
%%

"//".*                /* ignore comment */
\s+                   /* skip whitespace */
"transitions"         return 'TRANSITIONS'
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
    : transitions outputs EOF
        { $$ = node('FSM', {transitions: $1, outputs: $2}); return $$; }
    ;

outputs
    : OUTPUTS LBRACE sol RBRACE
        {$$ = $3;}
    ;

sol
    : so SEMICOLON sol
        {$$ = child($3, $1);}
    | so SEMICOLON
        {$$ = node('OutputList', {outputs: [$1]});}
    ;

so
    : mod_stl COLON outl
        {$$ = node('StateOutput', {states: $1, outputs: $3});}
    ;

transitions
    : TRANSITIONS LBRACE trl RBRACE
        {$$ = $3;}
    ;

trl
    : tr SEMICOLON trl
        {$$ = child($3, $1);}
    | tr SEMICOLON
        {$$ = node('TransitionList', {transitions: [$1]});}
    ;

tr
    : stl ARROW st COLON inl
        {$$ = node('Transition', {from: $1, to: $3, inputs: $5});}
    ;

mod_stl
    : BANG stl
        {$$ = option($2, 'invert', 'true');}
    | CARET stl
        {$$ = option($2, 'iff', 'true');}
    | stl
        {$$ = $1;}
    ;

stl
    : st COMMA stl
        {$$ = child($3, $1);}
    | st
        {$$ = node('StateList', {states: [$1]});}
    ;

st
    : id
        {$$ = node('State', {id: $1});}
    ;

outl
    : out COMMA outl
        {$$ = child($3, $1);}
    | out
        {$$ = node('OutputList', {outputs: [$1]});}
    ;

out
    : BANG out
        {$$ = option($2, 'invert', 'true');}
    | id
        {$$ = node('Output', {id: $1});}
    ;

inl
    : in COMMA inl
        {$$ = child($3, $1);}
    | in
        {$$ = node('InputList', {inputs: [$1]});}
    ;

in
    : BANG in
        {$$ = option($2, 'invert', 'true');}
    | id
        {$$ = node('Input', {id: $1});}
    ;

id
    : ID
        {$$ = node('Id', {name: yytext});}
    ;
