local Types = require(script.Parent.Parent.Types)

local Token = {}
Token.__index = Token

function Token.new(type: Types.TokenType, lexeme: string, literal: any, column: number): Types.Token
    local self = setmetatable({} :: Types.Token, Token)
    self.Type = type
    self.Lexeme = lexeme
    self.Literal = literal
    self.Column = column
    return self
end

function Token.__tostring(self: Types.Token): string
    return `({self.Type}, {self.Lexeme}, {self.Literal}, {self.Column})`
end

return Token