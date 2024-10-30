local Types = require(script.Parent.Parent.Parent.Types)

local Expression = require(script.Parent.Expression)

local VariableExpression = {}
setmetatable(VariableExpression, Expression)
VariableExpression.__index = VariableExpression

function VariableExpression.new(name: Types.Token)
    local self: Types.VariableExpression = setmetatable(Expression.new(), VariableExpression)
    self.Name = name
    return self
end

function VariableExpression.Accept(self: Types.VariableExpression, visitor: Types.ExpressionVisitor)
    return visitor:VisitVariableExpression(self)
end

return VariableExpression