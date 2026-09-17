--[[
    Project Sky - Counter Blox Script
    Modular Base UI & ESP
]]--

if _G.ProjectSkyLoaded then
    warn("Project Sky уже запущен!")
    return
end
_G.ProjectSkyLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Настройки скрипта
local Settings = {
    ESP = {
        Enabled = true,
        Boxes = true,
        Tracers = true,
        FOV = true,
        FOVRadius = 100,
        TeamCheck = true
    }
}

-- Создание UI (Кастомный интерфейс)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProjectSkyUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 200)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Project Sky | Counter Blox"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 16

-- Переключатель ESP в меню
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0.1, 0, 0.3, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Text = "ESP: ON"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Settings.ESP.Enabled = not Settings.ESP.Enabled
    ToggleButton.Text = Settings.ESP.Enabled and "ESP: ON" or "ESP: OFF"
    ToggleButton.TextColor3 = Settings.ESP.Enabled and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 75, 75)
end)

-- Простая логика ESP (отрисовка)
local function createESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(0, 170, 255)
    box.Thickness = 1
    box.Filled = false

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(0, 170, 255)
    tracer.Thickness = 1

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not Settings.ESP.Enabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
            box.Visible = false
            tracer.Visible = false
            return
        end

        if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then
            box.Visible = false
            tracer.Visible = false
            return
        end

        local rootPart = player.Character.HumanoidRootPart
        local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)

        if onScreen then
            box.Size = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
            box.Position = Vector2.new(vector.X - box.Size.X / 2, vector.Y - box.Size.Y / 2)
            box.Visible = Settings.ESP.Boxes

            tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
            tracer.To = Vector2.new(vector.X, vector.Y + box.Size.Y / 2)
            tracer.Visible = Settings.ESP.Tracers
        else
            box.Visible = false
            tracer.Visible = false
        end
    end)

    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            connection:Disconnect()
            box:Remove()
            tracer:Remove()
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        createESP(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        createESP(p)
    end
end)

print("Project Sky успешно инициализирован!")
