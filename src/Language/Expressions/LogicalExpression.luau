local Types = require(script.Parent.Parent.Parent.Types)

local Expression = require(script.Parent.Expression)

local LogicalExpression = {}
setmetatable(LogicalExpression, Expression)
LogicalExpression.__index = LogicalExpression

function LogicalExpression.new(left: Types.Expression, operator: Types.Token, right: Types.Expression): Types.LogicalExpression
    local self: Types.LogicalExpression = setmetatable(Expression.new(), LogicalExpression)
    self.Left = left
    self.Operator = operator
    self.Right = right
    return self
end

function LogicalExpression.Accept(self: Types.LogicalExpression, visitor: Types.ExpressionVisitor)
    return visitor:VisitLogicalExpression(self)
end

return LogicalExpression