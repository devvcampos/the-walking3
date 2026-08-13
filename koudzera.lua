-- =============================================================================
-- TRAVA DE SEGURANÇA (EVITA ABRIR 2 VEZES)
-- =============================================================================
if _G.ObsidianLoaded then
    return
end
_G.ObsidianLoaded = true

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

-- ============================================
-- FUNÇÃO DE VISIBILIDADE
-- ============================================
local function isPlayerVisible(targetPos, ignoreList)
    if not Library.Flags["ESP_VisibilityCheck"] then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    if distance > 5000 then return true end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = ignoreList
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, direction * distance, params)
    return result == nil
end

local function isPlayerAlly(player)
    if not Library.Flags["ESP_TeamCheck"] then return false end
    return player.TeamColor == LocalPlayer.TeamColor
end

-- ============================================
-- FUNÇÕES DE CORPOS
-- ============================================
local function getMasterGUI()
    if ESP_GUI then return ESP_GUI end

    -- [PROTEÇÃO 1] Injeção Fantasma: Tenta achar uma GUI que o jogo já usa para se esconder dentro
    local gameHUD = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("MainHUD") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui")
    
    if gameHUD then
        -- Cria um Frame invisível dentro da GUI do jogo (muito mais seguro que ScreenGui)
        ESP_GUI = Instance.new(string.char(70,114,97,109,101)) -- "Frame"
        ESP_GUI.Name = string.char(83,121,115,116,101,109,79,118,101,114,108,97,121) -- "SystemOverlay"
        ESP_GUI.Visible = false
        ESP_GUI.Parent = gameHUD
        ESP_GUI.BackgroundTransparency = 1
        ESP_GUI.Size = UDim2.new(1, 0, 1, 0)
        ESP_GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ESP_GUI.DisplayOrder = 999999
    else
        -- Fallback seguro (caso não ache a GUI do jogo)
        ESP_GUI = Instance.new(string.char(83,99,114,101,101,110,71,117,105)) -- "ScreenGui"
        ESP_GUI.Name = string.char(72,85,68,95,79,118,101,114,108,97,121) -- "HUD_Overlay"
        ESP_GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")
        ESP_GUI.ResetOnSpawn = false
        ESP_GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ESP_GUI.DisplayOrder = 999999
    end
    return ESP_GUI
end

local function getCorpseColor()
    local mode = Library.Flags["ESP_Corpse_Color"]
    if mode == "Roxo" then return Color3.fromRGB(170, 0, 255) end
    if mode == "Amarelo" then return Color3.fromRGB(255, 255, 0) end
    if mode == "Azul" then return Color3.fromRGB(0, 170, 255) end
    if mode == "Personalizado" then
        return Library.Flags["ESP_Corpse_CustomColor"] or Color3.fromRGB(255, 50, 50)
    end
    return Color3.fromRGB(170, 0, 255)
end

local function createCorpseElements(corpse)
    local folder = Instance.new(string.char(70,111,108,100,101,114)) -- "Folder"
    folder.Name = string.char(67,111,114,112,115,101,69,83,80) .. "_" .. corpse.Name
    folder.Parent = getMasterGUI()

    local highlight = Instance.new(string.char(72,105,103,104,108,105,103,104,116)) -- "Highlight"
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = corpse

    local nameLabel = Instance.new(string.char(84,101,120,116,76,97,98,101,108)) -- "TextLabel"
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

    local distLabel = Instance.new(string.char(84,101,120,116,76,97,98,101,108)) -- "TextLabel"
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

local function clearCorpseESP()
    for corpse, elements in pairs(corpseCache) do
        if elements then
            if elements.Highlight then elements.Highlight:Destroy() end
            if elements.Folder then elements.Folder:Destroy() end
        end
    end
    corpseCache = {}
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
        end
        clearCorpseESP()
    end
