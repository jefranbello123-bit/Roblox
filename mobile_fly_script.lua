-- Script BASE ESTABLE (revert) — Fly, ESP, Speed, Lock Quick Button, Noclip, Anti-Hit, Knockback, Floor y HUD
-- ✅ Vuelve a las mismas rutinas/estructuras que te funcionaban (sin Kill Aura ni Fast Attack, sin estilos extra).
-- ⚠️ Pega este LocalScript en StarterPlayerScripts o StarterGui (móvil primero, sin dependencias externas).

--==================================================
-- SERVICIOS
--==================================================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris     = game:GetService("Debris")

local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

--==================================================
-- GUI PRINCIPAL (MISMA ESTRUCTURA QUE FUNCIONABA)
--==================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "FlySpeedESPLockGui"
screenGui.ResetOnSpawn   = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder   = 100
screenGui.Parent         = playerGui

-- Botón circular (☰) para abrir menú (movible)
local dragFrame = Instance.new("Frame", screenGui)
dragFrame.Size                   = UDim2.new(0,60,0,60)
dragFrame.Position               = UDim2.new(0.5,-30,0.5,-30)
dragFrame.BackgroundTransparency = 1
dragFrame.Active                 = true
dragFrame.ZIndex                 = 100

local openBtn = Instance.new("TextButton", dragFrame)
openBtn.Size             = UDim2.new(1,0,1,0)
openBtn.BackgroundColor3 = Color3.fromRGB(50,170,160)   -- TEAL
openBtn.TextColor3       = Color3.new(1,1,1)
openBtn.Font             = Enum.Font.GothamBold
openBtn.TextSize         = 28
openBtn.Text             = "☰"
openBtn.BorderSizePixel  = 0
openBtn.ZIndex           = 101
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0.5,0)

-- Menú principal (5 filas x 2 columnas)
local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size              = UDim2.new(0,260,0,320)
menuFrame.Position          = UDim2.new(0.5,-130,0.5,-160)
menuFrame.BackgroundColor3  = Color3.fromRGB(24,24,30)
menuFrame.Visible           = false
menuFrame.Active            = true
menuFrame.ZIndex            = 100
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0,8)

local titleLabel = Instance.new("TextLabel", menuFrame)
titleLabel.Size                   = UDim2.new(1,-40,0,24)
titleLabel.Position               = UDim2.new(0,20,0,8)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3             = Color3.new(1,1,1)
titleLabel.Font                   = Enum.Font.GothamBold
titleLabel.TextSize               = 20
titleLabel.TextXAlignment         = Enum.TextXAlignment.Left
titleLabel.Text                   = "Menú"
titleLabel.ZIndex                 = 101

local closeBtn = Instance.new("TextButton", menuFrame)
closeBtn.Size             = UDim2.new(0,24,0,24)
closeBtn.Position         = UDim2.new(1,-32,0,8)
closeBtn.BackgroundColor3 = Color3.fromRGB(235,70,70)
closeBtn.TextColor3       = Color3.new(1,1,1)
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 18
closeBtn.Text             = "×"
closeBtn.BorderSizePixel  = 0
closeBtn.ZIndex           = 101
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0.5,0)

-- Helper para botones del menú
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

