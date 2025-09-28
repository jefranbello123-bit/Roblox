-- 🌿 VerdeSpeed Mobile con burbuja flotante
-- 🚀 Script de velocidad infinita SOLO móviles

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local plr = Players.LocalPlayer

-- Configuración
local speedEnabled = false
local walkSpeed = 16

-- Crear GUI
local gui = Instance.new("ScreenGui")
gui.Name = "VerdeSpeedBubble"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

-- 🔵 Botón burbuja flotante
local bubbleBtn = Instance.new("TextButton")
bubbleBtn.Size = UDim2.new(0, 60, 0, 60)
bubbleBtn.Position = UDim2.new(0.85, 0, 0.7, 0)
bubbleBtn.Text = "⚡"
bubbleBtn.TextSize = 28
bubbleBtn.Font = Enum.Font.GothamBold
bubbleBtn.TextColor3 = Color3.new(1,1,1)
bubbleBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
bubbleBtn.Parent = gui

local bubbleCorner = Instance.new("UICorner")
bubbleCorner.CornerRadius = UDim.new(1,0)
bubbleCorner.Parent = bubbleBtn

-- 📂 Menú oculto al inicio
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 170)
mainFrame.Position = UDim2.new(0.6, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0,15)
frameCorner.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,35)
title.Text = "🌿 VerdeSpeed"
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- Botón Speed
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.9,0,0,40)
speedBtn.Position = UDim2.new(0.05,0,0.25,0)
speedBtn.Text = "SPEED: OFF"
speedBtn.TextSize = 18
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextColor3 = Color3.new(1,1,1)
speedBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
speedBtn.Parent = mainFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0,10)
speedCorner.Parent = speedBtn

-- Label Velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9,0,0,25)
speedLabel.Position = UDim2.new(0.05,0,0.55,0)
speedLabel.Text = "Velocidad: "..walkSpeed
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 0.3
speedLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
speedLabel.Parent = mainFrame

local labelCorner = Instance.new("UICorner")
labelCorner.CornerRadius = UDim.new(0,10)
labelCorner.Parent = speedLabel

-- Botones Velocidad
local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Size = UDim2.new(0.42,0,0,30)
speedUpBtn.Position = UDim2.new(0.05,0,0.82,0)
speedUpBtn.Text = "➕"
speedUpBtn.TextSize = 22
speedUpBtn.Font = Enum.Font.GothamBold
speedUpBtn.TextColor3 = Color3.new(1,1,1)
speedUpBtn.BackgroundColor3 = Color3.fromRGB(60,200,60)
speedUpBtn.Parent = mainFrame

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0,10)
upCorner.Parent = speedUpBtn

local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Size = UDim2.new(0.42,0,0,30)
speedDownBtn.Position = UDim2.new(0.53,0,0.82,0)
speedDownBtn.Text = "➖"
speedDownBtn.TextSize = 22
speedDownBtn.Font = Enum.Font.GothamBold
speedDownBtn.TextColor3 = Color3.new(1,1,1)
speedDownBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
speedDownBtn.Parent = mainFrame

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0,10)
downCorner.Parent = speedDownBtn

-- Funciones
local function toggleSpeed()
    local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
    if not humanoid then return end

    speedEnabled = not speedEnabled
    if speedEnabled then
        speedBtn.Text = "SPEED: ON"
        speedBtn.BackgroundColor3 = Color3.fromRGB(60,200,60)
        humanoid.WalkSpeed = walkSpeed
    else
        speedBtn.Text = "SPEED: OFF"
        speedBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
        humanoid.WalkSpeed = 16
    end
end

-- Eventos Speed
speedBtn.MouseButton1Click:Connect(toggleSpeed)

speedUpBtn.MouseButton1Click:Connect(function()
    walkSpeed = walkSpeed + 10
    if speedEnabled and plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.WalkSpeed = walkSpeed
    end
    speedLabel.Text = "Velocidad: "..walkSpeed
end)

speedDownBtn.MouseButton1Click:Connect(function()
    walkSpeed = math.max(walkSpeed - 10, 1)
    if speedEnabled and plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.WalkSpeed = walkSpeed
    end
    speedLabel.Text = "Velocidad: "..walkSpeed
end)

-- Reset personaje
plr.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = speedEnabled and walkSpeed or 16
end)

-- 📂 Abrir/cerrar menú desde la burbuja
bubbleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- 🔄 Hacer la burbuja arrastrable
local dragging = false
local dragInput, dragStart, startPos

bubbleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = bubbleBtn.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

bubbleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        bubbleBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

print("🌿 VerdeSpeed con burbuja flotante cargado 🚀")
