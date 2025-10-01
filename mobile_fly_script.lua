-- LocalScript completo: Fly, ESP, Speed (con MUCHO más límite), Lock Quick Button, Noclip, Anti-Hit mejorado,
-- Knockback, Floor, HUD y Ajustes. Mantiene arrastre estable y paleta original.
-- Pega tal cual en StarterPlayerScripts o StarterGui. Sin dependencias externas.

--==================================================
-- SERVICIOS
--==================================================
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Debris      = game:GetService("Debris")
local Workspace   = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

--==================================================
-- PARÁMETROS AJUSTABLES
--==================================================
local SPEED_INC_DEFAULT     = 6
local WALK_MAX_SPEED        = 500   -- ↑↑ subido muchísimo
local NOCLIP_MAX_SPEED      = 300
local FLY_DEFAULT_SPEED     = 60
local NOCLIP_DEFAULT_SPEED  = 60

-- Lock-on (se mantiene el comportamiento suave que ya funcionaba)
local LOCK_DOT_THRESHOLD    = 0.90
local LOCK_RANGE            = 220
local LOCK_SMOOTH_ALPHA     = 0.12
local LOCK_MAX_DEG_PER_SEC  = 240
local LOCK_LOSS_GRACE       = 0.40

-- Anti-Hit mejorado
local AH_MAX_FALL_SPEED     = -120  -- límite de caída (más rápido baja, pero controlado)
local AH_UPWARD_CAP_GROUND  = 12    -- límite de subida cuando estás en suelo (evita mini-lanzamientos)
local AH_UPWARD_CAP_AIR     = 20    -- límite de subida en aire si no estás saltando
local AH_JUMP_UP_CAP        = 60    -- permite salto normal hasta ~60 studs/s hacia arriba
local AH_MAX_ACCEL_PER_SEC  = 220   -- tope de cambio de velocidad por segundo (suaviza correcciones)

--==================================================
-- GUI PRINCIPAL
--==================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "FlySpeedESPLockGui"
screenGui.ResetOnSpawn   = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder   = 100
screenGui.Parent         = playerGui

-- Botón circular (☰) contenedor movible
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

-- Menú principal
local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size              = UDim2.new(0,300,0,320) -- un poco más ancho para caber mejor
menuFrame.Position          = UDim2.new(0.5,-150,0.5,-160)
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
    btn.Size             = UDim2.new(0,140,0,38) -- un pelín más compacto
    btn.Position         = pos
    btn.BackgroundColor3 = color
    btn.TextColor3       = Color3.new(1,1,1)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 18
    btn.Text             = text
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 101
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    return btn
end

-- Botones (5x2)
local flyToggleBtn     = createToggleButton("FlyToggle",     "Fly OFF",         UDim2.new(0,10,0,40),  Color3.fromRGB(0,170,255))
local espToggleBtn     = createToggleButton("ESPToggle",     "ESP OFF",         UDim2.new(0,150,0,40), Color3.fromRGB(255,105,180))
local speedToggleBtn   = createToggleButton("SpeedToggle",   "Speed OFF",       UDim2.new(0,10,0,90),  Color3.fromRGB(255,165,0))
local lockToggleBtn    = createToggleButton("LockToggle",    "Lock Btn OFF",    UDim2.new(0,150,0,90), Color3.fromRGB(120,200,255))
local noclipToggleBtn  = createToggleButton("NoclipToggle",  "Noclip OFF",      UDim2.new(0,10,0,140), Color3.fromRGB(255,99,71))
local antiHitToggleBtn = createToggleButton("AntiHitToggle", "Anti-Hit ON",     UDim2.new(0,150,0,140),Color3.fromRGB(100,110,130))
local knockToggleBtn   = createToggleButton("KnockToggle",   "Knockback OFF",   UDim2.new(0,10,0,190), Color3.fromRGB(144,238,144))
local floorToggleBtn   = createToggleButton("FloorToggle",   "Floor OFF",       UDim2.new(0,150,0,190),Color3.fromRGB(210,180,140))
local hudToggleBtn     = createToggleButton("HUDToggle",     "HUD OFF",         UDim2.new(0,10,0,240), Color3.fromRGB(80,120,200))
local settingsBtn      = createToggleButton("SettingsBtn",   "Ajustes",         UDim2.new(0,150,0,240),Color3.fromRGB(50,170,160))

