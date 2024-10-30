local Types = require(script.Parent.Parent.Types)

local TokenType = require(script.Parent.Parent.Enums.TokenType)

local BinaryExpression = require(script.Parent.Expressions.BinaryExpression)
local UnaryExpression = require(script.Parent.Expressions.UnaryExpression)
local LiteralExpression = require(script.Parent.Expressions.LiteralExpression)
local GroupingExpression = require(script.Parent.Expressions.GroupingExpression)
local VariableExpression = require(script.Parent.Expressions.VariableExpression)

local SelectStatement = require(script.Parent.Statements.SelectStatement)

local rSQL = require(script.Parent.rSQL) :: Types.rSQL

local Parser = {}
Parser.__index = Parser

function Parser.new(tokens: { Types.Token }): Types.Parser
    local self = setmetatable({} :: Types.Parser, Parser)
    self._tokens = tokens
    print(self._tokens)
    self._current = 1
    return self
end

function Parser.Parse(self: Types.Parser): { Types.Statement } 
    local statements = {} :: { Types.Statement }
    while not self:_IsAtEnd() do
        table.insert(statements, self:_Statement())
    end

    return statements
end

function Parser._Declaration(self: Types.Parser): Types.Statement?
    local success, result = pcall(function()
        if self:_Match(TokenType.SELECT) then
            return self:_SelectStatement()
        end
    
        return self:_Statement()
    end)

    if success then
        return result
    end

    self:_Synchronize()

    return
end

function Parser._Match(self: Types.Parser, ...: Types.TokenType): boolean
    for _, type in {...} do
        if self:_Check(type) then
            self:_Advance()
            return true
        end
    end

    return false
end

function Parser._Check(self: Types.Parser, type: Types.TokenType): boolean
    if self:_IsAtEnd() then
        return false
    end

    return self:_Peek().Type == type
end

function Parser._Advance(self: Types.Parser): Types.Token
    if not self:_IsAtEnd() then
        self._current += 1
    end

    return self:_Previous()
end

function Parser._IsAtEnd(self: Types.Parser): boolean
    return self:_Peek().Type == TokenType.EOF
end

function Parser._Peek(self: Types.Parser): Types.Token
    return self._tokens[self._current]
end

function Parser._PeekNext(self: Types.Parser): Types.Token
    if self:_IsAtEnd() then
        return self:_Peek()
    end

    return self._tokens[self._current + 1]
end

function Parser._Previous(self: Types.Parser): Types.Token
    return self._tokens[self._current - 1]
end

function Parser._Statement(self: Types.Parser): Types.Statement
    if self:_Match(TokenType.SELECT) then
        return self:_SelectStatement()
    end

    self:_Error(self:_Peek(), "Expect statement.")

    return {} :: any
end

function Parser._SelectStatement(self: Types.Parser): Types.Statement
    local classNames = {}
    if self:_Match(TokenType.STAR) then
        -- keep classes table empty to select all classes
    
    else
        classNames = { self:_Consume(TokenType.IDENTIFIER, "Expect class name after 'SELECT'.").Lexeme }
        while self:_Match(TokenType.DOT) do
            table.insert(classNames, self:_Consume(TokenType.IDENTIFIER, "Expect class name after '.'.").Lexeme)
        end
    end

    self:_Consume(TokenType.FROM, "Expect 'FROM' after select clause.")

    local fromExpressions = { self:_Expression() }
    while self:_Match(TokenType.COMMA) do
        table.insert(fromExpressions, self:_Expression())
    end

    local whereExpression: Types.Expression?

    if self:_Match(TokenType.WHERE) then
        whereExpression = self:_Expression()
    end

    return SelectStatement.new(classNames, fromExpressions, whereExpression)
end

function Parser._Expression(self: Types.Parser): Types.Expression
    return self:_LogicalOr()
end

