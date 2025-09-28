-- Fly, Speed and ESP menu for mobile
-- Coloca este LocalScript en StarterPlayerScripts o StarterGui.
-- Usa este script sólo en tus propios proyectos; podría violar los Términos de Roblox en juegos públicos.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlySpeedESPGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

-- Botón circular que abre el menú
local dragFrame = Instance.new("Frame")
dragFrame.Size = UDim2.new(0, 60, 0, 60)
dragFrame.Position = UDim2.new(0.5, -30, 0.5, -30)
dragFrame.BackgroundTransparency = 1
dragFrame.Active = true
dragFrame.ZIndex = 100
dragFrame.Parent = screenGui

local openBtn = Instance.new("TextButton", dragFrame)
openBtn.Size = UDim2.new(1, 0, 1, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(220, 120, 30)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 28
openBtn.Text = "☰"
openBtn.BorderSizePixel = 0
openBtn.ZIndex = 101
local openCorner = Instance.new("UICorner", openBtn)
openCorner.CornerRadius = UDim.new(0.5,0)

-- Menú flotante
local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size = UDim2.new(0,200,0,270)
menuFrame.Position = UDim2.new(0.5,-100,0.5,-135)
menuFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.ZIndex = 100
local menuCorner = Instance.new("UICorner", menuFrame)
menuCorner.CornerRadius = UDim.new(0,8)

local titleLabel = Instance.new("TextLabel", menuFrame)
titleLabel.Size = UDim2.new(1,-40,0,24)
titleLabel.Position = UDim2.new(0,20,0,8)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = "Menú"
titleLabel.ZIndex = 101

local closeBtn = Instance.new("TextButton", menuFrame)
closeBtn.Size = UDim2.new(0,24,0,24)
closeBtn.Position = UDim2.new(1,-32,0,8)
closeBtn.BackgroundColor3 = Color3.fromRGB(220,45,45)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Text = "×"
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 101
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0.5,0)

-- Función para crear botones de las opciones
local function createToggleButton(name, text, position, color)
    local btn = Instance.new("TextButton", menuFrame)
    btn.Name = name
    btn.Size = UDim2.new(0,140,0,40)
    btn.Position = position
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text
    btn.BorderSizePixel = 0
    btn.ZIndex = 101
    return btn
end

-- Crear los botones de las funciones
local flyToggleBtn   = createToggleButton("FlyToggle","Fly OFF",  UDim2.new(0.5,-70,0,50),  Color3.fromRGB(220,45,45))
local espToggleBtn   = createToggleButton("ESPToggle","ESP OFF",  UDim2.new(0.5,-70,0,100), Color3.fromRGB(45,140,220))
local speedToggleBtn = createToggleButton("SpeedToggle","Speed OFF",UDim2.new(0.5,-70,0,150),Color3.fromRGB(45,220,120))

-- Botones de ascenso y descenso
local ascendBtn = Instance.new("TextButton", menuFrame)
ascendBtn.Name = "AscendBtn"
ascendBtn.Size = UDim2.new(0,50,0,50)
ascendBtn.Position = UDim2.new(0.5,-60,0,200)
ascendBtn.BackgroundColor3 = Color3.fromRGB(220,45,45)
ascendBtn.TextColor3 = Color3.new(1,1,1)
ascendBtn.Font = Enum.Font.GothamBold
ascendBtn.TextSize = 22
ascendBtn.Text = "↑"
ascendBtn.BorderSizePixel = 0
ascendBtn.Visible = false
ascendBtn.ZIndex = 101

local descendBtn = Instance.new("TextButton", menuFrame)
descendBtn.Name = "DescendBtn"
descendBtn.Size = UDim2.new(0,50,0,50)
descendBtn.Position = UDim2.new(0.5,10,0,200)
descendBtn.BackgroundColor3 = Color3.fromRGB(160,25,25)
descendBtn.TextColor3 = Color3.new(1,1,1)
descendBtn.Font = Enum.Font.GothamBold
descendBtn.TextSize = 22
descendBtn.Text = "↓"
descendBtn.BorderSizePixel = 0
descendBtn.Visible = false
descendBtn.ZIndex = 101

-- Variables de vuelo
local flying = false
local bodyGyro, bodyVel, flyConnection
local ascend, descend = false, false

-- Variables de ESP
local espEnabled = false
local currentHighlights = {}

-- Variables de velocidad
local speedEnabled = false
local originalWalkSpeed

