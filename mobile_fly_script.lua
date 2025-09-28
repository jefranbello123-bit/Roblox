– Script de Vuelo Solo para Móvil
– Con joystick funcional y controles de subir/bajar

local Players = game:GetService(“Players”)
local UIS = game:GetService(“UserInputService”)
local RS = game:GetService(“RunService”)
local CG = game:GetService(“CoreGui”)
local ContextActionService = game:GetService(“ContextActionService”)

local plr = Players.LocalPlayer
local mouse = plr:GetMouse()

– Configuración
local flyEnabled = false
local flySpeed = 50
local bv, bg
local connection

– Variables para movimiento móvil
local moveVector = Vector3.new(0, 0, 0)
local verticalInput = 0

– Crear GUI para móvil
local gui = Instance.new(“ScreenGui”, CG)
gui.Name = “MobileFlyMenu”
gui.ResetOnSpawn = false

– Frame principal
local frame = Instance.new(“Frame”, gui)
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(1, -210, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0

– Esquinas redondeadas
local corner = Instance.new(“UICorner”, frame)
corner.CornerRadius = UDim.new(0, 10)

– Botón de FLY
local flyBtn = Instance.new(“TextButton”, frame)
flyBtn.Size = UDim2.new(0.9, 0, 0, 35)
flyBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
flyBtn.Text = “✈️ FLY OFF”
flyBtn.TextSize = 16
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
flyBtn.BorderSizePixel = 0
flyBtn.TextColor3 = Color3.new(1, 1, 1)

local flyCorner = Instance.new(“UICorner”, flyBtn)
flyCorner.CornerRadius = UDim.new(0, 8)

– Botones de subir/bajar (grandes para móvil)
local upBtn = Instance.new(“TextButton”, gui)
upBtn.Size = UDim2.new(0, 60, 0, 60)
upBtn.Position = UDim2.new(1, -80, 0.5, -70)
upBtn.Text = “⬆️”
upBtn.TextSize = 24
upBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
upBtn.BorderSizePixel = 0
upBtn.TextColor3 = Color3.new(1, 1, 1)
upBtn.Visible = false

local downBtn = Instance.new(“TextButton”, gui)
downBtn.Size = UDim2.new(0, 60, 0, 60)
downBtn.Position = UDim2.new(1, -80, 0.5, 20)
downBtn.Text = “⬇️”
downBtn.TextSize = 24
downBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
downBtn.BorderSizePixel = 0
downBtn.TextColor3 = Color3.new(1, 1, 1)
downBtn.Visible = false

– Esquinas redondeadas para botones
local upCorner = Instance.new(“UICorner”, upBtn)
upCorner.CornerRadius = UDim.new(0, 30)
local downCorner = Instance.new(“UICorner”, downBtn)
downCorner.CornerRadius = UDim.new(0, 30)

– Función principal de vuelo para móvil
local function flyUpdate()
if not flyEnabled then return end

```
local chr = plr.Character
if not chr or not chr:FindFirstChild("HumanoidRootPart") then return end

local hrp = chr.HumanoidRootPart
local cam = workspace.CurrentCamera
local humanoid = chr:FindFirstChild("Humanoid")

if not bv or not bg then return end

-- Obtener vector de movimiento del joystick móvil
local moveVec = Vector3.new(0, 0, 0)

-- Detectar input del joystick táctil de Roblox
if humanoid and humanoid.MoveDirection.Magnitude > 0 then
    local cameraCFrame = cam.CFrame
    local forward = cameraCFrame.LookVector
    local right = cameraCFrame.RightVector
    
    -- Usar la dirección de movimiento del humanoid (esto captura el joystick)
    local moveDir = humanoid.MoveDirection
    moveVec = forward * moveDir.Z + right * moveDir.X
end

-- Agregar movimiento vertical
moveVec = moveVec + Vector3.new(0, verticalInput, 0)

-- Aplicar velocidad
bv.Velocity = moveVec * flySpeed

-- Orientar hacia donde mira la cámara
if moveVec.Magnitude > 0.1 then
    local lookDirection = (cam.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
    bg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + lookDirection)
end
```

end

– Función para activar/desactivar vuelo
local function toggleFly()
flyEnabled = not flyEnabled

```
local chr = plr.Character
if not chr or not chr:FindFirstChild("HumanoidRootPart") then return end

local hrp = chr.HumanoidRootPart
local humanoid = chr:FindFirstChild("Humanoid")

if flyEnabled then
    flyBtn.Text = "✈️ FLY ON"
    flyBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    upBtn.Visible = true
    downBtn.Visible = true
    
    -- Crear BodyVelocity y BodyGyro
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(4000, 4000, 4000)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(4000, 4000, 4000)
    bg.D = 500
    bg.P = 3000
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    
    if humanoid then
        humanoid.PlatformStand = true
    end
    
else
    flyBtn.Text = "✈️ FLY OFF"
    flyBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    upBtn.Visible = false
    downBtn.Visible = false
    verticalInput = 0
    
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    if humanoid then
        humanoid.PlatformStand = false
    end
end
```

end

– Eventos de botones
flyBtn.MouseButton1Click:Connect(toggleFly)

– Botones de subir/bajar con touch events para mejor respuesta
upBtn.TouchStarted:Connect(function()
verticalInput = 1
end)

upBtn.TouchEnded:Connect(function()
verticalInput = 0
end)

upBtn.MouseButton1Down:Connect(function()
verticalInput = 1
end)

upBtn.MouseButton1Up:Connect(function()
verticalInput = 0
end)

downBtn.TouchStarted:Connect(function()
verticalInput = -1
end)

downBtn.TouchEnded:Connect(function()
verticalInput = 0
end)

downBtn.MouseButton1Down:Connect(function()
verticalInput = -1
end)

downBtn.MouseButton1Up:Connect(function()
verticalInput = 0
end)

– Conexión principal
connection = RS.Heartbeat:Connect(flyUpdate)

– Limpiar al cambiar de personaje
plr.CharacterAdded:Connect(function()
if flyEnabled then
flyEnabled = false
toggleFly()
end
end)

print(“✈️ Fly script para móvil cargado correctamente!”)
print(“📱 Usa el joystick de Roblox para moverte”)
print(“⬆️⬇️ Usa los botones para subir/bajar”)
