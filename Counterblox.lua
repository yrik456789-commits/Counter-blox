-- // Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Удаляем старое меню, если оно было запущено
if CoreGui:FindFirstChild("ProjectSky_Menu") then
    CoreGui.ProjectSky_Menu:Destroy()
end

-- // Красивое и плавное интро
local IntroGui = Instance.new("ScreenGui")
IntroGui.Name = "ProjectSky_Intro"
IntroGui.Parent = CoreGui
IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local IntroFrame = Instance.new("Frame")
IntroFrame.Parent = IntroGui
IntroFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
IntroFrame.BorderSizePixel = 0
IntroFrame.Position = UDim2.new(0.5, -175, 0.5, -40)
IntroFrame.Size = UDim2.new(0, 350, 0, 80)
IntroFrame.BackgroundTransparency = 1

local UICornerIntro = Instance.new("UICorner")
UICornerIntro.CornerRadius = UDim.new(0, 8)
UICornerIntro.Parent = IntroFrame

local IntroText = Instance.new("TextLabel")
IntroText.Parent = IntroFrame
IntroText.BackgroundTransparency = 1
IntroText.Size = UDim2.new(1, 0, 1, 0)
IntroText.Font = Enum.Font.SourceSansBold
IntroText.Text = "Project Sky загружен успешно!"
IntroText.TextColor3 = Color3.fromRGB(0, 255, 170)
IntroText.TextSize = 18
IntroText.TextTransparency = 1

task.spawn(function()
    TweenService:Create(IntroFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15}):Play()
    TweenService:Create(IntroText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    
    task.wait(2.2)
    
    TweenService:Create(IntroFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
    TweenService:Create(IntroText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
    
    task.wait(0.7)
    IntroGui:Destroy()
end)

-- // Настройки функций
local Settings = {
    ESP_Highlight = false,
    Boxes = false,
    Tracers = false,
    TracerBullets = false,
    TracerColor = Color3.fromRGB(0, 255, 255),
    TracerType = "Neon",
    FOVEnabled = false,
    FOVValue = 70
}

-- // Главное окно UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProjectSky_Menu"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

-- Шапка
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 30)

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 6)
TopCorner.Parent = TopBar

local WelcomeLabel = Instance.new("TextLabel")
WelcomeLabel.Parent = TopBar
WelcomeLabel.BackgroundTransparency = 1
WelcomeLabel.Position = UDim2.new(0, 10, 0, 0)
WelcomeLabel.Size = UDim2.new(1, -90, 1, 0)
WelcomeLabel.Font = Enum.Font.SourceSansBold
WelcomeLabel.Text = "Project Sky — Counter Blox Menu"
WelcomeLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
WelcomeLabel.TextSize = 14
WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка закрытия [X]
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Size = UDim2.new(0, 22, 0, 20)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Кнопка сворачивания [-] (Слева от крестика)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
MinimizeBtn.Position = UDim2.new(1, -58, 0, 5)
MinimizeBtn.Size = UDim2.new(0, 22, 0, 20)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 14

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinimizeBtn

-- Контейнер содержимого (Левая и правая панели)
local Container = Instance.new("Frame")
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 0, 0, 30)
Container.Size = UDim2.new(1, 0, 1, -30)

-- Логика плавного сворачивания/разворачивания
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if isMinimized then
        MinimizeBtn.Text = "+"
        -- Скрываем контент внутри
        Container.Visible = false
        -- Плавно сжимаем окно в аккуратный прямоугольник и поднимаем вверх экрана
        TweenService:Create(MainFrame, tweenInfo, {
            Size = UDim2.new(0, 220, 0, 35),
            Position = UDim2.new(0.5, -110, 0, 15)
        }):Play()
        WelcomeLabel.Text = "Project Sky [Свернуто]"
    else
        MinimizeBtn.Text = "-"
        -- Возвращаем исходный размер и позицию в центр
        TweenService:Create(MainFrame, tweenInfo, {
            Size = UDim2.new(0, 500, 0, 350),
            Position = UDim2.new(0.5, -250, 0.5, -175)
        }):Play()
        task.wait(0.2)
        Container.Visible = true
        WelcomeLabel.Text = "Project Sky — Counter Blox Menu"
    end