-- Botones laterales (móvil)
local ascendBtn, descendBtn  = Instance.new("TextButton"), Instance.new("TextButton")
local speedUpBtn, speedDownBtn = Instance.new("TextButton"), Instance.new("TextButton")
ascendBtn.Parent, descendBtn.Parent, speedUpBtn.Parent, speedDownBtn.Parent = screenGui, screenGui, screenGui, screenGui

local function styleSide(btn, pos, color, txt)
    btn.Size             = UDim2.new(0,52,0,52)
    btn.Position         = pos
    btn.BackgroundColor3 = color
    btn.TextColor3       = Color3.new(1,1,1)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 20
    btn.Text             = txt
    btn.BorderSizePixel  = 0
    btn.Visible          = false
    btn.ZIndex           = 101
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.4,0)
end
styleSide(ascendBtn,    UDim2.new(0.86,0,0.45,0), Color3.fromRGB(0,170,255), "↑")
styleSide(descendBtn,   UDim2.new(0.86,0,0.61,0), Color3.fromRGB(0,120,200), "↓")
styleSide(speedUpBtn,   UDim2.new(0.72,0,0.45,0), Color3.fromRGB(50,205,50), "↑")
styleSide(speedDownBtn, UDim2.new(0.72,0,0.61,0), Color3.fromRGB(46,139,87), "↓")

--==================================================
-- ESTADO
--==================================================
local flying, espEnabled, speedEnabled, noclipEnabled, antiHitEnabled, knockbackEnabled, floorEnabled = false,false,false,false,true,false,false
local lockBtnVisible, lockActive = false, false
local ascend, descend = false, false

local bodyGyro, bodyVel, flyConnection
local currentHighlights, espConnections, espGlobalConnection = {}, {}, nil
local originalWalkSpeed, currentSpeed, speedConnection = nil, nil, nil
local speedIncrement = SPEED_INC_DEFAULT
local speedTarget = nil

local noclipSpeed = NOCLIP_DEFAULT_SPEED
local noclipBodyGyro, noclipBodyVel, noclipConnection, noclipCollisionConn = nil, nil, nil, nil

local targetCharacter, lockConnection = nil, nil
local lastGoodDotTime = 0

local antiDamageConn, platformConn, stateConn, antiKnockConn = nil, nil, nil, nil

local knockbackConnections = {}
local knockbackPower, upwardPower = 100, 50

local floorConnection

--==================================================
-- HUD DE REGISTRO
--==================================================
local hudFrame = Instance.new("Frame", screenGui)
hudFrame.Name                   = "LogHUD"
hudFrame.Size                   = UDim2.new(0,260,0,150)
hudFrame.Position               = UDim2.new(0.025,0,0.12,0)
hudFrame.BackgroundColor3       = Color3.fromRGB(12,12,16)
hudFrame.BackgroundTransparency = 0.15
hudFrame.Visible                = false
hudFrame.Active                 = true
hudFrame.ZIndex                 = 102
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0,8)

local hudTitle = Instance.new("TextLabel", hudFrame)
hudTitle.Size, hudTitle.Position = UDim2.new(1,-60,0,20), UDim2.new(0,8,0,6)
hudTitle.BackgroundTransparency = 1
hudTitle.Text = "Registro"
hudTitle.Font = Enum.Font.GothamBold
hudTitle.TextSize = 16
hudTitle.TextColor3 = Color3.fromRGB(240,240,255)
hudTitle.TextXAlignment = Enum.TextXAlignment.Left
hudTitle.ZIndex = 103

