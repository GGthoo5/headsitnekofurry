local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")

local sitting = false
local targetModel = nil
local targetHead = nil
local connection = nil

local yOffset = 1.6 
local zOffset = 0.1   
local step = 0.2 

-- Переменные персонажа
local myChar = player.Character or player.CharacterAdded:Wait()
local myRoot = myChar:WaitForChild("HumanoidRootPart")
local myHum = myChar:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(char)
    myChar = char
    myRoot = char:WaitForChild("HumanoidRootPart")
    myHum = char:WaitForChild("Humanoid")
    sitting = false
end)

--===================================================================================
-- ИНТЕРФЕЙС
--===================================================================================
local Theme = {
    Background = Color3.fromRGB(15, 15, 18),
    Accent = Color3.fromRGB(0, 162, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Button = Color3.fromRGB(28, 28, 32),
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Headsit_NoPhysics"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 90, 0, 30)
openButton.Position = UDim2.new(1, -100, 1, -40)
openButton.BackgroundColor3 = Theme.Background
openButton.Text = "Headsit"
openButton.TextColor3 = Theme.Accent
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 13
openButton.Parent = screenGui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", openButton).Color = Theme.Accent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 170, 0, 270)
frame.Position = UDim2.new(1, -180, 1, -320)
frame.BackgroundColor3 = Theme.Background
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = Theme.Accent
frameStroke.Thickness = 1.8

local title = Instance.new("TextLabel")
title.Text = "HEADSIT CTRL"
title.Size = UDim2.new(1, 0, 0, 35)
title.TextColor3 = Theme.Text
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local getToolBtn = Instance.new("TextButton")
getToolBtn.Text = "GET TOOL"
getToolBtn.Size = UDim2.new(1, -20, 0, 25)
getToolBtn.Position = UDim2.new(0, 10, 0, 35)
getToolBtn.BackgroundColor3 = Theme.Accent
getToolBtn.TextColor3 = Theme.Text
getToolBtn.Font = Enum.Font.GothamBold
getToolBtn.TextSize = 11
getToolBtn.Parent = frame
Instance.new("UICorner", getToolBtn).CornerRadius = UDim.new(0, 6)

local stepInput = Instance.new("TextBox")
stepInput.Size = UDim2.new(1, -20, 0, 30)
stepInput.Position = UDim2.new(0, 10, 0, 70)
stepInput.BackgroundColor3 = Theme.Button
stepInput.TextColor3 = Theme.Accent
stepInput.Text = "0.2"
stepInput.Font = Enum.Font.GothamMedium
stepInput.TextSize = 12
stepInput.Parent = frame
Instance.new("UICorner", stepInput).CornerRadius = UDim.new(0, 6)

local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(1, -20, 0, 100)
btnContainer.Position = UDim2.new(0, 10, 0, 120)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = frame

local function createBtn(text, pos)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0, 70, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = Theme.Button
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = btnContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local upBtn = createBtn("+Y", UDim2.new(0, 0, 0, 0))
local downBtn = createBtn("-Y", UDim2.new(0, 80, 0, 0))
local fwdBtn = createBtn("+Z", UDim2.new(0, 0, 0, 50))
local backBtn = createBtn("-Z", UDim2.new(0, 80, 0, 50))

local authorLabel = Instance.new("TextLabel")
authorLabel.Text = "Автор: dogirlx_tikt0k"
authorLabel.Size = UDim2.new(1, 0, 0, 20)
authorLabel.Position = UDim2.new(0, 0, 1, -20)
authorLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
authorLabel.BackgroundTransparency = 1
authorLabel.Font = Enum.Font.Gotham
authorLabel.TextSize = 9
authorLabel.Parent = frame

--===================================================================================
-- ЛОГИКА БЕЗ ФИЗИКИ
--===================================================================================

local function setPhysics(state)
    for _, part in pairs(myChar:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state -- Отключаем коллизию, если state = true
            if state then
                part.Velocity = Vector3.new(0,0,0)
                part.RotVelocity = Vector3.new(0,0,0)
            end
        end
    end
end

local function giveTool()
    local old = player.Backpack:FindFirstChild("Headsit")
    if old then old:Destroy() end
    
    local Tool = Instance.new("Tool")
    Tool.RequiresHandle = false
    Tool.Name = "Headsit"
    Tool.Parent = player.Backpack
    
    Tool.Activated:Connect(function()
        if not sitting then
            local target = mouse.Target
            if target then
                local char = target:FindFirstAncestorOfClass("Model")
                if char and char:FindFirstChild("Humanoid") and char ~= myChar then
                    startSitting(char)
                end
            end
        end
    end)
end

function startSitting(char)
    if sitting then return end
    targetModel = char
    targetHead = char:FindFirstChild("Head")
    
    if targetHead and myRoot and myHum then
        sitting = true
        myHum.Sit = true
        
        connection = RunService.Heartbeat:Connect(function()
            -- Проверка прыжка
            if myHum:GetState() == Enum.HumanoidStateType.Jumping or myHum.Jump then
                sitting = false
                setPhysics(false) -- Возвращаем коллизию
                if connection then connection:Disconnect() end
                return
            end
            
            -- Проверка существования цели
            if not targetModel or not targetModel.Parent or not targetHead or not myRoot or not myChar.Parent then
                sitting = false
                setPhysics(false)
                if connection then connection:Disconnect() end
                return
            end
            
            -- ОТКЛЮЧЕНИЕ ФИЗИКИ КАЖДЫЙ КАДР (чтобы не выбивало)
            setPhysics(true)
            myRoot.CFrame = targetHead.CFrame * CFrame.new(0, yOffset, zOffset)
            myRoot.Velocity = Vector3.zero
            myRoot.RotVelocity = Vector3.zero
        end)
    end
end

-- Кнопки
stepInput.FocusLost:Connect(function() step = tonumber(stepInput.Text) or step end)
upBtn.MouseButton1Click:Connect(function() yOffset = yOffset + step end)
downBtn.MouseButton1Click:Connect(function() yOffset = yOffset - step end)
fwdBtn.MouseButton1Click:Connect(function() zOffset = zOffset - step end)
backBtn.MouseButton1Click:Connect(function() zOffset = zOffset + step end)
openButton.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
getToolBtn.MouseButton1Click:Connect(function() giveTool() end)

giveTool()
