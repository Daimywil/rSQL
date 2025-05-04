local Types = require(script.Parent.Parent.Types)

local Token = require(script.Parent.Token) :: Types.Token
local TokenType = require(script.Parent.Parent.Enums.TokenType)
local rSQL = require(script.Parent.rSQL) :: Types.rSQL

local Scanner = {}
Scanner.__index = Scanner

function Scanner.new(source: string): Types.Scanner
    local self = setmetatable({} :: Types.Scanner, Scanner)
    self.Source = source
    self._tokens = {}
    self._start = 1
    self._current = 1
    return self
end

function Scanner.ScanTokens(self: Types.Scanner): { Types.Token }
    while not self:_IsAtEnd() do
        self._start = self._current
        self:_ScanToken()
    end

    table.insert(self._tokens, Token.new(TokenType.EOF, "", nil, self._current))
    return self._tokens
end

function Scanner._ScanToken(self: Types.Scanner)
    local char = self:_Advance()
    if char == "(" then
        self:_AddToken(TokenType.LEFT_PAREN)
    elseif char == ")" then
        self:_AddToken(TokenType.RIGHT_PAREN)
    elseif char == "[" then
        self:_AddToken(TokenType.LEFT_BRACKET)
    elseif char == "]" then
        self:_AddToken(TokenType.RIGHT_BRACKET)
    elseif char == "," then
        self:_AddToken(TokenType.COMMA)
    elseif char == "." then
        self:_AddToken(self:_Match(".") and TokenType.CONCAT or TokenType.DOT)
    elseif char == "-" then
        self:_AddToken(TokenType.MINUS)
    elseif char == "+" then
        self:_AddToken(TokenType.PLUS)
    elseif char == "%" then
        self:_AddToken(TokenType.MODULO)
    elseif char == "/" then
        if self:_Match("/") then
            self:_AddToken(TokenType.SLASH_SLASH)
        else
            self:_AddToken(TokenType.SLASH)
        end
    elseif char == ";" then
        self:_AddToken(TokenType.SEMICOLON)
    elseif char == "*" then
        self:_AddToken(TokenType.STAR)
    elseif char == "=" then
        if self:_Match("=") then
            self:_AddToken(TokenType.EQUAL_EQUAL)
        else
            self:_AddToken(TokenType.EQUAL)
        end
    elseif char == "~" then
        if self:_Match("=") then
            self:_AddToken(TokenType.BANG_EQUAL)
        else
            rSQL.Error(self._current, "Unexpected character.")
        end
    elseif char == ">" then
        if self:_Match("=") then
            self:_AddToken(TokenType.GREATER_EQUAL)
        else
            self:_AddToken(TokenType.GREATER)
        end
    elseif char == "<" then
        if self:_Match("=") then
            self:_AddToken(TokenType.LESS_EQUAL)
        else
            self:_AddToken(TokenType.LESS)
        end
    elseif char == '"' then
        self:_String()
    elseif char == " " then
        -- ignore whitespace
    elseif char == "\r" then
        -- ignore carriage return (moves cursor to the beginning of the line)
    elseif char == "\t" then
        -- ignore tab
    elseif char == "\n" then
        -- ignore new line
    elseif char == "$" then
        self:_Special()
    elseif self:_IsDigit(char) then
        self:_Number()
    elseif self:_IsAlpha(char) then
        self:_Identifier()
    else
        rSQL.Error(self._current, "Unexpected character.")
    end
end

function Scanner._String(self: Types.Scanner)
    while self:_Peek() ~= '"' and not self:_IsAtEnd() do
        self:_Advance()
    end

    if self:_IsAtEnd() then
        rSQL.Error(self._current, "Unterminated string.")
        return
    end

    -- consume the closing "
    self:_Advance()

    -- trim the surrounding quotes
    local value = string.sub(self.Source, self._start + 1, self._current - 2)
    self:_AddToken(TokenType.STRING, value)
end

function Scanner._IsDigit(self: Types.Scanner, char: string): boolean
    return tonumber(char) ~= nil
end

function Scanner._IsAlpha(self: Types.Scanner, char: string): boolean
    return char:match("%a") ~= nil or char == "_"
end

function Scanner._IsAlphaNumeric(self: Types.Scanner, char: string): boolean
    return self:_IsAlpha(char) or self:_IsDigit(char)
end

function Scanner._Number(self: Types.Scanner)
    while self:_IsDigit(self:_Peek()) do
        self:_Advance()
    end

    -- look for a fractional part
    if self:_Peek() == "." and self:_IsDigit(self:_PeekNext()) then
        -- consume the "."
        self:_Advance()

        while self:_IsDigit(self:_Peek()) do
            self:_Advance()
        end
    end

    self:_AddToken(TokenType.NUMBER, tonumber(string.sub(self.Source, self._start, self._current - 1)))
end

function Scanner._Special(self: Types.Scanner)
    while self:_IsAlpha(self:_Peek()) do
        self:_Advance()
    end

    local text = string.sub(self.Source, self._start + 1, self._current - 1)
    if text:lower() == "selected" then
        self:_AddToken(TokenType.SPECIAL_SELECTED)
    else
        rSQL.Error(self._current, `Unexpected special token: ${text}`)
    end
end

function Scanner._Identifier(self: Types.Scanner)
    while self:_IsAlphaNumeric(self:_Peek()) do
        self:_Advance()
    end

    local keywords = {
        ["and"] = TokenType.AND,
        ["or"] = TokenType.OR,
        ["nil"] = TokenType.NIL,
        ["false"] = TokenType.FALSE,
        ["true"] = TokenType.TRUE,
        ["select"] = TokenType.SELECT,
        ["update"] = TokenType.UPDATE,
        ["delete"] = TokenType.DELETE,
        ["insert"] = TokenType.INSERT,
        ["from"] = TokenType.FROM,
        ["where"] = TokenType.WHERE,
        ["set"] = TokenType.SET,
        ["into"] = TokenType.INTO,
        ["values"] = TokenType.VALUES,
        ["not"] = TokenType.NOT,
    }

    local text = string.sub(self.Source, self._start, self._current - 1)
    local tokenType = keywords[text:lower()] or TokenType.IDENTIFIER
    self:_AddToken(tokenType)
end

function Scanner._Peek(self: Types.Scanner): string
    if self:_IsAtEnd() then
        return "\0"
    end
    return string.sub(self.Source, self._current, self._current)
end

function Scanner._PeekNext(self: Types.Scanner): string
    if self._current + 1 > #self.Source then
        return "\0"
    end
    return string.sub(self.Source, self._current + 1, self._current + 1)
end

function Scanner._Advance(self: Types.Scanner): string
    self._current += 1
    return string.sub(self.Source, self._current - 1, self._current - 1)
end

function Scanner._Match(self: Types.Scanner, expected: string): boolean
    if self:_IsAtEnd() then
        return false
    end
    if string.sub(self.Source, self._current, self._current) ~= expected then
        return false
    end

    -- consume the character
    self._current += 1
    return true
end

function Scanner._AddToken(self: Types.Scanner, type: Types.TokenType, literal: any)
    local text = string.sub(self.Source, self._start, self._current - 1)
    table.insert(self._tokens, Token.new(type, text, literal, self._start))
end

function Scanner._IsAtEnd(self: Types.Scanner): boolean
    return self._current > #self.Source
end

return Scanner