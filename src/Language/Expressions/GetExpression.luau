local Types = require(script.Parent.Parent.Parent.Types)

local Expression = require(script.Parent.Expression)

local GetExpression = {}
setmetatable(GetExpression, Expression)
GetExpression.__index = GetExpression

function GetExpression.new(object: Types.Expression, name: Types.Expression, nameToken: Types.Token): Types.GetExpression
    local self: Types.GetExpression = setmetatable(Expression.new(), GetExpression)
    self.Object = object
    self.Name = name
    self.NameToken = nameToken
    return self
end

function GetExpression.Accept(self: Types.GetExpression, visitor: Types.ExpressionVisitor)
    return visitor:VisitGetExpression(self)
end

return GetExpression