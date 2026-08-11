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

-- Variáveis de Controle Globais
_G.EspPlayersEnabled = true
_G.MaxEspDistance = 5000 

local function generateRandomName()
    local length = math.random(14, 26)
    local array = {}
    for i = 1, length do array[i] = string.char(math.random(65, 90)) end
    return table.concat(array)
end

-- =============================================================================
-- 2. CARREGAMENTO DA RAYFIELD VIA WEB
-- =============================================================================
local Rayfield = nil

local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://githubusercontent.com'))()
end)

if not success or not Rayfield then
    warn("Falha ao conectar com o GitHub da Rayfield. Erro: ", err)
    return
end

local Window = Rayfield:CreateWindow({
   Name = "TWD Online 3 | Alpha v1.0",
   LoadingTitle = "Carregando Módulos Web...",
   LoadingSubtitle = "Aguarde a sincronização",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local VisualsTab = Window:CreateTab("ESP Jogadores", 4483362458)

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

VisualsTab:CreateToggle({
   Name = "Ativar ESP (Caixas 2D)",
   CurrentValue = _G.EspPlayersEnabled,
   Flag = "Toggle_PlayersESP",
   Callback = function(Value)
       _G.EspPlayersEnabled = Value
       if not Value then
           hideAllActiveESP(espElements)
       end
   end,
})

VisualsTab:CreateSlider({
   Name = "Distância Máxima (Metros)",
   Min = 100,
   Max = 5000,
   CurrentValue = _G.MaxEspDistance,
   Increment = 100,
   Suffix = "m",
   Flag = "Slider_MaxDistance",
   Callback = function(Value)
       _G.MaxEspDistance = Value
   end,
})

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.K then
        pcall(function()
            Rayfield:Minimize()
        end)
    end
end)

-- =============================================================================
-- 3. MOTOR DO ESP 2D SEGURO (MANTIDO 100% BLINDADO)
-- =============================================================================
local GuiParent = getService(game, "CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
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
        local player = playersList[i]
        
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local hrp = findFirstChild(character, "HumanoidRootPart")
                local humanoid = findFirstChild(character, "Humanoid")
                
                if hrp and humanoid and isA(hrp, "BasePart") and isA(humanoid, "Humanoid") then
                    local currentHealth = humanoid.Health
                    
                    if currentHealth > 0 then
                        local distance = (camCFrame.Position - hrp.Position).Magnitude

                        if distance <= _G.MaxEspDistance then
                            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                            if onScreen then
                                if not espElements[player] then createSafeESP(player) end
                                local elements = espElements[player]
                                
                                local sizeX = 2100 / distance
                                local sizeY = 3100 / distance
                                local posX = pos.X - sizeX / 2
                                local posY = pos.Y - sizeY / 2

                                elements.Box.Position = UDim2.new(0, posX, 0, posY)
                                elements.Box.Size = UDim2.new(0, sizeX, 0, sizeY)
                                elements.Box.Visible = true

                                elements.Name.Text = player.Name
                                elements.Name.Position = UDim2.new(0, pos.X - 100, 0, posY - 20)
                                elements.Name.Size = UDim2.new(0, 200, 0, 15)
                                elements.Name.Visible = true

                                elements.Distance.Text = math.floor(distance) .. "m"
                                elements.Distance.Position = UDim2.new(0, pos.X - 100, 0, posY + sizeY + 5)
                                elements.Distance.Size = UDim2.new(0, 200, 0, 15)
                                elements.Distance.Visible = true

                                local healthRatio = math.clamp(currentHealth / humanoid.MaxHealth, 0, 1)
                                local barHeight = sizeY * healthRatio
                                local barWidth = 3
                                local padding = 5

                                elements.HealthOutline.Position = UDim2.new(0, posX - barWidth - padding - 1, 0, posY - 1)
                                elements.HealthOutline.Size = UDim2.new(0, barWidth + 2, 0, sizeY + 2)
                                elements.HealthOutline.Visible = true

                                elements.HealthBar.Position = UDim2.new(0, posX - barWidth - padding, 0, posY + sizeY - barHeight)
                                elements.HealthBar.Size = UDim2.new(0, barWidth, 0, barHeight)
                                elements.HealthBar.BackgroundColor3 = Color3.fromHSV(healthRatio * 0.33, 1, 1)
                                elements.HealthBar.Visible = true
                            else
                                if espElements[player] then hidePlayerESP(espElements[player]) end
                            end
                        else
                            if espElements[player] then hidePlayerESP(espElements[player]) end
                        end
                    else
                        if espElements[player] then removeSafeESP(player) end
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

Players.PlayerRemoving:Connect(removeSafeESP)
