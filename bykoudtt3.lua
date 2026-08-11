-- =============================================================================
-- QA VISUALS - ESP DE TESTE
-- LocalScript
-- Coloque em StarterPlayer > StarterPlayerScripts
-- =============================================================================

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

-- =============================================================================
-- 3. GUI
-- =============================================================================

local GuiParent = LocalPlayer:WaitForChild("PlayerGui")

local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "QA_Visuals_Interface"
MenuGui.ResetOnSpawn = false
MenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MenuGui.Parent = GuiParent

-- =============================================================================
-- 4. JANELA PRINCIPAL
-- =============================================================================

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = MenuGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- =============================================================================
-- 5. TOP BAR
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
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "THE WALKING DEAD 3 — QA VISUALS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local AccLine = Instance.new("Frame")
AccLine.Size = UDim2.new(1, 0, 0, 2)
AccLine.Position = UDim2.new(0, 0, 0, 48)
AccLine.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
AccLine.BorderSizePixel = 0
AccLine.Parent = TopBar

-- =============================================================================
-- 6. PAINEL LATERAL
-- =============================================================================

local SidePanel = Instance.new("Frame")
SidePanel.Size = UDim2.new(0, 150, 1, -50)
SidePanel.Position = UDim2.new(0, 0, 0, 50)
SidePanel.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
SidePanel.BorderSizePixel = 0
SidePanel.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -150, 1, -50)
ContentContainer.Position = UDim2.new(0, 150, 0, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local function addTab(name, index, isActive)

	local tabBtn = Instance.new("TextButton")

	tabBtn.Size = UDim2.new(1, -20, 0, 36)
	tabBtn.Position = UDim2.new(0, 10, 0, 15 + (index * 42))

	tabBtn.BackgroundColor3 =
		isActive
		and Color3.fromRGB(30, 30, 30)
		or Color3.fromRGB(26, 26, 26)

	tabBtn.BorderSizePixel = 0
	tabBtn.Font = Enum.Font.SourceSansBold
	tabBtn.TextSize = 13

	tabBtn.TextColor3 =
		isActive
		and Color3.fromRGB(255, 255, 255)
		or Color3.fromRGB(140, 140, 140)

	tabBtn.Text = "  " .. name
	tabBtn.TextXAlignment = Enum.TextXAlignment.Left
	tabBtn.Parent = SidePanel

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = tabBtn

	if isActive then

		local indicator = Instance.new("Frame")

		indicator.Size = UDim2.new(0, 3, 0, 16)
		indicator.Position = UDim2.new(0, 0, 0.5, -8)
		indicator.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
		indicator.BorderSizePixel = 0
		indicator.Parent = tabBtn

	end

	return tabBtn
end

addTab("ESP Sobreviventes", 0, true)
addTab("ESP Infectados", 1, false)
addTab("ESP Suprimentos", 2, false)

-- =============================================================================
-- 7. CARD DE CONFIGURAÇÕES
-- =============================================================================

local CardFrame = Instance.new("Frame")
CardFrame.Size = UDim2.new(1, -30, 1, -30)
CardFrame.Position = UDim2.new(0, 15, 0, 15)
CardFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
CardFrame.BorderSizePixel = 0
CardFrame.Parent = ContentContainer

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 8)
CardCorner.Parent = CardFrame

-- =============================================================================
-- 8. TOGGLE
-- =============================================================================

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(0, 200, 0, 40)
ToggleLabel.Position = UDim2.new(0, 20, 0, 20)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "Rastrear Jogadores"
ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
ToggleLabel.TextSize = 14
ToggleLabel.Font = Enum.Font.SourceSansBold
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.Parent = CardFrame

local ToggleBG = Instance.new("TextButton")
ToggleBG.Size = UDim2.new(0, 45, 0, 22)
ToggleBG.Position = UDim2.new(1, -65, 0, 29)
ToggleBG.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleBG.BorderSizePixel = 0
ToggleBG.Text = ""
ToggleBG.Parent = CardFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBG

local ToggleBall = Instance.new("Frame")
ToggleBall.Size = UDim2.new(0, 16, 0, 16)
ToggleBall.Position = UDim2.new(0, 25, 0.5, -8)
ToggleBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleBall.BorderSizePixel = 0
ToggleBall.Parent = ToggleBG

