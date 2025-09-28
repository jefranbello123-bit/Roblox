--[[
    ESP + WalkHack + Fly con menú multipanel (móvil y PC)
    - Menú dividido en secciones con barra lateral: “ESP” y “PLAYER”.
    - Arrastrar el menú no mueve la cámara ni el personaje.
    - Vuelo: botones ↑ y ↓ separados y más altos.
    - Se corrigen variables mal declaradas (gradientes, etc.) para que el menú abra correctamente.
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Estados globales
local espEnabled       = false
local walkhackEnabled  = false
local flyEnabled       = false
local currentSpeed     = 100
local flyBodyGyro, flyBodyVelocity, flyUpdateConnection
local flyAscend, flyDescend = false, false

-- Almacenes para ESP
local espFolders, espUpdateConnections = {}, {}
local playerAddedConnection, playerRemovingConnection = nil, nil

-- GUI principal
local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "ESPWalkhackMenu"

-- Botón principal
local mainButton = Instance.new("TextButton", screenGui)
mainButton.Size     = UDim2.new(0, 70, 0, 70)
mainButton.Position = UDim2.new(0.5, -35, 0.1, 0)
mainButton.Text     = "Menu"
mainButton.TextSize = 30
mainButton.Font     = Enum.Font.GothamBold
mainButton.TextColor3       = Color3.new(1,1,1)
mainButton.BackgroundColor3 = Color3.fromRGB(255,100,0)
mainButton.BorderSizePixel  = 0
mainButton.ZIndex = 2

local mainCorner = Instance.new("UICorner", mainButton)
mainCorner.CornerRadius = UDim.new(1,0)
local mainStroke = Instance.new("UIStroke", mainButton)
mainStroke.Thickness = 2
local mainGradient = Instance.new("UIGradient", mainButton)
mainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,170,0)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,100,0))
}
mainGradient.Rotation = 90

-- Marco del menú
local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size            = UDim2.new(0, 270, 0, 340)
menuFrame.Position        = UDim2.new(0.5, -135, 0.1, 0)
menuFrame.BackgroundColor3= Color3.fromRGB(40,40,40)
menuFrame.BorderSizePixel = 0
menuFrame.Visible         = false
menuFrame.ZIndex          = 1
local menuCorner = Instance.new("UICorner", menuFrame)
menuCorner.CornerRadius = UDim.new(0,15)
local menuGradient = Instance.new("UIGradient", menuFrame)
menuGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50,50,50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,25))
}
menuGradient.Rotation = 90

-- Título superior
local title = Instance.new("TextLabel", menuFrame)
title.Size            = UDim2.new(1, 0, 0, 30)
title.Text            = "ESP • WALKHACK • FLY"
title.TextSize        = 16
title.Font            = Enum.Font.GothamBold
title.TextColor3      = Color3.new(1,1,1)
title.BackgroundColor3= Color3.fromRGB(25,25,25)
title.BorderSizePixel = 0

-- Botón de cierre
local closeButton = Instance.new("TextButton", menuFrame)
closeButton.Size     = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.Text     = "X"
closeButton.TextSize = 16
closeButton.Font     = Enum.Font.GothamBold
closeButton.TextColor3       = Color3.new(1,1,1)
closeButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
closeButton.BorderSizePixel  = 0
local closeCorner = Instance.new("UICorner", closeButton)
closeCorner.CornerRadius = UDim.new(0, 4)
local closeStroke = Instance.new("UIStroke", closeButton)
closeStroke.Thickness = 2
closeStroke.Color     = Color3.fromRGB(50,50,50)

-- Botones de vuelo (↑ / ↓)
local ascendButton = Instance.new("TextButton", screenGui)
ascendButton.Size     = UDim2.new(0, 40, 0, 40)
ascendButton.Position = UDim2.new(0.80, 0, 0.70, 0)
ascendButton.Text     = "↑"
ascendButton.TextSize = 20
ascendButton.Font     = Enum.Font.GothamBold
ascendButton.TextColor3       = Color3.new(1,1,1)
ascendButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
ascendButton.BorderSizePixel  = 0
ascendButton.Visible  = false
Instance.new("UICorner", ascendButton).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", ascendButton).Thickness = 2
Instance.new("UIStroke", ascendButton).Color = Color3.fromRGB(50,50,50)

local descendButton = Instance.new("TextButton", screenGui)
descendButton.Size     = UDim2.new(0, 40, 0, 40)
descendButton.Position = UDim2.new(0.88, 0, 0.70, 0)
descendButton.Text     = "↓"
descendButton.TextSize = 20
descendButton.Font     = Enum.Font.GothamBold
descendButton.TextColor3       = Color3.new(1,1,1)
descendButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
descendButton.BorderSizePixel  = 0
descendButton.Visible  = false
Instance.new("UICorner", descendButton).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", descendButton).Thickness = 2
Instance.new("UIStroke", descendButton).Color = Color3.fromRGB(50,50,50)

