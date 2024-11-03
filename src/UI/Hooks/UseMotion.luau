local RunService = game:GetService("RunService")

local React = require(script.Parent.Parent.Parent.Packages.React)
local Ripple = require(script.Parent.Parent.Parent.Packages.Ripple)

local useEventListener = require(script.Parent.UseEventListener)

return function<T>(initialValue: T)
    local motion = React.useMemo(function()
		return Ripple.createMotion(initialValue, { start = false });
    end, {})

	local binding, setValue = React.useBinding(initialValue);

	useEventListener(RunService.Heartbeat, function(delta: number)
		local newValue = motion:step(delta)

		if newValue ~= binding:getValue() then
			setValue(newValue);
		end
	end)

	React.useEffect(function()
		return function ()
			motion:destroy()
		end
	end, {});

	return binding, motion
end