local hudClear = Instance.new("TextButton", hudFrame)
hudClear.Size, hudClear.Position = UDim2.new(0,24,0,20), UDim2.new(1,-54,0,6)
hudClear.BackgroundColor3 = Color3.fromRGB(90,130,200)
hudClear.TextColor3 = Color3.new(1,1,1)
hudClear.Text, hudClear.Font, hudClear.TextSize = "⟲", Enum.Font.GothamBold, 14
hudClear.BorderSizePixel, hudClear.ZIndex = 0, 103
Instance.new("UICorner", hudClear).CornerRadius = UDim.new(0.5,0)

local hudClose = Instance.new("TextButton", hudFrame)
hudClose.Size, hudClose.Position = UDim2.new(0,24,0,20), UDim2.new(1,-26,0,6)
hudClose.BackgroundColor3 = Color3.fromRGB(235,70,70)
hudClose.TextColor3 = Color3.new(1,1,1)
hudClose.Text, hudClose.Font, hudClose.TextSize = "×", Enum.Font.GothamBold, 14
hudClose.BorderSizePixel, hudClose.ZIndex = 0, 103
Instance.new("UICorner", hudClose).CornerRadius = UDim.new(0.5,0)

local hudScroll = Instance.new("ScrollingFrame", hudFrame)
hudScroll.Size, hudScroll.Position = UDim2.new(1,-12,1,-34), UDim2.new(0,6,0,28)
hudScroll.BackgroundTransparency, hudScroll.BorderSizePixel, hudScroll.ScrollBarThickness = 1, 0, 4
hudScroll.ZIndex = 102
local hudList = Instance.new("UIListLayout", hudScroll)
hudList.SortOrder = Enum.SortOrder.LayoutOrder
hudList.Padding   = UDim.new(0,4)

local function updateCanvas()
    hudScroll.CanvasSize   = UDim2.new(0,0,0, hudList.AbsoluteContentSize.Y + 8)
    hudScroll.CanvasPosition = Vector2.new(0, math.max(0, hudList.AbsoluteContentSize.Y - hudScroll.AbsoluteSize.Y))
end
hudList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

local function colorForMessage(msg)
    msg = string.lower(msg or "")
    if msg:find("on") or msg:find("visible") then
        return Color3.fromRGB(160,230,180)
    elseif msg:find("off") or msg:find("oculto") or msg:find("perdido") then
        return Color3.fromRGB(240,170,170)
    elseif msg:find("speed") or msg:find("noclip") then
        return Color3.fromRGB(220,210,150)
    else
        return Color3.fromRGB(230,230,240)
    end
end

local hudEnabled = false
local function logEvent(msg)
    print(msg)
    if not hudEnabled then return end
    local lab = Instance.new("TextLabel")
    lab.BackgroundTransparency = 1
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.TextYAlignment = Enum.TextYAlignment.Center
    lab.Font, lab.TextSize = Enum.Font.GothamSemibold, 14
    lab.TextColor3 = colorForMessage(msg)
    lab.Size = UDim2.new(1,-6,0,18)
    lab.Text = os.date("%H:%M:%S") .. "  " .. (msg or "")
    lab.ZIndex = 102
    lab.Parent = hudScroll
    updateCanvas()
    Debris:AddItem(lab, 14)
end

hudClose.MouseButton1Click:Connect(function()
    hudEnabled = false
    hudFrame.Visible = false
    hudToggleBtn.Text = "HUD OFF"
    logEvent("HUD oculto")
end)
hudClear.MouseButton1Click:Connect(function()
    for _, ch in ipairs(hudScroll:GetChildren()) do
        if ch:IsA("TextLabel") then ch:Destroy() end
    end
    updateCanvas()
    logEvent("HUD limpiado")
end)

--==================================================
-- BOTÓN RÁPIDO DE LOCK (movible)
--==================================================
local quickLockBtn = Instance.new("TextButton", screenGui)
quickLockBtn.Size             = UDim2.new(0,70,0,70)
quickLockBtn.Position         = UDim2.new(0.7,0,0.6,0)
quickLockBtn.BackgroundColor3 = Color3.fromRGB(120,200,255)
quickLockBtn.TextColor3       = Color3.new(1,1,1)
quickLockBtn.Font             = Enum.Font.GothamBold
quickLockBtn.TextSize         = 18
quickLockBtn.Text             = "LOCK"
quickLockBtn.BorderSizePixel  = 0
quickLockBtn.Visible          = false
quickLockBtn.ZIndex           = 101
Instance.new("UICorner", quickLockBtn).CornerRadius = UDim.new(0.5,0)

