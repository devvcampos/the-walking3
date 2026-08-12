-- =============================================================================
-- TRAVA DE SEGURANÇA (EVITA ABRIR 2 VEZES)
-- =============================================================================
if _G.ObsidianLoaded then
    print("⚠️ Script já está em execução! Use 'Unload Safely' antes de executar novamente.")
    return
end
_G.ObsidianLoaded = true

-- =============================================================================
-- OBSIDIAN ESP - COMPLETO PARA BIBLIOTECA DO SAMET (CORRIGIDO)
-- =============================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/devvcampos/the-walking3/refs/heads/main/Library.lua"))()

-- ============================================
-- CONFIGURAÇÕES GLOBAIS
-- ============================================
_G.Settings_ESP = {
    DangerColor = Color3.fromRGB(255, 60, 60),
    SafeColor = Color3.fromRGB(130, 255, 130),
    VisibleColor = Color3.fromRGB(220, 220, 220),
}

-- ============================================
-- SERVIÇOS E UTILITÁRIOS
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espElements = {}
local ESP_GUI = nil
local espConnection = nil
local frameCounter = 0

local corpseCache = {}
local corpseConnection = nil
local corpseFrameCounter = 0
local skeletonCache = {}

local function isPlayerVisible(targetPos, ignoreList)
    if not Library.Flags["ESP_VisibilityCheck"] then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = ignoreList
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, direction * distance, params)
    return result == nil
end

local function isPlayerAlly(player)
    if not Library.Flags["ESP_TeamCheck"] then return false end
    return player.TeamColor == LocalPlayer.TeamColor
end

function clearAllESP()
    for player, elements in pairs(espElements) do
        if elements.Folder then elements.Folder:Destroy() end
        espElements[player] = nil
    end
    if ESP_GUI then ESP_GUI:Destroy(); ESP_GUI = nil end

    for corpse, highlight in pairs(corpseCache) do
        if highlight then highlight:Destroy() end
    end
    corpseCache = {}

    for player, data in pairs(skeletonCache) do
        for _, line in pairs(data) do
            if type(line) == "table" and line.Remove then
                line:Remove()
            end
        end
        skeletonCache[player] = nil
    end
end

function manageCorpseConnection()
    local enabled = Library.Flags["ESP_Enabled"]
    local corpses = Library.Flags["ESP_Corpses"]
    if enabled and corpses then
        if not corpseConnection then
            corpseConnection = RunService.Heartbeat:Connect(updateCorpseESP)
        end
    else
        if corpseConnection then
            corpseConnection:Disconnect()
            corpseConnection = nil
            for corpse, highlight in pairs(corpseCache) do
                if highlight then highlight:Destroy() end
            end
            corpseCache = {}
        end
    end
end

-- ============================================
-- JANELA PRINCIPAL
-- ============================================
local Window = Library:Window({
    Name = "KOUDZERA -- script by devvcampos",
    SubTitle = "v2.0 - Samet Lib",
    ExpiresIn = "∞"
})

-- ============================================
-- PÁGINAS E SUBPÁGINAS
-- ============================================
local ESP_Page = Window:Page({Name = "ESP", Icon = "136879043989014"})
local Visuals_Page = Window:Page({Name = "Visuals", Icon = "131595494666590"})
local Teleports_Page = Window:Page({Name = "Teleports", Icon = "97491613646216"})
local Aimbot_Page = Window:Page({Name = "Aimbot", Icon = "136879043989014"})
local Menu_Page = Window:Page({Name = "Menu", Icon = "72732892493295"})

-- Cria a página de configurações nativa (temas, arquivos, etc)
Library:CreateSettingsPage(Window)

-- ============================================
-- ABA ESP (Aqui corrigimos a falta das variáveis)
-- ============================================
local ESP_Sub = ESP_Page:SubPage({Name = "Configuration"})
local ESP_Sec = ESP_Sub:Section({Name = "ESP", Icon = "136879043989014", Side = 1})

ESP_Sec:Toggle({Name = "Ligar ESP", Flag = "ESP_Enabled", Default = false, Callback = function(v)
    if not v then clearAllESP() end
    manageCorpseConnection()
end})
ESP_Sec:Toggle({Name = "Caixa", Flag = "ESP_Box", Default = true})
ESP_Sec:Toggle({Name = "Nome", Flag = "ESP_Name", Default = true})
ESP_Sec:Toggle({Name = "Distância", Flag = "ESP_Distance", Default = false})
ESP_Sec:Toggle({Name = "Barra de Vida", Flag = "ESP_Health", Default = true})
ESP_Sec:Toggle({Name = "Linha (Tracer)", Flag = "ESP_Tracer", Default = true})
ESP_Sec:Toggle({Name = "Check de Time", Flag = "ESP_TeamCheck", Default = true})
ESP_Sec:Toggle({Name = "Skeleton ESP", Flag = "ESP_Skeleton", Default = false})
ESP_Sec:Toggle({Name = "Corpos Deads", Flag = "ESP_Corpses", Default = false, Callback = function(v)
    manageCorpseConnection()
end})

