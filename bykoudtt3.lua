-- =============================================================================
-- 1. ISOLAMENTO DE AMBIENTE E PROTEÇÃO ANTI-HOOKING
-- =============================================================================
local getService = game.GetService
local Players = getService(game, "Players")
local RunService = getService(game, "RunService")
local UserInputService = getService(game, "UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local findFirstChild = game.FindFirstChild
local isA = game.IsA

_G.EspPlayersEnabled = true
_G.MaxEspDistance = 5000 

local function generateRandomName()
    local length = math.random(14, 26)
    local array = {}
    for i = 1, length do array[i] = string.char(math.random(65, 90)) end
    return table.concat(array)
end

-- =============================================================================
-- 2. INTERFACE GRÁFICA PROFISSIONAL OFFLINE (ESTILO RAYFIELD)
-- =============================================================================
local GuiParent = getService(game, "CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = generateRandomName()
MenuGui.ResetOnSpawn = false
MenuGui.Parent = GuiParent
if typeof(getfenv().protect_gui) == "function" then getfenv().protect_gui(MenuGui) end

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = MenuGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 9)
MainCorner.Parent = MainFrame

-- Barra de Topo
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 9)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TWD Online 3 | Painel de Sobrevivência"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Linha Divisória Vermelha
local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, 0, 0, 1)
Line.Position = UDim2.new(0, 0, 0, 45)
Line.BackgroundColor3 = Color3.fromRGB(230, 50, 50)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- Menu Lateral de Abas
local LeftMenu = Instance.new("Frame")
LeftMenu.Size = UDim2.new(0, 140, 1, -46)
LeftMenu.Position = UDim2.new(0, 0, 0, 46)
LeftMenu.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
LeftMenu.BorderSizePixel = 0
LeftMenu.Parent = MainFrame

-- Container de Conteúdo (Direita)
local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -140, 1, -46)
ContentHolder.Position = UDim2.new(0, 140, 0, 46)
ContentHolder.BackgroundTransparency = 1
ContentHolder.Parent = MainFrame

-- Abas Laterais
local function createTabButton(name, posIndex)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 32)
    btn.Position = UDim2.new(0, 8, 0, 12 + (posIndex * 38))
    btn.BackgroundColor3 = posIndex == 0 and Color3.fromRGB(30, 30, 45) or Color3.fromRGB(22, 22, 30)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.TextColor3 = posIndex == 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
    btn.Text = name
    btn.Parent = LeftMenu
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 5) c.Parent = btn
    return btn
end

local Tab1 = createTabButton("ESP Jogadores", 0)
local Tab2 = createTabButton("ESP Zumbis (Breve)", 1)
local Tab3 = createTabButton("ESP Loot (Breve)", 2)

-- Elementos Interativos (Botões Internos da Aba Ativa)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -30, 0, 40)
ToggleBtn.Position = UDim2.new(0, 15, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Caixas 2D: LIGADO"
ToggleBtn.Parent = ContentHolder
local tc1 = Instance.new("UICorner") tc1.CornerRadius = UDim.new(0, 6) tc1.Parent = ToggleBtn

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(1, -30, 0, 40)
SliderBtn.Position = UDim2.new(0, 15, 0, 75)
SliderBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SliderBtn.Font = Enum.Font.SourceSansBold
SliderBtn.TextSize = 14
SliderBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderBtn.Text = "Distância Máxima: 5000m"
SliderBtn.Parent = ContentHolder
local tc2 = Instance.new("UICorner") tc2.CornerRadius = UDim.new(0, 6) tc2.Parent = SliderBtn

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, 0, 0, 20)
InfoText.Position = UDim2.new(0, 0, 1, -25)
InfoText.BackgroundTransparency = 1
InfoText.Text = "Pressione [ K ] para ocultar ou exibir este menu"
InfoText.TextColor3 = Color3.fromRGB(110, 110, 120)
InfoText.TextSize = 12
InfoText.Font = Enum.Font.SourceSansItalic
InfoText.Parent = ContentHolder

