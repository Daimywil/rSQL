local React = require(script.Parent.Parent.Parent.Packages.React)

return function<T>(event: RBXScriptSignal<...T>, callback: (...T) -> nil)
    React.useEffect(function()
        local connection = event:Connect(callback)
        return function()
            connection:Disconnect()
        end
    end, {event, callback})

    return nil
end