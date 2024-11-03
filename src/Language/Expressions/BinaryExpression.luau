local Types = require(script.Parent.Parent.Parent.Types)

local Expression = require(script.Parent.Expression)

local BinaryExpression = {}
setmetatable(BinaryExpression, Expression)
BinaryExpression.__index = BinaryExpression

function BinaryExpression.new(left: Types.Expression, operator: Types.Token, right: Types.Expression)
    local self: Types.BinaryExpression = setmetatable(Expression.new(), BinaryExpression)
    self.Left = left
    self.Operator = operator
    self.Right = right
    return self
end

function BinaryExpression.Accept(self: Types.BinaryExpression, visitor: Types.ExpressionVisitor)
    return visitor:VisitBinaryExpression(self)
end

return BinaryExpression