--[[
    ESP + WalkHack + Fly with Sidebar Menu and GodMode

    Este script añade ESP, WalkHack (ajuste de velocidad), Fly y GodMode.
    La interfaz se organiza en una barra lateral con secciones (ESP y PLAYER).
    El menú puede arrastrarse sin mover la cámara; los botones ↑ y ↓ para volar aparecen sólo al activar Fly.
    GodMode impide que pierdas vida.

    Nota: El uso de scripts de este tipo suele violar los Términos de Servicio de Roblox. Úsalo bajo tu responsabilidad.
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Estados de los hacks
local espEnabled      = false
local walkhackEnabled = false
local flyEnabled      = false
local currentSpeed    = 100

-- Variables para Fly
local flyBodyGyro, flyBodyVelocity, flyUpdateConnection
local flyAscend  = false
local flyDescend = false

-- Variables para GodMode
local godModeEnabled    = false
local godModeConnection = nil
local originalMaxHealth = nil

-- Almacenamiento para ESP
local espFolders           = {}  -- [player] = Folder
local espUpdateConnections = {}  -- [player] = RBXScriptConnection
local playerAddedConnection, playerRemovingConnection

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
do
    local corner = Instance.new("UICorner", mainButton)
    corner.CornerRadius = UDim.new(1,0)
    local stroke = Instance.new("UIStroke", mainButton)
    stroke.Thickness = 2
    stroke.Color     = Color3.fromRGB(50,50,50)
    local grad = Instance.new("UIGradient", mainButton)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,170,0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,100,0))
    }
    grad.Rotation = 90
end

-- Marco del menú
local menuFrame = Instance.new("Frame")
menuFrame.Size            = UDim2.new(0,280,0,350)
menuFrame.Position        = UDim2.new(0.5,-140,0.1,0)
menuFrame.BackgroundColor3= Color3.fromRGB(40,40,40)
menuFrame.BorderSizePixel = 0
menuFrame.Visible         = false
menuFrame.Parent          = screenGui
do
    local corner = Instance.new("UICorner", menuFrame)
    corner.CornerRadius = UDim.new(0,15)
    local grad = Instance.new("UIGradient", menuFrame)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50,50,50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,25))
    }
    grad.Rotation = 90
end

-- Título
local titleLabel = Instance.new("TextLabel", menuFrame)
titleLabel.Size     = UDim2.new(1,0,0,30)
titleLabel.Position = UDim2.new(0,0,0,0)
titleLabel.Text     = "ESP • WALKHACK • FLY"
titleLabel.TextSize = 16
titleLabel.Font     = Enum.Font.GothamBold
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.BackgroundColor3 = Color3.fromRGB(25,25,25)
titleLabel.BorderSizePixel = 0

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
do
    local corner = Instance.new("UICorner", closeButton)
    corner.CornerRadius = UDim.new(0,4)
    local stroke = Instance.new("UIStroke", closeButton)
    stroke.Thickness = 2
    stroke.Color     = Color3.fromRGB(50,50,50)
end

-- Panel de navegación (barra lateral)
local navFrame = Instance.new("Frame", menuFrame)
navFrame.Size     = UDim2.new(0,80,1,-30)
navFrame.Position = UDim2.new(0,0,0,30)
navFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
navFrame.BorderSizePixel  = 0

-- Panel de contenido (zona derecha)
local contentFrame = Instance.new("Frame", menuFrame)
contentFrame.Size     = UDim2.new(1,-80,1,-30)
contentFrame.Position = UDim2.new(0,80,0,30)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0

-- Función para crear botones de navegación
local function makeNavButton(text, index)
    local btn = Instance.new("TextButton", navFrame)
    btn.Name     = text.."Nav"
    btn.Size     = UDim2.new(1,0,0,40)
    btn.Position = UDim2.new(0,0,0,(index-1)*45)
    btn.Text     = text
    btn.TextSize = 14
    btn.Font     = Enum.Font.GothamBold
    btn.TextColor3       = Color3.fromRGB(200,200,200)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.BorderSizePixel  = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1
    stroke.Color     = Color3.fromRGB(60,60,60)
    return btn
end

-- Botones de navegación (ESP y PLAYER)
local navEsp    = makeNavButton("ESP",1)
local navPlayer = makeNavButton("PLAYER",2)

