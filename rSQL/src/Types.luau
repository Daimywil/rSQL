export type TokenType = string

export type TokenTypeEnum = typeof(require(script.Parent.Enums.TokenType))

export type rSQL = {
    Error: (line: number, message: string) -> nil,
}

-- scanner

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
    new: () -> Expression<T>, -- actually exists but optionally leave this out for now so that the superclasses constructors properly get their typings

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

-- end expressions

export type AstPrinter = Visitor<string> & {
    new: () -> AstPrinter,
    Print: (self: AstPrinter, expression: Expression) -> string,

    Parenthesize: (self: AstPrinter, name: string, ...Expression) -> string,
}

return nil