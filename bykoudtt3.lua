-- =============================================================================
-- OBSIDIAN ESP - BIBLIOTECA BALRIGHT (ORIGINAL)
-- =============================================================================

-- CARREGANDO A BIBLIOTECA ORIGINAL COMPLETA (Link corrigido)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sametexe001/sametlibs/refs/heads/main/Arcane/Library%2BExample.lua"))()

-- ============================================
-- VARIÁVEIS GLOBAIS
-- ============================================
_G.Settings_ESP = {
    Enabled = false,
    Box = true,
    Name = true,
    Distance = false,
    Health = true,
    Tracer = true,
    Skeleton = false,
    TeamCheck = true,
    Corpses = false,
    MaxDistance = 10000,
    VisibilityCheck = true,
    Scale = 100,
    DangerColor = Color3.fromRGB(255, 60, 60),
    SafeColor = Color3.fromRGB(130, 255, 130),
    VisibleColor = Color3.fromRGB(220, 220, 220),
}

_G.Aimbot = {
    Enabled = false,
    FOV = 120,
    Mode = "Cabeça (Head)",
    CircleEnabled = true,
}

-- ============================================
-- CRIAÇÃO DA JANELA E CATEGORIAS
-- ============================================
local Window = Library:Window({
    Name = "Obsidian ESP",
    SubTitle = "New UI",
    ExpiresIn = "Forever"
})

Window:Category("Cheats")
local ESPPage = Window:Page({ Name = "ESP Configuration", Icon = "136879043989014" })
local AimbotPage = Window:Page({ Name = "Aimbot", Icon = "136879043989014" })

Window:Category("Utilities")
local TeleportPage = Window:Page({ Name = "Teleports", Icon = "136879043989014" })

-- ============================================
-- ABA: ESP CONFIGURATION
-- ============================================
local ESPSub = ESPPage:SubPage({ Name = "ESP Config" })
local VisualSub = ESPPage:SubPage({ Name = "Visuals" })

-- Configurações Principais
local ESPGroup = ESPSub:Section({ Name = "ESP Configuration", Icon = "136879043989014", Side = 1 })
ESPGroup:Toggle({
    Name = "Ligar ESP",
    Flag = "ESP_Enabled",
    Default = false,
    Callback = function(Value)
        _G.Settings_ESP.Enabled = Value
        if not Value then clearAllESP() end
        manageCorpseConnection()
    end
})
ESPGroup:Toggle({ Name = "Caixa", Flag = "ESP_Box", Default = true, Callback = function(v) _G.Settings_ESP.Box = v end })
ESPGroup:Toggle({ Name = "Nome", Flag = "ESP_Name", Default = true, Callback = function(v) _G.Settings_ESP.Name = v end })
ESPGroup:Toggle({ Name = "Distância", Flag = "ESP_Distance", Default = false, Callback = function(v) _G.Settings_ESP.Distance = v end })
ESPGroup:Toggle({ Name = "Barra de Vida", Flag = "ESP_Health", Default = true, Callback = function(v) _G.Settings_ESP.Health = v end })
ESPGroup:Toggle({ Name = "Linha (Tracer)", Flag = "ESP_Tracer", Default = true, Callback = function(v) _G.Settings_ESP.Tracer = v end })
ESPGroup:Toggle({ Name = "Check de Time", Flag = "ESP_TeamCheck", Default = true, Callback = function(v) _G.Settings_ESP.TeamCheck = v end })
ESPGroup:Toggle({ Name = "Skeleton ESP (Bones)", Flag = "ESP_Skeleton", Default = false, Callback = function(v) _G.Settings_ESP.Skeleton = v end })
ESPGroup:Toggle({ Name = "Corpos Deads (Chams)", Flag = "ESP_Corpses", Default = false, Callback = function(v)
    _G.Settings_ESP.Corpses = v
    manageCorpseConnection()
end })

