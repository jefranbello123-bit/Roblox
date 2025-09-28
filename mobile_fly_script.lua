--[[ 
    ESP + WalkHack + Fly (móvil)
    Este script permite ver jugadores a través de paredes (ESP), aumentar la velocidad (WalkHack) y volar.
    Se ha optimizado para móviles: el vuelo usa el joystick virtual y botones de subida/bajada.
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Estados
local espEnabled        = false
local walkhackEnabled   = false
local currentSpeed      = 100
local flyEnabled        = false
local flyBodyGyro       = nil
local flyBodyVelocity   = nil
local flyUpdateConnection = nil
local flyAscend         = false
local flyDescend        = false

-- Almacenes de ESP
local espFolders            = {}
local espUpdateConnections  = {}
local playerAddedConnection = nil
local playerRemovingConnection = nil

-- GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPWalkhackMenu"
screenGui.Parent = CoreGui

-- Botón circular del menú
local mainButton = Instance.new("TextButton")
mainButton.Size     = UDim2.new(0,70,0,70)
mainButton.Position = UDim2.new(0.5,-35,0.1,0)
mainButton.Text     = "Menu"
mainButton.TextSize = 30
mainButton.Font     = Enum.Font.GothamBold
mainButton.TextColor3      = Color3.new(1,1,1)
mainButton.BackgroundColor3= Color3.fromRGB(255,100,0)
mainButton.BorderSizePixel = 0
mainButton.ZIndex  = 2
mainButton.Parent  = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(1,0)
mainCorner.Parent       = mainButton

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2
mainStroke.Color     = Color3.fromRGB(50,50,50)
mainStroke.Parent    = mainButton

local buttonGradient = Instance.new("UIGradient")
buttonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,170,0)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,100,0))
}
buttonGradient.Rotation = 90
buttonGradient.Parent   = mainButton

-- Marco del menú
local menuFrame = Instance.new("Frame")
menuFrame.Size     = UDim2.new(0,220,0,200)
menuFrame.Position = UDim2.new(0.5,-110,0.1,0)
menuFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
menuFrame.BorderSizePixel  = 0
menuFrame.Visible = false
menuFrame.ZIndex  = 1
menuFrame.Parent  = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0,15)
menuCorner.Parent = menuFrame

local menuGradient = Instance.new("UIGradient")
menuGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(50,50,50)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(25,25,25))
}
menuGradient.Rotation = 90
menuGradient.Parent   = menuFrame

-- Título
local title = Instance.new("TextLabel")
title.Size            = UDim2.new(1,0,0,30)
title.Position        = UDim2.new(0,0,0,0)
title.Text            = "ESP • WALKHACK • FLY"
title.TextSize        = 16
title.Font            = Enum.Font.GothamBold
title.TextColor3      = Color3.new(1,1,1)
title.BackgroundColor3= Color3.fromRGB(25,25,25)
title.BorderSizePixel = 0
title.Parent          = menuFrame

-- Botón de cierre
local closeButton = Instance.new("TextButton")
closeButton.Size     = UDim2.new(0,25,0,25)
closeButton.Position = UDim2.new(1,-30,0,5)
closeButton.Text     = "X"
closeButton.TextSize = 16
closeButton.Font     = Enum.Font.GothamBold
closeButton.TextColor3       = Color3.new(1,1,1)
closeButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
closeButton.BorderSizePixel  = 0
closeButton.Parent           = menuFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0,4)
closeCorner.Parent       = closeButton

local closeStroke = Instance.new("UIStroke")
closeStroke.Thickness = 2
closeStroke.Color     = Color3.fromRGB(50,50,50)
closeStroke.Parent    = closeButton

-- Botón ESP
local espButton = Instance.new("TextButton")
espButton.Size     = UDim2.new(0.9,0,0,40)
espButton.Position = UDim2.new(0.05,0,0.2,0)
espButton.Text     = "ESP: OFF"
espButton.TextSize = 14
espButton.Font     = Enum.Font.GothamBold
espButton.TextColor3       = Color3.new(1,1,1)
espButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
espButton.BorderSizePixel  = 0
espButton.Parent   = menuFrame

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0,8)
espCorner.Parent       = espButton

local espStroke = Instance.new("UIStroke")
espStroke.Thickness = 2
espStroke.Color     = Color3.fromRGB(50,50,50)
espStroke.Parent    = espButton

-- Botón Walkhack
local walkButton = Instance.new("TextButton")
walkButton.Size     = UDim2.new(0.9,0,0,40)
walkButton.Position = UDim2.new(0.05,0,0.45,0)
walkButton.Text     = "WALKHACK: OFF"
walkButton.TextSize = 14
walkButton.Font     = Enum.Font.GothamBold
walkButton.TextColor3       = Color3.new(1,1,1)
walkButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
walkButton.BorderSizePixel  = 0
walkButton.Parent   = menuFrame

