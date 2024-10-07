export type TokenType = string

export type TokenTypeEnum = typeof(require(script.Parent.Enums.TokenType))

export type rSQL = {
    Error: (line: number, message: string) -> nil,
}

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

    _IsDigit: (self: Scanner, char: string) -> boolean,
    _IsAlpha: (self: Scanner, char: string) -> boolean,
    
    Source: string,

    ScanTokens: (self: Scanner) -> { Token },
}

return nil