end

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

    for corpse, elements in pairs(corpseCache) do
        if not corpse.Parent or not table.find(currentCorpses, corpse) then
            if elements then
                if elements.Highlight then elements.Highlight:Destroy() end
                if elements.Folder then elements.Folder:Destroy() end
            end
            corpseCache[corpse] = nil
        end
    end

    for _, corpse in ipairs(currentCorpses) do
        local elements = corpseCache[corpse]
        if not elements then
            elements = createCorpseElements(corpse)
            corpseCache[corpse] = elements
        end

        local rootPart = corpse:FindFirstChild("HumanoidRootPart") or corpse:FindFirstChild("Torso") or corpse:FindFirstChild("Head")
        if not rootPart then
            elements.NameLabel.Visible = false
            elements.DistLabel.Visible = false
            continue
        end

        local cameraPos = camera.CFrame.Position
        local dist = (cameraPos - rootPart.Position).Magnitude

        if dist > maxDist then
            elements.NameLabel.Visible = false
            elements.DistLabel.Visible = false
            continue
        end

        local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
        if onScreen and pos.Z > 0 then
            elements.Highlight.FillColor = currentColor
            elements.Highlight.OutlineColor = currentColor

            if showName then
                elements.NameLabel.Position = UDim2.new(0, pos.X, 0, pos.Y - 35)
                elements.NameLabel.AnchorPoint = Vector2.new(0.5, 1)
                elements.NameLabel.Visible = true
            else
                elements.NameLabel.Visible = false
            end

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
-- FUNÇÃO DE LIMPEZA GERAL
-- ============================================
function clearAllESP()
    for player, elements in pairs(espElements) do
        if elements.Folder then elements.Folder:Destroy() end
        espElements[player] = nil
    end
    if ESP_GUI then ESP_GUI:Destroy(); ESP_GUI = nil end

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
-- JANELA PRINCIPAL (Library)
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

Library:CreateSettingsPage(Window)

-- ============================================
-- INICIALIZAÇÃO MANUAL DAS FLAGS
-- ============================================
Library.Flags["ESP_Enabled"] = Library.Flags["ESP_Enabled"] or false
Library.Flags["ESP_Box"] = Library.Flags["ESP_Box"] or true
Library.Flags["ESP_Name"] = Library.Flags["ESP_Name"] or true
Library.Flags["ESP_Distance"] = Library.Flags["ESP_Distance"] or false
Library.Flags["ESP_Health"] = Library.Flags["ESP_Health"] or true
Library.Flags["ESP_Tracer"] = Library.Flags["ESP_Tracer"] or true
Library.Flags["ESP_TeamCheck"] = Library.Flags["ESP_TeamCheck"] or true
Library.Flags["ESP_Skeleton"] = Library.Flags["ESP_Skeleton"] or false
Library.Flags["ESP_Corpses"] = Library.Flags["ESP_Corpses"] or false
Library.Flags["ESP_Corpse_Name"] = Library.Flags["ESP_Corpse_Name"] or true
Library.Flags["ESP_Corpse_Distance"] = Library.Flags["ESP_Corpse_Distance"] or true
Library.Flags["ESP_Corpse_MaxDistance"] = Library.Flags["ESP_Corpse_MaxDistance"] or 5000
Library.Flags["ESP_Corpse_Color"] = Library.Flags["ESP_Corpse_Color"] or "Roxo"
Library.Flags["ESP_Corpse_CustomColor"] = Library.Flags["ESP_Corpse_CustomColor"] or Color3.fromRGB(255, 50, 50)

-- ============================================
-- ABA ESP (CONFIGURATION)
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

local DEAD_Sec = ESP_Sub:Section({Name = "Dead Body ESP", Icon = "136879043989014", Side = 2})
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
-- ABA VISUALS
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
-- ABA TELEPORTS (COM DESVIO ALEATÓRIO)
-- ============================================
local Tel_Sub = Teleports_Page:SubPage({Name = "Locations"})
local Tel_Sec = Tel_Sub:Section({Name = "Teleports", Icon = "97491613646216", Side = 1})

