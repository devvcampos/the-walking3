-- =============================================================================
-- NEXUS EXECUTOR - MADIUM VERSION (ESP FIXED)
-- =============================================================================

-- =============================================================================
-- 1. ANTI-DETECÇÃO
-- =============================================================================

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if method == "FireServer" or method == "InvokeServer" then
        local parent = self.Parent
        if parent then
            local parentName = parent.Name
            if parentName == "MdrRemotes" then
                return nil
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- =============================================================================
-- 2. SERVICES
-- =============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =============================================================================
-- 3. CONFIG
-- =============================================================================

local Config = {
    ESP_Main = true,
    ESP_Names = true,
    ESP_Distance = true,
    ESP_Health = true,
    ESP_Boxes = true,
    ESP_Lines = true,
    ESP_Dot = true,
    ESP_RangeMeters = 3000,
    ESP_RangeStuds = 10714,
    
    AIM_Enabled = false,
    AIM_FOV = 200,
    AIM_Smooth = 5,
    AIM_TeamCheck = true,
}

-- =============================================================================
-- 4. TELEPORT LOCATIONS
-- =============================================================================

local TeleportLocations = {
    {Name = "Police Station", Position = Vector3.new(0, 266, 0), Icon = "🚔"},
}

-- =============================================================================
-- 5. UI COLORS
-- =============================================================================

local UI = {
    BG = Color3.fromRGB(12, 12, 20),
    Card = Color3.fromRGB(18, 18, 30),
    CardHover = Color3.fromRGB(24, 24, 38),
    Accent = Color3.fromRGB(120, 60, 255),
    Text = Color3.fromRGB(220, 220, 230),
    TextDim = Color3.fromRGB(140, 140, 160),
    Green = Color3.fromRGB(60, 255, 100),
    Red = Color3.fromRGB(255, 60, 60),
    Blue = Color3.fromRGB(60, 140, 255)
}

-- =============================================================================
-- 6. GUI
-- =============================================================================

local GuiParent = LocalPlayer:WaitForChild("PlayerGui")
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "Nexus_" .. tostring(math.random(10000, 99999))
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.Parent = GuiParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 440)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -220)
MainFrame.BackgroundColor3 = UI.BG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = MainGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
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

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 200, 0, 20)
TitleText.Position = UDim2.new(0, 16, 0, 8)
TitleText.BackgroundTransparency = 1
TitleText.Text = "NEXUS"
TitleText.TextColor3 = UI.Text
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local SubText = Instance.new("TextLabel")
SubText.Size = UDim2.new(0, 200, 0, 14)
SubText.Position = UDim2.new(0, 16, 0, 28)
SubText.BackgroundTransparency = 1
SubText.Text = "Madium Edition"
SubText.TextColor3 = UI.TextDim
SubText.TextSize = 10
SubText.Font = Enum.Font.Gotham
SubText.TextXAlignment = Enum.TextXAlignment.Left
SubText.Parent = TitleBar

-- Status
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -35, 0, 14)
StatusDot.BackgroundColor3 = UI.Green
StatusDot.BorderSizePixel = 0
StatusDot.Parent = TitleBar

Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 30, 0, 12)
StatusText.Position = UDim2.new(1, -33, 0, 24)
StatusText.BackgroundTransparency = 1
StatusText.Text = "ON"
StatusText.TextColor3 = UI.Text
StatusText.TextSize = 9
StatusText.Font = Enum.Font.GothamBold
StatusText.Parent = TitleBar

-- =============================================================================
-- 7. TABS
-- =============================================================================

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 130, 1, -50)
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 12)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -138, 1, -50)
ContentContainer.Position = UDim2.new(0, 135, 0, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Tabs = {}
local CurrentTab = "Visuals"

local function CreateTab(name, icon, order)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -16, 0, 40)
    tabBtn.Position = UDim2.new(0, 8, 0, 12 + (order * 48))
    tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = TabContainer
    
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 24, 0, 24)
    iconLabel.Position = UDim2.new(0, 8, 0.5, -12)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 18
    iconLabel.Parent = tabBtn
    
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Size = UDim2.new(1, -40, 1, 0)
    tabLabel.Position = UDim2.new(0, 36, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = name
    tabLabel.TextColor3 = UI.TextDim
    tabLabel.Font = Enum.Font.GothamBold
    tabLabel.TextSize = 12
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.Parent = tabBtn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 18)
    indicator.Position = UDim2.new(0, 0, 0.5, -9)
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
    contentPage.CanvasSize = UDim2.new(0, 0, 0, 500)
    contentPage.Visible = false
    contentPage.Parent = ContentContainer
    
    Instance.new("UIListLayout", contentPage).Padding = UDim.new(0, 5)
    
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
-- 8. UI COMPONENTS
-- =============================================================================

