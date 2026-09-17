--[[
    Project Sky - Murder Mystery 2
    Modular UI & Advanced Visuals Base
]]--

if _G.ProjectSkyMM2Loaded then
    warn("Project Sky (MM2) уже запущен!")
    return
end
_G.ProjectSkyMM2Loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки функций
local Settings = {
    Visuals = {
        Highlight = false,
        Boxes = false,
        Tracers = false,
        BulletTracers = false,
        BulletTracerMode = "Simple", -- "Simple" или "Neon"
        BulletTracerColor = Color3.fromRGB(0, 170, 255),
        TeamCheck = false -- В MM2 команды как таковые другие, но оставим параметр для совместимости
    }
}

-- Создание главного UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProjectSkyMM2"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.Size = UDim2.new(0, 450, 0, 300)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(40, 40, 55)
MainStroke.Thickness = 1.5

-- Шапка (для перетаскивания)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundTransparency = 1
TopBar.Size = UDim2.new(1, 0, 0, 35)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(1, -15, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Project Sky | Murder Mystery 2"
Title.TextColor3 = Color3.fromRGB(255, 170, 0)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Логика перетаскивания окна
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Левая панель (Вкладки)
local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Parent = MainFrame
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.Size = UDim2.new(0, 120, 1, -55)
TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TabContainer.ScrollBarThickness = 2

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabContainer
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)

-- Правая панель (Контент вкладок)
local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 140, 0, 45)
ContentContainer.Size = UDim2.new(1, -150, 1, -55)

-- Функция создания вкладки
local Tabs = {}
local function createTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Parent = TabContainer
    tabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    tabButton.BorderSizePixel = 0
    tabButton.Size = UDim2.new(1, 0, 0, 32)
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.Text = name
    tabButton.TextColor3 = Color3.fromRGB(170, 170, 180)
    tabButton.TextSize = 13

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tabButton

    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Parent = ContentContainer
    tabContent.BackgroundTransparency = 1
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.ScrollBarThickness = 3
    tabContent.Visible = false

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = tabContent
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)

    tabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Content.Visible = false
            t.Button.TextColor3 = Color3.fromRGB(170, 170, 180)
            t.Button.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        end
        tabContent.Visible = true
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    end)

    if #Tabs == 0 then
        tabContent.Visible = true
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    end

    table.insert(Tabs, {Button = tabButton, Content = tabContent})
    return tabContent
end

-- Функция создания чекбокса
local function addToggle(parent, text, callback)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = parent
    toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    toggleBtn.Size = UDim2.new(1, -10, 0, 36)
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.Text = "  " .. text .. ": OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    toggleBtn.TextSize = 12
    toggleBtn.TextXAlignment = Enum.TextXAlignment.Left

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggleBtn

    local state = false
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = "  " .. text .. (state and ": ON" or ": OFF")
        toggleBtn.TextColor3 = state and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(220, 220, 220)
        callback(state)
    end)
end

-- Создаем вкладку VISUALS
local VisualsTab = createTab("VISUALS")

-- 1. Highlight (Подсветка)
addToggle(VisualsTab, "Highlight ESP", function(state)
    Settings.Visuals.Highlight = state
end)

-- 2. Boxes (2D Боксы)
addToggle(VisualsTab, "Boxes ESP", function(state)
    Settings.Visuals.Boxes = state
end)

-- 3. Tracers (Линии до игроков)
addToggle(VisualsTab, "Tracers", function(state)
    Settings.Visuals.Tracers = state
end)

-- 4. Tracer Bullets + подвкладка (настройки цвета и режима)
local bulletSubFrame = Instance.new("Frame")
bulletSubFrame.Parent = VisualsTab
bulletSubFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
bulletSubFrame.Size = UDim2.new(1, -10, 0, 95)
bulletSubFrame.Visible = false

local subCorner = Instance.new("UICorner")
subCorner.CornerRadius = UDim.new(0, 6)
subCorner.Parent = bulletSubFrame

local subLayout = Instance.new("UIListLayout")
subLayout.Parent = bulletSubFrame
subLayout.SortOrder = Enum.SortOrder.LayoutOrder
subLayout.Padding = UDim.new(0, 5)

-- Кнопка включения Tracer Bullets
addToggle(VisualsTab, "Tracer Bullets", function(state)
    Settings.Visuals.BulletTracers = state
    bulletSubFrame.Visible = state
end)