local ToggleBallCorner = Instance.new("UICorner")
ToggleBallCorner.CornerRadius = UDim.new(1, 0)
ToggleBallCorner.Parent = ToggleBall

-- =============================================================================
-- 9. DISTÂNCIA
-- =============================================================================

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(0, 200, 0, 40)
SliderLabel.Position = UDim2.new(0, 20, 0, 80)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Distância de Renderização"
SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SliderLabel.TextSize = 14
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = CardFrame

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(1, -40, 0, 36)
SliderBtn.Position = UDim2.new(0, 20, 0, 120)
SliderBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
SliderBtn.BorderSizePixel = 0
SliderBtn.Font = Enum.Font.SourceSansBold
SliderBtn.TextSize = 13
SliderBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderBtn.Text = "Alcance Máximo: 5000m"
SliderBtn.Parent = CardFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 6)
SliderCorner.Parent = SliderBtn

-- =============================================================================
-- 10. FOOTER
-- =============================================================================

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 30)
Footer.Position = UDim2.new(0, 0, 1, -30)
Footer.BackgroundTransparency = 1
Footer.Text = "Pressione [ K ] para ocultar a interface"
Footer.TextColor3 = Color3.fromRGB(90, 90, 90)
Footer.TextSize = 12
Footer.Font = Enum.Font.SourceSansItalic
Footer.Parent = CardFrame

-- =============================================================================
-- 11. ESP GUI
-- =============================================================================

local EspGui = Instance.new("ScreenGui")
EspGui.Name = "QA_ESP_Render"
EspGui.ResetOnSpawn = false
EspGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
EspGui.Parent = GuiParent

local espElements = {}

-- =============================================================================
-- 12. CRIAR ESP
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
	box.BorderColor3 = Color3.fromRGB(180, 40, 40)
	box.BorderSizePixel = 1
	box.Visible = false
	box.Parent = holder

	elements.Box = box

	-- NOME
	local nameLabel = Instance.new("TextLabel")

	nameLabel.Name = "Name"
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 12
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.Visible = false
	nameLabel.Parent = holder

	elements.Name = nameLabel

	-- DISTÂNCIA
	local distLabel = Instance.new("TextLabel")

	distLabel.Name = "Distance"
	distLabel.BackgroundTransparency = 1
	distLabel.TextColor3 = Color3.fromRGB(240, 200, 50)
	distLabel.TextSize = 11
	distLabel.Font = Enum.Font.SourceSansBold
	distLabel.TextStrokeTransparency = 0
	distLabel.TextXAlignment = Enum.TextXAlignment.Center
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
-- 13. REMOVER ESP
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
-- 14. OCULTAR ESP
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

local function hideAllActiveESP()

	for _, elements in pairs(espElements) do
		hidePlayerESP(elements)
	end
end

-- =============================================================================
-- 15. TOGGLE
-- =============================================================================

ToggleBG.MouseButton1Click:Connect(function()

	EspPlayersEnabled = not EspPlayersEnabled

	if EspPlayersEnabled then

		TweenService:Create(
			ToggleBG,
			TweenInfo.new(0.2),
			{
				BackgroundColor3 = Color3.fromRGB(180, 40, 40)
			}
		):Play()

		TweenService:Create(
			ToggleBall,
			TweenInfo.new(0.2),
			{
				Position = UDim2.new(0, 25, 0.5, -8)
			}
		):Play()

		ToggleLabel.TextColor3 =
			Color3.fromRGB(220, 220, 220)

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

		ToggleLabel.TextColor3 =
			Color3.fromRGB(100, 100, 100)

		hideAllActiveESP()
	end
end)

-- =============================================================================
-- 16. DISTÂNCIA
-- =============================================================================

SliderBtn.MouseButton1Click:Connect(function()

	if MaxEspDistance == 5000 then

		MaxEspDistance = 1500

		SliderBtn.Text =
			"Alcance Limitado: 1500m (Otimizado)"

	else

		MaxEspDistance = 5000

		SliderBtn.Text =
			"Alcance Máximo: 5000m (Máximo)"
	end
end)

-- =============================================================================
-- 17. TECLA K
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
-- 18. MOTOR ESP
-- =============================================================================

