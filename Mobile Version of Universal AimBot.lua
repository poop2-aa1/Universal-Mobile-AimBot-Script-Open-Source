-- Secret Service Protection (FIXED: NO ESP THROUGH WALLS)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Protection Configuration
local ProtectionSettings = {
    Enabled = false,
    FOV = 20,
    Smoothness = 0.15,
    HardAim = false,
    TargetPart = "Head",
    WallCheck = true,
    ShowFOV = true,
    ShowHealthBars = false,
}

local GuiOpen = false
local HealthBarStorage = {}

----------------------------------------------------------------
-- UI CONSTRUCTION
----------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SecretServiceUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 
ScreenGui.Parent = PlayerGui

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.AnchorPoint = Vector2.new(1, 1)
OpenButton.Size = UDim2.new(0, 140, 0, 50)
OpenButton.Position = UDim2.new(1, -20, 1, -20)
OpenButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Text = "Open Menu"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 14
OpenButton.ZIndex = 10
OpenButton.Parent = ScreenGui
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 8)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Secret Service Protection"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainFrame
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -60)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 2
Scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.Parent = Scroll

----------------------------------------------------------------
-- UI HELPERS
----------------------------------------------------------------

local function CreateToggle(name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.Parent = Scroll
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 40, 0, 20)
    Btn.Position = UDim2.new(1, -45, 0.5, -10)
    Btn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 60)
    Btn.Text = ""
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    Btn.Activated:Connect(function()
        local newState = Btn.BackgroundColor3 == Color3.fromRGB(60, 60, 60)
        Btn.BackgroundColor3 = newState and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 60)
        callback(newState)
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.Parent = Scroll
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local SliderBack = Instance.new("Frame")
    SliderBack.Size = UDim2.new(1, -20, 0, 4)
    SliderBack.Position = UDim2.new(0, 10, 0.7, 0)
    SliderBack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBack.Parent = Frame

    local SliderMain = Instance.new("Frame")
    SliderMain.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    SliderMain.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SliderMain.BorderSizePixel = 0
    SliderMain.Parent = SliderBack

    local dragging = false
    local function update()
        local inputPos = UserInputService:GetMouseLocation().X
        local sliderPos = SliderBack.AbsolutePosition.X
        local sliderWidth = SliderBack.AbsoluteSize.X
        local pos = math.clamp((inputPos - sliderPos) / sliderWidth, 0, 1)
        SliderMain.Size = UDim2.new(pos, 0, 1, 0)
        local value = min + (max - min) * pos
        if max > 1 then value = math.floor(value) else value = math.floor(value * 100) / 100 end
        Label.Text = name .. ": " .. value
        callback(value)
    end

    SliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update() end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update() end
    end)
end

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -10, 0, 30)
InfoLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
InfoLabel.Text = "Target: None"
InfoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
InfoLabel.Parent = Scroll
Instance.new("UICorner", InfoLabel)

----------------------------------------------------------------
-- CORE UTILITIES
----------------------------------------------------------------

local function isVisible(part)
    local char = LocalPlayer.Character
    if not char then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, part.Parent}
    local result = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    return result == nil
end

local function CreateHealthBar(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Bar_" .. player.Name
    billboard.Size = UDim2.new(4, 0, 0.5, 0)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    
    local background = Instance.new("Frame", billboard)
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0,0,0)
    background.BorderSizePixel = 0
    Instance.new("UICorner", background)

    local fill = Instance.new("Frame", background)
    fill.Name = "Fill"
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill)

    billboard.Parent = ScreenGui
    return billboard
end

----------------------------------------------------------------
-- INITIALIZE UI CONTROLS
----------------------------------------------------------------

CreateToggle("Enable Protection", true, function(v) ProtectionSettings.Enabled = v end)
CreateSlider("FOV Radius", 0, 600, 20, function(v) ProtectionSettings.FOV = v end)
CreateSlider("Smoothness", 0, 1, 0.15, function(v) ProtectionSettings.Smoothness = v end)
CreateToggle("Hard Aim", false, function(v) ProtectionSettings.HardAim = v end)
CreateToggle("Wall Check", true, function(v) ProtectionSettings.WallCheck = v end)
CreateToggle("Show FOV Circle", true, function(v) ProtectionSettings.ShowFOV = v end)
CreateToggle("Show Health Bars", true, function(v) ProtectionSettings.ShowHealthBars = v end)

local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = ScreenGui
local Stroke = Instance.new("UIStroke", FOVCircle)
Stroke.Color = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)

OpenButton.Activated:Connect(function()
    GuiOpen = not GuiOpen
    MainFrame.Visible = GuiOpen
    OpenButton.Text = GuiOpen and "Close Menu" or "Open Menu"
end)

CloseButton.Activated:Connect(function()
    GuiOpen = false
    MainFrame.Visible = false
    OpenButton.Text = "Open Menu"
end)

----------------------------------------------------------------
-- MAIN LOOP
----------------------------------------------------------------

RunService.RenderStepped:Connect(function()
    local mouseLoc = UserInputService:GetMouseLocation()
    
    -- 1. FOV Circle Update
    if ProtectionSettings.Enabled and ProtectionSettings.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Position = UDim2.new(0, mouseLoc.X, 0, mouseLoc.Y)
        FOVCircle.Size = UDim2.new(0, ProtectionSettings.FOV * 2, 0, ProtectionSettings.FOV * 2)
    else
        FOVCircle.Visible = false
    end

    -- 2. Aimbot Logic
    local target = nil
    if ProtectionSettings.Enabled then
        local maxDist = ProtectionSettings.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local part = p.Character:FindFirstChild(ProtectionSettings.TargetPart)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                        if dist <= maxDist and isVisible(part) then
                            maxDist = dist
                            target = p
                        end
                    end
                end
            end
        end

        if target and target.Character then
            local aimPart = target.Character[ProtectionSettings.TargetPart]
            local targetCF = CFrame.new(Camera.CFrame.Position, aimPart.Position)
            if ProtectionSettings.HardAim then
                Camera.CFrame = targetCF
            else
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, ProtectionSettings.Smoothness)
            end
            InfoLabel.Text = "Target: " .. target.Name
        else
            InfoLabel.Text = "Target: None"
        end
    end

    -- 3. Health Bars (With Wall Check)
    for _, player in pairs(Players:GetPlayers()) do
        pcall(function()
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
                local bar = HealthBarStorage[player.Name]
                if not bar then
                    bar = CreateHealthBar(player)
                    HealthBarStorage[player.Name] = bar
                end
                
                local hum = player.Character.Humanoid
                local head = player.Character.Head
                
                -- Check if setting is on, player is alive, and NOT behind a wall
                if ProtectionSettings.ShowHealthBars and hum.Health > 0 and isVisible(head) then
                    bar.Enabled = true
                    bar.Adornee = head
                    local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    bar.Frame.Fill.Size = UDim2.new(hp, 0, 1, 0)
                    bar.Frame.Fill.BackgroundColor3 = Color3.fromHSV(hp * 0.3, 1, 1)
                else
                    bar.Enabled = false
                end
            elseif HealthBarStorage[player.Name] then
                HealthBarStorage[player.Name]:Destroy()
                HealthBarStorage[player.Name] = nil
            end
        end)
    end
end)

-- Cleanup on leave
Players.PlayerRemoving:Connect(function(player)
    if HealthBarStorage[player.Name] then
        HealthBarStorage[player.Name]:Destroy()
        HealthBarStorage[player.Name] = nil
    end
end)