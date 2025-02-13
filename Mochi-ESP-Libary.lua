local ESP = {}
ESP.__index = ESP

ESP.espElements = {}

ESP.defaultConfig = {
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxOutlineColor = Color3.fromRGB(50, 50, 50),
    BoxOutlineThickness = 2,
    BoxInnerOutlineColor = Color3.fromRGB(0, 0, 0),
    BoxInnerOutlineThickness = 1,
    BoxFillTransparency = 0.8,
    BoxThickness = 2,
    DoubleOutline = false,
    Enabled = true
}

function ESP.new(player, config)
    local self = setmetatable({}, ESP)
    self.config = setmetatable(config or {}, {__index = ESP.defaultConfig})
    self.player = player
    self.boxOutline = nil
    self.boxInnerOutline = nil
    self.boxFill = nil
    self.outerOutline = nil
    self:createESP()
    table.insert(ESP.espElements, self)
    return self
end

function ESP:createESP()
    self.boxOutline = Drawing.new("Square")
    self.boxOutline.Color = self.config.BoxOutlineColor
    self.boxOutline.Transparency = 0
    self.boxOutline.Thickness = self.config.BoxOutlineThickness
    self.boxOutline.Visible = self.config.Enabled
    self.boxOutline.Filled = false

    self.boxInnerOutline = Drawing.new("Square")
    self.boxInnerOutline.Color = self.config.BoxInnerOutlineColor
    self.boxInnerOutline.Transparency = 0
    self.boxInnerOutline.Thickness = self.config.BoxInnerOutlineThickness
    self.boxInnerOutline.Visible = self.config.Enabled
    self.boxInnerOutline.Filled = false

    self.boxFill = Drawing.new("Square")
    self.boxFill.Color = self.config.BoxColor
    self.boxFill.Transparency = self.config.BoxFillTransparency
    self.boxFill.Thickness = self.config.BoxThickness
    self.boxFill.Visible = self.config.Enabled
    self.boxFill.Filled = true

    if self.config.DoubleOutline then
        self.outerOutline = Drawing.new("Square")
        self.outerOutline.Color = self.config.BoxOutlineColor
        self.outerOutline.Transparency = 0
        self.outerOutline.Thickness = self.config.BoxOutlineThickness * 2
        self.outerOutline.Visible = self.config.Enabled
        self.outerOutline.Filled = false
    end
end

function ESP:update()
    if not self.player or not self.player.Character or not self.player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local humanoidRootPart = self.player.Character.HumanoidRootPart
    local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)

    if onScreen then
        local boxSize = Vector2.new(120, 200)

        if self.config.DoubleOutline then
            self.outerOutline.Position = Vector2.new(screenPos.X - boxSize.X / 2 - 4, screenPos.Y - boxSize.Y / 2 - 4)
            self.outerOutline.Size = boxSize + Vector2.new(8, 8)
        end

        self.boxOutline.Position = Vector2.new(screenPos.X - boxSize.X / 2 - 2, screenPos.Y - boxSize.Y / 2 - 2)
        self.boxOutline.Size = boxSize + Vector2.new(4, 4)

        self.boxInnerOutline.Position = Vector2.new(screenPos.X - boxSize.X / 2 - 1, screenPos.Y - boxSize.Y / 2 - 1)
        self.boxInnerOutline.Size = boxSize + Vector2.new(2, 2)

        self.boxFill.Position = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2)
        self.boxFill.Size = boxSize
    else
        self.boxOutline.Visible = false
        self.boxInnerOutline.Visible = false
        self.boxFill.Visible = false
        if self.config.DoubleOutline then
            self.outerOutline.Visible = false
        end
    end
end

function ESP:toggleVisibility(visible)
    self.config.Enabled = visible
    self.boxOutline.Visible = visible
    self.boxInnerOutline.Visible = visible
    self.boxFill.Visible = visible
    if self.config.DoubleOutline then
        self.outerOutline.Visible = visible
    end
end

function ESP:destroy()
    for i, esp in ipairs(ESP.espElements) do
        if esp == self then
            table.remove(ESP.espElements, i)
            break
        end
    end
    self.boxOutline:Remove()
    self.boxInnerOutline:Remove()
    self.boxFill:Remove()
    if self.config.DoubleOutline then
        self.outerOutline:Remove()
    end
end

function ESP.updateAll()
    for _, esp in ipairs(ESP.espElements) do
        esp:update()
    end
end

function ESP.destroyAll()
    for _, esp in ipairs(ESP.espElements) do
        esp:destroy()
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    ESP.updateAll()
end)

return ESP
