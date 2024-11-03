local Types = require(script.Parent.Parent.Parent.Types)

local Expression = require(script.Parent.Expression)

local LiteralExpression = {}
setmetatable(LiteralExpression, Expression)
LiteralExpression.__index = LiteralExpression

function LiteralExpression.new(value: any)
    local self: Types.LiteralExpression = setmetatable(Expression.new(), LiteralExpression)
    self.Value = value
    return self
end

function LiteralExpression.Accept(self: Types.LiteralExpression, visitor: Types.ExpressionVisitor)
    return visitor:VisitLiteralExpression(self)
end

return LiteralExpression