--[[
    Project Sky 1.2 - Murder Mystery 2 (GunDrop, Logs & Bhop Fix)
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

-- ==================== НАСТРОЙКИ ЯЗЫКА И ТЕМ ====================
local CurrentLang = "RU"
local CurrentTheme = "Purple"

local Themes = {
    Purple = {Primary = Color3.fromRGB(14, 14, 18), Accent = Color3.fromRGB(110, 40, 210), Stroke = Color3.fromRGB(60, 30, 95)},
    Blue = {Primary = Color3.fromRGB(12, 16, 22), Accent = Color3.fromRGB(0, 120, 255), Stroke = Color3.fromRGB(20, 60, 120)},
    Red = {Primary = Color3.fromRGB(20, 12, 12), Accent = Color3.fromRGB(220, 40, 40), Stroke = Color3.fromRGB(100, 25, 25)},
    Green = {Primary = Color3.fromRGB(12, 20, 14), Accent = Color3.fromRGB(40, 200, 100), Stroke = Color3.fromRGB(25, 90, 45)}
}

local Dict = {
    RU = {
        Title = "PROJECT SKY <font color='#8c46ff'>| MM2 Расширенный 1.2</font>",
        Tabs = {"ВИЗУАЛЫ", "БОЙ", "РАЗНОЕ", "НАСТРОЙКИ"},
        GunAlert = "⚠️ Пистолет (GunDrop) упал на карте!",
        Highlight = "Подсветка ESP",
        Boxes = "Коробки (Boxes)",
        Tracers = "Линии (Tracers)",
        GunESP = "ESP Пистолета",
        GunAlertToggle = "Уведомление о пистолете",
        LogsToggle = "Показать Логи (Роли)",
        TracerBullets = "Трейсеры пуль",
        ModeSimple = " Режим: Простой",
        ModeNeon = " Режим: Неоновый",
        SilentAim = "Silent Aim",
        AimRadius = " Радиус Aim: ",
        AntiFling = "Анти-Флинг",
        TargetSelect = " Цель: Выбрать игрока",
        NoPlayers = " Цель: Нет игроков",
        LaunchFling = "🚀 Запустить Fling",
        Fly = "Fly (Полёт)",
        FlySpeed = " Скорость флая: ",
        Noclip = "Noclip",
        SpinBot = "SpinBot (Крутилка)",
        SpinSpeed = " Скорость спина: ",
        Bhop = "Bunny Hop (При прыжке)",
        BhopSpeed = " Ускорение в прыжке: ",
        LangBtn = " Язык / Language: RU",
        ThemeNames = {"Фиолетовая", "Синяя", "Красная", "Зеленая"},
        MurdText = "🔪 Мардер: ",
        SheriffText = "🔫 Шериф: ",
        UnknownText = "Неизвестно"
    },
    EN = {
        Title = "PROJECT SKY <font color='#8c46ff'>| MM2 Advanced 1.2</font>",
        Tabs = {"VISUALS", "COMBAT", "MISC", "OPTIONS"},
        GunAlert = "⚠️ GunDrop spotted on the map!",
        Highlight = "Highlight ESP",
        Boxes = "Boxes ESP",
        Tracers = "Tracers",
        GunESP = "Gun ESP",
        GunAlertToggle = "Gun Drop Alert",
        LogsToggle = "Show Logs (Roles)",
        TracerBullets = "Tracer Bullets",
        ModeSimple = " Mode: Simple",
        ModeNeon = " Mode: Neon",
        SilentAim = "Silent Aim",
        AimRadius = " Aim Radius: ",
        AntiFling = "Anti-Fling",
        TargetSelect = " Target: Select Player",
        NoPlayers = " Target: No Players",
        LaunchFling = "🚀 Launch Fling",
        Fly = "Fly",
        FlySpeed = " Fly Speed: ",
        Noclip = "Noclip",
        SpinBot = "SpinBot",
        SpinSpeed = " Spin Speed: ",
        Bhop = "Bunny Hop (Jump Boost)",
        BhopSpeed = " Jump Speed: ",
        LangBtn = " Language / Язык: EN",
        ThemeNames = {"Purple", "Blue", "Red", "Green"},
        MurdText = "🔪 Murderer: ",
        SheriffText = "🔫 Sheriff: ",
        UnknownText = "Unknown"
    }
}

-- Глобальный ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProjectSkyMM2"
ScreenGui.Parent = CoreGui

local Settings = {
    Visuals = {Highlight = false, Boxes = false, Tracers = false, BulletTracers = false, BulletTracerMode = "Simple", BulletTracerColor = Color3.fromRGB(140, 70, 255), GunAlert = false, GunESP = false, ShowLogs = true},
    Combat = {SilentAim = false, SilentRadius = 100, Bhop = false, BhopSpeed = 50},
    Misc = {AntiFling = false, SelectedTarget = nil, Fly = false, FlySpeed = 50, Noclip = false, Spin = false, SpinSpeed = 50}
}

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
    if hasKnife then return "Murderer", Colors.Murderer
    elseif hasGun then return "Sheriff", Colors.Sheriff
    else return "Innocent", Colors.Innocent end
end

-- ==================== ИНТЕРФЕЙС ЛОГОВ (ROLE LOGS) ====================
local LogsFrame = Instance.new("Frame", ScreenGui)
LogsFrame.Name = "LogsFrame"
LogsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
LogsFrame.Size = UDim2.new(0, 200, 0, 70)
LogsFrame.Position = UDim2.new(0, 20, 0.5, -35)
LogsFrame.Visible = Settings.Visuals.ShowLogs
Instance.new("UICorner", LogsFrame).CornerRadius = UDim.new(0, 8)
local logsStroke = Instance.new("UIStroke", LogsFrame)
logsStroke.Color = Themes[CurrentTheme].Accent
logsStroke.Thickness = 1.5

local MurdLabel = Instance.new("TextLabel", LogsFrame)
MurdLabel.BackgroundTransparency = 1
MurdLabel.Size = UDim2.new(1, -20, 0, 30)
MurdLabel.Position = UDim2.new(0, 10, 0, 5)
MurdLabel.Font = Enum.Font.GothamBold
MurdLabel.TextColor3 = Colors.Murderer
MurdLabel.TextSize = 13
MurdLabel.TextXAlignment = Enum.TextXAlignment.Left

local SheriffLabel = Instance.new("TextLabel", LogsFrame)
SheriffLabel.BackgroundTransparency = 1
SheriffLabel.Size = UDim2.new(1, -20, 0, 30)
SheriffLabel.Position = UDim2.new(0, 10, 0, 35)
SheriffLabel.Font = Enum.Font.GothamBold
SheriffLabel.TextColor3 = Colors.Sheriff
SheriffLabel.TextSize = 13
SheriffLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Перетаскивание логов
local logDragging, logDragStart, logStartPos
LogsFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        logDragging = true; logDragStart = input.Position; logStartPos = LogsFrame.Position
    end
end)
LogsFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then logDragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and logDragging then
        local delta = input.Position - logDragStart
        LogsFrame.Position = UDim2.new(logStartPos.X.Scale, logStartPos.X.Offset + delta.X, logStartPos.Y.Scale, logStartPos.Y.Offset + delta.Y)
    end
end)

