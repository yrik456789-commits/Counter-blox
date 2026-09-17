--[[
    Project Sky 1.1 - Murder Mystery 2 (Full Script: Intro 1.1 + Minimize/Close + Fixed Combat/Misc/Visuals)
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
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==================== ИНТРО АНИМАЦИЯ (1.1) ====================
local IntroGui = Instance.new("ScreenGui")
IntroGui.Name = "ProjectSkyIntro"
IntroGui.Parent = CoreGui

local IntroBg = Instance.new("Frame", IntroGui)
IntroBg.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
IntroBg.Size = UDim2.new(1, 0, 1, 0)
IntroBg.BackgroundTransparency = 0

local IntroText = Instance.new("TextLabel", IntroBg)
IntroText.BackgroundTransparency = 1
IntroText.AnchorPoint = Vector2.new(0.5, 0.5)
IntroText.Position = UDim2.new(-0.5, 0, 0.5, 0)
IntroText.Size = UDim2.new(0, 500, 0, 100)
IntroText.Font = Enum.Font.GothamBold
IntroText.Text = "PROJECT SKY <font color='#8c46ff'>1.1</font>"
IntroText.RichText = true
IntroText.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroText.TextSize = 36
IntroText.TextXAlignment = Enum.TextXAlignment.Center

TweenService:Create(IntroText, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()

task.wait(2.2)

TweenService:Create(IntroBg, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
TweenService:Create(IntroText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()

task.wait(0.6)
IntroGui:Destroy()

-- Настройки
local Settings = {
    Visuals = {
        Highlight = false,
        Boxes = false,
        Tracers = false,
        BulletTracers = false,
        BulletTracerMode = "Simple",
        BulletTracerColor = Color3.fromRGB(140, 70, 255),
        GunAlert = false,
        GunESP = false
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
    Lobby = Color3.fromRGB(140, 140, 140),
    Innocent = Color3.fromRGB(50, 255, 150),
    Sheriff = Color3.fromRGB(50, 150, 255),
    Murderer = Color3.fromRGB(255, 60, 60)
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

-- ==================== ОСНОВНОЙ ГУИ ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProjectSkyMM2"
ScreenGui.Parent = CoreGui

-- Сообщение внизу экрана (Упал пистолет)
local GunAlertLabel = Instance.new("TextLabel", ScreenGui)
GunAlertLabel.Name = "GunAlertLabel"
GunAlertLabel.AnchorPoint = Vector2.new(0.5, 1)
GunAlertLabel.Position = UDim2.new(0.5, 0, 1, -25)
GunAlertLabel.Size = UDim2.new(0, 320, 0, 36)
GunAlertLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
GunAlertLabel.Font = Enum.Font.GothamBold
GunAlertLabel.Text = "⚠️ Пистолет упал на карте!"
GunAlertLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
GunAlertLabel.TextSize = 13
GunAlertLabel.Visible = false
Instance.new("UICorner", GunAlertLabel).CornerRadius = UDim.new(0, 6)
local alertStroke = Instance.new("UIStroke", GunAlertLabel)
alertStroke.Color = Color3.fromRGB(255, 60, 60)
alertStroke.Thickness = 1.5

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -165)
MainFrame.Size = UDim2.new(0, 460, 0, 330)
MainFrame.BackgroundTransparency = 1

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(60, 30, 95)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 1

-- Анимация появления главного окна
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
TweenService:Create(MainStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()

-- Шапка
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name = "TopBar"
TopBar.BackgroundTransparency = 1
TopBar.Size = UDim2.new(1, 0, 0, 40)

local Title = Instance.new("TextLabel", TopBar)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "PROJECT SKY <font color='#8c46ff'>| MM2 Advanced</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка сворачивания
local MinimizeBtn = Instance.new("TextButton", TopBar)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MinimizeBtn.Position = UDim2.new(1, -65, 0.5, -12)
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
MinimizeBtn.TextSize = 14
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -12)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Кнопка восстановления
local RestoreBtn = Instance.new("TextButton", MainFrame)
RestoreBtn.BackgroundTransparency = 1
RestoreBtn.Size = UDim2.new(1, 0, 1, 0)
RestoreBtn.Font = Enum.Font.GothamBold
RestoreBtn.Text = "Project Sky"
RestoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RestoreBtn.TextSize = 13
RestoreBtn.Visible = false
RestoreBtn.ZIndex = 10

local isMinimized = false
local normalSize = UDim2.new(0, 460, 0, 330)
local normalPos = UDim2.new(0.5, -230, 0.5, -165)

local TabContainer = Instance.new("ScrollingFrame", MainFrame)
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 10, 0, 50)
TabContainer.Size = UDim2.new(0, 125, 1, -60)
TabContainer.ScrollBarThickness = 0

local TabListLayout = Instance.new("UIListLayout", TabContainer)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 145, 0, 50)
ContentContainer.Size = UDim2.new(1, -155, 1, -60)

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = true
    TabContainer.Visible = false
    ContentContainer.Visible = false
    Title.Visible = false
    MinimizeBtn.Visible = false
    CloseBtn.Visible = false
    
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 160, 0, 34),
        Position = UDim2.new(0.5, -80, 0, 10)
    }):Play()
    
    task.wait(0.2)
    RestoreBtn.Visible = true
end)

