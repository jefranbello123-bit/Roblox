-- BOOM SPEED MOBILE (corregido)
-- Usa BodyVelocity para velocidades altas y estableces la UI en PlayerGui.
-- Soporta burbuja movible, menú desplegable y ajustes instantáneos.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Settings
local speedEnabled = false
local normalSpeed = 16
local currentSpeed = 100 -- velocidad inicial
local bv -- BodyVelocity
local bvParent = nil
local heartbeatConn

-- ==== UI ====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BoomSpeedMenu"
screenGui.Parent = playerGui

-- Botón principal (burbuja móvil)
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 70, 0, 70)
mainButton.Position = UDim2.new(0.5, -35, 0.1, 0)  -- centrado arriba por defecto
mainButton.AnchorPoint = Vector2.new(0.5, 0)
mainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
mainButton.Text = "⚡"
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.TextSize = 30
mainButton.Font = Enum.Font.GothamBold
mainButton.BorderSizePixel = 0
mainButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = mainButton

-- Marco del menú (inicialmente igual que el botón)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 70, 0, 70)
mainFrame.Position = mainButton.Position
mainFrame.AnchorPoint = mainButton.AnchorPoint
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = mainFrame

-- Contenido (oculto al inicio)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
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

local menuAbierto = false

-- ==== Funciones de velocidad (BodyVelocity) ====
local function ensureBV(hrp)
    if not hrp then return end
    if not bv or bv.Parent ~= hrp then
        if bv then pcall(function() bv:Destroy() end) end
        bv = Instance.new("BodyVelocity")
        bv.Name = "BoomSpeedBV"
        bv.MaxForce = Vector3.new(math.huge, 0, math.huge) -- solo XZ
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
    end
end

local function removeBV()
    if bv then
        pcall(function() bv:Destroy() end)
        bv = nil
    end
end

-- Actualiza el BV según MoveDirection y cámara (se corre en Heartbeat)
local function updateVelocity()
    if not speedEnabled then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    local cam = workspace.CurrentCamera
    if not hrp or not humanoid or not cam then return end

    ensureBV(hrp)

    local md = humanoid.MoveDirection
    if md.Magnitude > 0.01 then
        local camCF = cam.CFrame
        local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
        if forward.Magnitude == 0 then forward = Vector3.new(0,0,-1) end
        forward = forward.Unit
        local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

        local target = (forward * md.Z + right * md.X) * currentSpeed
        -- Mantener componente Y actual (gravedad/jump) para no anular saltos
        bv.Velocity = Vector3.new(target.X, hrp.Velocity.Y, target.Z)
    else
        -- Si no hay input, frenar horizontalmente manteniendo Y
        bv.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
    end
end

-- Llamada segura para aplicar velocidad cuando se cambia currentSpeed o toggles
local function applySpeedInstant()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if speedEnabled then
        -- mantenemos WalkSpeed normal para animaciones; la velocidad real viene del BV
        if humanoid then humanoid.WalkSpeed = normalSpeed end
        ensureBV(hrp)
        -- actualizamos BV inmediatamente:
        updateVelocity()
    else
        -- desactivar: quitar BV y restaurar WalkSpeed normal
        removeBV()
        if humanoid then humanoid.WalkSpeed = normalSpeed end
    end
end

-- ==== UI comportamiento ====
local function abrirMenu()
    menuAbierto = true
    mainButton.Visible = false

    local startSize = mainFrame.Size
    local startPos = mainFrame.Position

    -- target size/pos relative al botón actual
    local targetW, targetH = 250, 170
    local btnPixelX = mainButton.AbsolutePosition.X
    local btnPixelY = mainButton.AbsolutePosition.Y
    -- center the expanded frame around the button X
    local targetXOffset = mainButton.AbsoluteSize.X * 0.5 - targetW * 0.5
    local targetPos = UDim2.new(0, mainButton.AbsolutePosition.X - (targetW/2) + (mainButton.AbsoluteSize.X/2), 0, mainButton.AbsolutePosition.Y + mainButton.AbsoluteSize.Y + 8)

    -- simple animation (10 frames)
    for i = 1, 10 do
        local t = i / 10
        mainFrame.Size = UDim2.new(0, 70 + (targetW - 70) * t, 0, 70 + (targetH - 70) * t)
        mainFrame.Position = UDim2.new(0, (targetPos.X.Offset), 0, (targetPos.Y.Offset))
        RunService.Heartbeat:Wait()
    end

    -- mostrar contenido
    title.Visible = true
    speedButton.Visible = true
    speedLabel.Visible = true
    speedUpButton.Visible = true
    speedDownButton.Visible = true
end

local function cerrarMenu()
    title.Visible = false
    speedButton.Visible = false
    speedLabel.Visible = false
    speedUpButton.Visible = false
    speedDownButton.Visible = false

    -- contraer al tamaño del botón (sin animar la posición de forma compleja)
    for i = 10, 1, -1 do
        local t = i / 10
        mainFrame.Size = UDim2.new(0, 70 + (180 * t), 0, 70 + (100 * t))
        RunService.Heartbeat:Wait()
    end

    mainFrame.Size = UDim2.new(0, 70, 0, 70)
    -- reposicionar al botón actual (por si lo moviste)
    mainFrame.Position = mainButton.Position
    menuAbierto = false
    mainButton.Visible = true
end

local function toggleMenu()
    if menuAbierto then
        cerrarMenu()
    else
        abrirMenu()
    end
end

-- ==== Dragging (hacer burbuja movible) ====
local dragging = false
local dragInput, dragStart, startPos

mainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainButton.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        -- mantener marco oculto en la misma posición del botón
        if not menuAbierto then
            mainFrame.Position = mainButton.Position
        end
    end
end)

-- ==== Conexiones UI ====
mainButton.MouseButton1Click:Connect(function()
    toggleMenu()
end)

speedButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        speedButton.Text = "ON"
        speedButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    else
        speedButton.Text = "OFF"
        speedButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
    applySpeedInstant()
end)

speedUpButton.MouseButton1Click:Connect(function()
    currentSpeed = currentSpeed + 50
    speedLabel.Text = "Vel: " .. currentSpeed
    applySpeedInstant()
end)

speedDownButton.MouseButton1Click:Connect(function()
    currentSpeed = math.max(currentSpeed - 50, 1)
    speedLabel.Text = "Vel: " .. currentSpeed
    applySpeedInstant()
end)

-- ==== Heartbeat loop para actualizar BV continuamente ====
heartbeatConn = RunService.Heartbeat:Connect(function()
    if speedEnabled then
        updateVelocity()
    end
end)

-- ==== Restore / Character handlers ====
player.CharacterAdded:Connect(function(char)
    -- espera HRP
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    -- si está activo, aseguramos BV
    if speedEnabled and hrp then
        ensureBV(hrp)
    else
        removeBV()
    end
end)

-- al iniciar
if player.Character then
    if speedEnabled then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        ensureBV(hrp)
    end
end

print("🚀 BOOM SPEED corregido cargado!")
print("⚡ Velocidad inicial: " .. currentSpeed)
