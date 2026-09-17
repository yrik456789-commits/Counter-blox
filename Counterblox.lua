--[[
    Project Sky - Murder Mystery 2 (Roles ESP + Advanced Misc)
    Tabs: Visuals, Misc (Anti-Fling, Target Fling [Downwards], Fly, Noclip, Spin)
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
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Настройки скрипта
local Settings = {
    Visuals = {
        Highlight = false,
        Boxes = false,
        Tracers = false,
        BulletTracers = false,
        BulletTracerMode = "Simple",
        BulletTracerColor = Color3.fromRGB(255, 170, 0)
    },
    Misc = {
        AntiFling = false,
        TargetFlingEnabled = false,
        SelectedTarget = nil,
        Fly = false,
        FlySpeed = 50,
        Noclip = false,
        Spin = false,
        SpinSpeed = 50
    }
}

-- Цвета ролей для ESP
local Colors = {
    Lobby = Color3.fromRGB(150, 150, 150),
    Innocent = Color3.fromRGB(0, 255, 127),
    Sheriff = Color3.fromRGB(0, 150, 255),
    Murderer = Color3.fromRGB(255, 50, 50)
}

local function getPlayerRole(player)
    local char = player.Character
    local backpack = player:FindFirstChildOfClass("Backpack")
    local hasKnife, hasGun = false, false
    
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") or name:find("нож") then hasKnife = true end
                if name:find("gun") or name:find("revolver") or name:find("пистолет") then hasGun = true end
            end
        end
    end
    
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") or name:find("нож") then hasKnife = true end
                if name:find("gun") or name:find("revolver") or name:find("пистолет") then hasGun = true end
            end
        end
    end
    
    if not hasKnife and not hasGun and (not char or not char:FindFirstChild("HumanoidRootPart")) then
        return "Lobby", Colors.Lobby
    end
    
    if hasKnife then
        return "Murderer", Colors.Murderer
    elseif hasGun then
        return "Sheriff", Colors.Sheriff
    else
        return "Innocent", Colors.Innocent
    end
end

-- Создание UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProjectSkyMM2"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.Size = UDim2.new(0, 450, 0, 320)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(40, 40, 55)
MainStroke.Thickness = 1.5

-- Шапка (Перетаскивание)
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
Title.Text = "Project Sky | MM2 Advanced"
Title.TextColor3 = Color3.fromRGB(255, 170, 0)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

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

-- Правая панель (Контент)
local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 140, 0, 45)
ContentContainer.Size = UDim2.new(1, -150, 1, -55)

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

local function addToggle(parent, text, callback)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = parent
    toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    toggleBtn.Size = UDim2.new(1, -10, 0, 34)
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

-- ==================== ВКЛАДКА 1: VISUALS ====================
local VisualsTab = createTab("VISUALS")

addToggle(VisualsTab, "Highlight ESP", function(state) Settings.Visuals.Highlight = state end)
addToggle(VisualsTab, "Boxes ESP", function(state) Settings.Visuals.Boxes = state end)
addToggle(VisualsTab, "Tracers", function(state) Settings.Visuals.Tracers = state end)

local bulletSubFrame = Instance.new("Frame")
bulletSubFrame.Parent = VisualsTab
bulletSubFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
bulletSubFrame.Size = UDim2.new(1, -10, 0, 85)
bulletSubFrame.Visible = false

local subCorner = Instance.new("UICorner")
subCorner.CornerRadius = UDim.new(0, 6)
subCorner.Parent = bulletSubFrame

local subLayout = Instance.new("UIListLayout")
subLayout.Parent = bulletSubFrame
subLayout.SortOrder = Enum.SortOrder.LayoutOrder
subLayout.Padding = UDim.new(0, 4)

addToggle(VisualsTab, "Tracer Bullets", function(state)
    Settings.Visuals.BulletTracers = state
    bulletSubFrame.Visible = state
end)

local modeBtn = Instance.new("TextButton")
modeBtn.Parent = bulletSubFrame
modeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
modeBtn.Size = UDim2.new(1, 0, 0, 26)
modeBtn.Font = Enum.Font.Gotham
modeBtn.Text = " Режим: Простой"
modeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
modeBtn.TextSize = 11
modeBtn.TextXAlignment = Enum.TextXAlignment.Left

modeBtn.MouseButton1Click:Connect(function()
    if Settings.Visuals.BulletTracerMode == "Simple" then
        Settings.Visuals.BulletTracerMode = "Neon"
        modeBtn.Text = " Режим: Неоновый"
    else
        Settings.Visuals.BulletTracerMode = "Simple"
        modeBtn.Text = " Режим: Простой"
    end
end)

local colorBtn = Instance.new("TextButton")
colorBtn.Parent = bulletSubFrame
colorBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
colorBtn.Size = UDim2.new(1, 0, 0, 26)
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


-- ==================== ВКЛАДКА 2: MISC ====================
local MiscTab = createTab("MISC")

-- 1. Anti-Fling
addToggle(MiscTab, "Anti-Fling", function(state)
    Settings.Misc.AntiFling = state
end)

-- 2. Target Fling + подвкладка выбора игрока
local flingSubFrame = Instance.new("Frame")
flingSubFrame.Parent = MiscTab
flingSubFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
flingSubFrame.Size = UDim2.new(1, -10, 0, 65)
flingSubFrame.Visible = false

local flingSubCorner = Instance.new("UICorner")
flingSubCorner.CornerRadius = UDim.new(0, 6)
flingSubCorner.Parent = flingSubFrame

local flingSubLayout = Instance.new("UIListLayout")
flingSubLayout.Parent = flingSubFrame
flingSubLayout.SortOrder = Enum.SortOrder.LayoutOrder
flingSubLayout.Padding = UDim.new(0, 4)

addToggle(MiscTab, "Target Fling (Вниз)", function(state)
    Settings.Misc.TargetFlingEnabled = state
    flingSubFrame.Visible = state
end)

local targetSelectBtn = Instance.new("TextButton")
targetSelectBtn.Parent = flingSubFrame
targetSelectBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
targetSelectBtn.Size = UDim2.new(1, 0, 0, 28)
targetSelectBtn.Font = Enum.Font.Gotham
targetSelectBtn.Text = " Цель: Выбрать игрока"
targetSelectBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
targetSelectBtn.TextSize = 11
targetSelectBtn.TextXAlignment = Enum.TextXAlignment.Left

local otherPlayers = {}
local targetIdx = 1
targetSelectBtn.MouseButton1Click:Connect(function()
    otherPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(otherPlayers, p) end
    end
    if #otherPlayers > 0 then
        targetIdx = targetIdx % #otherPlayers + 1
        Settings.Misc.SelectedTarget = otherPlayers[targetIdx]
        targetSelectBtn.Text = " Цель: " .. Settings.Misc.SelectedTarget.Name
    else
        targetSelectBtn.Text = " Цель: Нет игроков"
    end
end)

-- 3. Fly + Поднастройка скорости
local flySubFrame = Instance.new("Frame")
flySubFrame.Parent = MiscTab
flySubFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
flySubFrame.Size = UDim2.new(1, -10, 0, 65)
flySubFrame.Visible = false

local flySubCorner = Instance.new("UICorner")
flySubCorner.CornerRadius = UDim.new(0, 6)
flySubCorner.Parent = flySubFrame

local flySubLayout = Instance.new("UIListLayout")
flySubLayout.Parent = flySubFrame
flySubLayout.SortOrder = Enum.SortOrder.LayoutOrder
flySubLayout.Padding = UDim.new(0, 4)

addToggle(MiscTab, "Fly (Полёт)", function(state)
    Settings.Misc.Fly = state
    flySubFrame.Visible = state
end)

local flySpeedBtn = Instance.new("TextButton")
flySpeedBtn.Parent = flySubFrame
flySpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
flySpeedBtn.Size = UDim2.new(1, 0, 0, 28)
flySpeedBtn.Font = Enum.Font.Gotham
flySpeedBtn.Text = " Скорость флая: 50"
flySpeedBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
flySpeedBtn.TextSize = 11
flySpeedBtn.TextXAlignment = Enum.TextXAlignment.Left

local speeds = {30, 50, 80, 120, 200}
local speedIdx = 2
flySpeedBtn.MouseButton1Click:Connect(function()
    speedIdx = speedIdx % #speeds + 1
    Settings.Misc.FlySpeed = speeds[speedIdx]
    flySpeedBtn.Text = " Скорость флая: " .. Settings.Misc.FlySpeed
end)

-- 4. Noclip
addToggle(MiscTab, "Noclip", function(state)
    Settings.Misc.Noclip = state
end)

-- 5. SpinBot + Поднастройка скорости
local spinSubFrame = Instance.new("Frame")
spinSubFrame.Parent = MiscTab
spinSubFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
spinSubFrame.Size = UDim2.new(1, -10, 0, 65)
spinSubFrame.Visible = false

local spinSubCorner = Instance.new("UICorner")
spinSubCorner.CornerRadius = UDim.new(0, 6)
spinSubCorner.Parent = spinSubFrame

local spinSubLayout = Instance.new("UIListLayout")
spinSubLayout.Parent = spinSubFrame
spinSubLayout.SortOrder = Enum.SortOrder.LayoutOrder
spinSubLayout.Padding = UDim.new(0, 4)

addToggle(MiscTab, "SpinBot (Крутилка)", function(state)
    Settings.Misc.Spin = state
    spinSubFrame.Visible = state
end)

local spinSpeedBtn = Instance.new("TextButton")
spinSpeedBtn.Parent = spinSubFrame
spinSpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
spinSpeedBtn.Size = UDim2.new(1, 0, 0, 28)
spinSpeedBtn.Font = Enum.Font.Gotham
spinSpeedBtn.Text = " Скорость спина: 50"
spinSpeedBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
spinSpeedBtn.TextSize = 11
spinSpeedBtn.TextXAlignment = Enum.TextXAlignment.Left

local spinSpeeds = {20, 50, 100, 200, 500}
local spinSpeedIdx = 2
spinSpeedBtn.MouseButton1Click:Connect(function()
    spinSpeedIdx = spinSpeedIdx % #spinSpeeds + 1
    Settings.Misc.SpinSpeed = spinSpeeds[spinSpeedIdx]
    spinSpeedBtn.Text = " Скорость спина: " .. Settings.Misc.SpinSpeed
end)


-- ==================== ФОНОВАЯ ЛОГИКА И ВИЗУАЛЫ ====================

-- Рендер ESP по ролям
local function setupPlayerESP(player)
    if player == LocalPlayer then return end

    local highlight = Instance.new("Highlight")
    highlight.Parent = CoreGui
    highlight.Adornee = nil
    highlight.FillTransparency = 0.5
    highlight.Enabled = false

    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1
    box.Filled = false

    local tracer = Drawing.new("Line")
    tracer.Visible = false
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

        local role, roleColor = getPlayerRole(player)
        highlight.FillColor = roleColor
        highlight.OutlineColor = roleColor
        box.Color = roleColor
        tracer.Color = roleColor

        highlight.Adornee = char
        highlight.Enabled = Settings.Visuals.Highlight

        local vector, onScreen = Camera:WorldToViewportPoint(root.Position)

        if onScreen then
            if Settings.Visuals.Boxes then
                box.Size = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
                box.Position = Vector2.new(vector.X - box.Size.X / 2, vector.Y - box.Size.Y / 2)
                box.Visible = true
            else
                box.Visible = false
            end

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

for _, p in ipairs(Players:GetPlayers()) do setupPlayerESP(p) end
Players.PlayerAdded:Connect(setupPlayerESP)

-- Пулевые трессеры
RunService.RenderStepped:Connect(function()
    if Settings.Visuals.BulletTracers then
        local tracerBeam = Drawing.new("Line")
        tracerBeam.Visible = true
        tracerBeam.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        tracerBeam.To = Vector2.new(Camera.ViewportSize.X / 2 + math.random(-60, 60), Camera.ViewportSize.Y / 2 + math.random(-60, 60))
        tracerBeam.Color = Settings.Visuals.BulletTracerColor
        tracerBeam.Thickness = (Settings.Visuals.BulletTracerMode == "Neon") and 3 or 1

        task.delay(0.05, function() tracerBeam:Remove() end)
    end
end)

-- РАБОТА ФУНКЦИЙ MISC (Anti-Fling, Target Fling ВНИЗ, Fly, Noclip, Spin)
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    -- 1. Anti-Fling (отключение коллизий и сброс скоростей раскидки)
    if Settings.Misc.AntiFling and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            end
        end
    end

    -- 2. Target Fling (Раскидка выбранного игрока ВНИЗ под карту)
    if Settings.Misc.TargetFlingEnabled and Settings.Misc.SelectedTarget and root then
        local targetChar = Settings.Misc.SelectedTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local oldPos = root.CFrame
            -- Телепортируемся прямо под цель и толкаем сильно вниз по оси Y
            root.CFrame = targetRoot.CFrame - Vector3.new(0, 5, 0)
            root.Velocity = Vector3.new(0, -9999, 0)
            task.wait(0.02)
            root.CFrame = oldPos
        end
    end

    -- 3. Noclip
    if Settings.Misc.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- 4. SpinBot
    if Settings.Misc.Spin and root then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Settings.Misc.SpinSpeed), 0)
    end
end)

-- 5. Fly (Полёт)
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if Settings.Misc.Fly and root and hum then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        local camVector = Camera.CFrame.LookVector
        local velocity = Vector3.new(0, 0, 0)

        if moveDir.Magnitude > 0 then
            velocity = (Camera.CFrame.LookVector * moveDir.Z + Camera.CFrame.RightVector * moveDir.X) * Settings.Misc.FlySpeed
        else
            velocity = Vector3.new(0, 0, 0)
        end
        root.Velocity = velocity
    elseif hum then
        hum.PlatformStand = false
    end
end)

print("Project Sky (MM2) с вкладкой Misc успешно загружен!")