--==================================================
-- UTILIDADES (ARRASTRE)
--==================================================
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
    if not draggingFlag then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - startPosInput
    local newPos= UDim2.new(startPosGui.X.Scale,startPosGui.X.Offset+delta.X, startPosGui.Y.Scale,startPosGui.Y.Offset+delta.Y)
    local cam      = Workspace.CurrentCamera
    local viewport = cam and cam.ViewportSize or Vector2.new(800,600)
    local guiSize  = gui.AbsoluteSize
    local maxX     = viewport.X - guiSize.X
    local maxY     = viewport.Y - guiSize.Y
    local clampedX = math.clamp(newPos.X.Offset,0,math.max(0,maxX))
    local clampedY = math.clamp(newPos.Y.Offset,0,math.max(0,maxY))
    gui.Position   = UDim2.new(0,clampedX,0,clampedY)
end
local function makeDraggable(gui)
    gui.InputBegan:Connect(function(input) beginDrag(input, gui) end)
    gui.InputChanged:Connect(function(input) updateDrag(input, gui) end)
end

makeDraggable(dragFrame)
makeDraggable(openBtn)
makeDraggable(menuFrame)
makeDraggable(hudFrame)
makeDraggable(quickLockBtn)

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
        bodyVel.Velocity = dir * FLY_DEFAULT_SPEED
        local cam = Workspace.CurrentCamera
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
            h.FillColor           = Color3.fromRGB(255,20,147)
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
                if espConnections[plr] then espConnections[plr]:Disconnect() end
                espConnections[plr] = plr.CharacterAdded:Connect(function(char)
                    if espEnabled then task.defer(function() highlightPlayer(plr, char) end) end
                end)
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
-- SPEED (con tope mucho mayor)
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
            currentSpeed      = math.clamp(math.max(hum.WalkSpeed*2, originalWalkSpeed), 10, WALK_MAX_SPEED)
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
-- LOCK-ON (se mantiene estable de versión previa)
--==================================================
local function findTarget()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local camPos   = cam.CFrame.Position
    local camDir   = cam.CFrame.LookVector
    local bestTarget, bestDot = nil, LOCK_DOT_THRESHOLD
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local vec  = root.Position - camPos
                local dist = vec.Magnitude
                if dist < LOCK_RANGE then
                    local dir  = vec / dist
                    local dot  = dir:Dot(camDir)
                    if dot > bestDot then bestDot, bestTarget = dot, char end
                end
            end
        end
    end
    return bestTarget