end)

-- Левая панель (Вкладки)
local TabsFrame = Instance.new("Frame")
TabsFrame.Parent = Container
TabsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
TabsFrame.Position = UDim2.new(0, 0, 0, 0)
TabsFrame.Size = UDim2.new(0, 130, 1, 0)

-- Правая панель (Контент)
local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = Container
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 140, 0, 10)
ContentFrame.Size = UDim2.new(1, -150, 1, -10)

-- Вкладка VISUALS
local VisualsTabBtn = Instance.new("TextButton")
VisualsTabBtn.Parent = TabsFrame
VisualsTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
VisualsTabBtn.Position = UDim2.new(0, 10, 0, 10)
VisualsTabBtn.Size = UDim2.new(0, 110, 0, 35)
VisualsTabBtn.Font = Enum.Font.SourceSansBold
VisualsTabBtn.Text = "VISUALS"
VisualsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VisualsTabBtn.TextSize = 14

local VisualsContent = Instance.new("ScrollingFrame")
VisualsContent.Parent = ContentFrame
VisualsContent.BackgroundTransparency = 1
VisualsContent.Size = UDim2.new(1, 0, 1, 0)
VisualsContent.CanvasSize = UDim2.new(0, 0, 1.8, 0)
VisualsContent.ScrollBarThickness = 4

-- Функция создания чекбоксов
local function CreateToggle(name, yPos, xPos, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = VisualsContent
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ToggleBtn.Position = UDim2.new(xPos, 0, 0, yPos)
    ToggleBtn.Size = UDim2.new(0, 160, 0, 35)
    ToggleBtn.Font = Enum.Font.SourceSans
    ToggleBtn.Text = name .. ": [OFF]"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    ToggleBtn.TextSize = 14

    local state = false
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            ToggleBtn.Text = name .. ": [ON]"
            ToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            ToggleBtn.Text = name .. ": [OFF]"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        callback(state)
    end)
end

-- Основные тумблеры
CreateToggle("ESP Highlight", 0, 0, function(state) Settings.ESP_Highlight = state end)
CreateToggle("2D Boxes", 45, 0, function(state) Settings.Boxes = state end)
CreateToggle("Tracers", 0, 0.5, function(state) Settings.Tracers = state end)
CreateToggle("Tracer Bullets", 45, 0.5, function(state) Settings.TracerBullets = state end)

-- // БЛОК FOV
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Parent = VisualsContent
FOVLabel.BackgroundTransparency = 1
FOVLabel.Position = UDim2.new(0, 45, 0, 95)
FOVLabel.Size = UDim2.new(0, 240, 0, 25)
FOVLabel.Font = Enum.Font.SourceSansBold
FOVLabel.Text = "--- Настройки FOV (Обзор) ---"
FOVLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FOVLabel.TextSize = 13
FOVLabel.TextXAlignment = Enum.TextXAlignment.Center

local FOVToggle = Instance.new("TextButton")
FOVToggle.Parent = VisualsContent
FOVToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
FOVToggle.Position = UDim2.new(0.25, 0, 0, 125)
FOVToggle.Size = UDim2.new(0, 160, 0, 30)
FOVToggle.Font = Enum.Font.SourceSans
FOVToggle.Text = "Кастомный FOV: [OFF]"
FOVToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
FOVToggle.TextSize = 13

FOVToggle.MouseButton1Click:Connect(function()
    Settings.FOVEnabled = not Settings.FOVEnabled
    if Settings.FOVEnabled then
        FOVToggle.Text = "Кастомный FOV: [ON]"
        FOVToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        FOVToggle.Text = "Кастомный FOV: [OFF]"
        FOVToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        Camera.FieldOfView = 70
    end
end)

local FOVMinus = Instance.new("TextButton")
FOVMinus.Parent = VisualsContent
FOVMinus.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
FOVMinus.Position = UDim2.new(0.25, 0, 0, 165)
FOVMinus.Size = UDim2.new(0, 75, 0, 30)
FOVMinus.Font = Enum.Font.SourceSansBold
FOVMinus.Text = "FOV -"
FOVMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVMinus.TextSize = 13