local function teleportTo(x, y, z)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hrp = char.HumanoidRootPart
        local humanoid = char.Humanoid
        
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        
        local startPos = hrp.Position
        local endPos = Vector3.new(x, y, z)
        local distance = (endPos - startPos).Magnitude
        
        local steps = math.clamp(math.floor(distance / 10), 10, 60)
        local stepVector = (endPos - startPos) / steps
        
        -- [PROTEÇÃO 2] Adiciona desvio aleatório humano a cada passo para confundir o servidor
        for i = 1, steps do
            local randomX = (math.random() - 0.5) * 0.2
            local randomZ = (math.random() - 0.5) * 0.2
            
            local nextPos = startPos + stepVector * i
            nextPos = Vector3.new(nextPos.X + randomX, nextPos.Y, nextPos.Z + randomZ)
            
            hrp.CFrame = CFrame.new(nextPos)
            task.wait(0.03)
        end
        
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        
        Library:Notification("Teleporte fracionado concluído!", 2, nil)
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
-- CÍRCULO DE FOV (OFUSCADO)
-- ============================================
local CircleGui = Instance.new(string.char(83,99,114,101,101,110,71,117,105)) -- "ScreenGui"
CircleGui.Name = string.char(70,79,86,67,105,114,99,108,101) -- "FOVCircle"
CircleGui.ResetOnSpawn = false
CircleGui.IgnoreGuiInset = true
CircleGui.DisplayOrder = 100
local success = pcall(function() CircleGui.Parent = game:GetService("CoreGui") end)
if not success then
    CircleGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local CircleFrame = Instance.new(string.char(70,114,97,109,101)) -- "Frame"
CircleFrame.Name = string.char(67,105,114,99,108,101) -- "Circle"
CircleFrame.BackgroundTransparency = 1
CircleFrame.BorderSizePixel = 0
CircleFrame.Visible = false
CircleFrame.Parent = CircleGui

local UICorner = Instance.new(string.char(85,73,67,111,114,110,101,114)) -- "UICorner"
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = CircleFrame

local UIStroke = Instance.new(string.char(85,73,83,116,114,111,107,101)) -- "UIStroke"
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2.5
UIStroke.Transparency = 0.1
UIStroke.Parent = CircleFrame

local fovPositionConnection = nil

local function UpdateFOVSizeAndVisibility()
    local show = Library.Flags["Aimbot_Circle"]
    if not show then
        CircleFrame.Visible = false
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

    if not fovPositionConnection then
        fovPositionConnection = RunService.RenderStepped:Connect(function()
            if not CircleFrame.Visible then return end
            local mousePos = UserInputService:GetMouseLocation()
            local radius = CircleFrame.Size.X.Offset / 2
            CircleFrame.Position = UDim2.new(0, mousePos.X - radius, 0, mousePos.Y - radius)
        end)
    end
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateFOVSizeAndVisibility)
task.wait(0.1)
UpdateFOVSizeAndVisibility()

-- ============================================
-- ABA AIMBOT
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
-- CRIAÇÃO DOS ELEMENTOS ESP (OFUSCADOS)
-- ============================================
function createESPForPlayer(player)
    if espElements[player] then return end
    local gui = getMasterGUI()
    
    local folder = Instance.new(string.char(70,111,108,100,101,114)) -- "Folder"
    folder.Name = tostring(player.UserId)
    folder.Parent = gui

    local box = Instance.new(string.char(70,114,97,109,101)) -- "Frame"
    box.Name = string.char(66,111,120) -- "Box"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Size = UDim2.new(0, 100, 0, 100)
    box.Visible = false
    box.Parent = folder

    local boxStroke = Instance.new(string.char(85,73,83,116,114,111,107,101)) -- "UIStroke"
    boxStroke.Name = string.char(83,116,114,111,107,101) -- "Stroke"
    boxStroke.Thickness = 1.2
    boxStroke.Color = Color3.new(1,1,1)
    boxStroke.Transparency = 0.2
    boxStroke.Parent = box

    local tracer = Instance.new(string.char(70,114,97,109,101)) -- "Frame"
    tracer.Name = string.char(84,114,97,99,101,114) -- "Tracer"
    tracer.BackgroundColor3 = Color3.new(1,1,1)
    tracer.BorderSizePixel = 0
    tracer.Size = UDim2.new(0, 1, 0, 1)
    tracer.Visible = false
    tracer.Parent = folder

    local nameLabel = Instance.new(string.char(84,101,120,116,76,97,98,101,108)) -- "TextLabel"
    nameLabel.Name = string.char(78,97,109,101) -- "Name"
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextStrokeTransparency = 0.8
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Visible = false
    nameLabel.Parent = folder

    local distLabel = Instance.new(string.char(84,101,120,116,76,97,98,101,108)) -- "TextLabel"
    distLabel.Name = string.char(68,105,115,116,97,110,99,101) -- "Distance"
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(180,180,180)
    distLabel.TextSize = 11
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextStrokeTransparency = 0.8
    distLabel.TextStrokeColor3 = Color3.new(0,0,0)
    distLabel.TextXAlignment = Enum.TextXAlignment.Center
    distLabel.Visible = false
    distLabel.Parent = folder

    local healthBar = Instance.new(string.char(70,114,97,109,101)) -- "Frame"
    healthBar.Name = string.char(72,101,97,108,116,104,66,97,114) -- "HealthBar"
    healthBar.BackgroundColor3 = Color3.fromRGB(0,255,0)
    healthBar.BorderSizePixel = 0
    healthBar.Size = UDim2.new(0, 2, 0, 100)
    healthBar.Visible = false
    healthBar.Parent = folder

    local healthBg = Instance.new(string.char(70,114,97,109,101)) -- "Frame"
    healthBg.Name = string.char(72,101,97,108,116,104,66,103) -- "HealthBg"
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

