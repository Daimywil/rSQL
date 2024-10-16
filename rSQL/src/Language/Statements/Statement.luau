local Types = require(script.Parent.Parent.Parent.Types)

local Statement = {}
Statement.__index = Statement

function Statement.new()
    local self = setmetatable({} :: Types.Statement, Statement)
    return self
end

function Statement:__tostring()
    return "Statement"
end

return Statement