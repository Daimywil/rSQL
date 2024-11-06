local Types = require(script.Parent.Parent.Parent.Types)

local Statement = require(script.Parent.Statement)

local UpdateStatement = {}
setmetatable(UpdateStatement, Statement)
UpdateStatement.__index = UpdateStatement

function UpdateStatement.new(classes: { string }, fromExpressions: { Types.Expression }, whereExpression: Types.Expression?): Types.UpdateStatement
    local self: Types.UpdateStatement = setmetatable(Statement.new(), UpdateStatement)
    self.Classes = classes
    self.FromExpressions = fromExpressions
    self.WhereExpression = whereExpression
    return self
end

function UpdateStatement.Accept(self: Types.UpdateStatement, visitor: Types.Visitor)
    return visitor:VisitSelectStatement(self)
end

return UpdateStatement