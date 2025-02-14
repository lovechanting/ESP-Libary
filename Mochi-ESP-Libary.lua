local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.__index = ESP
ESP.espElements = {}

ESP.defaultConfig = {
    BoxColor = Color3.fromRGB(0, 0, 0),
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),
    BoxThickness = 2,
    BoxTransparency = 0.5,
    NameESP = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 18,
    HealthESP = true,
    HealthColor = Color3.fromRGB(0, 255, 0),
    HealthSize = 16,
}

function ESP.new(player, config)
    if player == LocalPlayer then return end
    local self = setmetatable({}, ESP)
    self.config = setmetatable(config or {}, {__index = ESP.defaultConfig})
    self.player = player
    self:createESP()
    table.insert(ESP.espElements, self)
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
        self.name.Visible = false
    end

    if self.config.HealthESP then
        self.health = Drawing.new("Text")
        self.health.Color = self.config.HealthColor
        self.health.Size = self.config.HealthSize
        self.health.Visible = false
    end
end

function ESP:update()
    if not self.player or not self.player.Character or not self.player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local root = self.player.Character.HumanoidRootPart
    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)

    if onScreen then
        local boxSize = Vector2.new(120, 200)
        self.box.Position = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2)
        self.box.Size = boxSize
        self.box.Visible = true

        if self.config.NameESP then
            self.name.Text = self.player.Name
            self.name.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y / 2 - 20)
            self.name.Visible = true
        end

        if self.config.HealthESP then
            local humanoid = self.player.Character:FindFirstChild("Humanoid")
            if humanoid then
                self.health.Text = tostring(math.floor(humanoid.Health)) .. " HP"
                self.health.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2)
                self.health.Visible = true
            end
        end
    else
        self.box.Visible = false
        if self.config.NameESP then self.name.Visible = false end
        if self.config.HealthESP then self.health.Visible = false end
    end
end

function ESP.updateAll()
    for _, esp in ipairs(ESP.espElements) do
        esp:update()
    end
end

RunService.RenderStepped:Connect(ESP.updateAll)

return ESP