-- ============================================
-- ABA VISUALS (Cores e Sliders)
-- ============================================
local Vis_Sub = Visuals_Page:SubPage({Name = "Visual Settings"})
local Vis_SecL = Vis_Sub:Section({Name = "Ajustes", Icon = "131595494666590", Side = 1})
local Vis_SecR = Vis_Sub:Section({Name = "Cores", Icon = "131595494666590", Side = 2})

Vis_SecL:Slider({Name = "Distância Máxima", Flag = "ESP_MaxDistance", Min = 500, Max = 500000, Default = 10000, Decimals = 1, Suffix = "m"})
Vis_SecL:Slider({Name = "Escala do ESP", Flag = "ESP_Scale", Min = 0, Max = 200, Default = 100, Decimals = 1, Suffix = "%"})
Vis_SecL:Toggle({Name = "Check de Visibilidade", Flag = "ESP_VisibilityCheck", Default = true})

Vis_SecR:Label("Cor do Inimigo"):Colorpicker({Flag = "ESP_DangerColor", Default = _G.Settings_ESP.DangerColor, Callback = function(v) _G.Settings_ESP.DangerColor = v end})
Vis_SecR:Label("Cor do Visível"):Colorpicker({Flag = "ESP_VisibleColor", Default = _G.Settings_ESP.VisibleColor, Callback = function(v) _G.Settings_ESP.VisibleColor = v end})
Vis_SecR:Label("Cor do Aliado"):Colorpicker({Flag = "ESP_SafeColor", Default = _G.Settings_ESP.SafeColor, Callback = function(v) _G.Settings_ESP.SafeColor = v end})

-- ============================================
-- ABA TELEPORTS
-- ============================================
local Tel_Sub = Teleports_Page:SubPage({Name = "Locations"})
local Tel_Sec = Tel_Sub:Section({Name = "Teleports", Icon = "97491613646216", Side = 1})

local function teleportTo(x, y, z)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
        Library:Notification("Teleportado!", 2, nil)
    else
        Library:Notification("Personagem não encontrado.", 2, nil)
    end
end

Tel_Sec:Button({Name = "🏥 Hospital Central", Callback = function() teleportTo(-2178.95, 173.73+3.5, 4970.18) end})
Tel_Sec:Button({Name = "🛰️ Satélite", Callback = function() teleportTo(-2009.40, 349.97+3.5, 897.70) end})
Tel_Sec:Button({Name = "🚨 PD (Policia)", Callback = function() teleportTo(4643.18, 121.35+3.5, -1044.83) end})
Tel_Sec:Button({Name = "🛡️ Bunker", Callback = function() teleportTo(5327.28, 128.99+3.5, -5802.90) end})
Tel_Sec:Button({Name = "⛓️ Prisão", Callback = function() teleportTo(5166.66, 116.43+3.5, -3402.79) end})
Tel_Sec:Button({Name = "🏪 Big Spot", Callback = function() teleportTo(1765.86, 241.35+3.5, 1452.03) end})

-- ============================================
-- CÍRCULO DE FOV (MOVIDO PARA CÁ - ANTES DO AIMBOT)
-- ============================================
local CircleGui = Instance.new("ScreenGui")
CircleGui.Name = "FOVCircle"
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

function UpdateFOVCircle()
    if not Library.Flags["Aimbot_Circle"] then CircleFrame.Visible = false return end
    local vpSize = workspace.CurrentCamera.ViewportSize
    local fov = Library.Flags["Aimbot_FOV"] or 120
    local radius = math.clamp(fov * 3, 20, vpSize.Y / 1.5)
    CircleFrame.Position = UDim2.new(0.5, -radius, 0.5, -radius)
    CircleFrame.Size = UDim2.new(0, radius*2, 0, radius*2)
    CircleFrame.Visible = true
end

-- ============================================
-- ABA AIMBOT (AGORA A FUNÇÃO JÁ EXISTE!)
-- ============================================
local Aim_Sub = Aimbot_Page:SubPage({Name = "Aimbot"})
local Aim_Sec = Aim_Sub:Section({Name = "Configurações", Icon = "136879043989014", Side = 1})

