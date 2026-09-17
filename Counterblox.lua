--[[
    Project Sky - Murder Mystery 2 (Full Script: Roles ESP + Fixed Misc)
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

-- Настройки
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
        SelectedTarget = nil,
        Fly = false,
        FlySpeed = 50,
        Noclip = false,
        Spin = false,
        SpinSpeed = 50
    }
}

-- Цвета ролей MM2
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
    
    local function checkTools(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") or name:find("нож") then hasKnife = true end
                if name:find("gun") or name:find("revolver") or name:find("пистолет") then hasGun = true end
            end
        end
    end
    
    checkTools(char)
    checkTools(backpack)
    
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

-- ==================== СОЗДАНИЕ UI ====================
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

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 55)
MainStroke.Thickness = 1.5

-- Перетаскивание UI
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name = "TopBar"
TopBar.BackgroundTransparency = 1
TopBar.Size = UDim2.new(1, 0, 0, 35)

local Title = Instance.new("TextLabel", TopBar)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(1, -15, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Project Sky | MM2 Advanced"
Title.TextColor3 = Color3.fromRGB(255, 170, 0)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Левая панель вкладок
local TabContainer = Instance.new("ScrollingFrame", MainFrame)
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.Size = UDim2.new(0, 120, 1, -55)
TabContainer.ScrollBarThickness = 0

local TabListLayout = Instance.new("UIListLayout", TabContainer)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)

-- Правая панель контента
local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 140, 0, 45)
ContentContainer.Size = UDim2.new(1, -150, 1, -55)

local Tabs = {}
local function createTab(name)
    local tabBtn = Instance.new("TextButton", TabContainer)
    tabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(170, 170, 180)
    tabBtn.TextSize = 13
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    local tabContent = Instance.new("ScrollingFrame", ContentContainer)
    tabContent.BackgroundTransparency = 1
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.ScrollBarThickness = 2
    tabContent.Visible = false

    local contentLayout = Instance.new("UIListLayout", tabContent)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Content.Visible = false
            t.Button.TextColor3 = Color3.fromRGB(170, 170, 180)
            t.Button.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        end
        tabContent.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    end)

    if #Tabs == 0 then
        tabContent.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    end

    table.insert(Tabs, {Button = tabBtn, Content = tabContent})
    return tabContent
end

local function addToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.Font = Enum.Font.Gotham
    btn.Text = "  " .. text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = "  " .. text .. (state and ": ON" or ": OFF")
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(220, 220, 220)
        callback(state)
    end)
    return btn
end

local function addButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ==================== ВКЛАДКА 1: VISUALS ====================
local VisualsTab = createTab("VISUALS")

addToggle(VisualsTab, "Highlight ESP", function(s) Settings.Visuals.Highlight = s end)
addToggle(VisualsTab, "Boxes ESP", function(s) Settings.Visuals.Boxes = s end)
addToggle(VisualsTab, "Tracers", function(s) Settings.Visuals.Tracers = s end)

local bulletSubFrame = Instance.new("Frame", VisualsTab)
bulletSubFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
bulletSubFrame.Size = UDim2.new(1, -10, 0, 60)
bulletSubFrame.Visible = false
Instance.new("UICorner", bulletSubFrame).CornerRadius = UDim.new(0, 6)
local subLayout = Instance.new("UIListLayout", bulletSubFrame)
subLayout.Padding = UDim.new(0, 4)

addToggle(VisualsTab, "Tracer Bullets", function(s)
    Settings.Visuals.BulletTracers = s
    bulletSubFrame.Visible = s
end)

local modeBtn = Instance.new("TextButton", bulletSubFrame)
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

local colorBtn = Instance.new("TextButton", bulletSubFrame)
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
    colorIdx = (colorIdx % #colorsList) + 1
    local selected = colorsList[colorIdx]
    Settings.Visuals.BulletTracerColor = selected.Color
    colorBtn.Text = " Цвет: " .. selected.Name
    colorBtn.TextColor3 = selected.Color
end)

-- ==================== ВКЛАДКА 2: MISC ====================
local MiscTab = createTab("MISC")

-- 1. Anti-Fling
addToggle(MiscTab, "Anti-Fling", function(s)
    Settings.Misc.AntiFling = s
end)

-- 2. Target Fling (Выбор цели + Отдельный запуск)
local flingSubFrame = Instance.new("Frame", MiscTab)
flingSubFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
flingSubFrame.Size = UDim2.new(1, -10, 0, 68)
Instance.new("UICorner", flingSubFrame).CornerRadius = UDim.new(0, 6)
local flingLayout = Instance.new("UIListLayout", flingSubFrame)
flingLayout.Padding = UDim.new(0, 4)

local targetSelectBtn = Instance.new("TextButton", flingSubFrame)
targetSelectBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
targetSelectBtn.Size = UDim2.new(1, 0, 0, 28)
targetSelectBtn.Font = Enum.Font.Gotham
targetSelectBtn.Text = " Цель: Выбрать игрока"
targetSelectBtn.TextColor3 = Color3.fromRGB(255, 170, 0)
targetSelectBtn.TextSize = 11
targetSelectBtn.TextXAlignment = Enum.TextXAlignment.Left

