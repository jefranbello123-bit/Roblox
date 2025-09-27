-- Fly System para Móvil - Basado en Chilli.txt (Desofuscado)
-- Versión limpia y funcional

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")

-- Configuración como en Chilli.txt
local flightPower = 50
local maxFlightPower = 150
local minFlightPower = 10
local speedIncrement = 10
local isFlying = false

-- Física como en el script ruso
local bodyPosition = Instance.new("BodyPosition")
local bodyGyro = Instance.new("BodyGyro"

bodyPosition.maxForce = Vector3.new(40000, 40000, 40000)
bodyGyro.maxTorque = Vector3.new(40000, 40000, 40000)

-- Crear GUI móvil
local gui = Instance.new("ScreenGui")
gui.Name = "FlyMobileSystem"
gui.Parent = CoreGui

-- Marco principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 350)
mainFrame.Position = UDim2.new(0, 10, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
title.Text = "🚀 FLY SYSTEM v4.0"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Botón principal de fly
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.9, 0, 0, 50)
flyButton.Position = UDim2.new(0.05, 0, 0.12, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
flyButton.Text = "✈️ ACTIVAR VUELO"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextSize = 14
flyButton.Font = Enum.Font.GothamBold
flyButton.Parent = mainFrame

-- Display de potencia
local powerLabel = Instance.new("TextLabel")
powerLabel.Size = UDim2.new(0.9, 0, 0, 35)
powerLabel.Position = UDim2.new(0.05, 0, 0.28, 0)
powerLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
powerLabel.Text = "POTENCIA: " .. flightPower
powerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
powerLabel.TextSize = 14
powerLabel.Parent = mainFrame

-- Controles de potencia
local powerUp = Instance.new("TextButton")
powerUp.Size = UDim2.new(0.4, 0, 0, 35)
powerUp.Position = UDim2.new(0.05, 0, 0.38, 0)
powerUp.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
powerUp.Text = "⬆️ + POTENCIA"
powerUp.TextColor3 = Color3.fromRGB(255, 255, 255)
powerUp.TextSize = 12
powerUp.Parent = mainFrame

local powerDown = Instance.new("TextButton")
powerDown.Size = UDim2.new(0.4, 0, 0, 35)
powerDown.Position = UDim2.new(0.55, 0, 0.38, 0)
powerDown.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
powerDown.Text = "⬇️ - POTENCIA"
powerDown.TextColor3 = Color3.fromRGB(255, 255, 255)
powerDown.TextSize = 12
powerDown.Parent = mainFrame

-- Área de control direccional (Joystick virtual)
local joystickArea = Instance.new("Frame")
joystickArea.Size = UDim2.new(0.9, 0, 0, 120)
joystickArea.Position = UDim2.new(0.05, 0, 0.52, 0)
joystickArea.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
joystickArea.BorderSizePixel = 2
joystickArea.BorderColor3 = Color3.fromRGB(100, 100, 150)
joystickArea.Parent = mainFrame

local joystickDot = Instance.new("Frame")
joystickDot.Size = UDim2.new(0, 30, 0, 30)
joystickDot.Position = UDim2.new(0.5, -15, 0.5, -15)
joystickDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
joystickDot.BorderSizePixel = 0
joystickDot.Parent = joystickArea

local joystickLabel = Instance.new("TextLabel")
joystickLabel.Size = UDim2.new(1, 0, 0, 30)
joystickLabel.Position = UDim2.new(0, 0, 0.85, 0)
joystickLabel.BackgroundTransparency = 1
joystickLabel.Text = "⬅️➡️ MUEVE EL PUNTO PARA VOLAR"
joystickLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
joystickLabel.TextSize = 11
joystickLabel.TextWrapped = true
joystickLabel.Parent = joystickArea

-- Controles de altura
local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0.4, 0, 0, 35)
upButton.Position = UDim2.new(0.05, 0, 0.78, 0)
upButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
upButton.Text = "⬆️ ASCENDER"
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.TextSize = 12
upButton.Parent = mainFrame

local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0.4, 0, 0, 35)
downButton.Position = UDim2.new(0.55, 0, 0.78, 0)
downButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
downButton.Text = "⬇️ DESCENDER"
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.TextSize = 12
downButton.Parent = mainFrame

-- Variables de control
local touchStartPos = nil
local touchCurrentPos = nil
local touchActive = false
local moveDirection = Vector2.new(0, 0)
local verticalInput = 0

