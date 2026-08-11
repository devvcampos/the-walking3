-- =============================================================================
-- OBSIDIAN ULTRA PREMIUM - VERSÃO COMPLETA (2D/3D + SKELETON + CHAMS + FOV)
-- =============================================================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Obsidian Ultra Premium",
    Footer = "v8.0 - Full Edition",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    ESP = Window:AddTab("ESP Settings", "eye"),
    Visuals = Window:AddTab("Visuals & Chams", "palette"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- =============================================================================
-- VARIÁVEIS GLOBAIS (INICIALIZAÇÃO)
-- =============================================================================
_G.ESP_Enabled = false
_G.ESP_Box = false
_G.ESP_Box3D = true
_G.ESP_BoxStyle = "Cheia"
_G.ESP_Name = false
_G.ESP_Distance = false
_G.ESP_Health = false
_G.ESP_Tracer = false
_G.ESP_Circle = false
_G.ESP_HeadDot = false
_G.ESP_Skeleton = false
_G.ESP_Chams = false
_G.ESP_TeamCheck = false
_G.ESP_VisibilityCheck = false
_G.ESP_MaxDistance = 10000
_G.ESP_VisibilityFOV = 120
_G.ESP_CircleSize = 3

-- Cores
_G.ESP_DangerColor = Color3.new(1, 0, 0)
_G.ESP_SafeColor = Color3.new(0, 1, 0)
_G.ESP_ChamsColor = Color3.new(0, 0, 1)

-- =============================================================================
-- ABA: ESP SETTINGS
-- =============================================================================
local ESPGroup = Tabs.ESP:AddLeftGroupbox("ESP Configuration", "eye")

ESPGroup:AddToggle("ESP_Enabled", {
    Text = "Master ESP Switch",
    Default = false,
})
Toggles.ESP_Enabled:OnChanged(function()
    _G.ESP_Enabled = Toggles.ESP_Enabled.Value
    if not _G.ESP_Enabled then clearAllESP() end
end)

ESPGroup:AddDivider()

ESPGroup:AddToggle("ESP_Box", {
    Text = "Box ESP",
    Default = false,
})
Toggles.ESP_Box:OnChanged(function() _G.ESP_Box = Toggles.ESP_Box.Value end)

ESPGroup:AddToggle("ESP_Box3D", {
    Text = "3D Box Mode (ViewportFrame)",
    Default = true,
    Tooltip = "Ativa a caixa 3D otimizada",
})
Toggles.ESP_Box3D:OnChanged(function() _G.ESP_Box3D = Toggles.ESP_Box3D.Value end)

ESPGroup:AddDropdown("ESP_BoxStyle", {
    Values = { "Cheia", "Esquadrinhada (Cantos)" },
    Default = 1,
    Text = "Estilo da Caixa (2D)",
})
Options.ESP_BoxStyle:OnChanged(function() _G.ESP_BoxStyle = Options.ESP_BoxStyle.Value end)

ESPGroup:AddToggle("ESP_Name", {
    Text = "Name ESP",
    Default = false,
})
Toggles.ESP_Name:OnChanged(function() _G.ESP_Name = Toggles.ESP_Name.Value end)

ESPGroup:AddToggle("ESP_Distance", {
    Text = "Distance ESP",
    Default = false,
})
Toggles.ESP_Distance:OnChanged(function() _G.ESP_Distance = Toggles.ESP_Distance.Value end)

ESPGroup:AddToggle("ESP_Health", {
    Text = "Health Bar",
    Default = false,
})
Toggles.ESP_Health:OnChanged(function() _G.ESP_Health = Toggles.ESP_Health.Value end)

ESPGroup:AddToggle("ESP_Tracer", {
    Text = "Tracer (Line)",
    Default = false,
})
Toggles.ESP_Tracer:OnChanged(function() _G.ESP_Tracer = Toggles.ESP_Tracer.Value end)

ESPGroup:AddToggle("ESP_Circle", {
    Text = "3D Ground Circle",
    Default = false,
})
Toggles.ESP_Circle:OnChanged(function() _G.ESP_Circle = Toggles.ESP_Circle.Value end)

ESPGroup:AddToggle("ESP_HeadDot", {
    Text = "Head Dot (Ponto na cabeça)",
    Default = false,
})
Toggles.ESP_HeadDot:OnChanged(function() _G.ESP_HeadDot = Toggles.ESP_HeadDot.Value end)

ESPGroup:AddToggle("ESP_Skeleton", {
    Text = "Skeleton ESP (Esqueleto)",
    Default = false,
})
Toggles.ESP_Skeleton:OnChanged(function() _G.ESP_Skeleton = Toggles.ESP_Skeleton.Value end)

ESPGroup:AddToggle("ESP_TeamCheck", {
    Text = "Team Check (Aliado/Inimigo)",
    Default = false,
})
Toggles.ESP_TeamCheck:OnChanged(function() _G.ESP_TeamCheck = Toggles.ESP_TeamCheck.Value end)

-- =============================================================================
-- ABA: VISUALS & CHAMS
-- =============================================================================
local VisualGroup = Tabs.Visuals:AddLeftGroupbox("Visual & Chams Settings", "palette")

VisualGroup:AddSlider("ESP_MaxDistance", {
    Text = "Max Distance",
    Default = 10000,
    Min = 500,
    Max = 100000,
    Rounding = 0,
    Suffix = "m",
})
Options.ESP_MaxDistance:OnChanged(function() _G.ESP_MaxDistance = Options.ESP_MaxDistance.Value end)

VisualGroup:AddSlider("ESP_CircleSize", {
    Text = "Circle Size",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Suffix = "x",
})
Options.ESP_CircleSize:OnChanged(function() _G.ESP_CircleSize = Options.ESP_CircleSize.Value end)

VisualGroup:AddLabel("Danger Color"):AddColorPicker("ESP_DangerColor", {
    Default = Color3.new(1, 0, 0),
    Title = "Inimigo",
    Transparency = 0,
})
Options.ESP_DangerColor:OnChanged(function() _G.ESP_DangerColor = Options.ESP_DangerColor.Value end)

VisualGroup:AddLabel("Safe Color"):AddColorPicker("ESP_SafeColor", {
    Default = Color3.new(0, 1, 0),
    Title = "Aliado",
    Transparency = 0,
})
Options.ESP_SafeColor:OnChanged(function() _G.ESP_SafeColor = Options.ESP_SafeColor.Value end)

-- FOV CHECK
VisualGroup:AddDivider()
VisualGroup:AddToggle("ESP_VisibilityCheck", {
    Text = "Visibility Check (FOV)",
    Default = false,
    Tooltip = "Só desenha o ESP se o jogador estiver no seu campo de visão",
})
Toggles.ESP_VisibilityCheck:OnChanged(function() _G.ESP_VisibilityCheck = Toggles.ESP_VisibilityCheck.Value end)

VisualGroup:AddSlider("ESP_VisibilityFOV", {
    Text = "FOV Angle",
    Default = 120,
    Min = 30,
    Max = 180,
    Rounding = 0,
    Suffix = "°",
})
Options.ESP_VisibilityFOV:OnChanged(function() _G.ESP_VisibilityFOV = Options.ESP_VisibilityFOV.Value end)

-- CHAMS
VisualGroup:AddDivider()
VisualGroup:AddToggle("ESP_Chams", {
    Text = "Enable Chams (Wallhack)",
    Default = false,
})
Toggles.ESP_Chams:OnChanged(function() _G.ESP_Chams = Toggles.ESP_Chams.Value end)

VisualGroup:AddLabel("Chams Color"):AddColorPicker("ESP_ChamsColor", {
    Default = Color3.new(0, 0, 1),
    Title = "Cor do Chams",
    Transparency = 0.5,
})
Options.ESP_ChamsColor:OnChanged(function() _G.ESP_ChamsColor = Options.ESP_ChamsColor.Value end)

-- =============================================================================
-- SISTEMA PREMIUM DE ESP (BACKEND)
-- =============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espElements = {}
local ESP_GUI = nil

-- Função para criar GUI Mestre
local function createMasterGUI()
    if ESP_GUI then return ESP_GUI end
    
    ESP_GUI = Instance.new("ScreenGui")
    ESP_GUI.Name = "ObsidianPremium_" .. math.random(100000, 999999)
    ESP_GUI.ResetOnSpawn = false
    ESP_GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ESP_GUI.IgnoreGuiInset = true
    ESP_GUI.ScreenInsets = Enum.ScreenInsets.None
    ESP_GUI.DisplayOrder = 999999
    
    local success = pcall(function()
        ESP_GUI.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        ESP_GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    return ESP_GUI
end

-- Team Check
local function isPlayerAlly(player)
    if not _G.ESP_TeamCheck then return false end
    if player.TeamColor == LocalPlayer.TeamColor and LocalPlayer.TeamColor ~= nil then
        return true
    end
    return false
end

-- FOV Check (Verifica se o jogador está dentro do campo de visão)
local function isPlayerInFOV(playerPos)
    if not _G.ESP_VisibilityCheck then return true end
    
    local camera = workspace.CurrentCamera
    local cameraCFrame = camera.CFrame
    local lookVector = cameraCFrame.LookVector
    local cameraPos = cameraCFrame.Position
    
    local targetVector = (playerPos - cameraPos).Unit
    local dotProduct = lookVector:Dot(targetVector)
    local angle = math.deg(math.acos(dotProduct))
    
    return angle <= _G.ESP_VisibilityFOV
end

-- Cria os elementos visuais
local function createESPForPlayer(player)
    if espElements[player] then return end
    
    local masterGUI = createMasterGUI()
    if not masterGUI then return end
    
    local holder = Instance.new("Folder")
    holder.Name = "ESP_" .. player.UserId
    holder.Parent = masterGUI
    
    -- ==================== BOX 3D (ViewportFrame) ====================
    local box3D = Instance.new("ViewportFrame")
    box3D.Name = "Box3D"
    box3D.BackgroundTransparency = 1
    box3D.BorderSizePixel = 0
    box3D.Visible = false
    box3D.Parent = holder
    
    local canvas = Instance.new("CanvasGroup")
    canvas.GroupTransparency = 0
    canvas.Size = UDim2.new(1, 0, 1, 0)
    canvas.Parent = box3D
    
    for i = 1, 4 do
        local line = Instance.new("Frame")
        line.BackgroundColor3 = Color3.new(1, 1, 1)
        line.BorderSizePixel = 0
        line.Visible = true
        line.Parent = canvas
    end
    
    -- ==================== BOX 2D (Alternativa) ====================
    local box2D = Instance.new("Frame")
    box2D.Name = "Box2D"
    box2D.BackgroundTransparency = 1
    box2D.BorderSizePixel = 0
    box2D.Visible = false
    box2D.Parent = holder
    
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 1)
    top.Position = UDim2.new(0, 0, 0, 0)
    top.BorderSizePixel = 0
    top.Parent = box2D
    
    local bottom = Instance.new("Frame")
    bottom.Size = UDim2.new(1, 0, 0, 1)
    bottom.Position = UDim2.new(0, 0, 1, 0)
    bottom.BorderSizePixel = 0
    bottom.Parent = box2D
    
    local left = Instance.new("Frame")
    left.Size = UDim2.new(0, 1, 1, 0)
    left.Position = UDim2.new(0, 0, 0, 0)
    left.BorderSizePixel = 0
    left.Parent = box2D
    
    local right = Instance.new("Frame")
    right.Size = UDim2.new(0, 1, 1, 0)
    right.Position = UDim2.new(1, 0, 0, 0)
    right.BorderSizePixel = 0
    right.Parent = box2D
    
    -- ==================== TRACER ====================
    local tracer = Instance.new("Frame")
    tracer.Name = "Tracer"
    tracer.BackgroundColor3 = Color3.new(1, 1, 1)
    tracer.BorderSizePixel = 0
    tracer.Visible = false
    tracer.Parent = holder
    
    -- ==================== CIRCLE ====================
    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.BackgroundTransparency = 0.5
    circle.BorderSizePixel = 0
    circle.Visible = false
    circle.Parent = holder
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    
    -- ==================== HEAD DOT ====================
    local headDot = Instance.new("Frame")
    headDot.Name = "HeadDot"
    headDot.BackgroundColor3 = Color3.new(1, 1, 1)
    headDot.BorderSizePixel = 0
    headDot.Visible = false
    headDot.Parent = holder
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = headDot
    
    -- ==================== SKELETON ====================
    local skeletonFolder = Instance.new("Folder")
    skeletonFolder.Name = "Skeleton"
    skeletonFolder.Parent = holder
    
    local skeletonParts = {}
    local joints = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Left Hand", "Right Hand", "Left Foot", "Right Foot"}
    for _, name in pairs(joints) do
        local line = Instance.new("Frame")
        line.Name = name
        line.BackgroundColor3 = Color3.new(1, 1, 1)
        line.BorderSizePixel = 0
        line.Visible = false
        line.Parent = skeletonFolder
        table.insert(skeletonParts, line)
    end
    
    -- ==================== NOME, DISTÂNCIA E VIDA ====================
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Visible = false
    nameLabel.Parent = holder
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "Distance"
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextStrokeTransparency = 0.5
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.TextXAlignment = Enum.TextXAlignment.Center
    distLabel.Visible = false
    distLabel.Parent = holder
    
    local barOutline = Instance.new("Frame")
    barOutline.Name = "HealthOutline"
    barOutline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    barOutline.BackgroundTransparency = 0.5
    barOutline.BorderSizePixel = 0
    barOutline.Visible = false
    barOutline.Parent = holder
    
    local bar = Instance.new("Frame")
    bar.Name = "HealthBar"
    bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    bar.BorderSizePixel = 0
    bar.Visible = false
    bar.Parent = holder
    
    espElements[player] = {
        Holder = holder,
        Box3D = box3D, BoxCanvas = canvas, Box2D = box2D, Top = top, Bottom = bottom, Left = left, Right = right,
        Tracer = tracer, Circle = circle, HeadDot = headDot, Skeleton = skeletonParts, SkeletonFolder = skeletonFolder,
        Name = nameLabel, Distance = distLabel, HealthOutline = barOutline, HealthBar = bar
    }
end

local function hidePlayerESP(elements)
    if not elements then return end
    if elements.Box3D then elements.Box3D.Visible = false end
    if elements.Box2D then elements.Box2D.Visible = false end
    if elements.Tracer then elements.Tracer.Visible = false end
    if elements.Circle then elements.Circle.Visible = false end
    if elements.HeadDot then elements.HeadDot.Visible = false end
    if elements.SkeletonFolder then elements.SkeletonFolder.Visible = false end
    if elements.Name then elements.Name.Visible = false end
    if elements.Distance then elements.Distance.Visible = false end
    if elements.HealthOutline then elements.HealthOutline.Visible = false end
    if elements.HealthBar then elements.HealthBar.Visible = false end
end

local function clearAllESP()
    for player, elements in pairs(espElements) do
        if elements.Holder then
            elements.Holder:Destroy()
        end
        espElements[player] = nil
    end
    if ESP_GUI then
        ESP_GUI:Destroy()
        ESP_GUI = nil
    end
    -- Limpa os Chams
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Obsidian_Chams" then
            v:Destroy()
        end
    end
end

-- =============================================================================
-- MOTOR PREMIUM ESP (LOOP PRINCIPAL)
-- =============================================================================

local function drawSkeleton(character, elements, espColor)
    if not _G.ESP_Skeleton then return end
    
    local head = character:FindFirstChild("Head", true)
    local torso = character:FindFirstChild("Torso", true) or character:FindFirstChild("UpperTorso", true)
    local leftArm = character:FindFirstChild("Left Arm", true) or character:FindFirstChild("LeftUpperArm", true)
    local rightArm = character:FindFirstChild("Right Arm", true) or character:FindFirstChild("RightUpperArm", true)
    local leftLeg = character:FindFirstChild("Left Leg", true) or character:FindFirstChild("LeftUpperLeg", true)
    local rightLeg = character:FindFirstChild("Right Leg", true) or character:FindFirstChild("RightUpperLeg", true)
    local leftHand = character:FindFirstChild("LeftHand", true) or character:FindFirstChild("LeftLowerArm", true)
    local rightHand = character:FindFirstChild("RightHand", true) or character:FindFirstChild("RightLowerArm", true)
    local leftFoot = character:FindFirstChild("LeftFoot", true) or character:FindFirstChild("LeftLowerLeg", true)
    local rightFoot = character:FindFirstChild("RightFoot", true) or character:FindFirstChild("RightLowerLeg", true)
    
    local joints = {head, torso, leftArm, rightArm, leftLeg, rightLeg, leftHand, rightHand, leftFoot, rightFoot}
    local lines = elements.Skeleton
    
    for i, part in pairs(joints) do
        if part then
            local nextPart = joints[i+1]
            if nextPart then
                local pos1, on1 = Camera:WorldToViewportPoint(part.Position)
                local pos2, on2 = Camera:WorldToViewportPoint(nextPart.Position)
                
                if on1 and on2 then
                    local line = lines[i]
                    if line then
                        local dx = pos2.X - pos1.X
                        local dy = pos2.Y - pos1.Y
                        local length = math.sqrt(dx*dx + dy*dy)
                        local angle = math.atan2(dy, dx)
                        
                        line.Size = UDim2.new(0, length, 0, 1.5)
                        line.Position = UDim2.new(0, pos1.X, 0, pos1.Y)
                        line.Rotation = math.deg(angle)
                        line.Visible = true
                        line.BackgroundColor3 = espColor
                    end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not _G.ESP_Enabled then return end
    
    Camera = workspace.CurrentCamera
    if not Camera then return end
    
    local playersList = Players:GetPlayers()
    local cameraPosition = Camera.CFrame.Position
    local localChar = LocalPlayer.Character
    
    for i = 1, #playersList do
        local player = playersList[i]
        
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart", true)
                local humanoid = character:FindFirstChild("Humanoid", true)
                local head = character:FindFirstChild("Head", true)
                
                if hrp and humanoid and head and hrp:IsA("BasePart") then
                    local currentHealth = humanoid.Health
                    
                    if currentHealth > 0 then
                        local distance = (cameraPosition - hrp.Position).Magnitude
                        
                        if distance <= _G.ESP_MaxDistance then
                            
                            -- =============================================
                            -- FOV CHECK (Se estiver fora do ângulo, esconde)
                            -- =============================================
                            if not isPlayerInFOV(hrp.Position) then
                                if espElements[player] then hidePlayerESP(espElements[player]) end
                                continue
                            end
                            
                            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                            
                            if onScreen and pos.Z > 0 then
                                if not espElements[player] then
                                    createESPForPlayer(player)
                                end
                                
                                local elements = espElements[player]
                                local isAlly = isPlayerAlly(player)
                                local espColor = isAlly and _G.ESP_SafeColor or _G.ESP_DangerColor
                                
                                -- Altura e largura reais
                                local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                                local bottomPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                                local height = math.clamp(math.abs(topPos.Y - bottomPos.Y), 20, 500)
                                local width = height * 0.45
                                local posX = pos.X - width / 2
                                local posY = topPos.Y - 5
                                
                                -- =============================================
                                -- BOX (3D ou 2D)
                                -- =============================================
                                if _G.ESP_Box then
                                    if _G.ESP_Box3D then
                                        -- CAIXA 3D (ViewportFrame)
                                        elements.Box3D.Position = UDim2.new(0, pos.X - width/2, 0, topPos.Y - 5)
                                        elements.Box3D.Size = UDim2.new(0, width, 0, height)
                                        elements.Box3D.Visible = true
                                        
                                        local lines3D = elements.BoxCanvas:GetChildren()
                                        if #lines3D >= 4 then
                                            lines3D[1].Size = UDim2.new(1, -4, 0, 1)
                                            lines3D[1].Position = UDim2.new(0, 2, 0, 0)
                                            lines3D[2].Size = UDim2.new(1, -4, 0, 1)
                                            lines3D[2].Position = UDim2.new(0, 2, 1, 0)
                                            lines3D[3].Size = UDim2.new(0, 1, 1, -4)
                                            lines3D[3].Position = UDim2.new(0, 0, 0, 2)
                                            lines3D[4].Size = UDim2.new(0, 1, 1, -4)
                                            lines3D[4].Position = UDim2.new(1, 0, 0, 2)
                                            
                                            for _, line in pairs(lines3D) do
                                                line.BackgroundColor3 = espColor
                                            end
                                        end
                                        elements.Box2D.Visible = false
                                    else
                                        -- CAIXA 2D
                                        elements.Box2D.Position = UDim2.new(0, posX, 0, posY)
                                        elements.Box2D.Size = UDim2.new(0, width, 0, height)
                                        elements.Box2D.Visible = true
                                        
                                        if _G.ESP_BoxStyle == "Cheia" then
                                            elements.Top.Size = UDim2.new(1, 0, 0, 1)
                                            elements.Top.Position = UDim2.new(0, 0, 0, 0)
                                            elements.Bottom.Size = UDim2.new(1, 0, 0, 1)
                                            elements.Bottom.Position = UDim2.new(0, 0, 1, 0)
                                            elements.Left.Size = UDim2.new(0, 1, 1, 0)
                                            elements.Left.Position = UDim2.new(0, 0, 0, 0)
                                            elements.Right.Size = UDim2.new(0, 1, 1, 0)
                                            elements.Right.Position = UDim2.new(1, 0, 0, 0)
                                        else -- Esquadrinhada
                                            local cornerSize = width * 0.25
                                            elements.Top.Size = UDim2.new(0, cornerSize, 0, 1)
                                            elements.Top.Position = UDim2.new(0, 0, 0, 0)
                                            elements.Bottom.Size = UDim2.new(0, cornerSize, 0, 1)
                                            elements.Bottom.Position = UDim2.new(0, width - cornerSize, 1, 0)
                                            elements.Left.Size = UDim2.new(0, 1, 0, cornerSize)
                                            elements.Left.Position = UDim2.new(0, 0, 0, 0)
                                            elements.Right.Size = UDim2.new(0, 1, 0, cornerSize)
                                            elements.Right.Position = UDim2.new(1, 0, height - cornerSize, 0)
                                        end
                                        
                                        elements.Top.BackgroundColor3 = espColor
                                        elements.Bottom.BackgroundColor3 = espColor
                                        elements.Left.BackgroundColor3 = espColor
                                        elements.Right.BackgroundColor3 = espColor
                                        elements.Box3D.Visible = false
                                    end
                                else
                                    elements.Box3D.Visible = false
                                    elements.Box2D.Visible = false
                                end
                                
                                -- =============================================
                                -- TRACER
                                -- =============================================
                                if _G.ESP_Tracer and localChar and localChar:FindFirstChild("HumanoidRootPart", true) then
                                    local myPos = Camera:WorldToViewportPoint(localChar.HumanoidRootPart.Position)
                                    local x1, y1 = myPos.X, myPos.Y
                                    local x2, y2 = pos.X, pos.Y
                                    
                                    local dx = x2 - x1
                                    local dy = y2 - y1
                                    local length = math.sqrt(dx*dx + dy*dy)
                                    local angle = math.atan2(dy, dx)
                                    
                                    elements.Tracer.Size = UDim2.new(0, length, 0, 1.5)
                                    elements.Tracer.Position = UDim2.new(0, x1, 0, y1)
                                    elements.Tracer.Rotation = math.deg(angle)
                                    elements.Tracer.Visible = true
                                    elements.Tracer.BackgroundColor3 = espColor
                                else
                                    elements.Tracer.Visible = false
                                end
                                
                                -- =============================================
                                -- GROUND CIRCLE
                                -- =============================================
                                if _G.ESP_Circle then
                                    local circleSize = _G.ESP_CircleSize * 15
                                    local circlePos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0))
                                    elements.Circle.Position = UDim2.new(0, circlePos.X - circleSize/2, 0, circlePos.Y - circleSize/2)
                                    elements.Circle.Size = UDim2.new(0, circleSize, 0, circleSize)
                                    elements.Circle.Visible = true
                                    elements.Circle.BackgroundColor3 = espColor
                                    elements.Circle.BackgroundTransparency = 0.4
                                else
                                    elements.Circle.Visible = false
                                end
                                
                                -- =============================================
                                -- HEAD DOT
                                -- =============================================
                                if _G.ESP_HeadDot then
                                    local dotPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                                    elements.HeadDot.Position = UDim2.new(0, dotPos.X - 3, 0, dotPos.Y - 3)
                                    elements.HeadDot.Size = UDim2.new(0, 6, 0, 6)
                                    elements.HeadDot.Visible = true
                                    elements.HeadDot.BackgroundColor3 = espColor
                                else
                                    elements.HeadDot.Visible = false
                                end
                                
                                -- =============================================
                                -- SKELETON
                                -- =============================================
                                if _G.ESP_Skeleton then
                                    drawSkeleton(character, elements, espColor)
                                    elements.SkeletonFolder.Visible = true
                                else
                                    elements.SkeletonFolder.Visible = false
                                end
                                
                                -- =============================================
                                -- NOME
                                -- =============================================
                                if _G.ESP_Name then
                                    elements.Name.Text = player.Name
                                    elements.Name.Position = UDim2.new(0, pos.X - 100, 0, posY - 22)
                                    elements.Name.Size = UDim2.new(0, 200, 0, 14)
                                    elements.Name.Visible = true
                                else
                                    elements.Name.Visible = false
                                end
                                
                                -- =============================================
                                -- DISTÂNCIA
                                -- =============================================
                                if _G.ESP_Distance then
                                    elements.Distance.Text = math.floor(distance) .. "m"
                                    elements.Distance.Position = UDim2.new(0, pos.X - 100, 0, posY + height + 4)
                                    elements.Distance.Size = UDim2.new(0, 200, 0, 12)
                                    elements.Distance.Visible = true
                                else
                                    elements.Distance.Visible = false
                                end
                                
                                -- =============================================
                                -- VIDA
                                -- =============================================
                                if _G.ESP_Health then
                                    local healthRatio = math.clamp(currentHealth / humanoid.MaxHealth, 0, 1)
                                    local barHeight = height * healthRatio
                                    local barWidth = 3
                                    local padding = 4
                                    
                                    elements.HealthOutline.Position = UDim2.new(0, posX - barWidth - padding, 0, posY)
                                    elements.HealthOutline.Size = UDim2.new(0, barWidth, 0, height)
                                    elements.HealthOutline.Visible = true
                                    
                                    elements.HealthBar.Position = UDim2.new(0, posX - barWidth - padding, 0, posY + height - barHeight)
                                    elements.HealthBar.Size = UDim2.new(0, barWidth, 0, barHeight)
                                    elements.HealthBar.BackgroundColor3 = Color3.fromHSV(healthRatio * 0.33, 1, 1)
                                    elements.HealthBar.Visible = true
                                else
                                    elements.HealthOutline.Visible = false
                                    elements.HealthBar.Visible = false
                                end
                                
                            else
                                if espElements[player] then hidePlayerESP(espElements[player]) end
                            end
                        else
                            if espElements[player] then hidePlayerESP(espElements[player]) end
                        end
                    else
                        if espElements[player] then hidePlayerESP(espElements[player]) end
                    end
                else
                    if espElements[player] then hidePlayerESP(espElements[player]) end
                end
            else
                if espElements[player] then hidePlayerESP(espElements[player]) end
            end
        end
    end
