local Types = require(script.Parent.Parent.Types)

local TokenType = require(script.Parent.Parent.Enums.TokenType)

local rSQL = {} :: Types.rSQL

rSQL.HadError = false
rSQL.HadRuntimeError = false

function rSQL.Run(source: string)
    rSQL.HadError = false
    rSQL.HadRuntimeError = false

    local Interpreter = require(script.Parent.Interpreter :: any) :: Types.Interpreter -- circular dependency
    local Scanner = require(script.Parent.Scanner)
    local Parser = require(script.Parent.Parser)

    local interpreter = Interpreter.new()
    local scanner = Scanner.new(source)

    if rSQL.HadError then
        warn("[rSQL] Lexer error. Please check your syntax.")
        return
    end

    local tokens = scanner:ScanTokens()
    local parser = Parser.new(tokens)
    local statements = parser:Parse()

    if rSQL.HadError then
        warn("[rSQL] Parsing error. Please check your syntax.")
        return
    end

    interpreter:Interpret(statements)

    if rSQL.HadRuntimeError then
        warn("[rSQL] Runtime error.")
        return
    end

    print("[rSQL] Execution completed successfully.")
end

function rSQL.Error(tokenOrLineNumber: Types.Token | number, message: string)
    if typeof(tokenOrLineNumber) == "number" then
        rSQL._Report(tokenOrLineNumber, "", message)
        return
    end

    if tokenOrLineNumber.Type == TokenType.EOF then
        rSQL._Report(tokenOrLineNumber.Column, "at end", message)
    else
        rSQL._Report(tokenOrLineNumber.Column, `at '{tokenOrLineNumber.Lexeme}'`, message)
    end
end

function rSQL.RuntimeError(err: Types.RuntimeError)
    warn(`[rSQL] {err.Message}\n[column {err.Token.Column}]`)
    rSQL.HadRuntimeError = true
end

function rSQL._Report(line: number, where: string, message: string)
    warn(`[rSQL] Error at line {line} {where}: {message}`)
    rSQL.HadError = true
end

return rSQL