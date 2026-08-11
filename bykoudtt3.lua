--[[
    QA ESP - Ferramenta de teste visual
    Coloque como LocalScript em:

    StarterPlayer
        > StarterPlayerScripts

    Recursos:
    - ESP de jogadores
    - Box 2D
    - Nome
    - Distância
    - Barra de vida
    - Toggle ativar/desativar
    - Limite de distância
    - Tecla K para ocultar/mostrar interface
]]

-- =============================================================================
-- 1. SERVIÇOS
-- =============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =============================================================================
-- 2. CONFIGURAÇÕES
-- =============================================================================

local EspPlayersEnabled = true
local MaxEspDistance = 5000

local THEME_RED = Color3.fromRGB(180, 40, 40)
local DARK_1 = Color3.fromRGB(18, 18, 18)
local DARK_2 = Color3.fromRGB(24, 24, 24)
local DARK_3 = Color3.fromRGB(30, 30, 30)
local TEXT_PRIMARY = Color3.fromRGB(255, 255, 255)
local TEXT_SECONDARY = Color3.fromRGB(180, 180, 180)

-- =============================================================================
-- 3. GUI PRINCIPAL
-- =============================================================================

local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "QA_ESP_Interface"
MenuGui.ResetOnSpawn = false
MenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MenuGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(520, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = DARK_1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = MenuGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- =============================================================================
-- 4. TOP BAR
-- =============================================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.fromOffset(20, 0)
Title.BackgroundTransparency = 1
Title.Text = "THE WALKING DEAD 3 — QA VISUALS"
Title.TextColor3 = TEXT_PRIMARY
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local AccLine = Instance.new("Frame")
AccLine.Size = UDim2.new(1, 0, 0, 2)
AccLine.Position = UDim2.new(0, 0, 1, -2)
AccLine.BackgroundColor3 = THEME_RED
AccLine.BorderSizePixel = 0
AccLine.Parent = TopBar

-- =============================================================================
-- 5. PAINEL LATERAL
-- =============================================================================

local SidePanel = Instance.new("Frame")
SidePanel.Size = UDim2.new(0, 150, 1, -50)
SidePanel.Position = UDim2.fromOffset(0, 50)
SidePanel.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
SidePanel.BorderSizePixel = 0
SidePanel.Parent = MainFrame

local function addTab(name, index, isActive)
    local tabBtn = Instance.new("TextButton")

    tabBtn.Size = UDim2.new(1, -20, 0, 36)
    tabBtn.Position = UDim2.fromOffset(10, 15 + (index * 42))
    tabBtn.BackgroundColor3 = isActive
        and Color3.fromRGB(30, 30, 30)
        or Color3.fromRGB(26, 26, 26)

    tabBtn.BorderSizePixel = 0
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 13
    tabBtn.TextColor3 = isActive
        and TEXT_PRIMARY
        or Color3.fromRGB(140, 140, 140)

    tabBtn.Text = "  " .. name
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = SidePanel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabBtn

    if isActive then
        local indicator = Instance.new("Frame")

        indicator.Size = UDim2.fromOffset(3, 16)
        indicator.Position = UDim2.new(0, 0, 0.5, -8)
        indicator.BackgroundColor3 = THEME_RED
        indicator.BorderSizePixel = 0
        indicator.Parent = tabBtn
    end

    return tabBtn
end

addTab("ESP Sobreviventes", 0, true)
addTab("ESP Infectados", 1, false)
addTab("ESP Suprimentos", 2, false)

-- =============================================================================
-- 6. CONTAINER DE CONTEÚDO
-- =============================================================================

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -150, 1, -50)
ContentContainer.Position = UDim2.fromOffset(150, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local CardFrame = Instance.new("Frame")
CardFrame.Size = UDim2.new(1, -30, 1, -30)
CardFrame.Position = UDim2.fromOffset(15, 15)
CardFrame.BackgroundColor3 = DARK_2
CardFrame.BorderSizePixel = 0
CardFrame.Parent = ContentContainer

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 8)
CardCorner.Parent = CardFrame