-- Configurações Visuais
local VisualGroup = VisualSub:Section({ Name = "Visual Settings", Icon = "136879043989014", Side = 1 })
VisualGroup:Slider({
    Name = "Distância Máxima",
    Flag = "ESP_MaxDistance",
    Default = 10000,
    Min = 500,
    Max = 500000,
    Suffix = "m",
    Callback = function(Value) _G.Settings_ESP.MaxDistance = Value end
})
VisualGroup:Slider({
    Name = "Escala do ESP",
    Flag = "ESP_Scale",
    Default = 100,
    Min = 0,
    Max = 200,
    Suffix = "%",
    Callback = function(Value) _G.Settings_ESP.Scale = Value end
})
VisualGroup:Label("Cor do Inimigo"):Colorpicker({
    Flag = "ESP_DangerColor",
    Default = _G.Settings_ESP.DangerColor,
    Callback = function(Value) _G.Settings_ESP.DangerColor = Value end
})
VisualGroup:Label("Cor do Visível"):Colorpicker({
    Flag = "ESP_VisibleColor",
    Default = _G.Settings_ESP.VisibleColor,
    Callback = function(Value) _G.Settings_ESP.VisibleColor = Value end
})
VisualGroup:Label("Cor do Aliado"):Colorpicker({
    Flag = "ESP_SafeColor",
    Default = _G.Settings_ESP.SafeColor,
    Callback = function(Value) _G.Settings_ESP.SafeColor = Value end
})
VisualGroup:Toggle({ Name = "Check de Visibilidade (Raycast)", Flag = "ESP_VisibilityCheck", Default = true, Callback = function(v) _G.Settings_ESP.VisibilityCheck = v end })

-- ============================================
-- ABA: TELEPORTS
-- ============================================
local TeleportSub = TeleportPage:SubPage({ Name = "Locais" })
local HospitalSection = TeleportSub:Section({ Name = "🏥 Hospitais", Icon = "136879043989014", Side = 1 })
local MilitarySection = TeleportSub:Section({ Name = "⚔️ Militares", Icon = "136879043989014", Side = 1 })
local CitySection = TeleportSub:Section({ Name = "🏙️ Cidades", Icon = "136879043989014", Side = 1 })

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function teleportTo(posX, posY, posZ)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(posX, posY, posZ)
        Library:Notification("Teleport", 2, nil)
    else
        Library:Notification("Erro: Personagem não encontrado.", 2, nil)
    end
end

HospitalSection:Button({ Name = "🏥 Hospital Central", Callback = function() teleportTo(-2178.95, 173.73 + 3.5, 4970.18) end })
MilitarySection:Button({ Name = "🛰️ Satélite", Callback = function() teleportTo(-2009.40, 349.97 + 3.5, 897.70) end })
MilitarySection:Button({ Name = "🚨 PD (Policia)", Callback = function() teleportTo(4643.18, 121.35 + 3.5, -1044.83) end })
MilitarySection:Button({ Name = "🛡️ Bunker", Callback = function() teleportTo(5327.28, 128.99 + 3.5, -5802.90) end })
CitySection:Button({ Name = "⛓️ Prisão", Callback = function() teleportTo(5166.66, 116.43 + 3.5, -3402.79) end })
CitySection:Button({ Name = "🏪 Big Spot", Callback = function() teleportTo(1765.86, 241.35 + 3.5, 1452.03) end })

-- ============================================
-- ABA: AIMBOT
-- ============================================
local AimbotSub = AimbotPage:SubPage({ Name = "Aimbot" })
local AimbotGroup = AimbotSub:Section({ Name = "Configurações", Icon = "136879043989014", Side = 1 })

-- Círculo de FOV
local CircleGui = Instance.new("ScreenGui")
CircleGui.Name = "FOVCircle_" .. math.random(10000, 99999)
CircleGui.ResetOnSpawn = false
CircleGui.IgnoreGuiInset = true
CircleGui.DisplayOrder = 100
CircleGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local CircleFrame = Instance.new("Frame")
CircleFrame.Name = "Circle"
CircleFrame.BackgroundTransparency = 1
CircleFrame.BorderSizePixel = 1
CircleFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
CircleFrame.Visible = false
CircleFrame.Parent = CircleGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = CircleFrame

local function UpdateFOVCircle()
    if not _G.Aimbot.CircleEnabled then CircleFrame.Visible = false return end
    local vpSize = Camera.ViewportSize
    local fov = _G.Aimbot.FOV
    local radius = math.clamp(fov * 3, 20, vpSize.Y / 1.5)
    CircleFrame.Position = UDim2.new(0.5, -radius, 0.5, -radius)
    CircleFrame.Size = UDim2.new(0, radius*2, 0, radius*2)
    CircleFrame.Visible = true
end

