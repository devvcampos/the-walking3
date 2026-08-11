-- =============================================================================
-- 11. ESP SYSTEM (CORRIGIDO - DESLIGA COMPLETAMENTE)
-- =============================================================================

local ESP = {}

-- Função para REMOVER completamente TODOS os ESPs
local function RemoveAllESP()
    for player, data in pairs(ESP) do
        pcall(function()
            if data.BoxOut then data.BoxOut:Remove() end
            if data.Box then data.Box:Remove() end
            if data.Name then data.Name:Remove() end
            if data.Dist then data.Dist:Remove() end
            if data.HealthBg then data.HealthBg:Remove() end
            if data.HealthBar then data.HealthBar:Remove() end
            if data.Line then data.Line:Remove() end
            if data.Dot then data.Dot:Remove() end
        end)
    end
    ESP = {} -- Limpa a tabela completamente
end

-- Função para esconder TODOS os elementos de um ESP
local function HideESP(data)
    if not data then return end
    pcall(function()
        if data.BoxOut then data.BoxOut.Visible = false end
        if data.Box then data.Box.Visible = false end
        if data.Name then data.Name.Visible = false end
        if data.Dist then data.Dist.Visible = false end
        if data.HealthBg then data.HealthBg.Visible = false end
        if data.HealthBar then data.HealthBar.Visible = false end
        if data.Line then data.Line.Visible = false end
        if data.Dot then data.Dot.Visible = false end
    end)
end

-- Função para REMOVER completamente um ESP específico
local function RemoveESP(player)
    local data = ESP[player]
    if data then
        pcall(function()
            if data.BoxOut then data.BoxOut:Remove() end
            if data.Box then data.Box:Remove() end
            if data.Name then data.Name:Remove() end
            if data.Dist then data.Dist:Remove() end
            if data.HealthBg then data.HealthBg:Remove() end
            if data.HealthBar then data.HealthBar:Remove() end
            if data.Line then data.Line:Remove() end
            if data.Dot then data.Dot:Remove() end
        end)
        ESP[player] = nil
    end
end

-- Função para criar ESP
local function CreateESP(player)
    -- Primeiro remove qualquer ESP existente desse player
    RemoveESP(player)
    
    local data = {
        BoxOut = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Dist = Drawing.new("Text"),
        HealthBg = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        Dot = Drawing.new("Circle")
    }
    
    -- Configurar valores padrão (tudo invisível)
    data.BoxOut.Visible = false
    data.Box.Visible = false
    data.Name.Visible = false
    data.Dist.Visible = false
    data.HealthBg.Visible = false
    data.HealthBar.Visible = false
    data.Line.Visible = false
    data.Dot.Visible = false
    
    ESP[player] = data
    return data
end

-- Variável para controlar se o ESP foi desligado
local wasESPMasterOff = false

