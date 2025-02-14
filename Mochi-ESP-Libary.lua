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
        if self.config.HealthBarOutline then
            self.healthBarOutline = Drawing.new("Square")
            self.healthBarOutline.Filled = false
            self.healthBarOutline.Thickness = 2
            self.healthBarOutline.Visible = false
        end
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
        self:remove()
        return
    end
    local root = self.player.Character.HumanoidRootPart
    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    
    if onScreen and (LocalPlayer:DistanceFromCharacter(root.Position) <= self.config.RenderDistance) then
        local boxSize = Vector2.new(120, 200)
        self.box.Position = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2)
        self.box.Size = boxSize
        self.box.Visible = true
        
        if self.config.NameESP then
            self.name.Text = self.player.DisplayName
            self.name.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y / 2 - 20)
            self.name.Visible = true
        end

        if self.config.HealthESP then
            local humanoid = self.player.Character:FindFirstChild("Humanoid")
            if humanoid then
                local healthText = ""
                if self.config.HealthDisplayMode == "Percentage" then
                    healthText = tostring(math.floor((humanoid.Health / humanoid.MaxHealth) * 100)) .. "%"
                elseif self.config.HealthDisplayMode == "Health" then
                    healthText = tostring(math.floor(humanoid.Health))
                else
                    healthText = tostring(math.floor(humanoid.Health)) .. "/" .. tostring(math.floor(humanoid.MaxHealth))
                end
                self.health.Text = healthText
                self.health.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2 + 10)
                self.health.Visible = true
                
                if self.config.HealthBar then
                    local healthRatio = humanoid.Health / humanoid.MaxHealth
                    self.healthBar.Size = Vector2.new(5, boxSize.Y * healthRatio)
                    local barX = self.config.HealthBarPosition == "Left" and screenPos.X - boxSize.X / 2 - 10 or screenPos.X + boxSize.X / 2 + 5
                    self.healthBar.Position = Vector2.new(barX, screenPos.Y - boxSize.Y / 2 + (boxSize.Y * (1 - healthRatio)))
                    self.healthBar.Color = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
                    self.healthBar.Visible = true
                    if self.config.HealthBarOutline then
                        self.healthBarOutline.Size = Vector2.new(7, boxSize.Y)
                        self.healthBarOutline.Position = Vector2.new(barX - 1, screenPos.Y - boxSize.Y / 2)
                        self.healthBarOutline.Color = Color3.fromRGB(0, 0, 0)
                        self.healthBarOutline.Visible = true
                    end
                end
            end
        end

        if self.config.ToolESP then
            local tool = self.player.Character:FindFirstChildOfClass("Tool")
            if tool then
                self.tool.Text = tool.Name
                self.tool.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2 + 25)
                self.tool.Visible = true
            else
                self.tool.Visible = false
            end
        end

        if self.config.DistanceESP then
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
            self.distance.Text = tostring(math.floor(distance)) .. (self.config.DistanceUnit == "Meters" and "m" or " studs")
            self.distance.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2 + 40)
            self.distance.Visible = true
        end
    else
        self.box.Visible = false
        if self.config.NameESP then self.name.Visible = false end
        if self.config.HealthESP then self.health.Visible = false end
        if self.config.HealthBar then self.healthBar.Visible = false end
        if self.config.HealthBarOutline then self.healthBarOutline.Visible = false end
        if self.config.ToolESP then self.tool.Visible = false end
        if self.config.DistanceESP then self.distance.Visible = false end
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
