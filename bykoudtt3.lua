if _G.ObsidianLoaded then
    print("⚠️ Script já está em execução! Use 'Unload Safely' antes de executar novamente.")
    return
end
_G.ObsidianLoaded = true

local encodedUrl = "aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2RldnZjYW1wb3MvdGhlLXdhbGtpbmczL3JlZnMvaGVhZHMvbWFpbi9MaWJyYXJ5Lmx1YQ=="

local function decodeBase64(s)
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = ""
    s = s:gsub("=", "")
    for i = 1, #s, 4 do
        local a = b64chars:find(s:sub(i,i)) - 1
        local b = b64chars:find(s:sub(i+1,i+1)) - 1
        local c = b64chars:find(s:sub(i+2,i+2)) - 1
        local d = b64chars:find(s:sub(i+3,i+3)) - 1
        if c == -1 then c = 0 end
        if d == -1 then d = 0 end
        local n = (a << 18) | (b << 12) | (c << 6) | d
        result = result .. string.char((n >> 16) & 0xFF, (n >> 8) & 0xFF, n & 0xFF)
    end
    return result
end

-- Decodifica a URL
local realUrl = decodeBase64(encodedUrl)

-- Carrega a Library usando a URL decodificada
local success, Library = pcall(function()
    return loadstring(game:HttpGet(realUrl))()
end)
if not success then
    print("⚠️ Falha ao carregar Library. Tentando método alternativo...")
    -- Aqui você pode colocar um fallback, se quiser
end

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

local corpseConnection = nil
local corpseFrameCounter = 0
local skeletonCache = {}
local corpseCache = {}

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
clearCorpseESP()

    for player, data in pairs(skeletonCache) do
        for _, line in pairs(data) do
            if type(line) == "table" and line.Remove then
                line:Remove()
            end
        end
        skeletonCache[player] = nil
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
-- ============================================
-- DEAD BODY ESP (NOVOS CONTROLES)
-- ============================================
local DEAD_Sec = ESP_Sub:Section({Name = "Dead Body ESP", Icon = "136879043989014", Side = 1})

DEAD_Sec:Toggle({Name = "Ligar ESP Corpos", Flag = "ESP_Corpses", Default = false, Callback = function(v)
    manageCorpseConnection()
end})

DEAD_Sec:Toggle({Name = "Mostrar Nome (Dead Body)", Flag = "ESP_Corpse_Name", Default = true})
DEAD_Sec:Toggle({Name = "Mostrar Distância", Flag = "ESP_Corpse_Distance", Default = true})

DEAD_Sec:Slider({Name = "Distância Máxima", Flag = "ESP_Corpse_MaxDistance", Min = 50, Max = 100000, Default = 5000, Decimals = 0, Suffix = "m"})

DEAD_Sec:Dropdown({Name = "Cor do Destaque", Flag = "ESP_Corpse_Color", Items = {"Roxo", "Amarelo", "Azul", "Personalizado"}, Default = "Roxo", Multi = false})

DEAD_Sec:Label("Cor Personalizada (Selecionar acima)"):Colorpicker({
    Flag = "ESP_Corpse_CustomColor", 
    Default = Color3.fromRGB(255, 50, 50)
})

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
local TweenService = game:GetService("TweenService")
local function teleportTo(x, y, z)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hrp = char.HumanoidRootPart
        local humanoid = char.Humanoid
        
        -- 1. Pausa o movimento atual para não conflitar
        humanoid.WalkSpeed = 0 
        humanoid.JumpPower = 0
        
        -- 2. Cria um movimento suave de 0.5s (simula uma "corrida")
        local targetPos = Vector3.new(x, y, z)
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
        tween:Play()
        
        task.wait(0.5)
        -- 3. Restaura os atributos normais
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        
        Library:Notification("Teleporte simulado com sucesso!", 2, nil)
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
-- CÍRCULO DE FOV (AGORA SEGUE O MOUSE)
-- ============================================
local CircleGui = Instance.new("ScreenGui")
CircleGui.Name = "FOVCircle"
CircleGui.ResetOnSpawn = false
CircleGui.IgnoreGuiInset = true
CircleGui.DisplayOrder = 100
local success = pcall(function() CircleGui.Parent = game:GetService("CoreGui") end)
if not success then
    CircleGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local CircleFrame = Instance.new("Frame")