AimbotGroup:Toggle({ Name = "Ativar Aimbot (Snap)", Flag = "Aimbot_Enabled", Default = false, Callback = function(v) _G.Aimbot.Enabled = v end })
AimbotGroup:Slider({ Name = "Campo de Visão (FOV)", Flag = "Aimbot_FOV", Default = 120, Min = 20, Max = 180, Suffix = "°", Callback = function(v) _G.Aimbot.FOV = v; UpdateFOVCircle() end })
AimbotGroup:Dropdown({ Name = "Alvo Preferido", Flag = "Aimbot_Mode", Items = { "Cabeça (Head)", "Torso (Body)" }, Default = "Cabeça (Head)", Callback = function(v) _G.Aimbot.Mode = v end })
AimbotGroup:Toggle({ Name = "Mostrar Círculo de FOV", Flag = "Aimbot_Circle", Default = true, Callback = function(v) _G.Aimbot.CircleEnabled = v; UpdateFOVCircle() end })

-- ============================================
-- LÓGICA DO ESP, ESQUELETO E CORPOS (MANTIDA)
-- ============================================
local espElements = {}
local ESP_GUI = nil
local espConnection = nil
local frameCounter = 0
local corpseCache = {}
local corpseConnection = nil
local corpseFrameCounter = 0
local skeletonCache = {}

local function isPlayerVisible(targetPos, ignoreList)
    if not _G.Settings_ESP.VisibilityCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = ignoreList
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    return workspace:Raycast(origin, direction * distance, params) == nil
end

local function isPlayerAlly(player)
    if not _G.Settings_ESP.TeamCheck then return false end
    return player.TeamColor == LocalPlayer.TeamColor
end

local function getMasterGUI()
    if ESP_GUI then return ESP_GUI end
    ESP_GUI = Instance.new("ScreenGui")
    ESP_GUI.Name = "ESP_Minimal"
    ESP_GUI.ResetOnSpawn = false
    ESP_GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ESP_GUI.IgnoreGuiInset = true
    ESP_GUI.DisplayOrder = 999999
    local success = pcall(function() ESP_GUI.Parent = game:GetService("CoreGui") end)
    if not success then ESP_GUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    return ESP_GUI
end

function createESPForPlayer(player)
    if espElements[player] then return end
    local gui = getMasterGUI()
    local folder = Instance.new("Folder")
    folder.Name = player.UserId
    folder.Parent = gui

    local box = Instance.new("Frame")
    box.Name = "Box"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Size = UDim2.new(0, 100, 0, 100)
    box.Visible = false
    box.Parent = folder

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Name = "Stroke"
    boxStroke.Thickness = 1.2
    boxStroke.Color = Color3.new(1,1,1)
    boxStroke.Transparency = 0.2
    boxStroke.Parent = box

    local tracer = Instance.new("Frame")
    tracer.Name = "Tracer"
    tracer.BackgroundColor3 = Color3.new(1,1,1)
    tracer.BorderSizePixel = 0
    tracer.Size = UDim2.new(0, 1, 0, 1)
    tracer.Visible = false
    tracer.Parent = folder

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextStrokeTransparency = 0.8
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Visible = false
    nameLabel.Parent = folder

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "Distance"
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(180,180,180)
    distLabel.TextSize = 11
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextStrokeTransparency = 0.8
    distLabel.TextStrokeColor3 = Color3.new(0,0,0)
    distLabel.TextXAlignment = Enum.TextXAlignment.Center
    distLabel.Visible = false
    distLabel.Parent = folder

    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.BackgroundColor3 = Color3.fromRGB(0,255,0)
    healthBar.BorderSizePixel = 0
    healthBar.Size = UDim2.new(0, 2, 0, 100)
    healthBar.Visible = false
    healthBar.Parent = folder

    local healthBg = Instance.new("Frame")
    healthBg.Name = "HealthBg"
    healthBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
    healthBg.BorderSizePixel = 0
    healthBg.Size = UDim2.new(0, 2, 0, 100)
    healthBg.Visible = false
    healthBg.Parent = folder

    espElements[player] = { Folder = folder, Box = box, BoxStroke = boxStroke, Tracer = tracer, Name = nameLabel, Distance = distLabel, HealthBar = healthBar, HealthBg = healthBg }
end

local function hidePlayerESP(elements)
    if not elements then return end
    elements.Box.Visible = false
    elements.Tracer.Visible = false
    elements.Name.Visible = false
    elements.Distance.Visible = false
    elements.HealthBar.Visible = false
    elements.HealthBg.Visible = false
