local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.__index = ESP
ESP.espElements = {}

ESP.defaultConfig = {
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxOutlineColor = Color3.fromRGB(50, 50, 50),
    BoxInnerOutlineColor = Color3.fromRGB(0, 0, 0),
    BoxThickness = 2,
    BoxTransparency = 0.8,
    NameESP = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 18,
    HealthESP = true,
    HealthSize = 16,
    HealthBar = true,
    HealthBarPosition = "Left",
    NamePosition = "Top",
    HealthTextPosition = "Bottom",
    DoubleOutline = true
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
    self.box = Drawing.new("Square")
    self.box.Color = self.config.BoxColor
    self.box.Thickness = self.config.BoxThickness
    self.box.Transparency = self.config.BoxTransparency
    self.box.Visible = false
    self.box.Filled = false

    if self.config.DoubleOutline then
        self.boxOutline = Drawing.new("Square")
        self.boxOutline.Color = self.config.BoxOutlineColor
        self.boxOutline.Thickness = self.config.BoxThickness + 2
        self.boxOutline.Transparency = 1
        self.boxOutline.Visible = false
    end

    if self.config.NameESP then
        self.name = Drawing.new("Text")
        self.name.Color = self.config.NameColor
        self.name.Size = self.config.NameSize
        self.name.Visible = false
    end

    if self.config.HealthESP then
        self.health = Drawing.new("Text")
        self.health.Size = self.config.HealthSize
        self.health.Visible = false
    end

    if self.config.HealthBar then
        self.healthBar = Drawing.new("Square")
        self.healthBar.Filled = true
        self.healthBar.Visible = false
    end
end

function ESP:update()
    if not self.player or not self.player.Parent or not self.player.Character or not self.player.Character:FindFirstChild("HumanoidRootPart") then
        self:remove()
        return
    end
    local root = self.player.Character.HumanoidRootPart
    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    
    if onScreen then
        local boxSize = Vector2.new(120, 200)
        self.box.Position = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2)
        self.box.Size = boxSize
        self.box.Visible = true
        
        if self.config.DoubleOutline then
            self.boxOutline.Position = self.box.Position
            self.boxOutline.Size = self.box.Size
            self.boxOutline.Visible = true
        end

        if self.config.NameESP then
            self.name.Text = self.player.Name
            self.name.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y / 2 - 20)
            self.name.Visible = true
        end

        if self.config.HealthESP then
            local humanoid = self.player.Character:FindFirstChild("Humanoid")
            if humanoid then
                self.health.Text = tostring(math.floor(humanoid.Health)) .. " HP"
                self.health.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2 + 10)
                self.health.Visible = true

                if self.config.HealthBar then
                    local healthRatio = humanoid.Health / humanoid.MaxHealth
                    self.healthBar.Size = Vector2.new(5, boxSize.Y * healthRatio)
                    local barX = self.config.HealthBarPosition == "Left" and screenPos.X - boxSize.X / 2 - 10 or screenPos.X + boxSize.X / 2 + 5
                    self.healthBar.Position = Vector2.new(barX, screenPos.Y - boxSize.Y / 2 + (boxSize.Y * (1 - healthRatio)))
                    self.healthBar.Color = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
                    self.healthBar.Visible = true
                end
            end
        end
    else
        self.box.Visible = false
        if self.boxOutline then self.boxOutline.Visible = false end
        if self.config.NameESP then self.name.Visible = false end
        if self.config.HealthESP then self.health.Visible = false end
        if self.config.HealthBar then self.healthBar.Visible = false end
    end
end

function ESP:remove()
    if self.box then self.box:Remove() end
    if self.boxOutline then self.boxOutline:Remove() end
    if self.name then self.name:Remove() end
    if self.health then self.health:Remove() end
    if self.healthBar then self.healthBar:Remove() end
    ESP.espElements[self.player] = nil
end

function ESP.updateAll()
    for player, esp in pairs(ESP.espElements) do
        esp:update()
    end
end

function ESP.cleanup()
    for player, esp in pairs(ESP.espElements) do
        if not Players:FindFirstChild(player.Name) then
            esp:remove()
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    ESP.new(player)
end)

RunService.RenderStepped:Connect(function()
    ESP.updateAll()
    ESP.cleanup()
end)

return ESP