-- Botones del menú (paleta original)
local flyToggleBtn     = createToggleButton("FlyToggle",     "Fly OFF",         UDim2.new(0,10,0,40),  Color3.fromRGB(0,170,255))
local espToggleBtn     = createToggleButton("ESPToggle",     "ESP OFF",         UDim2.new(0,130,0,40), Color3.fromRGB(255,105,180))
local speedToggleBtn   = createToggleButton("SpeedToggle",   "Speed OFF",       UDim2.new(0,10,0,90),  Color3.fromRGB(255,165,0))
local lockToggleBtn    = createToggleButton("LockToggle",    "Lock Btn OFF",    UDim2.new(0,130,0,90), Color3.fromRGB(120,200,255))
local noclipToggleBtn  = createToggleButton("NoclipToggle",  "Noclip OFF",      UDim2.new(0,10,0,140), Color3.fromRGB(255,99,71))
local antiHitToggleBtn = createToggleButton("AntiHitToggle", "Anti-Hit OFF",    UDim2.new(0,130,0,140),Color3.fromRGB(100,110,130))
local knockToggleBtn   = createToggleButton("KnockToggle",   "Knockback OFF",   UDim2.new(0,10,0,190), Color3.fromRGB(144,238,144))
local floorToggleBtn   = createToggleButton("FloorToggle",   "Floor OFF",       UDim2.new(0,130,0,190),Color3.fromRGB(210,180,140))
local hudToggleBtn     = createToggleButton("HUDToggle",     "HUD OFF",         UDim2.new(0,10,0,240), Color3.fromRGB(80,120,200))

-- Botones laterales (ascenso/descenso y speed +/-)
local ascendBtn, descendBtn, speedUpBtn, speedDownBtn = Instance.new("TextButton"), Instance.new("TextButton"), Instance.new("TextButton"), Instance.new("TextButton")
ascendBtn.Parent, descendBtn.Parent, speedUpBtn.Parent, speedDownBtn.Parent = screenGui, screenGui, screenGui, screenGui

local function styleSide(btn, pos, color, txt)
    btn.Size             = UDim2.new(0,50,0,50)
    btn.Position         = pos
    btn.BackgroundColor3 = color
    btn.TextColor3       = Color3.new(1,1,1)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 22
    btn.Text             = txt
    btn.BorderSizePixel  = 0
    btn.Visible          = false
    btn.ZIndex           = 101
end

styleSide(ascendBtn,     UDim2.new(0.88,0,0.48,0), Color3.fromRGB(0,170,255), "↑")
styleSide(descendBtn,    UDim2.new(0.88,0,0.62,0), Color3.fromRGB(0,120,200), "↓")
styleSide(speedUpBtn,    UDim2.new(0.74,0,0.48,0), Color3.fromRGB(50,205,50), "↑")
styleSide(speedDownBtn,  UDim2.new(0.74,0,0.62,0), Color3.fromRGB(46,139,87), "↓")

--==================================================
-- ESTADO
--==================================================
local flying, espEnabled, speedEnabled, noclipEnabled, antiHitEnabled, knockbackEnabled, floorEnabled = false,false,false,false,false,false,false
local lockBtnVisible, lockActive = false, false
local ascend, descend = false, false

local bodyGyro, bodyVel, flyConnection
local currentHighlights, espConnections, espGlobalConnection = {}, {}, nil
local originalWalkSpeed, currentSpeed, speedConnection = nil, nil, nil
local speedIncrement, maxSpeed = 4, 100
local speedTarget = nil

local noclipSpeed = 50
local noclipBodyGyro, noclipBodyVel, noclipConnection, noclipCollisionConn = nil, nil, nil, nil

local targetCharacter, lockConnection = nil, nil

local antiDamageConn, platformConn, stateConn, antiKnockConn = nil, nil, nil, nil

local knockbackConnections = {}
local knockbackPower, upwardPower = 100, 50

local floorConnection

--==================================================
-- HUD DE REGISTRO (movible)
--==================================================
local hudFrame = Instance.new("Frame", screenGui)
hudFrame.Name                   = "LogHUD"
hudFrame.Size                   = UDim2.new(0,260,0,140)
hudFrame.Position               = UDim2.new(0.025,0,0.12,0)
hudFrame.BackgroundColor3       = Color3.fromRGB(12,12,16)
hudFrame.BackgroundTransparency = 0.15
hudFrame.Visible                = false
hudFrame.Active                 = true
hudFrame.ZIndex                 = 102
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0,8)

