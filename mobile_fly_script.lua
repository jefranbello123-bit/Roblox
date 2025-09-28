– LocalScript de Velocidad y Vuelo
– COLOCAR EN: StarterPlayer > StarterCharacterScripts

local Players = game:GetService(“Players”)
local UserInputService = game:GetService(“UserInputService”)
local RunService = game:GetService(“RunService”)
local ContextActionService = game:GetService(“ContextActionService”)

local player = Players.LocalPlayer

– Variables de velocidad
local speedEnabled = false
local normalSpeed = 16
local currentSpeed = 50

– Variables de vuelo
local flyEnabled = false
local flySpeed = 50
local flying = false

– Componentes de vuelo modernos
local linearVelocity = nil
local alignOrientation = nil
local attachment = nil

– Variables de control
local flyConnection = nil

– Función para crear GUI
local function createGUI()
local playerGui = player:WaitForChild(“PlayerGui”)

```
-- Eliminar GUI anterior si existe
local existingGUI = playerGui:FindFirstChild("SpeedFlyGUI")
if existingGUI then
    existingGUI:Destroy()
end

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedFlyGUI"
screenGui.Parent = playerGui

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 280)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = "⚡ SPEED & FLY HACK"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- === SECCIÓN VELOCIDAD ===
local speedSection = Instance.new("TextLabel")
speedSection.Size = UDim2.new(0.9, 0, 0, 20)
speedSection.Position = UDim2.new(0.05, 0, 0.15, 0)
speedSection.BackgroundTransparency = 1
speedSection.Text = "🏃 VELOCIDAD:"
speedSection.TextColor3 = Color3.fromRGB(200, 200, 200)
speedSection.TextSize = 12
speedSection.TextXAlignment = Enum.TextXAlignment.Left
speedSection.Parent = mainFrame

local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0.9, 0, 0, 35)
speedButton.Position = UDim2.new(0.05, 0, 0.22, 0)
speedButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
speedButton.Text = "🚫 VELOCIDAD OFF"
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.TextSize = 12
speedButton.Font = Enum.Font.GothamBold
speedButton.Parent = mainFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 25)
speedLabel.Position = UDim2.new(0.05, 0, 0.32, 0)
speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedLabel.Text = "Velocidad: " .. currentSpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 11
speedLabel.Parent = mainFrame

local speedUpButton = Instance.new("TextButton")
speedUpButton.Size = UDim2.new(0.4, 0, 0, 25)
speedUpButton.Position = UDim2.new(0.05, 0, 0.39, 0)
speedUpButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
speedUpButton.Text = "⬆️ MÁS"
speedUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpButton.TextSize = 10
speedUpButton.Parent = mainFrame

local speedDownButton = Instance.new("TextButton")
speedDownButton.Size = UDim2.new(0.4, 0, 0, 25)
speedDownButton.Position = UDim2.new(0.55, 0, 0.39, 0)
speedDownButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
speedDownButton.Text = "⬇️ MENOS"
speedDownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownButton.TextSize = 10
speedDownButton.Parent = mainFrame

-- === SECCIÓN VUELO ===
local flySection = Instance.new("TextLabel")
flySection.Size = UDim2.new(0.9, 0, 0, 20)
flySection.Position = UDim2.new(0.05, 0, 0.48, 0)
flySection.BackgroundTransparency = 1
flySection.Text = "✈️ VUELO:"
flySection.TextColor3 = Color3.fromRGB(200, 200, 200)
flySection.TextSize = 12
flySection.TextXAlignment = Enum.TextXAlignment.Left
flySection.Parent = mainFrame

local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.9, 0, 0, 35)
flyButton.Position = UDim2.new(0.05, 0, 0.55, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
flyButton.Text = "🚫 VUELO OFF"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextSize = 12
flyButton.Font = Enum.Font.GothamBold
flyButton.Parent = mainFrame

local flyLabel = Instance.new("TextLabel")
flyLabel.Size = UDim2.new(0.9, 0, 0, 25)
flyLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
flyLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
flyLabel.Text = "Velocidad Vuelo: " .. flySpeed
flyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
flyLabel.TextSize = 11
flyLabel.Parent = mainFrame

local flySpeedUpButton = Instance.new("TextButton")
flySpeedUpButton.Size = UDim2.new(0.4, 0, 0, 25)
flySpeedUpButton.Position = UDim2.new(0.05, 0, 0.72, 0)
flySpeedUpButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flySpeedUpButton.Text = "⬆️ + VEL"
flySpeedUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedUpButton.TextSize = 10
flySpeedUpButton.Parent = mainFrame

local flySpeedDownButton = Instance.new("TextButton")
flySpeedDownButton.Size = UDim2.new(0.4, 0, 0, 25)
flySpeedDownButton.Position = UDim2.new(0.55, 0, 0.72, 0)
flySpeedDownButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
flySpeedDownButton.Text = "⬇️ - VEL"
flySpeedDownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedDownButton.TextSize = 10
flySpeedDownButton.Parent = mainFrame

-- Instrucciones
local instructions = Instance.new("TextLabel")
instructions.Size = UDim2.new(0.9, 0, 0, 40)
instructions.Position = UDim2.new(0.05, 0, 0.87, 0)
instructions.BackgroundTransparency = 1
instructions.Text = "PC: WASD + Espacio/Shift\nMóvil: Joystick + botones"
instructions.TextColor3 = Color3.fromRGB(200, 200, 200)
instructions.TextSize = 9
instructions.TextWrapped = true
instructions.Parent = mainFrame

return {
    speedButton = speedButton,
    speedLabel = speedLabel,
    speedUpButton = speedUpButton,
    speedDownButton = speedDownButton,
    flyButton = flyButton,
    flyLabel = flyLabel,
    flySpeedUpButton = flySpeedUpButton,
    flySpeedDownButton = flySpeedDownButton
}
```

