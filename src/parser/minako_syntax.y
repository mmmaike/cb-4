%expect 0

%define api.parser.struct {Parser}
%define api.value.type {Value}
%define api.parser.check_debug { self.debug }

%define parse.error custom
%define parse.trace

%code use {
    // all use goes here
    use crate::{Token, C1Lexer as Lexer, Loc, Value};
}

%code parser_fields {
    errors: Vec<String>,
    /// Enables debug printing
    pub debug: bool,
}

%token
    AND           "&&"
    OR            "||"
    EQ            "=="
    NEQ           "!="
    LEQ           "<="
    GEQ           ">="
    LSS           "<"
    GRT           ">"
    KW_BOOLEAN    "bool"
    KW_DO         "do"
    KW_ELSE       "else"
    KW_FLOAT      "float"
    KW_FOR        "for"
    KW_IF         "if"
    KW_INT        "int"
    KW_PRINTF     "printf"
    KW_RETURN     "return"
    KW_VOID       "void"
    KW_WHILE      "while"
    CONST_INT     "integer literal"
    CONST_FLOAT   "float literal"
    CONST_BOOLEAN "boolean literal"
    CONST_STRING  "string literal"
    ID            "identifier"

// definition of association and precedence of operators
%left '+' '-' OR
%left '*' '/' AND
%nonassoc UMINUS

// workaround for handling dangling else
// LOWER_THAN_ELSE stands for a not existing else
%nonassoc LOWER_THAN_ELSE
%nonassoc KW_ELSE

%%

program:
programbody
{
            $$ = Value::None;
}

programbody:
%empty
{
            $$ = Value::None;
}
| programbody declassignment ';'	
{
            $$ = Value::None;
}
| programbody functiondefinition 	
{
            $$ = Value::None;
}

functiondefinition:
type id '(' parameterlist ')' '{' statementlist '}' 
{
            $$ = Value::None;
}
| type id '('')' '{' statementlist '}'
{
            $$ = Value::None;
}

parameterlist:
type id parameterlistrep 
{
            $$ = Value::None;
}

parameterlistrep:
%empty 
{
            $$ = Value::None;
} 
| parameterlistrep ',' type id 
{
            $$ = Value::None;
}

functioncall:
id '(' functioncallopt ')' 
{
            $$ = Value::None;
}

functioncallopt:
%empty
{
            $$ = Value::None;
}
| assignment assignmentrep
{
            $$ = Value::None;
}

assignmentrep:
%empty
{
            $$ = Value::None;
}
| assignmentrep ',' assignment
{
            $$ = Value::None;
}

statementlist:
blockrep 
{
            $$ = Value::None;
}

blockrep:
%empty 
{
            $$ = Value::None;
}
| blockrep block
{
            $$ = Value::None;
}

block:
'{' statementlist '}'
{
            $$ = Value::None;
}
| statement
{
            $$ = Value::None;
}

statement:
ifstatement
{
            $$ = Value::None;
}
| whilestatement
{
            $$ = Value::None;
}
| returnstatement ';'
{
            $$ = Value::None;
}
| dowhilestatement ';'
{
            $$ = Value::None;
}
| printf ';'
{
            $$ = Value::None;
}
| declassignment ';'
{
            $$ = Value::None;
}
| statassignment ';'
{
            $$ = Value::None;
}
| functioncall ';'
{
            $$ = Value::None;
}

statblock:
'{' statementlist '}'
{
            $$ = Value::None;
}
| statement

ifstatement:
KW_IF '(' assignment ')' statblock else
{
            $$ = Value::None;
}

else:
%empty
{
            $$ = Value::None;
}
| KW_ELSE statblock
{
            $$ = Value::None;
}

forstatement:
KW_FOR '(' statassignment ';' expr ';' statassignment ')' statblock
{
            $$ = Value::None;
}
| KW_FOR '(' declassignment ';' expr ';' statassignment ')' statblock
{
            $$ = Value::None;
}

dowhilestatement:
KW_DO statblock KW_WHILE '(' assignment ')'
{
            $$ = Value::None;
}

whilestatement:
KW_WHILE '(' assignment ')' statblock
{
            $$ = Value::None;
}

returnstatement:



%%

impl Parser {
    /// "Sucess" status-code of the parser
    pub const ACCEPTED: i32 = -1;

    /// "Failure" status-code of the parser
    pub const ABORTED: i32 = -2;

    /// Constructor
    pub fn new(lexer: Lexer) -> Self {
        // This statement was added to manually remove a dead code warning for 'owned_value_at' which is auto-generated code
        Self::remove_dead_code_warning();
        Self {
            yy_error_verbose: true,
            yynerrs: 0,
            debug: false,
            yyerrstatus_: 0,
            yylexer: lexer,
            errors: Vec::new(),
        }
    }

    /// Wrapper around generated `parse` method that also
    /// extracts the `errors` field and returns it.
    pub fn do_parse(mut self) -> Vec<String> {
        self.parse();
        self.errors
    }

    /// Retrieve the next token from the lexer
    fn next_token(&mut self) -> Token {
        self.yylexer.yylex()
    }

    /// Print a syntax error and add it to the errors field
    fn report_syntax_error(&mut self, stack: &YYStack, yytoken: &SymbolKind, loc: YYLoc) {
        let token_name = yytoken.name();
        let error = format!("Unexpected token {} at {:?}", token_name, loc);
        eprintln!("Stack: {}\nError: {}", stack, error);
        self.errors.push(error);
    }

    /// Helper function that removes a dead code warning, which would otherwise interfere with the correction of a submitted
    /// solution
    fn remove_dead_code_warning() {
    	let mut stack = YYStack::new();
    	let yystate: i32 = 0;
    	let yylval: YYValue = YYValue::new_uninitialized();
    	let yylloc: YYLoc = YYLoc { begin: 0, end: 0 };
        stack.push(yystate, yylval.clone(), yylloc);
    	let _ = stack.owned_value_at(0);
    }
}