-- Função de Ocultar Desenhos do ESP
local function hideAllActiveESP(elementsTable)
    for _, elements in pairs(elementsTable or {}) do
        if elements.Box then elements.Box.Visible = false end
        if elements.Name then elements.Name.Visible = false end
        if elements.Distance then elements.Distance.Visible = false end
        if elements.HealthOutline then elements.HealthOutline.Visible = false end
        if elements.HealthBar then elements.HealthBar.Visible = false end
    end
end

local espElements = {}

-- Sincronização dos Cliques
ToggleBtn.MouseButton1Click:Connect(function()
    _G.EspPlayersEnabled = not _G.EspPlayersEnabled
    if _G.EspPlayersEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        ToggleBtn.Text = "Caixas 2D: LIGADO"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
        ToggleBtn.Text = "Caixas 2D: DESLIGADO"
        hideAllActiveESP(espElements)
    end
end)

SliderBtn.MouseButton1Click:Connect(function()
    if _G.MaxEspDistance == 5000 then
        _G.MaxEspDistance = 1500
        SliderBtn.Text = "Distância Máxima: 1500m (Performance)"
    else
        _G.MaxEspDistance = 5000
        SliderBtn.Text = "Distância Máxima: 5000m (Máximo)"
    end
end)

-- Tecla K para Minimizar a UI
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- =============================================================================
-- 3. MOTOR DO ESP 2D SEGURO (MANTIDO 100% BLINDADO)
-- =============================================================================
local EspGui = Instance.new("ScreenGui")
EspGui.Name = generateRandomName()
EspGui.ResetOnSpawn = false
EspGui.Parent = GuiParent
if typeof(getfenv().protect_gui) == "function" then getfenv().protect_gui(EspGui) end

local function createSafeESP(player)
    local elements = {}
    local holder = Instance.new("Folder")
    holder.Name = generateRandomName()
    holder.Parent = EspGui

    local box = Instance.new("Frame")
    box.Name = generateRandomName()
    box.BackgroundTransparency = 1
    box.BorderColor3 = Color3.fromRGB(230, 50, 50)
    box.BorderSizePixel = 1.5
    box.Visible = false
    box.Parent = holder
    elements.Box = box

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = generateRandomName()
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Visible = false
    nameLabel.Parent = holder
    elements.Name = nameLabel

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = generateRandomName()
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(240, 200, 50)
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.SourceSansBold
    distLabel.TextStrokeTransparency = 0
    distLabel.Visible = false
    distLabel.Parent = holder
    elements.Distance = distLabel

    local barOutline = Instance.new("Frame")
    barOutline.Name = generateRandomName()
    barOutline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    barOutline.BorderSizePixel = 0
    barOutline.Visible = false
    barOutline.Parent = holder
    elements.HealthOutline = barOutline

    local bar = Instance.new("Frame")
    bar.Name = generateRandomName()
    bar.BorderSizePixel = 0
    bar.Visible = false
    bar.Parent = holder
    elements.HealthBar = bar
    
    elements.Holder = holder
    espElements[player] = elements
end

local function removeSafeESP(player)
    if espElements[player] then
        if espElements[player].Holder then espElements[player].Holder:Destroy() end
        table.clear(espElements[player])
        espElements[player] = nil
    end
end

local function hidePlayerESP(elements)
    if elements.Box then elements.Box.Visible = false end
    if elements.Name then elements.Name.Visible = false end
    if elements.Distance then elements.Distance.Visible = false end
    if elements.HealthOutline then elements.HealthOutline.Visible = false end
    if elements.HealthBar then elements.HealthBar.Visible = false end
end

RunService.RenderStepped:Connect(function()
    if not _G.EspPlayersEnabled then return end

    local playersList = Players:GetPlayers()
    local camCFrame = Camera.CFrame
    
    for i = 1, #playersList do
