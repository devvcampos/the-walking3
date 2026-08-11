\-- Made by samet & AI Visual Overhaul
\-- UI Library Modificada e Otimizada

if getgenv().Library then
    getgenv().Library\:Unload()
end

local Library do 
    local Workspace = game\:GetService("Workspace")
    local UserInputService = game\:GetService("UserInputService")
    local Players = game\:GetService("Players")
    local HttpService = game\:GetService("HttpService")
    local RunService = game\:GetService("RunService")
    local CoreGui = cloneref and cloneref(game\:GetService("CoreGui")) or game\:GetService("CoreGui")
    local TweenService = game\:GetService("TweenService")
    local Lighting = game\:GetService("Lighting")

    gethui = gethui or function()
        return CoreGui
    end

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    local Mouse = LocalPlayer\:GetMouse()

    local FromRGB = Color3.fromRGB
    local FromHSV = Color3.fromHSV
    local FromHex = Color3.fromHex

    local RGBSequence = ColorSequence.new
    local RGBSequenceKeypoint = ColorSequenceKeypoint.new
    local NumSequence = NumberSequence.new
    local NumSequenceKeypoint = NumberSequenceKeypoint.new

    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local UDim2FromOffset = UDim2.fromOffset
    local Vector2New = Vector2.new
    local Vector3New = Vector3.new

    local MathClamp = math.clamp
    local MathFloor = math.floor
    local MathAbs = math.abs
    local MathSin = math.sin

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableClone = table.clone
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringFind = string.find
    local StringGSub = string.gsub
    local StringLower = string.lower
    local StringLen = string.len

    local InstanceNew = Instance.new
    local RectNew = Rect.new

    Library = {
        Theme =  { },
        MenuKeybind = tostring(Enum.KeyCode.K), 
        Flags = { },
        Tween = {
            Time = 0.2,
            Style = Enum.EasingStyle.Circular,
            Direction = Enum.EasingDirection.Out
        },
        FadeSpeed = 0.2,
        Folders = {
            Directory = "homxiide",
            Configs = "homxiide/Configs",
            Assets = "homxiide/Assets",
        },
        Pages = { },
        Sections = { },
        Connections = { },
        Threads = { },
        ThemeMap = { },
        ThemeItems = { },
        OpenFrames = { },
        SetFlags = { },
        UnnamedConnections = 0,
        UnnamedFlags = 0,
        Holder = nil,
        NotifHolder = nil,
        UnusedHolder = nil,
        Font = nil
    }

    Library.\_\_index = Library
    Library.Sections.\_\_index = Library.Sections
    Library.Pages.\_\_index = Library.Pages

    local Keys = {
        ["Unknown"] = "Unknown", ["Backspace"] = "Back", ["Tab"] = "Tab", ["Clear"] = "Clear",
        ["Return"] = "Return", ["Pause"] = "Pause", ["Escape"] = "Escape", ["Space"] = "Space",
        ["RightShift"] = "RightShift", ["LeftShift"] = "LeftShift", ["RightControl"] = "RightControl",
        ["LeftControl"] = "LeftControl", ["LeftAlt"] = "LeftAlt", ["RightAlt"] = "RightAlt"
    }

    -- TEMA SOMBRIO PREMIUM ATUALIZADO (Visual muito mais limpo e elegante)
    local Themes = {
        ["Preset"] = {
            ["Background"] = FromRGB(13, 14, 17),    -- Fundo Dark Premium
            ["Outline"] = FromRGB(32, 34, 42),       -- Bordas Sutis
            ["Inline"] = FromRGB(19, 21, 26),        -- Containers Internos
            ["Accent"] = FromRGB(0, 180, 216),       -- Azul Elétrico Moderno
            ["Text"] = FromRGB(245, 247, 250),       -- Texto Branco Limpo
            ["Element"] = FromRGB(25, 28, 36)        -- Botões e Sliders
        }
    }

    Library.Theme = TableClone(Themes["Preset"])

    for Index, Value in Library.Folders do 
        if not isfolder(Value) then makefolder(Value) end
    end

    local Tween = { } do
        Tween.\_\_index = Tween
        Tween.Create = function(*self*, *Item*, *Info*, *Goal*, *IsRawItem*)
            Item = IsRawItem and Item or Item.Instance
            Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)
            local NewTween = { Tween = TweenService\:Create(Item, Info, Goal), Info = Info, Goal = Goal, Item = Item }
            NewTween.Tween\:Play()
            setmetatable(NewTween, Tween)
            return NewTween
        end

        Tween.GetProperty = function(*self*, *Item*)
            Item = Item or *self*.Item 
            if Item\:IsA("Frame") then return { "BackgroundTransparency" }
            elseif Item\:IsA("TextLabel") or Item\:IsA("TextButton") then return { "TextTransparency", "BackgroundTransparency" }
            elseif Item\:IsA("ImageLabel") or Item\:IsA("ImageButton") then return { "BackgroundTransparency", "ImageTransparency" }
            elseif Item\:IsA("ScrollingFrame") then return { "BackgroundTransparency", "ScrollBarImageTransparency" }
            elseif Item\:IsA("TextBox") then return { "TextTransparency", "BackgroundTransparency" }
            elseif Item\:IsA("UIStroke") then return { "Transparency" } end
        end

        Tween.FadeItem = function(*self*, *Item*, *Property*, *Visibility*, *Speed*)
            local Item = Item or *self*.Item 
            local OldTransparency = Item[Property]
            Item[Property] = Visibility and 1 or OldTransparency
            local NewTween = Tween\:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
                [Property] = Visibility and OldTransparency or 1
            }, true)
            Library\:Connect(NewTween.Tween.Completed, function()
                if not Visibility then task.wait() Item[Property] = OldTransparency end
            end)
            return NewTween
        end
    end

    local Instances = { } do
        Instances.\_\_index = Instances
        Instances.Create = function(*self*, *Class*, *Properties*)
            local NewItem = { Instance = InstanceNew(Class), Properties = Properties, Class = Class }
            setmetatable(NewItem, Instances)
            for Property, Value in NewItem.Properties do NewItem.Instance[Property] = Value end
            return NewItem
        end
        Instances.AddToTheme = function(*self*, *Properties*)
            if not *self*.Instance then return end
            Library\:AddToTheme(*self*, Properties)
            return *self*
        end
        Instances.ChangeItemTheme = function(*self*, *Properties*)
            if not *self*.Instance then return end
            Library\:ChangeItemTheme(*self*, Properties)
        end
        Instances.Connect = function(*self*, *Event*, *Callback*, *Name*)
            if not *self*.Instance or not *self*.Instance[Event] then return end
            return Library\:Connect(*self*.Instance[Event], Callback, Name)
        end
        Instances.Tween = function(*self*, *Info*, *Goal*)
            if not *self*.Instance then return end
            return Tween\:Create(*self*, Info, Goal)
        end
        Instances.Clean = function(*self*)
            if not *self*.Instance then return end
            *self*.Instance\:Destroy()
            *self* = nil
        end
        Instances.MakeDraggable = function(*self*)
            if not *self*.Instance then return end
            local Gui = *self*.Instance
            local Dragging, DragStart, StartPosition = false, nil, nil
            local Set = function(*Input*)
                local DragDelta = Input.Position - DragStart
                local NewX = StartPosition.X.Offset + DragDelta.X
                local NewY = StartPosition.Y.Offset + DragDelta.Y
                local ScreenSize = Gui.Parent.AbsoluteSize
                local GuiSize = Gui.AbsoluteSize
                NewX = MathClamp(NewX, 0, ScreenSize.X - GuiSize.X)
                NewY = MathClamp(NewY, 0, ScreenSize.Y - GuiSize.Y)
                *self*:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2New(0, NewX, 0, NewY)})
            end
            local InputChanged
            *self*:Connect("InputBegan", function(*Input*)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position
                    if InputChanged then return end
                    InputChanged = Input.Changed\:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            InputChanged\:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)
            Library\:Connect(UserInputService.InputChanged, function(*Input*)
                if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Dragging then
                    Set(Input)
                end
            end)
        end
    end

    local CustomFont = { } do
        function CustomFont\:New(*Name*, *Weight*, *Style*, *Data*)
            if not isfile(Data.Id) then writefile(Data.Id, game\:HttpGet(Data.Url)) end
            local FontData = { name = Name, faces = { { name = Name, weight = Weight, style = Style, assetId = getcustomasset(Data.Id) } } }
            writefile(\`{Library.Folders.Assets}/{Name}.font\`, HttpService\:JSONEncode(FontData))
            return Font.new(getcustomasset(\`{Library.Folders.Assets}/{Name}.font\`))
        end
        Library.Font = CustomFont\:New("OutfitMedium", 400, "Regular", {
            Id = "OutfitMedium",
            Url = "https\://github.com"
        })
    end

Library.Holder = Instances\:Create("ScreenGui", { Parent = gethui(), Name = "\0", ZIndexBehavior = Enum.ZIndexBehavior.Global, DisplayOrder = 2, ResetOnSpawn = false })Library.UnusedHolder = Instances\:Create("ScreenGui", { Parent = gethui(), Name = "\0", ZIndexBehavior = Enum.ZIndexBehavior.Global, Enabled = false, ResetOnSpawn = false })Library.Unload = function(self)for \_, Value in self.Connections do Value.Connection\:Disconnect() endif self.Holder then self.Holder\:Clean() endLibrary = nilgetgenv().Library = nilendLibrary.Round = function(self, Number, Float)local Multiplier = 1 / (Float or 1)return MathFloor(Number \* Multiplier) / MultiplierendLibrary.Thread = function(self, Function)local NewThread = coroutine.create(Function)coroutine.wrap(function() coroutine.resume(NewThread)
end)()TableInsert(self.Threads, NewThread)return NewThreadendLibrary.SafeCall = function(self, Function, ...)local Success, Result = pcall(Function, ...)if not Success then warn(Result)
return false endreturn SuccessendLibrary.Connect = function(self, Event, Callback, Name)Name = Name or StringFormat("conn\_%s", HttpService\:GenerateGUID(false))local NewConnection = { Event = Event, Callback = Callback, Name = Name, Connection = nil }Library\:Thread(function() NewConnection.Connection = Event\:Connect(Callback)
end)TableInsert(self.Connections, NewConnection)return NewConnectionendLibrary.NextFlag = function(self)self.UnnamedFlags = self.UnnamedFlags + 1return StringFormat("flag\_%s", self.UnnamedFlags)end
Library.AddToTheme = function(self, Item, Properties)Item = Item.Instance or Itemlocal ThemeData = { Item = Item, Properties = Properties }for Property, Value in ThemeData.Properties doif type(Value) == "string" then Item[Property] = self.Theme[Value]else Item[Property] = Value() endendTableInsert(self.ThemeItems, ThemeData)self.ThemeMap[Item] = ThemeDataendLibrary.ChangeItemTheme = function(self, Item, Properties)Item = Item.Instance or Itemif not self.ThemeMap[Item] then
return endself.ThemeMap[Item].Properties = PropertiesendLibrary.IsMouseOverFrame = function(self, Frame)Frame = Frame.Instancelocal MousePosition = Vector2New(Mouse.X, Mouse.Y)return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.Xand MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.YendLibrary.Window = function(self, Data)local Window = { Name = Data.Name or "Window", SubName = Data.SubName or "", Logo = Data.Logo or "", Pages = { }, IsOpen = false }local Items = { } doItems["MainFrame"] = Instances\:Create("Frame", {Parent = Library.Holder.Instance, Name = "\0", AnchorPoint = Vector2New(0.5, 0.5),Position = UDim2New(0.5, 0, 0.5, 0), Size = UDim2New(0, 680, 0, 480), BorderSizePixel = 0,BackgroundColor3 = Library.Theme["Background"]})\:AddToTheme({BackgroundColor3 = 'Background'})Items["MainFrame"]\:MakeDraggable()Instances\:Create("UICorner", { Parent = Items["MainFrame"].Instance, CornerRadius = UDimNew(0, 8) })-- Linha Estética Superior Glow Accentlocal TopGlow = Instances\:Create("Frame", {Parent = Items["MainFrame"].Instance, Size = UDim2New(1, 0, 0, 2),BorderSizePixel = 0, BackgroundColor3 = Library.Theme["Accent"]})\:AddToTheme({BackgroundColor3 = 'Accent'})Instances\:Create("UICorner", { Parent = TopGlow\.Instance, CornerRadius = UDimNew(0, 8) })Items["Sidebar"] = Instances\:Create("Frame", {Parent = Items["MainFrame"].Instance, Size = UDim2New(0, 190, 1, 0),BackgroundTransparency = 1, BorderSizePixel = 0})local Sep = Instances\:Create("Frame", {Parent = Items["MainFrame"].Instance, Position = UDim2New(0, 190, 0, 0),Size = UDim2New(0, 1, 1, 0), BorderSizePixel = 0, BackgroundColor3 = Library.Theme["Outline"]})\:AddToTheme({BackgroundColor3 = 'Outline'})Items["Top"] = Instances\:Create("Frame", { Parent = Items["Sidebar"].Instance, Size = UDim2New(1, 0, 0, 70), BackgroundTransparency = 1 })Items["Title"] = Instances\:Create("TextLabel", {Parent = Items["Top"].Instance, FontFace = Library.Font, TextColor3 = Library.Theme["Text"],Text = Window\.Name, Position = UDim2New(0, 20, 0, 18), TextSize = 18, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X})\:AddToTheme({TextColor3 = 'Text'})Items["Subtitle"] = Instances\:Create("TextLabel", {Parent = Items["Top"].Instance, FontFace = Library.Font, TextColor3 = Library.Theme["Accent"],Text = Window\.SubName, Position = UDim2New(0, 20, 0, 38), TextSize = 12, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X})\:AddToTheme({TextColor3 = 'Accent'})Items["Pages"] = Instances\:Create("ScrollingFrame", {Parent = Items["Sidebar"].Instance, Position = UDim2New(0, 10, 0, 80), Size = UDim2New(1, -20, 1, -90),BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2New(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y})Instances\:Create("UIListLayout", { Parent = Items["Pages"].Instance, Padding = UDimNew(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })Items["Content"] = Instances\:Create("Frame", {Parent = Items["MainFrame"].Instance, Position = UDim2New(0, 205, 0, 15),Size = UDim2New(1, -220, 1, -30), BackgroundTransparency = 1})Window\.Items = Itemsendlocal Debounce = falsefunction Window\:SetOpen(Bool)if Debounce then
return endWindow\.IsOpen = BoolDebounce = trueItems["MainFrame"].Instance.Visible = BoolDebounce = falseendLibrary\:Connect(UserInputService.InputBegan, function(Input)if tostring(Input.KeyCode) == Library.MenuKeybind thenWindow\:SetOpen(not Window\.IsOpen)endend)Window\:SetOpen(true)return setmetatable(Window, Library)end
Library.Page = function(self, Data)local Page = { Window = self, Name = Data.Name or "Page", Active = false, Items = {} }local Items = { } doItems["Button"] = Instances\:Create("TextButton", {Parent = Page.Window\.Items["Pages"].Instance, Size = UDim2New(1, 0, 0, 36),BackgroundTransparency = 1, Text = "", AutoButtonColor = false})local Bg = Instances\:Create("Frame", {Parent = Items["Button"].Instance, Size = UDim2New(1, 0, 1, 0),BackgroundColor3 = Library.Theme["Element"], BackgroundTransparency = 1, BorderSizePixel = 0})\:AddToTheme({BackgroundColor3 = 'Element'})Instances\:Create("UICorner", { Parent = Bg.Instance, CornerRadius = UDimNew(0, 6) })local Tx = Instances\:Create("TextLabel", {Parent = Items["Button"].Instance, FontFace = Library.Font, TextColor3 = Library.Theme["Text"],Text = Page.Name, Position = UDim2New(0, 12, 0, 0), Size = UDim2New(1, -12, 1, 0), TextSize = 14,TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, TextTransparency = 0.4})\:AddToTheme({TextColor3 = 'Text'})Items["PageFrame"] = Instances\:Create("ScrollingFrame", {Parent = Library.UnusedHolder.Instance, Size = UDim2New(1, 0, 1, 0),BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme["Accent"],CanvasSize = UDim2New(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false})\:AddToTheme({ScrollBarImageColor3 = 'Accent'})Instances\:Create("UIListLayout", { Parent = Items["PageFrame"].Instance, Padding = UDimNew(0, 12), SortOrder = Enum.SortOrder.LayoutOrder })Page.Items = ItemsPage.Bg = BgPage.Tx = Txendfunction Page\:Turn(Bool)Page.Active = BoolItems["PageFrame"].Instance.Visible = BoolItems["PageFrame"].Instance.Parent = Bool and Page.Window\.Items["Content"].Instance or Library.UnusedHolder.Instanceif Bool thenPage.Bg\:Tween(nil, {BackgroundTransparency = 0})Page.Tx\:Tween(nil, {TextTransparency = 0})elsePage.Bg\:Tween(nil, {BackgroundTransparency = 1})Page.Tx\:Tween(nil, {TextTransparency = 0.4})endendItems["Button"]\:Connect("MouseButton1Down", function()for \_, v in Page.Window\.Pages do v\:Turn(v == Page) endend)if #Page.Window\.Pages == 0 then Page\:Turn(true) endTableInsert(Page.Window\.Pages, Page)return setmetatable(Page, Library.Pages)end
Library.Pages.Section = function(self, Data)local Section = { Window = self.Window, Page = self, Name = Data.Name or "Section", Items = {} }local Items = { } doItems["Outer"] = Instances\:Create("Frame", {Parent = Section.Page.Items["PageFrame"].Instance, Size = UDim2New(1, 0, 0, 40),BackgroundColor3 = Library.Theme["Outline"], BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y})\:AddToTheme({BackgroundColor3 = 'Outline'})Instances\:Create("UICorner", { Parent = Outer.Instance, CornerRadius = UDimNew(0, 6) })Items["Inner"] = Instances\:Create("Frame", {Parent = Items["Outer"].Instance, Position = UDim2New(0, 1, 0, 1), Size = UDim2New(1, -2, 1, -2),BackgroundColor3 = Library.Theme["Inline"], BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y})\:AddToTheme({BackgroundColor3 = 'Inline'})Instances\:Create("UICorner", { Parent = Items["Inner"].Instance, CornerRadius = UDimNew(0, 6) })Items["Container"] = Instances\:Create("Frame", {Parent = Items["Inner"].Instance, Position = UDim2New(0, 12, 0, 12), Size = UDim2New(1, -24, 1, -24),BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y})Instances\:Create("UIListLayout", { Parent = Items["Container"].Instance, Padding = UDimNew(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })-- Título da Seção separado de forma minimalistalocal Title = Instances\:Create("TextLabel", {Parent = Items["Container"].Instance, FontFace = Library.Font, TextColor3 = Library.Theme["Accent"],Text = Section.Name\:upper(), TextSize = 11, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY})\:AddToTheme({TextColor3 = 'Accent'})endSection.Container = Items["Container"]return setmetatable(Section, Library.Sections)end
Library.Sections.Toggle = function(self, Data)local Toggle = { Flag = Data.Flag or Library\:NextFlag(), Callback = Data.Callback or function()
end, Value = false }local Items = { } doItems["Button"] = Instances\:Create("TextButton", {Parent = self.Container.Instance, Size = UDim2New(1, 0, 0, 24), BackgroundTransparency = 1, Text = ""})Items["Label"] = Instances\:Create("TextLabel", {Parent = Items["Button"].Instance, FontFace = Library.Font, TextColor3 = Library.Theme["Text"],Text = Data.Name or "Toggle", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2New(1, -40, 1, 0)})\:AddToTheme({TextColor3 = 'Text'})Items["Frame"] = Instances\:Create("Frame", {Parent = Items["Button"].Instance, Position = UDim2New(1, -36, 0, 3), Size = UDim2New(0, 36, 0, 18),BackgroundColor3 = Library.Theme["Element"], BorderSizePixel = 0})\:AddToTheme({BackgroundColor3 = 'Element'})Instances\:Create("UICorner", { Parent = Items["Frame"].Instance, CornerRadius = UDimNew(1, 0) })Items["Stroke"] = Instances\:Create("UIStroke", { Parent = Items["Frame"].Instance, Color = Library.Theme["Outline"] })\:AddToTheme({Color = 'Outline'})Items["Dot"] = Instances\:Create("Frame", {Parent = Items["Frame"].Instance, Position = UDim2New(0, 3, 0, 3), Size = UDim2New(0, 12, 0, 12),BackgroundColor3 = FromRGB(150, 150, 150), BorderSizePixel = 0})Instances\:Create("UICorner", { Parent = Items["Dot"].Instance, CornerRadius = UDimNew(1, 0) })endfunction Toggle\:Set(Value)Toggle.Value = ValueLibrary.Flags[Toggle.Flag] = Valueif Value thenItems["Dot"]\:Tween(nil, {Position = UDim2New(0, 21, 0, 3), BackgroundColor3 = Library.Theme.Accent})Items["Stroke"]\:Tween(nil, {Color = Library.Theme.Accent})elseItems["Dot"]\:Tween(nil, {Position = UDim2New(0, 3, 0, 3), BackgroundColor3 = FromRGB(140, 140, 140)})Items["Stroke"]\:Tween(nil, {Color = Library.Theme.Outline})endpcall(Toggle.Callback, Value)endItems["Button"]\:Connect("MouseButton1Down", function() Toggle\:Set(not Toggle.Value)
end)Toggle\:Set(Data.Default or false)return ToggleendLibrary.Sections.Slider = function(self, Data)local Slider = { Min = Data.Min or 0, Max = Data.Max or 100, Value = Data.Default or 0, Suffix = Data.Suffix or "", Callback = Data.Callback or function()
end, Flag = Data.Flag or Library\:NextFlag() }local Items = { } doItems["Main"] = Instances\:Create("Frame", { Parent = self.Container.Instance, Size = UDim2New(1, 0, 0, 38), BackgroundTransparency = 1 })Items["Label"] = Instances\:Create("TextLabel", {Parent = Items["Main"].Instance, FontFace = Library.Font, TextColor3 = Library.Theme["Text"],Text = Data.Name or "Slider", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2New(1, 0, 0, 16)})\:AddToTheme({TextColor3 = 'Text'})Items["ValLabel"] = Instances\:Create("TextLabel", {Parent = Items["Main"].Instance, FontFace = Library.Font, TextColor3 = Library.Theme["Accent"],Text = tostring(Slider.Value)..Slider.Suffix, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Size = UDim2New(1, 0, 0, 16)})\:AddToTheme({TextColor3 = 'Accent'})Items["Bar"] = Instances\:Create("TextButton", {Parent = Items["Main"].Instance, Position = UDim2New(0, 0, 0, 24), Size = UDim2New(1, 0, 0, 6),BackgroundColor3 = Library.Theme["Element"], BorderSizePixel = 0, Text = ""})\:AddToTheme({BackgroundColor3 = 'Element'})Instances\:Create("UICorner", { Parent = Items["Bar"].Instance, CornerRadius = UDimNew(1, 0) })Items["Fill"] = Instances\:Create("Frame", {Parent = Items["Bar"].Instance, Size = UDim2New(0, 0, 1, 0),BackgroundColor3 = Library.Theme["Accent"], BorderSizePixel = 0})\:AddToTheme({BackgroundColor3 = 'Accent'})Instances\:Create("UICorner", { Parent = Items["Fill"].Instance, CornerRadius = UDimNew(1, 0) })end
local
function UpdateSlider(Input)local SizeX = MathClamp((Input.Position.X - Items["Bar"].Instance.AbsolutePosition.X) / Items["Bar"].Instance.AbsoluteSize.X, 0, 1)local NewValue = MathFloor(Slider.Min + ((Slider.Max - Slider.Min) \* SizeX))Slider.Value = NewValueLibrary.Flags[Slider.Flag] = NewValueItems["Fill"].Instance.Size = UDim2New(SizeX, 0, 1, 0)Items["ValLabel"].Instance.Text = tostring(NewValue)..Slider.Suffixpcall(Slider.Callback, NewValue)end
    local Sliding = falseItems["Bar"]\:Connect("InputBegan", function(Input)if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch thenSliding = true UpdateSlider(Input)endend)Library\:Connect(UserInputService.InputChanged, function(Input)if Sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) thenUpdateSlider(Input)endend)UserInputService.InputEnded\:Connect(function(Input)if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then Sliding = false endend)-- Inicializar Posição Real do Slider Baseado no Defaultlocal InitRatio = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)Items["Fill"].Instance.Size = UDim2New(MathClamp(InitRatio, 0, 1), 0, 1, 0)return SliderendLibrary.Sections.Label = function(self, Text)local Label = Instances\:Create("TextLabel", {Parent = self.Container.Instance, FontFace = Library.Font, TextColor3 = Library.Theme["Text"],Text = Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2New(1, 0, 0, 0), TextTransparency = 0.5})\:AddToTheme({TextColor3 = 'Text'})return LabelendLibrary.CreateWindow = Library.WindowLibrary.AddTab = Library.PageLibrary.Pages.AddSection = Library.Pages.SectionLibrary.Sections.AddToggle = Library.Sections.ToggleLibrary.Sections.AddSlider = Library.Sections.SliderLibrary.Sections.AddLabel = Library.Sections.Labelend-- =============================================================================-- CONFIGURAÇÕES E ESTADOS DO ESP / CHAMS-- =============================================================================local EspPlayersEnabled = truelocal EspBoxEnabled = truelocal EspChamsEnabled = truelocal MaxEspDistance = 5000-- =============================================================================-- GERENCIADOR DE INTERFACE DO USUÁRIO-- =============================================================================local Window = Library\:CreateWindow({Name = "THE WALKING DEAD 3",SubName = "QA VISUALS OVERHAUL",SettingsTabEnabled = false})local SurvivorsPage = Window\:AddTab("ESP Sobreviventes")local SurvivorsSection = SurvivorsPage\:AddSection("Configurações Visuais")SurvivorsSection\:AddToggle({Name = "Mestre Ativado (ESP Global)",Default = true,Callback = function(Value)EspPlayersEnabled = Valueend})SurvivorsSection\:AddToggle({Name = "Mostrar Caixas (2D Boxes)",Default = true,Callback = function(Value)EspBoxEnabled = Valueend})SurvivorsSection\:AddToggle({Name = "Mostrar Silhuetas (Chams)",Default = true,Callback = function(Value)EspChamsEnabled = Valueend})-- SLIDER DESLIZÁVEL ATUALIZADO: 0 a 10.000 MetrosSurvivorsSection\:AddSlider({Name = "Distância de Renderização",Min = 0,Max = 10000,Default = 5000,Suffix = "m",Callback = function(Value)MaxEspDistance = Valueend})SurvivorsSection\:AddLabel("Dica: Pressione [ K ] para fechar ou abrir este painel a qualquer momento.")local InfectedPage = Window\:AddTab("ESP Infectados")local InfectedSection = InfectedPage\:AddSection("Em Breve")InfectedSection\:AddLabel("Módulos em desenvolvimento.")-- =============================================================================-- ENGENHARIA DO MOTOR DE RENDERIZAÇÃO (ESP BOX 2D + HEALTH + CHAMS NATIVO)-- =============================================================================local GuiParent = LocalPlayer\:WaitForChild("PlayerGui")local EspGui = Instance.new("ScreenGui")EspGui.Name = "QA\_ESP\_Engine"EspGui.ResetOnSpawn = falseEspGui.ZIndexBehavior = Enum.ZIndexBehavior.GlobalEspGui.Parent = GuiParentlocal espElements = {}local
    function createSafeESP(player)local elements = {}local holder = Instance.new("Folder")holder.Name = "Render\_" .. player.UserIdholder.Parent = EspGui-- Box Outline Externalocal box = Instance.new("Frame")box.BackgroundTransparency = 1box.BorderColor3 = Color3.fromRGB(0, 180, 216) -- Azul Cyan Premium combinando com a UIbox.BorderSizePixel = 1box.Visible = falsebox.Parent = holderelements.Box = box-- Nomelocal nameLabel = Instance.new("TextLabel")nameLabel.BackgroundTransparency = 1nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)nameLabel.TextSize = 12nameLabel.Font = Enum.Font.SourceSansBoldnameLabel.TextStrokeTransparency = 0.3nameLabel.TextXAlignment = Enum.TextXAlignment.CenternameLabel.Visible = falsenameLabel.Parent = holderelements.Name = nameLabel-- Distâncialocal distLabel = Instance.new("TextLabel")distLabel.BackgroundTransparency = 1distLabel.TextColor3 = Color3.fromRGB(240, 220, 80)distLabel.TextSize = 11distLabel.Font = Enum.Font.SourceSansBolddistLabel.TextStrokeTransparency = 0.3distLabel.TextXAlignment = Enum.TextXAlignment.CenterdistLabel.Visible = falsedistLabel.Parent = holderelements.Distance = distLabel-- Healthbarslocal barOutline = Instance.new("Frame")barOutline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)barOutline.BorderSizePixel = 0barOutline.Visible = falsebarOutline.Parent = holderelements.HealthOutline = barOutlinelocal bar = Instance.new("Frame")bar.BorderSizePixel = 0bar.Visible = falsebar.Parent = holderelements.HealthBar = bar-- Elemento de Chams Nativo Otimizado (Highlight)local highlight = Instance.new("Highlight")highlight.Name = "Chams"highlight.FillColor = Color3.fromRGB(0, 180, 216)highlight.FillTransparency = 0.5highlight.OutlineColor = Color3.fromRGB(255, 255, 255)highlight.OutlineTransparency = 0.2highlight.Enabled = falsehighlight.Parent = holderelements.Highlight = highlightelements.Holder = holderespElements[player] = elementsendlocal
        function removeSafeESP(player)if espElements[player] thenif espElements[player].Holder then espElements[player].Holder\:Destroy() endespElements[player] = nilendendlocal
            function cleanAllVisuals()for \_, elements in pairs(espElements) doif elements.Box then elements.Box.Visible = false endif elements.Name then elements.Name.Visible = false endif elements.Distance then elements.Distance.Visible = false endif elements.HealthOutline then elements.HealthOutline.Visible = false endif elements.HealthBar then elements.HealthBar.Visible = false endif elements.Highlight then elements.Highlight.Enabled = false endendend-- Loop de renderização com performance aprimoradaRunService.RenderStepped\:Connect(function()if not EspPlayersEnabled thencleanAllVisuals()returnendlocal cameraPosition = Camera.CFrame.Positionlocal playersList = Players\:GetPlayers()for i = 1, #playersList dolocal player = playersList[i]if player \~= LocalPlayer thenlocal character = player.Characterif character thenlocal hrp = character\:FindFirstChild("HumanoidRootPart")local humanoid = character\:FindFirstChildOfClass("Humanoid")if hrp and humanoid and hrp\:IsA("BasePart") and humanoid.Health > 0 thenlocal distance = (cameraPosition - hrp.Position).Magnitudeif distance <= MaxEspDistance thenlocal pos, onScreen = Camera\:WorldToViewportPoint(hrp.Position)if not espElements[player] thencreateSafeESP(player)end
                local elements = espElements[player]-- Atualização Dinâmica do Chams (Highlight)if EspChamsEnabled thenelements.Highlight.Adornee = characterelements.Highlight.Enabled = trueelseelements.Highlight.Enabled = falseend-- Atualização Dinâmica da Box 2D e Textoif onScreen and pos.Z > 0 and EspBoxEnabled thenlocal sizeX = math.clamp((1000 / distance) \* 35, 8, 120)local sizeY = math.clamp((1600 / distance) \* 35, 12, 200)local posX = pos.X - sizeX / 2local posY = pos.Y - sizeY / 2elements.Box.Position = UDim2.new(0, posX, 0, posY)elements.Box.Size = UDim2.new(0, sizeX, 0, sizeY)elements.Box.Visible = trueelements.Name.Text = player.Nameelements.Name.Position = UDim2.new(0, pos.X - 100, 0, posY - 28)elements.Name.Size = UDim2.new(0, 200, 0, 14)elements.Name.Visible = trueelements.Distance.Text = math.floor(distance) .. "m"elements.Distance.Position = UDim2.new(0, pos.X - 100, 0, posY - 16)elements.Distance.Size = UDim2.new(0, 200, 0, 14)elements.Distance.Visible = true-- Barra de Vida Lateral Embutida na Caixalocal healthRatio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)local barHeight = sizeY \* healthRatiolocal barWidth = 2elements.HealthOutline.Position = UDim2.new(0, posX - barWidth - 5, 0, posY - 1)elements.HealthOutline.Size = UDim2.new(0, barWidth + 2, 0, sizeY + 2)elements.HealthOutline.Visible = trueelements.HealthBar.Position = UDim2.new(0, posX - barWidth - 4, 0, posY + sizeY - barHeight)elements.HealthBar.Size = UDim2.new(0, barWidth, 0, barHeight)elements.HealthBar.BackgroundColor3 = Color3.fromHSV(healthRatio \* 0.33, 1, 1) -- Verde para Vermelho dinâmicoelements.HealthBar.Visible = trueelse-- Caso saia da tela mas permaneça no raio, mantém o Chams ativo e esconde a Box 2Dif elements.Box then elements.Box.Visible = false endif elements.Name then elements.Name.Visible = false endif elements.Distance then elements.Distance.Visible = false endif elements.HealthOutline then elements.HealthOutline.Visible = false endif elements.HealthBar then elements.HealthBar.Visible = false endendelseif espElements[player] thenremoveSafeESP(player)endelseif espElements[player] thenremoveSafeESP(player)endelseif espElements[player] thenremoveSafeESP(player)endendendend)Players.PlayerRemoving\:Connect(removeSafeESP)script.Destroying\:Connect(function()cleanAllVisuals()if EspGui then EspGui\:Destroy() endif Window and Window\.SetOpen then pcall(function() Window\:SetOpen(false)
            end) endend)
