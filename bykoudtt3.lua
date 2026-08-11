-- =============================================================================
-- NEXUS EXECUTOR - ADVANCED TOOLS
-- Cole no seu executor e execute
-- =============================================================================

-- =============================================================================
-- 1. ANTI-DETECÇÃO (SILENCIAR ANTI-CHEAT)
-- =============================================================================

-- Proteção contra detecção
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Bloquear MdrRemotes
    if method == "FireServer" or method == "InvokeServer" then
        local parent = self.Parent
        if parent then
            local parentName = parent.Name
            if parentName == "MdrRemotes" or parentName:find("Remote") then
                return nil
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Bloquear logs suspeitos
local oldPrint = print
print = function(...) end
warn = function(...) end

-- =============================================================================
-- 2. SERVICOS
-- =============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =============================================================================
-- 3. CONFIGURAÇÕES
-- =============================================================================

local Config = {
    -- ESP
    ESP_Main = true,
    ESP_Names = true,
    ESP_Distance = true,
    ESP_Health = true,
    ESP_Boxes = true,
    ESP_Lines = true,
    ESP_Dot = true,
    ESP_RangeMeters = 3000,
    ESP_RangeStuds = 10714,
    
    -- Hitbox
    HIT_Enabled = false,
    HIT_Size = 3,
    HIT_Transparency = 0.7,
    HIT_Color = Color3.fromRGB(255, 100, 100),
    
    -- Aimbot
    AIM_Enabled = false,
    AIM_FOV = 200,
    AIM_Smooth = 5,
    AIM_Part = "Head",
    AIM_TeamCheck = true,
    
    -- Visual
    VIS_Chams = false,
    VIS_Crosshair = true,
}

-- =============================================================================
-- 4. TELEPORT LOCATIONS
-- =============================================================================

local TeleportLocations = {
    {Name = "Police Station", Position = Vector3.new(0, 266, 0), Icon = "🚔"},
    {Name = "Spawn", Position = Vector3.new(0, 100, 0), Icon = "🏠"},
}

-- =============================================================================
-- 5. UI STYLE
-- =============================================================================

local UI = {
    BG = Color3.fromRGB(12, 12, 20),
    Card = Color3.fromRGB(18, 18, 30),
    CardHover = Color3.fromRGB(24, 24, 38),
    Accent = Color3.fromRGB(120, 60, 255),
    Accent2 = Color3.fromRGB(255, 80, 80),
    Text = Color3.fromRGB(220, 220, 230),
    TextDim = Color3.fromRGB(140, 140, 160),
    Green = Color3.fromRGB(60, 255, 100),
    Red = Color3.fromRGB(255, 60, 60),
    Orange = Color3.fromRGB(255, 150, 50),
    Blue = Color3.fromRGB(60, 140, 255)
}

-- =============================================================================
-- 6. GUI PRINCIPAL
-- =============================================================================

local GuiParent = LocalPlayer:WaitForChild("PlayerGui")
local MainGui = Instance.new("ScreenGui")
MainGui.Name = Random.new():NextInteger(10000, 99999) .. "Nexus"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.IgnoreGuiInset = true
syn.protect_gui(MainGui) -- Proteger de outros scripts

MainGui.Parent = GuiParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 460)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -230)
MainFrame.BackgroundColor3 = UI.BG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = MainGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- =============================================================================
-- 7. TITLE BAR
-- =============================================================================

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- Gradient
local GradientLine = Instance.new("Frame")
GradientLine.Size = UDim2.new(1, 0, 0, 2)
GradientLine.Position = UDim2.new(0, 0, 1, 0)
GradientLine.BorderSizePixel = 0
GradientLine.Parent = TitleBar

Instance.new("UIGradient", GradientLine).Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, UI.Accent),
    ColorSequenceKeypoint.new(0.5, UI.Accent2),
    ColorSequenceKeypoint.new(1, UI.Accent)
})

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 200, 0, 20)
TitleText.Position = UDim2.new(0, 16, 0, 10)
TitleText.BackgroundTransparency = 1
TitleText.Text = "NEXUS EXECUTOR"
TitleText.TextColor3 = UI.Text
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local SubText = Instance.new("TextLabel")
SubText.Size = UDim2.new(0, 200, 0, 14)
SubText.Position = UDim2.new(0, 16, 0, 30)
SubText.BackgroundTransparency = 1
SubText.Text = "Advanced Game Tools"
SubText.TextColor3 = UI.TextDim
SubText.TextSize = 10
SubText.Font = Enum.Font.Gotham
SubText.TextXAlignment = Enum.TextXAlignment.Left
SubText.Parent = TitleBar