-- Panel de navegación (izquierda)
local navFrame = Instance.new("Frame", menuFrame)
navFrame.Size     = UDim2.new(0, 80, 1, -30)
navFrame.Position = UDim2.new(0, 0, 0, 30)
navFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
navFrame.BorderSizePixel  = 0

-- Panel de contenido (derecha)
local contentFrame = Instance.new("Frame", menuFrame)
contentFrame.Size     = UDim2.new(1, -80, 1, -30)
contentFrame.Position = UDim2.new(0, 80, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0

-- Crea un botón para la barra lateral
local function createNavButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name.."NavButton"
    btn.Size = UDim2.new(1,0,0,40)
    btn.Position = UDim2.new(0,0,0,(order-1)*45)
    btn.Text     = name
    btn.TextSize = 14
    btn.Font     = Enum.Font.GothamBold
    btn.TextColor3       = Color3.fromRGB(200,200,200)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.BorderSizePixel  = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    Instance.new("UIStroke", btn).Thickness = 1
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(60,60,60)
    btn.Parent = navFrame
    return btn
end

local espNavButton    = createNavButton("ESP",    1)
local playerNavButton = createNavButton("PLAYER", 2)

-- Contenido de la sección ESP
local espContent = Instance.new("Frame", contentFrame)
espContent.Size = UDim2.new(1,0,1,0)
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
local espStroke = Instance.new("UIStroke", espToggle)
espStroke.Thickness = 2
espStroke.Color = Color3.fromRGB(50,50,50)

-- Contenido de la sección PLAYER
local playerContent = Instance.new("Frame", contentFrame)
playerContent.Size = UDim2.new(1,0,1,0)
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
local walkStroke = Instance.new("UIStroke", walkToggle)
walkStroke.Thickness = 2
walkStroke.Color = Color3.fromRGB(50,50,50)

-- Fly
local flyToggle = Instance.new("TextButton", playerContent)
flyToggle.Size     = UDim2.new(0.8,0,0,40)
flyToggle.Position = UDim2.new(0.1,0,0.22,0)
flyToggle.Text     = "FLY: OFF"
flyToggle.TextSize = 14
flyToggle.Font     = Enum.Font.GothamBold
flyToggle.TextColor3       = Color3.new(1,1,1)
flyToggle.BackgroundColor3 = Color3.fromRGB(200,60,60)
flyToggle.BorderSizePixel  = 0
Instance.new("UICorner", flyToggle).CornerRadius = UDim.new(0,8)
local flyStroke = Instance.new("UIStroke", flyToggle)
flyStroke.Thickness = 2
flyStroke.Color = Color3.fromRGB(50,50,50)

-- Speed label y botones +/- 50
local speedLabel = Instance.new("TextLabel", playerContent)
speedLabel.Size     = UDim2.new(0.8,0,0,25)
speedLabel.Position = UDim2.new(0.1,0,0.36,0)
speedLabel.Text     = "VELOCIDAD: "..currentSpeed
speedLabel.TextSize = 12
speedLabel.Font     = Enum.Font.Gotham
speedLabel.TextColor3       = Color3.new(1,1,1)
speedLabel.BackgroundColor3 = Color3.fromRGB(60,60,60)
speedLabel.BorderSizePixel  = 0
Instance.new("UICorner", speedLabel).CornerRadius = UDim.new(0,8)

local upButton = Instance.new("TextButton", playerContent)
upButton.Size     = UDim2.new(0.35,0,0,25)
upButton.Position = UDim2.new(0.1,0,0.46,0)
upButton.Text     = "+50"
upButton.TextSize = 12
upButton.Font     = Enum.Font.GothamBold
upButton.TextColor3       = Color3.new(1,1,1)
upButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
upButton.BorderSizePixel  = 0
Instance.new("UICorner", upButton).CornerRadius = UDim.new(0,8)
local upStroke2 = Instance.new("UIStroke", upButton)
upStroke2.Thickness = 2
upStroke2.Color = Color3.fromRGB(50,50,50)

local downButton = Instance.new("TextButton", playerContent)
downButton.Size     = UDim2.new(0.35,0,0,25)
downButton.Position = UDim2.new(0.55,0,0.46,0)
downButton.Text     = "-50"
downButton.TextSize = 12
downButton.Font     = Enum.Font.GothamBold
downButton.TextColor3       = Color3.new(1,1,1)
downButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
downButton.BorderSizePixel  = 0
Instance.new("UICorner", downButton).CornerRadius = UDim.new(0,8)
local downStroke2 = Instance.new("UIStroke", downButton)
downStroke2.Thickness = 2
downStroke2.Color = Color3.fromRGB(50,50,50)

-- Mostrar sección activa en navegación
local currentSection = "ESP"
local function updateNav()
    if currentSection == "ESP" then
        espNavButton.BackgroundColor3    = Color3.fromRGB(60,80,160)
        espNavButton.TextColor3          = Color3.new(1,1,1)
        playerNavButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
        playerNavButton.TextColor3       = Color3.fromRGB(200,200,200)
        espContent.Visible    = true
        playerContent.Visible = false
    else
        playerNavButton.BackgroundColor3 = Color3.fromRGB(60,80,160)
        playerNavButton.TextColor3       = Color3.new(1,1,1)
        espNavButton.BackgroundColor3    = Color3.fromRGB(45,45,45)
        espNavButton.TextColor3          = Color3.fromRGB(200,200,200)
        espContent.Visible    = false
        playerContent.Visible = true
    end
end
local function showSection(name)
    currentSection = name
    updateNav()
end
espNavButton.MouseButton1Click:Connect(function() showSection("ESP") end)
playerNavButton.MouseButton1Click:Connect(function() showSection("PLAYER") end)
updateNav()

-- Walkhack (funciones)
local walkUpdateConnection
local function applyWalkhack()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.WalkSpeed = walkhackEnabled and currentSpeed or 16
end
local function toggleWalkhack()
    walkhackEnabled = not walkhackEnabled
    walkToggle.Text = walkhackEnabled and "WALKHACK: ON" or "WALKHACK: OFF"
    walkToggle.BackgroundColor3 = walkhackEnabled and Color3.fromRGB(60,200,60) or Color3.fromRGB(200,60,60)
    if walkhackEnabled then
        applyWalkhack()
        if not walkUpdateConnection then
            walkUpdateConnection = RunService.RenderStepped:Connect(function()
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = currentSpeed end
            end)
        end
    else
        if walkUpdateConnection then walkUpdateConnection:Disconnect() walkUpdateConnection=nil end
        applyWalkhack()
    end
end

-- Fly (funciones)
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
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro=nil end
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

-- ESP (funciones)
local function removeESP(target)
    if espFolders[target] then espFolders[target]:Destroy() espFolders[target] = nil end
    if espUpdateConnections[target] then espUpdateConnections[target]:Disconnect() espUpdateConnections[target] = nil end
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
        for _,c in ipairs(folder:GetChildren()) do c:Destroy() end
        local box = Instance.new("BoxHandleAdornment", folder)
        box.Adornee      = root
        box.AlwaysOnTop  = true
        box.ZIndex       = 1
        box.Size         = Vector3.new(4,6,2)
        box.Color3       = Color3.new(1,0,0)
        box.Transparency = 0.3
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
        local line = Instance.new("LineHandleAdornment", folder)
        line.Adornee     = workspace.Terrain
        line.ZIndex      = 0
        line.Thickness   = 2
        line.Color3      = Color3.new(1,1,0)
        line.Transparency= 0.5
        local localChar = player.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
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

-- Mostrar y ocultar menú
local menuOpen = false
local function openMenu()
    menuOpen = true
    mainButton.Visible = false
    menuFrame.Visible  = true
end
local function closeMenuFunc()
    menuOpen = false
    menuFrame.Visible  = false
    mainButton.Visible = true
end

-- Conexiones de botones y eventos
mainButton.MouseButton1Click:Connect(openMenu)
closeButton.MouseButton1Click:Connect(closeMenuFunc)
espToggle.MouseButton1Click:Connect(toggleESP)
walkToggle.MouseButton1Click:Connect(toggleWalkhack)
flyToggle.MouseButton1Click:Connect(toggleFly)

-- Botones de vuelo
ascendButton.MouseButton1Down:Connect(function() flyAscend  = true  end)
ascendButton.MouseButton1Up:Connect(function()   flyAscend  = false end)
descendButton.MouseButton1Down:Connect(function() flyDescend= true  end)
descendButton.MouseButton1Up:Connect(function()   flyDescend= false end)

-- Ajuste de velocidad
upButton.MouseButton1Click:Connect(function()
    currentSpeed = currentSpeed + 50
    speedLabel.Text = "VELOCIDAD: "..currentSpeed
    applyWalkhack()
end)
downButton.MouseButton1Click:Connect(function()
    currentSpeed = math.max(50, currentSpeed - 50)
    speedLabel.Text = "VELOCIDAD: "..currentSpeed
    applyWalkhack()
end)

-- Reaplicar walkhack al reaparecer
player.CharacterAdded:Connect(function()
    task.wait(1)
    applyWalkhack()
end)
applyWalkhack()

-- Arrastrar el menú sin girar la cámara
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
        -- Captura el input para evitar que la cámara se mueva durante el arrastre
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

-- Mensajes informativos en consola
print("🎯 ESP + WALKHACK + FLY CARGADO CON MENÚ MULTIPANEL CORREGIDO.")
print("Pulsa 'Menu' para abrir o cerrar. Usa la barra lateral para navegar.")
print("Mientras arrastras el menú, la cámara no se moverá.")
