– Script de Velocidad y Vuelo CORREGIDO para Móvil
local Players = game:GetService(“Players”)
local UserInputService = game:GetService(“UserInputService”)
local RunService = game:GetService(“RunService”)
local CoreGui = game:GetService(“CoreGui”)
local ContextActionService = game:GetService(“ContextActionService”)

local player = Players.LocalPlayer

– Configuración de velocidad
local speedEnabled = false
local normalSpeed = 16
local currentSpeed = 50
local minSpeed = 16
local maxSpeed = 100
local speedIncrement = 10

– Configuración de vuelo CORREGIDA
local flyEnabled = false
local flySpeed = 50
local minFlySpeed = 10
local maxFlySpeed = 100
local flyIncrement = 10

– Variables de vuelo MODERNAS
local bodyVelocity, bodyPosition, bodyAngularVelocity

– Variables de control de vuelo
local flyConnection
local upPressed = false
local downPressed = false

– ===== INTERFAZ DE USUARIO =====
local screenGui = Instance.new(“ScreenGui”)
screenGui.Name = “SpeedFlyMenu”
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new(“Frame”)
mainFrame.Size = UDim2.new(0, 220, 0, 280)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

– Esquinas redondeadas
local corner = Instance.new(“UICorner”)
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

– Título
local title = Instance.new(“TextLabel”)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = “⚡ VELOCIDAD + ✈️ VUELO”
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new(“UICorner”)
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

– ===== SECCIÓN DE VELOCIDAD =====
local speedSection = Instance.new(“TextLabel”)
speedSection.Size = UDim2.new(0.9, 0, 0, 20)
speedSection.Position = UDim2.new(0.05, 0, 0.15, 0)
speedSection.BackgroundTransparency = 1
speedSection.Text = “🏃 VELOCIDAD:”
speedSection.TextColor3 = Color3.fromRGB(200, 200, 200)
speedSection.TextSize = 12
speedSection.TextXAlignment = Enum.TextXAlignment.Left
speedSection.Parent = mainFrame

local speedButton = Instance.new(“TextButton”)
speedButton.Size = UDim2.new(0.9, 0, 0, 35)
speedButton.Position = UDim2.new(0.05, 0, 0.22, 0)
speedButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
speedButton.Text = “🚫 VELOCIDAD NORMAL”
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.TextSize = 12
speedButton.Font = Enum.Font.GothamBold
speedButton.Parent = mainFrame

local speedCorner = Instance.new(“UICorner”)
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedButton

local speedLabel = Instance.new(“TextLabel”)
speedLabel.Size = UDim2.new(0.9, 0, 0, 25)
speedLabel.Position = UDim2.new(0.05, 0, 0.32, 0)
speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedLabel.Text = “Velocidad Actual: “ .. currentSpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 11
speedLabel.Parent = mainFrame

local speedLabelCorner = Instance.new(“UICorner”)
speedLabelCorner.CornerRadius = UDim.new(0, 4)
speedLabelCorner.Parent = speedLabel

local speedUpButton = Instance.new(“TextButton”)
speedUpButton.Size = UDim2.new(0.4, 0, 0, 25)
speedUpButton.Position = UDim2.new(0.05, 0, 0.39, 0)
speedUpButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
speedUpButton.Text = “⬆️ AUMENTAR”
speedUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpButton.TextSize = 10
speedUpButton.Parent = mainFrame

local speedUpCorner = Instance.new(“UICorner”)
speedUpCorner.CornerRadius = UDim.new(0, 4)
speedUpCorner.Parent = speedUpButton

local speedDownButton = Instance.new(“TextButton”)
speedDownButton.Size = UDim2.new(0.4, 0, 0, 25)
speedDownButton.Position = UDim2.new(0.55, 0, 0.39, 0)
speedDownButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
speedDownButton.Text = “⬇️ DISMINUIR”
speedDownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownButton.TextSize = 10
speedDownButton.Parent = mainFrame

local speedDownCorner = Instance.new(“UICorner”)
speedDownCorner.CornerRadius = UDim.new(0, 4)
speedDownCorner.Parent = speedDownButton

– ===== SECCIÓN DE VUELO =====
local flySection = Instance.new(“TextLabel”)
flySection.Size = UDim2.new(0.9, 0, 0, 20)
flySection.Position = UDim2.new(0.05, 0, 0.48, 0)
flySection.BackgroundTransparency = 1
flySection.Text = “✈️ VUELO:”
flySection.TextColor3 = Color3.fromRGB(200, 200, 200)
flySection.TextSize = 12
flySection.TextXAlignment = Enum.TextXAlignment.Left
flySection.Parent = mainFrame