-- Sección ESP
local espContent = Instance.new("Frame", contentFrame)
espContent.Size     = UDim2.new(1,0,1,0)
espContent.BackgroundTransparency = 1
local espToggle = Instance.new("TextButton", espContent)
espToggle.Size     = UDim2.new(0.8,0,0,40)
espToggle.Position = UDim2.new(0.1,0,0.1,0)
espToggle.Text     = "ESP: OFF"
espToggle.TextSize = 14
espToggle.Font     = Enum.Font.GothamBold
espToggle.TextColor3       = Color3.new(1,1,1)
espToggle.BackgroundColor3 = Color3.fromRGB(200,60,60)
espToggle.BorderSizePixel  = 0
Instance.new("UICorner", espToggle).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", espToggle).Thickness = 2
Instance.new("UIStroke", espToggle).Color     = Color3.fromRGB(50,50,50)

-- Sección PLAYER
local playerContent = Instance.new("Frame", contentFrame)
playerContent.Size     = UDim2.new(1,0,1,0)
playerContent.BackgroundTransparency = 1

-- Walkhack
local walkToggle = Instance.new("TextButton", playerContent)
walkToggle.Size     = UDim2.new(0.8,0,0,40)
walkToggle.Position = UDim2.new(0.1,0,0.1,0)
walkToggle.Text     = "WALKHACK: OFF"
walkToggle.TextSize = 14
walkToggle.Font     = Enum.Font.GothamBold
walkToggle.TextColor3       = Color3.new(1,1,1)
walkToggle.BackgroundColor3 = Color3.fromRGB(200,60,60)
walkToggle.BorderSizePixel  = 0
Instance.new("UICorner", walkToggle).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", walkToggle).Thickness = 2
Instance.new("UIStroke", walkToggle).Color     = Color3.fromRGB(50,50,50)

-- Fly
local flyToggle = Instance.new("TextButton", playerContent)
flyToggle.Size     = UDim2.new(0.8,0,0,40)
flyToggle.Position = UDim2.new(0.1,0,0.25,0)
flyToggle.Text     = "FLY: OFF"
flyToggle.TextSize = 14
flyToggle.Font     = Enum.Font.GothamBold
flyToggle.TextColor3       = Color3.new(1,1,1)
flyToggle.BackgroundColor3 = Color3.fromRGB(200,60,60)
flyToggle.BorderSizePixel  = 0
Instance.new("UICorner", flyToggle).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", flyToggle).Thickness = 2
Instance.new("UIStroke", flyToggle).Color     = Color3.fromRGB(50,50,50)

-- GodMode
local godToggle = Instance.new("TextButton", playerContent)
godToggle.Size     = UDim2.new(0.8,0,0,40)
godToggle.Position = UDim2.new(0.1,0,0.40,0)
godToggle.Text     = "GODMODE: OFF"
godToggle.TextSize = 14
godToggle.Font     = Enum.Font.GothamBold
godToggle.TextColor3       = Color3.new(1,1,1)
godToggle.BackgroundColor3 = Color3.fromRGB(200,60,60)
godToggle.BorderSizePixel  = 0
Instance.new("UICorner", godToggle).CornerRadius = UDim.new(0,8)
local godStroke = Instance.new("UIStroke", godToggle)
godStroke.Thickness = 2
godStroke.Color = Color3.fromRGB(50,50,50)

-- Etiqueta de velocidad
local speedLabel = Instance.new("TextLabel", playerContent)
speedLabel.Size     = UDim2.new(0.8,0,0,25)
speedLabel.Position = UDim2.new(0.1,0,0.55,0)
speedLabel.Text     = "VELOCIDAD: "..currentSpeed
speedLabel.TextSize = 12
speedLabel.Font     = Enum.Font.Gotham
speedLabel.TextColor3       = Color3.new(1,1,1)
speedLabel.BackgroundColor3 = Color3.fromRGB(60,60,60)
speedLabel.BorderSizePixel  = 0
Instance.new("UICorner", speedLabel).CornerRadius = UDim.new(0,8)

-- Botones +50 / -50
local speedUp = Instance.new("TextButton", playerContent)
speedUp.Size     = UDim2.new(0.35,0,0,25)
speedUp.Position = UDim2.new(0.1,0,0.65,0)
speedUp.Text     = "+50"
speedUp.TextSize = 12
speedUp.Font     = Enum.Font.GothamBold
speedUp.TextColor3       = Color3.new(1,1,1)
speedUp.BackgroundColor3 = Color3.fromRGB(60,200,60)
speedUp.BorderSizePixel  = 0
Instance.new("UICorner", speedUp).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", speedUp).Thickness = 2
Instance.new("UIStroke", speedUp).Color     = Color3.fromRGB(50,50,50)