-- =============================================================================
-- 7. TOGGLE ESP
-- =============================================================================

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.fromOffset(200, 40)
ToggleLabel.Position = UDim2.fromOffset(20, 20)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "Rastrear Jogadores"
ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
ToggleLabel.TextSize = 14
ToggleLabel.Font = Enum.Font.GothamBold
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.Parent = CardFrame

local ToggleBG = Instance.new("TextButton")
ToggleBG.Size = UDim2.fromOffset(45, 22)
ToggleBG.Position = UDim2.new(1, -65, 0, 29)
ToggleBG.BackgroundColor3 = THEME_RED
ToggleBG.BorderSizePixel = 0
ToggleBG.Text = ""
ToggleBG.Parent = CardFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBG

local ToggleBall = Instance.new("Frame")
ToggleBall.Size = UDim2.fromOffset(16, 16)
ToggleBall.Position = UDim2.new(0, 25, 0.5, -8)
ToggleBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleBall.BorderSizePixel = 0
ToggleBall.Parent = ToggleBG

local ToggleBallCorner = Instance.new("UICorner")
ToggleBallCorner.CornerRadius = UDim.new(1, 0)
ToggleBallCorner.Parent = ToggleBall

-- =============================================================================
-- 8. DISTÂNCIA
-- =============================================================================

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.fromOffset(250, 40)
SliderLabel.Position = UDim2.fromOffset(20, 80)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Distância de Renderização"
SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SliderLabel.TextSize = 14
SliderLabel.Font = Enum.Font.GothamBold
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = CardFrame

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(1, -40, 0, 36)
SliderBtn.Position = UDim2.fromOffset(20, 120)
SliderBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
SliderBtn.BorderSizePixel = 0
SliderBtn.Font = Enum.Font.GothamBold
SliderBtn.TextSize = 13
SliderBtn.TextColor3 = TEXT_PRIMARY
SliderBtn.Text = "Alcance Máximo: 5000m"
SliderBtn.Parent = CardFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 6)
SliderCorner.Parent = SliderBtn

-- =============================================================================
-- 9. FOOTER
-- =============================================================================

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -20, 0, 30)
Footer.Position = UDim2.new(0, 10, 1, -40)
Footer.BackgroundTransparency = 1
Footer.Text = "Pressione [ K ] para ocultar a interface"
Footer.TextColor3 = Color3.fromRGB(90, 90, 90)
Footer.TextSize = 12
Footer.Font = Enum.Font.Gotham
Footer.Parent = CardFrame

-- =============================================================================
-- 10. ESP GUI
-- =============================================================================

local EspGui = Instance.new("ScreenGui")
EspGui.Name = "QA_ESP_Render"
EspGui.ResetOnSpawn = false
EspGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
EspGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local espElements = {}

-- =============================================================================
-- 11. CRIAÇÃO DOS ELEMENTOS DE ESP
-- =============================================================================

local function createSafeESP(player)

    local elements = {}

    local holder = Instance.new("Folder")
    holder.Name = "ESP_" .. player.UserId
    holder.Parent = EspGui

    -- BOX
    local box = Instance.new("Frame")
    box.Name = "Box"
    box.BackgroundTransparency = 1
    box.BorderColor3 = THEME_RED
    box.BorderSizePixel = 1
    box.Visible = false
    box.Parent = holder

    elements.Box = box

    -- NOME
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = TEXT_PRIMARY
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Visible = false
    nameLabel.Parent = holder

    elements.Name = nameLabel

    -- DISTÂNCIA
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "Distance"
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(240, 200, 50)
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextStrokeTransparency = 0
    distLabel.Visible = false
    distLabel.Parent = holder

    elements.Distance = distLabel

    -- CONTORNO DA VIDA
    local barOutline = Instance.new("Frame")
    barOutline.Name = "HealthOutline"
    barOutline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    barOutline.BorderSizePixel = 0
    barOutline.Visible = false
    barOutline.Parent = holder

    elements.HealthOutline = barOutline

    -- VIDA
    local bar = Instance.new("Frame")
    bar.Name = "HealthBar"
    bar.BorderSizePixel = 0
    bar.Visible = false
    bar.Parent = holder

    elements.HealthBar = bar

    elements.Holder = holder

    espElements[player] = elements
