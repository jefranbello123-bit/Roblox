-- Simple Fly Toggle Script para móviles
-- Crea un botón de ON/OFF que activa el modo Fly y muestra botones para subir y bajar.
-- ⚠️ El uso de scripts de vuelo puede violar los Términos de Servicio de Roblox. Úsalo bajo tu responsabilidad.

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- Esperar a que PlayerGui esté disponible
local playerGui = LP:WaitForChild("PlayerGui")

-- Crear contenedor de GUI
local flyGui = Instance.new("ScreenGui")
flyGui.Name = "SimpleFlyGUI"
flyGui.ResetOnSpawn = false
flyGui.IgnoreGuiInset = true
flyGui.Parent = playerGui

-- Crear botón de activación/desactivación
local toggleBtn = Instance.new("TextButton", flyGui)
toggleBtn.Size = UDim2.new(0, 120, 0, 40)
toggleBtn.Position = UDim2.new(0.04, 0, 0.8, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(220,45,45)
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Text = "Fly OFF"
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = true

-- Botón de ascenso
local ascendBtn = Instance.new("TextButton", flyGui)
ascendBtn.Size = UDim2.new(0, 50, 0, 50)
ascendBtn.Position = UDim2.new(0.88, 0, 0.6, 0)
ascendBtn.BackgroundColor3 = Color3.fromRGB(220,45,45)
ascendBtn.TextColor3 = Color3.fromRGB(255,255,255)
ascendBtn.Font = Enum.Font.GothamBold
ascendBtn.TextSize = 22
ascendBtn.Text = "↑"
ascendBtn.BorderSizePixel = 0
ascendBtn.Visible = false

-- Botón de descenso
local descendBtn = Instance.new("TextButton", flyGui)
descendBtn.Size = UDim2.new(0, 50, 0, 50)
descendBtn.Position = UDim2.new(0.88, 0, 0.7, 0)
descendBtn.BackgroundColor3 = Color3.fromRGB(160,25,25)
descendBtn.TextColor3 = Color3.fromRGB(255,255,255)
descendBtn.Font = Enum.Font.GothamBold
descendBtn.TextSize = 22
descendBtn.Text = "↓"
descendBtn.BorderSizePixel = 0
descendBtn.Visible = false

-- Variables internas de fly
local flying = false
local bodyGyro, bodyVel, flyConn
local ascend = false
local descend = false

-- Iniciar el vuelo
local function startFly()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    bodyGyro = Instance.new("BodyGyro", root)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyVel = Instance.new("BodyVelocity", root)
    bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVel.P = 9e4

    -- Conexión para actualizar cada frame
    flyConn = RunService.RenderStepped:Connect(function()
        local dir = Vector3.new()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local move = hum.MoveDirection
            if move.Magnitude > 0 then
                dir = dir + move
            end
        end
        if ascend then dir = dir + Vector3.new(0,1,0) end
        if descend then dir = dir + Vector3.new(0,-1,0) end
        if dir.Magnitude > 0 then
            dir = dir.Unit
        end
        bodyVel.Velocity = dir * 50
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    end)
end

-- Finalizar el vuelo
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if bodyVel then bodyVel:Destroy(); bodyVel = nil end
end

-- Eventos de los botones ↑/↓
ascendBtn.MouseButton1Down:Connect(function() ascend = true end)
ascendBtn.MouseButton1Up:Connect(function() ascend = false end)
descendBtn.MouseButton1Down:Connect(function() descend = true end)
descendBtn.MouseButton1Up:Connect(function() descend = false end)

-- Activar/desactivar Fly
toggleBtn.MouseButton1Click:Connect(function()
    flying = not flying
    toggleBtn.Text = flying and "Fly ON" or "Fly OFF"
    ascendBtn.Visible = flying
    descendBtn.Visible = flying
    if flying then
        startFly()
    else
        ascend = false
        descend = false
        stopFly()
    end
end)

print("✅ Simple Fly script cargado.")
