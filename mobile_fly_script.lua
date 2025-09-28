--[[
    ESP + WalkHack + Fly (versión móvil mejorada)

    Esta versión divide el menú en dos secciones, agranda la ventana para que
    los botones no se sobrepongan y añade botones de ascenso/descenso fuera del
    menú (sólo visibles al volar). Compatible con móvil: el vuelo usa el joystick
    virtual para moverse y los botones ↑/↓ para subir/bajar.
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Estados
local espEnabled       = false
local walkhackEnabled  = false
local currentSpeed     = 100

-- Estado de vuelo
local flyEnabled         = false
local flyBodyGyro        = nil
local flyBodyVelocity    = nil
local flyUpdateConnection = nil
local flyAscend          = false
local flyDescend         = false

-- Almacenes de ESP
local espFolders           = {}
local espUpdateConnections = {}
local playerAddedConnection   = nil
local playerRemovingConnection= nil

-- GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name   = "ESPWalkhackMenu"
screenGui.Parent = CoreGui

-- Botón principal (Menu)
local mainButton = Instance.new("TextButton")
mainButton.Size     = UDim2.new(0,70,0,70)
mainButton.Position = UDim2.new(0.5,-35,0.1,0)
mainButton.Text     = "Menu"
mainButton.TextSize = 30
mainButton.Font     = Enum.Font.GothamBold
mainButton.TextColor3       = Color3.new(1,1,1)
mainButton.BackgroundColor3 = Color3.fromRGB(255,100,0)
mainButton.BorderSizePixel  = 0
mainButton.ZIndex           = 2
mainButton.Parent           = screenGui

local mainCorner = Instance.new("UICorner", mainButton)
mainCorner.CornerRadius = UDim.new(1,0)
local mainStroke = Instance.new("UIStroke", mainButton)
mainStroke.Thickness = 2
mainStroke.Color     = Color3.fromRGB(50,50,50)
local buttonGradient = Instance.new("UIGradient", mainButton)
buttonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,170,0)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,100,0))
}
buttonGradient.Rotation = 90

-- Marco del menú (más grande para separar secciones)
local menuFrame = Instance.new("Frame")
menuFrame.Size            = UDim2.new(0,270,0,340)
menuFrame.Position        = UDim2.new(0.5,-135,0.1,0)
menuFrame.BackgroundColor3= Color3.fromRGB(40,40,40)
menuFrame.BorderSizePixel = 0
menuFrame.Visible         = false
menuFrame.ZIndex          = 1
menuFrame.Parent          = screenGui

local menuCorner   = Instance.new("UICorner", menuFrame)
menuCorner.CornerRadius = UDim.new(0,15)
local menuGradient = Instance.new("UIGradient", menuFrame)
menuGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(50,50,50)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(25,25,25))
}
menuGradient.Rotation = 90

-- Título
local title = Instance.new("TextLabel", menuFrame)
title.Size            = UDim2.new(1,0,0,30)
title.Position        = UDim2.new(0,0,0,0)
title.Text            = "ESP • WALKHACK • FLY"
title.TextSize        = 16
title.Font            = Enum.Font.GothamBold
title.TextColor3      = Color3.new(1,1,1)
title.BackgroundColor3= Color3.fromRGB(25,25,25)
title.BorderSizePixel = 0

-- Encabezado de la sección ESP
local espSectionLabel = Instance.new("TextLabel", menuFrame)
espSectionLabel.Size            = UDim2.new(0.9,0,0,20)
espSectionLabel.Position        = UDim2.new(0.05,0,0.1,0)
espSectionLabel.Text            = "ESP"
espSectionLabel.TextSize        = 14
espSectionLabel.Font            = Enum.Font.GothamBold
espSectionLabel.TextColor3      = Color3.fromRGB(230,230,230)
espSectionLabel.BackgroundTransparency = 1