end)

-- =============================================================================
-- SISTEMA DE CHAMS (WALLHACK)
-- =============================================================================

local chamsRunning = false

local function updateChams()
    if not _G.ESP_Chams then
        if chamsRunning then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Obsidian_Chams" then
                    v:Destroy()
                end
            end
            chamsRunning = false
        end
        return
    end
    
    chamsRunning = true
    local chamsColor = _G.ESP_ChamsColor
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    if not part:FindFirstChild("Obsidian_Chams") then
                        local chams = Instance.new("BoxHandleAdornment")
                        chams.Name = "Obsidian_Chams"
                        chams.Size = part.Size + Vector3.new(0.2, 0.2, 0.2)
                        chams.Adornee = part
                        chams.ZIndex = 10
                        chams.AlwaysOnTop = true
                        chams.Transparency = 0.5
                        chams.Color3 = chamsColor
                        chams.Parent = part
                    else
                        local chams = part:FindFirstChild("Obsidian_Chams")
                        if chams then
                            chams.Color3 = chamsColor
                            chams.Transparency = 0.5
                        end
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(updateChams)
    end
end)

-- =============================================================================
-- UI SETTINGS E MANAGERS
-- =============================================================================

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
    Title = "Obsidian Ultra Premium - Full",
    Description = "✅ 2D/3D Box + Skeleton + Chams + FOV\n✅ Visual TWD Online",
    Time = 6,
})
