-- ============================================================
-- OBSIDIAN ULTRA - CORRIGIDO PARA SUA ESTRUTURA DE PASTAS
-- ============================================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Obsidian Dev Tools",
    Footer = "v3.3 - Estrutura Corrigida",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    ESP = Window:AddTab("ESP", "eye"),
    Misc = Window:AddTab("Misc", "settings"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local ESPGroup = Tabs.ESP:AddLeftGroupbox("ESP Configuration", "eye")

ESPGroup:AddToggle("ESP_Enabled", {
    Text = "Enable ESP (Players Only)",
    Default = false,
    Tooltip = "Ativa o ESP para jogadores (ignora zumbis/bots)",
})
Toggles.ESP_Enabled:OnChanged(function()
    _G.ESP_Enabled = Toggles.ESP_Enabled.Value
    if not _G.ESP_Enabled then clearAllESP() end
end)

ESPGroup:AddToggle("ESP_Box", {
    Text = "Box ESP (ViewportFrame)",
    Default = true,
})
Toggles.ESP_Box:OnChanged(function() _G.ESP_Box = Toggles.ESP_Box.Value end)

ESPGroup:AddToggle("ESP_Line", {
    Text = "Line ESP",
    Default = true,
})
Toggles.ESP_Line:OnChanged(function() _G.ESP_Line = Toggles.ESP_Line.Value end)

ESPGroup:AddToggle("ESP_Name", {
    Text = "Name ESP",
    Default = true,
})
Toggles.ESP_Name:OnChanged(function() _G.ESP_Name = Toggles.ESP_Name.Value end)

ESPGroup:AddToggle("ESP_Distance", {
    Text = "Distance ESP",
    Default = true,
})
Toggles.ESP_Distance:OnChanged(function() _G.ESP_Distance = Toggles.ESP_Distance.Value end)

ESPGroup:AddToggle("ESP_Health", {
    Text = "Health Bar",
    Default = true,
})
Toggles.ESP_Health:OnChanged(function() _G.ESP_Health = Toggles.ESP_Health.Value end)

ESPGroup:AddSlider("ESP_MaxDistance", {
    Text = "Max Distance",
    Default = 500,
    Min = 50,
    Max = 100000,
    Rounding = 0,
    Suffix = " studs",
})
Options.ESP_MaxDistance:OnChanged(function() _G.ESP_MaxDistance = Options.ESP_MaxDistance.Value end)

ESPGroup:AddSlider("ESP_BoxSize", {
    Text = "Box Size",
    Default = 4,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Suffix = "x",
})
Options.ESP_BoxSize:OnChanged(function() _G.ESP_BoxSize = Options.ESP_BoxSize.Value end)

ESPGroup:AddLabel("ESP Color"):AddColorPicker("ESP_Color", {
    Default = Color3.new(1, 0, 0),
    Title = "ESP Color",
    Transparency = 0,
})
Options.ESP_Color:OnChanged(function() _G.ESP_Color = Options.ESP_Color.Value end)

-- ============================================================
-- SISTEMA DE ESP (BACKEND)
-- ============================================================

local ESP_Objects = {}
local ESP_GUI = nil
local espLoopRunning = false

_G.ESP_Enabled = false
_G.ESP_Box = true
_G.ESP_Line = true
_G.ESP_Name = true
_G.ESP_Distance = true
_G.ESP_Health = true
_G.ESP_MaxDistance = 500
_G.ESP_BoxSize = 4
_G.ESP_Color = Color3.new(1, 0, 0)

local function createSecureGUI()
    if ESP_GUI then return ESP_GUI end
    
    ESP_GUI = Instance.new("ScreenGui")
    ESP_GUI.Name = "ObsidianESP_" .. math.random(100000, 999999)
    ESP_GUI.IgnoreGuiInset = true
    ESP_GUI.ScreenInsets = Enum.ScreenInsets.None
    ESP_GUI.DisplayOrder = 999999
    ESP_GUI.ResetOnSpawn = false
    ESP_GUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    
    local success = pcall(function()
        ESP_GUI.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        ESP_GUI.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    return ESP_GUI
end

local function createViewportFrame(parent)
    local frame = Instance.new("ViewportFrame")
    frame.Name = "ESP_" .. math.random(10000, 99999)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, 100, 0, 100)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.Parent = parent
    
    local canvas = Instance.new("CanvasGroup")
    canvas.GroupTransparency = 0
    canvas.Size = UDim2.new(1, 0, 1, 0)
    canvas.Parent = frame
    
    for i = 1, 4 do
        local line = Instance.new("Frame")
        line.BackgroundColor3 = Color3.new(1, 0, 0)
        line.BorderSizePixel = 0
        line.Visible = true
        line.Parent = canvas
    end
    
    return frame
end

local function createESPForPlayer(player)
    if ESP_Objects[player] then return end
    
    local gui = createSecureGUI()
    if not gui then return end
    
    local espData = {
        Player = player,
        GUI = gui,
        Viewport = createViewportFrame(gui),
        Line = nil,
        NameLabel = nil,
        DistanceLabel = nil,
        HealthBar = nil,
        HealthBg = nil,
    }
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 2, 0, 2)
    line.BackgroundColor3 = Color3.new(1, 0, 0)
    line.BorderSizePixel = 0
    line.Parent = gui
    espData.Line = line
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 200, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.AnchorPoint = Vector2.new(0.5, 1)
    nameLabel.Parent = gui
    espData.NameLabel = nameLabel
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(0, 200, 0, 20)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.new(1, 1, 1)
    distLabel.TextStrokeTransparency = 0.3
    distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.AnchorPoint = Vector2.new(0.5, 0)
    distLabel.Parent = gui
    espData.DistanceLabel = distLabel
    
    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(0, 50, 0, 4)
    healthBg.BackgroundColor3 = Color3.new(0, 0, 0)
    healthBg.BackgroundTransparency = 0.5
    healthBg.BorderSizePixel = 0
    healthBg.Parent = gui
    espData.HealthBg = healthBg
    
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.new(0, 1, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBg
    espData.HealthBar = healthBar
    
    ESP_Objects[player] = espData
    return espData
end

-- ⚠️ ESSA É A PARTE QUE EU CORRIGI PARA VOCÊ
local function updateESPForPlayer(player, espData)
    if not espData or not _G.ESP_Enabled then return end
    
    local character = player.Character
    if not character then return end

    -- CORREÇÃO AQUI: Usamos FindFirstChild em toda a árvore do personagem
    -- Isso garante que ele ache o HumanoidRootPart mesmo dentro da pasta "CharacterItems"
    local rootPart = character:FindFirstChild("HumanoidRootPart", true) 
    local head = character:FindFirstChild("Head", true)
    
    if not rootPart then return end
    
    local localPlayer = game:GetService("Players").LocalPlayer
    local camera = workspace.CurrentCamera
    
    local distance = 9999
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart", true) then
        distance = (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
    end
    
    if distance > _G.ESP_MaxDistance then
        espData.Viewport.Visible = false
        espData.Line.Visible = false
        espData.NameLabel.Visible = false
        espData.DistanceLabel.Visible = false
        espData.HealthBg.Visible = false
        return
    end
    
    local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        espData.Viewport.Visible = false
        espData.Line.Visible = false
        espData.NameLabel.Visible = false
        espData.DistanceLabel.Visible = false
        espData.HealthBg.Visible = false
        return
    end
    
    -- BOX
    if _G.ESP_Box then
        local boxSize = _G.ESP_BoxSize * 3
        local topPos = camera:WorldToViewportPoint(head and head.Position or rootPart.Position + Vector3.new(0, 3, 0))
        local bottomPos = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
        
        local height = math.abs(topPos.Y - bottomPos.Y)
        local width = height * 0.6
        
        espData.Viewport.Position = UDim2.new(0, screenPos.X - width/2, 0, topPos.Y)
        espData.Viewport.Size = UDim2.new(0, width, 0, height)
        espData.Viewport.Visible = true
        
        local lines = espData.Viewport:GetChildren()[1]:GetChildren()
        if #lines >= 4 then
            lines[1].Size = UDim2.new(1, 0, 0, 1)
            lines[1].Position = UDim2.new(0, 0, 0, 0)
            lines[2].Size = UDim2.new(1, 0, 0, 1)
            lines[2].Position = UDim2.new(0, 0, 1, 0)
            lines[3].Size = UDim2.new(0, 1, 1, 0)
            lines[3].Position = UDim2.new(0, 0, 0, 0)
            lines[4].Size = UDim2.new(0, 1, 1, 0)
            lines[4].Position = UDim2.new(1, 0, 0, 0)
            
            for _, line in pairs(lines) do
                line.BackgroundColor3 = _G.ESP_Color or Color3.new(1, 0, 0)
            end
        end
    else
        espData.Viewport.Visible = false
    end
    
    -- LINE
    if _G.ESP_Line and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart", true) then
        local localPos = camera:WorldToViewportPoint(localPlayer.Character.HumanoidRootPart.Position)
        espData.Line.Size = UDim2.new(0, 2, 0, math.abs(screenPos.Y - localPos.Y))
        espData.Line.Position = UDim2.new(0, math.min(screenPos.X, localPos.X), 0, math.min(screenPos.Y, localPos.Y))
        espData.Line.Visible = true
        espData.Line.BackgroundColor3 = _G.ESP_Color or Color3.new(1, 0, 0)
    else
        espData.Line.Visible = false
    end
    
    -- NAME
    if _G.ESP_Name then
        espData.NameLabel.Text = player.Name
        espData.NameLabel.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - 25)
        espData.NameLabel.Visible = true
    else
        espData.NameLabel.Visible = false
    end
    
    -- DISTANCE
    if _G.ESP_Distance then
        espData.DistanceLabel.Text = math.floor(distance) .. " studs"
        espData.DistanceLabel.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y + 25)
        espData.DistanceLabel.Visible = true
    else
        espData.DistanceLabel.Visible = false
    end
    
    -- HEALTH
    if _G.ESP_Health and character:FindFirstChild("Humanoid", true) then
        local humanoid = character:FindFirstChild("Humanoid", true)
        if humanoid then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            
            espData.HealthBg.Position = UDim2.new(0, screenPos.X - 25, 0, screenPos.Y + 50)
            espData.HealthBg.Visible = true
            
            espData.HealthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
            espData.HealthBar.BackgroundColor3 = Color3.new(1 - healthPercent, healthPercent, 0)
        end
    else
        espData.HealthBg.Visible = false
    end