CircleFrame.Name = "Circle"
CircleFrame.BackgroundTransparency = 1
CircleFrame.BorderSizePixel = 0
CircleFrame.Visible = false
CircleFrame.Parent = CircleGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = CircleFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2.5
UIStroke.Transparency = 0.1
UIStroke.Parent = CircleFrame

-- Variável para controlar o loop de posição
local fovPositionConnection = nil

-- Função que atualiza o TAMANHO e a VISIBILIDADE (chamada por eventos)
local function UpdateFOVSizeAndVisibility()
    local show = Library.Flags["Aimbot_Circle"]
    if not show then
        CircleFrame.Visible = false
        -- Desconecta o loop de posição para economizar desempenho
        if fovPositionConnection then
            fovPositionConnection:Disconnect()
            fovPositionConnection = nil
        end
        return
    end

    local vpSize = workspace.CurrentCamera.ViewportSize
    local fov = Library.Flags["Aimbot_FOV"] or 120
    local radius = math.clamp(fov * 3, 20, vpSize.Y / 1.5)

    CircleFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    CircleFrame.Visible = true

    -- Se o loop de posição não estiver ativo, liga ele agora
    if not fovPositionConnection then
        fovPositionConnection = RunService.RenderStepped:Connect(function()
            -- Só atualiza posição se estiver visível
            if not CircleFrame.Visible then return end
            
            local mousePos = UserInputService:GetMouseLocation()
            local radius = CircleFrame.Size.X.Offset / 2 -- Pega o raio atual
            CircleFrame.Position = UDim2.new(0, mousePos.X - radius, 0, mousePos.Y - radius)
        end)
    end
end

-- Atualiza o tamanho quando a tela é redimensionada
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateFOVSizeAndVisibility)

-- Chama a função pela primeira vez
task.wait(0.1)
UpdateFOVSizeAndVisibility()

-- ============================================
-- ABA AIMBOT (AGORA A FUNÇÃO JÁ EXISTE!)
-- ============================================
local Aim_Sub = Aimbot_Page:SubPage({Name = "Aimbot"})
local Aim_Sec = Aim_Sub:Section({Name = "Configurações", Icon = "136879043989014", Side = 1})

