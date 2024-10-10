local CoreGui = game:GetService("CoreGui")

local React = require(script.Parent.Packages.React)
local ReactRoblox = require(script.Parent.Packages.ReactRoblox)

local App = require(script.Parent.UI.App)

local container = Instance.new("Folder")
container.Name = "rSQL"

local root = ReactRoblox.createRoot(container)

root:render(React.createElement(App))

container.Parent = CoreGui

plugin.Unloading:Connect(function()
    root:unmount()
    container:Destroy()
end)