-- ==================== ОСНОВНОЙ ГУИ ====================
local GunAlertLabel = Instance.new("TextLabel", ScreenGui)
GunAlertLabel.AnchorPoint = Vector2.new(0.5, 1)
GunAlertLabel.Position = UDim2.new(0.5, 0, 1, -25)
GunAlertLabel.Size = UDim2.new(0, 350, 0, 36)
GunAlertLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
GunAlertLabel.Font = Enum.Font.GothamBold
GunAlertLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
GunAlertLabel.TextSize = 14
GunAlertLabel.Visible = false
Instance.new("UICorner", GunAlertLabel).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", GunAlertLabel).Color = Color3.fromRGB(255, 200, 50)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Themes[CurrentTheme].Primary
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -165)
MainFrame.Size = UDim2.new(0, 460, 0, 330)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Themes[CurrentTheme].Stroke
MainStroke.Thickness = 1.5

-- Шапка
local TopBar = Instance.new("Frame", MainFrame)
TopBar.BackgroundTransparency = 1
TopBar.Size = UDim2.new(1, 0, 0, 40)

local Title = Instance.new("TextLabel", TopBar)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -12)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    _G.ProjectSkyMM2Loaded = false
    ScreenGui:Destroy()
end)

local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local TabContainer = Instance.new("ScrollingFrame", MainFrame)
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 10, 0, 50)
TabContainer.Size = UDim2.new(0, 135, 1, -60)
TabContainer.ScrollBarThickness = 0
local TabListLayout = Instance.new("UIListLayout", TabContainer)
TabListLayout.Padding = UDim.new(0, 6)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 155, 0, 50)
ContentContainer.Size = UDim2.new(1, -165, 1, -60)

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
    contentLayout.Padding = UDim.new(0, 8)

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Content.Visible = false
            t.Button.TextColor3 = Color3.fromRGB(150, 150, 165)
            t.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        end
        tabContent.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundColor3 = Themes[CurrentTheme].Accent
    end)

    if #Tabs == 0 then
        tabContent.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundColor3 = Themes[CurrentTheme].Accent
    end

    table.insert(Tabs, {Button = tabBtn, Content = tabContent, DefaultName = name})
    return tabContent
