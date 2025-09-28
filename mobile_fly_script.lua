– Script de Velocidad y Vuelo SIMPLE Y FUNCIONAL
local Players = game:GetService(“Players”)
local UserInputService = game:GetService(“UserInputService”)
local RunService = game:GetService(“RunService”)
local CoreGui = game:GetService(“CoreGui”)
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
local bodyVelocity = nil
local bodyGyro = nil

– Variables de control
local W, A, S, D = false, false, false, false
local SPACE, SHIFT = false, false

– Crear GUI
local function createGUI()
– Eliminar GUI existente si existe
local existingGUI = CoreGui:FindFirstChild(“SpeedFlyGUI”)
if existingGUI then
existingGUI:Destroy()
end

```
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedFlyGUI"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 250)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
title.Text = "Speed & Fly Hack"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Botón de velocidad
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0.9, 0, 0, 35)
speedButton.Position = UDim2.new(0.05, 0, 0.15, 0)
speedButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
speedButton.Text = "Speed: OFF"
speedButton.TextColor3 = Color3.new(1, 1, 1)
speedButton.TextScaled = true
speedButton.Font = Enum.Font.SourceSans
speedButton.Parent = frame

-- Label de velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 25)
speedLabel.Position = UDim2.new(0.05, 0, 0.3, 0)
speedLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
speedLabel.Text = "Speed: " .. currentSpeed
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextScaled = true
speedLabel.Parent = frame

-- Botones de velocidad
local speedUp = Instance.new("TextButton")
speedUp.Size = UDim2.new(0.4, 0, 0, 25)
speedUp.Position = UDim2.new(0.05, 0, 0.45, 0)
speedUp.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
speedUp.Text = "Speed +"
speedUp.TextColor3 = Color3.new(1, 1, 1)
speedUp.TextScaled = true
speedUp.Parent = frame

local speedDown = Instance.new("TextButton")
speedDown.Size = UDim2.new(0.4, 0, 0, 25)
speedDown.Position = UDim2.new(0.55, 0, 0.45, 0)
speedDown.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
speedDown.Text = "Speed -"
speedDown.TextColor3 = Color3.new(1, 1, 1)
speedDown.TextScaled = true
speedDown.Parent = frame

-- Botón de vuelo
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.9, 0, 0, 35)
flyButton.Position = UDim2.new(0.05, 0, 0.6, 0)
flyButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
flyButton.Text = "Fly: OFF"
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.TextScaled = true
flyButton.Font = Enum.Font.SourceSans
flyButton.Parent = frame

-- Label de vuelo
local flyLabel = Instance.new("TextLabel")
flyLabel.Size = UDim2.new(0.9, 0, 0, 25)
flyLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
flyLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
flyLabel.Text = "Fly Speed: " .. flySpeed
flyLabel.TextColor3 = Color3.new(1, 1, 1)
flyLabel.TextScaled = true
flyLabel.Parent = frame

-- Instrucciones
local instructions = Instance.new("TextLabel")
instructions.Size = UDim2.new(0.9, 0, 0, 30)
instructions.Position = UDim2.new(0.05, 0, 0.88, 0)
instructions.BackgroundTransparency = 1
instructions.Text = "Fly: WASD + Space/Shift\nMobile: Use controls"
instructions.TextColor3 = Color3.new(0.8, 0.8, 0.8)
instructions.TextSize = 10
instructions.TextWrapped = true
instructions.Parent = frame

return {
    gui = screenGui,
    speedButton = speedButton,
    speedLabel = speedLabel,
    speedUp = speedUp,
    speedDown = speedDown,
    flyButton = flyButton,
    flyLabel = flyLabel
}
```

end

– Función para aplicar velocidad
local function applySpeed()
local character = player.Character
if character then
local humanoid = character:FindFirstChild(“Humanoid”)
if humanoid then
if speedEnabled then
humanoid.WalkSpeed = currentSpeed
else
humanoid.WalkSpeed = normalSpeed
end
end
end
end

– Función para actualizar UI de velocidad
local function updateSpeedUI(gui)
if speedEnabled then
gui.speedButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
gui.speedButton.Text = “Speed: ON”
else
gui.speedButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
gui.speedButton.Text = “Speed: OFF”
end
gui.speedLabel.Text = “Speed: “ .. currentSpeed
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

– Sistema de vuelo SIMPLE
local function startFlying()
local character = player.Character
if not character then return end

```
local rootPart = character:FindFirstChild("HumanoidRootPart")
local humanoid = character:FindFirstChild("Humanoid")
if not rootPart or not humanoid then return end

flying = true

-- Crear BodyVelocity
bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
bodyVelocity.Velocity = Vector3.new(0, 0, 0)
bodyVelocity.Parent = rootPart

-- Crear BodyGyro para estabilidad
bodyGyro = Instance.new("BodyGyro")
bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
bodyGyro.CFrame = rootPart.CFrame
bodyGyro.Parent = rootPart

humanoid.PlatformStand = true
```