-- Status
local StatusPill = Instance.new("Frame")
StatusPill.Size = UDim2.new(0, 60, 0, 22)
StatusPill.Position = UDim2.new(1, -75, 0, 16)
StatusPill.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
StatusPill.BorderSizePixel = 0
StatusPill.Parent = TitleBar

Instance.new("UICorner", StatusPill).CornerRadius = UDim.new(1, 0)

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 8, 0.5, -4)
StatusDot.BackgroundColor3 = UI.Green
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusPill

Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 40, 1, 0)
StatusText.Position = UDim2.new(0, 20, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "ON"
StatusText.TextColor3 = UI.Text
StatusText.TextSize = 10
StatusText.Font = Enum.Font.GothamBold
StatusText.Parent = StatusPill

-- =============================================================================
-- 8. TAB SYSTEM
-- =============================================================================

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 140, 1, -55)
TabContainer.Position = UDim2.new(0, 0, 0, 55)
TabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 12)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -148, 1, -55)
ContentContainer.Position = UDim2.new(0, 145, 0, 55)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Tabs = {}
local CurrentTab = "Visuals"

local function CreateTab(name, icon, order)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -16, 0, 42)
    tabBtn.Position = UDim2.new(0, 8, 0, 15 + (order * 50))
    tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = TabContainer
    
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 24, 0, 24)
    iconLabel.Position = UDim2.new(0, 10, 0.5, -12)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 18
    iconLabel.Parent = tabBtn
    
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Size = UDim2.new(1, -44, 1, 0)
    tabLabel.Position = UDim2.new(0, 38, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = name
    tabLabel.TextColor3 = UI.TextDim
    tabLabel.Font = Enum.Font.GothamBold
    tabLabel.TextSize = 12
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.Parent = tabBtn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 20)
    indicator.Position = UDim2.new(0, 0, 0.5, -10)
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Parent = tabBtn
    
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 2)
    
    local contentPage = Instance.new("ScrollingFrame")
    contentPage.Size = UDim2.new(1, 0, 1, 0)
    contentPage.BackgroundTransparency = 1
    contentPage.BorderSizePixel = 0
    contentPage.ScrollBarThickness = 3
    contentPage.ScrollBarImageColor3 = UI.Accent
    contentPage.CanvasSize = UDim2.new(0, 0, 0, 600)
    contentPage.Visible = false
    contentPage.Parent = ContentContainer
    
    Instance.new("UIListLayout", contentPage).Padding = UDim.new(0, 6)
    
    Tabs[name] = {
        Button = tabBtn,
        Label = tabLabel,
        Indicator = indicator,
        Content = contentPage
    }
    
    tabBtn.MouseButton1Click:Connect(function()
        CurrentTab = name
        for tn, td in pairs(Tabs) do
            td.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
            td.Label.TextColor3 = UI.TextDim
            td.Indicator.BackgroundTransparency = 1
            td.Content.Visible = false
        end
        tabBtn.BackgroundColor3 = UI.CardHover
        tabLabel.TextColor3 = UI.Text
        indicator.BackgroundTransparency = 0
        indicator.BackgroundColor3 = UI.Accent
        contentPage.Visible = true
    end)
    
    return contentPage
end

-- Criar abas
local VisualsPage = CreateTab("Visuals", "👁️", 0)
local AimbotPage = CreateTab("Aimbot", "🎯", 1)
local TeleportPage = CreateTab("Teleport", "📍", 2)

-- Ativar primeira aba
Tabs["Visuals"].Button.BackgroundColor3 = UI.CardHover
Tabs["Visuals"].Label.TextColor3 = UI.Text
Tabs["Visuals"].Indicator.BackgroundTransparency = 0
Tabs["Visuals"].Indicator.BackgroundColor3 = UI.Accent
Tabs["Visuals"].Content.Visible = true

-- =============================================================================
-- 9. UI COMPONENTS
-- =============================================================================

local function AddSection(parent, text, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 25)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "  " .. text
    label.TextColor3 = UI.Accent
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
end