end
local function startLock()
    if lockConnection then lockConnection:Disconnect() lockConnection = nil end
    targetCharacter = findTarget()
    if not targetCharacter then logEvent("Lock: sin objetivo"); return end
    lockActive, lastGoodDotTime = true, time()
    quickLockBtn.BackgroundColor3 = Color3.fromRGB(160,120,255)
    logEvent("Lock: ON → " .. (targetCharacter.Name or "objetivo"))
    lockConnection = RunService.RenderStepped:Connect(function(dt)
        local cam = Workspace.CurrentCamera
        if not cam then return end
        if not targetCharacter or not targetCharacter.Parent then
            lockConnection:Disconnect(); lockConnection=nil; lockActive=false
            quickLockBtn.BackgroundColor3 = Color3.fromRGB(120,200,255)
            logEvent("Lock: objetivo perdido"); return
        end
        local camPos = cam.CFrame.Position
        local root   = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local lookAtPos = root.Position
        local toTarget  = lookAtPos - camPos
        local dist      = toTarget.Magnitude
        if dist < 1e-3 then return end
        local dir       = toTarget / dist
        local dotNow    = dir:Dot(cam.CFrame.LookVector)
        if dist <= LOCK_RANGE and dotNow >= LOCK_DOT_THRESHOLD then
            lastGoodDotTime = time()
        elseif (time() - lastGoodDotTime) > LOCK_LOSS_GRACE then
            local newT = findTarget()
            if newT then targetCharacter=newT; lastGoodDotTime=time(); logEvent("Lock: objetivo cambiado → "..(newT.Name or "?"))
            else
                lockConnection:Disconnect(); lockConnection=nil; lockActive=false
                quickLockBtn.BackgroundColor3 = Color3.fromRGB(120,200,255)
                logEvent("Lock: OFF (sin objetivo)"); return
            end
        end
        local targetCF = CFrame.lookAt(camPos, lookAtPos)
        -- limitar giro brusco por segundo
        local current = cam.CFrame
        local _,_,_, r00,r01,r02, r10,r11,r12, r20,r21,r22 = (current:inverse() * targetCF):components()
        local angle = math.acos(math.clamp((r00 + r11 + r22 - 1)/2, -1, 1))
        local maxStep = math.rad(LOCK_MAX_DEG_PER_SEC) * math.max(dt, 0.016)
        local alpha = math.clamp(maxStep / math.max(angle, 1e-6), 0, 1)
        local soft  = 1 - (1-LOCK_SMOOTH_ALPHA)^(math.max(dt,0.016)*60)
        cam.CFrame = current:Lerp(targetCF, math.min(alpha, soft))
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
local function setCharacterCollision(enabled)
    local char = localPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = enabled end
    end
end
local function startNoclip()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
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
                if move.Magnitude > 0 then dir += move end
            end
        end
        if ascend then dir += Vector3.new(0,1,0) end
        if descend then dir += Vector3.new(0,-1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit end
        noclipBodyVel.Velocity = dir * noclipSpeed
        local cam = Workspace.CurrentCamera
        if cam then noclipBodyGyro.CFrame = cam.CFrame end
    end)
    noclipCollisionConn = RunService.Stepped:Connect(function()
        if noclipEnabled and localPlayer.Character then setCharacterCollision(false) end
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
-- ANTI-HIT (MEJORADO: sin “salir disparado”, respeta salto)
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
            if antiHitEnabled and (new == Enum.HumanoidStateType.FallingDown
            or new == Enum.HumanoidStateType.Physics
            or new == Enum.HumanoidStateType.Ragdoll) then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
    if not antiKnockConn then
        antiKnockConn = RunService.Heartbeat:Connect(function(dt)
            if not antiHitEnabled then return end
            local char  = localPlayer.Character
            hum   = char and char:FindFirstChildOfClass("Humanoid")
            local root  = char and char:FindFirstChild("HumanoidRootPart")
            if not (hum and root) then return end

            local isFlyingOrNoclip = flying or noclipEnabled
            local onGround = hum.FloorMaterial ~= Enum.Material.Air
            local jumping  = hum:GetState() == Enum.HumanoidStateType.Jumping or hum.Jump

            -- Horizontal deseado
            local desiredH = Vector3.new(0,0,0)
            local base = (noclipEnabled and noclipSpeed) or (currentSpeed or hum.WalkSpeed)
            local move = hum.MoveDirection
            if move.Magnitude > 0 then desiredH = move.Unit * base end

            -- Vertical controlado
            local v  = root.AssemblyLinearVelocity
            local targetY = v.Y

            if not isFlyingOrNoclip then
                if jumping and v.Y > 0 then
                    -- Permite salto normal, pero con tope razonable
                    targetY = math.min(v.Y, AH_JUMP_UP_CAP)
                else
                    if onGround then
                        -- En suelo: evita micro-lanzamientos hacia arriba y caídas bruscas
                        targetY = math.clamp(v.Y, AH_MAX_FALL_SPEED/2, AH_UPWARD_CAP_GROUND)
                    else
                        -- En aire: frena lanzamientos hacia arriba y acelera caída controlada
                        targetY = math.clamp(v.Y, AH_MAX_FALL_SPEED, AH_UPWARD_CAP_AIR)
                    end
                end
            end

            -- Componer velocidad objetivo
            local targetVel = Vector3.new(desiredH.X, targetY, desiredH.Z)

            -- Límite de aceleración para que no “teleporte” ni rebote
            local maxDelta = (AH_MAX_ACCEL_PER_SEC * math.max(dt, 0.016))
            local dv = targetVel - v
            local mag = dv.Magnitude
            if mag > maxDelta then dv = dv.Unit * maxDelta end

            root.AssemblyLinearVelocity = v + dv
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
-- KNOCKBACK
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
                                dir = (dir.Magnitude > 0) and dir.Unit or Vector3.new()
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
    for _, conn in pairs(knockbackConnections) do
        if conn then conn:Disconnect() end
    end
    knockbackConnections = {}
end

--==================================================
-- FLOOR
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
local function enableFloor()  floorConnection = RunService.Heartbeat:Connect(spawnFloorPlate) end
local function disableFloor() if floorConnection then floorConnection:Disconnect() floorConnection=nil end end

--==================================================
-- PANEL DE AJUSTES (sliders)
--==================================================
local settingsFrame = Instance.new("Frame", screenGui)
settingsFrame.Name, settingsFrame.Size = "SettingsPanel", UDim2.new(0,300,0,240)
settingsFrame.Position = UDim2.new(0.55, -150, 0.5, -120)
settingsFrame.BackgroundColor3 = Color3.fromRGB(18,18,24)
settingsFrame.Visible, settingsFrame.Active, settingsFrame.ZIndex = false, true, 110
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0,8)
makeDraggable(settingsFrame)

local setTitle = Instance.new("TextLabel", settingsFrame)
setTitle.Size, setTitle.Position = UDim2.new(1,-40,0,24), UDim2.new(0,12,0,8)
setTitle.BackgroundTransparency = 1
setTitle.Text, setTitle.Font, setTitle.TextSize = "Ajustes", Enum.Font.GothamBold, 20
setTitle.TextColor3, setTitle.TextXAlignment, setTitle.ZIndex = Color3.fromRGB(230,240,245), Enum.TextXAlignment.Left, 111

local setClose = Instance.new("TextButton", settingsFrame)
setClose.Size, setClose.Position = UDim2.new(0,24,0,24), UDim2.new(1,-32,0,8)
setClose.BackgroundColor3 = Color3.fromRGB(235,70,70)
setClose.TextColor3 = Color3.new(1,1,1)
setClose.Text, setClose.Font, setClose.TextSize = "×", Enum.Font.GothamBold, 18
setClose.BorderSizePixel, setClose.ZIndex = 0, 111
Instance.new("UICorner", setClose).CornerRadius = UDim.new(0.5,0)

local function createSlider(parent, y, labelText, minVal, maxVal, defaultVal, decimals, accentColor)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1,-20,0,52)
    holder.Position = UDim2.new(0,10,0,y)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 111

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1,0,0,18)
    lbl.Position = UDim2.new(0,0,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(220,225,235)
    lbl.Text = labelText
    lbl.ZIndex = 111

    local valueLbl = Instance.new("TextLabel", holder)
    valueLbl.Size = UDim2.new(0,80,0,18)
    valueLbl.Position = UDim2.new(1,-80,0,0)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Font = Enum.Font.GothamSemibold
    valueLbl.TextSize = 15
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.TextColor3 = Color3.fromRGB(200,210,220)
    valueLbl.Text = tostring(defaultVal)
    valueLbl.ZIndex = 111

    local bar = Instance.new("Frame", holder)
    bar.Size = UDim2.new(1,0,0,8)
    bar.Position = UDim2.new(0,0,0,28)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,48)
    bar.BorderSizePixel = 0
    bar.ZIndex = 111
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,4)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = accentColor
    fill.BorderSizePixel = 0
    fill.ZIndex = 112
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)

    local knob = Instance.new("Frame", holder)
    knob.Size = UDim2.new(0,18,0,18)
    knob.Position = UDim2.new(0,0,0,23)
    knob.BackgroundColor3 = accentColor
    knob.BorderSizePixel = 0
    knob.ZIndex = 113
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5,0)

    local dragging = false
    local currentValue = defaultVal
    local function setVisualByValue(v)
        local t = (v - minVal) / (maxVal - minVal)
        t = math.clamp(t,0,1)
        fill.Size = UDim2.new(t,0,1,0)
        knob.Position = UDim2.new(t, -9, 0, 23)
        if decimals == 0 then
            valueLbl.Text = string.format("%d", math.floor(v + 0.5))
        else
            valueLbl.Text = string.format("%."..decimals.."f", v)
        end
    end
    setVisualByValue(defaultVal)

    local function setValueFromX(x)
        local rel = (x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X)
        local v = minVal + math.clamp(rel,0,1) * (maxVal - minVal)
        if decimals == 0 then v = math.floor(v + 0.5) end
        currentValue = v
        setVisualByValue(v)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setValueFromX(input.Position.X)
        end
    end)
    bar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setValueFromX(input.Position.X)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        get = function() return currentValue end,
        set = function(v) currentValue=v; setVisualByValue(v) end,
        valueLabel = valueLbl
    }