-- Botón ESP
local espButton = Instance.new("TextButton", menuFrame)
espButton.Size     = UDim2.new(0.9,0,0,40)
espButton.Position = UDim2.new(0.05,0,0.17,0)
espButton.Text     = "ESP: OFF"
espButton.TextSize = 14
espButton.Font     = Enum.Font.GothamBold
espButton.TextColor3       = Color3.new(1,1,1)
espButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
espButton.BorderSizePixel  = 0
local espCorner = Instance.new("UICorner", espButton)
espCorner.CornerRadius = UDim.new(0,8)
local espStroke = Instance.new("UIStroke", espButton)
espStroke.Thickness = 2
espStroke.Color     = Color3.fromRGB(50,50,50)

-- Encabezado de la sección PLAYER
local playerSectionLabel = Instance.new("TextLabel", menuFrame)
playerSectionLabel.Size            = UDim2.new(0.9,0,0,20)
playerSectionLabel.Position        = UDim2.new(0.05,0,0.32,0)
playerSectionLabel.Text            = "PLAYER"
playerSectionLabel.TextSize        = 14
playerSectionLabel.Font            = Enum.Font.GothamBold
playerSectionLabel.TextColor3      = Color3.fromRGB(230,230,230)
playerSectionLabel.BackgroundTransparency = 1

-- Botón Walkhack
local walkButton = Instance.new("TextButton", menuFrame)
walkButton.Size     = UDim2.new(0.9,0,0,40)
walkButton.Position = UDim2.new(0.05,0,0.38,0)
walkButton.Text     = "WALKHACK: OFF"
walkButton.TextSize = 14
walkButton.Font     = Enum.Font.GothamBold
walkButton.TextColor3       = Color3.new(1,1,1)
walkButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
walkButton.BorderSizePixel  = 0
local walkCorner = Instance.new("UICorner", walkButton)
walkCorner.CornerRadius = UDim.new(0,8)
local walkStroke = Instance.new("UIStroke", walkButton)
walkStroke.Thickness = 2
walkStroke.Color     = Color3.fromRGB(50,50,50)

-- Botón Fly
local flyButton = Instance.new("TextButton", menuFrame)
flyButton.Size     = UDim2.new(0.9,0,0,40)
flyButton.Position = UDim2.new(0.05,0,0.49,0)
flyButton.Text     = "FLY: OFF"
flyButton.TextSize = 14
flyButton.Font     = Enum.Font.GothamBold
flyButton.TextColor3       = Color3.new(1,1,1)
flyButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
flyButton.BorderSizePixel  = 0
local flyCorner = Instance.new("UICorner", flyButton)
flyCorner.CornerRadius = UDim.new(0,8)
local flyStroke = Instance.new("UIStroke", flyButton)
flyStroke.Thickness = 2
flyStroke.Color     = Color3.fromRGB(50,50,50)

-- Etiqueta de velocidad
local speedLabel = Instance.new("TextLabel", menuFrame)
speedLabel.Size     = UDim2.new(0.9,0,0,25)
speedLabel.Position = UDim2.new(0.05,0,0.63,0)
speedLabel.Text     = "VELOCIDAD: "..currentSpeed
speedLabel.TextSize = 12
speedLabel.Font     = Enum.Font.Gotham
speedLabel.TextColor3       = Color3.new(1,1,1)
speedLabel.BackgroundColor3 = Color3.fromRGB(60,60,60)
speedLabel.BorderSizePixel  = 0
local labelCorner = Instance.new("UICorner", speedLabel)
labelCorner.CornerRadius = UDim.new(0,8)

-- Botones de velocidad (+50 / -50)
local upButton = Instance.new("TextButton", menuFrame)
upButton.Size     = UDim2.new(0.4,0,0,25)
upButton.Position = UDim2.new(0.05,0,0.72,0)
upButton.Text     = "+50"
upButton.TextSize = 12
upButton.Font     = Enum.Font.GothamBold
upButton.TextColor3       = Color3.new(1,1,1)
upButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
upButton.BorderSizePixel  = 0
local upCorner = Instance.new("UICorner", upButton)
upCorner.CornerRadius = UDim.new(0,8)
local upStroke = Instance.new("UIStroke", upButton)
upStroke.Thickness = 2
upStroke.Color     = Color3.fromRGB(50,50,50)

