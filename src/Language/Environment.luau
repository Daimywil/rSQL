local Types = require(script.Parent.Parent.Types)

local Environment = {}
Environment.__index = Environment

function Environment.new(type: Types.TokenType): Types.Environment
    local self = setmetatable({} :: Types.Environment, Environment)
    self.Values = {}
    return self
end

function Environment.Define(self: Types.Environment, name: string, value: any)
    self.Values[name] = value
end

function Environment.Get(self: Types.Environment, name: string): any
    return self.Values[name]
end

return Environment