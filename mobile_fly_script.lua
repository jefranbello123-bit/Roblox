-- Fly Script para Móvil con Menú GUI
-- Guardar como: mobile_fly_script.lua

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
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

-- Crear la interfaz GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyMobileMenu"
screenGui.Parent = CoreGui

-- Marco principal del menú
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 250)
mainFrame.Position = UDim2.new(0, 10, 0.5, -125)
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
title.Text = "🏃‍♂️ MENÚ FLY v1.0"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Botón Activar/Desactivar Fly
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.9, 0, 0, 40)
flyButton.Position = UDim2.new(0.05, 0, 0.15, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
flyButton.Text = "🚫 FLY DESACTIVADO"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextSize = 14
flyButton.Font = Enum.Font.GothamBold
flyButton.Parent = mainFrame

-- Display de velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 30)
speedLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedLabel.Text = "Velocidad: " .. flySpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 14
speedLabel.Parent = mainFrame

-- Botón aumentar velocidad
local speedUpButton = Instance.new("TextButton")
speedUpButton.Size = UDim2.new(0.9, 0, 0, 30)
speedUpButton.Position = UDim2.new(0.05, 0, 0.5, 0)
speedUpButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
speedUpButton.Text = "⬆️ AUMENTAR VELOCIDAD"
speedUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpButton.TextSize = 12
speedUpButton.Parent = mainFrame

-- Botón disminuir velocidad
local speedDownButton = Instance.new("TextButton")
speedDownButton.Size = UDim2.new(0.9, 0, 0, 30)
speedDownButton.Position = UDim2.new(0.05, 0, 0.65, 0)
speedDownButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
speedDownButton.Text = "⬇️ DISMINUIR VELOCIDAD"
speedDownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownButton.TextSize = 12
speedDownButton.Parent = mainFrame

-- Instrucciones
local instructions = Instance.new("TextLabel")
instructions.Size = UDim2.new(0.9, 0, 0, 50)
instructions.Position = UDim2.new(0.05, 0, 0.8, 0)
instructions.BackgroundTransparency = 1
instructions.Text = "Usa el joystick virtual para moverte mientras vuelas"
instructions.TextColor3 = Color3.fromRGB(200, 200, 200)
instructions.TextSize = 10
instructions.TextWrapped = true
instructions.Parent = mainFrame

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
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Parent = rootPart
    
    -- Crear BodyGyro para estabilidad
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
    bodyGyro.P = 1000
    bodyGyro.D = 50
    bodyGyro.Parent = rootPart
    
    humanoid.PlatformStand = true
    updateUI()
end

-- Función para desactivar el vuelo
local function disableFly()
    if not flyEnabled then return end
    
    flyEnabled = false
    
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

-- Detectar cuando el personaje muere
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    disableFly() -- Desactivar fly al respawnear
    wait(1) -- Esperar a que el personaje cargue
    getCharacter()
end)

-- Loop principal de vuelo
RunService.Heartbeat:Connect(function()
    if flyEnabled and bodyVelocity and bodyGyro and getCharacter() then
        -- Obtener input del joystick virtual (movimiento táctil)
        local touchEnabled = false
        local moveDirection = Vector3.new(0, 0, 0)
        
        -- Simular controles básicos (puedes mejorar esto)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + Vector3.new(0, 0, -1)
            touchEnabled = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection + Vector3.new(0, 0, 1)
            touchEnabled = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection + Vector3.new(-1, 0, 0)
            touchEnabled = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Vector3.new(1, 0, 0)
            touchEnabled = true
        end
        
        -- Control de altura (Space/Shift como alternativas táctiles)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
            touchEnabled = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection + Vector3.new(0, -1, 0)
            touchEnabled = true
        end
        
        if touchEnabled then
            -- Aplicar movimiento
            local camera = workspace.CurrentCamera
            if camera then
                local cf = camera.CFrame
                moveDirection = cf:VectorToWorldSpace(moveDirection)
                bodyVelocity.Velocity = moveDirection * flySpeed
                bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + cf.LookVector)
            end
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Inicializar UI
updateUI()

print("✅ Menú Fly para móvil cargado correctamente")
print("📱 Usa los botones en pantalla para controlar el fly")