end

– Función para aplicar velocidad
local function applySpeed()
local character = player.Character
if character then
local humanoid = character:FindFirstChild(“Humanoid”)
if humanoid then
humanoid.WalkSpeed = speedEnabled and currentSpeed or normalSpeed
end
end
end

– Función para actualizar UI de velocidad
local function updateSpeedUI(gui)
if speedEnabled then
gui.speedButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
gui.speedButton.Text = “⚡ VELOCIDAD ON”
else
gui.speedButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
gui.speedButton.Text = “🚫 VELOCIDAD OFF”
end
gui.speedLabel.Text = “Velocidad: “ .. currentSpeed
end

– Función para toggle velocidad
local function toggleSpeed(gui)
speedEnabled = not speedEnabled
updateSpeedUI(gui)
applySpeed()
end

– Función para cambiar velocidad
local function changeSpeed(amount, gui)
currentSpeed = math.max(16, math.min(200, currentSpeed + amount))
updateSpeedUI(gui)
if speedEnabled then
applySpeed()
end
end

– Función para limpiar componentes de vuelo
local function cleanupFly()
if flyConnection then
flyConnection:Disconnect()
flyConnection = nil
end

```
if linearVelocity then
    linearVelocity:Destroy()
    linearVelocity = nil
end

if alignOrientation then
    alignOrientation:Destroy()
    alignOrientation = nil
end

if attachment then
    attachment:Destroy()
    attachment = nil
end

-- Limpiar ContextActionService
ContextActionService:UnbindAction("FlyUp")
ContextActionService:UnbindAction("FlyDown")
```

end

– Función para iniciar vuelo
local function startFly()
local character = player.Character
if not character then return end