local otherPlayers = {}
local targetIdx = 0
targetSelectBtn.MouseButton1Click:Connect(function()
    otherPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(otherPlayers, p) end
    end
    if #otherPlayers > 0 then
        targetIdx = (targetIdx % #otherPlayers) + 1
        Settings.Misc.SelectedTarget = otherPlayers[targetIdx]
        targetSelectBtn.Text = " Цель: " .. Settings.Misc.SelectedTarget.Name
    else
        targetSelectBtn.Text = " Цель: Нет игроков"
        Settings.Misc.SelectedTarget = nil
    end
end)

local flingConnection = nil
local function executeFling()
    local target = Settings.Misc.SelectedTarget
    if not target or not target.Character then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not root or not target.Character:FindFirstChild("HumanoidRootPart") then return end

    if flingConnection then flingConnection:Disconnect() end

    local bav = Instance.new("BodyAngularVelocity")
    bav.Name = "FlingForce"
    bav.AngularVelocity = Vector3.new(999999, 999999, 999999)
    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bav.Parent = root

    local oldCFrame = root.CFrame
    local startTime = tick()

    flingConnection = RunService.Heartbeat:Connect(function()
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and (tick() - startTime < 1.2) then
            root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
            root.Velocity = Vector3.new(0, -10000, 0)
        else
            if flingConnection then flingConnection:Disconnect() end
            if bav then bav:Destroy() end
            root.CFrame = oldCFrame
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

addButton(flingSubFrame, "🚀 Запустить Fling (Вниз)", executeFling)

-- 3. Fly (Полёт)
local flySubFrame = Instance.new("Frame", MiscTab)
flySubFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
flySubFrame.Size = UDim2.new(1, -10, 0, 32)
flySubFrame.Visible = false
Instance.new("UICorner", flySubFrame).CornerRadius = UDim.new(0, 6)

local flySpeedBtn = Instance.new("TextButton", flySubFrame)
flySpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
flySpeedBtn.Size = UDim2.new(1, 0, 1, 0)
flySpeedBtn.Font = Enum.Font.Gotham
flySpeedBtn.Text = " Скорость флая: 50"
flySpeedBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
flySpeedBtn.TextSize = 11
flySpeedBtn.TextXAlignment = Enum.TextXAlignment.Left

local speeds = {30, 50, 80, 120, 200}
local speedIdx = 2
flySpeedBtn.MouseButton1Click:Connect(function()
    speedIdx = (speedIdx % #speeds) + 1
    Settings.Misc.FlySpeed = speeds[speedIdx]
    flySpeedBtn.Text = " Скорость флая: " .. Settings.Misc.FlySpeed
end)

local flyBg, flyBv
local flyKeys = {W = false, A = false, S = false, D = false}

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true
    elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = true
    elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = true
    elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false
    elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = false
    elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = false
    elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = false end
end)

addToggle(MiscTab, "Fly (Полёт)", function(state)
    Settings.Misc.Fly = state
    flySubFrame.Visible = state
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    if state then
        flyBg = Instance.new("BodyGyro", root)
        flyBg.P = 9e4
        flyBg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBg.cframe = root.CFrame
        
        flyBv = Instance.new("BodyVelocity", root)
        flyBv.velocity = Vector3.new(0, 0, 0)
        flyBv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        
        hum.PlatformStand = true

        task.spawn(function()
            while Settings.Misc.Fly and char and root and root.Parent do
                local moveDir = Vector3.new(0, 0, 0)
                if flyKeys.W then moveDir = moveDir + Camera.CFrame.LookVector end
                if flyKeys.S then moveDir = moveDir - Camera.CFrame.LookVector end
                if flyKeys.A then moveDir = moveDir - Camera.CFrame.RightVector end
                if flyKeys.D then moveDir = moveDir + Camera.CFrame.RightVector end
                
                if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
                
                flyBv.velocity = moveDir * Settings.Misc.FlySpeed
                flyBg.cframe = Camera.CFrame
                task.wait()
            end
        end)
    else
        if flyBg then flyBg:Destroy() end
        if flyBv then flyBv:Destroy() end
        hum.PlatformStand = false
        flyKeys = {W = false, A = false, S = false, D = false}
    end
end)

-- 4. Noclip
addToggle(MiscTab, "Noclip", function(s) Settings.Misc.Noclip = s end)

-- 5. SpinBot
local spinSubFrame = Instance.new("Frame", MiscTab)
spinSubFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
spinSubFrame.Size = UDim2.new(1, -10, 0, 32)
spinSubFrame.Visible = false
Instance.new("UICorner", spinSubFrame).CornerRadius = UDim.new(0, 6)

local spinSpeedBtn = Instance.new("TextButton", spinSubFrame)
spinSpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
spinSpeedBtn.Size = UDim2.new(1, 0, 1, 0)
spinSpeedBtn.Font = Enum.Font.Gotham
spinSpeedBtn.Text = " Скорость спина: 50"
spinSpeedBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
spinSpeedBtn.TextSize = 11
spinSpeedBtn.TextXAlignment = Enum.TextXAlignment.Left

local spinSpeeds = {20, 50, 100, 200, 500}
local spinSpeedIdx = 2
spinSpeedBtn.MouseButton1Click:Connect(function()
    spinSpeedIdx = (spinSpeedIdx % #spinSpeeds) + 1
    Settings.Misc.SpinSpeed = spinSpeeds[spinSpeedIdx]
    spinSpeedBtn.Text = " Скорость спина: " .. Settings.Misc.SpinSpeed
end)

addToggle(MiscTab, "SpinBot (Крутилка)", function(s)
    Settings.Misc.Spin = s
    spinSubFrame.Visible = s
end)

-- ==================== РЕНДЕР И ОБРАБОТКА ====================

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

-- Рендер пулевых трейсеров
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

-- Цикл Anti-Fling, Noclip и SpinBot
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- Anti-Fling (безопасное отключение столкновения с чужими игроками)
    if Settings.Misc.AntiFling then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end

    -- Noclip
    if Settings.Misc.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- SpinBot
    if Settings.Misc.Spin and root then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Settings.Misc.SpinSpeed), 0)
    end
end)

print("Project Sky (MM2) — основной код успешно загружен!")
