-- Fly Script para Móvil basado en el script ruso
-- Adaptado para Roblox Delta

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")

-- Configuración basada en el script ruso
local flightPower = 30
local maxFlightPower = 100
local minFlightPower = 10
local speedIncrement = 5
local isFlying = false

-- Componentes de física (como en el script ruso)
local bodyPosition = Instance.new("BodyPosition")
local bodyGyro = Instance.new("BodyGyro")

bodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
bodyPosition.maxForce = Vector3.new(math.huge, math.huge, math.huge)

-- Crear interfaz móvil
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RussianFlyMenu"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 300)
mainFrame.Position = UDim2.new(0, 10, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Título estilo ruso
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
title.Text = "✈️ FLY SYSTEM v3.0"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Botón de activación
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.9, 0, 0, 50)
flyButton.Position = UDim2.new(0.05, 0, 0.15, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
flyButton.Text = "🚫 FLY DESACTIVADO"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextSize = 14
flyButton.Font = Enum.Font.GothamBold
flyButton.Parent = mainFrame

-- Display de potencia (como en el ruso)
local powerLabel = Instance.new("TextLabel")
powerLabel.Size = UDim2.new(0.9, 0, 0, 40)
powerLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
powerLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
powerLabel.Text = "Flight Power: " .. flightPower
powerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
powerLabel.TextSize = 14
powerLabel.Parent = mainFrame

-- Botones de control (adaptados para móvil)
local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0.4, 0, 0, 40)
upButton.Position = UDim2.new(0.05, 0, 0.5, 0)
upButton.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
upButton.Text = "⬆️ +POWER"
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.TextSize = 12
upButton.Parent = mainFrame

local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0.4, 0, 0, 40)
downButton.Position = UDim2.new(0.55, 0, 0.5, 0)
downButton.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
downButton.Text = "⬇️ -POWER"
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.TextSize = 12
downButton.Parent = mainFrame

-- Área de control direccional (simula joystick)
local joystickFrame = Instance.new("Frame")
joystickFrame.Size = UDim2.new(0.9, 0, 0, 100)
joystickFrame.Position = UDim2.new(0.05, 0, 0.65, 0)
joystickFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
joystickFrame.BorderSizePixel = 2
joystickFrame.BorderColor3 = Color3.fromRGB(100, 100, 150)
joystickFrame.Parent = mainFrame

local joystickLabel = Instance.new("TextLabel")
joystickLabel.Size = UDim2.new(1, 0, 1, 0)
joystickLabel.BackgroundTransparency = 1
joystickLabel.Text = "⬅️➡️ MOVE JOYSTICK\n⬆️⬇️ USE GAME JOYSTICK"
joystickLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
joystickLabel.TextSize = 11
joystickLabel.TextWrapped = true
joystickLabel.Parent = joystickFrame

-- Variables de control táctil
local touchStartPos = nil
local touchCurrentPos = nil
local touchActive = false
local moveDirection = Vector2.new(0, 0)

-- Función para actualizar la UI
local function updateUI()
    if isFlying then
        flyButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        flyButton.Text = "✈️ FLY ACTIVADO"
    else
        flyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        flyButton.Text = "🚫 FLY DESACTIVADO"
    end
    powerLabel.Text = "Flight Power: " .. flightPower
end

-- Función de activación del vuelo (estilo ruso)
local function activateFly()
    if isFlying or not torso then return end
    
    isFlying = true
    
    -- Configurar componentes como en el script ruso
    bodyPosition.Parent = torso
    bodyPosition.Position = torso.Position + Vector3.new(0, 10, 0)
    bodyGyro.Parent = torso
    
    humanoid.PlatformStand = true
    
    updateUI()
    
    -- Loop de vuelo principal (adaptado del ruso)
    spawn(function()
        while isFlying and torso and torso.Parent do
            local camera = workspace.CurrentCamera
            
            if camera then
                -- Usar la dirección de la cámara como referencia
                local cameraCFrame = camera.CFrame
                
                -- Aplicar movimiento basado en input táctil
                local moveVector = Vector3.new(
                    moveDirection.X * flightPower,
                    0,
                    moveDirection.Y * flightPower
                )
                
                -- Convertir a espacio mundial
                local worldMove = cameraCFrame:VectorToWorldSpace(moveVector)
                
                -- Actualizar posición (método del script ruso)
                bodyPosition.Position = torso.Position + worldMove
                
                -- Mantener rotación estable mirando hacia adelante
                bodyGyro.CFrame = CFrame.new(torso.Position, torso.Position + cameraCFrame.LookVector)
            end
            
            RunService.Heartbeat:Wait()
        end
    end)
