local Types = require(script.Parent.Parent.Parent.Types)

local Statement = require(script.Parent.Statement)

local SelectStatement = {}
setmetatable(SelectStatement, Statement)
SelectStatement.__index = SelectStatement

function SelectStatement.new(token: Types.Token, classes: { string }, fromExpressions: { Types.Expression }, whereExpression: Types.Expression?): Types.SelectStatement
    local self: Types.SelectStatement = setmetatable(Statement.new(), SelectStatement)
    self.Token = token
    self.Classes = classes
    self.FromExpressions = fromExpressions
    self.WhereExpression = whereExpression
    return self
end

function SelectStatement.Accept(self: Types.SelectStatement, visitor: Types.Visitor)
    return visitor:VisitSelectStatement(self)
end

return SelectStatement