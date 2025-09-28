-- 📱 SCRIPT DE VUELO PARA MÓVIL (CORREGIDO)
-- ✅ Soporta joystick, botones de subir/bajar y sigue la cámara correctamente

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local plr = Players.LocalPlayer

-- Configuración
local flyEnabled = false
local flySpeed = 50
local bv, bg
local connection

-- Variables para controles móvil
local isUpPressed = false
local isDownPressed = false

-- Crear GUI para móvil
local gui = Instance.new("ScreenGui")
gui.Name = "MobileFlyMenu"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 150)
frame.Position = UDim2.new(0, 10, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(1, 1, 1)
frame.Parent = gui

-- Botón de FLY
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0.9, 0, 0, 50)
flyBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
flyBtn.Text = "FLY: OFF"
flyBtn.TextSize = 20
flyBtn.TextColor3 = Color3.new(1, 1, 1)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
flyBtn.BorderSizePixel = 0
flyBtn.Parent = frame

-- Label de velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 30)
speedLabel.Position = UDim2.new(0.05, 0, 0.4, 0)
speedLabel.Text = "Velocidad: " .. flySpeed
speedLabel.TextSize = 16
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedLabel.BorderSizePixel = 0
speedLabel.Parent = frame

-- Botones de velocidad
local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Size = UDim2.new(0.4, 0, 0, 30)
speedUpBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
speedUpBtn.Text = "Vel +"
speedUpBtn.TextSize = 14
speedUpBtn.TextColor3 = Color3.new(1, 1, 1)
speedUpBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
speedUpBtn.BorderSizePixel = 0
speedUpBtn.Parent = frame

local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Size = UDim2.new(0.4, 0, 0, 30)
speedDownBtn.Position = UDim2.new(0.55, 0, 0.7, 0)
speedDownBtn.Text = "Vel -"
speedDownBtn.TextSize = 14
speedDownBtn.TextColor3 = Color3.new(1, 1, 1)
speedDownBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 80)
speedDownBtn.BorderSizePixel = 0
speedDownBtn.Parent = frame

-- Botones de SUBIR/BAJAR
local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 80, 0, 80)
upBtn.Position = UDim2.new(1, -100, 0.3, 0)
upBtn.Text = "↑\nSUBIR"
upBtn.TextSize = 18
upBtn.TextColor3 = Color3.new(1, 1, 1)
upBtn.Font = Enum.Font.SourceSansBold
upBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
upBtn.BorderSizePixel = 2
upBtn.BorderColor3 = Color3.new(1, 1, 1)
upBtn.Visible = false
upBtn.Parent = gui

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 80, 0, 80)
downBtn.Position = UDim2.new(1, -100, 0.6, 0)
downBtn.Text = "↓\nBAJAR"
downBtn.TextSize = 18
downBtn.TextColor3 = Color3.new(1, 1, 1)
downBtn.Font = Enum.Font.SourceSansBold
downBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
downBtn.BorderSizePixel = 2
downBtn.BorderColor3 = Color3.new(1, 1, 1)
downBtn.Visible = false
downBtn.Parent = gui

-- Función de vuelo
local function flyUpdate()
    if not flyEnabled then return end

    local chr = plr.Character
    if not chr or not chr:FindFirstChild("HumanoidRootPart") then return end

    local hrp = chr.HumanoidRootPart
    local humanoid = chr:FindFirstChild("Humanoid")
    local cam = workspace.CurrentCamera

    if not bv or not bg then return end

    local moveVector = Vector3.new(0, 0, 0)

    -- ✅ Movimiento relativo a la cámara
    if humanoid and humanoid.MoveDirection.Magnitude > 0 then
        local camCF = cam.CFrame
        local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
        local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

        local inputDir = humanoid.MoveDirection
        moveVector = (forward * inputDir.Z + right * inputDir.X).Unit
    end

    -- Movimiento vertical
    local verticalMovement = 0
    if isUpPressed then
        verticalMovement = 1
    elseif isDownPressed then
        verticalMovement = -1
    end

    local finalVector = Vector3.new(moveVector.X, verticalMovement, moveVector.Z)

    -- Aplicar velocidad
    bv.Velocity = finalVector * flySpeed

    -- Mantener orientación
    if moveVector.Magnitude > 0.1 then
        local lookDirection = (cam.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
        if lookDirection.Magnitude > 0 then
            bg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + lookDirection)
        end
    else
        bg.CFrame = hrp.CFrame
    end
end

-- Alternar vuelo
local function toggleFly()
    local chr = plr.Character
    if not chr or not chr:FindFirstChild("HumanoidRootPart") then return end

    local hrp = chr.HumanoidRootPart
    local humanoid = chr:FindFirstChild("Humanoid")

    flyEnabled = not flyEnabled

    if flyEnabled then
        flyBtn.Text = "FLY: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        upBtn.Visible = true
        downBtn.Visible = true

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

        if humanoid then humanoid.PlatformStand = true end
    else
        flyBtn.Text = "FLY: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        upBtn.Visible = false
        downBtn.Visible = false

        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end

        if humanoid then humanoid.PlatformStand = false end

        isUpPressed = false
        isDownPressed = false
    end
end

-- Eventos de botones
flyBtn.MouseButton1Click:Connect(toggleFly)

speedUpBtn.MouseButton1Click:Connect(function()
    flySpeed = math.min(flySpeed + 10, 200)
    speedLabel.Text = "Velocidad: " .. flySpeed
end)

speedDownBtn.MouseButton1Click:Connect(function()
    flySpeed = math.max(flySpeed - 10, 10)
    speedLabel.Text = "Velocidad: " .. flySpeed
end)

-- Subir/Bajar
upBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isUpPressed = true
    end
end)
upBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isUpPressed = false
    end
end)

downBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDownPressed = true
    end
end)
downBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDownPressed = false
    end
end)

-- Loop
connection = RS.Heartbeat:Connect(flyUpdate)

-- Reset en respawn
plr.CharacterAdded:Connect(function()
    task.wait(1)
    if flyEnabled then toggleFly() end
end)

print("🚀 SCRIPT DE VUELO MÓVIL CARGADO")