end

function clearAllESP()
    for player, elements in pairs(espElements) do
        if elements.Folder then elements.Folder:Destroy() end
        espElements[player] = nil
    end
    if ESP_GUI then ESP_GUI:Destroy(); ESP_GUI = nil end
    for corpse, highlight in pairs(corpseCache) do if highlight then highlight:Destroy() end end
    corpseCache = {}
    for player, data in pairs(skeletonCache) do
        for _, line in pairs(data) do if type(line) == "table" and line.Remove then line:Remove() end end
        skeletonCache[player] = nil
    end
end

Players.PlayerRemoving:Connect(function(player)
    if espElements[player] then espElements[player].Folder:Destroy(); espElements[player] = nil end
    if skeletonCache[player] then
        for _, line in pairs(skeletonCache[player]) do if type(line) == "table" and line.Remove then line:Remove() end end
        skeletonCache[player] = nil
    end
end)

-- ============================================
-- SISTEMA DE SKELETON ESP
-- ============================================
local function createSkeletonForPlayer(player)
    local data = { HeadTorso = Drawing.new("Line"), TorsoLegs = Drawing.new("Line"), ArmL = Drawing.new("Line"), ArmR = Drawing.new("Line"), LegL = Drawing.new("Line"), LegR = Drawing.new("Line") }
    for _, line in pairs(data) do line.Thickness = 2; line.Transparency = 0.3; line.Visible = false end
    skeletonCache[player] = data
    return data
end

local function updateSkeleton(player, camera, espColor)
    local data = skeletonCache[player] or createSkeletonForPlayer(player)
    local char = player.Character
    if not char then
        for _, line in pairs(data) do line.Visible = false end
        return
    end
    local head = char:FindFirstChild("Head", true)
    local upperTorso = char:FindFirstChild("UpperTorso", true) or char:FindFirstChild("Torso", true)
    local lowerTorso = char:FindFirstChild("LowerTorso", true)
    local leftArm = char:FindFirstChild("LeftArm", true) or char:FindFirstChild("Left Arm", true)
    local rightArm = char:FindFirstChild("RightArm", true) or char:FindFirstChild("Right Arm", true)
    local leftLeg = char:FindFirstChild("LeftLeg", true) or char:FindFirstChild("Left Leg", true)
    local rightLeg = char:FindFirstChild("RightLeg", true) or char:FindFirstChild("Right Leg", true)

    local function getScreenPos(part)
        if part and part:IsA("BasePart") then
            local pos, onScreen = camera:WorldToViewportPoint(part.Position)
            if onScreen and pos.Z > 0 then return Vector2.new(pos.X, pos.Y) end
        end
        return nil
    end
    local headPos, upperPos, lowerPos, armLPos, armRPos, legLPos, legRPos = getScreenPos(head), getScreenPos(upperTorso), getScreenPos(lowerTorso), getScreenPos(leftArm), getScreenPos(rightArm), getScreenPos(leftLeg), getScreenPos(rightLeg)
    local function updateLine(line, p1, p2) if line and p1 and p2 then line.From = p1; line.To = p2; line.Color = espColor; line.Visible = true elseif line then line.Visible = false end end
    updateLine(data.HeadTorso, headPos, upperPos)
    if lowerTorso and lowerPos then updateLine(data.TorsoLegs, upperPos, lowerPos); updateLine(data.LegL, lowerPos, legLPos); updateLine(data.LegR, lowerPos, legRPos)
    else updateLine(data.TorsoLegs, upperPos, legLPos); updateLine(data.LegL, upperPos, legLPos); updateLine(data.LegR, upperPos, legRPos) end
    updateLine(data.ArmL, upperPos, armLPos); updateLine(data.ArmR, upperPos, armRPos)
end

