local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")

local sitting = false
local targetModel = nil
local targetHead = nil
local connection = nil

-- Параметры позиции
local xOffset = 0
local yOffset = 1.6 
local zOffset = 0.1   
local rOffset = 0 -- Вращение в градусах
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
screenGui.Name = "Headsit_FullControl"
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
frame.Size = UDim2.new(0, 200, 0, 350) -- Увеличено для новых кнопок
frame.Position = UDim2.new(1, -210, 1, -400)
frame.BackgroundColor3 = Theme.Background
frame.Active = true
frame.Draggable = true
frame.Visible = false
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = Theme.Accent
frameStroke.Thickness = 1.8

local title = Instance.new("TextLabel")
title.Text = "HEADSIT ADVANCED"
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
stepInput.Position = UDim2.new(0, 10, 0, 65)
stepInput.BackgroundColor3 = Theme.Button
stepInput.TextColor3 = Theme.Accent
stepInput.Text = "0.2"
stepInput.Font = Enum.Font.GothamMedium
stepInput.TextSize = 12
stepInput.Parent = frame
Instance.new("UICorner", stepInput).CornerRadius = UDim.new(0, 6)

-- СЕТКА КНОПОК
local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(1, -20, 0, 200)
btnContainer.Position = UDim2.new(0, 10, 0, 105)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = frame

local function createBtn(text, pos)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0, 85, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Theme.Button
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = btnContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- Кнопки управления
local upBtn = createBtn("+Y (Height)", UDim2.new(0, 0, 0, 0))
local downBtn = createBtn("-Y (Height)", UDim2.new(0, 95, 0, 0))

local fwdBtn = createBtn("+Z (Forward)", UDim2.new(0, 0, 0, 45))
local backBtn = createBtn("-Z (Back)", UDim2.new(0, 95, 0, 45))

local leftBtn = createBtn("+X (Right)", UDim2.new(0, 0, 0, 90))
local rightBtn = createBtn("-X (Left)", UDim2.new(0, 95, 0, 90))

local rotLBtn = createBtn("+Deg (Rot)", UDim2.new(0, 0, 0, 135))
local rotRBtn = createBtn("-Deg (Rot)", UDim2.new(0, 95, 0, 135))

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
-- ЛОГИКА
--===================================================================================

local function setPhysics(state)
    for _, part in pairs(myChar:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
            if state then
                part.Velocity = Vector3.zero
                part.RotVelocity = Vector3.zero
            end
        end
    end
end

function startSitting(char)
    if sitting then return end
    targetModel = char
    targetHead = char:FindFirstChild("Head")
    if targetHead and myRoot and myHum then
        sitting = true
        myHum.Sit = true
        connection = RunService.Heartbeat:Connect(function()
            if myHum:GetState() == Enum.HumanoidStateType.Jumping or myHum.Jump then
                sitting = false
                setPhysics(false)
                if connection then connection:Disconnect() end
                return
            end
            if not targetModel or not targetModel.Parent or not targetHead or not myRoot or not myChar.Parent then
                sitting = false
                setPhysics(false)
                if connection then connection:Disconnect() end
                return
            end
            setPhysics(true)
            -- Применяем позицию и вращение
            local rotationCF = CFrame.Angles(0, math.deg(rOffset), 0)
            myRoot.CFrame = targetHead.CFrame * CFrame.new(xOffset, yOffset, zOffset) * rotationCF
            myRoot.Velocity = Vector3.zero
        end)
    end
end

-- Ивенты кнопок
stepInput.FocusLost:Connect(function() step = tonumber(stepInput.Text) or step end)

upBtn.MouseButton1Click:Connect(function() yOffset = yOffset + step end)
downBtn.MouseButton1Click:Connect(function() yOffset = yOffset - step end)
fwdBtn.MouseButton1Click:Connect(function() zOffset = zOffset - step end)
backBtn.MouseButton1Click:Connect(function() zOffset = zOffset + step end)
leftBtn.MouseButton1Click:Connect(function() xOffset = xOffset + step end)
rightBtn.MouseButton1Click:Connect(function() xOffset = xOffset - step end)
rotLBtn.MouseButton1Click:Connect(function() rOffset = rOffset + step end)
rotRBtn.MouseButton1Click:Connect(function() rOffset = rOffset - step end)

openButton.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
getToolBtn.MouseButton1Click:Connect(function() 
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
end)