function Parser._LogicalOr(self: Types.Parser): Types.Expression
    local expr = self:_LogicalAnd()

    while self:_Match(TokenType.OR) do
        local operator = self:_Previous()
        local right = self:_LogicalAnd()
        expr = BinaryExpression.new(expr, operator, right)
    end

    return expr
end

function Parser._LogicalAnd(self: Types.Parser): Types.Expression
    local expr = self:_Equality()

    while self:_Match(TokenType.AND) do
        local operator = self:_Previous()
        local right = self:_Equality()
        expr = BinaryExpression.new(expr, operator, right)
    end

    return expr
end

function Parser._Equality(self: Types.Parser): Types.Expression
    local expr = self:_Comparison()

    while self:_Match(TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL) do
        local operator = self:_Previous()
        local right = self:_Comparison()
        expr = BinaryExpression.new(expr, operator, right)
    end

    return expr
end

function Parser._Comparison(self: Types.Parser): Types.Expression
    local expr = self:_Term()

    while self:_Match(TokenType.GREATER, TokenType.GREATER_EQUAL, TokenType.LESS, TokenType.LESS_EQUAL) do
        local operator = self:_Previous()
        local right = self:_Term()
        expr = BinaryExpression.new(expr, operator, right)
    end

    return expr
end

function Parser._Term(self: Types.Parser): Types.Expression
    local expr = self:_Factor()

    while self:_Match(TokenType.MINUS, TokenType.PLUS) do
        local operator = self:_Previous()
        local right = self:_Factor()
        expr = BinaryExpression.new(expr, operator, right)
    end

    return expr
end

function Parser._Factor(self: Types.Parser): Types.Expression
    local expr = self:_Unary()

    while self:_Match(TokenType.SLASH, TokenType.STAR) do
        local operator = self:_Previous()
        local right = self:_Unary()
        expr = BinaryExpression.new(expr, operator, right)
    end

    return expr
end

function Parser._Unary(self: Types.Parser): Types.Expression
    if self:_Match(TokenType.NOT, TokenType.MINUS) then
        local operator = self:_Previous()
        local right = self:_Unary()
        return UnaryExpression.new(operator, right)
    end

    return self:_Primary()
end

function Parser._Primary(self: Types.Parser): Types.Expression?
    if self:_Match(TokenType.FALSE) then
        return LiteralExpression.new(false)
    end

    if self:_Match(TokenType.TRUE) then
        return LiteralExpression.new(true)
    end

    if self:_Match(TokenType.NIL) then
        return LiteralExpression.new(nil)
    end

    if self:_Match(TokenType.NUMBER, TokenType.STRING) then
        return LiteralExpression.new(self:_Previous().Literal)
    end

    if self:_Match(TokenType.LEFT_PAREN) then
        local expr = self:_Expression()
        self:_Consume(TokenType.RIGHT_PAREN, "Expect ')' after expression.")        
        return GroupingExpression.new(expr)
    end

    if self:_Match(TokenType.IDENTIFIER) then
        return VariableExpression.new(self:_Previous())
    end

    self:_Error(self:_Peek(), "Expect expression.")

    return
end

function Parser._Consume(self: Types.Parser, type: Types.TokenType, message: string): Types.Token?
    if self:_Check(type) then
        return self:_Advance()
    end

    self:_Error(self:_Peek(), message)

    return
end

function Parser._Synchronize(self: Types.Parser): ()
    self:_Advance()

    while not self:_IsAtEnd() do
        if self:_Previous().Type == TokenType.SEMICOLON then
            return
        end

        local token = self:_Peek()
        if table.find({
            TokenType.SELECT,
            TokenType.UPDATE,
            TokenType.DELETE,
            TokenType.INSERT,
            TokenType.FROM,
            TokenType.WHERE,
            TokenType.SET,
            TokenType.INTO,
            TokenType.VALUES,
        }, token.Type) then
            return
        end

        self:_Advance()
    end
end

function Parser._Error(self: Types.Parser, token: Types.Token, message: string): ()
    rSQL.Error(token.Line, message)
    error(`[line {token.Line}] Error: {message}`)
end

return Parser