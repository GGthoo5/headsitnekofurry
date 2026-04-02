--[=[
    HEADSIT MODERN (FINAL VERSION)
    Автор: dogirlx_tikt0k
]=]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local sitting = false
local targetModel = nil
local targetHead = nil
local connection = nil

local yOffset = 1.6 
local zOffset = 0.1   

--===================================================================================
-- ИНТЕРФЕЙС
--===================================================================================
local Theme = {
    Background = Color3.fromRGB(15, 15, 18),
    Accent = Color3.fromRGB(0, 162, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Button = Color3.fromRGB(28, 28, 32),
    CornerRadius = UDim.new(0, 12),
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Headsit_Minimal_Final"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 180) -- Чуть увеличил высоту для подписи
frame.Position = UDim2.new(0.5, -80, 1, 50)
frame.BackgroundColor3 = Theme.Background
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = Theme.CornerRadius
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Theme.Accent
stroke.Thickness = 1.5
stroke.Transparency = 0.7

local title = Instance.new("TextLabel")
title.Text = "CONTROLS"
title.Size = UDim2.new(1, 0, 0, 40)
title.TextColor3 = Theme.Text
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

-- ПОДПИСЬ АВТОРА
local authorLabel = Instance.new("TextLabel")
authorLabel.Text = "Автор: dogirlx_tikt0k"
authorLabel.Size = UDim2.new(1, 0, 0, 20)
authorLabel.Position = UDim2.new(0, 0, 1, -25)
authorLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
authorLabel.BackgroundTransparency = 1
authorLabel.Font = Enum.Font.Gotham
authorLabel.TextSize = 10
authorLabel.Parent = frame

local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(1, -20, 1, -80)
btnContainer.Position = UDim2.new(0, 10, 0, 40)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = frame

local function createBtn(text, pos)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0, 65, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = Theme.Button
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    btn.Parent = btnContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local upBtn = createBtn("+Y", UDim2.new(0, 0, 0, 0))
local downBtn = createBtn("-Y", UDim2.new(0, 75, 0, 0))
local fwdBtn = createBtn("+Z", UDim2.new(0, 0, 0, 55))
local backBtn = createBtn("-Z", UDim2.new(0, 75, 0, 55))

upBtn.MouseButton1Click:Connect(function() yOffset = yOffset + 0.1 end)
downBtn.MouseButton1Click:Connect(function() yOffset = yOffset - 0.1 end)
fwdBtn.MouseButton1Click:Connect(function() zOffset = zOffset - 0.1 end)
backBtn.MouseButton1Click:Connect(function() zOffset = zOffset + 0.1 end)

--===================================================================================
-- ЛОГИКА (БЕЗ ИЗМЕНЕНИЙ)
--===================================================================================
local function toggleUI(show)
    if show then
        frame.Visible = true
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -80, 0.7, 0)}):Play()
    else
        local t = TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -80, 1, 50)})
        t:Play()
        t.Completed:Connect(function() if not sitting then frame.Visible = false end end)
    end
end

local function stopSitting()
    sitting = false
    targetModel = nil
    targetHead = nil
    toggleUI(false)
    if connection then 
        connection:Disconnect() 
        connection = nil
    end
end

local function startSitting(char)
    if sitting then return end
    
    targetModel = char
    targetHead = char:FindFirstChild("Head")
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChild("Humanoid")
    
    if targetHead and myRoot and myHum then
        sitting = true
        toggleUI(true)
        myHum.Sit = true
        
        connection = RunService.Heartbeat:Connect(function()
            if myHum:GetState() == Enum.HumanoidStateType.Jumping or myHum.Jump then
                stopSitting()
                return
            end
            if not targetModel or not targetModel.Parent or not targetHead or not targetHead.Parent then
                stopSitting()
                return
            end
            myRoot.CFrame = targetHead.CFrame * CFrame.new(0, yOffset, zOffset)
            myRoot.Velocity = Vector3.zero
        end)
    end
end

local Tool = Instance.new("Tool")
Tool.RequiresHandle = false
Tool.Name = "Headsit"
Tool.Parent = player.Backpack

Tool.Activated:Connect(function()
    if not sitting then
        local target = mouse.Target
        if target then
            local char = target:FindFirstAncestorOfClass("Model")
            if char and char:FindFirstChild("Humanoid") and char ~= player.Character then
                startSitting(char)
            end
       
end
    end
end)
