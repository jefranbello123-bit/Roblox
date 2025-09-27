-- Script de Velocidad y Vuelo para Móvil - Versión Mejorada
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

-- Configuración de velocidad
local speedEnabled = false
local normalSpeed = 16
local currentSpeed = 50
local minSpeed = 16
local maxSpeed = 100
local speedIncrement = 10

-- Configuración de vuelo
local flyEnabled = false
local flySpeed = 50
local minFlySpeed = 10
local maxFlySpeed = 100
local flyIncrement = 10

-- Variables de vuelo
local bodyVelocity, bodyGyro, bodyPosition

-- Crear menú principal
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

-- ===== SECCIÓN DE VELOCIDAD =====
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

-- ===== SECCIÓN DE VUELO =====
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

-- Botones de control de altura para vuelo (solo en móvil)
local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0.4, 0, 0, 25)
upButton.Position = UDim2.new(0.05, 0, 0.79, 0)
upButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
upButton.Text = "⬆️ SUBIR"
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.TextSize = 10
upButton.Visible = false  -- Solo visible en móvil
upButton.Parent = mainFrame

local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0.4, 0, 0, 25)
downButton.Position = UDim2.new(0.55, 0, 0.79, 0)
downButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
downButton.Text = "⬇️ BAJAR"
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.TextSize = 10
downButton.Visible = false  -- Solo visible en móvil
downButton.Parent = mainFrame

-- Instrucciones
local instructions = Instance.new("TextLabel")
instructions.Size = UDim2.new(0.9, 0, 0, 40)
instructions.Position = UDim2.new(0.05, 0, 0.87, 0)
instructions.BackgroundTransparency = 1
instructions.Text = "En móvil: Joystick para mover\nEspacio para subir, Shift para bajar"
instructions.TextColor3 = Color3.fromRGB(200, 200, 200)
instructions.TextSize = 9
instructions.TextWrapped = true
instructions.Parent = mainFrame

-- Detectar si es móvil y mostrar controles táctiles
if UserInputService.TouchEnabled then
    upButton.Visible = true
    downButton.Visible = true
    instructions.Text = "Usa joystick para mover\nBotones SUBIR/BAJAR para altura"
end

-- ===== FUNCIONES DE VELOCIDAD =====
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

-- ===== FUNCIONES DE VUELO =====
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

local function enableFly()
    if flyEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    flyEnabled = true
    
    -- Crear componentes de física para el vuelo
    bodyVelocity = Instance.new("BodyVelocity")
    bodyGyro = Instance.new("BodyGyro")
    bodyPosition = Instance.new("BodyPosition")
    
    -- Configurar BodyVelocity para movimiento
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
    bodyVelocity.Parent = rootPart
    
    -- Configurar BodyGyro para estabilidad
    bodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
    bodyGyro.P = 1000
    bodyGyro.D = 50
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    -- Configurar BodyPosition para control de altura
    bodyPosition.Position = rootPart.Position
    bodyPosition.MaxForce = Vector3.new(0, 10000, 0)
    bodyPosition.P = 1000
    bodyPosition.D = 50
    bodyPosition.Parent = rootPart
    
    -- Configurar el humanoid para vuelo
    humanoid.PlatformStand = true
    
    updateFlyUI()
end

local function disableFly()
    if not flyEnabled then return end
    
    flyEnabled = false
    
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            -- Limpiar componentes de física
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
            end
            if bodyGyro then
                bodyGyro:Destroy()
                bodyGyro = nil
            end
            if bodyPosition then
                bodyPosition:Destroy()
                bodyPosition = nil
            end
        end
    end
    
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

-- Variables para control de vuelo
local verticalInput = 0
local moveDirection = Vector3.new(0, 0, 0)

-- Control de altura para móvil
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

-- Control de vuelo para PC
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not flyEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.Space then
        verticalInput = 1
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        verticalInput = -1
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed or not flyEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then
        verticalInput = 0
    end
end)

-- Loop principal de vuelo
RunService.Heartbeat:Connect(function()
    if flyEnabled then
        local character = player.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        -- Obtener dirección de movimiento del joystick virtual o teclado
        local moveVector = Vector3.new(0, 0, 0)
        
        -- Detectar input de teclado (PC)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + Vector3.new(0, 0, -1)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector + Vector3.new(0, 0, 1)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector + Vector3.new(-1, 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + Vector3.new(1, 0, 0)
        end
        
        -- Aplicar movimiento si hay input
        if moveVector.Magnitude > 0 or verticalInput ~= 0 then
            local cameraCFrame = camera.CFrame
            
            -- Convertir dirección local a global
            local worldMove = cameraCFrame:VectorToWorldSpace(moveVector)
            
            -- Aplicar velocidad de vuelo
            local finalVelocity = (worldMove + Vector3.new(0, verticalInput, 0)) * flySpeed
            
            if bodyVelocity then
                bodyVelocity.Velocity = finalVelocity
            end
            
            -- Mantener orientación
            if bodyGyro then
                bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + cameraCFrame.LookVector)
            end
            
            -- Control de altura con BodyPosition
            if bodyPosition then
                bodyPosition.Position = bodyPosition.Position + Vector3.new(0, verticalInput * 0.5, 0)
            end
        else
            -- Detener movimiento si no hay input
            if bodyVelocity then
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end
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
    wait(1) -- Esperar a que el personaje cargue completamente
    
    -- Aplicar velocidad actual
    applySpeed()
    
    -- Desactivar vuelo si estaba activo
    if flyEnabled then
        disableFly()
    end
end)

-- Aplicar configuración inicial
updateSpeedUI()
updateFlyUI()
applySpeed()

print("✅ Sistema de Velocidad y Vuelo Cargado Correctamente")
print("⚡ Velocidad: " .. currentSpeed)
print("✈️ Vuelo: " .. (flyEnabled and "Activado" or "Desactivado"))