RestoreBtn.MouseButton1Click:Connect(function()
    isMinimized = false
    RestoreBtn.Visible = false
    
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = normalSize,
        Position = normalPos
    }):Play()
    
    task.wait(0.2)
    TabContainer.Visible = true
    ContentContainer.Visible = true
    Title.Visible = true
    MinimizeBtn.Visible = true
    CloseBtn.Visible = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    _G.ProjectSkyMM2Loaded = false
    ScreenGui:Destroy()
end)

-- Перетаскивание UI
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if not isMinimized and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
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
    if not isMinimized and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Tabs = {}
local function createTab(name)
    local tabBtn = Instance.new("TextButton", TabContainer)
    tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    tabBtn.Size = UDim2.new(1, 0, 0, 35)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(150, 150, 165)
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
            t.Button.TextColor3 = Color3.fromRGB(150, 150, 165)
            t.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        end
        tabContent.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundColor3 = Color3.fromRGB(110, 40, 210)
    end)

    if #Tabs == 0 then
        tabContent.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundColor3 = Color3.fromRGB(110, 40, 210)
    end

    table.insert(Tabs, {Button = tabBtn, Content = tabContent})
    return tabContent
end

local function addToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 29)
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.Font = Enum.Font.Gotham
    btn.Text = "  " .. text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(180, 180, 195)
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = "  " .. text .. (state and ": ON" or ": OFF")
        btn.TextColor3 = state and Color3.fromRGB(160, 90, 255) or Color3.fromRGB(180, 180, 195)
        callback(state)
    end)
    return btn
end

local function addButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.BackgroundColor3 = Color3.fromRGB(45, 25, 80)
    btn.Size = UDim2.new(1, -10, 0, 32)
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
addToggle(VisualsTab, "Gun ESP (Подсветка)", function(s) Settings.Visuals.GunESP = s end)
addToggle(VisualsTab, "Gun Drop Alert", function(s) Settings.Visuals.GunAlert = s end)

local bulletSubFrame = Instance.new("Frame", VisualsTab)
bulletSubFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
bulletSubFrame.Size = UDim2.new(1, -10, 0, 65)
bulletSubFrame.Visible = false
Instance.new("UICorner", bulletSubFrame).CornerRadius = UDim.new(0, 6)
local subLayout = Instance.new("UIListLayout", bulletSubFrame)
subLayout.Padding = UDim.new(0, 4)

addToggle(VisualsTab, "Tracer Bullets", function(s)
    Settings.Visuals.BulletTracers = s
    bulletSubFrame.Visible = s
end)

local modeBtn = Instance.new("TextButton", bulletSubFrame)
modeBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
modeBtn.Size = UDim2.new(1, 0, 0, 28)
modeBtn.Font = Enum.Font.Gotham
modeBtn.Text = " Режим: Простой"
modeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
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
colorBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
colorBtn.Size = UDim2.new(1, 0, 0, 28)
colorBtn.Font = Enum.Font.Gotham
colorBtn.Text = " Цвет: Фиолетовый"
colorBtn.TextColor3 = Color3.fromRGB(140, 70, 255)
colorBtn.TextSize = 11
colorBtn.TextXAlignment = Enum.TextXAlignment.Left

local colorsList = {
    {Name = "Фиолетовый", Color = Color3.fromRGB(140, 70, 255)},
    {Name = "Неоновый синий", Color = Color3.fromRGB(0, 170, 255)},
    {Name = "Красный", Color = Color3.fromRGB(255, 50, 50)},
    {Name = "Зеленый", Color = Color3.fromRGB(50, 255, 100)}
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

addToggle(MiscTab, "Anti-Fling", function(s)
    Settings.Misc.AntiFling = s
end)

-- Target Fling
local flingSubFrame = Instance.new("Frame", MiscTab)
flingSubFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
flingSubFrame.Size = UDim2.new(1, -10, 0, 72)
Instance.new("UICorner", flingSubFrame).CornerRadius = UDim.new(0, 6)
local flingLayout = Instance.new("UIListLayout", flingSubFrame)
flingLayout.Padding = UDim.new(0, 4)

local targetSelectBtn = Instance.new("TextButton", flingSubFrame)
targetSelectBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
targetSelectBtn.Size = UDim2.new(1, 0, 0, 30)
targetSelectBtn.Font = Enum.Font.Gotham
targetSelectBtn.Text = " Цель: Выбрать игрока"
targetSelectBtn.TextColor3 = Color3.fromRGB(180, 130, 255)
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
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    
    if not root or not targetRoot then return end

    if flingConnection then flingConnection:Disconnect() end

    local bav = Instance.new("BodyAngularVelocity")
    bav.Name = "FlingForce"
    bav.AngularVelocity = Vector3.new(99999, 99999, 99999)
    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bav.Parent = root

    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlingVel"
    bv.Velocity = Vector3.new(0, 1500, 0)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Parent = root

    local oldCFrame = root.CFrame
    local startTime = tick()

    flingConnection = RunService.Heartbeat:Connect(function()
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and (tick() - startTime < 1.2) then
            root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-2,2), 0, math.random(-2,2))
            root.Velocity = Vector3.new(99999, 99999, 99999)
        else
            if flingConnection then flingConnection:Disconnect() end
            if bav then bav:Destroy() end
            if bv then bv:Destroy() end
            root.CFrame = oldCFrame
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

