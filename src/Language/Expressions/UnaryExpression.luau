local Types = require(script.Parent.Parent.Parent.Types)

local Expression = require(script.Parent.Expression)

local UnaryExpression = {}
setmetatable(UnaryExpression, Expression)
UnaryExpression.__index = UnaryExpression

function UnaryExpression.new(operator: Types.Token, right: Types.Expression)
    local self: Types.UnaryExpression = setmetatable(Expression.new(), UnaryExpression)
    self.Operator = operator
    self.Right = right
    return self
end

function UnaryExpression.Accept(self: Types.UnaryExpression, visitor: Types.ExpressionVisitor)
    return visitor:VisitUnaryExpression(self)
end

return UnaryExpression