local UserInputService = game:GetService("UserInputService")

local Types = require(script.Parent.Parent.Types)

local React = require(script.Parent.Parent.Packages.React)

local useMotion = require(script.Parent.Hooks.UseMotion)

local SyntaxHighlight = require(script.Parent.Parent.Language.SyntaxHighlight)

local rSQL = require(script.Parent.Parent.Language.rSQL) :: Types.rSQL

return function()
    local isActive, setActive = React.useState(false)

    local commandBarPosition, commandBarPositionMotion = useMotion(0)
    
    local commandLineRef = React.useRef(nil :: TextBox?)

    local syntaxLabelBinding, setSyntaxLabelBinding = React.useState("")

    React.useEffect(function()
        if isActive then
            commandBarPositionMotion:spring(1, {
                damping = 1,
                frequency = 0.3
            })
        else
            commandBarPositionMotion:spring(0, {
                damping = 1,
                frequency = 0.3
            })
        end
    end, {isActive})

    React.useEffect(function()
        local connections = {
            commandLineRef.current.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    rSQL.Run(commandLineRef.current.Text)
                else
                    setActive(false)
                end
            end),
            commandLineRef.current.Changed:Connect(function()
                setSyntaxLabelBinding(SyntaxHighlight(commandLineRef.current.Text))
            end)
        }

        return function()
            for _, connection in connections do
                connection:Disconnect()
            end
        end
    end, {})

    React.useEffect(function()
        local con = UserInputService.InputBegan:Connect(function(key, gameProcessedEvent)
            if gameProcessedEvent then
                return
            end
            if key.KeyCode ~= Enum.KeyCode.Space then
                return
            end
            if not (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
                return
            end
            setActive(true)
            commandLineRef.current:CaptureFocus()
            -- remove the space character added by pressing the keybind to open
            task.wait()
            local lastCharacter = commandLineRef.current.Text:sub(-1)
            if lastCharacter == " " then
                commandLineRef.current.Text = commandLineRef.current.Text:sub(1, -2)
            end
        end)

        return function()
            con:Disconnect()
        end
    end, {})

    local commandBarHeight = 27

	return React.createElement("ScreenGui", {
		Enabled = true,
        IgnoreGuiInset = true,
        DisplayOrder = 100,
	}, {
		Main = React.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
            AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
            Position = commandBarPosition:map(function(value)
                return UDim2.fromOffset(4,4 * value + commandBarHeight * value)
            end),
			Size = UDim2.new(1, -8, 0, 0),
		}, {
			CommandBar = React.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(37, 37, 37),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 27),
                LayoutOrder = 1,
			}, {
				CommandLine = React.createElement("TextBox", {
					ClearTextOnFocus = false,
					FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
					PlaceholderColor3 = Color3.fromRGB(204, 204, 204),
					PlaceholderText = "Enter a command...",
					Text = "",
					TextColor3 = Color3.fromRGB(204, 204, 204),
					TextSize = 16,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundColor3 = Color3.fromRGB(37, 37, 37),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(27, 42, 53),
					Position = UDim2.fromOffset(5, 0),
					Size = UDim2.new(1, -10, 1, 0),
                    ref = commandLineRef,
				}, {
					SyntaxLabel = React.createElement("TextLabel", {
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
						RichText = true,
						Text = syntaxLabelBinding,
						TextColor3 = Color3.fromRGB(204, 204, 204),
						TextSize = 16,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = Color3.fromRGB(37, 37, 37),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(27, 42, 53),
						Selectable = true,
						Size = UDim2.fromScale(1, 1),
					}),
				}),

				Corner = React.createElement("UICorner"),
			}),

		-- 	Buttons = React.createElement("Frame", {
		-- 		AnchorPoint = Vector2.new(1, 0),
		-- 		AutomaticSize = Enum.AutomaticSize.XY,
		-- 		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		-- 		BackgroundTransparency = 1,
		-- 		BorderColor3 = Color3.fromRGB(27, 42, 53),
        --         LayoutOrder = 2
		-- 	}, {
		-- 		SettingsButton = React.createElement("ImageButton", {
		-- 			Image = "rbxassetid://1402032193",
		-- 			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		-- 			BackgroundTransparency = 1,
		-- 			BorderColor3 = Color3.fromRGB(27, 42, 53),
		-- 		}),

		-- 		GridLayout = React.createElement("UIGridLayout", {
		-- 			CellSize = UDim2.fromOffset(25, 25),
		-- 			HorizontalAlignment = Enum.HorizontalAlignment.Right,
		-- 			SortOrder = Enum.SortOrder.LayoutOrder,
		-- 		}),
		-- 	}),

		-- 	ListLayout = React.createElement("UIListLayout", {
		-- 		Padding = UDim.new(0, 4),
		-- 		SortOrder = Enum.SortOrder.LayoutOrder,
		-- 	}),
		}),
	})
end
