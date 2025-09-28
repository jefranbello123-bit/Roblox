-- 🚀 ESP + WALKHACK - Script Completo
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local espEnabled = false
local walkhackEnabled = false
local currentSpeed = 100

-- Almacenar instancias de ESP
local espFolders = {}
local espConnections = {}

-- Crear interfaz
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPWalkhackMenu"
screenGui.Parent = CoreGui

-- Botón principal
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 70, 0, 70)
mainButton.Position = UDim2.new(0.5, -35, 0.1, 0)
mainButton.Text = "👁️"
mainButton.TextSize = 30
mainButton.Font = Enum.Font.GothamBold
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
mainButton.BorderSizePixel = 0
mainButton.ZIndex = 2
mainButton.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(1, 0)
mainCorner.Parent = mainButton

-- Marco del menú
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 220, 0, 200)
menuFrame.Position = UDim2.new(0.5, -110, 0.1, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.ZIndex = 1
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 15)
menuCorner.Parent = menuFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "👁️ ESP + 🚀 WALKHACK"
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.BorderSizePixel = 0
title.Parent = menuFrame

-- Botón ESP
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0.9, 0, 0, 40)
espButton.Position = UDim2.new(0.05, 0, 0.2, 0)
espButton.Text = "ESP: OFF"
espButton.TextSize = 14
espButton.Font = Enum.Font.GothamBold
espButton.TextColor3 = Color3.new(1, 1, 1)
espButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
espButton.BorderSizePixel = 0
espButton.Parent = menuFrame

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 8)
espCorner.Parent = espButton

-- Botón Walkhack
local walkButton = Instance.new("TextButton")
walkButton.Size = UDim2.new(0.9, 0, 0, 40)
walkButton.Position = UDim2.new(0.05, 0, 0.45, 0)
walkButton.Text = "WALKHACK: OFF"
walkButton.TextSize = 14
walkButton.Font = Enum.Font.GothamBold
walkButton.TextColor3 = Color3.new(1, 1, 1)
walkButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
walkButton.BorderSizePixel = 0
walkButton.Parent = menuFrame

local walkCorner = Instance.new("UICorner")
walkCorner.CornerRadius = UDim.new(0, 8)
walkCorner.Parent = walkButton

-- Control de velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 25)
speedLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
speedLabel.Text = "VELOCIDAD: " .. currentSpeed
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedLabel.BorderSizePixel = 0
speedLabel.Parent = menuFrame

local labelCorner = Instance.new("UICorner")
labelCorner.CornerRadius = UDim.new(0, 8)
labelCorner.Parent = speedLabel

-- Botones de velocidad
local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0.4, 0, 0, 25)
upButton.Position = UDim2.new(0.05, 0, 0.85, 0)
upButton.Text = "+50"
upButton.TextSize = 12
upButton.Font = Enum.Font.GothamBold
upButton.TextColor3 = Color3.new(1, 1, 1)
upButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
upButton.BorderSizePixel = 0
upButton.Parent = menuFrame

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 8)
upCorner.Parent = upButton

local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0.4, 0, 0, 25)
downButton.Position = UDim2.new(0.55, 0, 0.85, 0)
downButton.Text = "-50"
downButton.TextSize = 12
downButton.Font = Enum.Font.GothamBold
downButton.TextColor3 = Color3.new(1, 1, 1)
downButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
downButton.BorderSizePixel = 0
downButton.Parent = menuFrame

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 8)
downCorner.Parent = downButton

-- Variables de estado
local menuOpen = false

-- ===== FUNCIÓN WALKHACK =====
local function applyWalkhack()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            if walkhackEnabled then
                humanoid.WalkSpeed = currentSpeed
            else
                humanoid.WalkSpeed = 16
            end
        end
    end
end

local function toggleWalkhack()
    walkhackEnabled = not walkhackEnabled
    if walkhackEnabled then
        walkButton.Text = "WALKHACK: ON"
        walkButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    else
        walkButton.Text = "WALKHACK: OFF"
        walkButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
    applyWalkhack()
end

