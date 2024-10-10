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
		-- because i made the mistake of connecting 2 heartbeats and stepping the motion twice, all the spring motions got messed up because they're now 50% the speed
		-- so we're just going to speed up the spring by 2
		-- springs are just twice as fast but it shouldnt have any other impact (i hope)
		local newValue = motion:step(delta * 2)

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