local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.__index = ESP
ESP.espElements = {}

ESP.defaultConfig = {
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),
    BoxThickness = 1,
    BoxTransparency = 0.8,
    NameESP = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 16,
    HealthESP = true,
    HealthSize = 14,
    HealthBar = true,
    HealthBarOutline = true,
    RenderDistance = 1000,
    DistanceESP = true,
    HealthDisplayMode = "Percentage",
    ToolESP = true
}

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
    self.box.Filled = false

    if self.config.NameESP then
        self.name = Drawing.new("Text")
        self.name.Color = self.config.NameColor
        self.name.Size = self.config.NameSize
        self.name.Center = true
        self.name.Visible = false
    end
end

function ESP:update()
    if not self.player or not self.player.Parent or not self.player.Character then self:remove() return end
    local root = self.player.Character:FindFirstChild("HumanoidRootPart")
    if not root then self:remove() return end
    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or math.huge
    if onScreen and distance <= self.config.RenderDistance then
        local boxSize = Vector2.new(120, 200)
        self.box.Position = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2)
        self.box.Size = boxSize
        self.box.Visible = true

        self.boxOutline.Position = self.box.Position
        self.boxOutline.Size = self.box.Size
        self.boxOutline.Visible = true
        
        if self.config.NameESP then
            self.name.Text = self.player.DisplayName
            self.name.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y / 2 - 20)
            self.name.Visible = true
        end
    else
        self.box.Visible = false
        self.boxOutline.Visible = false
        if self.config.NameESP then self.name.Visible = false end
    end
end

function ESP:remove()
    if self.box then self.box:Remove() end
    if self.boxOutline then self.boxOutline:Remove() end
    if self.name then self.name:Remove() end
    ESP.espElements[self.player] = nil
end

function ESP.updateAll()
    for _, esp in pairs(ESP.espElements) do
        esp:update()
    end
end

Players.PlayerAdded:Connect(function(player)
    ESP.new(player)
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
