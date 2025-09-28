-- 🌿 VERDEFLY SPEED SCRIPT (Móvil + PC)
-- 🚀 Vuelo super rápido con interfaz moderna

local Players = game:GetService("Players")
local RS = game:GetService("RunService")

local plr = Players.LocalPlayer

-- Configuración
local flyEnabled = false
local flySpeed = 50
local bv, bg
local connection

-- Variables de control
local isUpPressed = false
local isDownPressed = false

-- GUI Moderna
local gui = Instance.new("ScreenGui")
gui.Name = "VerdeFlyGUI"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 180)
mainFrame.Position = UDim2.new(0.5, -125, 0.7, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5,0)
mainFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,15)
corner.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.Text = "🌿 VerdeFly"
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- Botón Fly
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0.9,0,0,45)
flyBtn.Position = UDim2.new(0.05,0,0.25,0)
flyBtn.Text = "FLY: OFF"
flyBtn.TextSize = 18
flyBtn.Font = Enum.Font.GothamBold
flyBtn.TextColor3 = Color3.new(1,1,1)
flyBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
flyBtn.Parent = mainFrame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0,10)
flyCorner.Parent = flyBtn

-- Label Velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9,0,0,30)
speedLabel.Position = UDim2.new(0.05,0,0.55,0)
speedLabel.Text = "Speed: "..flySpeed
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 0.3
speedLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
speedLabel.Parent = mainFrame

local labelCorner = Instance.new("UICorner")
labelCorner.CornerRadius = UDim.new(0,10)
labelCorner.Parent = speedLabel

-- Botones de velocidad
local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Size = UDim2.new(0.42,0,0,35)
speedUpBtn.Position = UDim2.new(0.05,0,0.8,0)
speedUpBtn.Text = "➕ Faster"
speedUpBtn.TextSize = 16
speedUpBtn.Font = Enum.Font.GothamBold
speedUpBtn.TextColor3 = Color3.new(1,1,1)
speedUpBtn.BackgroundColor3 = Color3.fromRGB(60,200,60)
speedUpBtn.Parent = mainFrame

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0,10)
upCorner.Parent = speedUpBtn

local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Size = UDim2.new(0.42,0,0,35)
speedDownBtn.Position = UDim2.new(0.53,0,0.8,0)
speedDownBtn.Text = "➖ Slower"
speedDownBtn.TextSize = 16
speedDownBtn.Font = Enum.Font.GothamBold
speedDownBtn.TextColor3 = Color3.new(1,1,1)
speedDownBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
speedDownBtn.Parent = mainFrame

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0,10)
downCorner.Parent = speedDownBtn

-- Función de vuelo
local function flyUpdate()
    if not flyEnabled then return end

    local chr = plr.Character
    if not chr or not chr:FindFirstChild("HumanoidRootPart") then return end

    local hrp = chr.HumanoidRootPart
    local humanoid = chr:FindFirstChild("Humanoid")
    local cam = workspace.CurrentCamera

    if not bv or not bg then return end

    local moveVector = Vector3.new(0,0,0)

    if humanoid and humanoid.MoveDirection.Magnitude > 0 then
        local camCF = cam.CFrame
        local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
        local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

        local inputDir = humanoid.MoveDirection
        moveVector = (forward * inputDir.Z + right * inputDir.X).Unit
    end

    -- movimiento vertical
    local verticalMovement = 0
    if isUpPressed then verticalMovement = 1 end
    if isDownPressed then verticalMovement = -1 end

    local finalVector = Vector3.new(moveVector.X, verticalMovement, moveVector.Z)

    bv.Velocity = finalVector * flySpeed

    if moveVector.Magnitude > 0.1 then
        local lookDirection = (cam.CFrame.LookVector * Vector3.new(1,0,1)).Unit
        if lookDirection.Magnitude > 0 then
            bg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + lookDirection)
        end
    end
end

-- Toggle Fly
local function toggleFly()
    local chr = plr.Character
    if not chr or not chr:FindFirstChild("HumanoidRootPart") then return end

    local hrp = chr.HumanoidRootPart
    local humanoid = chr:FindFirstChild("Humanoid")

    flyEnabled = not flyEnabled

    if flyEnabled then
        flyBtn.Text = "FLY: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(60,200,60)

        if bv then bv:Destroy() end
        if bg then bg:Destroy() end

        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
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
        flyBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)

        if bv then bv:Destroy() bv=nil end
        if bg then bg:Destroy() bg=nil end

        if humanoid then humanoid.PlatformStand = false end
    end
end

-- Conexiones
flyBtn.MouseButton1Click:Connect(toggleFly)

speedUpBtn.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 25 -- sin límite máximo
    speedLabel.Text = "Speed: "..flySpeed
end)

speedDownBtn.MouseButton1Click:Connect(function()
    flySpeed = math.max(flySpeed - 25, 1) -- mínimo 1
    speedLabel.Text = "Speed: "..flySpeed
end)

connection = RS.Heartbeat:Connect(flyUpdate)

plr.CharacterAdded:Connect(function()
    task.wait(1)
    if flyEnabled then toggleFly() end
end)

print("🌿 VerdeFly Speed cargado 🚀")
