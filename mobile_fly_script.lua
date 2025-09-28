-- Script de Velocidad y Vuelo CORREGIDO para Móvil
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

-- Configuración de velocidad (ESTA PARTE SÍ FUNCIONA)
local speedEnabled = false
local normalSpeed = 16
local currentSpeed = 50
local minSpeed = 16
local maxSpeed = 100
local speedIncrement = 10

-- Configuración de vuelo CORREGIDA
local flyEnabled = false
local flySpeed = 50
local minFlySpeed = 10
local maxFlySpeed = 100
local flyIncrement = 10

-- Variables de vuelo MODERNAS
local linearVelocity, alignOrientation, flightAttachment

-- ===== INTERFAZ DE USUARIO (MANTENEMOS LA QUE FUNCIONA) =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedFlyMenu"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 280)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = "⚡ VELOCIDAD + ✈️ VUELO"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- ===== SECCIÓN DE VELOCIDAD (MANTENEMOS) =====
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
speedButton.Text = "🚫 VELOCIDAD NORMAL"
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.TextSize = 12
speedButton.Font = Enum.Font.GothamBold
speedButton.Parent = mainFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 25)
speedLabel.Position = UDim2.new(0.05, 0, 0.32, 0)
speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedLabel.Text = "Velocidad Actual: " .. currentSpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 11
speedLabel.Parent = mainFrame

local speedUpButton = Instance.new("TextButton")
speedUpButton.Size = UDim2.new(0.4, 0, 0, 25)
speedUpButton.Position = UDim2.new(0.05, 0, 0.39, 0)
speedUpButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
speedUpButton.Text = "⬆️ AUMENTAR"
speedUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpButton.TextSize = 10
speedUpButton.Parent = mainFrame

local speedDownButton = Instance.new("TextButton")
speedDownButton.Size = UDim2.new(0.4, 0, 0, 25)
speedDownButton.Position = UDim2.new(0.55, 0, 0.39, 0)
speedDownButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
speedDownButton.Text = "⬇️ DISMINUIR"
speedDownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownButton.TextSize = 10
speedDownButton.Parent = mainFrame

-- ===== SECCIÓN DE VUELO CORREGIDA =====
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
flyButton.Text = "🚫 VUELO DESACTIVADO"
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
flySpeedUpButton.Text = "⬆️ + VELOCIDAD"
flySpeedUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedUpButton.TextSize = 10
flySpeedUpButton.Parent = mainFrame

local flySpeedDownButton = Instance.new("TextButton")
flySpeedDownButton.Size = UDim2.new(0.4, 0, 0, 25)
flySpeedDownButton.Position = UDim2.new(0.55, 0, 0.72, 0)
flySpeedDownButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
flySpeedDownButton.Text = "⬇️ - VELOCIDAD"
flySpeedDownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedDownButton.TextSize = 10
flySpeedDownButton.Parent = mainFrame

-- Instrucciones actualizadas
local instructions = Instance.new("TextLabel")
instructions.Size = UDim2.new(0.9, 0, 0, 40)
instructions.Position = UDim2.new(0.05, 0, 0.87, 0)
instructions.BackgroundTransparency = 1
instructions.Text = "VUELO: Usa el joystick normal\nEspacio = Subir | Shift = Bajar"
instructions.TextColor3 = Color3.fromRGB(200, 200, 200)
instructions.TextSize = 9
instructions.TextWrapped = true
instructions.Parent = mainFrame

-- ===== SISTEMA DE VELOCIDAD (MANTENEMOS - ESTE SÍ FUNCIONA) =====
local function updateSpeedUI()
    if speedEnabled then
        speedButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        speedButton.Text = "⚡ VELOCIDAD RÁPIDA"
    else
        speedButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        speedButton.Text = "🚫 VELOCIDAD NORMAL"
    end
    speedLabel.Text = "Velocidad Actual: " .. currentSpeed
end

local function applySpeed()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            if speedEnabled then
                humanoid.WalkSpeed = currentSpeed
            else
                humanoid.WalkSpeed = normalSpeed
            end
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
    applySpeed()
end

local function decreaseSpeed()
    currentSpeed = math.max(currentSpeed - speedIncrement, minSpeed)
    updateSpeedUI()
    applySpeed()
end

-- ===== SISTEMA DE VUELO CORREGIDO =====
local verticalSpeed = 0

local function updateFlyUI()
    if flyEnabled then
        flyButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        flyButton.Text = "✈️ VUELO ACTIVADO"
    else
        flyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        flyButton.Text = "🚫 VUELO DESACTIVADO"
    end
    flyLabel.Text = "Velocidad Vuelo: " .. flySpeed
end