end

local function addToggle(parent, text, defaultState, callback)
    local btn = Instance.new("TextButton", parent)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 29)
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.Font = Enum.Font.Gotham
    btn.Text = "  " .. text .. (defaultState and ": ON" or ": OFF")
    btn.TextColor3 = defaultState and Themes[CurrentTheme].Accent or Color3.fromRGB(180, 180, 195)
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = "  " .. text .. (state and ": ON" or ": OFF")
        btn.TextColor3 = state and Themes[CurrentTheme].Accent or Color3.fromRGB(180, 180, 195)
        callback(state)
    end)
    return btn
end

-- ==================== НАПОЛНЕНИЕ МЕНЮ ====================
local VisualsTab = createTab(Dict[CurrentLang].Tabs[1])
local CombatTab = createTab(Dict[CurrentLang].Tabs[2])
local MiscTab = createTab(Dict[CurrentLang].Tabs[3])
local OptionsTab = createTab(Dict[CurrentLang].Tabs[4])

-- ВИЗУАЛЫ
addToggle(VisualsTab, Dict[CurrentLang].Highlight, false, function(s) Settings.Visuals.Highlight = s end)
addToggle(VisualsTab, Dict[CurrentLang].Boxes, false, function(s) Settings.Visuals.Boxes = s end)
addToggle(VisualsTab, Dict[CurrentLang].Tracers, false, function(s) Settings.Visuals.Tracers = s end)
addToggle(VisualsTab, Dict[CurrentLang].GunESP, false, function(s) Settings.Visuals.GunESP = s end)
addToggle(VisualsTab, Dict[CurrentLang].GunAlertToggle, false, function(s) Settings.Visuals.GunAlert = s end)
addToggle(VisualsTab, Dict[CurrentLang].LogsToggle, true, function(s) 
    Settings.Visuals.ShowLogs = s
    LogsFrame.Visible = s
end)

-- БОЙ (Combat)
addToggle(CombatTab, Dict[CurrentLang].SilentAim, false, function(s) Settings.Combat.SilentAim = s end)

local bhopSubFrame = Instance.new("Frame", CombatTab)
bhopSubFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
bhopSubFrame.Size = UDim2.new(1, -10, 0, 32)
bhopSubFrame.Visible = false
Instance.new("UICorner", bhopSubFrame).CornerRadius = UDim.new(0, 6)

local bhopSpeedBtn = Instance.new("TextButton", bhopSubFrame)
bhopSpeedBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
bhopSpeedBtn.Size = UDim2.new(1, 0, 1, 0)
bhopSpeedBtn.Font = Enum.Font.Gotham
bhopSpeedBtn.Text = Dict[CurrentLang].BhopSpeed .. "50"
bhopSpeedBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
bhopSpeedBtn.TextSize = 11
bhopSpeedBtn.TextXAlignment = Enum.TextXAlignment.Left

local bhopSpeeds = {30, 50, 75, 100}
local bhopSpeedIdx = 2
bhopSpeedBtn.MouseButton1Click:Connect(function()
    bhopSpeedIdx = (bhopSpeedIdx % #bhopSpeeds) + 1
    Settings.Combat.BhopSpeed = bhopSpeeds[bhopSpeedIdx]
    bhopSpeedBtn.Text = Dict[CurrentLang].BhopSpeed .. Settings.Combat.BhopSpeed
end)

addToggle(CombatTab, Dict[CurrentLang].Bhop, false, function(s)
    Settings.Combat.Bhop = s
    bhopSubFrame.Visible = s
end)

-- РАЗНОЕ (Misc)
addToggle(MiscTab, Dict[CurrentLang].AntiFling, false, function(s) Settings.Misc.AntiFling = s end)
addToggle(MiscTab, Dict[CurrentLang].Noclip, false, function(s) Settings.Misc.Noclip = s end)

-- НАСТРОЙКИ (Options)
local langBtn = Instance.new("TextButton", OptionsTab)
langBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 29)
langBtn.Size = UDim2.new(1, -10, 0, 34)
langBtn.Font = Enum.Font.Gotham
langBtn.Text = Dict[CurrentLang].LangBtn
langBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
langBtn.TextSize = 12
langBtn.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 6)

langBtn.MouseButton1Click:Connect(function()
    CurrentLang = (CurrentLang == "RU") and "EN" or "RU"
    Title.Text = Dict[CurrentLang].Title
    langBtn.Text = Dict[CurrentLang].LangBtn
    for i, t in ipairs(Tabs) do t.Button.Text = Dict[CurrentLang].Tabs[i] end
end)