local function AddToggle(parent, text, configKey, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 42)
    frame.BackgroundColor3 = UI.Card
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config[configKey] and UI.Text or UI.TextDim
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 46, 0, 22)
    toggleBg.Position = UDim2.new(1, -58, 0.5, -11)
    toggleBg.BackgroundColor3 = Config[configKey] and UI.Accent or Color3.fromRGB(50, 50, 65)
    toggleBg.BorderSizePixel = 0
    toggleBg.Text = ""
    toggleBg.AutoButtonColor = false
    toggleBg.Parent = frame
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = Config[configKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = toggleBg
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local isOn = Config[configKey]
    
    toggleBg.MouseButton1Click:Connect(function()
        isOn = not isOn
        Config[configKey] = isOn
        TweenService:Create(toggleBg, TweenInfo.new(0.15), {BackgroundColor3 = isOn and UI.Accent or Color3.fromRGB(50, 50, 65)}):Play()
        TweenService:Create(dot, TweenInfo.new(0.15), {Position = isOn and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
        label.TextColor3 = isOn and UI.Text or UI.TextDim
        
        if configKey == "ESP_Main" then
            StatusDot.BackgroundColor3 = isOn and UI.Green or UI.Red
            StatusText.Text = isOn and "ON" or "OFF"
        end
    end)
end

local function AddSlider(parent, text, configKey, min, max, unit, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 68)
    frame.BackgroundColor3 = UI.Card
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 18)
    label.Position = UDim2.new(0, 12, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = UI.Text
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 80, 0, 18)
    valueLabel.Position = UDim2.new(1, -92, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = Config[configKey] .. unit
    valueLabel.TextColor3 = UI.Accent
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -34, 0, 4)
    sliderBg.Position = UDim2.new(0, 17, 0, 42)
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
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end 
    end)
    
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
-- 9. BUILD PAGES
-- =============================================================================

-- Visuals
local vo = 0
local sp1 = Instance.new("Frame", VisualsPage)
sp1.Size = UDim2.new(1, 0, 0, 5)
sp1.BackgroundTransparency = 1
sp1.LayoutOrder = vo
vo = vo + 1

AddToggle(VisualsPage, "ESP Master", "ESP_Main", vo); vo = vo + 1
AddSlider(VisualsPage, "Render Range", "ESP_RangeMeters", 0, 3000, "m", vo); vo = vo + 1

local sec1 = Instance.new("TextLabel", VisualsPage)
sec1.Size = UDim2.new(1, -24, 0, 18)
sec1.BackgroundTransparency = 1
sec1.Text = "  PLAYER INFO"
sec1.TextColor3 = UI.Accent
sec1.Font = Enum.Font.GothamBold
sec1.TextSize = 10
sec1.TextXAlignment = Enum.TextXAlignment.Left
sec1.LayoutOrder = vo
vo = vo + 1

AddToggle(VisualsPage, "Names", "ESP_Names", vo); vo = vo + 1
AddToggle(VisualsPage, "Distance", "ESP_Distance", vo); vo = vo + 1
AddToggle(VisualsPage, "Health", "ESP_Health", vo); vo = vo + 1

local sec2 = Instance.new("TextLabel", VisualsPage)
sec2.Size = UDim2.new(1, -24, 0, 18)
sec2.BackgroundTransparency = 1
sec2.Text = "  RENDER STYLE"
sec2.TextColor3 = UI.Accent
sec2.Font = Enum.Font.GothamBold
sec2.TextSize = 10
sec2.TextXAlignment = Enum.TextXAlignment.Left
sec2.LayoutOrder = vo
vo = vo + 1

AddToggle(VisualsPage, "2D Boxes", "ESP_Boxes", vo); vo = vo + 1
AddToggle(VisualsPage, "Tracer Lines", "ESP_Lines", vo); vo = vo + 1
AddToggle(VisualsPage, "Head Dot", "ESP_Dot", vo); vo = vo + 1

-- Aimbot
local ao = 0
local sp2 = Instance.new("Frame", AimbotPage)
sp2.Size = UDim2.new(1, 0, 0, 5)
sp2.BackgroundTransparency = 1
sp2.LayoutOrder = ao
ao = ao + 1

AddToggle(AimbotPage, "Aimbot", "AIM_Enabled", ao); ao = ao + 1
AddSlider(AimbotPage, "FOV", "AIM_FOV", 50, 500, "px", ao); ao = ao + 1
AddSlider(AimbotPage, "Smoothness", "AIM_Smooth", 1, 20, "", ao); ao = ao + 1
AddToggle(AimbotPage, "Team Check", "AIM_TeamCheck", ao); ao = ao + 1

-- Teleport
local to = 0
local sp3 = Instance.new("Frame", TeleportPage)
sp3.Size = UDim2.new(1, 0, 0, 5)
sp3.BackgroundTransparency = 1
sp3.LayoutOrder = to
to = to + 1

local function TeleportTo(pos)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        c.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

for _, loc in ipairs(TeleportLocations) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 44)
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