end

-- Sliders (nota: tope aumentado)
local walkSlider   = createSlider(settingsFrame,  36, "Walk Speed",   10, WALK_MAX_SPEED,  32, 0, Color3.fromRGB(255,165,0))
local noclipSlider = createSlider(settingsFrame,  92, "Noclip Speed", 10, NOCLIP_MAX_SPEED, NOCLIP_DEFAULT_SPEED, 0, Color3.fromRGB(255,99,71))
local dotSlider    = createSlider(settingsFrame, 148, "Lock Dot",     0.70, 0.98, LOCK_DOT_THRESHOLD, 2, Color3.fromRGB(120,200,255))
local rangeSlider  = createSlider(settingsFrame, 204, "Lock Range",   100, 300, LOCK_RANGE, 0, Color3.fromRGB(120,200,255))

local function applySettings(fromWhere)
    local ws   = walkSlider.get()
    local ncs  = noclipSlider.get()
    local dot  = dotSlider.get()
    local rng  = rangeSlider.get()

    if speedEnabled then
        local char = localPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            originalWalkSpeed = originalWalkSpeed or hum.WalkSpeed
            currentSpeed      = math.clamp(ws, 10, WALK_MAX_SPEED)
            hum.WalkSpeed     = currentSpeed
            logEvent(("Speed set → %d (%s)"):format(currentSpeed, fromWhere or "Ajustes"))
        end
    end

    noclipSpeed = math.clamp(ncs, 10, NOCLIP_MAX_SPEED)
    if noclipEnabled then
        logEvent(("Noclip Speed set → %d (%s)"):format(noclipSpeed, fromWhere or "Ajustes"))
    end

    LOCK_DOT_THRESHOLD = math.clamp(dot, 0.70, 0.98)
    LOCK_RANGE         = math.clamp(rng, 100, 300)
    logEvent(("Lock ajustes: dot=%.2f, range=%d"):format(LOCK_DOT_THRESHOLD, LOCK_RANGE))
