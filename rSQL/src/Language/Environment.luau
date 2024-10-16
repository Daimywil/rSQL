local Types = require(script.Parent.Parent.Types)

local rSQL = require(script.Parent.rSQL)

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

function Environment.Get(self: Types.Environment, name: Types.Token): any
    if self.Values[name.Lexeme] ~= nil then
        return self.Values[name.Lexeme]
    end

    -- error("Undefined variable '" .. name .. "'.")
    rSQL.RuntimeError(name, `Undefined variable '{name.Lexeme}'.`)

    return
end

return Environment