local downButton = Instance.new("TextButton", menuFrame)
downButton.Size     = UDim2.new(0.4,0,0,25)
downButton.Position = UDim2.new(0.55,0,0.72,0)
downButton.Text     = "-50"
downButton.TextSize = 12
downButton.Font     = Enum.Font.GothamBold
downButton.TextColor3       = Color3.new(1,1,1)
downButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
downButton.BorderSizePixel  = 0
local downCorner = Instance.new("UICorner", downButton)
downCorner.CornerRadius = UDim.new(0,8)
local downStroke = Instance.new("UIStroke", downButton)
downStroke.Thickness = 2
downStroke.Color     = Color3.fromRGB(50,50,50)

-- Botón de cierre (X)
local closeButton = Instance.new("TextButton", menuFrame)
closeButton.Size     = UDim2.new(0,25,0,25)
closeButton.Position = UDim2.new(1,-30,0,5)
closeButton.Text     = "X"
closeButton.TextSize = 16
closeButton.Font     = Enum.Font.GothamBold
closeButton.TextColor3       = Color3.new(1,1,1)
closeButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
closeButton.BorderSizePixel  = 0
local closeCorner = Instance.new("UICorner", closeButton)
closeCorner.CornerRadius = UDim.new(0,4)
local closeStroke = Instance.new("UIStroke", closeButton)
closeStroke.Thickness = 2
closeStroke.Color     = Color3.fromRGB(50,50,50)

-- Botones de vuelo (↑ y ↓) fuera del menú, ocultos hasta que se active FLY
local ascendButton = Instance.new("TextButton", screenGui)
ascendButton.Size     = UDim2.new(0,40,0,40)
ascendButton.Position = UDim2.new(0.85,0,0.72,0) -- cerca del borde derecho, encima del salto
ascendButton.Text     = "↑"
ascendButton.TextSize = 20
ascendButton.Font     = Enum.Font.GothamBold
ascendButton.TextColor3       = Color3.new(1,1,1)
ascendButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
ascendButton.BorderSizePixel  = 0
ascendButton.Visible  = false
local ascendCorner = Instance.new("UICorner", ascendButton)
ascendCorner.CornerRadius = UDim.new(0,8)
local ascendStroke = Instance.new("UIStroke", ascendButton)
ascendStroke.Thickness = 2
ascendStroke.Color     = Color3.fromRGB(50,50,50)

local descendButton = Instance.new("TextButton", screenGui)
descendButton.Size     = UDim2.new(0,40,0,40)
descendButton.Position = UDim2.new(0.85,0,0.82,0)
descendButton.Text     = "↓"
descendButton.TextSize = 20
descendButton.Font     = Enum.Font.GothamBold
descendButton.TextColor3       = Color3.new(1,1,1)
descendButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
descendButton.BorderSizePixel  = 0
descendButton.Visible  = false
local descendCorner = Instance.new("UICorner", descendButton)
descendCorner.CornerRadius = UDim.new(0,8)
local descendStroke = Instance.new("UIStroke", descendButton)
descendStroke.Thickness = 2
descendStroke.Color     = Color3.fromRGB(50,50,50)

-- Manejadores del walkhack
local walkUpdateConnection = nil
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

-- Lógica del vuelo
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
        local humanoid  = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                direction = direction + moveDir
            end
        end
        if flyAscend  then direction = direction + Vector3.new(0,1,0) end
        if flyDescend then direction = direction + Vector3.new(0,-1,0) end
        if direction.Magnitude > 0 then
            direction = direction.Unit
        end
        flyBodyVelocity.velocity = direction * 50
        flyBodyGyro.CFrame       = workspace.CurrentCamera.CFrame
    end)
end

local function stopFlying()
    if flyUpdateConnection then flyUpdateConnection:Disconnect() flyUpdateConnection=nil end
    if flyBodyGyro     then flyBodyGyro:Destroy() flyBodyGyro=nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity=nil end
end

local function toggleFly()
    flyEnabled = not flyEnabled
    if flyEnabled then
        flyButton.Text             = "FLY: ON"
        flyButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
        ascendButton.Visible = true
        descendButton.Visible = true
        startFlying()
    else
        flyButton.Text             = "FLY: OFF"
        flyButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
        ascendButton.Visible = false
        descendButton.Visible = false
        stopFlying()
    end
