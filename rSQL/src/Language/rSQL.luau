local rSQL = {}

function rSQL.Error(line: number, message: string)
    warn(`[rSQL] Error at line {line}: {message}`)
    -- set _hadError to true to prevent execution of the code
end

return rSQL