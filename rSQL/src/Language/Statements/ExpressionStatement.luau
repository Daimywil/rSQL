local Types = require(script.Parent.Parent.Parent.Types)

local Statement = require(script.Parent.Statement)

local ExpressionStatement = {}
setmetatable(ExpressionStatement, Statement)
ExpressionStatement.__index = ExpressionStatement

function ExpressionStatement.new(expression: Types.Expression)
    local self: Types.ExpressionStatement = setmetatable(Statement.new(), ExpressionStatement)
    self.Expression = expression
    return self
end

function ExpressionStatement.Accept(self: Types.ExpressionStatement, visitor: Types.Visitor)
    return visitor:VisitExpressionStatement(self)
end

return ExpressionStatement