end

setClose.MouseButton1Click:Connect(function()
    settingsFrame.Visible = false
    applySettings("cierre Ajustes")
end)
settingsBtn.MouseButton1Click:Connect(function()
    settingsFrame.Visible = not settingsFrame.Visible
    if not settingsFrame.Visible then applySettings("Ajustes") end
end)

--==================================================
-- REAPARECER
--==================================================
localPlayer.CharacterAdded:Connect(function()
    if knockbackEnabled then disableKnockback() enableKnockback() end
    if antiHitEnabled  then enableAntiHit() end
    if speedEnabled    then maintainSpeed() applySettings("respawn") end
    if floorEnabled    then enableFloor() end
    if lockBtnVisible then quickLockBtn.Visible = true end
    if lockActive then startLock() end
end)

--==================================================
-- CONEXIONES (MENÚ)
--==================================================
flyToggleBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyToggleBtn.Text = flying and "Fly ON" or "Fly OFF"
    ascendBtn.Visible  = flying or noclipEnabled
    descendBtn.Visible = flying or noclipEnabled
    if flying then
        if noclipEnabled then
            noclipEnabled = false
            noclipToggleBtn.Text = "Noclip OFF"
            stopNoclip()
        end
        startFly()
    else
        ascend=false; descend=false; stopFly()
    end
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
        local ws = walkSlider.get()
        local char = localPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            originalWalkSpeed = originalWalkSpeed or hum.WalkSpeed
            currentSpeed      = math.clamp(ws, 10, WALK_MAX_SPEED)
            hum.WalkSpeed     = currentSpeed
        end
        speedToggleBtn.Text = "Speed ON"
        speedTarget = "walk"
    end
    logEvent("Speed: " .. (speedEnabled and "ON" or "OFF"))