local walkCorner = Instance.new("UICorner")
walkCorner.CornerRadius = UDim.new(0,8)
walkCorner.Parent       = walkButton

local walkStroke = Instance.new("UIStroke")
walkStroke.Thickness = 2
walkStroke.Color     = Color3.fromRGB(50,50,50)
walkStroke.Parent    = walkButton

-- Botón Fly
local flyButton = Instance.new("TextButton")
flyButton.Size     = UDim2.new(0.9,0,0,40)
flyButton.Position = UDim2.new(0.05,0,0.6,0)
flyButton.Text     = "FLY: OFF"
flyButton.TextSize = 14
flyButton.Font     = Enum.Font.GothamBold
flyButton.TextColor3       = Color3.new(1,1,1)
flyButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
flyButton.BorderSizePixel  = 0
flyButton.Parent   = menuFrame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0,8)
flyCorner.Parent       = flyButton

local flyStroke = Instance.new("UIStroke")
flyStroke.Thickness = 2
flyStroke.Color     = Color3.fromRGB(50,50,50)
flyStroke.Parent    = flyButton

-- Etiqueta de velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Size             = UDim2.new(0.9,0,0,25)
speedLabel.Position         = UDim2.new(0.05,0,0.75,0)
speedLabel.Text             = "VELOCIDAD: "..currentSpeed
speedLabel.TextSize         = 12
speedLabel.Font             = Enum.Font.Gotham
speedLabel.TextColor3       = Color3.new(1,1,1)
speedLabel.BackgroundColor3 = Color3.fromRGB(60,60,60)
speedLabel.BorderSizePixel  = 0
speedLabel.Parent           = menuFrame

local labelCorner = Instance.new("UICorner")
labelCorner.CornerRadius = UDim.new(0,8)
labelCorner.Parent       = speedLabel

-- Botones de velocidad +50 / -50
local upButton = Instance.new("TextButton")
upButton.Size     = UDim2.new(0.4,0,0,25)
upButton.Position = UDim2.new(0.05,0,0.8,0)
upButton.Text     = "+50"
upButton.TextSize = 12
upButton.Font     = Enum.Font.GothamBold
upButton.TextColor3       = Color3.new(1,1,1)
upButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
upButton.BorderSizePixel  = 0
upButton.Parent           = menuFrame

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0,8)
upCorner.Parent       = upButton

local upStroke = Instance.new("UIStroke")
upStroke.Thickness = 2
upStroke.Color     = Color3.fromRGB(50,50,50)
upStroke.Parent    = upButton

local downButton = Instance.new("TextButton")
downButton.Size     = UDim2.new(0.4,0,0,25)
downButton.Position = UDim2.new(0.55,0,0.8,0)
downButton.Text     = "-50"
downButton.TextSize = 12
downButton.Font     = Enum.Font.GothamBold
downButton.TextColor3       = Color3.new(1,1,1)
downButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
downButton.BorderSizePixel  = 0
downButton.Parent           = menuFrame

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0,8)
downCorner.Parent       = downButton

local downStroke = Instance.new("UIStroke")
downStroke.Thickness = 2
downStroke.Color     = Color3.fromRGB(50,50,50)
downStroke.Parent    = downButton

-- Flechas de vuelo (↑ y ↓) para móvil
local ascendButton = Instance.new("TextButton")
ascendButton.Size     = UDim2.new(0,30,0,30)
ascendButton.Position = UDim2.new(0.75,0,0.88,0)
ascendButton.Text     = "↑"
ascendButton.TextSize = 18
ascendButton.Font     = Enum.Font.GothamBold
ascendButton.TextColor3       = Color3.new(1,1,1)
ascendButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
ascendButton.BorderSizePixel  = 0
ascendButton.Parent           = menuFrame

local ascendCorner = Instance.new("UICorner")
ascendCorner.CornerRadius = UDim.new(0,8)
ascendCorner.Parent       = ascendButton

local ascendStroke = Instance.new("UIStroke")
ascendStroke.Thickness = 2
ascendStroke.Color     = Color3.fromRGB(50,50,50)
ascendStroke.Parent    = ascendButton

local descendButton = Instance.new("TextButton")
descendButton.Size     = UDim2.new(0,30,0,30)
descendButton.Position = UDim2.new(0.85,0,0.88,0)
descendButton.Text     = "↓"
descendButton.TextSize = 18
descendButton.Font     = Enum.Font.GothamBold
descendButton.TextColor3       = Color3.new(1,1,1)
descendButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
descendButton.BorderSizePixel  = 0
descendButton.Parent           = menuFrame