Aim_Sec:Toggle({Name = "Ativar Aimbot (Snap)", Flag = "Aimbot_Enabled", Default = false})
Aim_Sec:Slider({Name = "Campo de Visão (FOV)", Flag = "Aimbot_FOV", Min = 20, Max = 180, Default = 120, Decimals = 1, Suffix = "°"})
    UpdateFOVCircle()

Aim_Sec:Dropdown({Name = "Alvo Preferido", Flag = "Aimbot_Mode", Items = {"Cabeça (Head)", "Torso (Body)"}, Default = "Cabeça (Head)", Multi = false})
Aim_Sec:Toggle({Name = "Mostrar Círculo de FOV", Flag = "Aimbot_Circle", Default = true, Callback = function(v)
    UpdateFOVCircle()
end})

-- ============================================
-- ABA MENU
-- ============================================
local Menu_Sub = Menu_Page:SubPage({Name = "Principal"})
local Menu_Sec = Menu_Sub:Section({Name = "Opções", Icon = "72732892493295", Side = 1})
Menu_Sec:Button({Name = "Unload Safely", Callback = function()
    clearAllESP()
    if CircleGui then CircleGui:Destroy() end
    _G.ObsidianLoaded = nil
    Library:Unload()
end})

-- ============================================
-- LÓGICA DO ESP
-- ============================================
local getMasterGUI = function()
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

    espElements[player] = {
        Folder = folder,
        Box = box,
        BoxStroke = boxStroke,
        Tracer = tracer,
        Name = nameLabel,
        Distance = distLabel,
        HealthBar = healthBar,
        HealthBg = healthBg,
    }
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

-- Skeleton ESP
local function createSkeletonForPlayer(player)
    local data = {
        HeadTorso = Drawing.new("Line"),
        TorsoLegs = Drawing.new("Line"),
        ArmL = Drawing.new("Line"),
        ArmR = Drawing.new("Line"),
        LegL = Drawing.new("Line"),
        LegR = Drawing.new("Line")
    }
    for _, line in pairs(data) do
        line.Thickness = 2
        line.Transparency = 0.3
        line.Visible = false
    end
    skeletonCache[player] = data
    return data
end

local function updateSkeleton(player, camera, espColor)
    local data = skeletonCache[player]
    if not data then data = createSkeletonForPlayer(player) end

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

    local headPos = getScreenPos(head)
    local upperPos = getScreenPos(upperTorso)
    local lowerPos = getScreenPos(lowerTorso)
    local armLPos = getScreenPos(leftArm)
    local armRPos = getScreenPos(rightArm)
    local legLPos = getScreenPos(leftLeg)
    local legRPos = getScreenPos(rightLeg)

    local function updateLine(line, pos1, pos2)
        if line and pos1 and pos2 then
            line.From = pos1
            line.To = pos2
            line.Color = espColor
            line.Visible = true
        elseif line then
            line.Visible = false
        end
    end

    updateLine(data.HeadTorso, headPos, upperPos)
    if lowerTorso and lowerPos then
        updateLine(data.TorsoLegs, upperPos, lowerPos)
        updateLine(data.LegL, lowerPos, legLPos)
        updateLine(data.LegR, lowerPos, legRPos)
    else
        updateLine(data.TorsoLegs, upperPos, legLPos)
        updateLine(data.LegL, upperPos, legLPos)
        updateLine(data.LegR, upperPos, legRPos)
    end
    updateLine(data.ArmL, upperPos, armLPos)
    updateLine(data.ArmR, upperPos, armRPos)
end

