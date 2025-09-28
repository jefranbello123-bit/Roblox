-- 🚀 BoomSpeed - Botón que se expande a menú
-- ✅ Funciona perfecto en Delta

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local plr = Players.LocalPlayer

-- Configuración
local speedEnabled = false
local walkSpeed = 100  -- Velocidad inicial alta

-- Crear GUI
local gui = Instance.new("ScreenGui")
gui.Name = "BoomSpeedMenu"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

-- 🔘 BOTÓN PRINCIPAL - CENTRADO Y VISIBLE
local mainBtn = Instance.new("TextButton")
mainBtn.Size = UDim2.new(0, 70, 0, 70)
mainBtn.Position = UDim2.new(0.5, -35, 0.1, 0)  -- Centrado arriba
mainBtn.Text = "🚀"
mainBtn.TextSize = 30
mainBtn.Font = Enum.Font.GothamBold
mainBtn.TextColor3 = Color3.new(1,1,1)
mainBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
mainBtn.Parent = gui

-- Hacerlo redondo
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = mainBtn

-- 📋 MENÚ QUE SE EXPANDE
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 70, 0, 70)  -- Tamaño inicial igual al botón
menuFrame.Position = UDim2.new(0.5, -35, 0.1, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
menuFrame.BackgroundTransparency = 0.1
menuFrame.BorderSizePixel = 0
menuFrame.ClipsDescendants = true  -- Para animación suave
menuFrame.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 15)
menuCorner.Parent = menuFrame

-- 📝 CONTENIDO DEL MENÚ (oculto inicialmente)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "BOOM SPEED"
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Visible = false
title.Parent = menuFrame

-- Botón Speed
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.9, 0, 0, 40)
speedBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
speedBtn.Text = "OFF"
speedBtn.TextSize = 16
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextColor3 = Color3.new(1,1,1)
speedBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
speedBtn.Visible = false
speedBtn.Parent = menuFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedBtn

-- Velocidad actual
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 25)
speedLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
speedLabel.Text = "Speed: "..walkSpeed
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 0.8
speedLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
speedLabel.Visible = false
speedLabel.Parent = menuFrame

local labelCorner = Instance.new("UICorner")
labelCorner.CornerRadius = UDim.new(0, 8)
labelCorner.Parent = speedLabel

-- Botones de control
local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Size = UDim2.new(0.4, 0, 0, 30)
speedUpBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
speedUpBtn.Text = "⬆️"
speedUpBtn.TextSize = 18
speedUpBtn.Font = Enum.Font.GothamBold
speedUpBtn.TextColor3 = Color3.new(1,1,1)
speedUpBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
speedUpBtn.Visible = false
speedUpBtn.Parent = menuFrame

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 8)
upCorner.Parent = speedUpBtn

local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Size = UDim2.new(0.4, 0, 0, 30)
speedDownBtn.Position = UDim2.new(0.55, 0, 0.7, 0)
speedDownBtn.Text = "⬇️"
speedDownBtn.TextSize = 18
speedDownBtn.Font = Enum.Font.GothamBold
speedDownBtn.TextColor3 = Color3.new(1,1,1)
speedDownBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
speedDownBtn.Visible = false
speedDownBtn.Parent = menuFrame

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 8)
downCorner.Parent = speedDownBtn

-- Estado del menú
local menuAbierto = false

-- 🔧 FUNCIONES
local function aplicarVelocidad()
    local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
    if humanoid then
        if speedEnabled then
            humanoid.WalkSpeed = walkSpeed
        else
            humanoid.WalkSpeed = 16
        end
    end
end

local function toggleSpeed()
    speedEnabled = not speedEnabled
    if speedEnabled then
        speedBtn.Text = "ON"
        speedBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    else
        speedBtn.Text = "OFF"
        speedBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
    aplicarVelocidad()
end

local function abrirMenu()
    menuAbierto = true
    
    -- Animación de expansión
    for i = 1, 10 do
        menuFrame.Size = UDim2.new(0, 70 + (i * 15), 0, 70 + (i * 10))
        menuFrame.Position = UDim2.new(0.5, -35 - (i * 7.5), 0.1, 0)
        wait(0.01)
    end
    
    -- Mostrar contenido
    title.Visible = true
    speedBtn.Visible = true
    speedLabel.Visible = true
    speedUpBtn.Visible = true
    speedDownBtn.Visible = true
    
    -- Ocultar botón principal
    mainBtn.Visible = false
end

local function cerrarMenu()
    -- Ocultar contenido primero
    title.Visible = false
    speedBtn.Visible = false
    speedLabel.Visible = false
    speedUpBtn.Visible = false
    speedDownBtn.Visible = false
    
    -- Animación de contracción
    for i = 10, 1, -1 do
        menuFrame.Size = UDim2.new(0, 70 + (i * 15), 0, 70 + (i * 10))
        menuFrame.Position = UDim2.new(0.5, -35 - (i * 7.5), 0.1, 0)
        wait(0.01)
    end
    
    menuFrame.Size = UDim2.new(0, 70, 0, 70)
    menuFrame.Position = UDim2.new(0.5, -35, 0.1, 0)
    
    menuAbierto = false
    mainBtn.Visible = true
end

local function toggleMenu()
    if menuAbierto then
        cerrarMenu()
    else
        abrirMenu()
    end
end

-- 🎯 EVENTOS
mainBtn.MouseButton1Click:Connect(toggleMenu)

speedBtn.MouseButton1Click:Connect(toggleSpeed)

speedUpBtn.MouseButton1Click:Connect(function()
    walkSpeed = walkSpeed + 50  -- Incrementos grandes
    speedLabel.Text = "Speed: "..walkSpeed
    aplicarVelocidad()
end)

speedDownBtn.MouseButton1Click:Connect(function()
    walkSpeed = math.max(walkSpeed - 50, 50)  -- Mínimo 50
    speedLabel.Text = "Speed: "..walkSpeed
    aplicarVelocidad()
end)

-- 🔄 Reset al cambiar personaje
plr.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    aplicarVelocidad()
end)

-- 🎮 Hacer el menú arrastrable
local dragging = false
local dragInput, dragStart, startPos

menuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = menuFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

menuFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        menuFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        mainBtn.Position = menuFrame.Position  -- Mover también el botón
    end
end)

print("🎯 BOOM SPEED cargado!")
print("💥 Toca el botón azul para abrir el menú")
print("⚡ Velocidad inicial: " .. walkSpeed)