local hudTitle = Instance.new("TextLabel", hudFrame)
hudTitle.Size                   = UDim2.new(1, -28, 0, 20)
hudTitle.Position               = UDim2.new(0,8,0,6)
hudTitle.BackgroundTransparency = 1
hudTitle.Text                   = "Registro"
hudTitle.Font                   = Enum.Font.GothamBold
hudTitle.TextSize               = 16
hudTitle.TextColor3             = Color3.fromRGB(240,240,255)
hudTitle.TextXAlignment         = Enum.TextXAlignment.Left
hudTitle.ZIndex                 = 103

local hudClose = Instance.new("TextButton", hudFrame)
hudClose.Size             = UDim2.new(0,20,0,20)
hudClose.Position         = UDim2.new(1,-26,0,6)
hudClose.BackgroundColor3 = Color3.fromRGB(235,70,70)
hudClose.TextColor3       = Color3.new(1,1,1)
hudClose.Text             = "×"
hudClose.Font             = Enum.Font.GothamBold
hudClose.TextSize         = 16
hudClose.BorderSizePixel  = 0
hudClose.ZIndex           = 103
Instance.new("UICorner", hudClose).CornerRadius = UDim.new(0.5,0)

local hudScroll = Instance.new("ScrollingFrame", hudFrame)
hudScroll.Size                    = UDim2.new(1, -12, 1, -34)
hudScroll.Position                = UDim2.new(0,6,0,28)
hudScroll.BackgroundTransparency  = 1
hudScroll.BorderSizePixel         = 0
hudScroll.ScrollBarThickness      = 4
hudScroll.ZIndex                  = 102
local hudList = Instance.new("UIListLayout", hudScroll)
hudList.SortOrder = Enum.SortOrder.LayoutOrder
hudList.Padding   = UDim.new(0,4)

local function updateCanvas()
    hudScroll.CanvasSize    = UDim2.new(0,0,0, hudList.AbsoluteContentSize.Y + 8)
    hudScroll.CanvasPosition= Vector2.new(0, math.max(0, hudList.AbsoluteContentSize.Y - hudScroll.AbsoluteSize.Y))
end
hudList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

local hudEnabled = false
local function trimHUD(maxItems)
    local count = 0
    for _, ch in ipairs(hudScroll:GetChildren()) do
        if ch:IsA("TextLabel") then count += 1 end
    end
    while count > maxItems do
        for _, ch in ipairs(hudScroll:GetChildren()) do
            if ch:IsA("TextLabel") then
                ch:Destroy()
                count -= 1
                break
            end
        end
    end
end

local function logEvent(msg)
    print(msg)
    if not hudEnabled then return end
    local lab = Instance.new("TextLabel")
    lab.BackgroundTransparency = 1
    lab.TextXAlignment         = Enum.TextXAlignment.Left
    lab.TextYAlignment         = Enum.TextYAlignment.Center
    lab.Font                   = Enum.Font.GothamSemibold
    lab.TextSize               = 14
    lab.TextColor3             = Color3.fromRGB(230,230,240)
    lab.Size                   = UDim2.new(1, -6, 0, 18)
    lab.Text                   = os.date("%H:%M:%S") .. "  " .. msg
    lab.ZIndex                 = 102
    lab.Parent                 = hudScroll
    trimHUD(14)
    updateCanvas()
    Debris:AddItem(lab, 14) -- cada entrada dura ~14s
end

hudClose.MouseButton1Click:Connect(function()
    hudEnabled = false
    hudFrame.Visible = false
    hudToggleBtn.Text = "HUD OFF"
    logEvent("HUD oculto")
end)

--==================================================
-- BOTÓN RÁPIDO DE LOCK (movible)
--==================================================
local quickLockBtn = Instance.new("TextButton", screenGui)
quickLockBtn.Size             = UDim2.new(0,70,0,70)
quickLockBtn.Position         = UDim2.new(0.7,0,0.6,0)
quickLockBtn.BackgroundColor3 = Color3.fromRGB(120,200,255) -- inactivo
quickLockBtn.TextColor3       = Color3.new(1,1,1)
quickLockBtn.Font             = Enum.Font.GothamBold
quickLockBtn.TextSize         = 18
quickLockBtn.Text             = "LOCK"
quickLockBtn.BorderSizePixel  = 0
quickLockBtn.Visible          = false
quickLockBtn.ZIndex           = 101
Instance.new("UICorner", quickLockBtn).CornerRadius = UDim.new(0.5,0)