local FOVPlus = Instance.new("TextButton")
FOVPlus.Parent = VisualsContent
FOVPlus.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
FOVPlus.Position = UDim2.new(0.25, 85, 0, 165)
FOVPlus.Size = UDim2.new(0, 75, 0, 30)
FOVPlus.Font = Enum.Font.SourceSansBold
FOVPlus.Text = "FOV +"
FOVPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVPlus.TextSize = 13

FOVMinus.MouseButton1Click:Connect(function()
    if Settings.FOVValue > 30 then
        Settings.FOVValue = Settings.FOVValue - 10
    end
end)

FOVPlus.MouseButton1Click:Connect(function()
    if Settings.FOVValue < 120 then
        Settings.FOVValue = Settings.FOVValue + 10
    end
end)

-- Подвкладка для Tracer Bullets
local SubMenuLabel = Instance.new("TextLabel")
SubMenuLabel.Parent = VisualsContent
SubMenuLabel.BackgroundTransparency = 1
SubMenuLabel.Position = UDim2.new(0, 0, 0, 210)
SubMenuLabel.Size = UDim2.new(1, 0, 0, 25)
SubMenuLabel.Font = Enum.Font.SourceSansBold
SubMenuLabel.Text = "--- Настройки Tracer Bullets ---"
SubMenuLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SubMenuLabel.TextSize = 13

local ColorBtn = Instance.new("TextButton")
ColorBtn.Parent = VisualsContent
ColorBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
ColorBtn.Position = UDim2.new(0, 0, 0, 240)
ColorBtn.Size = UDim2.new(0, 160, 0, 30)
ColorBtn.Font = Enum.Font.SourceSans
ColorBtn.Text = "Цвет: Неоновый Голубой"
ColorBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
ColorBtn.TextSize = 13

local colorIndex = 1
local colors = {
    {Name = "Неоновый Голубой", Color = Color3.fromRGB(0, 255, 255)},
    {Name = "Зеленый", Color = Color3.fromRGB(0, 255, 0)},
    {Name = "Красный", Color = Color3.fromRGB(255, 0, 0)},
    {Name = "Желтый", Color = Color3.fromRGB(255, 255, 0)}
}

ColorBtn.MouseButton1Click:Connect(function()
    colorIndex = colorIndex % #colors + 1
    local selected = colors[colorIndex]
    Settings.TracerColor = selected.Color
    ColorBtn.Text = "Цвет: " .. selected.Name
    ColorBtn.TextColor3 = selected.Color
end)

local StyleBtn = Instance.new("TextButton")
StyleBtn.Parent = VisualsContent
StyleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
StyleBtn.Position = UDim2.new(0.5, 0, 0, 240)
StyleBtn.Size = UDim2.new(0, 160, 0, 30)
StyleBtn.Font = Enum.Font.SourceSans
StyleBtn.Text = "Стиль: Neon"
StyleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StyleBtn.TextSize = 13

StyleBtn.MouseButton1Click:Connect(function()
    if Settings.TracerType == "Neon" then
        Settings.TracerType = "Simple"
        StyleBtn.Text = "Стиль: Simple"
    else
        Settings.TracerType = "Neon"
        StyleBtn.Text = "Стиль: Neon"
    end
end)

-- Хранилища визуала
local Highlights = {}
local BoxDrawings = {}
local TracerLines = {}

Players.PlayerRemoving:Connect(function(plr)
    if Highlights[plr] then Highlights[plr]:Destroy() Highlights[plr] = nil end
    if BoxDrawings[plr] then 
        for _, boxLine in pairs(BoxDrawings[plr]) do boxLine:Remove() end
        BoxDrawings[plr] = nil 
    end
    if TracerLines[plr] then TracerLines[plr]:Remove() TracerLines[plr] = nil end
end)

