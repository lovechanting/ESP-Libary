local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local RemoteSpy = game:GetService("LogService")

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

    if self.config.NameESP then
        self.name = Drawing.new("Text")
        self.name.Color = self.config.NameColor
        self.name.Size = self.config.NameSize
        self.name.Center = true
        self.name.Visible = false
    end
    
    if self.config.DistanceESP then
        self.distance = Drawing.new("Text")
        self.distance.Color = self.config.NameColor
        self.distance.Size = 14
        self.distance.Center = true
        self.distance.Visible = false
    end
    
    if self.config.ToolESP then
        self.tool = Drawing.new("Text")
        self.tool.Color = self.config.NameColor
        self.tool.Size = 14
        self.tool.Center = true
        self.tool.Visible = false
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
end

function ESP:update()
    if not self.player or not self.player.Parent or not self.player.Character or not self.player.Character:FindFirstChild("HumanoidRootPart") then self:remove() return end
    local root = self.player.Character.HumanoidRootPart
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

        if self.config.SnapLines then
            self.snapLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 50)
            self.snapLine.To = Vector2.new(screenPos.X, screenPos.Y)
            self.snapLine.Visible = true
        end
        
        if self.config.NameESP then
            self.name.Text = self.player.DisplayName
            self.name.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y / 2 - 20)
            self.name.Visible = true
        end
        
        if self.config.DistanceESP then
            self.distance.Text = string.format("%.1f %s", distance, self.config.DistanceUnit)
            self.distance.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2 + 5)
            self.distance.Visible = true
        end
        
        if self.config.ToolESP and self.player.Character:FindFirstChildOfClass("Tool") then
            self.tool.Text = self.player.Character:FindFirstChildOfClass("Tool").Name
            self.tool.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2 + 20)
            self.tool.Visible = true
        else
            self.tool.Visible = false
        end
    else
        self.box.Visible = false
        self.boxOutline.Visible = false
        self.snapLine.Visible = false
        self.name.Visible = false
        self.distance.Visible = false
        self.tool.Visible = false
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