-- Update canvas
for _, tab in pairs(Tabs) do
    local h = 0
    for _, child in ipairs(tab.Content:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            h = h + child.Size.Y.Offset + 5
        end
    end
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, h + 10)
end

-- =============================================================================
-- 10. KEY BINDINGS
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
-- 11. ESP SYSTEM (CORRIGIDO - SEM FLUTUAR)
-- =============================================================================

local ESP = {} -- Armazena os Drawing objects por player

-- Função para esconder TODOS os elementos de um ESP
local function HideESP(data)
    if not data then return end
    pcall(function()
        if data.BoxOut then data.BoxOut.Visible = false end
        if data.Box then data.Box.Visible = false end
        if data.Name then data.Name.Visible = false end
        if data.Dist then data.Dist.Visible = false end
        if data.HealthBg then data.HealthBg.Visible = false end
        if data.HealthBar then data.HealthBar.Visible = false end
        if data.Line then data.Line.Visible = false end
        if data.Dot then data.Dot.Visible = false end
    end)
end

-- Função para REMOVER completamente um ESP
local function RemoveESP(player)
    local data = ESP[player]
    if data then
        pcall(function()
            if data.BoxOut then data.BoxOut:Remove() end
            if data.Box then data.Box:Remove() end
            if data.Name then data.Name:Remove() end
            if data.Dist then data.Dist:Remove() end
            if data.HealthBg then data.HealthBg:Remove() end
            if data.HealthBar then data.HealthBar:Remove() end
            if data.Line then data.Line:Remove() end
            if data.Dot then data.Dot:Remove() end
        end)
        ESP[player] = nil
    end
end

-- Função para criar ESP
local function CreateESP(player)
    local data = {
        BoxOut = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Dist = Drawing.new("Text"),
        HealthBg = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        Dot = Drawing.new("Circle")
    }
    
    -- Configurar valores padrão
    data.BoxOut.Visible = false
    data.Box.Visible = false
    data.Name.Visible = false
    data.Dist.Visible = false
    data.HealthBg.Visible = false
    data.HealthBar.Visible = false
    data.Line.Visible = false
    data.Dot.Visible = false
    
    ESP[player] = data
    return data
end