-- ============================================
-- LOOP DE ATUALIZAÇÃO DO ESP (MANTIDO)
-- ============================================
local function updateESP()
    if not _G.Settings_ESP.Enabled then return end
    frameCounter = frameCounter + 1
    if frameCounter % 2 ~= 0 then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local localChar = LocalPlayer.Character
    if not localChar then return end
    local cameraPos = camera.CFrame.Position
    local maxDist = _G.Settings_ESP.MaxDistance
    local maxDistBuffer = maxDist + 50
    local scaleFactor = _G.Settings_ESP.Scale / 100

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local character = player.Character
        if not character then if espElements[player] then hidePlayerESP(espElements[player]) end continue end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        local humanoid = character:FindFirstChild("Humanoid")
        if not (hrp and head and humanoid) or humanoid.Health <= 0 then if espElements[player] then hidePlayerESP(espElements[player]) end continue end
        local distance = (cameraPos - hrp.Position).Magnitude
        if distance > maxDistBuffer then if espElements[player] then hidePlayerESP(espElements[player]) end continue end
        local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if not onScreen or pos.Z <= 0 then if espElements[player] then hidePlayerESP(espElements[player]) end continue end

        if not espElements[player] then createESPForPlayer(player) end
        local el = espElements[player]
        if not el then continue end

        local espColor
        if isPlayerAlly(player) then espColor = _G.Settings_ESP.SafeColor
        else local visible = isPlayerVisible(hrp.Position, {localChar, character}); espColor = visible and _G.Settings_ESP.VisibleColor or _G.Settings_ESP.DangerColor end

        local topPos, topOn = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
        local bottomPos, botOn = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        if not topOn or not botOn then hidePlayerESP(el); continue end
        local rawHeight = math.abs(topPos.Y - bottomPos.Y)
        local scaledHeight = math.clamp(rawHeight * scaleFactor, 5, 500)
        local width = scaledHeight * 0.45
        local posX = pos.X - width/2
        local posY = topPos.Y - 2

        if _G.Settings_ESP.Box then el.Box.Position = UDim2.new(0, posX, 0, posY); el.Box.Size = UDim2.new(0, width, 0, scaledHeight); el.BoxStroke.Color = espColor; el.Box.Visible = true else el.Box.Visible = false end
        if _G.Settings_ESP.Tracer then
            local cx, cy = camera.ViewportSize.X/2, camera.ViewportSize.Y/2
            local dx, dy = pos.X - cx, pos.Y - cy
            local length = math.sqrt(dx*dx + dy*dy)
            el.Tracer.Position = UDim2.new(0, cx, 0, cy); el.Tracer.Size = UDim2.new(0, length, 0, 1 * scaleFactor); el.Tracer.Rotation = math.deg(math.atan2(dy, dx)); el.Tracer.BackgroundColor3 = espColor; el.Tracer.BackgroundTransparency = 0.4; el.Tracer.Visible = true
        else el.Tracer.Visible = false end
        if _G.Settings_ESP.Name then el.Name.Text = player.Name; local fs = math.clamp(scaledHeight * 0.13, 10, 18); el.Name.TextSize = fs; el.Name.Position = UDim2.new(0, pos.X - 100, 0, topPos.Y - fs - 4); el.Name.Size = UDim2.new(0, 200, 0, fs + 4); el.Name.TextColor3 = espColor; el.Name.Visible = true else el.Name.Visible = false end
        if _G.Settings_ESP.Distance then el.Distance.Text = math.floor(distance) .. "m"; local fs = math.clamp(scaledHeight * 0.10, 10, 14); el.Distance.TextSize = fs; el.Distance.Position = UDim2.new(0, pos.X - 100, 0, bottomPos.Y + 4); el.Distance.Size = UDim2.new(0, 200, 0, fs + 4); el.Distance.TextColor3 = Color3.fromRGB(180,180,180); el.Distance.Visible = true else el.Distance.Visible = false end
        if _G.Settings_ESP.Health then
            local pct = humanoid.Health / humanoid.MaxHealth
            local bw = 2 * scaleFactor
            local bx = posX + width + (4 * scaleFactor)
            el.HealthBg.Position = UDim2.new(0, bx, 0, posY); el.HealthBg.Size = UDim2.new(0, bw, 0, scaledHeight); el.HealthBg.Visible = true
            local fh = scaledHeight * pct
            el.HealthBar.Position = UDim2.new(0, bx, 0, posY + scaledHeight - fh); el.HealthBar.Size = UDim2.new(0, bw, 0, fh); el.HealthBar.BackgroundColor3 = Color3.fromHSV(pct * 0.33, 1, 1); el.HealthBar.Visible = true
        else el.HealthBar.Visible = false; el.HealthBg.Visible = false end
        if _G.Settings_ESP.Skeleton then updateSkeleton(player, camera, espColor)
        else local s = skeletonCache[player]; if s then for _, l in pairs(s) do if type(l) == "table" then l.Visible = false end end end end
    end