--==================================================
-- UTILIDADES (drag, colisión, etc.)
--==================================================
-- Drag genérico (MISMO que te funcionaba)
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
        local cam      = workspace.CurrentCamera
        local viewport = cam and cam.ViewportSize or Vector2.new(800,600)
        local guiSize  = gui.AbsoluteSize
        local maxX     = viewport.X - guiSize.X
        local maxY     = viewport.Y - guiSize.Y
        local clampedX = math.clamp(newPos.X.Offset,0,math.max(0,maxX))
        local clampedY = math.clamp(newPos.Y.Offset,0,math.max(0,maxY))
        gui.Position   = UDim2.new(0,clampedX,0,clampedY)
    end
end
local function makeDraggable(gui)
    gui.InputBegan:Connect(function(input) beginDrag(input, gui) end)
    gui.InputChanged:Connect(function(input) updateDrag(input, gui) end)
end

makeDraggable(dragFrame)
makeDraggable(menuFrame)
makeDraggable(openBtn)
makeDraggable(hudFrame)
makeDraggable(quickLockBtn)

-- Colisiones personaje (para noclip)
local function setCharacterCollision(enabled)
    local char = localPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = enabled
        end
    end
end

--==================================================
-- FLY
--==================================================
local function startFly()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    bodyGyro           = Instance.new("BodyGyro", hrp)
    bodyGyro.P         = 9e4
    bodyGyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
    bodyVel            = Instance.new("BodyVelocity", hrp)
    bodyVel.MaxForce   = Vector3.new(math.huge,math.huge,math.huge)
    bodyVel.P          = 9e4
    flyConnection      = RunService.RenderStepped:Connect(function()
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

--==================================================
-- ESP
--==================================================
local function enableESP()
    local function highlightPlayer(plr, character)
        if not character or not plr then return end
        local existing = currentHighlights[plr]
        if not existing then
            local h = Instance.new("Highlight")
            h.FillColor           = Color3.new(1,0,0)
            h.FillTransparency    = 0.5
            h.OutlineColor        = Color3.new(1,1,1)
            h.OutlineTransparency = 0
            h.Adornee             = character
            h.Parent              = character
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
                    if espEnabled then task.defer(function() highlightPlayer(plr, char) end) end
                end)
            end
        end
    end
    if not espGlobalConnection then
        espGlobalConnection = Players.PlayerAdded:Connect(function(plr)
            if plr ~= localPlayer and espEnabled then
                highlightPlayer(plr, plr.Character)
                espConnections[plr] = plr.CharacterAdded:Connect(function(char)
                    if espEnabled then task.defer(function() highlightPlayer(plr, char) end) end)
            end
        end)
    end
end

local function disableESP()
    for plr, conn in pairs(espConnections) do
        if conn then conn:Disconnect() end
        espConnections[plr] = nil
    end
    if espGlobalConnection then espGlobalConnection:Disconnect() espGlobalConnection = nil end
    for plr, highlight in pairs(currentHighlights) do
        if highlight then highlight:Destroy() end
        currentHighlights[plr] = nil
    end
end

--==================================================
-- SPEED
--==================================================
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

local function enableSpeed()
    local char = localPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            originalWalkSpeed = originalWalkSpeed or hum.WalkSpeed
            currentSpeed      = math.max(hum.WalkSpeed*2, originalWalkSpeed)
            if currentSpeed > maxSpeed then currentSpeed = maxSpeed end
            hum.WalkSpeed     = currentSpeed
            speedUpBtn.Visible   = true
            speedDownBtn.Visible = true
            maintainSpeed()
        end
    end
end

local function disableSpeed()
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