-- LOOP PRINCIPAL DO ESP
RunService.RenderStepped:Connect(function()
    -- Se ESP estiver desligado, esconde TUDO
    if not Config.ESP_Main then
        for _, data in pairs(ESP) do
            HideESP(data)
        end
        return
    end
    
    Camera = workspace.CurrentCamera
    if not Camera then return end
    
    local camPos = Camera.CFrame.Position
    local screenSize = Camera.ViewportSize
    local activePlayers = {} -- Lista de players que estão ativos neste frame
    
    -- Primeiro: verifica todos os players e renderiza
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            activePlayers[player] = true -- Marca como ativo
            
            local character = player.Character
            if not character then
                -- Player sem character - ESCONDE o ESP
                if ESP[player] then HideESP(ESP[player]) end
                continue
            end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            -- Verificação rigorosa
            if not hrp or not humanoid then
                if ESP[player] then HideESP(ESP[player]) end
                continue
            end
            
            if not hrp:IsA("BasePart") or not humanoid:IsA("Humanoid") then
                if ESP[player] then HideESP(ESP[player]) end
                continue
            end
            
            if humanoid.Health <= 0 then
                -- Player morto - ESCONDE
                if ESP[player] then HideESP(ESP[player]) end
                continue
            end
            
            local distance = (camPos - hrp.Position).Magnitude
            
            -- Verifica se está dentro do range
            if distance > Config.ESP_RangeStuds then
                if ESP[player] then HideESP(ESP[player]) end
                continue
            end
            
            -- Verifica se está na tela
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if not onScreen or screenPos.Z <= 0 then
                if ESP[player] then HideESP(ESP[player]) end
                continue
            end
            
            -- Se chegou aqui, o player é válido e visível
            if not ESP[player] then
                CreateESP(player)
            end
            
            local data = ESP[player]
            
            -- Calcular tamanho da box
            local factor = 45
            local sx = math.clamp((1000 / distance) * (factor / 45), 5, 110)
            local sy = math.clamp((1600 / distance) * (factor / 45), 8, 190)
            local px = screenPos.X - sx / 2
            local py = screenPos.Y - sy / 2
            local meters = math.floor(distance * 0.28 + 0.5)
            
            -- BOX
            if Config.ESP_Boxes then
                data.BoxOut.Position = Vector2.new(px - 1, py - 1)
                data.BoxOut.Size = Vector2.new(sx + 2, sy + 2)
                data.BoxOut.Color = Color3.fromRGB(0, 0, 0)
                data.BoxOut.Thickness = 3
                data.BoxOut.Filled = false
                data.BoxOut.Transparency = 0.5
                data.BoxOut.Visible = true
                
                data.Box.Position = Vector2.new(px, py)
                data.Box.Size = Vector2.new(sx, sy)
                data.Box.Color = Color3.fromRGB(140, 30, 30)
                data.Box.Thickness = 1
                data.Box.Filled = false
                data.Box.Transparency = 0.6
                data.Box.Visible = true
            else
                data.BoxOut.Visible = false
                data.Box.Visible = false
            end
            
            -- NOME
            if Config.ESP_Names then
                data.Name.Text = player.Name
                data.Name.Position = Vector2.new(screenPos.X, py - 20)
                data.Name.Color = Color3.fromRGB(255, 255, 255)
                data.Name.Size = 13
                data.Name.Font = 2
                data.Name.Center = true
                data.Name.Outline = true
                data.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
                data.Name.Visible = true
            else
                data.Name.Visible = false
            end
            
            -- DISTÂNCIA
            if Config.ESP_Distance then
                local distText = meters >= 1000 and string.format("%.1fkm", meters / 1000) or meters .. "m"
                data.Dist.Text = distText
                data.Dist.Position = Vector2.new(screenPos.X, py - 8)
                data.Dist.Color = Color3.fromRGB(255, 200, 50)
                data.Dist.Size = 12
                data.Dist.Font = 2
                data.Dist.Center = true
                data.Dist.Outline = true
                data.Dist.OutlineColor = Color3.fromRGB(0, 0, 0)
                data.Dist.Visible = true
            else
                data.Dist.Visible = false
            end
            
            -- VIDA
            if Config.ESP_Health then
                local hp = humanoid.Health / math.max(humanoid.MaxHealth, 1)
                data.HealthBg.Position = Vector2.new(px - 6, py - 1)
                data.HealthBg.Size = Vector2.new(4, sy + 2)
                data.HealthBg.Color = Color3.fromRGB(10, 10, 10)
                data.HealthBg.Filled = true
                data.HealthBg.Transparency = 0.5
                data.HealthBg.Visible = true
                
                data.HealthBar.Position = Vector2.new(px - 5, py + sy - sy * hp)
                data.HealthBar.Size = Vector2.new(2, sy * hp)
                data.HealthBar.Color = Color3.fromHSV(hp * 0.33, 1, 1)
                data.HealthBar.Filled = true
                data.HealthBar.Transparency = 0.2
                data.HealthBar.Visible = true
            else
                data.HealthBg.Visible = false
                data.HealthBar.Visible = false
            end
            
            -- LINHAS
            if Config.ESP_Lines then
                data.Line.From = Vector2.new(screenSize.X / 2, screenSize.Y)
                data.Line.To = Vector2.new(screenPos.X, py + sy / 2)
                data.Line.Color = Color3.fromRGB(140, 30, 30)
                data.Line.Thickness = 1
                data.Line.Transparency = 0.4
                data.Line.Visible = true
            else
                data.Line.Visible = false
            end
            
            -- HEAD DOT
            if Config.ESP_Dot then
                local head = character:FindFirstChild("Head")
                if head then
                    local headPos = Camera:WorldToViewportPoint(head.Position)
                    data.Dot.Position = Vector2.new(headPos.X, headPos.Y)
                    data.Dot.Color = Color3.fromRGB(255, 255, 255)
                    data.Dot.Filled = true
                    data.Dot.Transparency = 0.3
                    data.Dot.Radius = 3
                    data.Dot.Visible = true
                else
                    data.Dot.Visible = false
                end
            else
                data.Dot.Visible = false
            end
        end
    end
    
    -- SEGUNDO: Remove ESP de players que SAÍRAM do jogo
    for player, data in pairs(ESP) do
        if not activePlayers[player] then
            -- Player não está mais no jogo - REMOVE completamente
            RemoveESP(player)
        end
    end
end)

-- LIMPEZA quando player sai
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- =============================================================================
-- 12. AIMBOT
-- =============================================================================

local function GetClosestPlayer()
    local closest = nil
    local shortest = Config.AIM_FOV
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pc = p.Character
            if pc then
                if Config.AIM_TeamCheck and p.Team == LocalPlayer.Team then continue end
                
                local part = pc:FindFirstChild("Head")
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
