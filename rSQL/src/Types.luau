export type TokenType = string

export type RuntimeError = {
    Message: string,
    Token: Token,
}

export type rSQL = {
    Run: (source: string) -> nil,

    _Interpreter: Interpreter,

    HadError: boolean,
    HadRuntimeError: boolean,

    Error: (tokenOrLineNumber: Token | number, message: string) -> nil,
    RuntimeError: (err: RuntimeError) -> nil,

    _Report: (line: number, where: string, message: string) -> nil,
}

-- parser

export type Parser = {
    new: (tokens: { Token }) -> Parser,
    _tokens: { Token },
    _current: number,

    Parse: (self: Parser) -> Expression?,

    _Expression: (self: Parser) -> Expression,
    _Equality: (self: Parser) -> Expression,
    _Comparison: (self: Parser) -> Expression,
    _Term: (self: Parser) -> Expression,
    _Factor: (self: Parser) -> Expression,
    _Unary: (self: Parser) -> Expression,
    _Primary: (self: Parser) -> Expression,

    _Statement: (self: Parser) -> Statement,
    _ExpressionStatement: (self: Parser) -> Statement,
    _SelectStatement: (self: Parser) -> Statement,

    _Match: (self: Parser, ...TokenType) -> boolean,
    _Check: (self: Parser, type: TokenType) -> boolean,
    _Advance: (self: Parser) -> Token,
    _IsAtEnd: (self: Parser) -> boolean,
    _Peek: (self: Parser) -> Token,
    _Previous: (self: Parser) -> Token,
    _Consume: (self: Parser, type: TokenType, message: string) -> Token,
    _Error: (self: Parser, token: Token, message: string) -> nil,
    _Synchronize: (self: Parser) -> nil,
}

-- end parser

-- scanner (lexer)

export type Token = {
    new: (type: TokenType, lexeme: string, literal: any, line: number) -> Token,
    Type: TokenType,
    Lexeme: string,
    Literal: any,
    Line: number,

    __tostring: (self: Token) -> string,
}

export type Scanner = {
    new: (source: string) -> Scanner,
    _tokens: { Token },
    _start: number,
    _current: number,
    _line: number,
    
    _IsAtEnd: (self: Scanner) -> boolean,
    _ScanToken: (self: Scanner) -> nil,
    _Advance: (self: Scanner) -> string,
    _Match: (self: Scanner, expected: string) -> boolean,
    _Peek: (self: Scanner) -> string,
    _PeekNext: (self: Scanner) -> string,
    _AddToken: (self: Scanner, type: TokenType, literal: any) -> (),

    _String: (self: Scanner) -> nil,
    _Number: (self: Scanner) -> nil,
    _Identifier: (self: Scanner) -> nil,

    _IsDigit: (self: Scanner, char: string) -> boolean,
    _IsAlpha: (self: Scanner, char: string) -> boolean,
    _IsAlphaNumeric: (self: Scanner, char: string) -> boolean,
    
    Source: string,

    ScanTokens: (self: Scanner) -> { Token },
}

-- end scanner

-- expressions

export type Visitor<T = any> = {
    VisitBinaryExpression: (self: Visitor<T>, expression: BinaryExpression) -> T,
    VisitGroupingExpression: (self: Visitor<T>, expression: GroupingExpression) -> T,
    VisitLiteralExpression: (self: Visitor<T>, expression: LiteralExpression) -> T,
    VisitUnaryExpression: (self: Visitor<T>, expression: UnaryExpression) -> T,
}

export type Expression<T = any> = {
    -- new: () -> Expression<T>, -- actually exists but optionally leave this out for now so that the superclasses constructors properly get their typings

    -- the below should be implemented for each class inheriting from Expression
    -- visitor doesnt use the Visitor type because of recursive type restrictions :(
    Accept: (self: Expression<T>, visitor: any) -> T,

    __tostring: (self: Expression<T>) -> string,
}

export type BinaryExpression = Expression & {
    new: (left: Expression, operator: Token, right: Expression) -> BinaryExpression,
    Left: Expression,
    Operator: Token,
    Right: Expression,
}

export type GroupingExpression = Expression & {
    new: (expression: Expression) -> GroupingExpression,
    Expression: Expression,
}

export type LiteralExpression = Expression & {
    new: (value: any) -> LiteralExpression,
    Value: any,
}

export type UnaryExpression = Expression & {
    new: (operator: Token, right: Expression) -> UnaryExpression,
    Operator: Token,
    Right: Expression,
}

-- statements

export type Statement<T = any> = {
    -- new: () -> Statement, -- actually exists but optionally leave this out for now so that the superclasses constructors properly get their typings

    -- the below should be implemented for each class inheriting from Statement
    Accept: (self: Statement<T>, visitor: any) -> T,

    __tostring: (self: Statement<T>) -> string,
}

export type ExpressionStatement = Statement & {
    new: (expression: Expression) -> ExpressionStatement,
    Expression: Expression
}

-- end statements

-- end expressions

export type AstPrinter = Visitor<string> & {
    new: () -> AstPrinter,
    Print: (self: AstPrinter, expression: Expression) -> string,

    Parenthesize: (self: AstPrinter, name: string, ...Expression) -> string,
}

export type Interpreter = Visitor<any> & { -- any because the interpreter can produce any type of value (strings, numbers etc)
    new: () -> Interpreter,

    Interpret: (self: Interpreter, expression: Expression) -> any,

    _IsTruthy: (self: Interpreter, value: any) -> boolean,
    _IsEqual: (self: Interpreter, a: any, b: any) -> boolean,
    _CheckNumberOperand: (self: Interpreter, operator: Token, operand: any) -> (),
    _CheckNumberOperands: (self: Interpreter, operator: Token, left: any, right: any) -> (),
    _Error: (self: Interpreter, token: Token, message: string) -> (),
    _Evaluate: (self: Interpreter, expression: Expression) -> any,
}

return nil