-- LOOP PRINCIPAL DO ESP
RunService.RenderStepped:Connect(function()
    -- SE O MASTER ESTIVER DESLIGADO, REMOVE TUDO E SAI
    if not Config.ESP_Main then
        if not wasESPMasterOff then
            -- Só remove uma vez quando desliga
            RemoveAllESP()
            wasESPMasterOff = true
        end
        return
    end
    
    -- Resetar flag quando liga
    wasESPMasterOff = false
    
    Camera = workspace.CurrentCamera
    if not Camera then return end
    
    local camPos = Camera.CFrame.Position
    local screenSize = Camera.ViewportSize
    local activePlayers = {}
    
    -- Processa todos os players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            activePlayers[player] = true
            
            local character = player.Character
            if not character then
                RemoveESP(player) -- Remove completamente se não tem character
                continue
            end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if not hrp or not humanoid then
                RemoveESP(player)
                continue
            end
            
            if not hrp:IsA("BasePart") or not humanoid:IsA("Humanoid") then
                RemoveESP(player)
                continue
            end
            
            if humanoid.Health <= 0 then
                RemoveESP(player) -- Morto = remove
                continue
            end
            
            local distance = (camPos - hrp.Position).Magnitude
            
            if distance > Config.ESP_RangeStuds then
                RemoveESP(player) -- Fora do range = remove
                continue
            end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if not onScreen or screenPos.Z <= 0 then
                RemoveESP(player) -- Fora da tela = remove
                continue
            end
            
            -- Player válido - cria ESP se não existir
            if not ESP[player] then
                CreateESP(player)
            end
            
            local data = ESP[player]
            if not data then continue end
            
            -- Calcular tamanho da box
            local sx = math.clamp((1000 / distance), 5, 110)
            local sy = math.clamp((1600 / distance), 8, 190)
            local px = screenPos.X - sx / 2
            local py = screenPos.Y - sy / 2
            local meters = math.floor(distance * 0.28 + 0.5)
            
            -- BOX
            if Config.ESP_Boxes then
                data.BoxOut.Position = Vector2.new(px - 1, py - 1)
                data.BoxOut.Size = Vector2.new(sx + 2, sy + 2)
                data.BoxOut.Color = Color3.fromRGB(0, 0, 0)
                data.BoxOut.Thickness = 3
                data.BoxOut.Filled = false
                data.BoxOut.Transparency = 0.5
                data.BoxOut.Visible = true
                
                data.Box.Position = Vector2.new(px, py)
                data.Box.Size = Vector2.new(sx, sy)
                data.Box.Color = Color3.fromRGB(140, 30, 30)
                data.Box.Thickness = 1
                data.Box.Filled = false
                data.Box.Transparency = 0.6
                data.Box.Visible = true
            else
                data.BoxOut.Visible = false
                data.Box.Visible = false
            end
            
            -- NOME
            if Config.ESP_Names then
                data.Name.Text = player.Name
                data.Name.Position = Vector2.new(screenPos.X, py - 20)
                data.Name.Color = Color3.fromRGB(255, 255, 255)
                data.Name.Size = 13
                data.Name.Font = 2
                data.Name.Center = true
                data.Name.Outline = true
                data.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
                data.Name.Visible = true
            else
                data.Name.Visible = false
            end
            
            -- DISTÂNCIA
            if Config.ESP_Distance then
                local distText = meters >= 1000 and string.format("%.1fkm", meters / 1000) or meters .. "m"
                data.Dist.Text = distText
                data.Dist.Position = Vector2.new(screenPos.X, py - 8)
                data.Dist.Color = Color3.fromRGB(255, 200, 50)
                data.Dist.Size = 12
                data.Dist.Font = 2
                data.Dist.Center = true
                data.Dist.Outline = true
                data.Dist.OutlineColor = Color3.fromRGB(0, 0, 0)
                data.Dist.Visible = true
            else
                data.Dist.Visible = false
            end
            
            -- VIDA
            if Config.ESP_Health then
                local hp = humanoid.Health / math.max(humanoid.MaxHealth, 1)
                data.HealthBg.Position = Vector2.new(px - 6, py - 1)
                data.HealthBg.Size = Vector2.new(4, sy + 2)
                data.HealthBg.Color = Color3.fromRGB(10, 10, 10)
                data.HealthBg.Filled = true
                data.HealthBg.Transparency = 0.5
                data.HealthBg.Visible = true
                
                data.HealthBar.Position = Vector2.new(px - 5, py + sy - sy * hp)
                data.HealthBar.Size = Vector2.new(2, sy * hp)
                data.HealthBar.Color = Color3.fromHSV(hp * 0.33, 1, 1)
                data.HealthBar.Filled = true
                data.HealthBar.Transparency = 0.2
                data.HealthBar.Visible = true
            else
                data.HealthBg.Visible = false
                data.HealthBar.Visible = false
            end
            
            -- LINHAS
            if Config.ESP_Lines then
                data.Line.From = Vector2.new(screenSize.X / 2, screenSize.Y)
                data.Line.To = Vector2.new(screenPos.X, py + sy / 2)
                data.Line.Color = Color3.fromRGB(140, 30, 30)
                data.Line.Thickness = 1
                data.Line.Transparency = 0.4
                data.Line.Visible = true
            else
                data.Line.Visible = false
            end
            
            -- HEAD DOT
            if Config.ESP_Dot then
                local head = character:FindFirstChild("Head")
                if head then
                    local headPos = Camera:WorldToViewportPoint(head.Position)
                    data.Dot.Position = Vector2.new(headPos.X, headPos.Y)
                    data.Dot.Color = Color3.fromRGB(255, 255, 255)
                    data.Dot.Filled = true
                    data.Dot.Transparency = 0.3
                    data.Dot.Radius = 3
                    data.Dot.Visible = true
                else
                    data.Dot.Visible = false
                end
            else
                data.Dot.Visible = false
            end
        end
    end
    
    -- Remove ESP de players que saíram do jogo
    for player, data in pairs(ESP) do
        if not activePlayers[player] then
            RemoveESP(player)
        end
    end
end)

-- LIMPEZA quando player sai
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)
