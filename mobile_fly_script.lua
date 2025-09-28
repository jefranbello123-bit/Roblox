-- 🚀 Velocidad Ajustable para Móvil - Basado en tu script que funciona
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local speedEnabled = false
local normalSpeed = 16
local currentSpeed = 100  -- Velocidad inicial más alta

-- Crear menú mejorado
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BoomSpeedMenu"
screenGui.Parent = CoreGui

-- Botón principal que se expande
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 70, 0, 70)
mainButton.Position = UDim2.new(0.5, -35, 0.1, 0)  -- Centrado arriba
mainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
mainButton.Text = "⚡"
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.TextSize = 30
mainButton.Font = Enum.Font.GothamBold
mainButton.BorderSizePixel = 0
mainButton.Parent = screenGui

-- Hacerlo redondo
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = mainButton

-- Marco del menú (inicialmente pequeño)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 70, 0, 70)  -- Mismo tamaño que el botón
mainFrame.Position = UDim2.new(0.5, -35, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true  -- Para ocultar contenido cuando esté cerrado
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = mainFrame

-- Contenido del menú (oculto inicialmente)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = "BOOM SPEED"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Visible = false
title.Parent = mainFrame

local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0.9, 0, 0, 35)
speedButton.Position = UDim2.new(0.05, 0, 0.3, 0)
speedButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
speedButton.Text = "OFF"
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.TextSize = 14
speedButton.Font = Enum.Font.GothamBold
speedButton.Visible = false
speedButton.Parent = mainFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 25)
speedLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedLabel.Text = "Vel: " .. currentSpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 12
speedLabel.Visible = false
speedLabel.Parent = mainFrame

-- Botones para ajustar velocidad
local speedUpButton = Instance.new("TextButton")
speedUpButton.Size = UDim2.new(0.4, 0, 0, 25)
speedUpButton.Position = UDim2.new(0.05, 0, 0.85, 0)
speedUpButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
speedUpButton.Text = "+50"
speedUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpButton.TextSize = 12
speedUpButton.Visible = false
speedUpButton.Parent = mainFrame

local speedDownButton = Instance.new("TextButton")
speedDownButton.Size = UDim2.new(0.4, 0, 0, 25)
speedDownButton.Position = UDim2.new(0.55, 0, 0.85, 0)
speedDownButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
speedDownButton.Text = "-50"
speedDownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownButton.TextSize = 12
speedDownButton.Visible = false
speedDownButton.Parent = mainFrame

-- Estado del menú
local menuAbierto = false

-- Función para aplicar velocidad (la misma que funcionó)
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

-- Función para alternar velocidad
local function toggleSpeed()
    speedEnabled = not speedEnabled
    if speedEnabled then
        speedButton.Text = "ON"
        speedButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    else
        speedButton.Text = "OFF"
        speedButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
    applySpeed()
end

-- Función para abrir el menú
local function abrirMenu()
    menuAbierto = true
    
    -- Ocultar botón principal
    mainButton.Visible = false
    
    -- Expandir el marco con animación simple
    for i = 1, 10 do
        mainFrame.Size = UDim2.new(0, 70 + (i * 15), 0, 70 + (i * 8))
        mainFrame.Position = UDim2.new(0.5, -35 - (i * 7.5), 0.1, 0)
        wait(0.01)
    end
    
    -- Mostrar contenido
    title.Visible = true
    speedButton.Visible = true
    speedLabel.Visible = true
    speedUpButton.Visible = true
    speedDownButton.Visible = true
end

-- Función para cerrar el menú
local function cerrarMenu()
    -- Ocultar contenido
    title.Visible = false
    speedButton.Visible = false
    speedLabel.Visible = false
    speedUpButton.Visible = false
    speedDownButton.Visible = false
    
    -- Contraer el marco
    for i = 10, 1, -1 do
        mainFrame.Size = UDim2.new(0, 70 + (i * 15), 0, 70 + (i * 8))
        mainFrame.Position = UDim2.new(0.5, -35 - (i * 7.5), 0.1, 0)
        wait(0.01)
    end
    
    -- Volver al tamaño original
    mainFrame.Size = UDim2.new(0, 70, 0, 70)
    mainFrame.Position = UDim2.new(0.5, -35, 0.1, 0)
    
    menuAbierto = false
    mainButton.Visible = true
end

-- Función para alternar menú
local function toggleMenu()
    if menuAbierto then
        cerrarMenu()
    else
        abrirMenu()
    end
end

-- Conexión de botones
mainButton.MouseButton1Click:Connect(toggleMenu)
speedButton.MouseButton1Click:Connect(toggleSpeed)

speedUpButton.MouseButton1Click:Connect(function()
    currentSpeed = currentSpeed + 50  -- Incrementos grandes
    speedLabel.Text = "Vel: " .. currentSpeed
    applySpeed()
end)

speedDownButton.MouseButton1Click:Connect(function()
    currentSpeed = math.max(currentSpeed - 50, 50)  -- Mínimo 50
    speedLabel.Text = "Vel: " .. currentSpeed
    applySpeed()
end)

-- Aplicar velocidad cuando el personaje spawnée (igual que antes)
player.CharacterAdded:Connect(function(character)
    wait(1)
    applySpeed()
end)

-- Aplicar velocidad inicial
if player.Character then
    applySpeed()
end

-- Loop para mantener la velocidad (igual que antes)
while true do
    applySpeed()
    wait(0.1)
end

print("🚀 BOOM SPEED cargado!")
print("⚡ Velocidad inicial: " .. currentSpeed)
print("💥 Toca el botón azul para expandir el menú")