local function AddToggle(parent, text, configKey, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 44)
    frame.BackgroundColor3 = UI.Card
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config[configKey] and UI.Text or UI.TextDim
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 48, 0, 24)
    toggleBg.Position = UDim2.new(1, -62, 0.5, -12)
    toggleBg.BackgroundColor3 = Config[configKey] and UI.Accent or Color3.fromRGB(50, 50, 65)
    toggleBg.BorderSizePixel = 0
    toggleBg.Text = ""
    toggleBg.AutoButtonColor = false
    toggleBg.Parent = frame
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 18, 0, 18)
    dot.Position = Config[configKey] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = toggleBg
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local isOn = Config[configKey]
    
    toggleBg.MouseButton1Click:Connect(function()
        isOn = not isOn
        Config[configKey] = isOn
        TweenService:Create(toggleBg, TweenInfo.new(0.15), {BackgroundColor3 = isOn and UI.Accent or Color3.fromRGB(50, 50, 65)}):Play()
        TweenService:Create(dot, TweenInfo.new(0.15), {Position = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
        label.TextColor3 = isOn and UI.Text or UI.TextDim
        
        if configKey == "ESP_Main" then
            StatusDot.BackgroundColor3 = isOn and UI.Green or UI.Red
            StatusText.Text = isOn and "ON" or "OFF"
        end
    end)
end

local function AddSlider(parent, text, configKey, min, max, unit, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 70)
    frame.BackgroundColor3 = UI.Card
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 18)
    label.Position = UDim2.new(0, 14, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = UI.Text
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 80, 0, 18)
    valueLabel.Position = UDim2.new(1, -94, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = Config[configKey] .. unit
    valueLabel.TextColor3 = UI.Accent
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -38, 0, 4)
    sliderBg.Position = UDim2.new(0, 19, 0, 45)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 2)
    
    local pct = (Config[configKey] - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = UI.Accent
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
    
    local sdot = Instance.new("Frame")
    sdot.Size = UDim2.new(0, 12, 0, 12)
    sdot.Position = UDim2.new(pct, -6, 0.5, -6)
    sdot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sdot.BorderSizePixel = 0
    sdot.Parent = sliderBg
    Instance.new("UICorner", sdot).CornerRadius = UDim.new(1, 0)
    
    local sbtn = Instance.new("TextButton")
    sbtn.Size = UDim2.new(1, 0, 3, 0)
    sbtn.BackgroundTransparency = 1
    sbtn.Text = ""
    sbtn.Parent = sliderBg
    
    local dragging = false
    sbtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    
    sbtn.MouseMoved:Connect(function()
        if dragging then
            local mp = UserInputService:GetMouseLocation()
            local bp = sliderBg.AbsolutePosition
            local bs = sliderBg.AbsoluteSize
            local p = math.clamp((mp.X - bp.X) / bs.X, 0, 1)
            local v = math.floor(min + (max - min) * p)
            Config[configKey] = v
            fill.Size = UDim2.new(p, 0, 1, 0)
            sdot.Position = UDim2.new(p, -6, 0.5, -6)
            valueLabel.Text = v .. unit
            if configKey == "ESP_RangeMeters" then Config.ESP_RangeStuds = math.floor(v / 0.28) end
        end
    end)
end

-- =============================================================================
-- 10. BUILD VISUALS PAGE
-- =============================================================================

local vo = 0
Instance.new("Frame", VisualsPage).Size = UDim2.new(1, 0, 0, 6); Instance.new("Frame", VisualsPage).BackgroundTransparency = 1; Instance.new("UIListLayout", VisualsPage)

AddSection(VisualsPage, "ESP SETTINGS", vo); vo = vo + 1
AddToggle(VisualsPage, "ESP Master", "ESP_Main", vo); vo = vo + 1
AddSlider(VisualsPage, "Render Range", "ESP_RangeMeters", 0, 3000, "m", vo); vo = vo + 1

AddSection(VisualsPage, "PLAYER INFO", vo); vo = vo + 1
AddToggle(VisualsPage, "Names", "ESP_Names", vo); vo = vo + 1
AddToggle(VisualsPage, "Distance", "ESP_Distance", vo); vo = vo + 1
AddToggle(VisualsPage, "Health", "ESP_Health", vo); vo = vo + 1

AddSection(VisualsPage, "RENDER STYLE", vo); vo = vo + 1
AddToggle(VisualsPage, "2D Boxes", "ESP_Boxes", vo); vo = vo + 1
AddToggle(VisualsPage, "Tracer Lines", "ESP_Lines", vo); vo = vo + 1
AddToggle(VisualsPage, "Head Dot", "ESP_Dot", vo); vo = vo + 1

-- =============================================================================
-- 11. BUILD AIMBOT PAGE
-- =============================================================================

local ao = 0
Instance.new("Frame", AimbotPage).Size = UDim2.new(1, 0, 0, 6)

AddSection(AimbotPage, "AIMBOT SETTINGS", ao); ao = ao + 1
AddToggle(AimbotPage, "Aimbot", "AIM_Enabled", ao); ao = ao + 1
AddSlider(AimbotPage, "FOV", "AIM_FOV", 50, 500, "px", ao); ao = ao + 1
AddSlider(AimbotPage, "Smoothness", "AIM_Smooth", 1, 20, "", ao); ao = ao + 1
AddToggle(AimbotPage, "Team Check", "AIM_TeamCheck", ao); ao = ao + 1

-- =============================================================================
-- 12. BUILD TELEPORT PAGE
-- =============================================================================

local to = 0
Instance.new("Frame", TeleportPage).Size = UDim2.new(1, 0, 0, 6)

AddSection(TeleportPage, "LOCATIONS", to); to = to + 1

local function TeleportTo(pos)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        c.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

for _, loc in ipairs(TeleportLocations) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 45)
    frame.BackgroundColor3 = UI.Card
    frame.BorderSizePixel = 0
    frame.LayoutOrder = to
    frame.Parent = TeleportPage
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 1, 0)
    icon.Position = UDim2.new(0, 10, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = loc.Icon
    icon.TextSize = 20
    icon.Parent = frame
    
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(0.5, -40, 1, 0)
    name.Position = UDim2.new(0, 40, 0, 0)
    name.BackgroundTransparency = 1
    name.Text = loc.Name
    name.TextColor3 = UI.Text
    name.Font = Enum.Font.SourceSansBold
    name.TextSize = 12
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextYAlignment = Enum.TextYAlignment.Center
    name.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 26)
    btn.Position = UDim2.new(1, -62, 0.5, -13)
    btn.BackgroundColor3 = UI.Blue
    btn.BorderSizePixel = 0
    btn.Text = "GO"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function() TeleportTo(loc.Position) end)
    
    to = to + 1
