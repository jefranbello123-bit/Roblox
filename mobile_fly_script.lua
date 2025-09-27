-- Script de Velocidad para Móvil - Menú Simple
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local speedEnabled = false
local normalSpeed = 16
local fastSpeed = 50

-- Crear menú simple
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedMenu"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 120)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = "🏃 VELOCIDAD"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0.9, 0, 0, 40)
speedButton.Position = UDim2.new(0.05, 0, 0.3, 0)
speedButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
speedButton.Text = "🚫 VELOCIDAD NORMAL"
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.TextSize = 12
speedButton.Font = Enum.Font.GothamBold
speedButton.Parent = mainFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 30)
speedLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedLabel.Text = "Velocidad: " .. normalSpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 12
speedLabel.Parent = mainFrame

-- Función para cambiar velocidad
local function toggleSpeed()
    if speedEnabled then
        -- Desactivar velocidad rápida
        speedEnabled = false
        speedButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        speedButton.Text = "🚫 VELOCIDAD NORMAL"
        speedLabel.Text = "Velocidad: " .. normalSpeed
    else
        -- Activar velocidad rápida
        speedEnabled = true
        speedButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        speedButton.Text = "⚡ VELOCIDAD RÁPIDA"
        speedLabel.Text = "Velocidad: " .. fastSpeed
    end
end

-- Conexión del botón
speedButton.MouseButton1Click:Connect(toggleSpeed)

-- Función para aplicar la velocidad
local function applySpeed()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            if speedEnabled then
                humanoid.WalkSpeed = fastSpeed
            else
                humanoid.WalkSpeed = normalSpeed
            end
        end
    end
end

-- Aplicar velocidad cuando el personaje spawnée
player.CharacterAdded:Connect(function(character)
    wait(1) -- Esperar a que el personaje cargue
    applySpeed()
end)

-- Aplicar velocidad inicial
if player.Character then
    applySpeed()
end

-- Loop para mantener la velocidad aplicada
while true do
    applySpeed()
    wait(0.1)
end
