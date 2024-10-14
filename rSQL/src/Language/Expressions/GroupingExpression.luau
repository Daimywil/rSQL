local Types = require(script.Parent.Parent.Parent.Types)

local Expression = require(script.Parent.Expression)

local GroupingExpression = {}
setmetatable(GroupingExpression, Expression)
GroupingExpression.__index = GroupingExpression

function GroupingExpression.new(expression: Types.Expression)
    local self: Types.GroupingExpression = setmetatable(Expression.new(), GroupingExpression)
    self.Expression = expression
    return self
end

function GroupingExpression.Accept(self: Types.GroupingExpression, visitor: Types.Visitor)
    return visitor:VisitGroupingExpression(self)
end

return GroupingExpression