-- // Главный цикл обновления
RunService.RenderStepped:Connect(function()
    if Settings.FOVEnabled then
        Camera.FieldOfView = Settings.FOVValue
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local humanoid = character.Humanoid
            
            if humanoid.Health > 0 then
                -- 1. ESP HIGHLIGHT
                if Settings.ESP_Highlight then
                    if not Highlights[player] then
                        local hl = Instance.new("Highlight")
                        hl.Parent = character
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        Highlights[player] = hl
                    end
                    Highlights[player].Enabled = true
                else
                    if Highlights[player] then Highlights[player].Enabled = false end
                end
                
                -- 2. 2D BOXES
                if Settings.Boxes then
                    if not BoxDrawings[player] then
                        local boxLines = {}
                        for i = 1, 4 do
                            local l = Drawing.new("Line")
                            l.Visible = false
                            l.Color = Color3.fromRGB(255, 255, 255)
                            l.Thickness = 1.5
                            table.insert(boxLines, l)
                        end
                        BoxDrawings[player] = boxLines
                    end
                    
                    local _, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        local headPos = Camera:WorldToViewportPoint(character.Head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 2
                        
                        local boxLines = BoxDrawings[player]
                        local posTopLeft = Vector2.new(headPos.X - width / 2, headPos.Y)
                        local posTopRight = Vector2.new(headPos.X + width / 2, headPos.Y)
                        local posBottomLeft = Vector2.new(headPos.X - width / 2, legPos.Y)
                        local posBottomRight = Vector2.new(headPos.X + width / 2, legPos.Y)
                        
                        boxLines[1].From = posTopLeft; boxLines[1].To = posTopRight; boxLines[1].Visible = true
                        boxLines[2].From = posTopRight; boxLines[2].To = posBottomRight; boxLines[2].Visible = true
                        boxLines[3].From = posBottomRight; boxLines[3].To = posBottomLeft; boxLines[3].Visible = true
                        boxLines[4].From = posBottomLeft; boxLines[4].To = posTopLeft; boxLines[4].Visible = true
                    else
                        for _, line in pairs(BoxDrawings[player]) do line.Visible = false end
                    end
                else
                    if BoxDrawings[player] then
                        for _, line in pairs(BoxDrawings[player]) do line.Visible = false end
                    end
                end
                
                -- 3. TRACERS
                if Settings.Tracers then
                    if not TracerLines[player] then
                        local line = Drawing.new("Line")
                        line.Visible = false
                        line.Thickness = 1
                        TracerLines[player] = line
                    end
                    
                    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        TracersLines = TracerLines[player]
                        TracersLines.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        TracersLines.To = Vector2.new(vector.X, vector.Y)
                        TracersLines.Color = Settings.TracerColor
                        TracersLines.Visible = true
                    else
                        TracerLines[player].Visible = false
                    end
                else
                    if TracerLines[player] then TracerLines[player].Visible = false end
                end
            else
                if Highlights[player] then Highlights[player].Enabled = false end
                if BoxDrawings[player] then for _, l in pairs(BoxDrawings[player]) do l.Visible = false end end
                if TracerLines[player] then TracerLines[player].Visible = false end
            end
        end
    end
end)

-- 4. TRACER BULLETS (От дула оружия)
local mouse = LocalPlayer:GetMouse()
mouse.Button1Down:Connect(function()
    if Settings.TracerBullets then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local startPos = character.HumanoidRootPart.Position
            
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                local muzzlePart = tool:FindFirstChild("Muzzle") or tool:FindFirstChild("Handle")
                if muzzlePart then
                    startPos = muzzlePart.Position
                else
                    startPos = character.Head.Position + Vector3.new(0, -0.5, 1)
                end
            else
                startPos = character.Head.Position + Vector3.new(0, -0.5, 1)
            end
            
            local hitPos = mouse.Hit.Position
            local beam = Drawing.new("Line")
            
            local startScreen, startOnScreen = Camera:WorldToViewportPoint(startPos)
            local hitScreen, hitOnScreen = Camera:WorldToViewportPoint(hitPos)
            
            if startOnScreen then
                beam.From = Vector2.new(startScreen.X, startScreen.Y)
            else
                beam.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            end
            
            if hitOnScreen then
                beam.To = Vector2.new(hitScreen.X, hitScreen.Y)
            else
                beam.To = beam.From
            end
            
            beam.Color = Settings.TracerColor
            beam.Thickness = Settings.TracerType == "Neon" and 3 or 1
            beam.Visible = true
            
            coroutine.wrap(function()
                for i = 1, 20 do
                    task.wait(0.02)
                    beam.Transparency = 1 - (i / 20)
                end
                beam:Remove()
            end)()
        end
    end
end)