addButton(flingSubFrame, "🚀 Запустить Fling", executeFling)

-- Fly
local flySubFrame = Instance.new("Frame", MiscTab)
flySubFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
flySubFrame.Size = UDim2.new(1, -10, 0, 32)
flySubFrame.Visible = false
Instance.new("UICorner", flySubFrame).CornerRadius = UDim.new(0, 6)

local flySpeedBtn = Instance.new("TextButton", flySubFrame)
flySpeedBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
flySpeedBtn.Size = UDim2.new(1, 0, 1, 0)
flySpeedBtn.Font = Enum.Font.Gotham
flySpeedBtn.Text = " Скорость флая: 50"
flySpeedBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
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

addToggle(MiscTab, "Noclip", function(s) Settings.Misc.Noclip = s end)

-- SpinBot
local spinSubFrame = Instance.new("Frame", MiscTab)
spinSubFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
spinSubFrame.Size = UDim2.new(1, -10, 0, 32)
spinSubFrame.Visible = false
Instance.new("UICorner", spinSubFrame).CornerRadius = UDim.new(0, 6)

local spinSpeedBtn = Instance.new("TextButton", spinSubFrame)
spinSpeedBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
spinSpeedBtn.Size = UDim2.new(1, 0, 1, 0)
spinSpeedBtn.Font = Enum.Font.Gotham
spinSpeedBtn.Text = " Скорость спина: 50"
spinSpeedBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
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

-- ==================== ВКЛАДКА 3: COMBAT ====================
local CombatTab = createTab("COMBAT")
local combatInfo = Instance.new("TextLabel", CombatTab)
combatInfo.BackgroundTransparency = 1
combatInfo.Size = UDim2.new(1, -10, 0, 50)
combatInfo.Font = Enum.Font.GothamBold
combatInfo.Text = "Скоро..."
combatInfo.TextColor3 = Color3.fromRGB(150, 150, 165)
combatInfo.TextSize = 16
combatInfo.TextXAlignment = Enum.TextXAlignment.Center

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

-- Трейсеры пуль
local function monitorToolForTracers(tool)
    if tool:IsA("Tool") and (tool.Name:lower():find("gun") or tool.Name:lower():find("revolver") or tool.Name:lower():find("пистолет")) then
        tool.Activated:Connect(function()
            if not Settings.Visuals.BulletTracers then return end
            local mouse = LocalPlayer:GetMouse()
            local line = Drawing.new("Line")
            line.Visible = true
            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            line.To = Vector2.new(mouse.X, mouse.Y)
            line.Color = Settings.Visuals.BulletTracerColor
            line.Thickness = (Settings.Visuals.BulletTracerMode == "Neon") and 3 or 1
            
            task.delay(0.2, function()
                line:Remove()
            end)
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(monitorToolForTracers)
end)
if LocalPlayer.Character then
    for _, item in ipairs(LocalPlayer.Character:GetChildren()) do monitorToolForTracers(item) end
end
if LocalPlayer:FindFirstChildOfClass("Backpack") then
    LocalPlayer.Backpack.ChildAdded:Connect(monitorToolForTracers)
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do monitorToolForTracers(item) end
end

-- Подсветка упавшего пистолета и сообщение
local gunHighlight = Instance.new("Highlight")
gunHighlight.Parent = CoreGui
gunHighlight.FillColor = Color3.fromRGB(0, 150, 255)
gunHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
gunHighlight.FillTransparency = 0.3
gunHighlight.Enabled = false

RunService.RenderStepped:Connect(function()
    local foundGun = nil
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("revolver") or obj.Name:lower():find("пистолет")) then
            local isDropped = true
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and obj:IsDescendantOf(player.Character) then isDropped = false end
                if player.Backpack and obj:IsDescendantOf(player.Backpack) then isDropped = false end
            end
            if isDropped then
                foundGun = obj
                break
            end
        end
    end

    if foundGun then
        gunHighlight.Adornee = foundGun
        gunHighlight.Enabled = Settings.Visuals.GunESP
        GunAlertLabel.Visible = Settings.Visuals.GunAlert
    else
        gunHighlight.Enabled = false
        GunAlertLabel.Visible = false
    end
end)

-- Общий цикл (Anti-Fling, Noclip, SpinBot)
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

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

    if Settings.Misc.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if Settings.Misc.Spin and root then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Settings.Misc.SpinSpeed), 0)
    end
end)

print("Project Sky 1.1 успешно загружен!")