end

-- ESP
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
            for _,child in ipairs(espFolder:GetChildren()) do child:Destroy() end
            return
        end
        local root    = char:FindFirstChild("HumanoidRootPart")
        local humanoid= char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then
            for _,child in ipairs(espFolder:GetChildren()) do child:Destroy() end
            return
        end
        for _,child in ipairs(espFolder:GetChildren()) do child:Destroy() end
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee      = root
        box.AlwaysOnTop  = true
        box.ZIndex       = 1
        box.Size         = Vector3.new(4,6,2)
        box.Color3       = Color3.new(1,0,0)
        box.Transparency = 0.3
        box.Parent       = espFolder
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee     = root
        billboard.Size        = UDim2.new(0,200,0,40)
        billboard.StudsOffset = Vector3.new(0,4,0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 1000
        billboard.Parent      = espFolder
        local nameLabel = Instance.new("TextLabel", billboard)
        nameLabel.Size               = UDim2.new(1,0,1,0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text               = targetPlayer.Name .. " ["..math.floor(humanoid.Health).." HP]"
        nameLabel.TextColor3         = Color3.new(1,1,1)
        nameLabel.TextSize           = 20
        nameLabel.Font               = Enum.Font.GothamBold
        local line = Instance.new("LineHandleAdornment")
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
        for _,other in ipairs(Players:GetPlayers()) do createESP(other) end
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
        if playerAddedConnection then playerAddedConnection:Disconnect() playerAddedConnection=nil end
        if playerRemovingConnection then playerRemovingConnection:Disconnect() playerRemovingConnection=nil end
    end
end

-- Mostrar/ocultar menú
local menuOpen = false
local function openMenu()
    menuOpen           = true
    mainButton.Visible = false
    menuFrame.Visible  = true
end
local function closeMenu()
    menuOpen           = false
    menuFrame.Visible  = false
    mainButton.Visible = true
end

-- Conexiones de botones y eventos
mainButton.MouseButton1Click:Connect(openMenu)
closeButton.MouseButton1Click:Connect(closeMenu)
espButton.MouseButton1Click:Connect(toggleESP)
walkButton.MouseButton1Click:Connect(toggleWalkhack)
flyButton.MouseButton1Click:Connect(toggleFly)

-- Botones de vuelo
ascendButton.MouseButton1Down:Connect(function() flyAscend  = true end)
ascendButton.MouseButton1Up:Connect(function()   flyAscend  = false end)
descendButton.MouseButton1Down:Connect(function() flyDescend= true end)
descendButton.MouseButton1Up:Connect(function()   flyDescend= false end)

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
applyWalkhack()

-- Lógica de arrastre para mover menú y botón
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
            mainButton.Position = UDim2.new(startButtonPos.X.Scale, startButtonPos.X.Offset + delta.X,
                                            startButtonPos.Y.Scale, startButtonPos.Y.Offset + delta.Y)
        end
        if startMenuPos then
            menuFrame.Position = UDim2.new(startMenuPos.X.Scale, startMenuPos.X.Offset + delta.X,
                                           startMenuPos.Y.Scale, startMenuPos.Y.Offset + delta.Y)
        end
    end
end)
mainButton.InputBegan:Connect(beginDrag)
mainButton.InputChanged:Connect(updateDragInput)
menuFrame.InputBegan:Connect(beginDrag)
menuFrame.InputChanged:Connect(updateDragInput)

-- Mensajes de información en la consola del desarrollador
print("🎯 ESP + WALKHACK + FLY CARGADO!")
print("ESP: Ver jugadores a través de paredes")
print("WALKHACK: Ajusta la velocidad de tu personaje")
print("FLY: Actívalo para volar; usa el joystick virtual para moverte y los botones ↑/↓ en pantalla para subir o bajar")
print("💡 Pulsa el botón 'Menu' para abrir la interfaz.  Usa los encabezados 'ESP' y 'PLAYER' para encontrar las opciones")
