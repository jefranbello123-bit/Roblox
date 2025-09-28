-- Script Simple de Velocidad y Vuelo para Delta
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Configuración simple
local speedEnabled = false
local normalSpeed = 16
local fastSpeed = 50

local flyEnabled = false
local flySpeed = 50

-- Crear interfaz mínima
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleMenu"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 150)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Botón de velocidad
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.9, 0, 0, 40)
speedBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
speedBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
speedBtn.Text = "VELOCIDAD NORMAL"
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.TextSize = 12
speedBtn.Parent = mainFrame

-- Botón de vuelo
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0.9, 0, 0, 40)
flyBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
flyBtn.Text = "VUELO OFF"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.TextSize = 12
flyBtn.Parent = mainFrame

-- Función de velocidad (simple y probada)
local function toggleSpeed()
    speedEnabled = not speedEnabled
    
    if speedEnabled then
        speedBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        speedBtn.Text = "VELOCIDAD RAPIDA"
    else
        speedBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        speedBtn.Text = "VELOCIDAD NORMAL"
    end
    
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

-- Función de vuelo (método simple)
local function toggleFly()
    flyEnabled = not flyEnabled
    
    if flyEnabled then
        flyBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        flyBtn.Text = "VUELO ON"
        startFlying()
    else
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        flyBtn.Text = "VUELO OFF"
        stopFlying()
    end
end

-- Vuelo simple
local bv, bg

local function startFlying()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- Crear físicas simples
    bv = Instance.new("BodyVelocity")
    bg = Instance.new("BodyGyro")
    
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(10000, 10000, 10000)
    bv.Parent = rootPart
    
    bg.MaxTorque = Vector3.new(10000, 10000, 10000)
    bg.CFrame = rootPart.CFrame
    bg.Parent = rootPart
    
    humanoid.PlatformStand = true
end

local function stopFlying()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

-- Control de vuelo
local flyUp = false
local flyDown = false

UserInputService.InputBegan:Connect(function(input)
    if not flyEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        flyDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not flyEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        flyDown = false
    end
end)

-- Loop de vuelo simple
RunService.Heartbeat:Connect(function()
    if flyEnabled and bv then
        local character = player.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- Movimiento básico
        local move = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            move = move + Vector3.new(0, 0, -1)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            move = move + Vector3.new(0, 0, 1)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            move = move + Vector3.new(-1, 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            move = move + Vector3.new(1, 0, 0)
        end
        
        -- Control de altura
        if flyUp then
            move = move + Vector3.new(0, 1, 0)
        elseif flyDown then
            move = move + Vector3.new(0, -1, 0)
        end
        
        -- Aplicar movimiento
        if move.Magnitude > 0 then
            local camera = workspace.CurrentCamera
            if camera then
                local worldMove = camera.CFrame:VectorToWorldSpace(move)
                bv.Velocity = worldMove * flySpeed
            end
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Manejar respawn
player.CharacterAdded:Connect(function()
    wait(1)
    
    -- Re-aplicar velocidad
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
    
    -- Re-activar vuelo si estaba activo
    if flyEnabled then
        stopFlying()
        wait(0.5)
        startFlying()
    end
end)

-- Conectar botones
speedBtn.MouseButton1Click:Connect(toggleSpeed)
flyBtn.MouseButton1Click:Connect(toggleFly)

print("Script cargado - Usa los botones para activar funciones")
