-- Script completo con Fly, ESP, Speed, Lock-On, Noclip, Anti-Hit mejorado y Knockback
-- Colócalo como LocalScript en StarterPlayerScripts o StarterGui.

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris     = game:GetService("Debris")

local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

-- GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "FlySpeedESPLockGui"
screenGui.ResetOnSpawn   = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder   = 100
screenGui.Parent         = playerGui

-- Botón circular
local dragFrame = Instance.new("Frame", screenGui)
dragFrame.Size              = UDim2.new(0,60,0,60)
dragFrame.Position          = UDim2.new(0.5,-30,0.5,-30)
dragFrame.BackgroundTransparency = 1
dragFrame.Active           = true
dragFrame.ZIndex           = 100

local openBtn = Instance.new("TextButton", dragFrame)
openBtn.Size             = UDim2.new(1,0,1,0)
openBtn.BackgroundColor3 = Color3.fromRGB(220,120,30)
openBtn.TextColor3       = Color3.new(1,1,1)
openBtn.Font             = Enum.Font.GothamBold
openBtn.TextSize         = 28
openBtn.Text             = "☰"
openBtn.BorderSizePixel  = 0
openBtn.ZIndex           = 101
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0.5,0)

-- Menú principal (4 filas x 2 columnas)
local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size              = UDim2.new(0,260,0,280)
menuFrame.Position          = UDim2.new(0.5,-130,0.5,-140)
menuFrame.BackgroundColor3  = Color3.fromRGB(20,20,20)
menuFrame.Visible           = false
menuFrame.Active            = true
menuFrame.ZIndex            = 100
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0,8)

local titleLabel = Instance.new("TextLabel", menuFrame)
titleLabel.Size              = UDim2.new(1,-40,0,24)
titleLabel.Position          = UDim2.new(0,20,0,8)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3        = Color3.new(1,1,1)
titleLabel.Font              = Enum.Font.GothamBold
titleLabel.TextSize          = 20
titleLabel.TextXAlignment    = Enum.TextXAlignment.Left
titleLabel.Text              = "Menú"
titleLabel.ZIndex            = 101

local closeBtn = Instance.new("TextButton", menuFrame)
closeBtn.Size             = UDim2.new(0,24,0,24)
closeBtn.Position         = UDim2.new(1,-32,0,8)
closeBtn.BackgroundColor3 = Color3.fromRGB(220,45,45)
closeBtn.TextColor3       = Color3.new(1,1,1)
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 18
closeBtn.Text             = "×"
closeBtn.BorderSizePixel  = 0
closeBtn.ZIndex           = 101
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0.5,0)

-- Helper para botones
local function createToggleButton(name,text,pos,color)
    local btn = Instance.new("TextButton", menuFrame)
    btn.Name             = name
    btn.Size             = UDim2.new(0,120,0,40)
    btn.Position         = pos
    btn.BackgroundColor3 = color
    btn.TextColor3       = Color3.new(1,1,1)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 18
    btn.Text             = text
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 101
    return btn
end

-- Botones para cada función
local flyToggleBtn     = createToggleButton("FlyToggle",    "Fly OFF",      UDim2.new(0,10,0,40),  Color3.fromRGB(220,45,45))
local espToggleBtn     = createToggleButton("ESPToggle",    "ESP OFF",      UDim2.new(0,130,0,40), Color3.fromRGB(45,140,220))
local speedToggleBtn   = createToggleButton("SpeedToggle",  "Speed OFF",    UDim2.new(0,10,0,90),  Color3.fromRGB(45,220,120))
local lockToggleBtn    = createToggleButton("LockToggle",   "Lock OFF",     UDim2.new(0,130,0,90), Color3.fromRGB(140,120,220))
local noclipToggleBtn  = createToggleButton("NoclipToggle", "Noclip OFF",   UDim2.new(0,10,0,140), Color3.fromRGB(220,90,45))
local antiHitToggleBtn = createToggleButton("AntiHitToggle","Anti-Hit OFF", UDim2.new(0,130,0,140),Color3.fromRGB(120,120,120))
local knockToggleBtn   = createToggleButton("KnockToggle",  "Knockback OFF",UDim2.new(0,10,0,190), Color3.fromRGB(200,100,220))

