local Types = require(script.Parent.Parent.Parent.Types)

local Expression = {}
Expression.__index = Expression

function Expression.new()
    local self = setmetatable({} :: Types.Expression, Expression)
    return self
end

function Expression:__tostring()
    return "Expression"
end

return Expression