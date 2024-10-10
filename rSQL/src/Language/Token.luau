local Types = require(script.Parent.Parent.Types)

local Token = {}
Token.__index = Token

function Token.new(type: Types.TokenType, lexeme: string, literal: any, line: number): Types.Token
    local self = setmetatable({} :: Types.Token, Token)
    self.Type = type
    self.Lexeme = lexeme
    self.Literal = literal
    self.Line = line
    return self
end

function Token.__tostring(self: Types.Token): string
    return `({self.Type}, {self.Lexeme}, {self.Literal})`
end

return Token