--==================================================
-- LOCK-ON (usado por el botón rápido)
--==================================================
local function findTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local camPos   = cam.CFrame.Position
    local camDir   = cam.CFrame.LookVector
    local bestTarget, bestDot = nil, 0.9
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
    if lockConnection then lockConnection:Disconnect() lockConnection = nil end
    targetCharacter = findTarget()
    if not targetCharacter then
        logEvent("Lock: sin objetivo")
        return
    end
    lockActive = true
    quickLockBtn.BackgroundColor3 = Color3.fromRGB(160,120,255) -- activo
    logEvent("Lock: ON → " .. (targetCharacter.Name or "objetivo"))
    lockConnection = RunService.RenderStepped:Connect(function()
        if not targetCharacter or not targetCharacter.Parent then
            if lockConnection then lockConnection:Disconnect() lockConnection = nil end
            lockActive = false
            quickLockBtn.BackgroundColor3 = Color3.fromRGB(120,200,255)
            logEvent("Lock: objetivo perdido")
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
    if lockConnection then lockConnection:Disconnect() lockConnection = nil end
    lockActive = false
    quickLockBtn.BackgroundColor3 = Color3.fromRGB(120,200,255)
    logEvent("Lock: OFF")
end

--==================================================
-- NOCLIP
--==================================================
local function startNoclip()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    setCharacterCollision(false)
    noclipBodyGyro           = Instance.new("BodyGyro", hrp)
    noclipBodyGyro.P         = 9e4
    noclipBodyGyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
    noclipBodyVel            = Instance.new("BodyVelocity", hrp)
    noclipBodyVel.MaxForce   = Vector3.new(math.huge,math.huge,math.huge)
    noclipBodyVel.P          = 9e4
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
    if noclipConnection    then noclipConnection:Disconnect()    noclipConnection    = nil end
    if noclipCollisionConn then noclipCollisionConn:Disconnect() noclipCollisionConn = nil end
    if noclipBodyGyro      then noclipBodyGyro:Destroy()         noclipBodyGyro      = nil end
    if noclipBodyVel       then noclipBodyVel:Destroy()          noclipBodyVel       = nil end
end

--==================================================
-- ANTI-HIT (desactiva empujes y cae rápido)
--==================================================
local function enableAntiHit()
    local char = localPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not antiDamageConn then
        antiDamageConn = hum.HealthChanged:Connect(function()
            if antiHitEnabled and hum then hum.Health = hum.MaxHealth end
        end)
    end
    if not platformConn then
        platformConn = hum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
            if antiHitEnabled and hum.PlatformStand then hum.PlatformStand = false end
        end)
    end
    if not stateConn then
        stateConn = hum.StateChanged:Connect(function(_, new)
            if antiHitEnabled and (new == Enum.HumanoidStateType.Freefall
            or new == Enum.HumanoidStateType.FallingDown
            or new == Enum.HumanoidStateType.Physics
            or new == Enum.HumanoidStateType.Ragdoll) then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
    if not antiKnockConn then
        antiKnockConn = RunService.Heartbeat:Connect(function()
            if not antiHitEnabled then return end
            local char  = localPlayer.Character
            local hum   = char and char:FindFirstChildOfClass("Humanoid")
            local root  = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root then
                local move    = hum.MoveDirection
                local desired = Vector3.new(0,0,0)
                if move.Magnitude > 0 then
                    desired = move.Unit * (noclipEnabled and noclipSpeed or hum.WalkSpeed)
                end
                local currentVel = root.AssemblyLinearVelocity
                local yVel = currentVel.Y
                if hum:GetState() ~= Enum.HumanoidStateType.Jumping and not ascend and not descend then
                    yVel = -50
                end
                root.AssemblyLinearVelocity = Vector3.new(desired.X, yVel, desired.Z)
            end
        end)
    end
end

local function disableAntiHit()
    if antiDamageConn then antiDamageConn:Disconnect() antiDamageConn = nil end
    if platformConn  then platformConn:Disconnect()  platformConn = nil end
    if stateConn     then stateConn:Disconnect()     stateConn = nil end
    if antiKnockConn then antiKnockConn:Disconnect() antiKnockConn = nil end
end

--==================================================
-- KNOCKBACK (empujar a otros)
--==================================================
local function enableKnockback()
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
                                if dir.Magnitude > 0 then dir = dir.Unit else dir = Vector3.new(0,0,0) end
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
    for part, conn in pairs(knockbackConnections) do
        if conn then conn:Disconnect() end
        knockbackConnections[part] = nil
    end
end

--==================================================
-- FLOOR (placas bajo el jugador, 2s)
--==================================================
local function spawnFloorPlate()
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local plate = Instance.new("Part")
        plate.Size      = Vector3.new(6,1,6)
        plate.Anchored  = true
        plate.Color     = Color3.fromRGB(255,200,0)
        plate.Position  = root.Position - Vector3.new(0,3.5,0)
        plate.Parent    = workspace
        Debris:AddItem(plate, 2)
    end
end

local function enableFloor()
    floorConnection = RunService.Heartbeat:Connect(spawnFloorPlate)
end

local function disableFloor()
    if floorConnection then floorConnection:Disconnect() floorConnection = nil end
end

--==================================================
-- REAPARECER: reactivar lo que esté ON
--==================================================
localPlayer.CharacterAdded:Connect(function()
    if knockbackEnabled then disableKnockback() enableKnockback() end
    if antiHitEnabled  then enableAntiHit() end
    if speedEnabled    then maintainSpeed() end
    if floorEnabled    then enableFloor() end
    -- Lock: si el botón rápido estaba visible, lo dejamos visible; si además estaba activo, reanudamos
    if lockBtnVisible then quickLockBtn.Visible = true end
    if lockActive then startLock() end
end)

--==================================================
-- CONEXIONES DE BOTONES (MENÚ)
--==================================================
flyToggleBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyToggleBtn.Text = flying and "Fly ON" or "Fly OFF"
    ascendBtn.Visible  = flying or noclipEnabled
    descendBtn.Visible = flying or noclipEnabled
    if flying then startFly() else ascend=false descend=false stopFly() end
    logEvent("Fly: " .. (flying and "ON" or "OFF"))
end)