RunService.RenderStepped:Connect(function()

	if not EspPlayersEnabled then
		return
	end

	Camera = workspace.CurrentCamera

	if not Camera then
		return
	end

	local playersList = Players:GetPlayers()
	local cameraPosition = Camera.CFrame.Position

	for i = 1, #playersList do

		local player = playersList[i]

		if player ~= LocalPlayer then

			local character = player.Character

			if character then

				local hrp =
					character:FindFirstChild("HumanoidRootPart")

				local humanoid =
					character:FindFirstChildOfClass("Humanoid")

				if hrp
					and humanoid
					and hrp:IsA("BasePart")
					and humanoid:IsA("Humanoid")
				then

					local currentHealth =
						humanoid.Health

					if currentHealth > 0 then

						local distance =
							(cameraPosition - hrp.Position).Magnitude

						if distance <= MaxEspDistance then

							local pos, onScreen =
								Camera:WorldToViewportPoint(
									hrp.Position
								)

							if onScreen and pos.Z > 0 then

								if not espElements[player] then
									createSafeESP(player)
								end

								local elements =
									espElements[player]

								-- =====================================================
								-- MATEMÁTICA ORIGINAL MODIFICADA
								-- =====================================================

								local factor = 45

								local sizeX =
									(1000 / distance)
									* (factor / 45)

								local sizeY =
									(1600 / distance)
									* (factor / 45)

								sizeX =
									math.clamp(
										sizeX,
										6,
										120
									)

								sizeY =
									math.clamp(
										sizeY,
										10,
										200
									)

								local posX =
									pos.X - sizeX / 2

								local posY =
									pos.Y - sizeY / 2

								-- =====================================================
								-- BOX
								-- =====================================================

								elements.Box.Position =
									UDim2.new(
										0,
										posX,
										0,
										posY
									)

								elements.Box.Size =
									UDim2.new(
										0,
										sizeX,
										0,
										sizeY
									)

								elements.Box.Visible = true

								-- =====================================================
								-- NOME
								-- =====================================================

								elements.Name.Text =
									player.Name

								elements.Name.Position =
									UDim2.new(
										0,
										pos.X - 100,
										0,
										posY - 28
									)

								elements.Name.Size =
									UDim2.new(
										0,
										200,
										0,
										14
									)

								elements.Name.Visible = true

								-- =====================================================
								-- DISTÂNCIA
								-- =====================================================

								elements.Distance.Text =
									math.floor(distance) .. "m"

								elements.Distance.Position =
									UDim2.new(
										0,
										pos.X - 100,
										0,
										posY - 16
									)

								elements.Distance.Size =
									UDim2.new(
										0,
										200,
										0,
										14
									)

								elements.Distance.Visible = true

								-- =====================================================
								-- VIDA
								-- =====================================================

								local maxHealth =
									math.max(
										humanoid.MaxHealth,
										1
									)

								local healthRatio =
									math.clamp(
										currentHealth / maxHealth,
										0,
										1
									)

								local barHeight =
									sizeY * healthRatio

								local barWidth = 2
								local padding = 4

								elements.HealthOutline.Position =
									UDim2.new(
										0,
										posX - barWidth - padding - 1,
										0,
										posY - 1
									)

								elements.HealthOutline.Size =
									UDim2.new(
										0,
										barWidth + 2,
										0,
										sizeY + 2
									)

								elements.HealthOutline.Visible = true

								elements.HealthBar.Position =
									UDim2.new(
										0,
										posX - barWidth - padding,
										0,
										posY + sizeY - barHeight
									)

								elements.HealthBar.Size =
									UDim2.new(
										0,
										barWidth,
										0,
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
									hidePlayerESP(
										espElements[player]
									)
								end
							end

						else

							if espElements[player] then
								hidePlayerESP(
									espElements[player]
								)
							end
						end

					else

						if espElements[player] then
							hidePlayerESP(
								espElements[player]
							)
						end
					end

				else

					if espElements[player] then
						hidePlayerESP(
							espElements[player]
						)
					end
				end

			else

				if espElements[player] then
					hidePlayerESP(
						espElements[player]
					)
				end
			end
		end
	end
end)

-- =============================================================================
-- 19. LIMPEZA
-- =============================================================================

Players.PlayerRemoving:Connect(function(player)
	removeSafeESP(player)
end)

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