local speedDown = Instance.new("TextButton", playerContent)
speedDown.Size     = UDim2.new(0.35,0,0,25)
speedDown.Position = UDim2.new(0.55,0,0.65,0)
speedDown.Text     = "-50"
speedDown.TextSize = 12
speedDown.Font     = Enum.Font.GothamBold
speedDown.TextColor3       = Color3.new(1,1,1)
speedDown.BackgroundColor3 = Color3.fromRGB(200,60,60)
speedDown.BorderSizePixel  = 0
Instance.new("UICorner", speedDown).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", speedDown).Thickness = 2
Instance.new("UIStroke", speedDown).Color     = Color3.fromRGB(50,50,50)

-- Botones de vuelo ↑ y ↓ (fuera del menú)
local ascendButton = Instance.new("TextButton", screenGui)
ascendButton.Size     = UDim2.new(0,40,0,40)
ascendButton.Position = UDim2.new(0.80,0,0.70,0)
ascendButton.Text     = "↑"
ascendButton.TextSize = 20
ascendButton.Font     = Enum.Font.GothamBold
ascendButton.TextColor3       = Color3.new(1,1,1)
ascendButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
ascendButton.BorderSizePixel  = 0
ascendButton.Visible  = false
Instance.new("UICorner", ascendButton).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", ascendButton).Thickness = 2
Instance.new("UIStroke", ascendButton).Color     = Color3.fromRGB(50,50,50)

local descendButton = Instance.new("TextButton", screenGui)
descendButton.Size     = UDim2.new(0,40,0,40)
descendButton.Position = UDim2.new(0.88,0,0.70,0)
descendButton.Text     = "↓"
descendButton.TextSize = 20
descendButton.Font     = Enum.Font.GothamBold
descendButton.TextColor3       = Color3.new(1,1,1)
descendButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
descendButton.BorderSizePixel  = 0
descendButton.Visible  = false
Instance.new("UICorner", descendButton).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", descendButton).Thickness = 2
Instance.new("UIStroke", descendButton).Color     = Color3.fromRGB(50,50,50)

-- Función para actualizar la sección activa en la barra lateral
local currentSection = "ESP"
local function updateNav()
    if currentSection == "ESP" then
        navEsp.BackgroundColor3    = Color3.fromRGB(60,80,160)
        navEsp.TextColor3          = Color3.new(1,1,1)
        navPlayer.BackgroundColor3 = Color3.fromRGB(45,45,45)
        navPlayer.TextColor3       = Color3.fromRGB(200,200,200)
        espContent.Visible    = true
        playerContent.Visible = false
    else
        navPlayer.BackgroundColor3 = Color3.fromRGB(60,80,160)
        navPlayer.TextColor3       = Color3.new(1,1,1)
        navEsp.BackgroundColor3    = Color3.fromRGB(45,45,45)
        navEsp.TextColor3          = Color3.fromRGB(200,200,200)
        espContent.Visible    = false
        playerContent.Visible = true
    end
end
local function showSection(name)
    currentSection = name
    updateNav()
end
navEsp.MouseButton1Click:Connect(function() showSection("ESP") end)
navPlayer.MouseButton1Click:Connect(function() showSection("PLAYER") end)
updateNav()

-- Lógica de WalkHack
local walkUpdateConnection
local function applyWalkspeed()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = walkhackEnabled and currentSpeed or 16
        end
    end
end
local function toggleWalkhack()
    walkhackEnabled = not walkhackEnabled
    walkToggle.Text = walkhackEnabled and "WALKHACK: ON" or "WALKHACK: OFF"
    walkToggle.BackgroundColor3 = walkhackEnabled and Color3.fromRGB(60,200,60) or Color3.fromRGB(200,60,60)
    if walkhackEnabled then
        applyWalkspeed()
        if not walkUpdateConnection then
            walkUpdateConnection = RunService.RenderStepped:Connect(function()
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = currentSpeed end
            end)
        end
    else
        if walkUpdateConnection then walkUpdateConnection:Disconnect() walkUpdateConnection=nil end
        applyWalkspeed()
    end
end