-- ===== FUNCIÓN ESP =====
local function createESP(playerTarget)
    if not espEnabled then return end
    if playerTarget == player then return end
    
    local character = playerTarget.Character
    if not character then return end
    
    -- Crear folder para este jugador
    local espFolder = Instance.new("Folder")
    espFolder.Name = playerTarget.Name .. "_ESP"
    espFolder.Parent = screenGui
    espFolders[playerTarget] = espFolder
    
    -- Función para actualizar ESP
    local function updateESP()
        if not espEnabled or not character or not character.Parent then
            if espFolder then
                espFolder:Destroy()
                espFolders[playerTarget] = nil
            end
            return
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if humanoidRootPart and humanoid and humanoid.Health > 0 then
            -- Limpiar ESP anterior
            for _, child in pairs(espFolder:GetChildren()) do
                child:Destroy()
            end
            
            -- Crear caja ESP
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "ESP_Box"
            box.Adornee = humanoidRootPart
            box.AlwaysOnTop = true
            box.ZIndex = 1
            box.Size = Vector3.new(4, 6, 2)
            box.Color3 = Color3.new(1, 0, 0)  -- Rojo
            box.Transparency = 0.3
            box.Parent = espFolder
            
            -- Crear nombre flotante
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP_Name"
            billboard.Adornee = humanoidRootPart
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 4, 0)
            billboard.AlwaysOnTop = true
            billboard.MaxDistance = 1000
            billboard.Parent = espFolder
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = playerTarget.Name .. " [" .. math.floor(humanoid.Health) .. " HP]"
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.TextSize = 14
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Parent = billboard
            
            -- Crear línea de trayecto
            local line = Instance.new("LineHandleAdornment")
            line.Name = "ESP_Line"
            line.Adornee = workspace.Terrain
            line.ZIndex = 0
            line.Thickness = 2
            line.Color3 = Color3.new(1, 1, 0)  -- Amarillo
            line.Transparency = 0.5
            line.Parent = espFolder
            
            -- Actualizar línea
            local localChar = player.Character
            if localChar then
                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                if localRoot then
                    line.Length = (humanoidRootPart.Position - localRoot.Position).Magnitude
                    line.CFrame = CFrame.new(localRoot.Position, humanoidRootPart.Position)
                end
            end
        else
            -- Si el jugador murió, limpiar ESP
            espFolder:Destroy()
            espFolders[playerTarget] = nil
        end
    end
    
    -- Conexión para actualizar continuamente
    local connection = RunService.Heartbeat:Connect(updateESP)
    espConnections[playerTarget] = connection
end

local function removeESP(playerTarget)
    if espFolders[playerTarget] then
        espFolders[playerTarget]:Destroy()
        espFolders[playerTarget] = nil
    end
    if espConnections[playerTarget] then
        espConnections[playerTarget]:Disconnect()
        espConnections[playerTarget] = nil
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        espButton.Text = "ESP: ON"
        espButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        
        -- Crear ESP para jugadores existentes
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            createESP(otherPlayer)
        end
        
        -- Conectar para nuevos jugadores
        Players.PlayerAdded:Connect(createESP)
    else
        espButton.Text = "ESP: OFF"
        espButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        
        -- Limpiar todo el ESP
        for _, folder in pairs(espFolders) do
            folder:Destroy()
        end
        espFolders = {}
        
        for _, connection in pairs(espConnections) do
            connection:Disconnect()
        end
        espConnections = {}
        
        -- Desconectar eventos
        Players.PlayerAdded:Connect(function(plr)
            -- No hacer nada cuando el ESP está desactivado
        end)
    end
end

-- ===== INTERFAZ =====
local function toggleMenu()
    menuOpen = not menuOpen
    menuFrame.Visible = menuOpen
end

-- Conexión de eventos
mainButton.MouseButton1Click:Connect(toggleMenu)
espButton.MouseButton1Click:Connect(toggleESP)
walkButton.MouseButton1Click:Connect(toggleWalkhack)

upButton.MouseButton1Click:Connect(function()
    currentSpeed = currentSpeed + 50
    speedLabel.Text = "VELOCIDAD: " .. currentSpeed
    applyWalkhack()
end)

downButton.MouseButton1Click:Connect(function()
    currentSpeed = math.max(50, currentSpeed - 50)
    speedLabel.Text = "VELOCIDAD: " .. currentSpeed
    applyWalkhack()
end)

-- Manejo de respawn
player.CharacterAdded:Connect(function(character)
    wait(1)
    applyWalkhack()
end)

-- Aplicar walkhack al iniciar
applyWalkhack()

-- Sistema de arrastre
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        if input.UserInputState == Enum.UserInputState.Begin then
            dragging = true
            dragStart = input.Position
            startPos = mainButton.Position
        elseif input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end
end

mainButton.InputBegan:Connect(updateInput)
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
        menuFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X - 75,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

print("🎯 ESP + WALKHACK CARGADO!")
print("👁️ ESP: Ver jugadores a través de paredes")
print("🚀 WALKHACK: Velocidad aumentada")
print("💡 Toca el botón naranja para abrir el menú")
