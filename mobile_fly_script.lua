– Script de Vuelo CORREGIDO para Móvil
– Arreglando todos los problemas

local Players = game:GetService(“Players”)
local UIS = game:GetService(“UserInputService”)
local RS = game:GetService(“RunService”)
local CG = game:GetService(“CoreGui”)

local plr = Players.LocalPlayer
local mouse = plr:GetMouse()

– Configuración
local flyEnabled = false
local flySpeed = 50
local bv, bg
local connection

– Variables para controles móvil
local isUpPressed = false
local isDownPressed = false

– Crear GUI para móvil - VISIBLE
local gui = Instance.new(“ScreenGui”)
gui.Name = “MobileFlyMenu”
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild(“PlayerGui”)

– Frame principal - MÁS VISIBLE
local frame = Instance.new(“Frame”)
frame.Size = UDim2.new(0, 220, 0, 150)
frame.Position = UDim2.new(0, 10, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(1, 1, 1)
frame.Parent = gui

– Botón de FLY - MÁS GRANDE
local flyBtn = Instance.new(“TextButton”)
flyBtn.Size = UDim2.new(0.9, 0, 0, 50)
flyBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
flyBtn.Text = “FLY: OFF”
flyBtn.TextSize = 20
flyBtn.TextColor3 = Color3.new(1, 1, 1)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
flyBtn.BorderSizePixel = 0
flyBtn.Parent = frame

– Label de velocidad
local speedLabel = Instance.new(“TextLabel”)
speedLabel.Size = UDim2.new(0.9, 0, 0, 30)
speedLabel.Position = UDim2.new(0.05, 0, 0.4, 0)
speedLabel.Text = “Velocidad: “ .. flySpeed
speedLabel.TextSize = 16
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedLabel.BorderSizePixel = 0
speedLabel.Parent = frame

– Botones de velocidad
local speedUpBtn = Instance.new(“TextButton”)
speedUpBtn.Size = UDim2.new(0.4, 0, 0, 30)
speedUpBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
speedUpBtn.Text = “Vel +”
speedUpBtn.TextSize = 14
speedUpBtn.TextColor3 = Color3.new(1, 1, 1)
speedUpBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
speedUpBtn.BorderSizePixel = 0
speedUpBtn.Parent = frame

local speedDownBtn = Instance.new(“TextButton”)
speedDownBtn.Size = UDim2.new(0.4, 0, 0, 30)
speedDownBtn.Position = UDim2.new(0.55, 0, 0.7, 0)
speedDownBtn.Text = “Vel -”
speedDownBtn.TextSize = 14
speedDownBtn.TextColor3 = Color3.new(1, 1, 1)
speedDownBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 80)
speedDownBtn.BorderSizePixel = 0
speedDownBtn.Parent = frame

– BOTONES DE SUBIR/BAJAR - GRANDES Y VISIBLES
local upBtn = Instance.new(“TextButton”)
upBtn.Size = UDim2.new(0, 80, 0, 80)
upBtn.Position = UDim2.new(1, -100, 0.3, 0)
upBtn.Text = “↑\nSUBIR”
upBtn.TextSize = 18
upBtn.TextColor3 = Color3.new(1, 1, 1)
upBtn.Font = Enum.Font.SourceSansBold
upBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
upBtn.BorderSizePixel = 2
upBtn.BorderColor3 = Color3.new(1, 1, 1)
upBtn.Visible = false
upBtn.Parent = gui

local downBtn = Instance.new(“TextButton”)
downBtn.Size = UDim2.new(0, 80, 0, 80)
downBtn.Position = UDim2.new(1, -100, 0.6, 0)
downBtn.Text = “↓\nBAJAR”
downBtn.TextSize = 18
downBtn.TextColor3 = Color3.new(1, 1, 1)
downBtn.Font = Enum.Font.SourceSansBold
downBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
downBtn.BorderSizePixel = 2
downBtn.BorderColor3 = Color3.new(1, 1, 1)
downBtn.Visible = false
downBtn.Parent = gui

– Función CORREGIDA de vuelo
local function flyUpdate()
if not flyEnabled then return end