```
local humanoid = character:FindFirstChild("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")

if not humanoid or not rootPart then return end

flying = true

-- Crear attachment para BodyMovers modernos
attachment = Instance.new("Attachment")
attachment.Parent = rootPart

-- LinearVelocity para movimiento moderno
linearVelocity = Instance.new("LinearVelocity")
linearVelocity.Attachment0 = attachment
linearVelocity.MaxForce = 10000
linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
linearVelocity.Parent = rootPart

-- AlignOrientation para estabilidad
alignOrientation = Instance.new("AlignOrientation")
alignOrientation.Attachment0 = attachment
alignOrientation.MaxTorque = 10000
alignOrientation.Responsiveness = 50
alignOrientation.Parent = rootPart

-- Configurar humanoid
humanoid.PlatformStand = true

-- Controles de vuelo usando ContextActionService
local function flyUp(actionName, inputState)
    -- Esta función se maneja en el loop principal
    return Enum.ContextActionResult.Pass
end

local function flyDown(actionName, inputState)
    -- Esta función se maneja en el loop principal
    return Enum.ContextActionResult.Pass
end

-- Bind actions (esto creará botones automáticamente en móvil)
ContextActionService:BindAction("FlyUp", flyUp, true, Enum.KeyCode.Space)
ContextActionService:BindAction("FlyDown", flyDown, true, Enum.KeyCode.LeftShift)

-- Loop principal de vuelo
flyConnection = RunService.Heartbeat:Connect(function()
    if not flying or not character.Parent then return end
    
    local camera = workspace.CurrentCamera
    local cameraCFrame = camera.CFrame
    
    -- Obtener input de movimiento del humanoid (funciona con WASD y joystick)
    local moveVector = humanoid.MoveDirection
    
    -- Calcular dirección basada en cámara
    local forwardVector = cameraCFrame.LookVector
    local rightVector = cameraCFrame.RightVector
    
    -- Movimiento horizontal
    local horizontalVelocity = (forwardVector * moveVector.Z + rightVector * moveVector.X) * flySpeed
    
    -- Movimiento vertical
    local verticalVelocity = 0
    
    -- Verificar controles verticales
    local spacePressed = UserInputService:IsKeyDown(Enum.KeyCode.Space)
    local shiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    
    if spacePressed then
        verticalVelocity = flySpeed
    elseif shiftPressed then
        verticalVelocity = -flySpeed
    end
    
    -- Para móvil: usar Jump como subir
    if UserInputService.TouchEnabled and humanoid.Jump then
        verticalVelocity = flySpeed
        humanoid.Jump = false
    end
    
    -- Aplicar velocidad final
    local finalVelocity = Vector3.new(
        horizontalVelocity.X,
        verticalVelocity,
        horizontalVelocity.Z
    )
    
    if linearVelocity then
        linearVelocity.VectorVelocity = finalVelocity
    end
    
    -- Mantener orientación hacia la cámara
    if alignOrientation then
        alignOrientation.CFrame = cameraCFrame
    end
end)
```

end

– Función para parar vuelo
local function stopFly()
flying = false

```
local character = player.Character
if character then
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
    end
end

cleanupFly()
```

end

– Actualizar UI de vuelo
local function updateFlyUI(gui)
if flyEnabled then
gui.flyButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
gui.flyButton.Text = “✈️ VUELO ON”
else
gui.flyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
gui.flyButton.Text = “🚫 VUELO OFF”
end
gui.flyLabel.Text = “Velocidad Vuelo: “ .. flySpeed
end

– Toggle vuelo
local function toggleFly(gui)
flyEnabled = not flyEnabled
updateFlyUI(gui)

```
if flyEnabled then
    startFly()
else
    stopFly()
end
```

end

– Función para cambiar velocidad de vuelo
local function changeFlySpeed(amount, gui)
flySpeed = math.max(10, math.min(200, flySpeed + amount))
updateFlyUI(gui)
end

– Función principal que se ejecuta cuando aparece el personaje
local function setupCharacter()
local character = player.Character or player.CharacterAdded:Wait()

```
-- Limpiar cualquier vuelo anterior
cleanupFly()

-- Crear GUI
local gui = createGUI()

-- Conectar eventos de botones
gui.speedButton.MouseButton1Click:Connect(function()
    toggleSpeed(gui)
end)

gui.speedUpButton.MouseButton1Click:Connect(function()
    changeSpeed(10, gui)
end)

gui.speedDownButton.MouseButton1Click:Connect(function()
    changeSpeed(-10, gui)
end)

gui.flyButton.MouseButton1Click:Connect(function()
    toggleFly(gui)
end)

gui.flySpeedUpButton.MouseButton1Click:Connect(function()
    changeFlySpeed(10, gui)
end)

gui.flySpeedDownButton.MouseButton1Click:Connect(function()
    changeFlySpeed(-10, gui)
end)

-- Actualizar UI inicial
updateSpeedUI(gui)
updateFlyUI(gui)

-- Aplicar configuraciones
applySpeed()

print("✅ Speed & Fly LocalScript cargado correctamente!")
```

end

– Manejar cuando el personaje aparece/reaparece
player.CharacterAdded:Connect(setupCharacter)

– Si ya hay un personaje, configurarlo inmediatamente
if player.Character then
setupCharacter()
end
