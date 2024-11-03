local Selection = game:GetService("Selection")

local Types = require(script.Parent.Parent.Types)

local TokenType = require(script.Parent.Parent.Enums.TokenType)
local Environment = require(script.Parent.Environment) :: Types.Environment
local rSQL

local Interpreter = {}
Interpreter.__index = Interpreter

function Interpreter.new(type: Types.TokenType, lexeme: string, literal: any, line: number): Types.Interpreter
    local self = setmetatable({} :: Types.Interpreter, Interpreter)
    self._environment = Environment.new()
    rSQL = rSQL or require(script.Parent.rSQL)
    return self
end

function Interpreter.Interpret(self: Types.Interpreter, statements: { Types.Statement }): ()
    local success, result = pcall(function()
        for _, statement in statements do
            self:_Execute(statement)
        end
    end)

    if not success then
        -- rSQL.RuntimeError({})
    end
end

-- we cannot do game:GetDescendants because it has children that we cannot access (it'll error) and we dont want to select CoreGui either for example
-- so when 'game' is used in a from clause, we'll use these instances instead
local gameInstances = {
    game:GetService("Workspace"),
    game:GetService("Players"),
    game:GetService("Lighting"),
    game:GetService("MaterialService"),
    game:GetService("ReplicatedFirst"),
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("StarterPlayer"),
    game:GetService("Teams"),
    game:GetService("SoundService"),
    game:GetService("TextChatService"),
}

function Interpreter.VisitSelectStatement(self: Types.Interpreter, statement: Types.SelectStatement): ()
    local classes = statement.Classes
    local fromExpressions = statement.FromExpressions
    local whereExpression = statement.WhereExpression

    local fromInstances = {} :: { Instance }
    for _, fromExpression in fromExpressions do
        local instance = self:_Evaluate(fromExpression)
        if typeof(instance) ~= "Instance" then
            self:_Error(fromExpression.Token, "Expected instance from expression.")
        end
        table.insert(fromInstances, instance)
    end

    local queriedInstances = {} :: { Instance }

    for _, instance in fromInstances do
        local allDescendants
        if instance == game then
            allDescendants = {} :: { Instance }
            for _, gameInstance in gameInstances do
                table.insert(allDescendants, gameInstance)
                for _, descendant in gameInstance:GetDescendants() do
                    table.insert(allDescendants, descendant)
                end
            end
        end
        for _, descendant in (allDescendants or instance:GetDescendants()) :: { Instance } do
            if #classes > 0 then
                for _, class in classes do
                    if descendant:IsA(class) then
                        table.insert(queriedInstances, descendant)
                        break
                    end
                end
            else
                table.insert(queriedInstances, descendant)
            end
        end
    end

    if whereExpression then
        local filteredInstances = {} :: { Instance }
        for _, instance in queriedInstances do
            self._environment:Define("self", instance)
            local result = self:_Evaluate(whereExpression)
            if result then
                table.insert(filteredInstances, instance)
            end
        end
        queriedInstances = filteredInstances
        self._environment:Define("self", nil)
    end

    Selection:Set(queriedInstances)
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
        
    elseif expression.Operator.Type == TokenType.SLASH_SLASH then
        self:_CheckNumberOperands(expression.Operator, left, right)
        return (tonumber(left) :: number) // (tonumber(right) :: number)
        
    elseif expression.Operator.Type == TokenType.MODULO then
        self:_CheckNumberOperands(expression.Operator, left, right)
        return (tonumber(left) :: number) % (tonumber(right) :: number)
        
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

function Interpreter.VisitLogicalExpression(self: Types.Interpreter, expression: Types.LogicalExpression)
    local left = self:_Evaluate(expression.Left)
    local right = self:_Evaluate(expression.Right)

    if expression.Operator.Type == TokenType.OR then
        return self:_IsTruthy(left) or self:_IsTruthy(right)
    elseif expression.Operator.Type == TokenType.AND then
        return self:_IsTruthy(left) and self:_IsTruthy(right)
    end

    -- unreachable
    return nil
end

function Interpreter.VisitVariableExpression(self: Types.Interpreter, expression: Types.VariableExpression): any
    if expression.Name.Lexeme == "game" then
        return game
    elseif expression.Name.Lexeme == "workspace" then
        return workspace
    elseif game:FindFirstChild(expression.Name.Lexeme) then
        return game[expression.Name.Lexeme]
    elseif expression.Name.Lexeme == "self" then
        return self._environment:Get("self")
    end

    -- check if self has a property with the name
    if self._environment:Get("self") then
        local selfInstance = self._environment:Get("self")
        local success, propertyValue = pcall(function()
            return selfInstance[expression.Name.Lexeme]
        end)
        if success and typeof(propertyValue) ~= "Instance" and typeof(propertyValue) ~= "function" then
            return propertyValue
        end
    end

    return self._environment:Get(expression.Name.Lexeme)
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

function Interpreter.VisitGetExpression(self: Types.Interpreter, expression: Types.GetExpression): any
    local object = self:_Evaluate(expression.Object) :: Instance
    local name = self:_Evaluate(expression.Name) :: string
    if typeof(object) ~= "Instance" then
        self:_Error(expression.NameToken, "Expected instance.")
    end
    if typeof(name) ~= "string" then
        self:_Error(expression.NameToken, "Expected string as indexer.")
    end

    local success, propertyValue = pcall(function()
        return object[name]
    end)

    if not success then
        self:_Error(expression.NameToken, "Property or child not found.")
    end

    return propertyValue
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

function Interpreter._Execute(self: Types.Interpreter, statement: Types.Statement): ()
    statement:Accept(self)
end

return Interpreter