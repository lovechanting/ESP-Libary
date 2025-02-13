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
    Enabled = true,
    NameESP = false,
    DisplayNameESP = false,
    NameTextSize = 18,
    NameTextFont = 3,
    NameTextColor = Color3.fromRGB(255, 255, 255),
    NameTextOutline = true,
    NameTextOutlineColor = Color3.fromRGB(0, 0, 0),
    NameTextAnimation = false
}

function ESP.new(player, config)
    local self = setmetatable({}, ESP)
    self.config = setmetatable(config or {}, {__index = ESP.defaultConfig})
    self.player = player
    self:createESP()
    table.insert(ESP.espElements, self)
    return self
end

function ESP:createESP()
    self.boxOutline = Drawing.new("Square")
    self.boxOutline.Color = self.config.BoxOutlineColor
    self.boxOutline.Thickness = self.config.BoxOutlineThickness
    self.boxOutline.Visible = self.config.Enabled
    self.boxOutline.Filled = false

    self.boxInnerOutline = Drawing.new("Square")
    self.boxInnerOutline.Color = self.config.BoxInnerOutlineColor
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
        self.outerOutline.Thickness = self.config.BoxOutlineThickness * 2
        self.outerOutline.Visible = self.config.Enabled
        self.outerOutline.Filled = false
    end

    if self.config.NameESP then
        self.nameText = Drawing.new("Text")
        self.nameText.Size = self.config.NameTextSize
        self.nameText.Font = self.config.NameTextFont
        self.nameText.Color = self.config.NameTextColor
        self.nameText.Outline = self.config.NameTextOutline
        self.nameText.OutlineColor = self.config.NameTextOutlineColor
        self.nameText.Visible = self.config.Enabled
    end

    if self.config.DisplayNameESP then
        self.displayNameText = Drawing.new("Text")
        self.displayNameText.Size = self.config.NameTextSize
        self.displayNameText.Font = self.config.NameTextFont
        self.displayNameText.Color = self.config.NameTextColor
        self.displayNameText.Outline = self.config.NameTextOutline
        self.displayNameText.OutlineColor = self.config.NameTextOutlineColor
        self.displayNameText.Visible = self.config.Enabled
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

        if self.config.NameESP or self.config.DisplayNameESP then
            local nameText = self.config.NameESP and self.player.Name or ""
            local displayNameText = self.config.DisplayNameESP and self.player.DisplayName or ""

            local texts = {}
            if nameText ~= "" then table.insert(texts, nameText) end
            if displayNameText ~= "" then table.insert(texts, displayNameText) end

            table.sort(texts, function(a, b) return #a < #b end)

            local startY = screenPos.Y - boxSize.Y / 2 - (#texts * (self.config.NameTextSize + 2))

            if self.config.NameESP then
                self.nameText.Text = texts[1] or ""
                self.nameText.Position = Vector2.new(screenPos.X, startY)
                self.nameText.Visible = self.config.Enabled
                startY = startY + self.config.NameTextSize + 2
            end

            if self.config.DisplayNameESP then
                self.displayNameText.Text = texts[2] or ""
                self.displayNameText.Position = Vector2.new(screenPos.X, startY)
                self.displayNameText.Visible = self.config.Enabled
            end
        end
    else
        self.boxOutline.Visible = false
        self.boxInnerOutline.Visible = false
        self.boxFill.Visible = false
        if self.config.DoubleOutline then
            self.outerOutline.Visible = false
        end
        if self.config.NameESP then
            self.nameText.Visible = false
        end
        if self.config.DisplayNameESP then
            self.displayNameText.Visible = false
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
    if self.config.NameESP then
        self.nameText.Visible = visible
    end
    if self.config.DisplayNameESP then
        self.displayNameText.Visible = visible
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
    if self.config.NameESP then
        self.nameText:Remove()
    end
    if self.config.DisplayNameESP then
        self.displayNameText:Remove()
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
