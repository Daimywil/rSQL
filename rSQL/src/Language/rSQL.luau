local Types = require(script.Parent.Parent.Types)

local TokenType = require(script.Parent.Parent.Enums.TokenType) :: Types.TokenTypeEnum

local rSQL = {} :: Types.rSQL

rSQL.HadError = false

function rSQL.Error(tokenOrLineNumber: Types.Token | number, message: string)
    if typeof(tokenOrLineNumber) == "number" then
        rSQL._Report(tokenOrLineNumber, "", message)
        return        
    end
    
    if tokenOrLineNumber.Type == TokenType.EOF then
        rSQL._Report(tokenOrLineNumber.Line, "at end", message)
    else
        rSQL._Report(tokenOrLineNumber.Line, `at '{tokenOrLineNumber.Lexeme}'`, message)
    end
end

function rSQL._Report(line: number, where: string, message: string)
    warn(`[rSQL] Error at line {line} {where}: {message}`)
    rSQL.HadError = true
end

return rSQL