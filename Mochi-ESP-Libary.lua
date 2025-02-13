local ESP = {}
ESP.__index = ESP

ESP.espElements = {}

ESP.defaultConfig = {
    BoxColor = Color3.fromRGB(0, 255, 0),
    BoxTransparency = 0.4,
    BoxThickness = 2,
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Enabled = true
}

function ESP.new(player, config)
    local self = setmetatable({}, ESP)
    self.config = setmetatable(config or {}, {__index = ESP.defaultConfig})
    self.player = player
    self.box = nil
    self.text = nil
    self:createESP()
    table.insert(ESP.espElements, self)
    return self
end

function ESP:createESP()
    self.box = Drawing.new("Square")
    self.box.Color = self.config.BoxColor
    self.box.Transparency = self.config.BoxTransparency
    self.box.Thickness = self.config.BoxThickness
    self.box.Visible = self.config.Enabled
    self.box.Filled = false

    self.text = Drawing.new("Text")
    self.text.Color = self.config.TextColor
    self.text.Size = self.config.TextSize
    self.text.Visible = self.config.Enabled
end

function ESP:update()
    if not self.player or not self.player.Character or not self.player.Character:FindFirstChild("Head") then
        return
    end
    local head = self.player.Character.Head
    local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)

    if onScreen then
        local boxSize = Vector2.new(120, 200)
        self.box.Position = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2)
        self.box.Size = boxSize
        self.text.Position = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2 - 20)
        self.text.Text = self.player.Name
    else
        self.box.Visible = false
        self.text.Visible = false
    end
end

function ESP:toggleVisibility(visible)
    self.config.Enabled = visible
    self.box.Visible = visible
    self.text.Visible = visible
end

function ESP:destroy()
    for i, esp in ipairs(ESP.espElements) do
        if esp == self then
            table.remove(ESP.espElements, i)
            break
        end
    end
    self.box:Remove()
    self.text:Remove()
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