-- ============================================
-- LOOP PRINCIPAL DO ESP (Aqui estava o maior erro)
-- ============================================
local function updateESP()
    local enabled = Library.Flags["ESP_Enabled"]
    if not enabled then return end

    frameCounter = frameCounter + 1
    if frameCounter % 2 ~= 0 then return end

    local camera = workspace.CurrentCamera
    if not camera then return end
    local localChar = LocalPlayer.Character
    if not localChar then return end

    local box = Library.Flags["ESP_Box"]
    local name = Library.Flags["ESP_Name"]
    local distance = Library.Flags["ESP_Distance"]
    local health = Library.Flags["ESP_Health"]
    local tracer = Library.Flags["ESP_Tracer"]
    local skeleton = Library.Flags["ESP_Skeleton"]
    local maxDistance = Library.Flags["ESP_MaxDistance"]
    local scale = Library.Flags["ESP_Scale"]

    local maxDistBuffer = maxDistance + 50
    local scaleFactor = scale / 100
    local cameraPos = camera.CFrame.Position
    local playersList = Players:GetPlayers()

    for _, player in pairs(playersList) do
        if player == LocalPlayer then continue end

        local character = player.Character
        if not character then
            if espElements[player] then hidePlayerESP(espElements[player]) end
            continue
        end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        local humanoid = character:FindFirstChild("Humanoid")
        if not (hrp and head and humanoid) or humanoid.Health <= 0 then
            if espElements[player] then hidePlayerESP(espElements[player]) end
            continue
        end

        local dist = (cameraPos - hrp.Position).Magnitude
        if dist > maxDistBuffer then
            if espElements[player] then hidePlayerESP(espElements[player]) end
            continue
        end

        local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if not onScreen or pos.Z <= 0 then
            if espElements[player] then hidePlayerESP(espElements[player]) end
            continue
        end

        if not espElements[player] then createESPForPlayer(player) end
        local el = espElements[player]
        if not el then continue end

        local espColor
        if isPlayerAlly(player) then
            espColor = _G.Settings_ESP.SafeColor
        else
            local visible = isPlayerVisible(hrp.Position, {localChar, character})
            espColor = visible and _G.Settings_ESP.VisibleColor or _G.Settings_ESP.DangerColor
        end

        local topPos, topOn = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
        local bottomPos, botOn = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        if not topOn or not botOn then
            hidePlayerESP(el)
            continue
        end

        local rawHeight = math.abs(topPos.Y - bottomPos.Y)
        local scaledHeight = rawHeight * scaleFactor
        scaledHeight = math.clamp(scaledHeight, 5, 500)
        local width = scaledHeight * 0.45
        local posX = pos.X - width/2
        local posY = topPos.Y - 2

        -- Caixa
        if box then
            el.Box.Position = UDim2.new(0, posX, 0, posY)
            el.Box.Size = UDim2.new(0, width, 0, scaledHeight)
            el.BoxStroke.Color = espColor
            el.Box.Visible = true
        else
            el.Box.Visible = false
        end

        -- Tracer
        if tracer then
            local centerX = camera.ViewportSize.X/2
            local centerY = camera.ViewportSize.Y/2
            local dx = pos.X - centerX
            local dy = pos.Y - centerY
            local length = math.sqrt(dx*dx + dy*dy)
            local angle = math.atan2(dy, dx)

            el.Tracer.Position = UDim2.new(0, centerX, 0, centerY)
            el.Tracer.Size = UDim2.new(0, length, 0, 1 * scaleFactor)
            el.Tracer.Rotation = math.deg(angle)
            el.Tracer.BackgroundColor3 = espColor
            el.Tracer.BackgroundTransparency = 0.4
            el.Tracer.Visible = true
        else
            el.Tracer.Visible = false
        end

        -- Nome
        if name then
            el.Name.Text = player.Name
            local fontSize = math.clamp(scaledHeight * 0.13, 10, 18)
            el.Name.TextSize = fontSize
            el.Name.Position = UDim2.new(0, pos.X - 100, 0, topPos.Y - fontSize - 4)
            el.Name.Size = UDim2.new(0, 200, 0, fontSize + 4)
            el.Name.TextColor3 = espColor
            el.Name.Visible = true
        else
            el.Name.Visible = false
        end

        -- Distância
        if distance then
            el.Distance.Text = math.floor(dist) .. "m"
            local fontSize = math.clamp(scaledHeight * 0.10, 10, 14)
            el.Distance.TextSize = fontSize
            el.Distance.Position = UDim2.new(0, pos.X - 100, 0, bottomPos.Y + 4)
            el.Distance.Size = UDim2.new(0, 200, 0, fontSize + 4)
            el.Distance.TextColor3 = Color3.fromRGB(180,180,180)
            el.Distance.Visible = true
        else
            el.Distance.Visible = false
        end

        -- Barra de Vida
        if health then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barWidth = 2 * scaleFactor
            local padding = 4 * scaleFactor
            local barX = posX + width + padding

            el.HealthBg.Position = UDim2.new(0, barX, 0, posY)
            el.HealthBg.Size = UDim2.new(0, barWidth, 0, scaledHeight)
            el.HealthBg.Visible = true

            local filledHeight = scaledHeight * healthPercent
            el.HealthBar.Position = UDim2.new(0, barX, 0, posY + scaledHeight - filledHeight)
            el.HealthBar.Size = UDim2.new(0, barWidth, 0, filledHeight)
            el.HealthBar.BackgroundColor3 = Color3.fromHSV(healthPercent * 0.33, 1, 1)
            el.HealthBar.Visible = true
        else
            el.HealthBar.Visible = false
            el.HealthBg.Visible = false
        end

        -- Skeleton
        if skeleton then
            updateSkeleton(player, camera, espColor)
        else
            local skelData = skeletonCache[player]
            if skelData then
                for _, line in pairs(skelData) do
                    if type(line) == "table" then
                        line.Visible = false
                    end
                end
            end
        end
    end
