local UserInputService = game:GetService("UserInputService")

local Types = require(script.Parent.Parent.Types)

local React = require(script.Parent.Parent.Packages.React)

local useMotion = require(script.Parent.Hooks.UseMotion)

local Scanner = require(script.Parent.Parent.Language.Scanner) :: Types.Scanner
local Parser = require(script.Parent.Parent.Language.Parser) :: Types.Parser

return function()
    local isActive, setActive = React.useState(false)

    local commandBarPosition, commandBarPositionMotion = useMotion(0)
    
    local mainFrameRef = React.useRef(nil :: Frame?)
    local commandLineRef = React.useRef(nil :: TextBox?)

    React.useEffect(function()
        if isActive then
            commandBarPositionMotion:spring(1)
        else
            commandBarPositionMotion:spring(0)
        end
    end, {isActive})

    React.useEffect(function()
        commandLineRef.current.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                print(Parser.new(Scanner.new(commandLineRef.current.Text):ScanTokens()):Parse())
            else
                setActive(false)
            end
        end)
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
        end)

        return function()
            con:Disconnect()
        end
    end, {})

	return React.createElement("ScreenGui", {
		Enabled = true,
        DisplayOrder = 100,
	}, {
		Main = React.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
            AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
            Position = commandBarPosition:map(function(value)
                if not mainFrameRef.current then
                    return UDim2.new()
                end
                return UDim2.fromOffset(4,4 * value + mainFrameRef.current.AbsoluteSize.Y * value)
            end),
			Size = UDim2.new(1, -8, 0, 0),
            ref = mainFrameRef,
		}, {
			CommandBar = React.createElement("CanvasGroup", {
				Active = true,
				BackgroundColor3 = Color3.fromRGB(37, 37, 37),
				BorderSizePixel = 0,
				Selectable = true,
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
						Text = "",
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

				uICorner = React.createElement("UICorner"),
			}),

			Buttons = React.createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(27, 42, 53),
                LayoutOrder = 2
			}, {
				SettingsButton = React.createElement("ImageButton", {
					Image = "rbxassetid://1402032193",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(27, 42, 53),
				}),

				GridLayout = React.createElement("UIGridLayout", {
					CellSize = UDim2.fromOffset(25, 25),
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}),

			ListLayout = React.createElement("UIListLayout", {
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}),
	})
end