espToggleBtn.MouseButton1Click:Connect(function()
    if espEnabled then
        espEnabled = false; disableESP()
        espToggleBtn.Text = "ESP OFF"
    else
        espEnabled = true; enableESP()
        espToggleBtn.Text = "ESP ON"
    end
    logEvent("ESP: " .. (espEnabled and "ON" or "OFF"))
end)

speedToggleBtn.MouseButton1Click:Connect(function()
    if speedEnabled then
        speedEnabled = false; disableSpeed()
        speedToggleBtn.Text = "Speed OFF"
        if not noclipEnabled then
            speedUpBtn.Visible   = false
            speedDownBtn.Visible = false
        end
        speedTarget = noclipEnabled and "noclip" or nil
    else
        speedEnabled = true; enableSpeed()
        speedToggleBtn.Text = "Speed ON"
        speedTarget = "walk"
    end
    logEvent("Speed: " .. (speedEnabled and "ON" or "OFF"))
end)

lockToggleBtn.MouseButton1Click:Connect(function()
    lockBtnVisible = not lockBtnVisible
    quickLockBtn.Visible = lockBtnVisible
    lockToggleBtn.Text = lockBtnVisible and "Lock Btn ON" or "Lock Btn OFF"
    if not lockBtnVisible and lockActive then
        stopLock()
    end
    logEvent("Lock Button: " .. (lockBtnVisible and "VISIBLE" or "OCULTO"))
end)

