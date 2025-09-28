-- Crear el menú circular
local circleMenu = Instance.new("ScreenGui")
circleMenu.Name = "CircleMenu"
circleMenu.Parent = game:GetService("CoreGui")

local circleFrame = Instance.new("Frame")
circleFrame.Size = UDim2.new(0, 100, 0, 100)
circleFrame.Position = UDim2.new(0.5, -50, 0.5, -50)
circleFrame.BackgroundColor3 = Color3.new(0, 0, 0)
circleFrame.BackgroundTransparency = 0.5
circleFrame.Parent = circleMenu

local circleButton = Instance.new("TextButton")
circleButton.Size = UDim2.new(1, 0, 1, 0)
circleButton.Text = ""
circleButton.BackgroundColor3 = Color3.new(1, 1, 1)
circleButton.BackgroundTransparency = 0.5
circleButton.Parent = circleFrame

-- Crear el menú de opciones
local optionsMenu = Instance.new("Frame")
optionsMenu.Size = UDim2.new(0, 200, 0, 150)
optionsMenu.Position = UDim2.new(0.5, -100, 0.5, -75)
optionsMenu.BackgroundColor3 = Color3.new(0, 0, 0)
optionsMenu.BackgroundTransparency = 0.5
optionsMenu.Visible = false
optionsMenu.Parent = circleMenu

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 30)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.Text = "Speed: 16"
speedLabel.BackgroundColor3 = Color3.new(0, 0, 0)
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Parent = optionsMenu

local speedUpButton = Instance.new("TextButton")
speedUpButton.Size = UDim2.new(0.45, 0, 0, 30)
speedUpButton.Position = UDim2.new(0.05, 0, 0.4, 0)
speedUpButton.Text = "Up"
speedUpButton.BackgroundColor3 = Color3.new(0, 0, 0)
speedUpButton.TextColor3 = Color3.new(1, 1, 1)
speedUpButton.Parent = optionsMenu

local speedDownButton = Instance.new("TextButton")
speedDownButton.Size = UDim2.new(0.45, 0, 0, 30)
speedDownButton.Position = UDim2.new(0.5, 0, 0.4, 0)
speedDownButton.Text = "Down"
speedDownButton.BackgroundColor3 = Color3.new(0, 0, 0)
speedDownButton.TextColor3 = Color3.new(1, 1, 1)
speedDownButton.Parent = optionsMenu

-- Funciones para ajustar la velocidad
local currentSpeed = 16

local function setPlayerSpeed(speed)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = speed
end

speedUpButton.MouseButton1Click:Connect(function()
    currentSpeed = currentSpeed + 1
    speedLabel.Text = "Speed: " .. tostring(currentSpeed)
    setPlayerSpeed(currentSpeed)
end)

speedDownButton.MouseButton1Click:Connect(function()
    currentSpeed = currentSpeed - 1
    speedLabel.Text = "Speed: " .. tostring(currentSpeed)
    setPlayerSpeed(currentSpeed)
end)

-- Funcionalidad del menú circular
circleButton.MouseButton1Click:Connect(function()
    optionsMenu.Visible = not optionsMenu.Visible
end)

-- Hacer que el menú sea arrastrable
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    circleFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

circleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = circleFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

circleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
