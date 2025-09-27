-- Fly Script para Móvil con Detección de Joystick Virtual
-- Guardar como: mobile_fly_fixed.lua

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variables de vuelo
local flyEnabled = false
local flySpeed = 50
local bodyVelocity = nil
local bodyGyro = nil
local character = nil
local humanoid = nil
local rootPart = nil

-- Variables para control táctil
local touchStartPos = nil
local touchCurrentPos = nil
local touchActive = false
local moveDirection = Vector3.new(0, 0, 0)

-- Crear la interfaz GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyMobileMenu"
screenGui.Parent = CoreGui

-- Marco principal del menú
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 280)
mainFrame.Position = UDim2.new(0, 10, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = "✈️ MENÚ FLY v2.0"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Botón Activar/Desactivar Fly
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.9, 0, 0, 45)
flyButton.Position = UDim2.new(0.05, 0, 0.15, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
flyButton.Text = "🚫 FLY DESACTIVADO"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
flyButton.Font = Enum.Font.GothamBold
flyButton.Parent = mainFrame

-- Display de velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 35)
speedLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedLabel.Text = "Velocidad: " .. flySpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 14
speedLabel.Parent = mainFrame

-- Botón aumentar velocidad
local speedUpButton = Instance.new("TextButton")
speedUpButton.Size = UDim2.new(0.9, 0, 0, 35)
speedUpButton.Position = UDim2.new(0.05, 0, 0.5, 0)
speedUpButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
speedUpButton.Text = "⬆️ AUMENTAR VELOCIDAD"
speedUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpButton.TextSize = 12
speedUpButton.Parent = mainFrame

-- Botón disminuir velocidad
local speedDownButton = Instance.new("TextButton")
speedDownButton.Size = UDim2.new(0.9, 0, 0, 35)
speedDownButton.Position = UDim2.new(0.05, 0, 0.65, 0)
speedDownButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
speedDownButton.Text = "⬇️ DISMINUIR VELOCIDAD"
speedDownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownButton.TextSize = 12
speedDownButton.Parent = mainFrame

-- Botones de altura
local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0.4, 0, 0, 35)
upButton.Position = UDim2.new(0.05, 0, 0.8, 0)
upButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
upButton.Text = "⬆️ SUBIR"
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.TextSize = 12
upButton.Parent = mainFrame

local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0.4, 0, 0, 35)
downButton.Position = UDim2.new(0.55, 0, 0.8, 0)
downButton.BackgroundColor3 = Color3.fromRGB(200, 100, 60)
downButton.Text = "⬇️ BAJAR"
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.TextSize = 12
downButton.Parent = mainFrame

-- Función para actualizar la interfaz
local function updateUI()
    if flyEnabled then
        flyButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        flyButton.Text = "✈️ FLY ACTIVADO"
    else
        flyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        flyButton.Text = "🚫 FLY DESACTIVADO"
    end
    speedLabel.Text = "Velocidad: " .. flySpeed
end

-- Función para obtener el personaje
local function getCharacter()
    character = player.Character
    if character then
        humanoid = character:FindFirstChild("Humanoid")
        rootPart = character:FindFirstChild("HumanoidRootPart")
        return character and humanoid and rootPart
    end
    return false
end

-- Función para activar el vuelo
local function enableFly()
    if flyEnabled or not getCharacter() then return end
    
    flyEnabled = true
    
    -- Crear BodyVelocity para movimiento
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
    bodyVelocity.Parent = rootPart
    
    -- Crear BodyGyro para estabilidad
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
    bodyGyro.P = 1000
    bodyGyro.D = 50
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    humanoid.PlatformStand = true
    updateUI()
end

-- Función para desactivar el vuelo
local function disableFly()
    if not flyEnabled then return end
    
    flyEnabled = false
    moveDirection = Vector3.new(0, 0, 0)
    
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    
    updateUI()
end

-- Función para cambiar velocidad
local function changeSpeed(increase)
    if increase then
        flySpeed = math.min(flySpeed + 10, 100)
    else
        flySpeed = math.max(flySpeed - 10, 10)
    end
    updateUI()
end

-- Conexión de botones
flyButton.MouseButton1Click:Connect(function()
    if flyEnabled then
        disableFly()
    else
        enableFly()
    end
end)

speedUpButton.MouseButton1Click:Connect(function()
    changeSpeed(true)
end)

