if true then
    return
end

local Types = require(script.Parent.Parent.Types)

local AstPrinter = require(script.Parent.AstPrinter) :: Types.AstPrinter

local BinaryExpression = require(script.Parent.Expressions.BinaryExpression) :: Types.BinaryExpression
local GroupingExpression = require(script.Parent.Expressions.GroupingExpression) :: Types.GroupingExpression
local LiteralExpression = require(script.Parent.Expressions.LiteralExpression) :: Types.LiteralExpression
local UnaryExpression = require(script.Parent.Expressions.UnaryExpression) :: Types.UnaryExpression

local Token = require(script.Parent.Token) :: Types.Token
local TokenType = require(script.Parent.Parent.Enums.TokenType) :: Types.TokenTypeEnum

local expression: Types.Expression = BinaryExpression.new(
    UnaryExpression.new(
        Token.new(TokenType.MINUS, "-", nil, 1),
        LiteralExpression.new(123)
    ),
    Token.new(TokenType.STAR, "*", nil, 1),
    GroupingExpression.new(
        LiteralExpression.new(45.67)
    )
)

print(AstPrinter.new():Print(expression))