local Types = require(script.Parent.Parent.Types)

local TokenType = require(script.Parent.Parent.Enums.TokenType)
local rSQL

local Interpreter = {}
Interpreter.__index = Interpreter

function Interpreter.new(type: Types.TokenType, lexeme: string, literal: any, line: number): Types.Interpreter
    local self = setmetatable({} :: Types.Interpreter, Interpreter)
    rSQL = rSQL or require(script.Parent.rSQL)
    return self
end

function Interpreter.Interpret(self: Types.Interpreter, expression: Types.Expression)
    local success, result = pcall(self._Evaluate, self, expression)
    if success then
        print(tostring(result))
    else
        rSQL.RuntimeError(result)
    end
end

function Interpreter.VisitBinaryExpression(self: Types.Interpreter, expression: Types.BinaryExpression): any
    local left = self:_Evaluate(expression.Left)
    local right = self:_Evaluate(expression.Right)

    if expression.Operator.Type == TokenType.PLUS then
        self:_CheckNumberOperands(expression.Operator, left, right)
        return (tonumber(left) :: number) + (tonumber(right) :: number)
    elseif expression.Operator.Type == TokenType.MINUS then
        self:_CheckNumberOperands(expression.Operator, left, right)
        return (tonumber(left) :: number) - (tonumber(right) :: number)
    elseif expression.Operator.Type == TokenType.STAR then
        self:_CheckNumberOperands(expression.Operator, left, right)
        return (tonumber(left) :: number) * (tonumber(right) :: number)
    elseif expression.Operator.Type == TokenType.SLASH then
        self:_CheckNumberOperands(expression.Operator, left, right)
        return (tonumber(left) :: number) / (tonumber(right) :: number)
    elseif expression.Operator.Type == TokenType.GREATER then
        self:_CheckNumberOperands(expression.Operator, left, right)
        return (tonumber(left) :: number) > (tonumber(right) :: number)
    elseif expression.Operator.Type == TokenType.GREATER_EQUAL then
        self:_CheckNumberOperands(expression.Operator, left, right)
        return (tonumber(left) :: number) >= (tonumber(right) :: number)
    elseif expression.Operator.Type == TokenType.LESS then
        self:_CheckNumberOperands(expression.Operator, left, right)
        return (tonumber(left) :: number) < (tonumber(right) :: number)
    elseif expression.Operator.Type == TokenType.LESS_EQUAL then
        self:_CheckNumberOperands(expression.Operator, left, right)
        return (tonumber(left) :: number) <= (tonumber(right) :: number)
    elseif expression.Operator.Type == TokenType.EQUAL_EQUAL then
        return self:_IsEqual(left, right)
    elseif expression.Operator.Type == TokenType.BANG_EQUAL then
        return not self:_IsEqual(left, right)
    elseif expression.Operator.Type == TokenType.CONCAT then
        return tostring(left) .. tostring(right)
    end

    -- unreachable
    return nil
end

function Interpreter.VisitGroupingExpression(self: Types.Interpreter, expression: Types.GroupingExpression): any
    return self:_Evaluate(expression.Expression)
end

function Interpreter.VisitLiteralExpression(self: Types.Interpreter, expression: Types.LiteralExpression): any
    return expression.Value
end

function Interpreter.VisitUnaryExpression(self: Types.Interpreter, expression: Types.UnaryExpression): any
    local right = self:_Evaluate(expression.Right)

    if expression.Operator.Type == TokenType.MINUS then
        self:_CheckNumberOperand(expression.Operator, right)
        return -(tonumber(right) :: number)
    elseif expression.Operator.Type == TokenType.NOT then
        return not self:_IsTruthy(right)
    end

    -- unreachable
    return nil
end

function Interpreter._IsEqual(self: Types.Interpreter, a: any, b: any): boolean
    return a == b
end

function Interpreter._CheckNumberOperand(self: Types.Interpreter, operator: Types.Token, operand: any)
    if type(operand) == "number" then
        return
    end

    self:_Error(operator, "Operand must be a number.")
end

function Interpreter._CheckNumberOperands(self: Types.Interpreter, operator: Types.Token, left: any, right: any)
    if type(left) == "number" and type(right) == "number" then
        return
    end

    self:_Error(operator, "Operands must be numbers.")
end

function Interpreter._IsTruthy(self: Types.Interpreter, value: any): boolean
    if value == nil then
        return false
    end

    if type(value) == "boolean" then
        return value
    end

    return true
end

function Interpreter._Error(self: Types.Interpreter, token: Types.Token, message: string): nil
    error({
        Token = token,
        Message = message,
    } :: Types.RuntimeError)
end

function Interpreter._Evaluate(self: Types.Interpreter, expression: Types.Expression): any
    return expression:Accept(self)
end

return Interpreter