noclipToggleBtn.MouseButton1Click:Connect(function()
    if noclipEnabled then
        noclipEnabled        = false
        noclipToggleBtn.Text = "Noclip OFF"
        stopNoclip()
        if not speedEnabled then speedUpBtn.Visible=false; speedDownBtn.Visible=false end
        if not flying then ascendBtn.Visible=false; descendBtn.Visible=false end
        speedTarget = speedEnabled and "walk" or nil
    else
        noclipEnabled        = true
        noclipToggleBtn.Text = "Noclip ON"
        if flying then flying=false; flyToggleBtn.Text="Fly OFF"; ascend=false; descend=false; stopFly() end
        if speedEnabled then speedEnabled=false; disableSpeed(); speedToggleBtn.Text="Speed OFF" end
        startNoclip()
        ascendBtn.Visible    = true
        descendBtn.Visible   = true
        speedUpBtn.Visible   = true
        speedDownBtn.Visible = true
        speedTarget          = "noclip"
    end
    logEvent("Noclip: " .. (noclipEnabled and "ON" or "OFF"))
end)

antiHitToggleBtn.MouseButton1Click:Connect(function()
    if antiHitEnabled then
        antiHitEnabled = false; disableAntiHit()
        antiHitToggleBtn.Text = "Anti-Hit OFF"
    else
        antiHitEnabled = true; enableAntiHit()
        antiHitToggleBtn.Text = "Anti-Hit ON"
    end
    logEvent("Anti-Hit: " .. (antiHitEnabled and "ON" or "OFF"))
end)

knockToggleBtn.MouseButton1Click:Connect(function()
    if knockbackEnabled then
        knockbackEnabled = false; disableKnockback()
        knockToggleBtn.Text = "Knockback OFF"
    else
        knockbackEnabled = true; enableKnockback()
        knockToggleBtn.Text = "Knockback ON"
    end
    logEvent("Knockback: " .. (knockbackEnabled and "ON" or "OFF"))
end)

floorToggleBtn.MouseButton1Click:Connect(function()
    if floorEnabled then
        floorEnabled = false; disableFloor()
        floorToggleBtn.Text = "Floor OFF"
    else
        floorEnabled = true; enableFloor()
        floorToggleBtn.Text = "Floor ON"
    end
    logEvent("Floor: " .. (floorEnabled and "ON" or "OFF"))
end)

hudToggleBtn.MouseButton1Click:Connect(function()
    hudEnabled = not hudEnabled
    hudFrame.Visible = hudEnabled
    hudToggleBtn.Text = hudEnabled and "HUD ON" or "HUD OFF"
    if hudEnabled then logEvent("HUD visible") end
end)

--==================================================
-- QUICK LOCK BUTTON (juego)
--==================================================
quickLockBtn.MouseButton1Click:Connect(function()
    if not lockActive then
        startLock()
    else
        stopLock()
    end
end)

--==================================================
-- VELOCIDAD con flechas y ascenso/descenso
--==================================================
speedUpBtn.MouseButton1Click:Connect(function()
    if speedTarget == "walk" and speedEnabled then
        local char = localPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            currentSpeed = math.min(hum.WalkSpeed + speedIncrement, maxSpeed)
            hum.WalkSpeed = currentSpeed
            logEvent(("Speed + → %d"):format(currentSpeed))
        end
    elseif speedTarget == "noclip" and noclipEnabled then
        noclipSpeed  = math.min(noclipSpeed + speedIncrement, 200)
        logEvent(("Noclip Speed + → %d"):format(noclipSpeed))
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
            logEvent(("Speed - → %d"):format(currentSpeed))
        end
    elseif speedTarget == "noclip" and noclipEnabled then
        noclipSpeed  = math.max(noclipSpeed - speedIncrement, 10)
        logEvent(("Noclip Speed - → %d"):format(noclipSpeed))
    end
end)

ascendBtn.MouseButton1Down:Connect(function() ascend = true end)
ascendBtn.MouseButton1Up:Connect(function()   ascend = false end)
descendBtn.MouseButton1Down:Connect(function() descend = true end)
descendBtn.MouseButton1Up:Connect(function()   descend = false end)

-- Mostrar/ocultar menú principal
openBtn.MouseButton1Click:Connect(function()
    dragFrame.Visible = false
    menuFrame.Visible = true
end)
closeBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    dragFrame.Visible = true
end)

print("✅ Script cargado (BASE ESTABLE, sin extras)")
