local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local RemoteSpy = game:GetService("LogService")
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

local ESP = {}
ESP.__index = ESP
ESP.espElements = {}

ESP.defaultConfig = {
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),
    BoxThickness = 1,
    BoxTransparency = 0.8,
    BoxFilled = false,
    NameESP = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 16,
    HealthESP = true,
    HealthSize = 14,
    HealthBar = true,
    HealthBarOutline = true,
    RenderDistance = 1000,
    DistanceESP = true,
    DistanceUnit = "Studs",
    HealthDisplayMode = "Percentage",
    ToolESP = true,
    PerformanceStats = true,
    SnapLines = true,
    AimImprover = true
}

local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mouseLocation = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

function ESP.new(player, config)
    if player == LocalPlayer then return end
    local self = setmetatable({}, ESP)
    self.config = setmetatable(config or {}, {__index = ESP.defaultConfig})
    self.player = player
    self:createESP()
    ESP.espElements[player] = self
    return self
end

function ESP:createESP()
    self.boxOutline = Drawing.new("Square")
    self.boxOutline.Color = self.config.BoxOutlineColor
    self.boxOutline.Thickness = self.config.BoxThickness + 2
    self.boxOutline.Transparency = self.config.BoxTransparency
    self.boxOutline.Visible = false
    self.boxOutline.Filled = false

    self.box = Drawing.new("Square")
    self.box.Color = self.config.BoxColor
    self.box.Thickness = self.config.BoxThickness
    self.box.Transparency = self.config.BoxTransparency
    self.box.Visible = false
    self.box.Filled = self.config.BoxFilled

    self.snapLine = Drawing.new("Line")
    self.snapLine.Thickness = 1
    self.snapLine.Color = Color3.fromRGB(255, 255, 255)
    self.snapLine.Visible = false
end

function ESP:update()
    if not self.player or not self.player.Parent or not self.player.Character or not self.player.Character:FindFirstChild("HumanoidRootPart") then self:remove() return end
    local root = self.player.Character.HumanoidRootPart
    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or math.huge
    
    if onScreen and distance <= self.config.RenderDistance then
        self.snapLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 50)
        self.snapLine.To = Vector2.new(screenPos.X, screenPos.Y)
        self.snapLine.Visible = self.config.SnapLines
    else
        self.snapLine.Visible = false
    end
end

function ESP:remove()
    for _, v in pairs(self) do
        if typeof(v) == "userdata" then v:Remove() end
    end
    ESP.espElements[self.player] = nil
end

function ESP.updateAll()
    for _, esp in pairs(ESP.espElements) do
        esp:update()
    end
end

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if ESP.defaultConfig.AimImprover and typeof(args[1]) == "Vector3" then
        local closestPlayer = getClosestPlayerToCursor()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            args[1] = closestPlayer.Character.HumanoidRootPart.Position
        end
    end
    return oldNamecall(self, unpack(args))
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        ESP.new(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESP.espElements[player] then
        ESP.espElements[player]:remove()
    end
end)

RunService.RenderStepped:Connect(function()
    ESP.updateAll()
end)

return ESP