end

-- Update canvas sizes
for _, tab in pairs(Tabs) do
    local h = 0
    for _, child in ipairs(tab.Content:GetChildren()) do
        if child:IsA("Frame") then h = h + child.Size.Y.Offset + 6 end
    end
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, h + 10)
end

-- =============================================================================
-- 13. KEY BINDINGS
-- =============================================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
    if input.KeyCode == Enum.KeyCode.Delete then
        MainGui:Destroy()
    end
end)

-- =============================================================================
-- 14. ESP SYSTEM
-- =============================================================================

local ESP = {}

local function CreateESP(player)
    local d = {
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Dist = Drawing.new("Text"),
        HealthBg = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        Dot = Drawing.new("Circle")
    }
    
    d.BoxOutline.Visible = false; d.BoxOutline.Color = Color3.fromRGB(0, 0, 0); d.BoxOutline.Thickness = 3; d.BoxOutline.Filled = false; d.BoxOutline.Transparency = 0.5
    d.Box.Visible = false; d.Box.Color = Color3.fromRGB(140, 30, 30); d.Box.Thickness = 1; d.Box.Filled = false; d.Box.Transparency = 0.6
    d.Name.Visible = false; d.Name.Color = Color3.fromRGB(255, 255, 255); d.Name.Size = 13; d.Name.Font = 2; d.Name.Center = true; d.Name.Outline = true
    d.Dist.Visible = false; d.Dist.Color = Color3.fromRGB(255, 200, 50); d.Dist.Size = 12; d.Dist.Font = 2; d.Dist.Center = true; d.Dist.Outline = true
    d.HealthBg.Visible = false; d.HealthBg.Color = Color3.fromRGB(10, 10, 10); d.HealthBg.Filled = true; d.HealthBg.Transparency = 0.5
    d.HealthBar.Visible = false; d.HealthBar.Color = Color3.fromRGB(60, 255, 60); d.HealthBar.Filled = true; d.HealthBar.Transparency = 0.2
    d.Line.Visible = false; d.Line.Color = Color3.fromRGB(140, 30, 30); d.Line.Thickness = 1; d.Line.Transparency = 0.4
    d.Dot.Visible = false; d.Dot.Color = Color3.fromRGB(255, 255, 255); d.Dot.Filled = true; d.Dot.Transparency = 0.3; d.Dot.Radius = 3
    
    ESP[player] = d
end