-- Funciones para volar
local function startFly()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
    bodyGyro.Parent = hrp
    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
    bodyVel.P = 9e4
    bodyVel.Parent = hrp
    flyConnection = RunService.RenderStepped:Connect(function()
        local dir = Vector3.new()
        local char = localPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local move = hum.MoveDirection
                if move.Magnitude > 0 then dir = dir + move end
            end
        end
        if ascend then dir = dir + Vector3.new(0,1,0) end
        if descend then dir = dir + Vector3.new(0,-1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit end
        bodyVel.Velocity = dir * 50
        local cam = workspace.CurrentCamera
        if cam then bodyGyro.CFrame = cam.CFrame end
    end)
end

local function stopFly()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVel then bodyVel:Destroy() bodyVel = nil end
end

-- Funciones para ESP
local function enableESP()
    espEnabled = true
    for _,plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char and not currentHighlights[plr] then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = char
            highlight.FillColor = Color3.new(1,0,0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.new(1,1,1)
            highlight.OutlineTransparency = 0
            highlight.Parent = char
            currentHighlights[plr] = highlight
        end
    end
end

local function disableESP()
    espEnabled = false
    for plr, highlight in pairs(currentHighlights) do
        if highlight then highlight:Destroy() end
    end
    currentHighlights = {}
end

-- Funciones para velocidad
local function enableSpeed()
    speedEnabled = true
    local char = localPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            originalWalkSpeed = hum.WalkSpeed
            hum.WalkSpeed = 32
        end
    end
end

local function disableSpeed()
    speedEnabled = false
    local char = localPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and originalWalkSpeed then hum.WalkSpeed = originalWalkSpeed end
    end
    originalWalkSpeed = nil
end

-- Mantener el speed al reaparecer
localPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    if speedEnabled then
        wait(0.1)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 32 end
    end
end)

-- Actualizar ESP en nuevos jugadores
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        if espEnabled then
            wait(1)
            if not currentHighlights[plr] then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = char
                highlight.FillColor = Color3.new(1,0,0)
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.new(1,1,1)
                highlight.OutlineTransparency = 0
                highlight.Parent = char
                currentHighlights[plr] = highlight
            end
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if currentHighlights[plr] then
        currentHighlights[plr]:Destroy()
        currentHighlights[plr] = nil
    end
end)

-- Acciones de los botones
flyToggleBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyToggleBtn.Text = flying and "Fly ON" or "Fly OFF"
    ascendBtn.Visible = flying
    descendBtn.Visible = flying
    if flying then startFly() else ascend=false descend=false stopFly() end
end)

espToggleBtn.MouseButton1Click:Connect(function()
    if espEnabled then disableESP() espToggleBtn.Text = "ESP OFF"
    else enableESP() espToggleBtn.Text = "ESP ON" end
end)

speedToggleBtn.MouseButton1Click:Connect(function()
    if speedEnabled then disableSpeed() speedToggleBtn.Text = "Speed OFF"
    else enableSpeed() speedToggleBtn.Text = "Speed ON" end
end)

ascendBtn.MouseButton1Down:Connect(function() ascend = true end)
ascendBtn.MouseButton1Up:Connect(function() ascend = false end)
descendBtn.MouseButton1Down:Connect(function() descend = true end)
descendBtn.MouseButton1Up:Connect(function() descend = false end)

-- Mostrar/ocultar menú
openBtn.MouseButton1Click:Connect(function()
    dragFrame.Visible = false
    menuFrame.Visible = true
end)
closeBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    dragFrame.Visible = true
end)

-- Arrastrar el círculo y el menú
local dragging, startPosInput, startPosGui = false
local function beginDrag(input, gui)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        startPosInput = input.Position
        startPosGui = gui.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end

local function updateDrag(input, gui)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startPosInput
        local newPos = UDim2.new(startPosGui.X.Scale, startPosGui.X.Offset + delta.X,
                                 startPosGui.Y.Scale, startPosGui.Y.Offset + delta.Y)
        local cam = workspace.CurrentCamera
        local viewport = cam and cam.ViewportSize or Vector2.new(800,600)
        local guiSize = gui.AbsoluteSize
        local maxX = viewport.X - guiSize.X
        local maxY = viewport.Y - guiSize.Y
        local clampedX = math.clamp(newPos.X.Offset,0,maxX)
        local clampedY = math.clamp(newPos.Y.Offset,0,maxY)
        gui.Position = UDim2.new(0,clampedX,0,clampedY)
    end
end

local function makeDraggable(gui)
    gui.InputBegan:Connect(function(input) beginDrag(input, gui) end)
    gui.InputChanged:Connect(function(input) updateDrag(input, gui) end)
end

makeDraggable(dragFrame)
makeDraggable(menuFrame)

print("✅ Fly, ESP y Speed cargados")