end)

lockToggleBtn.MouseButton1Click:Connect(function()
    lockBtnVisible = not lockBtnVisible
    quickLockBtn.Visible = lockBtnVisible
    lockToggleBtn.Text = lockBtnVisible and "Lock Btn ON" or "Lock Btn OFF"
    if not lockBtnVisible and lockActive then stopLock() end
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
        noclipSpeed = math.clamp(noclipSlider.get(), 10, NOCLIP_MAX_SPEED)
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
-- QUICK LOCK
--==================================================
quickLockBtn.MouseButton1Click:Connect(function()
    if not lockActive then startLock() else stopLock() end
end)

--==================================================
-- FLECHAS SPEED y ASCENSO/DESCENSO
--==================================================
speedUpBtn.MouseButton1Click:Connect(function()
    if speedTarget == "walk" and speedEnabled then
        local char = localPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            currentSpeed = math.min((hum.WalkSpeed or 16) + speedIncrement, WALK_MAX_SPEED)
            hum.WalkSpeed = currentSpeed
            walkSlider.set(currentSpeed)
            logEvent(("Speed + → %d"):format(currentSpeed))
        end
    elseif speedTarget == "noclip" and noclipEnabled then
        noclipSpeed  = math.min(noclipSpeed + speedIncrement, NOCLIP_MAX_SPEED)
        noclipSlider.set(noclipSpeed)
        logEvent(("Noclip Speed + → %d"):format(noclipSpeed))
    end
end)
speedDownBtn.MouseButton1Click:Connect(function()
    if speedTarget == "walk" and speedEnabled then
        local char = localPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local baseMin = originalWalkSpeed or 10
            currentSpeed  = math.max((hum.WalkSpeed or 16) - speedIncrement, baseMin)
            currentSpeed  = math.min(currentSpeed, WALK_MAX_SPEED)
            hum.WalkSpeed = currentSpeed
            walkSlider.set(currentSpeed)
            logEvent(("Speed - → %d"):format(currentSpeed))
        end
    elseif speedTarget == "noclip" and noclipEnabled then
        noclipSpeed  = math.max(noclipSpeed - speedIncrement, 10)
        noclipSlider.set(noclipSpeed)
        logEvent(("Noclip Speed - → %d"):format(noclipSpeed))
    end
end)
ascendBtn.MouseButton1Down:Connect(function() ascend = true end)
ascendBtn.MouseButton1Up:Connect(function()   ascend = false end)
descendBtn.MouseButton1Down:Connect(function() descend = true end)
descendBtn.MouseButton1Up:Connect(function()   descend = false end)

--==================================================
-- MOSTRAR/OCULTAR MENÚ
--==================================================
openBtn.MouseButton1Click:Connect(function()
    dragFrame.Visible = false
    menuFrame.Visible = true
end)
closeBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    dragFrame.Visible = true
end)

-- Auto-activar Anti-Hit (mejorado) por defecto
enableAntiHit()

print("✅ Script cargado: Speed con tope alto y Anti-Hit mejorado (estabilidad en aire y salto)")