Aim_Sec:Toggle({Name = "Ativar Aimbot (Snap)", Flag = "Aimbot_Enabled", Default = false})
Aim_Sec:Slider({Name = "Campo de Visão (FOV)", Flag = "Aimbot_FOV", Min = 20, Max = 180, Default = 120, Decimals = 1, Suffix = "°", Callback = function(v)
    UpdateFOVSizeAndVisibility()
end})
Aim_Sec:Dropdown({Name = "Alvo Preferido", Flag = "Aimbot_Mode", Items = {"Cabeça (Head)", "Torso (Body)"}, Default = "Cabeça (Head)", Multi = false})
Aim_Sec:Toggle({Name = "Mostrar Círculo de FOV", Flag = "Aimbot_Circle", Default = true, Callback = function(v)
    UpdateFOVSizeAndVisibility()
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
-- Criação do Esqueleto
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
        line.Thickness = 3     -- Aumentei a espessura
        line.Transparency = 0  -- Mudei de 0.3 para 0 (Fica 100% visível)
        line.Visible = false
    end
    skeletonCache[player] = data
    return data
end

-- ============================================
-- FUNÇÃO COMPLETA DO SKELETON
-- ============================================
local function updateSkeleton(player, camera, espColor)
    -- Pega ou cria o cache de linhas para esse jogador
    local data = skeletonCache[player]
    if not data then
        data = createSkeletonForPlayer(player)
    end

    local char = player.Character
    -- Se não tiver personagem ou a cor for inválida, esconde tudo
    if not char or not espColor then
        for _, line in pairs(data) do
            line.Visible = false
        end
        return
    end

    -- Função auxiliar para converter posição 3D para coordenadas da tela
    local function getScreenPos(part)
        if part and part:IsA("BasePart") then
            local pos, onScreen = camera:WorldToViewportPoint(part.Position)
            -- Só desenha se estiver na tela e na frente da câmera (Z > 0)
            if onScreen and pos.Z > 0 then
                return Vector2.new(pos.X, pos.Y)
            end
        end
        return nil
    end

    -- Tenta pegar as partes. Suporta R15 e R6 automaticamente
    local head = char:FindFirstChild("Head", true)
    local upperTorso = char:FindFirstChild("UpperTorso", true) or char:FindFirstChild("Torso", true)
    local lowerTorso = char:FindFirstChild("LowerTorso", true)
    local leftArm = char:FindFirstChild("LeftArm", true) or char:FindFirstChild("Left Arm", true) or char:FindFirstChild("LeftUpperArm", true)
    local rightArm = char:FindFirstChild("RightArm", true) or char:FindFirstChild("Right Arm", true) or char:FindFirstChild("RightUpperArm", true)
    local leftLeg = char:FindFirstChild("LeftLeg", true) or char:FindFirstChild("Left Leg", true) or char:FindFirstChild("LeftUpperLeg", true)
    local rightLeg = char:FindFirstChild("RightLeg", true) or char:FindFirstChild("Right Leg", true) or char:FindFirstChild("RightUpperLeg", true)

    -- Se não tiver cabeça ou tronco, não faz sentido desenhar
    if not head or not upperTorso then
        for _, line in pairs(data) do
            line.Visible = false
        end
        return
    end

    -- Converte todas as partes para coordenadas de tela
    local headPos = getScreenPos(head)
    local upperPos = getScreenPos(upperTorso)
    local lowerPos = getScreenPos(lowerTorso)
    local armLPos = getScreenPos(leftArm)
    local armRPos = getScreenPos(rightArm)
    local legLPos = getScreenPos(leftLeg)
    local legRPos = getScreenPos(rightLeg)

    -- Função local para atualizar cada linha
    local function updateLine(line, p1, p2)
        if line and p1 and p2 then
            line.From = p1
            line.To = p2
            line.Color = espColor
            line.Visible = true
        elseif line then
            line.Visible = false
        end
    end

    -- 1. Cabeça -> Tronco Superior
    updateLine(data.HeadTorso, headPos, upperPos)

    -- 2. Parte inferior (R15 tem LowerTorso, R6 não)
    if lowerTorso and lowerPos and legLPos and legRPos then
        -- R15: Tronco Superior -> Tronco Inferior -> Pernas
        updateLine(data.TorsoLegs, upperPos, lowerPos)
        updateLine(data.LegL, lowerPos, legLPos)
        updateLine(data.LegR, lowerPos, legRPos)
    else
        -- R6: Tronco Superior direto para as pernas
        updateLine(data.TorsoLegs, upperPos, legLPos)
        updateLine(data.LegL, upperPos, legLPos)
        updateLine(data.LegR, upperPos, legRPos)
    end

    -- 3. Braços (Tronco Superior -> Braços)
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
if frameCounter % math.random(2, 4) ~= 0 then return end -- Varia entre 2 e 4

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
        scaledHeight = math.clamp(scaledHeight, 25, 500)
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
    -- Verificação extra: Só desenha se o jogador ainda estiver na tela!
    if onScreen and pos.Z > 0 then
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
-- NOVA LÓGICA DE CORPOS (HIGHLIGHT + LABELS)
-- ============================================
-- Função auxiliar para obter a cor com base no dropdown
local function getCorpseColor()
    local mode = Library.Flags["ESP_Corpse_Color"]
    if mode == "Roxo" then return Color3.fromRGB(170, 0, 255) end
    if mode == "Amarelo" then return Color3.fromRGB(255, 255, 0) end
    if mode == "Azul" then return Color3.fromRGB(0, 170, 255) end
    if mode == "Personalizado" then
        return Library.Flags["ESP_Corpse_CustomColor"] or Color3.fromRGB(255, 50, 50)
    end
    return Color3.fromRGB(170, 0, 255) -- Fallback roxo
end

-- Cria os elementos gráficos para um corpo
local function createCorpseElements(corpse)
    local folder = Instance.new("Folder")
    folder.Name = "CorpseESP_" .. corpse.Name
    folder.Parent = getMasterGUI() -- Usa a mesma GUI do ESP normal

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = corpse

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextStrokeTransparency = 0.8
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.Text = "Dead Body"
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Visible = false
    nameLabel.Parent = folder

    local distLabel = Instance.new("TextLabel")
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextStrokeTransparency = 0.8
    distLabel.TextStrokeColor3 = Color3.new(0,0,0)
    distLabel.TextXAlignment = Enum.TextXAlignment.Center
    distLabel.Visible = false
    distLabel.Parent = folder

    return {
        Folder = folder,
        Highlight = highlight,
        NameLabel = nameLabel,
        DistLabel = distLabel
    }
end

-- Limpa todos os corpos da memória
local function clearCorpseESP()
    for corpse, elements in pairs(corpseCache) do
        if elements then
            if elements.Highlight then elements.Highlight:Destroy() end
            if elements.Folder then elements.Folder:Destroy() end
        end
    end
    corpseCache = {}
end

-- Gerencia a conexão do loop e a limpeza
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
        end
        clearCorpseESP()
    end
end

-- LOOP PRINCIPAL DE CORPOS
function updateCorpseESP()
    local enabled = Library.Flags["ESP_Enabled"]
    local corpses = Library.Flags["ESP_Corpses"]
    if not enabled or not corpses then
        clearCorpseESP()
        return
    end

    corpseFrameCounter = corpseFrameCounter + 1
    if corpseFrameCounter % math.random(10, 20) ~= 0 then return end

    local camera = workspace.CurrentCamera
    local localChar = LocalPlayer.Character
    if not camera or not localChar then return end

    local maxDist = Library.Flags["ESP_Corpse_MaxDistance"] or 5000
    local showName = Library.Flags["ESP_Corpse_Name"]
    local showDist = Library.Flags["ESP_Corpse_Distance"]
    local currentColor = getCorpseColor()

    local corpsesFolder = workspace:FindFirstChild("Corpses")
    if not corpsesFolder then
        clearCorpseESP()
        return
    end

    -- Coleta todos os corpos válidos
    local currentCorpses = {}
    for _, child in ipairs(corpsesFolder:GetChildren()) do
        if child:IsA("Model") or child:IsA("Folder") then
            local hasBodyPart = false
            for _, part in ipairs(child:GetDescendants()) do
                if part:IsA("BasePart") and (part.Name == "Head" or part.Name == "Head2" or part.Name == "HumanoidRootPart" or part.Name == "Body" or part.Name == "Torso") then
                    hasBodyPart = true
                    break
                end
            end
            if hasBodyPart then
                table.insert(currentCorpses, child)
            end
        end
    end

    -- Remove corpos que não existem mais
    for corpse, elements in pairs(corpseCache) do
        if not corpse.Parent or not table.find(currentCorpses, corpse) then
            if elements then
                if elements.Highlight then elements.Highlight:Destroy() end
                if elements.Folder then elements.Folder:Destroy() end
            end
            corpseCache[corpse] = nil
        end
    end

    -- Processa os corpos atuais
    for _, corpse in ipairs(currentCorpses) do
        local elements = corpseCache[corpse]
        if not elements then
            elements = createCorpseElements(corpse)
            corpseCache[corpse] = elements
        end

        -- Encontra o RootPart do corpo para projetar na tela
        local rootPart = corpse:FindFirstChild("HumanoidRootPart") or corpse:FindFirstChild("Torso") or corpse:FindFirstChild("Head")
        if not rootPart then
            elements.NameLabel.Visible = false
            elements.DistLabel.Visible = false
            continue
        end

        local cameraPos = camera.CFrame.Position
        local dist = (cameraPos - rootPart.Position).Magnitude

        -- Verifica distância máxima
        if dist > maxDist then
            elements.NameLabel.Visible = false
            elements.DistLabel.Visible = false
            continue
        end

        -- Projeta para a tela
        local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
        if onScreen and pos.Z > 0 then
            -- Atualiza a cor do Highlight (chams)
            elements.Highlight.FillColor = currentColor
            elements.Highlight.OutlineColor = currentColor

            -- Atualiza Label de Nome
            if showName then
                elements.NameLabel.Position = UDim2.new(0, pos.X, 0, pos.Y - 35)
                elements.NameLabel.AnchorPoint = Vector2.new(0.5, 1)
                elements.NameLabel.Visible = true
            else
                elements.NameLabel.Visible = false
            end

            -- Atualiza Label de Distância
            if showDist then
                elements.DistLabel.Text = math.floor(dist) .. "m"
                elements.DistLabel.Position = UDim2.new(0, pos.X, 0, pos.Y + 5)
                elements.DistLabel.AnchorPoint = Vector2.new(0.5, 0)
                elements.DistLabel.Visible = true
            else
                elements.DistLabel.Visible = false
            end
        else
            elements.NameLabel.Visible = false
            elements.DistLabel.Visible = false
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
UpdateFOVSizeAndVisibility()
Library:Notification("✅ KOUDZERA -- script by devvcampos", 4, nil)

return Library
