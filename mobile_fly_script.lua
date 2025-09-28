local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

-- ===== CONFIGURACIÓN =====
-- Velocidad
local speedEnabled = false
local normalSpeed = 16
local currentSpeed = 50
local minSpeed = 16
local maxSpeed = 100
local speedIncrement = 10

-- Vuelo
local flyEnabled = false
local flySpeed = 50
local minFlySpeed = 10
local maxFlySpeed = 100
local flyIncrement = 10

-- Variables de vuelo (modernas)
local linearVelocity = nil
local alignOrientation = nil
local attachment0 = nil
local attachment1 = nil
local verticalInput = 0 -- -1 para bajar, 0 para neutro, 1 para subir

-- ===== CREACIÓN DE LA INTERFAZ DE USUARIO (UI) =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedFlyMenu"
screenGui.Parent = player:WaitForChild("PlayerGui") -- Es mejor práctica ponerlo en PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 280)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = "⚡ VELOCIDAD + ✈️ VUELO (Corregido)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- ===== SECCIÓN DE VELOCIDAD =====
local speedSection = Instance.new("TextLabel");speedSection.Size = UDim2.new(0.9, 0, 0, 20);speedSection.Position = UDim2.new(0.05, 0, 0.15, 0);speedSection.BackgroundTransparency = 1;speedSection.Text = "🏃 VELOCIDAD:";speedSection.TextColor3 = Color3.fromRGB(200, 200, 200);speedSection.TextSize = 12;speedSection.TextXAlignment = Enum.TextXAlignment.Left;speedSection.Parent = mainFrame
local speedButton = Instance.new("TextButton");speedButton.Size = UDim2.new(0.9, 0, 0, 35);speedButton.Position = UDim2.new(0.05, 0, 0.22, 0);speedButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60);speedButton.Text = "🚫 VELOCIDAD NORMAL";speedButton.TextColor3 = Color3.fromRGB(255, 255, 255);speedButton.TextSize = 12;speedButton.Font = Enum.Font.GothamBold;speedButton.Parent = mainFrame
local speedLabel = Instance.new("TextLabel");speedLabel.Size = UDim2.new(0.9, 0, 0, 25);speedLabel.Position = UDim2.new(0.05, 0, 0.32, 0);speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60);speedLabel.Text = "Velocidad Actual: " .. currentSpeed;speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255);speedLabel.TextSize = 11;speedLabel.Parent = mainFrame
local speedUpButton = Instance.new("TextButton");speedUpButton.Size = UDim2.new(0.4, 0, 0, 25);speedUpButton.Position = UDim2.new(0.05, 0, 0.39, 0);speedUpButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60);speedUpButton.Text = "⬆️ AUMENTAR";speedUpButton.TextColor3 = Color3.fromRGB(255, 255, 255);speedUpButton.TextSize = 10;speedUpButton.Parent = mainFrame
local speedDownButton = Instance.new("TextButton");speedDownButton.Size = UDim2.new(0.4, 0, 0, 25);speedDownButton.Position = UDim2.new(0.55, 0, 0.39, 0);speedDownButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60);speedDownButton.Text = "⬇️ DISMINUIR";speedDownButton.TextColor3 = Color3.fromRGB(255, 255, 255);speedDownButton.TextSize = 10;speedDownButton.Parent = mainFrame
-- ===== SECCIÓN DE VUELO =====
local flySection = Instance.new("TextLabel");flySection.Size = UDim2.new(0.9, 0, 0, 20);flySection.Position = UDim2.new(0.05, 0, 0.48, 0);flySection.BackgroundTransparency = 1;flySection.Text = "✈️ VUELO:";flySection.TextColor3 = Color3.fromRGB(200, 200, 200);flySection.TextSize = 12;flySection.TextXAlignment = Enum.TextXAlignment.Left;flySection.Parent = mainFrame
local flyButton = Instance.new("TextButton");flyButton.Size = UDim2.new(0.9, 0, 0, 35);flyButton.Position = UDim2.new(0.05, 0, 0.55, 0);flyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60);flyButton.Text = "🚫 VUELO DESACTIVADO";flyButton.TextColor3 = Color3.fromRGB(255, 255, 255);flyButton.TextSize = 12;flyButton.Font = Enum.Font.GothamBold;flyButton.Parent = mainFrame
local flyLabel = Instance.new("TextLabel");flyLabel.Size = UDim2.new(0.9, 0, 0, 25);flyLabel.Position = UDim2.new(0.05, 0, 0.65, 0);flyLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60);flyLabel.Text = "Velocidad Vuelo: " .. flySpeed;flyLabel.TextColor3 = Color3.fromRGB(255, 255, 255);flyLabel.TextSize = 11;flyLabel.Parent = mainFrame
local flySpeedUpButton = Instance.new("TextButton");flySpeedUpButton.Size = UDim2.new(0.4, 0, 0, 25);flySpeedUpButton.Position = UDim2.new(0.05, 0, 0.72, 0);flySpeedUpButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60);flySpeedUpButton.Text = "⬆️ + VELOCIDAD";flySpeedUpButton.TextColor3 = Color3.fromRGB(255, 255, 255);flySpeedUpButton.TextSize = 10;flySpeedUpButton.Parent = mainFrame
local flySpeedDownButton = Instance.new("TextButton");flySpeedDownButton.Size = UDim2.new(0.4, 0, 0, 25);flySpeedDownButton.Position = UDim2.new(0.55, 0, 0.72, 0);flySpeedDownButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60);flySpeedDownButton.Text = "⬇️ - VELOCIDAD";flySpeedDownButton.TextColor3 = Color3.fromRGB(255, 255, 255);flySpeedDownButton.TextSize = 10;flySpeedDownButton.Parent = mainFrame
-- Instrucciones
local instructions = Instance.new("TextLabel");instructions.Size = UDim2.new(0.9, 0, 0, 40);instructions.Position = UDim2.new(0.05, 0, 0.87, 0);instructions.BackgroundTransparency = 1;instructions.Text = "PC: Espacio (subir), Shift (bajar)\nMóvil: Botón Salto (subir), Botón en pantalla (bajar)";instructions.TextColor3 = Color3.fromRGB(200, 200, 200);instructions.TextSize = 10;instructions.TextWrapped = true;instructions.Parent = mainFrame