-- Botones laterales
local ascendBtn, descendBtn, speedUpBtn, speedDownBtn = Instance.new("TextButton"), Instance.new("TextButton"), Instance.new("TextButton"), Instance.new("TextButton")
ascendBtn.Parent, descendBtn.Parent, speedUpBtn.Parent, speedDownBtn.Parent = screenGui, screenGui, screenGui, screenGui
ascendBtn.Size             = UDim2.new(0,50,0,50)
ascendBtn.Position         = UDim2.new(0.88,0,0.48,0)
ascendBtn.BackgroundColor3 = Color3.fromRGB(220,45,45)
ascendBtn.TextColor3       = Color3.new(1,1,1)
ascendBtn.Font             = Enum.Font.GothamBold
ascendBtn.TextSize         = 22
ascendBtn.Text             = "↑"
ascendBtn.BorderSizePixel  = 0
ascendBtn.Visible          = false
ascendBtn.ZIndex           = 101

descendBtn.Size             = UDim2.new(0,50,0,50)
descendBtn.Position         = UDim2.new(0.88,0,0.62,0)
descendBtn.BackgroundColor3 = Color3.fromRGB(160,25,25)
descendBtn.TextColor3       = Color3.new(1,1,1)
descendBtn.Font             = Enum.Font.GothamBold
descendBtn.TextSize         = 22
descendBtn.Text             = "↓"
descendBtn.BorderSizePixel  = 0
descendBtn.Visible          = false
descendBtn.ZIndex           = 101

speedUpBtn.Size             = UDim2.new(0,50,0,50)
speedUpBtn.Position         = UDim2.new(0.74,0,0.48,0)
speedUpBtn.BackgroundColor3 = Color3.fromRGB(45,220,120)
speedUpBtn.TextColor3       = Color3.new(1,1,1)
speedUpBtn.Font             = Enum.Font.GothamBold
speedUpBtn.TextSize         = 22
speedUpBtn.Text             = "↑"
speedUpBtn.BorderSizePixel  = 0
speedUpBtn.Visible          = false
speedUpBtn.ZIndex           = 101

speedDownBtn.Size             = UDim2.new(0,50,0,50)
speedDownBtn.Position         = UDim2.new(0.74,0,0.62,0)
speedDownBtn.BackgroundColor3 = Color3.fromRGB(25,160,80)
speedDownBtn.TextColor3       = Color3.new(1,1,1)
speedDownBtn.Font             = Enum.Font.GothamBold
speedDownBtn.TextSize         = 22
speedDownBtn.Text             = "↓"
speedDownBtn.BorderSizePixel  = 0
speedDownBtn.Visible          = false
speedDownBtn.ZIndex           = 101

-- Estado y variables
local flying, espEnabled, speedEnabled, noclipEnabled, lockEnabled, antiHitEnabled, knockbackEnabled = false, false, false, false, false, false, false
local ascend, descend = false, false
local bodyGyro, bodyVel, flyConnection
local currentHighlights = {}
local espConnections    = {}
local espGlobalConnection
local originalWalkSpeed, currentSpeed, speedConnection
local speedIncrement, maxSpeed = 4, 100
local speedTarget
local noclipSpeed = 50
local noclipBodyGyro, noclipBodyVel, noclipConnection, noclipCollisionConn
local targetCharacter, lockConnection
local antiDamageConn, platformConn, stateConn, antiKnockConn
local knockbackConnections = {}
local knockbackPower, upwardPower = 100, 50

-- Mantenimiento de velocidad
local function maintainSpeed()
    if speedConnection then speedConnection:Disconnect() end
    speedConnection = RunService.Heartbeat:Connect(function()
        local char = localPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum and speedEnabled and currentSpeed then
            hum.WalkSpeed = currentSpeed
        end
    end)
