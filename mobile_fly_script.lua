-- 🚀 VELOCIDAD BOOM - Script Completo y Funcional
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local speedEnabled = false
local currentSpeed = 100

-- Crear la interfaz completa
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BoomSpeedMenu"
screenGui.Parent = CoreGui

-- Botón principal que se expande
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 70, 0, 70)
mainButton.Position = UDim2.new(0.5, -35, 0.1, 0)
mainButton.Text = "⚡"
mainButton.TextSize = 30
mainButton.Font = Enum.Font.GothamBold
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
mainButton.BorderSizePixel = 0
mainButton.ZIndex = 2
mainButton.Parent = screenGui

-- Hacerlo redondo
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(1, 0)
mainCorner.Parent = mainButton

-- Marco del menú (inicialmente oculto)
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 200, 0, 150)
menuFrame.Position = UDim2.new(0.5, -100, 0.1, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.ZIndex = 1
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 15)
menuCorner.Parent = menuFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "🚀 BOOM SPEED"
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.BorderSizePixel = 0
title.Parent = menuFrame

-- Botón ON/OFF
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 40)
toggleButton.Position = UDim2.new(0.05, 0, 0.25, 0)
toggleButton.Text = "VELOCIDAD: OFF"
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
toggleButton.BorderSizePixel = 0
toggleButton.Parent = menuFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Indicador de velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 25)
speedLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
speedLabel.Text = "VELOCIDAD: " .. currentSpeed
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedLabel.BorderSizePixel = 0
speedLabel.Parent = menuFrame

local labelCorner = Instance.new("UICorner")
labelCorner.CornerRadius = UDim.new(0, 8)
labelCorner.Parent = speedLabel

-- Botones de control
local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0.4, 0, 0, 30)
upButton.Position = UDim2.new(0.05, 0, 0.8, 0)
upButton.Text = "➕ +50"
upButton.TextSize = 14
upButton.Font = Enum.Font.GothamBold
upButton.TextColor3 = Color3.new(1, 1, 1)
upButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
upButton.BorderSizePixel = 0
upButton.Parent = menuFrame

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 8)
upCorner.Parent = upButton

local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0.4, 0, 0, 30)
downButton.Position = UDim2.new(0.55, 0, 0.8, 0)
downButton.Text = "➖ -50"
downButton.TextSize = 14
downButton.Font = Enum.Font.GothamBold
downButton.TextColor3 = Color3.new(1, 1, 1)
downButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
downButton.BorderSizePixel = 0
downButton.Parent = menuFrame

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 8)
downCorner.Parent = downButton

-- Variables de estado
local menuOpen = false

-- FUNCIÓN PRINCIPAL: Aplicar velocidad
local function applySpeed()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            if speedEnabled then
                humanoid.WalkSpeed = currentSpeed
            else
                humanoid.WalkSpeed = 16
            end
        end
    end
end

-- Función para alternar velocidad
local function toggleSpeed()
    speedEnabled = not speedEnabled
    if speedEnabled then
        toggleButton.Text = "VELOCIDAD: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    else
        toggleButton.Text = "VELOCIDAD: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
    applySpeed()
end

-- Función para abrir/cerrar menú
local function toggleMenu()
    menuOpen = not menuOpen
    menuFrame.Visible = menuOpen
end

-- CONEXIÓN DE EVENTOS
mainButton.MouseButton1Click:Connect(toggleMenu)
toggleButton.MouseButton1Click:Connect(toggleSpeed)

upButton.MouseButton1Click:Connect(function()
    currentSpeed = currentSpeed + 50
    speedLabel.Text = "VELOCIDAD: " .. currentSpeed
    applySpeed()
end)

downButton.MouseButton1Click:Connect(function()
    currentSpeed = math.max(50, currentSpeed - 50)
    speedLabel.Text = "VELOCIDAD: " .. currentSpeed
    applySpeed()
end)

-- Manejo de respawn
player.CharacterAdded:Connect(function(character)
    wait(1) -- Esperar a que cargue el personaje
    applySpeed()
end)

-- Aplicar velocidad al iniciar
applySpeed()

-- Hacer arrastrable
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        if input.UserInputState == Enum.UserInputState.Begin then
            dragging = true
            dragStart = input.Position
            startPos = mainButton.Position
        elseif input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end
end

mainButton.InputBegan:Connect(updateInput)
mainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainButton.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        menuFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X - 65,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

print("🎯 BOOM SPEED CARGADO!")
print("⚡ Toca el botón azul para abrir el menú")
print("🚀 Velocidad inicial: " .. currentSpeed)