end

local function mainESPLoop()
    if espLoopRunning then return end
    espLoopRunning = true
    
    while _G.ESP_Enabled do
        task.wait(0.03)
        
        local players = game:GetService("Players"):GetPlayers()
        local localPlayer = game:GetService("Players").LocalPlayer
        
        for _, player in pairs(players) do
            if player ~= localPlayer and player:IsA("Player") then
                local espData = ESP_Objects[player]
                if not espData then
                    espData = createESPForPlayer(player)
                end
                
                if espData then
                    pcall(function()
                        updateESPForPlayer(player, espData)
                    end)
                end
            end
        end
    end
    
    espLoopRunning = false
end

local function clearAllESP()
    for player, espData in pairs(ESP_Objects) do
        if espData.GUI then
            espData.GUI:Destroy()
        end
        ESP_Objects[player] = nil
    end
    ESP_GUI = nil
end

Toggles.ESP_Enabled:OnChanged(function()
    if _G.ESP_Enabled then
        task.spawn(mainESPLoop)
    else
        clearAllESP()
    end
end)

-- ============================================================
-- UI SETTINGS E MANAGERS
-- ============================================================

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value) Library.KeybindFrame.Visible = value end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = Library.ShowCustomCursor,
    Callback = function(Value) Library.ShowCustomCursor = Value end,
})
MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value) Library:SetNotifySide(Value) end,
})
MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(Value)
        Value = Value:gsub("%%", "")
        local DPI = tonumber(Value)
        Library:SetDPIScale(DPI)
    end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift", NoUI = true, Text = "Menu keybind"
})
MenuGroup:AddButton("Unload Safely", function()
    clearAllESP()
    _G.ESP_Enabled = false
    Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Obsidian")
SaveManager:SetFolder("Obsidian/Configs")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

Library:Notify({
    Title = "Obsidian ESP - Corrigido para CharacterItems",
    Description = "✅ Agora encontra HumanoidRootPart dentro de pastas\n✅ Apenas Players\n✅ Até 10.000 studs",
    Time = 6,
})