end

-- Colisiones para noclip
local function setCharacterCollision(enabled)
    local char = localPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = enabled
        end
    end
end

-- Noclip
local function startNoclip()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    setCharacterCollision(false)
    noclipBodyGyro           = Instance.new("BodyGyro")
    noclipBodyGyro.P         = 9e4
    noclipBodyGyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
    noclipBodyGyro.Parent    = hrp
    noclipBodyVel            = Instance.new("BodyVelocity")
    noclipBodyVel.MaxForce   = Vector3.new(math.huge,math.huge,math.huge)
    noclipBodyVel.P          = 9e4
    noclipBodyVel.Parent     = hrp
    noclipConnection         = RunService.RenderStepped:Connect(function()
        local dir = Vector3.new()
        local char2 = localPlayer.Character
        if char2 then
            local hum = char2:FindFirstChildOfClass("Humanoid")
            if hum then
                local move = hum.MoveDirection
                if move.Magnitude > 0 then dir = dir + move end
            end
        end
        if ascend then dir = dir + Vector3.new(0,1,0) end
        if descend then dir = dir + Vector3.new(0,-1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit end
        noclipBodyVel.Velocity = dir * noclipSpeed
        local cam = workspace.CurrentCamera
        if cam then noclipBodyGyro.CFrame = cam.CFrame end
    end)
    noclipCollisionConn = RunService.Stepped:Connect(function()
        if noclipEnabled and localPlayer.Character then
            setCharacterCollision(false)
        end
    end)
end

local function stopNoclip()
    setCharacterCollision(true)
    if noclipConnection   then noclipConnection:Disconnect()   noclipConnection   = nil end
    if noclipCollisionConn then noclipCollisionConn:Disconnect() noclipCollisionConn = nil end
    if noclipBodyGyro      then noclipBodyGyro:Destroy()      noclipBodyGyro      = nil end
    if noclipBodyVel       then noclipBodyVel:Destroy()       noclipBodyVel       = nil end
end

-- Fly
local function startFly()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    bodyGyro          = Instance.new("BodyGyro")
    bodyGyro.P        = 9e4
    bodyGyro.MaxTorque= Vector3.new(math.huge,math.huge,math.huge)
    bodyGyro.Parent   = hrp
    bodyVel           = Instance.new("BodyVelocity")
    bodyVel.MaxForce  = Vector3.new(math.huge,math.huge,math.huge)
    bodyVel.P         = 9e4
    bodyVel.Parent    = hrp
    flyConnection     = RunService.RenderStepped:Connect(function()
        local dir = Vector3.new()
        local char2 = localPlayer.Character
        if char2 then
            local hum = char2:FindFirstChildOfClass("Humanoid")
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
    if bodyGyro      then bodyGyro:Destroy()      bodyGyro      = nil end
    if bodyVel       then bodyVel:Destroy()       bodyVel       = nil end
end

-- ESP
local function enableESP()
    espEnabled = true
    local function highlightPlayer(plr, character)
        if not character or not plr then return end
        local existing = currentHighlights[plr]
        if not existing then
            local h = Instance.new("Highlight")
            h.FillColor         = Color3.new(1,0,0)
            h.FillTransparency  = 0.5
            h.OutlineColor      = Color3.new(1,1,1)
            h.OutlineTransparency = 0
            h.Adornee           = character
            h.Parent            = character
            currentHighlights[plr] = h
        else
            existing.Adornee = character
            existing.Parent  = character
        end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            highlightPlayer(plr, plr.Character)
            if not espConnections[plr] then
                espConnections[plr] = plr.CharacterAdded:Connect(function(char)
                    if espEnabled then
                        task.defer(function() highlightPlayer(plr, char) end)
                    end
                end)
            end
        end
    end
    if not espGlobalConnection then
        espGlobalConnection = Players.PlayerAdded:Connect(function(plr)
            if plr ~= localPlayer and espEnabled then
                highlightPlayer(plr, plr.Character)
                espConnections[plr] = plr.CharacterAdded:Connect(function(char)
                    if espEnabled then
                        task.defer(function() highlightPlayer(plr, char) end)
                    end
                end)
            end
        end)
    end
end

local function disableESP()
    espEnabled = false
    for plr, conn in pairs(espConnections) do
        if conn then conn:Disconnect() end
        espConnections[plr] = nil
    end
    if espGlobalConnection then
        espGlobalConnection:Disconnect()
        espGlobalConnection = nil
    end
    for plr, highlight in pairs(currentHighlights) do
        if highlight then highlight:Destroy() end
        currentHighlights[plr] = nil
    end
end

-- Speed
local function enableSpeed()
    speedEnabled = true
    local char = localPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            originalWalkSpeed = originalWalkSpeed or hum.WalkSpeed
            currentSpeed      = math.max(hum.WalkSpeed * 2, originalWalkSpeed)
            if currentSpeed > maxSpeed then currentSpeed = maxSpeed end
            hum.WalkSpeed     = currentSpeed
            speedUpBtn.Visible   = true
            speedDownBtn.Visible = true
            maintainSpeed()
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
    currentSpeed      = nil
    speedUpBtn.Visible   = false
    speedDownBtn.Visible = false
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
end

-- Lock-On
local function findTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local camPos   = cam.CFrame.Position
    local camDir   = cam.CFrame.LookVector
    local bestTarget = nil
    local bestDot    = 0.9
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local vec  = root.Position - camPos
                local dist = vec.Magnitude
                if dist < 200 then
                    local dir  = vec / dist
                    local dot  = dir:Dot(camDir)
                    if dot > bestDot then
                        bestDot   = dot
                        bestTarget= char
                    end
                end
            end
        end
    end
    return bestTarget
end

local function startLock()
    targetCharacter = findTarget()
    if not targetCharacter then return end
    lockConnection = RunService.RenderStepped:Connect(function()
        if not targetCharacter or not targetCharacter.Parent then
            if lockConnection then lockConnection:Disconnect() lockConnection = nil end
            lockEnabled        = false
            lockToggleBtn.Text = "Lock OFF"
            return
        end
        local cam = workspace.CurrentCamera
        if cam then
            local camPos    = cam.CFrame.Position
            local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
            local lookAtPos = targetHRP and targetHRP.Position or targetCharacter:GetPivot().Position
            cam.CFrame      = CFrame.lookAt(camPos, lookAtPos)
        end
    end)
end

local function stopLock()
    if lockConnection then lockConnection:Disconnect() end
    lockConnection = nil
    targetCharacter = nil
end

-- Anti-Hit con control vertical
local function enableAntiHit()
    antiHitEnabled = true
    local char = localPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not antiDamageConn then
        antiDamageConn = hum.HealthChanged:Connect(function()
            if antiHitEnabled and hum then
                hum.Health = hum.MaxHealth
            end
        end)
    end
    if not platformConn then
        platformConn = hum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
            if antiHitEnabled and hum.PlatformStand then
                hum.PlatformStand = false
            end
        end)
    end
    if not stateConn then
        stateConn = hum.StateChanged:Connect(function(_, newState)
            if antiHitEnabled and (newState == Enum.HumanoidStateType.Freefall
             or newState == Enum.HumanoidStateType.FallingDown
             or newState == Enum.HumanoidStateType.Physics
             or newState == Enum.HumanoidStateType.Ragdoll) then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
    if not antiKnockConn then
        antiKnockConn = RunService.Heartbeat:Connect(function()
            if not antiHitEnabled then return end
            local char = localPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root then
                local move = hum.MoveDirection
                local desired = Vector3.new(move.X,0,move.Z)
                if desired.Magnitude > 0 then
                    desired = desired.Unit * (noclipEnabled and noclipSpeed or hum.WalkSpeed)
                end
                local currentVel = root.AssemblyLinearVelocity
                -- Si no estamos saltando y no pulsamos ascenso/descenso, cancelar la velocidad vertical
                local yVel = currentVel.Y
                local state = hum:GetState()
                if state ~= Enum.HumanoidStateType.Jumping 
                and state ~= Enum.HumanoidStateType.Freefall
                and not ascend and not descend then
                    yVel = 0
                end
                root.AssemblyLinearVelocity = Vector3.new(desired.X, yVel, desired.Z)
            end
        end)
    end
end

local function disableAntiHit()
    antiHitEnabled = false
    if antiDamageConn then antiDamageConn:Disconnect() antiDamageConn = nil end
    if platformConn then platformConn:Disconnect() platformConn = nil end
    if stateConn then stateConn:Disconnect() stateConn = nil end
    if antiKnockConn then antiKnockConn:Disconnect() antiKnockConn = nil end
end

-- Knockback
local function enableKnockback()
    knockbackEnabled = true
    local char = localPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local conn = part.Touched:Connect(function(hit)
                    if not knockbackEnabled then return end
                    local otherChar = hit:FindFirstAncestorOfClass("Model")
                    if otherChar and otherChar ~= char then
                        local otherHum = otherChar:FindFirstChildOfClass("Humanoid")
                        if otherHum and otherHum.Health > 0 then
                            local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
                            if otherRoot and root then
                                local dir = otherRoot.Position - root.Position
                                if dir.Magnitude > 0 then
                                    dir = dir.Unit
                                else
                                    dir = Vector3.new(0,0,0)
                                end
                                local bv = Instance.new("BodyVelocity")
                                bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                                bv.P        = 1e4
                                bv.Velocity = dir * knockbackPower + Vector3.new(0, upwardPower, 0)
                                bv.Parent   = otherRoot
                                Debris:AddItem(bv, 0.3)
                            end
                        end
                    end
                end)
                knockbackConnections[part] = conn
            end
        end
    end
end

local function disableKnockback()
    knockbackEnabled = false
    for part, conn in pairs(knockbackConnections) do
        if conn then conn:Disconnect() end
        knockbackConnections[part] = nil
    end
end

-- Reconectar funcionalidades al reaparecer
localPlayer.CharacterAdded:Connect(function()
    if knockbackEnabled then
        disableKnockback()
        enableKnockback()
    end
    if antiHitEnabled then
        enableAntiHit()
    end
    if speedEnabled then
        maintainSpeed()
    end
end)

-- Conectar botones
flyToggleBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyToggleBtn.Text = flying and "Fly ON" or "Fly OFF"
    ascendBtn.Visible  = flying or noclipEnabled
    descendBtn.Visible = flying or noclipEnabled
    if flying then startFly() else ascend=false descend=false stopFly() end
end)

espToggleBtn.MouseButton1Click:Connect(function()
    if espEnabled then
        disableESP()
        espToggleBtn.Text = "ESP OFF"
    else
        enableESP()
        espToggleBtn.Text = "ESP ON"
    end
end)

speedToggleBtn.MouseButton1Click:Connect(function()
    if speedEnabled then
        disableSpeed()
        speedToggleBtn.Text = "Speed OFF"
        if not noclipEnabled then
            speedUpBtn.Visible   = false
            speedDownBtn.Visible = false
        end
        speedTarget = noclipEnabled and "noclip" or nil
    else
        enableSpeed()
        speedToggleBtn.Text = "Speed ON"
        speedTarget = "walk"
    end
end)

lockToggleBtn.MouseButton1Click:Connect(function()
    if lockEnabled then
        lockEnabled        = false
        lockToggleBtn.Text = "Lock OFF"
        stopLock()
    else
        lockEnabled        = true
        lockToggleBtn.Text = "Lock ON"
        startLock()
    end
end)

noclipToggleBtn.MouseButton1Click:Connect(function()
    if noclipEnabled then
        noclipEnabled        = false
        noclipToggleBtn.Text = "Noclip OFF"
        stopNoclip()
        if not speedEnabled then
            speedUpBtn.Visible   = false
            speedDownBtn.Visible = false
        end
        if not flying then
            ascendBtn.Visible    = false
            descendBtn.Visible   = false
        end
        speedTarget = speedEnabled and "walk" or nil
    else
        noclipEnabled        = true
        noclipToggleBtn.Text = "Noclip ON"
        if flying then
            flying            = false
            flyToggleBtn.Text = "Fly OFF"
            ascend            = false
            descend           = false
            stopFly()
        end
        if speedEnabled then
            disableSpeed()
            speedToggleBtn.Text = "Speed OFF"
        end
        startNoclip()
        ascendBtn.Visible    = true
        descendBtn.Visible   = true
        speedUpBtn.Visible   = true
        speedDownBtn.Visible = true
        speedTarget          = "noclip"
    end
end)

antiHitToggleBtn.MouseButton1Click:Connect(function()
    if antiHitEnabled then
        disableAntiHit()
        antiHitToggleBtn.Text = "Anti-Hit OFF"
    else
        enableAntiHit()
        antiHitToggleBtn.Text = "Anti-Hit ON"
    end
end)

knockToggleBtn.MouseButton1Click:Connect(function()
    if knockbackEnabled then
        disableKnockback()
        knockToggleBtn.Text = "Knockback OFF"
    else
        enableKnockback()
        knockToggleBtn.Text = "Knockback ON"
    end
end)

-- Ajuste de velocidad con flechas
speedUpBtn.MouseButton1Click:Connect(function()
    if speedTarget == "walk" and speedEnabled then
        local char = localPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            currentSpeed = math.min(hum.WalkSpeed + speedIncrement, maxSpeed)
            hum.WalkSpeed= currentSpeed
        end
    elseif speedTarget == "noclip" and noclipEnabled then
        noclipSpeed  = math.min(noclipSpeed + speedIncrement, 200)
    end
end)

speedDownBtn.MouseButton1Click:Connect(function()
    if speedTarget == "walk" and speedEnabled then
        local char = localPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local minSpeed = originalWalkSpeed or hum.WalkSpeed
            currentSpeed   = math.max(hum.WalkSpeed - speedIncrement, minSpeed)
            hum.WalkSpeed  = currentSpeed
        end
    elseif speedTarget == "noclip" and noclipEnabled then
        noclipSpeed  = math.max(noclipSpeed - speedIncrement, 10)
    end
end)

-- Controles de ascenso/descenso
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

-- Arrastrar elementos
local draggingFlag, startPosInput, startPosGui
local function beginDrag(input, gui)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFlag  = true
        startPosInput = input.Position
        startPosGui   = gui.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingFlag = false end
        end)
    end
end
local function updateDrag(input, gui)
    if draggingFlag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startPosInput
        local newPos= UDim2.new(startPosGui.X.Scale,startPosGui.X.Offset+delta.X,
                                 startPosGui.Y.Scale,startPosGui.Y.Offset+delta.Y)
        local cam = workspace.CurrentCamera
        local viewport  = cam and cam.ViewportSize or Vector2.new(800,600)
        local guiSize   = gui.AbsoluteSize
        local maxX      = viewport.X - guiSize.X
        local maxY      = viewport.Y - guiSize.Y
        local clampedX  = math.clamp(newPos.X.Offset,0,maxX)
        local clampedY  = math.clamp(newPos.Y.Offset,0,maxY)
        gui.Position    = UDim2.new(0,clampedX,0,clampedY)
    end
end
local function makeDraggable(gui)
    gui.InputBegan:Connect(function(input) beginDrag(input, gui) end)
    gui.InputChanged:Connect(function(input) updateDrag(input, gui) end)
end

makeDraggable(dragFrame)
makeDraggable(menuFrame)
makeDraggable(openBtn)

print("✅ Script completo cargado con Fly, ESP, Speed, Lock, Noclip, Anti-Hit mejorado y Knockback")