speedDownButton.MouseButton1Click:Connect(function()
    changeSpeed(false)
end)

-- Variables para control de altura
local verticalInput = 0

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

-- Detectar cuando el personaje muere
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    disableFly()
    wait(2)
    getCharacter()
end)

-- Detectar el joystick virtual de Roblox
local function setupTouchControls()
    -- Intentar encontrar el joystick virtual estándar
    local touchGui = playerGui:FindFirstChild("TouchGui")
    if touchGui then
        local touchControlFrame = touchGui:FindFirstChild("TouchControlFrame")
        if touchControlFrame then
            local thumbstickFrame = touchControlFrame:FindFirstChild("ThumbstickFrame")
            if thumbstickFrame then
                -- Conectar al evento de movimiento del joystick
                thumbstickFrame:GetPropertyChangedSignal("Position"):Connect(function()
                    if flyEnabled then
                        local pos = thumbstickFrame.Position
                        local deadzone = 0.1
                        
                        -- Convertir posición del joystick a dirección de movimiento
                        if pos.Magnitude > deadzone then
                            moveDirection = Vector3.new(pos.X, 0, -pos.Y)
                        else
                            moveDirection = Vector3.new(0, 0, 0)
                        end
                    end
                end)
            end
        end
    end
end

-- Configurar controles táctiles alternativos
local touchInput = nil

UserInputService.TouchStarted:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Detectar toques en la pantalla que no sean en la UI
    local touchPos = input.Position
    local guiInset = game:GetService("GuiService"):GetGuiInset()
    local actualPos = touchPos - guiInset
    
    -- Ignorar toques en el menú
    local menuPos = mainFrame.AbsolutePosition
    local menuSize = mainFrame.AbsoluteSize
    if actualPos.X >= menuPos.X and actualPos.X <= menuPos.X + menuSize.X and
       actualPos.Y >= menuPos.Y and actualPos.Y <= menuPos.Y + menuSize.Y then
        return
    end
    
    touchInput = input
    touchStartPos = actualPos
    touchCurrentPos = actualPos
    touchActive = true
end)

UserInputService.TouchMoved:Connect(function(input, gameProcessed)
    if touchInput == input and touchActive and flyEnabled then
        touchCurrentPos = input.Position - game:GetService("GuiService"):GetGuiInset()
        
        -- Calcular dirección basada en el movimiento táctil
        local delta = touchCurrentPos - touchStartPos
        local maxDelta = 50
        local normalizedDelta = Vector2.new(
            math.clamp(delta.X / maxDelta, -1, 1),
            math.clamp(delta.Y / maxDelta, -1, 1)
        )
        
        moveDirection = Vector3.new(normalizedDelta.X, 0, normalizedDelta.Y)
    end
end)

UserInputService.TouchEnded:Connect(function(input, gameProcessed)
    if touchInput == input then
        touchActive = false
        moveDirection = Vector3.new(0, 0, 0)
        touchInput = nil
    end
end)

-- Loop principal de vuelo mejorado
RunService.Heartbeat:Connect(function()
    if flyEnabled and bodyVelocity and bodyGyro and getCharacter() then
        local finalDirection = moveDirection
        
        -- Añadir control vertical
        if verticalInput ~= 0 then
            finalDirection = finalDirection + Vector3.new(0, verticalInput, 0)
        end
        
        -- Aplicar movimiento si hay dirección
        if finalDirection.Magnitude > 0 then
            local camera = workspace.CurrentCamera
            if camera then
                -- Convertir dirección local a dirección global
                local cameraCFrame = camera.CFrame
                local moveCFrame = CFrame.new(
                    finalDirection.X * flySpeed,
                    finalDirection.Y * flySpeed,
                    finalDirection.Z * flySpeed
                )
                
                local worldMove = cameraCFrame:VectorToWorldSpace(Vector3.new(
                    moveCFrame.X, 
                    moveCFrame.Y, 
                    moveCFrame.Z
                ))
                
                bodyVelocity.Velocity = worldMove
                
                -- Mantener la rotación estable mirando hacia adelante
                bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + cameraCFrame.LookVector)
            end
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Inicializar controles y UI
spawn(function()
    wait(2)
    setupTouchControls()
end)
updateUI()

print("✅ Menú Fly para móvil CORREGIDO cargado correctamente")
print("📱 Ahora debería funcionar con el joystick virtual")
print("🔼 Usa los botones SUBIR/BAJAR para controlar la altura")