```
local chr = plr.Character
if not chr or not chr:FindFirstChild("HumanoidRootPart") then return end

local hrp = chr.HumanoidRootPart
local humanoid = chr:FindFirstChild("Humanoid")
local cam = workspace.CurrentCamera

if not bv or not bg then return end

local moveVector = Vector3.new(0, 0, 0)

-- MÉTODO CORREGIDO para capturar joystick móvil
if humanoid then
    local moveDir = humanoid.MoveDirection
    if moveDir.Magnitude > 0 then
        -- Obtener dirección de la cámara
        local camCF = cam.CFrame
        local forwardVector = camCF.LookVector
        local rightVector = camCF.RightVector
        
        -- Calcular movimiento basado en cámara y joystick
        moveVector = (forwardVector * -moveDir.Z) + (rightVector * moveDir.X)
        moveVector = Vector3.new(moveVector.X, 0, moveVector.Z)
    end
end

-- Agregar movimiento vertical
if isUpPressed then
    moveVector = moveVector + Vector3.new(0, 1, 0)
elseif isDownPressed then
    moveVector = moveVector + Vector3.new(0, -1, 0)
end

-- Aplicar velocidad
bv.Velocity = moveVector * flySpeed

-- Rotar hacia donde mira la cámara
bg.CFrame = cam.CFrame
```

end

– Función para alternar vuelo
local function toggleFly()
local chr = plr.Character
if not chr or not chr:FindFirstChild(“HumanoidRootPart”) then
print(“No hay personaje”)
return
end

```
local hrp = chr.HumanoidRootPart
local humanoid = chr:FindFirstChild("Humanoid")

flyEnabled = not flyEnabled

if flyEnabled then
    -- ACTIVAR VUELO
    flyBtn.Text = "FLY: ON"
    flyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    upBtn.Visible = true
    downBtn.Visible = true
    
    -- Crear objetos de vuelo
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.D = 2000
    bg.P = 10000
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    
    if humanoid then
        humanoid.PlatformStand = true
    end
    
    print("✅ Vuelo ACTIVADO")
    
else
    -- DESACTIVAR VUELO
    flyBtn.Text = "FLY: OFF"
    flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    upBtn.Visible = false
    downBtn.Visible = false
    
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    isUpPressed = false
    isDownPressed = false
    
    print("❌ Vuelo DESACTIVADO")
end
```

end

– Eventos de botones
flyBtn.MouseButton1Click:Connect(toggleFly)

– Controles de velocidad
speedUpBtn.MouseButton1Click:Connect(function()
flySpeed = math.min(flySpeed + 10, 200)
speedLabel.Text = “Velocidad: “ .. flySpeed
end)

speedDownBtn.MouseButton1Click:Connect(function()
flySpeed = math.max(flySpeed - 10, 10)
speedLabel.Text = “Velocidad: “ .. flySpeed
end)

– Controles de subir/bajar - CORREGIDOS
upBtn.TouchStarted:Connect(function()
isUpPressed = true
end)

upBtn.TouchEnded:Connect(function()
isUpPressed = false
end)

upBtn.MouseButton1Down:Connect(function()
isUpPressed = true
end)

upBtn.MouseButton1Up:Connect(function()
isUpPressed = false
end)

downBtn.TouchStarted:Connect(function()
isDownPressed = true
end)

downBtn.TouchEnded:Connect(function()
isDownPressed = false
end)

downBtn.MouseButton1Down:Connect(function()
isDownPressed = true
end)

downBtn.MouseButton1Up:Connect(function()
isDownPressed = false
end)

– Conexión del loop principal
connection = RS.Heartbeat:Connect(flyUpdate)

– Limpiar cuando cambie el personaje
plr.CharacterAdded:Connect(function()
wait(1)
if flyEnabled then
toggleFly() – Desactivar primero
end
end)

print(“🚀 SCRIPT DE VUELO MÓVIL CARGADO”)
print(“📱 Toca FLY: OFF para activar”)
print(“🕹️ Usa el joystick para moverte”)
print(“⬆️⬇️ Usa los botones SUBIR/BAJAR”)