end

espConnection = RunService.RenderStepped:Connect(updateESP)

-- ============================================
-- FUNÇÃO DE CORPOS (Erro de sintaxe corrigido)
-- ============================================
function updateCorpseESP()
    local enabled = Library.Flags["ESP_Enabled"]
    local corpses = Library.Flags["ESP_Corpses"]
    if not enabled or not corpses then return end

    corpseFrameCounter = corpseFrameCounter + 1
    if corpseFrameCounter % 30 ~= 0 then return end

    local corpsesFolder = workspace:FindFirstChild("Corpses")
    if not corpsesFolder then
        for corpse, highlight in pairs(corpseCache) do
            highlight:Destroy()
            corpseCache[corpse] = nil
        end
        return
    end

    local currentCorpses = {}
    for _, child in ipairs(corpsesFolder:GetChildren()) do
        if child:IsA("Model") or child:IsA("Folder") then
            local hasBodyPart = false
            for _, part in ipairs(child:GetDescendants()) do
                if part:IsA("BasePart") and (part.Name == "Head" or part.Name == "Head2" or part.Name == "HumanoidRootPart" or part.Name == "Body") then
                    hasBodyPart = true
                    break
                end
            end
            if hasBodyPart then
                table.insert(currentCorpses, child)
            end
        end
    end

    for corpse, highlight in pairs(corpseCache) do
        if not corpse.Parent or not table.find(currentCorpses, corpse) then
            highlight:Destroy()
            corpseCache[corpse] = nil
        end
    end

    for _, corpse in ipairs(currentCorpses) do
        if not corpseCache[corpse] then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(170, 0, 255)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.8
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = corpse
            corpseCache[corpse] = highlight
        end
    end
end

-- ============================================
-- AIMBOT BACKEND (Aqui corrigimos a variável faltante)
-- ============================================
local function getAimbotTarget()
    local enabled = Library.Flags["Aimbot_Enabled"]
    if not enabled then return nil end
    
    local fov = Library.Flags["Aimbot_FOV"] or 120
    local closestTarget = nil
    local closestDistance = fov -- <-- Corrigido: Definimos a variável inicial
    local cameraPos = Camera.CFrame.Position
    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChild("Humanoid")
                if hrp and humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen and screenPos.Z > 0 then
                        local dx = screenPos.X - centerX
                        local dy = screenPos.Y - centerY
                        local distFromCenter = math.sqrt(dx*dx + dy*dy)
                        if distFromCenter < closestDistance then
                            if isPlayerVisible(hrp.Position, {LocalPlayer.Character, char}) then
                                closestDistance = distFromCenter
                                closestTarget = player
                            end
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if Library.Flags["Aimbot_Enabled"] then
        local target = getAimbotTarget()
        if target and target.Character then
            local aimMode = Library.Flags["Aimbot_Mode"] or "Cabeça (Head)"
            local targetPart = target.Character:FindFirstChild("Head")
            if aimMode == "Torso (Body)" then
                targetPart = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso")
            end
            if targetPart then
                local originalCFrame = Camera.CFrame
                Camera.CFrame = CFrame.new(originalCFrame.Position, targetPart.Position)
                RunService.RenderStepped:Wait()
                Camera.CFrame = originalCFrame
                Library:Notification("💀 Tiro desviado para " .. target.Name, 1, nil)
            end
        end
    end
end)

-- ============================================
-- EVENTOS DE REMOÇÃO DE PLAYER
-- ============================================
Players.PlayerRemoving:Connect(function(player)
    local elements = espElements[player]
    if elements then
        elements.Folder:Destroy()
        espElements[player] = nil
    end
    local skelData = skeletonCache[player]
    if skelData then
        for _, line in pairs(skelData) do
            if type(line) == "table" and line.Remove then
                line:Remove()
            end
        end
        skeletonCache[player] = nil
    end
end)

-- ============================================
-- FINALIZAÇÃO
-- ============================================
task.wait(0.5)
UpdateFOVCircle()
Library:Notification("✅ KOUDZERA -- script by devvcampos", 4, nil)

return Library