-- ============================================
-- SKELETON ESP (OFUSCADO)
-- ============================================
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
        line.Thickness = 3
        line.Transparency = 0
        line.Visible = false
    end
    skeletonCache[player] = data
    return data
end

local function updateSkeleton(player, camera, espColor)
    local data = skeletonCache[player]
    if not data then
        data = createSkeletonForPlayer(player)
    end

    local char = player.Character
    if not char or not espColor then
        for _, line in pairs(data) do
            line.Visible = false
        end
        return
    end

    local function getScreenPos(part)
        if part and part:IsA("BasePart") then
            local pos, onScreen = camera:WorldToViewportPoint(part.Position)
            if onScreen and pos.Z > 0 then
                return Vector2.new(pos.X, pos.Y)
            end
        end
        return nil
    end

    local head = char:FindFirstChild("Head", true)
    local upperTorso = char:FindFirstChild("UpperTorso", true) or char:FindFirstChild("Torso", true)
    local lowerTorso = char:FindFirstChild("LowerTorso", true)
    local leftArm = char:FindFirstChild("LeftArm", true) or char:FindFirstChild("Left Arm", true) or char:FindFirstChild("LeftUpperArm", true)
    local rightArm = char:FindFirstChild("RightArm", true) or char:FindFirstChild("Right Arm", true) or char:FindFirstChild("RightUpperArm", true)
    local leftLeg = char:FindFirstChild("LeftLeg", true) or char:FindFirstChild("Left Leg", true) or char:FindFirstChild("LeftUpperLeg", true)
    local rightLeg = char:FindFirstChild("RightLeg", true) or char:FindFirstChild("Right Leg", true) or char:FindFirstChild("RightUpperLeg", true)

    if not head or not upperTorso then
        for _, line in pairs(data) do
            line.Visible = false
        end
        return
    end

    local headPos = getScreenPos(head)
    local upperPos = getScreenPos(upperTorso)
    local lowerPos = getScreenPos(lowerTorso)
    local armLPos = getScreenPos(leftArm)
    local armRPos = getScreenPos(rightArm)
    local legLPos = getScreenPos(leftLeg)
    local legRPos = getScreenPos(rightLeg)

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

    updateLine(data.HeadTorso, headPos, upperPos)
    if lowerTorso and lowerPos and legLPos and legRPos then
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
-- LOOP PRINCIPAL DO ESP (COM LIMPEZA NA MORTE)
-- ============================================
local function updateESP()
    local enabled = Library.Flags["ESP_Enabled"]
    if not enabled then return end

    -- [PROTEÇÃO 3] Limpeza instantânea se o personagem morrer (evita erros no console)
    local localChar = LocalPlayer.Character
    if not localChar then
        clearAllESP()
        return
    end

    frameCounter = frameCounter + 1
    if frameCounter % math.random(2, 4) ~= 0 then return end

    local camera = workspace.CurrentCamera
    if not camera then return end

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

        if box then
            el.Box.Position = UDim2.new(0, posX, 0, posY)
            el.Box.Size = UDim2.new(0, width, 0, scaledHeight)
            el.BoxStroke.Color = espColor
            el.Box.Visible = true
        else
            el.Box.Visible = false
        end

        if tracer then
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
-- AIMBOT BACKEND (SNAP)
-- ============================================
local function getAimbotTarget()
    local enabled = Library.Flags["Aimbot_Enabled"]
    if not enabled then return nil end
    
    local fov = Library.Flags["Aimbot_FOV"] or 120
    local closestTarget = nil
    local closestDistance = fov
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
-- EVENTO DE REMOÇÃO DE PLAYER
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