local Types = require(script.Parent.Parent.Parent.Types)

local Expression = require(script.Parent.Expression)

local SpecialExpression = {}
setmetatable(SpecialExpression, Expression)
SpecialExpression.__index = SpecialExpression

function SpecialExpression.new(name: Types.Token)
    local self: Types.SpecialExpression = setmetatable(Expression.new(), SpecialExpression)
    self.Name = name
    return self
end

function SpecialExpression.Accept(self: Types.SpecialExpression, visitor: Types.ExpressionVisitor)
    return visitor:VisitSpecialExpression(self)
end

return SpecialExpression