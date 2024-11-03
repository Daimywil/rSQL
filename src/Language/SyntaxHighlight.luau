local Keywords = {
	["select"] = Color3.fromRGB(4, 56, 255),
	-- ["update"] = Color3.fromRGB(255, 144, 253),
	-- ["delete"] = Color3.fromRGB(253, 79, 89),
	-- ["set"] = Color3.fromRGB(86, 255, 247),
	["from"] = Color3.fromRGB(4, 56, 255),
	["where"] = Color3.fromRGB(4, 56, 255),
	["true"] = Color3.fromRGB(255, 198, 0),
	["false"] = Color3.fromRGB(255, 198, 0),
    ["and"] = Color3.fromRGB(255, 34, 0),
    ["or"] = Color3.fromRGB(255, 34, 0),
    ["not"] = Color3.fromRGB(255, 34, 0),
} :: { [string]: Color3 }

local syntaxPatterns = {}

for keyword: string,color: Color3 in Keywords do
	local syntaxIndex = "(%f[%a]"..keyword.."%f[%A])"
	local syntaxValue = "<font color='rgb("..math.round(color.R * 255)..", "..math.round(color.G * 255)..", "..math.round(color.B * 255)..")'>%1</font>"
	syntaxPatterns[syntaxIndex] = syntaxValue
end

return function(str: string)
	str = str:gsub("[<]","&lt;"):gsub("[>]", "&gt;")
	
    for pattern, repl in pairs(syntaxPatterns) do
		str = str:gsub(pattern, repl)
	end
	
	return str
end