end
espConnection = RunService.RenderStepped:Connect(updateESP)

-- ============================================
-- SISTEMA DE CHAMS PARA CORPOS (MANTIDO)
-- ============================================
local function updateCorpseESP()
    if not _G.Settings_ESP.Enabled or not _G.Settings_ESP.Corpses then return end
    corpseFrameCounter = corpseFrameCounter + 1
    if corpseFrameCounter % 30 ~= 0 then return end
    local f = workspace:FindFirstChild("Corpses")
    if not f then for c, h in pairs(corpseCache) do h:Destroy(); corpseCache[c] = nil end return end
    local current = {}
    for _, child in ipairs(f:GetChildren()) do
        if child:IsA("Model") or child:IsA("Folder") then
            for _, part in ipairs(child:GetDescendants()) do
                if part:IsA("BasePart") and (part.Name == "Head" or part.Name == "Head2" or part.Name == "HumanoidRootPart" or part.Name == "Body") then table.insert(current, child); break end
            end
        end
    end
    for c, h in pairs(corpseCache) do if not c.Parent or not table.find(current, c) then h:Destroy(); corpseCache[c] = nil end end
    for _, c in ipairs(current) do if not corpseCache[c] then local h = Instance.new("Highlight"); h.FillColor = Color3.fromRGB(170, 0, 255); h.OutlineColor = Color3.fromRGB(255, 255, 255); h.FillTransparency = 0.8; h.OutlineTransparency = 0; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = c; corpseCache[c] = h end end
end
function manageCorpseConnection()
    if _G.Settings_ESP.Corpses and _G.Settings_ESP.Enabled then
        if not corpseConnection then corpseConnection = RunService.Heartbeat:Connect(updateCorpseESP) end
    else
        if corpseConnection then corpseConnection:Disconnect(); corpseConnection = nil; for c, h in pairs(corpseCache) do if h then h:Destroy() end end; corpseCache = {} end
    end
end

-- ============================================
-- BACKEND DO AIMBOT (MANTIDO)
-- ============================================
local function getAimbotTarget()
    if not _G.Aimbot.Enabled then return nil end
    local closestTarget, closestDist = nil, _G.Aimbot.FOV
    local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local hrp = p.Character.HumanoidRootPart
            local sp, os = Camera:WorldToViewportPoint(hrp.Position)
            if os and sp.Z > 0 then
                local d = math.sqrt((sp.X-cx)^2 + (sp.Y-cy)^2)
                if d < closestDist and isPlayerVisible(hrp.Position, {LocalPlayer.Character, p.Character}) then closestDist = d; closestTarget = p end
            end
        end
    end
    return closestTarget
end
UserInputService.InputBegan:Connect(function(i, p)
    if p or i.UserInputType ~= Enum.UserInputType.MouseButton1 or not _G.Aimbot.Enabled then return end
    local t = getAimbotTarget()
    if t and t.Character then
        local part = t.Character:FindFirstChild(_G.Aimbot.Mode == "Cabeça (Head)" and "Head" or "HumanoidRootPart") or t.Character:FindFirstChild("Torso")
        if part then local orig = Camera.CFrame; Camera.CFrame = CFrame.new(orig.Position, part.Position); RunService.RenderStepped:Wait(); Camera.CFrame = orig; Library:Notification("Aimbot", 1, nil) end
    end
end)

-- ============================================
-- CRIAÇÃO DA PÁGINA DE CONFIGURAÇÕES (Settings)
-- ============================================
local SettingsPage = Library:CreateSettingsPage(Window)
local SettingsSub = SettingsPage:SubPage({ Name = "UI Settings" })
local SettingsSection = SettingsSub:Section({ Name = "Configurações", Icon = "136879043989014", Side = 1 })
SettingsSection:Button({ Name = "Unload Safely", Callback = function()
    clearAllESP(); if corpseConnection then corpseConnection:Disconnect(); corpseConnection = nil end; _G.Settings_ESP.Enabled = false; _G.Aimbot.Enabled = false; CircleGui:Destroy(); Library:Unload()
end})

-- ============================================
-- FINALIZAÇÃO
-- ============================================
task.wait(0.5)
UpdateFOVCircle()
Library:Notification("Obsidian ESP Carregado!", 6, nil)