-- Función para actualizar UI
local function updateUI()
    if isFlying then
        flyButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        flyButton.Text = "✈️ VUELO ACTIVADO"
    else
        flyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        flyButton.Text = "🚫 VUELO DESACTIVADO"
    end
    powerLabel.Text = "POTENCIA: " .. flightPower
end

-- Función de activación de vuelo (estilo ruso)
local function activateFlight()
    if isFlying or not torso then return end
    
    isFlying = true
    
    -- Configurar componentes físicos
    bodyPosition.Parent = torso
    bodyPosition.Position = torso.Position + Vector3.new(0, 5, 0)
    bodyGyro.Parent = torso
    
    humanoid.PlatformStand = true
    
    updateUI()
    
    -- Loop principal de vuelo
    spawn(function()
        while isFlying and torso and torso.Parent do
            local camera = workspace.CurrentCamera
            
            if camera then
                -- Control direccional con joystick
                local cameraCFrame = camera.CFrame
                local moveVector = Vector3.new(
                    moveDirection.X * flightPower,
                    verticalInput * flightPower,
                    moveDirection.Y * flightPower
                )
                
                -- Convertir a espacio mundial
                local worldMove = cameraCFrame:VectorToWorldSpace(moveVector)
                
                -- Aplicar movimiento (método ruso)
                bodyPosition.Position = torso.Position + worldMove
                
                -- Mantener orientación
                bodyGyro.CFrame = CFrame.new(torso.Position, torso.Position + cameraCFrame.LookVector)
            end
            
            RunService.Heartbeat:Wait()
        end
    end)
end

-- Función de desactivación
local function deactivateFlight()
    if not isFlying then return end
    
    isFlying = false
    
    bodyGyro.Parent = nil
    bodyPosition.Parent = nil
    
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    moveDirection = Vector2.new(0, 0)
    verticalInput = 0
    updateUI()
end

-- Control de potencia
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
        deactivateFlight()
    else
        activateFlight()
    end
end)

powerUp.MouseButton1Click:Connect(increasePower)
powerDown.MouseButton1Click:Connect(decreasePower)

-- Control táctil del joystick
joystickArea.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touchStartPos = input.Position
        touchActive = true
    end
end)

joystickArea.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and touchActive then
        touchCurrentPos = input.Position
        
        local center = joystickArea.AbsolutePosition + joystickArea.AbsoluteSize / 2
        local delta = (touchCurrentPos - center)
        local maxDistance = 40
        
        -- Limitar movimiento del joystick visual
        local distance = math.min(delta.Magnitude, maxDistance)
        local direction = delta.Unit
        
        -- Actualizar posición visual del joystick
        joystickDot.Position = UDim2.new(0.5, direction.X * distance, 0.5, direction.Y * distance)
        
        -- Calcular dirección de movimiento
        moveDirection = Vector2.new(
            math.clamp(delta.X / maxDistance, -1, 1),
            math.clamp(delta.Y / maxDistance, -1, 1)
        )
    end
end)

joystickArea.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touchActive = false
        moveDirection = Vector2.new(0, 0)
        -- Resetear joystick visual
        joystickDot.Position = UDim2.new(0.5, -15, 0.5, -15)
    end
end)

-- Control de altura
upButton.MouseButton1Down:Connect(function()
    verticalInput = 1
end)

upButton.MouseButton1Up:Connect(function()
    verticalInput = 0
end)

downButton.MouseButton1Down:Connect(function()
    verticalInput = -1
end)

downButton.MouseButton1Up:Connect(function()
    verticalInput = 0
end)

-- Manejar respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    torso = newCharacter:FindFirstChild("UpperTorso") or newCharacter:FindFirstChild("Torso")
    
    deactivateFlight()
    wait(2) -- Esperar estabilización
end)

-- Inicializar
updateUI()

print("✅ Sistema de Vuelo para Móvil Cargado")
print("🎮 Usa el área joystick para moverte")
print("⬆️⬇️ Botones para altura")
print("⚡ Ajusta la potencia con los botones +-")

return {
    activateFlight = activateFlight,
    deactivateFlight = deactivateFlight,
    setFlightPower = function(power)
        flightPower = math.clamp(power, minFlightPower, maxFlightPower)
        updateUI()
    end
}