local themeBtn = Instance.new("TextButton", OptionsTab)
themeBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 29)
themeBtn.Size = UDim2.new(1, -10, 0, 34)
themeBtn.Font = Enum.Font.Gotham
themeBtn.Text = " Тема меню: Фиолетовая"
themeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
themeBtn.TextSize = 12
themeBtn.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", themeBtn).CornerRadius = UDim.new(0, 6)

local themeIdx = 1
themeBtn.MouseButton1Click:Connect(function()
    themeIdx = (themeIdx % #Dict["RU"].ThemeNames) + 1
    CurrentTheme = Dict["EN"].ThemeNames[themeIdx]
    themeBtn.Text = " Тема меню: " .. Dict[CurrentLang].ThemeNames[themeIdx]
    MainFrame.BackgroundColor3 = Themes[CurrentTheme].Primary
    MainStroke.Color = Themes[CurrentTheme].Stroke
    logsStroke.Color = Themes[CurrentTheme].Accent
    for _, t in ipairs(Tabs) do
        if t.Content.Visible then t.Button.BackgroundColor3 = Themes[CurrentTheme].Accent end
    end
end)

-- Инициализация текстов
Title.Text = Dict[CurrentLang].Title

-- ==================== ЛОГИКА ====================

-- Обновление Логов и Поиск упавшего GunDrop
local gunHighlight = Instance.new("Highlight", CoreGui)
gunHighlight.FillColor = Color3.fromRGB(0, 200, 255)
gunHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
gunHighlight.FillTransparency = 0.3
gunHighlight.Enabled = false

RunService.RenderStepped:Connect(function()
    -- ЛОГИ РОЛЕЙ
    local murdName, sherName = Dict[CurrentLang].UnknownText, Dict[CurrentLang].UnknownText
    for _, p in ipairs(Players:GetPlayers()) do
        local role = getPlayerRole(p)
        if role == "Murderer" then murdName = p.Name end
        if role == "Sheriff" then sherName = p.Name end
    end
    MurdLabel.Text = Dict[CurrentLang].MurdText .. murdName
    SheriffLabel.Text = Dict[CurrentLang].SheriffText .. sherName

    -- ИСКАТЬ УПАВШИЙ ПИСТОЛЕТ (В MM2 ЭТО МОДЕЛЬ/ДЕТАЛЬ "GunDrop" в Workspace)
    local foundGun = Workspace:FindFirstChild("GunDrop")
    
    GunAlertLabel.Text = Dict[CurrentLang].GunAlert
    if foundGun then
        gunHighlight.Adornee = foundGun
        gunHighlight.Enabled = Settings.Visuals.GunESP
        GunAlertLabel.Visible = Settings.Visuals.GunAlert
    else
        gunHighlight.Enabled = false
        GunAlertLabel.Visible = false
    end
end)

-- Игроки ESP
local function setupPlayerESP(player)
    if player == LocalPlayer then return end
    local highlight = Instance.new("Highlight", CoreGui)
    highlight.FillTransparency = 0.5
    highlight.Enabled = false

    RunService.RenderStepped:Connect(function()
        local char = player.Character
        if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
            highlight.Enabled = false
            return
        end
        local role, roleColor = getPlayerRole(player)
        highlight.FillColor = roleColor
        highlight.OutlineColor = roleColor
        highlight.Adornee = char
        highlight.Enabled = Settings.Visuals.Highlight
    end)
end
for _, p in ipairs(Players:GetPlayers()) do setupPlayerESP(p) end
Players.PlayerAdded:Connect(setupPlayerESP)

-- Физика: Анти-Флинг, Noclip, ИСПРАВЛЕННЫЙ БХОП
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    -- Анти-флинг
    if Settings.Misc.AntiFling then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if pRoot and (pRoot.AssemblyLinearVelocity.Magnitude > 500) then
                    pRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end

    -- Noclip
    if Settings.Misc.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- НОВЫЙ БХОП: Ускоряет ТОЛЬКО когда вы сами прыгнули (находитесь в воздухе)
    if Settings.Combat.Bhop and hum and root then
        if hum.FloorMaterial == Enum.Material.Air then
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                -- Увеличиваем скорость только по X и Z, оставляя Y (гравитацию) нетронутой
                root.Velocity = Vector3.new(moveDir.X * Settings.Combat.BhopSpeed, root.Velocity.Y, moveDir.Z * Settings.Combat.BhopSpeed)
            end
        end
    end
end)

print("Project Sky 1.2: Logs, GunDrop & Bhop Fixes Applied!")