-- ===== FUNCIONES DE VELOCIDAD (CORREGIDAS) =====
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
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = speedEnabled and currentSpeed or normalSpeed
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

-- ===== FUNCIONES DE VUELO (REESCRITAS Y CORREGIDAS) =====
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
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	
	local rootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid

	-- Crear attachments necesarios para los movers
	attachment0 = Instance.new("Attachment", rootPart)
	attachment1 = Instance.new("Attachment", rootPart)
	
	-- Crear LinearVelocity para el movimiento
	linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment0
	linearVelocity.MaxForce = math.huge
	linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.Parent = rootPart

	-- Crear AlignOrientation para la estabilidad
	alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = attachment1
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.MaxTorque = 100000
	alignOrientation.Responsiveness = 200 -- Muy rígido para mantener al personaje erguido
	alignOrientation.Parent = rootPart
	
	humanoid.PlatformStand = true
	flyEnabled = true
	updateFlyUI()
end

local function disableFly()
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then humanoid.PlatformStand = false end
	end

	-- Destruir los movers y attachments para limpiar
	if linearVelocity then linearVelocity:Destroy() linearVelocity = nil end
	if alignOrientation then alignOrientation:Destroy() alignOrientation = nil end
	if attachment0 then attachment0:Destroy() attachment0 = nil end
	if attachment1 then attachment1:Destroy() attachment1 = nil end
	
	flyEnabled = false
	updateFlyUI()
end

local function toggleFly()
	if flyEnabled then
		disableFly()
	else
		enableFly()
	end
end

local function increaseFlySpeed() flySpeed = math.min(flySpeed + flyIncrement, maxFlySpeed) updateFlyUI() end
local function decreaseFlySpeed() flySpeed = math.max(flySpeed - flyIncrement, minFlySpeed) updateFlyUI() end

-- ===== MANEJO DE CONTROLES CON CONTEXTACTIONSERVICE =====
local function handleFlyInput(actionName, inputState, inputObject)
    if actionName == "FlyUpAction" then
        verticalInput = (inputState == Enum.UserInputState.Begin) and 1 or 0
    elseif actionName == "FlyDownAction" then
        verticalInput = (inputState == Enum.UserInputState.Begin) and -1 or 0
    end
    return Enum.ContextActionResult.Sink
end

-- Vincular acciones: Esto crea los botones en móvil automáticamente
ContextActionService:BindAction("FlyUpAction", handleFlyInput, true, Enum.PlayerActions.CharacterJump)
ContextActionService:BindAction("FlyDownAction", handleFlyInput, true, Enum.KeyCode.LeftShift)

-- Personalizar el botón móvil que se crea
local downButton = ContextActionService:GetButton("FlyDownAction")
if downButton then
	downButton.Size = UDim2.new(0, 80, 0, 80)
	downButton.Position = UDim2.new(1, -100, 1, -180)
	downButton.Image = "rbxassetid://9949214325" -- Un ícono de flecha hacia abajo
end


-- ===== LOOP PRINCIPAL DE VUELO (CORREGIDO) =====
RunService.Heartbeat:Connect(function(deltaTime)
    if flyEnabled and linearVelocity and alignOrientation then
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end

        local moveDirection = humanoid.MoveDirection
        local cameraCFrame = workspace.CurrentCamera.CFrame

        local horizontalVelocity = cameraCFrame:VectorToWorldSpace(Vector3.new(moveDirection.X, 0, moveDirection.Z)) * flySpeed
        local verticalVelocity = Vector3.new(0, verticalInput * flySpeed, 0)

        linearVelocity.VectorVelocity = Vector3.new(horizontalVelocity.X, verticalVelocity.Y, horizontalVelocity.Z)

        if moveDirection.Magnitude > 0.1 then
            alignOrientation.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(horizontalVelocity.X, 0, horizontalVelocity.Z))
        else
            alignOrientation.CFrame = CFrame.new(rootPart.Position, rootPart.Position + cameraCFrame.LookVector)
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
	-- Esperar a que el personaje cargue completamente
	character:WaitForChild("Humanoid")
	character:WaitForChild("HumanoidRootPart")
	
	applySpeed()
	
	if flyEnabled then
		disableFly()
	end
end)

-- Aplicar configuración inicial
updateSpeedUI()
updateFlyUI()
applySpeed()

print("✅ Sistema de Velocidad y Vuelo (Versión FINAL) Cargado")