local descendCorner = Instance.new("UICorner")
descendCorner.CornerRadius = UDim.new(0,8)
descendCorner.Parent       = descendButton

local descendStroke = Instance.new("UIStroke")
descendStroke.Thickness = 2
descendStroke.Color     = Color3.fromRGB(50,50,50)
descendStroke.Parent    = descendButton

-- Variables internas
local menuOpen = false
local walkUpdateConnection = nil

-- Funciones del Walkhack
local function applyWalkhack()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if walkhackEnabled then
        humanoid.WalkSpeed = currentSpeed
    else
        humanoid.WalkSpeed = 16
    end
end

local function toggleWalkhack()
    walkhackEnabled = not walkhackEnabled
    if walkhackEnabled then
        walkButton.Text             = "WALKHACK: ON"
        walkButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
        applyWalkhack()
        if not walkUpdateConnection then
            walkUpdateConnection = RunService.RenderStepped:Connect(function()
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = currentSpeed
                    end
                end
            end)
        end
    else
        walkButton.Text             = "WALKHACK: OFF"
        walkButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
        if walkUpdateConnection then
            walkUpdateConnection:Disconnect()
            walkUpdateConnection = nil
        end
        applyWalkhack()
    end
end

-- Funciones del ESP (creación, eliminación, activación)
local function removeESP(targetPlayer)
    if espFolders[targetPlayer] then
        espFolders[targetPlayer]:Destroy()
        espFolders[targetPlayer] = nil
    end
    if espUpdateConnections[targetPlayer] then
        espUpdateConnections[targetPlayer]:Disconnect()
        espUpdateConnections[targetPlayer] = nil
    end
end