-- Подвкладка: выбор режима (Simple / Neon)
local modeBtn = Instance.new("TextButton")
modeBtn.Parent = bulletSubFrame
modeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
modeBtn.Size = UDim2.new(1, 0, 0, 28)
modeBtn.Font = Enum.Font.Gotham
modeBtn.Text = " Режим: Простой (Simple)"
modeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
modeBtn.TextSize = 11
modeBtn.TextXAlignment = Enum.TextXAlignment.Left

modeBtn.MouseButton1Click:Connect(function()
    if Settings.Visuals.BulletTracerMode == "Simple" then
        Settings.Visuals.BulletTracerMode = "Neon"
        modeBtn.Text = " Режим: Неоновый (Neon)"
        modeBtn.TextColor3 = Color3.fromRGB(255, 170, 0)
    else
        Settings.Visuals.BulletTracerMode = "Simple"
        modeBtn.Text = " Режим: Простой (Simple)"
        modeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- Подвкладка: смена цвета линий выстрела
local colorBtn = Instance.new("TextButton")
colorBtn.Parent = bulletSubFrame
colorBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
colorBtn.Size = UDim2.new(1, 0, 0, 28)
colorBtn.Font = Enum.Font.Gotham
colorBtn.Text = " Цвет: Оранжевый"
colorBtn.TextColor3 = Color3.fromRGB(255, 170, 0)
colorBtn.TextSize = 11
colorBtn.TextXAlignment = Enum.TextXAlignment.Left

local colorsList = {
    {Name = "Оранжевый", Color = Color3.fromRGB(255, 170, 0)},
    {Name = "Красный", Color = Color3.fromRGB(255, 50, 50)},
    {Name = "Зеленый", Color = Color3.fromRGB(50, 255, 50)},
    {Name = "Голубой", Color = Color3.fromRGB(0, 170, 255)}
}
local colorIdx = 1

colorBtn.MouseButton1Click:Connect(function()
    colorIdx = colorIdx % #colorsList + 1
    local selected = colorsList[colorIdx]
    Settings.Visuals.BulletTracerColor = selected.Color
    colorBtn.Text = " Цвет: " .. selected.Name
    colorBtn.TextColor3 = selected.Color
end)


-- ЛОГИКА ОТРИСОВКИ И ОБНОВЛЕНИЯ (ESP, Boxes, Tracers)
local function setupPlayerESP(player)
    if player == LocalPlayer then return end

    -- 1. Highlight
    local highlight = Instance.new("Highlight")
    highlight.Parent = CoreGui
    highlight.Adornee = nil
    highlight.FillColor = Color3.fromRGB(255, 170, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Enabled = false

    -- 2. 2D Box
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 170, 0)
    box.Thickness = 1
    box.Filled = false

    -- 3. Tracer
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(255, 170, 0)
    tracer.Thickness = 1

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if not char or not hum or not root or hum.Health <= 0 then
            highlight.Enabled = false
            box.Visible = false
            tracer.Visible = false
            return
        end

        -- Обновление Highlight
        highlight.Adornee = char
        highlight.Enabled = Settings.Visuals.Highlight

        -- Проекция на экран
        local vector, onScreen = Camera:WorldToViewportPoint(root.Position)

        if onScreen then
            -- Boxes
            if Settings.Visuals.Boxes then
                box.Size = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
                box.Position = Vector2.new(vector.X - box.Size.X / 2, vector.Y - box.Size.Y / 2)
                box.Visible = true
            else
                box.Visible = false
            end

            -- Tracers
            if Settings.Visuals.Tracers then
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(vector.X, vector.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        else
            box.Visible = false
            tracer.Visible = false
        end
    end)

    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            connection:Disconnect()
            highlight:Destroy()
            box:Remove()
            tracer:Remove()
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    setupPlayerESP(p)
end
Players.PlayerAdded:Connect(setupPlayerESP)

-- Логика Tracer Bullets
RunService.RenderStepped:Connect(function()
    if Settings.Visuals.BulletTracers then
        local tracerBeam = Drawing.new("Line")
        tracerBeam.Visible = true
        tracerBeam.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        tracerBeam.To = Vector2.new(Camera.ViewportSize.X / 2 + math.random(-60, 60), Camera.ViewportSize.Y / 2 + math.random(-60, 60))
        tracerBeam.Color = Settings.Visuals.BulletTracerColor
        tracerBeam.Thickness = (Settings.Visuals.BulletTracerMode == "Neon") and 3 or 1

        task.delay(0.05, function()
            tracerBeam:Remove()
        end)
    end
end)

print("Project Sky (MM2) успешно загружен!")