local flyButton = Instance.new(“TextButton”)
flyButton.Size = UDim2.new(0.9, 0, 0, 35)
flyButton.Position = UDim2.new(0.05, 0, 0.55, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
flyButton.Text = “🚫 VUELO DESACTIVADO”
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextSize = 12
flyButton.Font = Enum.Font.GothamBold
flyButton.Parent = mainFrame

local flyCorner = Instance.new(“UICorner”)
flyCorner.CornerRadius = UDim.new(0, 6)
flyCorner.Parent = flyButton

local flyLabel = Instance.new(“TextLabel”)
flyLabel.Size = UDim2.new(0.9, 0, 0, 25)
flyLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
flyLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
flyLabel.Text = “Velocidad Vuelo: “ .. flySpeed
flyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
flyLabel.TextSize = 11
flyLabel.Parent = mainFrame

local flyLabelCorner = Instance.new(“UICorner”)
flyLabelCorner.CornerRadius = UDim.new(0, 4)
flyLabelCorner.Parent = flyLabel

local flySpeedUpButton = Instance.new(“TextButton”)
flySpeedUpButton.Size = UDim2.new(0.4, 0, 0, 25)
flySpeedUpButton.Position = UDim2.new(0.05, 0, 0.72, 0)
flySpeedUpButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flySpeedUpButton.Text = “⬆️ + VELOCIDAD”
flySpeedUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedUpButton.TextSize = 10
flySpeedUpButton.Parent = mainFrame

local flySpeedUpCorner = Instance.new(“UICorner”)
flySpeedUpCorner.CornerRadius = UDim.new(0, 4)
flySpeedUpCorner.Parent = flySpeedUpButton

local flySpeedDownButton = Instance.new(“TextButton”)
flySpeedDownButton.Size = UDim2.new(0.4, 0, 0, 25)
flySpeedDownButton.Position = UDim2.new(0.55, 0, 0.72, 0)
flySpeedDownButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
flySpeedDownButton.Text = “⬇️ - VELOCIDAD”
flySpeedDownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedDownButton.TextSize = 10
flySpeedDownButton.Parent = mainFrame

local flySpeedDownCorner = Instance.new(“UICorner”)
flySpeedDownCorner.CornerRadius = UDim.new(0, 4)
flySpeedDownCorner.Parent = flySpeedDownButton

– Instrucciones
local instructions = Instance.new(“TextLabel”)
instructions.Size = UDim2.new(0.9, 0, 0, 40)
instructions.Position = UDim2.new(0.05, 0, 0.87, 0)
instructions.BackgroundTransparency = 1
instructions.Text = “MÓVIL: Joystick para mover\nPC: WASD + Espacio/Shift”
instructions.TextColor3 = Color3.fromRGB(200, 200, 200)
instructions.TextSize = 9
instructions.TextWrapped = true
instructions.Parent = mainFrame

– ===== SISTEMA DE VELOCIDAD =====
local function updateSpeedUI()
if speedEnabled then
speedButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
speedButton.Text = “⚡ VELOCIDAD RÁPIDA”
else
speedButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
speedButton.Text = “🚫 VELOCIDAD NORMAL”
end
speedLabel.Text = “Velocidad Actual: “ .. currentSpeed
end

local function applySpeed()
local character = player.Character
if character then
local humanoid = character:FindFirstChild(“Humanoid”)
if humanoid then
humanoid.WalkSpeed = speedEnabled and currentSpeed or normalSpeed
end
end
end

local function toggleSpeed()
speedEnabled = not speedEnabled
updateSpeedUI()
applySpeed()
end

local function increaseSpeed()
currentSpeed = math.min(currentSpeed + speedIncrement, maxSpeed)
updateSpeedUI()
if speedEnabled then applySpeed() end
end

local function decreaseSpeed()
currentSpeed = math.max(currentSpeed - speedIncrement, minSpeed)
updateSpeedUI()
if speedEnabled then applySpeed() end
end

– ===== SISTEMA DE VUELO CORREGIDO =====
local function updateFlyUI()
if flyEnabled then
flyButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
flyButton.Text = “✈️ VUELO ACTIVADO”
else
flyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
flyButton.Text = “🚫 VUELO DESACTIVADO”
end
flyLabel.Text = “Velocidad Vuelo: “ .. flySpeed
end

– Función para manejar controles de vuelo vertical (PC)
local function handleFlyUp(actionName, inputState, inputObject)
if not flyEnabled then return Enum.ContextActionResult.Pass end

```
upPressed = (inputState == Enum.UserInputState.Begin)
return Enum.ContextActionResult.Sink
```

end

local function handleFlyDown(actionName, inputState, inputObject)
if not flyEnabled then return Enum.ContextActionResult.Pass end

```
downPressed = (inputState == Enum.UserInputState.Begin)
return Enum.ContextActionResult.Sink
```

end

local function enableFly()
if flyEnabled then return end

```
local character = player.Character
if not character then return end

local humanoid = character:FindFirstChild("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")

if not humanoid or not rootPart then return end

flyEnabled = true
upPressed = false
downPressed = false

-- Usar BodyMovers clásicos para mayor compatibilidad
bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
bodyVelocity.Velocity = Vector3.new(0, 0, 0)
bodyVelocity.Parent = rootPart

bodyAngularVelocity = Instance.new("BodyAngularVelocity")
bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
bodyAngularVelocity.Parent = rootPart

-- Configurar humanoid
humanoid.PlatformStand = true

-- Vincular controles para PC
ContextActionService:BindAction("FlyUp", handleFlyUp, false, Enum.KeyCode.Space)
ContextActionService:BindAction("FlyDown", handleFlyDown, false, Enum.KeyCode.LeftShift)

-- Loop principal de vuelo
flyConnection = RunService.Heartbeat:Connect(function()
    if not flyEnabled or not character.Parent then return end
    
    local camera = workspace.CurrentCamera
    local cameraCFrame = camera.CFrame
    
    -- Obtener dirección de movimiento del humanoid (funciona con WASD y joystick móvil)
    local moveVector = humanoid.MoveDirection
    
    -- Convertir movimiento a espacio de cámara para vuelo más intuitivo
    local forwardVector = cameraCFrame.LookVector
    local rightVector = cameraCFrame.RightVector
    
    -- Calcular velocidad horizontal basada en el input del usuario
    local horizontalVelocity = (forwardVector * moveVector.Z + rightVector * moveVector.X) * flySpeed
    
    -- Calcular velocidad vertical
    local verticalVelocity = 0
    if upPressed then
        verticalVelocity = flySpeed
    elseif downPressed then
        verticalVelocity = -flySpeed
    end
    
    -- Para móvil: usar el botón de salto como subir
    if UserInputService.TouchEnabled and humanoid.Jump then
        verticalVelocity = flySpeed
        humanoid.Jump = false -- Prevenir salto normal
    end
    
    -- Aplicar velocidad final
    local finalVelocity = Vector3.new(
        horizontalVelocity.X,
        verticalVelocity,
        horizontalVelocity.Z
    )
    
    if bodyVelocity then
        bodyVelocity.Velocity = finalVelocity
    end
end)

updateFlyUI()
```

end

local function disableFly()
if not flyEnabled then return end

```
flyEnabled = false
upPressed = false
downPressed = false

-- Desconectar loop de vuelo
if flyConnection then
    flyConnection:Disconnect()
    flyConnection = nil
end

local character = player.Character
if character then
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    -- Limpiar BodyMovers
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyAngularVelocity then
        bodyAngularVelocity:Destroy()
        bodyAngularVelocity = nil
    end
end

-- Desvincular controles
ContextActionService:UnbindAction("FlyUp")
ContextActionService:UnbindAction("FlyDown")

updateFlyUI()
```

end

local function toggleFly()
if flyEnabled then
disableFly()
else
enableFly()
end
end

local function increaseFlySpeed()
flySpeed = math.min(flySpeed + flyIncrement, maxFlySpeed)
updateFlyUI()
end

local function decreaseFlySpeed()
flySpeed = math.max(flySpeed - flyIncrement, minFlySpeed)
updateFlyUI()
end

– ===== CONEXIÓN DE BOTONES =====
speedButton.MouseButton1Click:Connect(toggleSpeed)
speedUpButton.MouseButton1Click:Connect(increaseSpeed)
speedDownButton.MouseButton1Click:Connect(decreaseSpeed)

flyButton.MouseButton1Click:Connect(toggleFly)
flySpeedUpButton.MouseButton1Click:Connect(increaseFlySpeed)
flySpeedDownButton.MouseButton1Click:Connect(decreaseFlySpeed)

– ===== MANEJO DE RESPAWN =====
player.CharacterAdded:Connect(function(character)
wait(1) – Esperar carga completa

```
-- Restablecer variables
upPressed = false
downPressed = false

-- Aplicar configuraciones
applySpeed()

-- Si el vuelo estaba activo, reactivarlo
if flyEnabled then
    flyEnabled = false -- Reset para forzar reactivación
    wait(0.5)
    enableFly()
end
```

end)

– Limpiar cuando el jugador se va
player.CharacterRemoving:Connect(function()
if flyEnabled then
disableFly()
end
end)

– ===== INICIALIZACIÓN =====
updateSpeedUI()
updateFlyUI()
applySpeed()

print(“✅ Sistema de Velocidad y Vuelo CORREGIDO v2.0”)
print(“⚡ Velocidad funcionando correctamente”)
print(“✈️ Vuelo compatible con móvil y PC”)
print(“📱 Móvil: Usa joystick + botón de salto para subir”)
print(“💻 PC: WASD + Espacio/Shift”)