-- Lógica de Fly
local function startFlying()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    flyBodyGyro = Instance.new("BodyGyro", root)
    flyBodyGyro.P = 9e4
    flyBodyGyro.maxTorque = Vector3.new(9e9,9e9,9e9)
    flyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
    flyBodyVelocity = Instance.new("BodyVelocity", root)
    flyBodyVelocity.velocity = Vector3.new(0,0,0)
    flyBodyVelocity.maxForce = Vector3.new(9e9,9e9,9e9)
    flyBodyVelocity.P = 9e4
    flyUpdateConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        local dir = Vector3.new(0,0,0)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then dir = dir + moveDir end
        end
        if flyAscend  then dir = dir + Vector3.new(0,1,0) end
        if flyDescend then dir = dir + Vector3.new(0,-1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit end
        flyBodyVelocity.velocity = dir * 50
        flyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
    end)
end
local function stopFlying()
    if flyUpdateConnection then flyUpdateConnection:Disconnect() flyUpdateConnection=nil end
    if flyBodyGyro     then flyBodyGyro:Destroy() flyBodyGyro=nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity=nil end
end
local function toggleFly()
    flyEnabled = not flyEnabled
    flyToggle.Text = flyEnabled and "FLY: ON" or "FLY: OFF"
    flyToggle.BackgroundColor3 = flyEnabled and Color3.fromRGB(60,200,60) or Color3.fromRGB(200,60,60)
    ascendButton.Visible  = flyEnabled
    descendButton.Visible = flyEnabled
    if flyEnabled then startFlying() else stopFlying() end
end

-- Lógica de GodMode
local function applyGodMode()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    -- Guardar MaxHealth original si no está guardado
    if not originalMaxHealth then
        originalMaxHealth = hum.MaxHealth
    end
    hum.MaxHealth = math.huge
    hum.Health = hum.MaxHealth
    -- Asegurar que la vida permanezca llena
    if godModeConnection then godModeConnection:Disconnect() end
    godModeConnection = hum.HealthChanged:Connect(function()
        if hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)
end

local function removeGodMode()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    if originalMaxHealth then
        hum.MaxHealth = originalMaxHealth
    end
    hum.Health = hum.MaxHealth
end

local function toggleGodMode()
    godModeEnabled = not godModeEnabled
    godToggle.Text = godModeEnabled and "GODMODE: ON" or "GODMODE: OFF"
    godToggle.BackgroundColor3 = godModeEnabled and Color3.fromRGB(60,200,60) or Color3.fromRGB(200,60,60)
    if godModeEnabled then
        applyGodMode()
    else
        removeGodMode()
    end
end

-- Lógica de ESP
local function removeESP(target)
    if espFolders[target] then espFolders[target]:Destroy() espFolders[target] = nil end
    if espUpdateConnections[target] then espUpdateConnections[target]:Disconnect() espUpdateConnections[target]=nil end