end

-- Función de desactivación del vuelo
local function deactivateFly()
    if not isFlying then return end
    
    isFlying = false
    
    bodyGyro.Parent = nil
    bodyPosition.Parent = nil
    
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    moveDirection = Vector2.new(0, 0)
    updateUI()
end

-- Control de potencia (como en el script ruso)
local function increasePower()
    flightPower = math.min(flightPower + speedIncrement, maxFlightPower)
    updateUI()
end

local function decreasePower()
    flightPower = math.max(flightPower - speedIncrement, minFlightPower)
    updateUI()
end

-- Conexión de botones
flyButton.MouseButton1Click:Connect(function()
    if isFlying then
        deactivateFly()
    else
        activateFly()
    end
end)

upButton.MouseButton1Click:Connect(increasePower)
downButton.MouseButton1Click:Connect(decreasePower)

-- Sistema de control táctil mejorado
joystickFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touchStartPos = input.Position
        touchActive = true
    end
end)

joystickFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and touchActive then
        touchCurrentPos = input.Position
        
        local delta = (touchCurrentPos - touchStartPos)
        local maxDelta = 50
        
        -- Normalizar la dirección
        moveDirection = Vector2.new(
            math.clamp(delta.X / maxDelta, -1, 1),
            math.clamp(delta.Y / maxDelta, -1, 1)
        )
        
        -- Actualizar visual del joystick
        joystickLabel.Text = string.format("MOVING:\nX: %.1f\nY: %.1f", moveDirection.X, moveDirection.Y)
    end
end)

joystickFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touchActive = false
        moveDirection = Vector2.new(0, 0)
        joystickLabel.Text = "⬅️➡️ MOVE JOYSTICK\n⬆️⬇️ USE GAME JOYSTICK"
    end
end)

-- Control de altura con botones táctiles
local heightInput = 0
local heightUpBtn = Instance.new("TextButton")
heightUpBtn.Size = UDim2.new(0.4, 0, 0, 30)
heightUpBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
heightUpBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
heightUpBtn.Text = "⬆️ ASCENDER"
heightUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
heightUpBtn.TextSize = 10
heightUpBtn.Parent = mainFrame

local heightDownBtn = Instance.new("TextButton")
heightDownBtn.Size = UDim2.new(0.4, 0, 0, 30)
heightDownBtn.Position = UDim2.new(0.55, 0, 0.55, 0)
heightDownBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
heightDownBtn.Text = "⬇️ DESCENDER"
heightDownBtn.TextSize = 10
heightDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
heightDownBtn.Parent = mainFrame

heightUpBtn.MouseButton1Down:Connect(function()
    heightInput = 1
end)

heightUpBtn.MouseButton1Up:Connect(function()
    heightInput = 0
end)

heightDownBtn.MouseButton1Down:Connect(function()
    heightInput = -1
end)

heightDownBtn.MouseButton1Up:Connect(function()
    heightInput = 0
end)

-- Loop para control de altura
spawn(function()
    while true do
        if isFlying and torso and bodyPosition then
            bodyPosition.Position = bodyPosition.Position + Vector3.new(0, heightInput * 2, 0)
        end
        wait(0.1)
    end
end)

-- Manejar respawn del personaje
localPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    torso = newCharacter:FindFirstChild("UpperTorso") or newCharacter:FindFirstChild("Torso")
    
    deactivateFly()
    wait(2) -- Esperar a que el personaje se estabilice
end)

-- Inicializar
updateUI()
print("✅ Russian Fly System adaptado para móvil cargado")
print("📱 Usa el área joystick para moverte horizontalmente")
print("⬆️⬇️ Usa los botones de altura para subir/bajar")