-- Función para manejar subir (usando ContextActionService)
local function handleFlyUp(actionName, inputState, inputObject)
    if not flyEnabled then return end
    
    if inputState == Enum.UserInputState.Begin then
        verticalSpeed = flySpeed  -- Subir
    elseif inputState == Enum.UserInputState.End then
        verticalSpeed = 0  -- Detener
    end
end

-- Función para manejar bajar (usando ContextActionService)
local function handleFlyDown(actionName, inputState, inputObject)
    if not flyEnabled then return end
    
    if inputState == Enum.UserInputState.Begin then
        verticalSpeed = -flySpeed  -- Bajar
    elseif inputState == Enum.UserInputState.End then
        verticalSpeed = 0  -- Detener
    end
end

local function enableFly()
    if flyEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    flyEnabled = true
    
    -- CREAR SISTEMA MODERNO DE VUELO (CORREGIDO)
    
    -- 1. Attachment necesario para los BodyMovers modernos
    flightAttachment = Instance.new("Attachment")
    flightAttachment.Name = "FlightAttachment"
    flightAttachment.Parent = rootPart
    
    -- 2. LinearVelocity para movimiento TOTAL (no solo horizontal)
    linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.Attachment0 = flightAttachment
    linearVelocity.MaxForce = 10000
    linearVelocity.Enabled = true
    linearVelocity.Parent = rootPart
    
    -- 3. AlignOrientation para estabilidad (sucesor moderno de BodyGyro)
    alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Attachment0 = flightAttachment
    alignOrientation.MaxTorque = 10000
    alignOrientation.Responsiveness = 50
    alignOrientation.Enabled = true
    alignOrientation.Parent = rootPart
    
    -- Configurar humanoid para vuelo
    humanoid.PlatformStand = true
    
    -- Vincular controles usando ContextActionService (MÉTODO CORRECTO)
    ContextActionService:BindAction("FlyUp", handleFlyUp, false, Enum.KeyCode.Space)
    ContextActionService:BindAction("FlyDown", handleFlyDown, false, Enum.KeyCode.LeftShift)
    
    updateFlyUI()
end

local function disableFly()
    if not flyEnabled then return end
    
    flyEnabled = false
    verticalSpeed = 0
    
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        
        -- LIMPIAR COMPONENTES MODERNOS
        if linearVelocity then
            linearVelocity:Destroy()
            linearVelocity = nil
        end
        if alignOrientation then
            alignOrientation:Destroy()
            alignOrientation = nil
        end
        if flightAttachment then
            flightAttachment:Destroy()
            flightAttachment = nil
        end
    end
    
    -- DESVINCULAR CONTROLES
    ContextActionService:UnbindAction("FlyUp")
    ContextActionService:UnbindAction("FlyDown")
    
    updateFlyUI()
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

-- ===== LOOP PRINCIPAL CORREGIDO =====
RunService.Heartbeat:Connect(function()
    if flyEnabled then
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart or not linearVelocity then return end
        
        -- ✅ MÉTODO CORRECTO: Usar MoveDirection del Humanoid
        -- Esto automáticamente funciona con WASD y joystick móvil
        local moveDirection = humanoid.MoveDirection
        
        -- Calcular velocidad final combinando movimiento horizontal y vertical
        local finalVelocity = Vector3.new(
            moveDirection.X * flySpeed,  -- Movimiento lateral (WASD/Joystick)
            verticalSpeed,               -- Movimiento vertical (Espacio/Shift)
            moveDirection.Z * flySpeed   -- Movimiento frontal (WASD/Joystick)
        )
        
        -- Aplicar la velocidad al LinearVelocity
        linearVelocity.VectorVelocity = finalVelocity
    end
end)

-- ===== CONEXIÓN DE BOTONES =====
speedButton.MouseButton1Click:Connect(toggleSpeed)
speedUpButton.MouseButton1Click:Connect(increaseSpeed)
speedDownButton.MouseButton1Click:Connect(decreaseSpeed)

flyButton.MouseButton1Click:Connect(toggleFly)
flySpeedUpButton.MouseButton1Click:Connect(increaseFlySpeed)
flySpeedDownButton.MouseButton1Click:Connect(decreaseFlySpeed)

-- ===== MANEJO DE RESPAWN =====
player.CharacterAdded:Connect(function(character)
    wait(1) -- Esperar carga completa
    
    -- Aplicar velocidad
    applySpeed()
    
    -- Si el vuelo estaba activo, reactivarlo
    if flyEnabled then
        disableFly() -- Limpiar primero
        wait(0.5)
        enableFly()  -- Reactivar con nuevo personaje
    end
end)

-- ===== INICIALIZACIÓN =====
updateSpeedUI()
updateFlyUI()
applySpeed()

print("✅ Sistema de Velocidad y Vuelo CORREGIDO")
print("⚡ Velocidad: " .. currentSpeed)
print("✈️ Vuelo: Usa joystick normal + Espacio/Shift")
