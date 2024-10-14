local Types = require(script.Parent.Parent.Types)

local AstPrinter = {}
AstPrinter.__index = AstPrinter

function AstPrinter.new(type: Types.TokenType, lexeme: string, literal: any, line: number): Types.AstPrinter
    local self = setmetatable({} :: Types.AstPrinter, AstPrinter)
    return self
end

function AstPrinter.Print(self: Types.AstPrinter, expression: Types.Expression): string
    return expression:Accept(self)
end

function AstPrinter.VisitBinaryExpression(self: Types.AstPrinter, expression: Types.BinaryExpression): string
    return self:Parenthesize(expression.Operator.Lexeme, expression.Left, expression.Right)
end

function AstPrinter.VisitGroupingExpression(self: Types.AstPrinter, expression: Types.GroupingExpression): string
    return self:Parenthesize("group", expression.Expression)
end

function AstPrinter.VisitLiteralExpression(self: Types.AstPrinter, expression: Types.LiteralExpression): string
    if expression.Value == nil then
        return "nil"
    end
    return tostring(expression.Value)
end

function AstPrinter.VisitUnaryExpression(self: Types.AstPrinter, expression: Types.UnaryExpression): string
    return self:Parenthesize(expression.Operator.Lexeme, expression.Right)
end

function AstPrinter.Parenthesize(self: Types.AstPrinter, name: string, ...: Types.Expression): string
    local builder = {"(", name}
    for _, expression in {...} do
        table.insert(builder, " ")
        table.insert(builder, expression:Accept(self))
    end
    table.insert(builder, ")")
    return table.concat(builder)
end

return AstPrinter