end

-- =============================================================================
-- 12. REMOÇÃO DO ESP
-- =============================================================================

local function removeSafeESP(player)

    local elements = espElements[player]

    if not elements then
        return
    end

    if elements.Holder then
        elements.Holder:Destroy()
    end

    espElements[player] = nil
end

-- =============================================================================
-- 13. OCULTAR ESP
-- =============================================================================

local function hidePlayerESP(elements)

    if not elements then
        return
    end

    if elements.Box then
        elements.Box.Visible = false
    end

    if elements.Name then
        elements.Name.Visible = false
    end

    if elements.Distance then
        elements.Distance.Visible = false
    end

    if elements.HealthOutline then
        elements.HealthOutline.Visible = false
    end

    if elements.HealthBar then
        elements.HealthBar.Visible = false
    end
end

local function hideAllESP()

    for _, elements in pairs(espElements) do
        hidePlayerESP(elements)
    end
end

-- =============================================================================
-- 14. TOGGLE
-- =============================================================================

ToggleBG.MouseButton1Click:Connect(function()

    EspPlayersEnabled = not EspPlayersEnabled

    if EspPlayersEnabled then

        TweenService:Create(
            ToggleBG,
            TweenInfo.new(0.2),
            {
                BackgroundColor3 = THEME_RED
            }
        ):Play()

        TweenService:Create(
            ToggleBall,
            TweenInfo.new(0.2),
            {
                Position = UDim2.new(0, 25, 0.5, -8)
            }
        ):Play()

        ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)

    else

        TweenService:Create(
            ToggleBG,
            TweenInfo.new(0.2),
            {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            }
        ):Play()

        TweenService:Create(
            ToggleBall,
            TweenInfo.new(0.2),
            {
                Position = UDim2.new(0, 4, 0.5, -8)
            }
        ):Play()

        ToggleLabel.TextColor3 = Color3.fromRGB(100, 100, 100)

        hideAllESP()
    end
end)

-- =============================================================================
-- 15. ALTERAÇÃO DA DISTÂNCIA
-- =============================================================================

SliderBtn.MouseButton1Click:Connect(function()

    if MaxEspDistance == 5000 then

        MaxEspDistance = 1500

        SliderBtn.Text = "Alcance Limitado: 1500m"
        SliderBtn.TextColor3 = Color3.fromRGB(180, 180, 180)

    else

        MaxEspDistance = 5000

        SliderBtn.Text = "Alcance Máximo: 5000m"
        SliderBtn.TextColor3 = TEXT_PRIMARY
    end
end)

-- =============================================================================
-- 16. TECLA K
-- =============================================================================

