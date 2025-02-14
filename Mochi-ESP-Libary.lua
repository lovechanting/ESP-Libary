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
    HealthBarPosition = "Left",
    NamePosition = "Top",
    HealthTextPosition = "Bottom",
    RenderDistance = 1000,
    DistanceESP = true,
    DistanceUnit = "Studs",
    HealthDisplayMode = "Percentage",
    ToolESP = true,
    PerformanceStats = true
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

    self.boxInnerOutline = Drawing.new("Square")
    self.boxInnerOutline.Color = Color3.fromRGB(0, 0, 0)
    self.boxInnerOutline.Thickness = 1
    self.boxInnerOutline.Visible = false

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

    if self.config.HealthESP then
        self.health = Drawing.new("Text")
        self.health.Size = self.config.HealthSize
        self.health.Center = true
        self.health.Visible = false
    end

    if self.config.HealthBar then
        self.healthBar = Drawing.new("Square")
        self.healthBar.Filled = true
        self.healthBar.Visible = false
        self.healthBarOutline = Drawing.new("Square")
        self.healthBarOutline.Filled = false
        self.healthBarOutline.Thickness = 2
        self.healthBarOutline.Visible = false
    end

    if self.config.ToolESP then
        self.tool = Drawing.new("Text")
        self.tool.Color = self.config.NameColor
        self.tool.Size = 14
        self.tool.Center = true
        self.tool.Visible = false
    end

    if self.config.DistanceESP then
        self.distance = Drawing.new("Text")
        self.distance.Color = self.config.NameColor
        self.distance.Size = 14
        self.distance.Center = true
        self.distance.Visible = false
    end
end

function ESP:update()
    if not self.player or not self.player.Parent or not self.player.Character or not self.player.Character:FindFirstChild("HumanoidRootPart") then
        ESP.espElements[self.player] = nil
        return
    end
    local root = self.player.Character.HumanoidRootPart
    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    
    if onScreen and (LocalPlayer:DistanceFromCharacter(root.Position) <= self.config.RenderDistance) then
        local boxSize = Vector2.new(120, 200)
        self.box.Position = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2)
        self.box.Size = boxSize
        self.box.Visible = true

        self.boxOutline.Position = self.box.Position
        self.boxOutline.Size = self.box.Size
        self.boxOutline.Visible = true
        self.boxInnerOutline.Position = self.box.Position + Vector2.new(1, 1)
        self.boxInnerOutline.Size = self.box.Size - Vector2.new(2, 2)
        self.boxInnerOutline.Visible = true
        
        if self.config.NameESP then
            self.name.Text = self.player.DisplayName
            self.name.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y / 2 - 20)
            self.name.Visible = true
        end
    else
        self.box.Visible = false
        self.boxOutline.Visible = false
        self.boxInnerOutline.Visible = false
        if self.config.NameESP then self.name.Visible = false end
    end
end

function ESP:remove()
    if self.box then self.box:Remove() end
    if self.boxOutline then self.boxOutline:Remove() end
    if self.boxInnerOutline then self.boxInnerOutline:Remove() end
    if self.name then self.name:Remove() end
    if self.health then self.health:Remove() end
    if self.healthBar then self.healthBar:Remove() end
    if self.healthBarOutline then self.healthBarOutline:Remove() end
    if self.tool then self.tool:Remove() end
    if self.distance then self.distance:Remove() end
    ESP.espElements[self.player] = nil
end

function ESP.updateAll()
    local toRemove = {}
    for player, esp in pairs(ESP.espElements) do
        if player.Parent then
            esp:update()
        else
            table.insert(toRemove, player)
        end
    end
    for _, player in ipairs(toRemove) do
        ESP.espElements[player]:remove()
    end
end

function ESP.cleanup()
    local toRemove = {}
    for player, esp in pairs(ESP.espElements) do
        if not player.Parent then
            table.insert(toRemove, player)
        end
    end
    for _, player in ipairs(toRemove) do
        ESP.espElements[player]:remove()
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
    ESP.cleanup()
end)

return ESP