RunService.RenderStepped:Connect(function()
    if not Config.ESP_Main then
        for _, d in pairs(ESP) do
            pcall(function() d.BoxOutline.Visible = false; d.Box.Visible = false; d.Name.Visible = false; d.Dist.Visible = false; d.HealthBg.Visible = false; d.HealthBar.Visible = false; d.Line.Visible = false; d.Dot.Visible = false end)
        end
        return
    end
    
    Camera = workspace.CurrentCamera
    if not Camera then return end
    
    local cp = Camera.CFrame.Position
    local ss = Camera.ViewportSize
    local active = {}
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            active[p] = true
            local c = p.Character
            if c then
                local hrp = c:FindFirstChild("HumanoidRootPart")
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hrp:IsA("BasePart") and hum.Health > 0 then
                    local dist = (cp - hrp.Position).Magnitude
                    if dist <= Config.ESP_RangeStuds then
                        local pos, on = Camera:WorldToViewportPoint(hrp.Position)
                        if on and pos.Z > 0 then
                            if not ESP[p] then CreateESP(p) end
                            local d = ESP[p]
                            if not d then continue end
                            
                            local sx = math.clamp((1000/dist)*(45/45), 5, 110)
                            local sy = math.clamp((1600/dist)*(45/45), 8, 190)
                            local px, py = pos.X - sx/2, pos.Y - sy/2
                            local m = math.floor(dist*0.28+0.5)
                            
                            if Config.ESP_Boxes then
                                d.BoxOutline.Position = Vector2.new(px-1, py-1); d.BoxOutline.Size = Vector2.new(sx+2, sy+2); d.BoxOutline.Visible = true
                                d.Box.Position = Vector2.new(px, py); d.Box.Size = Vector2.new(sx, sy); d.Box.Visible = true
                            else d.BoxOutline.Visible = false; d.Box.Visible = false end
                            
                            if Config.ESP_Names then d.Name.Text = p.Name; d.Name.Position = Vector2.new(pos.X, py-20); d.Name.Visible = true else d.Name.Visible = false end
                            
                            if Config.ESP_Distance then
                                d.Dist.Text = m >= 1000 and string.format("%.1fkm", m/1000) or m.."m"
                                d.Dist.Position = Vector2.new(pos.X, py-8); d.Dist.Visible = true
                            else d.Dist.Visible = false end
                            
                            if Config.ESP_Health then
                                local hp = hum.Health/math.max(hum.MaxHealth, 1)
                                d.HealthBg.Position = Vector2.new(px-6, py-1); d.HealthBg.Size = Vector2.new(4, sy+2); d.HealthBg.Visible = true
                                d.HealthBar.Position = Vector2.new(px-5, py+sy-sy*hp); d.HealthBar.Size = Vector2.new(2, sy*hp); d.HealthBar.Color = Color3.fromHSV(hp*0.33, 1, 1); d.HealthBar.Visible = true
                            else d.HealthBg.Visible = false; d.HealthBar.Visible = false end
                            
                            if Config.ESP_Lines then d.Line.From = Vector2.new(ss.X/2, ss.Y); d.Line.To = Vector2.new(pos.X, py+sy/2); d.Line.Visible = true else d.Line.Visible = false end
                            
                            if Config.ESP_Dot then
                                local h = c:FindFirstChild("Head")
                                if h then local hp2 = Camera:WorldToViewportPoint(h.Position); d.Dot.Position = Vector2.new(hp2.X, hp2.Y); d.Dot.Visible = true end
                            else d.Dot.Visible = false end
                        else if ESP[p] then pcall(function() ESP[p].BoxOutline.Visible = false end) end end
                    else if ESP[p] then pcall(function() ESP[p].BoxOutline.Visible = false end) end end
                end
            end
        end
    end
    
    for p, _ in pairs(ESP) do if not active[p] then pcall(function() ESP[p].BoxOutline:Remove(); ESP[p] = nil end) end end
end)

-- =============================================================================
-- 15. AIMBOT SYSTEM
-- =============================================================================

local function GetClosestPlayer()
    local closest = nil
    local shortest = Config.AIM_FOV
    
    local c = LocalPlayer.Character
    if not c then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pc = p.Character
            if pc and pc:FindFirstChild("HumanoidRootPart") then
                if Config.AIM_TeamCheck and p.Team == LocalPlayer.Team then continue end
                
                local part = pc:FindFirstChild(Config.AIM_Part) or pc:FindFirstChild("Head")
                if part then
                    local pos, on = Camera:WorldToViewportPoint(part.Position)
                    if on then
                        local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

RunService.RenderStepped:Connect(function()
    if not Config.AIM_Enabled then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    
    local target = GetClosestPlayer()
    if target then
        local pos = Camera:WorldToViewportPoint(target.Position)
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local move = (Vector2.new(pos.X, pos.Y) - center) / Config.AIM_Smooth
        mousemoverel(move.X, move.Y)
    end
end)

-- =============================================================================
-- 16. CLEANUP
-- =============================================================================

Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then pcall(function() ESP[p].BoxOutline:Remove() end); ESP[p] = nil end
end)

oldPrint("Nexus Executor loaded successfully!")
