--!strict
-- ESP + GUI - mazesamaxkaya

---------------------------
-- SERVICES
---------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

---------------------------
-- CONFIG
---------------------------
local CONFIG = {
    ShowLocalPlayer = false,
    FillTransparency = 0.5,
    OutlineTransparency = 0,
    DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
    Color_Teammate = Color3.fromRGB(0,255,0),
    Color_Enemy = Color3.fromRGB(255,0,0),
    Color_Neutral = Color3.fromRGB(255,255,255)
}

local ESP_ENABLED = false
local connections = {}

---------------------------
-- ESP Functions
---------------------------
local function getColorForPlayer(plr: Player?): Color3
    if not plr or not LocalPlayer.Team or not plr.Team then
        return CONFIG.Color_Neutral
    end
    if LocalPlayer.Team == plr.Team then
        return CONFIG.Color_Teammate
    else
        return CONFIG.Color_Enemy
    end
end

local function addHighlight(plr: Player)
    if not ESP_ENABLED then return end
    if not CONFIG.ShowLocalPlayer and plr == LocalPlayer then return end
    if not plr.Character then return end
    if plr.Character:FindFirstChild("GlowHighlight") then return end

    local hl = Instance.new("Highlight")
    hl.Name = "GlowHighlight"
    hl.Adornee = plr.Character
    hl.FillTransparency = CONFIG.FillTransparency
    hl.OutlineTransparency = CONFIG.OutlineTransparency
    hl.DepthMode = CONFIG.DepthMode
    hl.OutlineColor = getColorForPlayer(plr)
    hl.FillColor = getColorForPlayer(plr)
    hl.Parent = plr.Character
end

local function updateHighlight(plr: Player)
    if not ESP_ENABLED then return end
    local char = plr.Character
    if not char then return end
    local hl = char:FindFirstChild("GlowHighlight")
    if hl then
        local color = getColorForPlayer(plr)
        hl.OutlineColor = color
        hl.FillColor = color
    end
end

local function onPlayerAdded(plr: Player)
    local c1 = plr.CharacterAdded:Connect(function()
        task.wait(0.2)
        addHighlight(plr)
        updateHighlight(plr)
    end)
    local c2 = plr:GetPropertyChangedSignal("Team"):Connect(function()
        updateHighlight(plr)
    end)
    table.insert(connections, c1)
    table.insert(connections, c2)
end

local function enableESP()
    ESP_ENABLED = true
    for _, p in ipairs(Players:GetPlayers()) do
        onPlayerAdded(p)
        if p.Character then
            addHighlight(p)
            updateHighlight(p)
        end
    end
    local c = Players.PlayerAdded:Connect(onPlayerAdded)
    table.insert(connections, c)
end

local function disableESP()
    ESP_ENABLED = false
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("GlowHighlight") then
            p.Character.GlowHighlight:Destroy()
        end
    end
    for _, c in ipairs(connections) do
        c:Disconnect()
    end
    connections = {}
end

---------------------------
-- GUI
---------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Ana Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.4, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- koyu gri
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Üst Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- siyah
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

-- Başlık
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Character Outline ESP"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = TopBar

-- Sürüklenebilirlik
local dragging = false
local dragStart, startPos, dragInput
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Buton
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0.6, 0, 0.35, 0)
Button.Position = UDim2.new(0.2, 0, 0.5, 0)
Button.BackgroundColor3 = Color3.fromRGB(0, 120, 255) -- mavi
Button.TextColor3 = Color3.fromRGB(255,255,255)
Button.Text = "On / Off"
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 16
Button.Parent = MainFrame

-- Toggle
Button.MouseButton1Click:Connect(function()
    if ESP_ENABLED then
        disableESP()
        Button.Text = "Off"
        Button.BackgroundColor3 = Color3.fromRGB(180, 0, 0) -- kırmızı
    else
        enableESP()
        Button.Text = "On"
        Button.BackgroundColor3 = Color3.fromRGB(0, 120, 255) -- mavi
    end
end)