UserInputService.InputBegan:Connect(function(input, processed)

    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- =============================================================================
-- 17. MOTOR DO ESP
-- =============================================================================

RunService.RenderStepped:Connect(function()

    if not EspPlayersEnabled then
        return
    end

    Camera = workspace.CurrentCamera

    if not Camera then
        return
    end

    local cameraPosition = Camera.CFrame.Position

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            local character = player.Character

            if character then

                local hrp = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")

                if hrp and humanoid then

                    if humanoid.Health > 0 then

                        local distance =
                            (cameraPosition - hrp.Position).Magnitude

                        if distance <= MaxEspDistance then

                            local screenPosition, onScreen =
                                Camera:WorldToViewportPoint(hrp.Position)

                            if onScreen and screenPosition.Z > 0 then

                                if not espElements[player] then
                                    createSafeESP(player)
                                end

                                local elements = espElements[player]

                                -- Tamanho aproximado baseado na distância
                                local sizeX =
                                    math.clamp(2100 / distance, 30, 180)

                                local sizeY =
                                    math.clamp(3100 / distance, 50, 260)

                                local posX =
                                    screenPosition.X - (sizeX / 2)

                                local posY =
                                    screenPosition.Y - (sizeY / 2)

                                -- BOX
                                elements.Box.Position =
                                    UDim2.fromOffset(posX, posY)

                                elements.Box.Size =
                                    UDim2.fromOffset(sizeX, sizeY)

                                elements.Box.Visible = true

                                -- NOME
                                elements.Name.Text =
                                    player.DisplayName

                                elements.Name.Position =
                                    UDim2.fromOffset(
                                        screenPosition.X - 100,
                                        posY - 20
                                    )

                                elements.Name.Size =
                                    UDim2.fromOffset(200, 15)

                                elements.Name.Visible = true

                                -- DISTÂNCIA
                                elements.Distance.Text =
                                    math.floor(distance) .. "m"

                                elements.Distance.Position =
                                    UDim2.fromOffset(
                                        screenPosition.X - 100,
                                        posY + sizeY + 5
                                    )

                                elements.Distance.Size =
                                    UDim2.fromOffset(200, 15)

                                elements.Distance.Visible = true

                                -- VIDA
                                local maxHealth =
                                    math.max(humanoid.MaxHealth, 1)

                                local healthRatio =
                                    math.clamp(
                                        humanoid.Health / maxHealth,
                                        0,
                                        1
                                    )

                                local barHeight =
                                    sizeY * healthRatio

                                local barWidth = 3
                                local padding = 5

                                -- CONTORNO
                                elements.HealthOutline.Position =
                                    UDim2.fromOffset(
                                        posX - barWidth - padding - 1,
                                        posY - 1
                                    )

                                elements.HealthOutline.Size =
                                    UDim2.fromOffset(
                                        barWidth + 2,
                                        sizeY + 2
                                    )

                                elements.HealthOutline.Visible = true

                                -- BARRA
                                elements.HealthBar.Position =
                                    UDim2.fromOffset(
                                        posX - barWidth - padding,
                                        posY + sizeY - barHeight
                                    )

                                elements.HealthBar.Size =
                                    UDim2.fromOffset(
                                        barWidth,
                                        barHeight
                                    )

                                elements.HealthBar.BackgroundColor3 =
                                    Color3.fromHSV(
                                        healthRatio * 0.33,
                                        1,
                                        1
                                    )

                                elements.HealthBar.Visible = true

                            else

                                if espElements[player] then
                                    hidePlayerESP(espElements[player])
                                end
                            end

                        else

                            if espElements[player] then
                                hidePlayerESP(espElements[player])
                            end
                        end

                    else

                        if espElements[player] then
                            hidePlayerESP(espElements[player])
                        end
                    end

                else

                    if espElements[player] then
                        hidePlayerESP(espElements[player])
                    end
                end

            else

                if espElements[player] then
                    hidePlayerESP(espElements[player])
                end
            end
        end
    end
end)

-- =============================================================================
-- 18. LIMPEZA QUANDO O JOGADOR SAI
-- =============================================================================

Players.PlayerRemoving:Connect(function(player)
    removeSafeESP(player)
end)

-- =============================================================================
-- 19. LIMPEZA QUANDO O SCRIPT FOR ENCERRADO
-- =============================================================================

script.Destroying:Connect(function()

    for player, elements in pairs(espElements) do

        if elements.Holder then
            elements.Holder:Destroy()
        end

        espElements[player] = nil
    end

    if MenuGui then
        MenuGui:Destroy()
    end

    if EspGui then
        EspGui:Destroy()
    end
end)