local function createESP(targetPlayer)
    if not espEnabled or targetPlayer == player then return end
    if espFolders[targetPlayer] then return end
    local espFolder = Instance.new("Folder")
    espFolder.Name   = targetPlayer.Name .. "_ESP"
    espFolder.Parent = screenGui
    espFolders[targetPlayer] = espFolder
    local function update()
        if not espEnabled then return end
        local char = targetPlayer.Character
        if not char or not char.Parent then
            for _, child in ipairs(espFolder:GetChildren()) do child:Destroy() end
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then
            for _, child in ipairs(espFolder:GetChildren()) do child:Destroy() end
            return
        end
        for _, child in ipairs(espFolder:GetChildren()) do child:Destroy() end
        local box = Instance.new("BoxHandleAdornment")
        box.Name         = "ESP_Box"
        box.Adornee      = root
        box.AlwaysOnTop  = true
        box.ZIndex       = 1
        box.Size         = Vector3.new(4,6,2)
        box.Color3       = Color3.new(1,0,0)
        box.Transparency = 0.3
        box.Parent       = espFolder
        local billboard = Instance.new("BillboardGui")
        billboard.Name        = "ESP_Name"
        billboard.Adornee     = root
        billboard.Size        = UDim2.new(0,200,0,40)
        billboard.StudsOffset = Vector3.new(0,4,0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 1000
        billboard.Parent      = espFolder
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size   = UDim2.new(1,0,1,0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text   = targetPlayer.Name .. " [" .. math.floor(humanoid.Health) .. " HP]"
        nameLabel.TextColor3 = Color3.new(1,1,1)
        nameLabel.TextSize   = 20
        nameLabel.Font       = Enum.Font.GothamBold
        nameLabel.Parent     = billboard
        local line = Instance.new("LineHandleAdornment")
        line.Name        = "ESP_Line"
        line.Adornee     = workspace.Terrain
        line.ZIndex      = 0
        line.Thickness   = 2
        line.Color3      = Color3.new(1,1,0)
        line.Transparency= 0.5
        line.Parent      = espFolder
        local localChar  = player.Character
        local localRoot  = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if localRoot then
            line.Length = (root.Position - localRoot.Position).Magnitude
            line.CFrame = CFrame.new(localRoot.Position, root.Position)
        end
    end
    espUpdateConnections[targetPlayer] = RunService.RenderStepped:Connect(update)
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        espButton.Text             = "ESP: ON"
        espButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
        for _, other in ipairs(Players:GetPlayers()) do createESP(other) end
        if not playerAddedConnection then
            playerAddedConnection = Players.PlayerAdded:Connect(function(p)
                task.delay(1,function() createESP(p) end)
            end)
        end
        if not playerRemovingConnection then
            playerRemovingConnection = Players.PlayerRemoving:Connect(function(p)
                removeESP(p)
            end)
        end
    else
        espButton.Text             = "ESP: OFF"
        espButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
        for ply,_ in pairs(espFolders) do removeESP(ply) end
        espFolders = {}
        if playerAddedConnection then
            playerAddedConnection:Disconnect()
            playerAddedConnection = nil
        end
        if playerRemovingConnection then
            playerRemovingConnection:Disconnect()
            playerRemovingConnection = nil
        end
    end
end

-- Funciones del vuelo
local function startFlying()
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.maxTorque = Vector3.new(9e9,9e9,9e9)
    flyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
    flyBodyGyro.Parent = root
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.velocity = Vector3.new(0,0,0)
    flyBodyVelocity.maxForce = Vector3.new(9e9,9e9,9e9)
    flyBodyVelocity.P = 9e4
    flyBodyVelocity.Parent = root
    flyUpdateConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        local direction = Vector3.new(0,0,0)
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                direction = direction + moveDir
            end
        end
        if flyAscend then direction = direction + Vector3.new(0,1,0) end
        if flyDescend then direction = direction + Vector3.new(0,-1,0) end
        if direction.Magnitude > 0 then
            direction = direction.Unit
        end
        local speed = 50
        flyBodyVelocity.velocity = direction * speed
        local cam = workspace.CurrentCamera
        flyBodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFlying()
    if flyUpdateConnection then flyUpdateConnection:Disconnect() flyUpdateConnection=nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro=nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity=nil end
end

local function toggleFly()
    flyEnabled = not flyEnabled
    if flyEnabled then
        flyButton.Text             = "FLY: ON"
        flyButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
        startFlying()
    else
        flyButton.Text             = "FLY: OFF"
        flyButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
        stopFlying()
    end
end

-- Funciones del menú
local function openMenu()
    menuOpen           = true
    mainButton.Visible = false
    menuFrame.Visible  = true
end

local function closeMenu()
    menuOpen          = false
    menuFrame.Visible = false
    mainButton.Visible= true
end

-- Conexiones de botones
mainButton.MouseButton1Click:Connect(openMenu)
closeButton.MouseButton1Click:Connect(closeMenu)
espButton.MouseButton1Click:Connect(toggleESP)
walkButton.MouseButton1Click:Connect(toggleWalkhack)
flyButton.MouseButton1Click:Connect(toggleFly)

-- Flechas de vuelo
ascendButton.MouseButton1Down:Connect(function() flyAscend = true end)
ascendButton.MouseButton1Up:Connect(function() flyAscend = false end)
descendButton.MouseButton1Down:Connect(function() flyDescend = true end)
descendButton.MouseButton1Up:Connect(function() flyDescend = false end)

-- Ajuste de velocidad
upButton.MouseButton1Click:Connect(function()
    currentSpeed = currentSpeed + 50
    speedLabel.Text = "VELOCIDAD: "..currentSpeed
    applyWalkhack()
end)
downButton.MouseButton1Click:Connect(function()
    currentSpeed = math.max(50,currentSpeed - 50)
    speedLabel.Text = "VELOCIDAD: "..currentSpeed
    applyWalkhack()
end)

-- Reaplicar walkhack al reaparecer
player.CharacterAdded:Connect(function()
    task.wait(1)
    applyWalkhack()
end)

-- Aplicar velocidad inicial
applyWalkhack()

-- Lógica de arrastre para mover el menú y el botón
local dragging       = false
local dragStart      = nil
local startButtonPos = nil
local startMenuPos   = nil
local dragInput      = nil

local function beginDrag(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging       = true
        dragStart      = input.Position
        startButtonPos = mainButton.Position
        startMenuPos   = menuFrame.Position
        dragInput      = input
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

local function updateDragInput(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        if startButtonPos then
            mainButton.Position = UDim2.new(startButtonPos.X.Scale, startButtonPos.X.Offset + delta.X, startButtonPos.Y.Scale, startButtonPos.Y.Offset + delta.Y)
        end
        if startMenuPos then
            menuFrame.Position = UDim2.new(startMenuPos.X.Scale, startMenuPos.X.Offset + delta.X, startMenuPos.Y.Scale, startMenuPos.Y.Offset + delta.Y)
        end
    end
end)

mainButton.InputBegan:Connect(beginDrag)
mainButton.InputChanged:Connect(updateDragInput)
menuFrame.InputBegan:Connect(beginDrag)
menuFrame.InputChanged:Connect(updateDragInput)

-- Mensajes de depuración
print("🎯 ESP + WALKHACK + FLY CARGADO!")
print("ESP: Ver jugadores a través de paredes")
print("WALKHACK: Velocidad aumentada")
print("FLY: Usa el joystick virtual para moverte y las flechas ↑/↓ del menú para subir o bajar")
print("💡 Pulsa el botón de Menu para abrir la interfaz")