end

local function stopFlying()
flying = false

```
local character = player.Character
if character then
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
    end
end

if bodyVelocity then
    bodyVelocity:Destroy()
    bodyVelocity = nil
end

if bodyGyro then
    bodyGyro:Destroy()
    bodyGyro = nil
end
```

end

– Actualizar UI de vuelo
local function updateFlyUI(gui)
if flyEnabled then
gui.flyButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
gui.flyButton.Text = “Fly: ON”
else
gui.flyButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
gui.flyButton.Text = “Fly: OFF”
end
gui.flyLabel.Text = “Fly Speed: “ .. flySpeed
end

– Toggle vuelo
local function toggleFly(gui)
flyEnabled = not flyEnabled
updateFlyUI(gui)

```
if flyEnabled then
    startFlying()
else
    stopFlying()
end
```

end

– Input handling
local function setupInput()
– Manejar teclas PC
UserInputService.InputBegan:Connect(function(input)
if input.KeyCode == Enum.KeyCode.W then W = true
elseif input.KeyCode == Enum.KeyCode.A then A = true
elseif input.KeyCode == Enum.KeyCode.S then S = true
elseif input.KeyCode == Enum.KeyCode.D then D = true
elseif input.KeyCode == Enum.KeyCode.Space then SPACE = true
elseif input.KeyCode == Enum.KeyCode.LeftShift then SHIFT = true
end
end)

```
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then W = false
    elseif input.KeyCode == Enum.KeyCode.A then A = false
    elseif input.KeyCode == Enum.KeyCode.S then S = false
    elseif input.KeyCode == Enum.KeyCode.D then D = false
    elseif input.KeyCode == Enum.KeyCode.Space then SPACE = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift then SHIFT = false
    end
end)
```

end

– Loop de vuelo
local function flyLoop()
RunService.Heartbeat:Connect(function()
if flying and bodyVelocity then
local character = player.Character
if not character then return end

```
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not rootPart or not humanoid then return end
        
        local camera = workspace.CurrentCamera
        local direction = Vector3.new(0, 0, 0)
        
        -- Movimiento horizontal (PC)
        if W then direction = direction + camera.CFrame.LookVector end
        if S then direction = direction - camera.CFrame.LookVector end
        if A then direction = direction - camera.CFrame.RightVector end
        if D then direction = direction + camera.CFrame.RightVector end
        
        -- Para móvil, usar MoveDirection del humanoid
        if UserInputService.TouchEnabled then
            local moveVector = humanoid.MoveDirection
            if moveVector.Magnitude > 0 then
                direction = camera.CFrame:VectorToWorldSpace(Vector3.new(moveVector.X, 0, -moveVector.Z))
            end
        end
        
        -- Movimiento vertical
        if SPACE then direction = direction + Vector3.new(0, 1, 0) end
        if SHIFT then direction = direction + Vector3.new(0, -1, 0) end
        
        -- Para móvil: usar el salto como subir
        if UserInputService.TouchEnabled and humanoid.Jump then
            direction = direction + Vector3.new(0, 1, 0)
            humanoid.Jump = false
        end
        
        -- Aplicar velocidad
        bodyVelocity.Velocity = direction.Unit * flySpeed
        if direction.Magnitude == 0 then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Mantener orientación
        bodyGyro.CFrame = camera.CFrame
    end
end)
```

end

– Función principal
local function main()
– Crear GUI
local gui = createGUI()

```
-- Conectar botones
gui.speedButton.MouseButton1Click:Connect(function()
    toggleSpeed(gui)
end)

gui.speedUp.MouseButton1Click:Connect(function()
    changeSpeed(10, gui)
end)

gui.speedDown.MouseButton1Click:Connect(function()
    changeSpeed(-10, gui)
end)

gui.flyButton.MouseButton1Click:Connect(function()
    toggleFly(gui)
end)

-- Configurar input
setupInput()

-- Iniciar loop de vuelo
flyLoop()

-- Manejar respawn
player.CharacterAdded:Connect(function()
    wait(1)
    applySpeed()
    if flyEnabled then
        flyEnabled = false
        toggleFly(gui)
    end
end)

-- Aplicar configuración inicial
updateSpeedUI(gui)
updateFlyUI(gui)
applySpeed()

print("✅ Speed & Fly Script cargado correctamente!")
```

end

– Ejecutar cuando el jugador se cargue
if player.Character then
main()
else
player.CharacterAdded:Wait()
main()
end