end
local function createESP(target)
    if not espEnabled or target == player or espFolders[target] then return end
    local folder = Instance.new("Folder", screenGui)
    folder.Name = target.Name.."_ESP"
    espFolders[target] = folder
    local function update()
        if not espEnabled then return end
        local char = target.Character
        if not char or not char.Parent then
            for _,c in ipairs(folder:GetChildren()) do c:Destroy() end
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then
            for _,c in ipairs(folder:GetChildren()) do c:Destroy() end
            return
        end
        -- Limpiar antes de recrear
        for _,c in ipairs(folder:GetChildren()) do c:Destroy() end
        -- Caja
        local box = Instance.new("BoxHandleAdornment", folder)
        box.Adornee      = root
        box.AlwaysOnTop  = true
        box.ZIndex       = 1
        box.Size         = Vector3.new(4,6,2)
        box.Color3       = Color3.new(1,0,0)
        box.Transparency = 0.3
        -- Nombre flotante
        local billboard = Instance.new("BillboardGui", folder)
        billboard.Adornee     = root
        billboard.Size        = UDim2.new(0,200,0,40)
        billboard.StudsOffset = Vector3.new(0,4,0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 1000
        local label = Instance.new("TextLabel", billboard)
        label.Size               = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.Text               = target.Name.." ["..math.floor(hum.Health).." HP]"
        label.TextColor3         = Color3.new(1,1,1)
        label.TextSize           = 20
        label.Font               = Enum.Font.GothamBold
        -- Línea
        local line = Instance.new("LineHandleAdornment", folder)
        line.Adornee     = workspace.Terrain
        line.ZIndex      = 0
        line.Thickness   = 2
        line.Color3      = Color3.new(1,1,0)
        line.Transparency= 0.5
        local localChar  = player.Character
        local localRoot  = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if localRoot then
            line.Length = (root.Position - localRoot.Position).Magnitude
            line.CFrame = CFrame.new(localRoot.Position, root.Position)
        end
    end
    espUpdateConnections[target] = RunService.RenderStepped:Connect(update)
end
local function toggleESP()
    espEnabled = not espEnabled
    espToggle.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espToggle.BackgroundColor3 = espEnabled and Color3.fromRGB(60,200,60) or Color3.fromRGB(200,60,60)
    if espEnabled then
        for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
        if not playerAddedConnection then
            playerAddedConnection = Players.PlayerAdded:Connect(function(p) task.delay(1,function() createESP(p) end) end)
        end
        if not playerRemovingConnection then
            playerRemovingConnection = Players.PlayerRemoving:Connect(function(p) removeESP(p) end)
        end
    else
        for ply,_ in pairs(espFolders) do removeESP(ply) end
        if playerAddedConnection then playerAddedConnection:Disconnect() playerAddedConnection=nil end
        if playerRemovingConnection then playerRemovingConnection:Disconnect() playerRemovingConnection=nil end
    end
end

-- Conexión de eventos de cada control
espToggle.MouseButton1Click:Connect(toggleESP)
walkToggle.MouseButton1Click:Connect(toggleWalkhack)
flyToggle.MouseButton1Click:Connect(toggleFly)
godToggle.MouseButton1Click:Connect(toggleGodMode)

speedUp.MouseButton1Click:Connect(function()
    currentSpeed = currentSpeed + 50
    speedLabel.Text = "VELOCIDAD: "..currentSpeed
    applyWalkspeed()
end)
speedDown.MouseButton1Click:Connect(function()
    currentSpeed = math.max(50, currentSpeed - 50)
    speedLabel.Text = "VELOCIDAD: "..currentSpeed
    applyWalkspeed()
end)
ascendButton.MouseButton1Down:Connect(function() flyAscend = true end)
ascendButton.MouseButton1Up:Connect(function()   flyAscend = false end)
descendButton.MouseButton1Down:Connect(function() flyDescend = true end)
descendButton.MouseButton1Up:Connect(function()   flyDescend = false end)

-- Mostrar/ocultar menú
local menuOpen = false
local function openMenu()
    menuOpen           = true
    mainButton.Visible = false
    menuFrame.Visible  = true
end
local function closeMenuFrame()
    menuOpen           = false
    menuFrame.Visible  = false
    mainButton.Visible = true
end
mainButton.MouseButton1Click:Connect(openMenu)
closeButton.MouseButton1Click:Connect(closeMenuFrame)

-- Reaplicar WalkHack y GodMode al reaparecer
player.CharacterAdded:Connect(function()
    task.wait(1)
    applyWalkspeed()
    if godModeEnabled then
        applyGodMode()
    end
end)
-- Aplicar estados iniciales
applyWalkspeed()
if godModeEnabled then
    applyGodMode()
end

-- Lógica de arrastre (no mueve la cámara)
local dragging, dragStart, startButtonPos, startMenuPos, dragInputRef = false, nil, nil, nil, nil
local function beginDrag(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging       = true
        dragStart      = input.Position
        startButtonPos = mainButton.Position
        startMenuPos   = menuFrame.Position
        dragInputRef   = input
        UserInputService.ModalEnabled = true
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                UserInputService.ModalEnabled = false
            end
        end)
    end
end
local function updateDragInput(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInputRef = input
    end
end
UserInputService.InputChanged:Connect(function(input)
    if input == dragInputRef and dragging then
        local delta = input.Position - dragStart
        mainButton.Position = UDim2.new(startButtonPos.X.Scale, startButtonPos.X.Offset + delta.X,
                                        startButtonPos.Y.Scale, startButtonPos.Y.Offset + delta.Y)
        menuFrame.Position = UDim2.new(startMenuPos.X.Scale, startMenuPos.X.Offset + delta.X,
                                       startMenuPos.Y.Scale, startMenuPos.Y.Offset + delta.Y)
    end
end)
mainButton.InputBegan:Connect(beginDrag)
mainButton.InputChanged:Connect(updateDragInput)
menuFrame.InputBegan:Connect(beginDrag)
menuFrame.InputChanged:Connect(updateDragInput)

print("🎯 Menú multipanel con GodMode cargado. Pulsa 'Menu' para abrir y navega entre ESP y PLAYER.")
