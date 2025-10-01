-- LocalScript COMPLETO (pegar tal cual en StarterPlayerScripts o StarterGui)
-- Funciones: Fly, ESP, Speed, Lock (Aim Assist al más cercano), Noclip, Anti-Hit mejorado, Knockback, Floor, HUD, Ajustes, TP-Server
-- UI simplificada estilo “web”: pocos colores, grises suaves + acento teal. Arrastre estable. Todo dentro del viewport.

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
-- PARÁMETROS
--==================================================
-- Speed
local SPEED_INC_DEFAULT     = 6
local WALK_MAX_SPEED        = 500
local NOCLIP_MAX_SPEED      = 300
local FLY_DEFAULT_SPEED     = 60
local NOCLIP_DEFAULT_SPEED  = 60

-- Lock / Aim Assist
local LOCK_RANGE            = 230   -- rango de búsqueda
local LOCK_FOV_DEG          = 120   -- FOV de captura (cono frente a cámara)
local LOCK_SMOOTH_ALPHA     = 0.10  -- lerp por frame (más bajo = más suave)
local LOCK_MAX_DEG_PER_SEC  = 220   -- límite de giro por segundo
local LOCK_STICKY           = true  -- si true: siempre se pega al más cercano dentro de FOV

-- Anti-Hit (estabilidad)
local AH_MAX_FALL_SPEED     = -140  -- límite caída rápida (baja más rápido pero controlado)
local AH_UPWARD_CAP_GROUND  = 10    -- tope hacia arriba si estás en suelo
local AH_UPWARD_CAP_AIR     = 8     -- tope hacia arriba en aire si NO saltas
local AH_JUMP_UP_CAP        = 55    -- tope hacia arriba cuando saltas
local AH_MAX_ACCEL_PER_SEC  = 260   -- límite de cambio de velocidad por segundo (suaviza)
local AH_PURGE_BODYMOVERS   = true  -- elimina Body* extraños ajenos al script (cliente)

--==================================================
-- GUI (estilo web simple)
--==================================================
local function corner(o, r) local c=Instance.new("UICorner",o); c.CornerRadius=UDim.new(0,r or 8); return c end

local screenGui = Instance.new("ScreenGui")
screenGui.Name, screenGui.ResetOnSpawn, screenGui.IgnoreGuiInset, screenGui.DisplayOrder = "FlySpeedESPLockGui", false, true, 100
screenGui.Parent = playerGui

-- Paleta simple
local COL_BG  = Color3.fromRGB(26,28,33)   -- fondo panel
local COL_BTN = Color3.fromRGB(40,44,52)   -- botón base gris
local COL_TXT = Color3.fromRGB(230,235,240)
local COL_ACC = Color3.fromRGB(38,166,154) -- teal acento
local COL_RED = Color3.fromRGB(235,70,70)

-- Botón flotante (☰) minimal
local dragFrame = Instance.new("Frame", screenGui)
dragFrame.Size, dragFrame.Position, dragFrame.BackgroundTransparency, dragFrame.Active, dragFrame.ZIndex =
    UDim2.new(0,56,0,56), UDim2.new(0.08,0,0.75,0), 1, true, 100

local openBtn = Instance.new("TextButton", dragFrame)
openBtn.Size, openBtn.BackgroundColor3, openBtn.TextColor3, openBtn.Font, openBtn.TextSize, openBtn.Text, openBtn.BorderSizePixel, openBtn.ZIndex =
    UDim2.new(1,0,1,0), COL_ACC, Color3.new(1,1,1), Enum.Font.GothamBold, 26, "☰", 0, 101
corner(openBtn, 12)

-- Menú principal (ligeramente más alto para incluir TP-Server)
local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size, menuFrame.Position, menuFrame.BackgroundColor3, menuFrame.Visible, menuFrame.Active, menuFrame.ZIndex =
    UDim2.new(0,300,0,360), UDim2.new(0.5,-150,0.5,-180), COL_BG, false, true, 100
corner(menuFrame, 10)

local titleBar = Instance.new("Frame", menuFrame)
titleBar.BackgroundColor3, titleBar.Size, titleBar.Position, titleBar.BorderSizePixel, titleBar.ZIndex =
    Color3.fromRGB(30,32,38), UDim2.new(1,0,0,42), UDim2.new(0,0,0,0), 0, 101
corner(titleBar, 10)

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.BackgroundTransparency, titleLabel.Text, titleLabel.TextColor3, titleLabel.Font, titleLabel.TextSize, titleLabel.TextXAlignment,
titleLabel.Size, titleLabel.Position, titleLabel.ZIndex =
    1, "Menú", COL_TXT, Enum.Font.GothamBold, 20, Enum.TextXAlignment.Left, UDim2.new(1,-60,1,0), UDim2.new(0,16,0,0), 101

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size, closeBtn.Position, closeBtn.BackgroundColor3, closeBtn.TextColor3, closeBtn.Font, closeBtn.TextSize, closeBtn.Text, closeBtn.BorderSizePixel, closeBtn.ZIndex =
    UDim2.new(0,28,0,28), UDim2.new(1,-36,0,7), COL_RED, Color3.new(1,1,1), Enum.Font.GothamBold, 18, "×", 0, 101
corner(closeBtn, 8)

-- Helper botón simple
local function makeButton(parent, name, text, pos)
    local b = Instance.new("TextButton", parent)
    b.Name, b.Size, b.Position, b.BackgroundColor3, b.TextColor3, b.Font, b.TextSize, b.Text, b.BorderSizePixel, b.ZIndex =
        name, UDim2.new(0,140,0,40), pos, COL_BTN, Color3.new(1,1,1), Enum.Font.GothamSemibold, 18, text, 0, 101
    corner(b, 8); return b
end

-- Grid 5x2 + fila extra TP (6x2)
local gridY0, rowH, colX1, colX2 = 54, 46, 10, 150
local flyToggleBtn     = makeButton(menuFrame,"FlyToggle",     "Fly OFF",         UDim2.new(0,colX1,0,gridY0+0*rowH))
local espToggleBtn     = makeButton(menuFrame,"ESPToggle",     "ESP OFF",         UDim2.new(0,colX2,0,gridY0+0*rowH))
local speedToggleBtn   = makeButton(menuFrame,"SpeedToggle",   "Speed OFF",       UDim2.new(0,colX1,0,gridY0+1*rowH))
local lockToggleBtn    = makeButton(menuFrame,"LockToggle",    "Lock Btn OFF",    UDim2.new(0,colX2,0,gridY0+1*rowH))
local noclipToggleBtn  = makeButton(menuFrame,"NoclipToggle",  "Noclip OFF",      UDim2.new(0,colX1,0,gridY0+2*rowH))
local antiHitToggleBtn = makeButton(menuFrame,"AntiHitToggle", "Anti-Hit ON",     UDim2.new(0,colX2,0,gridY0+2*rowH))
local knockToggleBtn   = makeButton(menuFrame,"KnockToggle",   "Knockback OFF",   UDim2.new(0,colX1,0,gridY0+3*rowH))
local floorToggleBtn   = makeButton(menuFrame,"FloorToggle",   "Floor OFF",       UDim2.new(0,colX2,0,gridY0+3*rowH))
local hudToggleBtn     = makeButton(menuFrame,"HUDToggle",     "HUD OFF",         UDim2.new(0,colX1,0,gridY0+4*rowH))
local settingsBtn      = makeButton(menuFrame,"SettingsBtn",   "Ajustes",         UDim2.new(0,colX2,0,gridY0+4*rowH))

-- Fila extra: TP-Server (2 columnas)
local tpBtn = Instance.new("TextButton", menuFrame)
tpBtn.Size, tpBtn.Position, tpBtn.BackgroundColor3, tpBtn.TextColor3, tpBtn.Font, tpBtn.TextSize, tpBtn.Text, tpBtn.BorderSizePixel, tpBtn.ZIndex =
    UDim2.new(0,280,0,40), UDim2.new(0,10,0,gridY0+5*rowH), COL_ACC, Color3.new(1,1,1), Enum.Font.GothamBold, 18, "TP a tu servidor (Privado)", 0, 101
corner(tpBtn, 8)

-- Botones laterales móviles (ascenso/descenso & speed +/-)
local ascendBtn, descendBtn, speedUpBtn, speedDownBtn = Instance.new("TextButton"), Instance.new("TextButton"), Instance.new("TextButton"), Instance.new("TextButton")
ascendBtn.Parent, descendBtn.Parent, speedUpBtn.Parent, speedDownBtn.Parent = screenGui, screenGui, screenGui, screenGui

local function styleSide(btn, pos, txt)
    btn.Size, btn.Position, btn.BackgroundColor3, btn.TextColor3, btn.Font, btn.TextSize, btn.Text, btn.BorderSizePixel, btn.Visible, btn.ZIndex =
        UDim2.new(0,52,0,52), pos, COL_ACC, Color3.new(1,1,1), Enum.Font.GothamBold, 20, txt, 0, false, 101
    corner(btn, 12)
end
styleSide(ascendBtn,   UDim2.new(0.86,0,0.46,0), "↑")
styleSide(descendBtn,  UDim2.new(0.86,0,0.61,0), "↓")
styleSide(speedUpBtn,  UDim2.new(0.72,0,0.46,0), "＋")
styleSide(speedDownBtn,UDim2.new(0.72,0,0.61,0), "－")

--==================================================
-- ESTADO
--==================================================
local flying, espEnabled, speedEnabled, noclipEnabled, antiHitEnabled, knockbackEnabled, floorEnabled =
      false,  false,     false,        false,         true,            false,             false
local lockBtnVisible, lockActive = false, false
local ascend, descend = false, false

local bodyGyro, bodyVel, flyConnection
local currentHighlights, espConnections, espGlobalConnection = {}, {}, nil
local originalWalkSpeed, currentSpeed, speedConnection = nil, nil, nil
local speedIncrement, speedTarget = SPEED_INC_DEFAULT, nil

local noclipSpeed = NOCLIP_DEFAULT_SPEED
local noclipBodyGyro, noclipBodyVel, noclipConnection, noclipCollisionConn = nil, nil, nil, nil

local targetCharacter, lockConnection = nil, nil
local antiDamageConn, platformConn, stateConn, antiKnockConn = nil, nil, nil, nil
local knownOurBodyMovers = {} -- para no eliminar los nuestros

local knockbackConnections = {}
local knockbackPower, upwardPower = 100, 50
local floorConnection

--==================================================
-- HUD de Registro
--==================================================
local hudFrame = Instance.new("Frame", screenGui)
hudFrame.Name, hudFrame.Size, hudFrame.Position, hudFrame.BackgroundColor3, hudFrame.BackgroundTransparency, hudFrame.Visible, hudFrame.Active, hudFrame.ZIndex =
    "LogHUD", UDim2.new(0,280,0,150), UDim2.new(0.03,0,0.12,0), Color3.fromRGB(22,24,28), 0.1, false, true, 102
corner(hudFrame, 10)

local hudTop = Instance.new("Frame", hudFrame)
hudTop.Size, hudTop.Position, hudTop.BackgroundColor3, hudTop.BorderSizePixel, hudTop.ZIndex =
    UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), Color3.fromRGB(28,30,36), 0, 103
corner(hudTop, 10)

local hudTitle = Instance.new("TextLabel", hudTop)
hudTitle.BackgroundTransparency, hudTitle.Text, hudTitle.TextColor3, hudTitle.Font, hudTitle.TextSize, hudTitle.TextXAlignment,
hudTitle.Size, hudTitle.Position, hudTitle.ZIndex =
    1, "Registro", COL_TXT, Enum.Font.GothamBold, 15, Enum.TextXAlignment.Left, UDim2.new(1,-56,1,0), UDim2.new(0,10,0,0), 103

local hudClear = Instance.new("TextButton", hudTop)
hudClear.Size, hudClear.Position, hudClear.BackgroundColor3, hudClear.TextColor3, hudClear.Text, hudClear.Font, hudClear.TextSize, hudClear.BorderSizePixel, hudClear.ZIndex =
    UDim2.new(0,24,0,24), UDim2.new(1,-56,0,2), COL_ACC, Color3.new(1,1,1), "⟲", Enum.Font.GothamBold, 14, 0, 103
corner(hudClear, 8)

local hudClose = Instance.new("TextButton", hudTop)
hudClose.Size, hudClose.Position, hudClose.BackgroundColor3, hudClose.TextColor3, hudClose.Text, hudClose.Font, hudClose.TextSize, hudClose.BorderSizePixel, hudClose.ZIndex =
    UDim2.new(0,24,0,24), UDim2.new(1,-28,0,2), COL_RED, Color3.new(1,1,1), "×", Enum.Font.GothamBold, 14, 0, 103
corner(hudClose, 8)

local hudScroll = Instance.new("ScrollingFrame", hudFrame)
hudScroll.Size, hudScroll.Position, hudScroll.BackgroundTransparency, hudScroll.BorderSizePixel, hudScroll.ScrollBarThickness, hudScroll.ZIndex =
    UDim2.new(1,-12,1,-36), UDim2.new(0,6,0,32), 1, 0, 4, 102
local hudList = Instance.new("UIListLayout", hudScroll)
hudList.SortOrder, hudList.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0,4)

local function updateCanvas()
    hudScroll.CanvasSize = UDim2.new(0,0,0, hudList.AbsoluteContentSize.Y + 8)
    hudScroll.CanvasPosition = Vector2.new(0, math.max(0, hudList.AbsoluteContentSize.Y - hudScroll.AbsoluteSize.Y))
end
hudList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

local hudEnabled = false
local function colorForMessage(msg)
    msg = (msg or ""):lower()
    if msg:find("on") or msg:find("visible") then return Color3.fromRGB(160,230,180)
    elseif msg:find("off") or msg:find("oculto") or msg:find("perdido") then return Color3.fromRGB(240,170,170)
    elseif msg:find("speed") or msg:find("noclip") then return Color3.fromRGB(220,210,150)
    else return COL_TXT end
end
local function logEvent(msg)
    print(msg)
    if not hudEnabled then return end
    local lab = Instance.new("TextLabel")
    lab.BackgroundTransparency, lab.TextXAlignment, lab.TextYAlignment, lab.Font, lab.TextSize, lab.TextColor3,
    lab.Size, lab.Text, lab.ZIndex, lab.Parent =
        1, Enum.TextXAlignment.Left, Enum.TextYAlignment.Center, Enum.Font.GothamSemibold, 14, colorForMessage(msg),
        UDim2.new(1,-6,0,18), os.date("%H:%M:%S") .. "  " .. (msg or ""), 102, hudScroll
    updateCanvas()
    Debris:AddItem(lab, 14)
end
hudClose.MouseButton1Click:Connect(function()
    hudEnabled = false; hudFrame.Visible = false; hudToggleBtn.Text = "HUD OFF"; logEvent("HUD oculto")
end)
hudClear.MouseButton1Click:Connect(function()
    for _, ch in ipairs(hudScroll:GetChildren()) do if ch:IsA("TextLabel") then ch:Destroy() end end
    updateCanvas(); logEvent("HUD limpiado")
end)

--==================================================
-- DRAG util (simple y estable)
--==================================================
local draggingFlag, startPosInput, startPosGui
local function beginDrag(input, gui)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFlag, startPosInput, startPosGui = true, input.Position, gui.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingFlag=false end end)
    end
end
local function updateDrag(input, gui)
    if not draggingFlag then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - startPosInput
    local newPos = UDim2.new(startPosGui.X.Scale, startPosGui.X.Offset+delta.X, startPosGui.Y.Scale, startPosGui.Y.Offset+delta.Y)
    local cam = Workspace.CurrentCamera
    local vp  = cam and cam.ViewportSize or Vector2.new(800,600)
    local s   = gui.AbsoluteSize
    local maxX, maxY = vp.X - s.X, vp.Y - s.Y
    gui.Position = UDim2.new(0, math.clamp(newPos.X.Offset, 0, math.max(0,maxX)), 0, math.clamp(newPos.Y.Offset, 0, math.max(0,maxY)))
end
local function makeDraggable(gui)
    gui.InputBegan:Connect(function(i) beginDrag(i, gui) end)
    gui.InputChanged:Connect(function(i) updateDrag(i, gui) end)
end
makeDraggable(dragFrame); makeDraggable(openBtn); makeDraggable(menuFrame); makeDraggable(hudFrame)

--==================================================
-- UTILIDADES
--==================================================
local function markOurs(inst) if inst then knownOurBodyMovers[inst]=true end end

local function purgeForeignBodyMovers()
    if not AH_PURGE_BODYMOVERS then return end
    local char = localPlayer.Character
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BodyVelocity") or d:IsA("BodyPosition") or d:IsA("BodyGyro") or d:IsA("BodyAngularVelocity") or d:IsA("BodyForce") or d:IsA("BodyThrust") then
            if not knownOurBodyMovers[d] then
                pcall(function()
                    -- Anular influencia en cliente (si el servidor lo recrea, volvemos a purgar en el siguiente Heartbeat)
                    if d:IsA("BodyVelocity") then d.Velocity = Vector3.new() end
                    if d:IsA("BodyPosition") then d.P = 0; d.D = 1000 end
                    if d:IsA("BodyGyro") then d.P = 0 end
                    d:Destroy()
                end)
            end
        end
    end
end

local function setCharacterCollision(enabled)
    local char = localPlayer.Character; if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = enabled end
    end
end

--==================================================
-- FLY
--==================================================
local function startFly()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp  = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    bodyGyro = Instance.new("BodyGyro", hrp); bodyGyro.P=9e4; bodyGyro.MaxTorque=Vector3.new(math.huge,math.huge,math.huge); markOurs(bodyGyro)
    bodyVel  = Instance.new("BodyVelocity", hrp); bodyVel.MaxForce=Vector3.new(math.huge,math.huge,math.huge); bodyVel.P=9e4; markOurs(bodyVel)
    flyConnection = RunService.RenderStepped:Connect(function()
        local dir = Vector3.new(); local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude>0 then dir += hum.MoveDirection end
        if ascend then dir += Vector3.new(0,1,0) end; if descend then dir += Vector3.new(0,-1,0) end
        if dir.Magnitude>0 then dir=dir.Unit end
        bodyVel.Velocity = dir * FLY_DEFAULT_SPEED
        local cam = Workspace.CurrentCamera; if cam then bodyGyro.CFrame = cam.CFrame end
    end)
end
local function stopFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection=nil end
    if bodyGyro then bodyGyro:Destroy(); knownOurBodyMovers[bodyGyro]=nil; bodyGyro=nil end
    if bodyVel  then bodyVel:Destroy();  knownOurBodyMovers[bodyVel]=nil;  bodyVel=nil end
end

--==================================================
-- ESP
--==================================================
local function enableESP()
    local function hi(plr, character)
        if not character or not plr then return end
        local h = currentHighlights[plr]
        if not h then
            h = Instance.new("Highlight")
            h.FillColor           = Color3.fromRGB(255,72,164) -- sutil rosa
            h.FillTransparency    = 0.6
            h.OutlineColor        = Color3.fromRGB(240,240,245)
            h.OutlineTransparency = 0.2
            h.Adornee             = character
            h.Parent              = character
            currentHighlights[plr] = h
        else
            h.Adornee = character; h.Parent = character
        end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            hi(plr, plr.Character)
            espConnections[plr] = plr.CharacterAdded:Connect(function(char) if espEnabled then task.defer(function() hi(plr, char) end) end end)
        end
    end
    espGlobalConnection = Players.PlayerAdded:Connect(function(plr)
        if plr~=localPlayer and espEnabled then
            hi(plr, plr.Character)
            espConnections[plr] = plr.CharacterAdded:Connect(function(char) if espEnabled then task.defer(function() hi(plr, char) end) end end)
        end
    end)
end
local function disableESP()
    for _, conn in pairs(espConnections) do if conn then conn:Disconnect() end end; espConnections={}
    if espGlobalConnection then espGlobalConnection:Disconnect(); espGlobalConnection=nil end
    for plr,h in pairs(currentHighlights) do if h then h:Destroy() end; currentHighlights[plr]=nil end
end

--==================================================
-- SPEED
--==================================================
local function maintainSpeed()
    if speedConnection then speedConnection:Disconnect() end
    speedConnection = RunService.Heartbeat:Connect(function()
        local char = localPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and speedEnabled and currentSpeed then hum.WalkSpeed = currentSpeed end
    end)
end
local function enableSpeed()
    local char = localPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        originalWalkSpeed = originalWalkSpeed or hum.WalkSpeed
        currentSpeed = math.clamp(math.max(hum.WalkSpeed*2, originalWalkSpeed), 10, WALK_MAX_SPEED)
        hum.WalkSpeed = currentSpeed
        speedUpBtn.Visible, speedDownBtn.Visible = true, true
        maintainSpeed()
    end
end
local function disableSpeed()
    local char = localPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and originalWalkSpeed then hum.WalkSpeed = originalWalkSpeed end
    originalWalkSpeed, currentSpeed = nil, nil
    speedUpBtn.Visible, speedDownBtn.Visible = false, false
    if speedConnection then speedConnection:Disconnect(); speedConnection=nil end
end

--==================================================
-- LOCK / AIM ASSIST (pega al más cercano dentro de FOV)
--==================================================
local function getNearestInFOV()
    local cam = Workspace.CurrentCamera; if not cam then return nil end
    local camPos, camDir = cam.CFrame.Position, cam.CFrame.LookVector
    local best, bestDist = nil, math.huge
    local cosFov = math.cos(math.rad(LOCK_FOV_DEG/2))
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local vec = root.Position - camPos
                local dist = vec.Magnitude
                if dist <= LOCK_RANGE and dist > 1 then
                    local dir = vec / dist
                    local dot = dir:Dot(camDir)
                    if dot >= cosFov then
                        if dist < bestDist then bestDist = dist; best = char end
                    end
                end
            end
        end
    end
    return best
end

local function startLock()
    if lockConnection then lockConnection:Disconnect(); lockConnection=nil end
    targetCharacter = getNearestInFOV()
    if not targetCharacter then logEvent("Lock: sin objetivo"); return end
    lockActive = true
    logEvent("Lock: ON → "..(targetCharacter.Name or "objetivo"))
    lockConnection = RunService.RenderStepped:Connect(function(dt)
        local cam = Workspace.CurrentCamera; if not cam then return end
        -- modo “sticky”: siempre elegir el más cercano dentro de FOV (evita perderlo)
        if LOCK_STICKY then
            local n = getNearestInFOV(); if n then targetCharacter = n end
        end
        if not targetCharacter or not targetCharacter.Parent then
            lockConnection:Disconnect(); lockConnection=nil; lockActive=false; logEvent("Lock: objetivo perdido"); return
        end
        local root = targetCharacter:FindFirstChild("HumanoidRootPart"); if not root then return end
        local camPos = cam.CFrame.Position
        local targetCF = CFrame.lookAt(camPos, root.Position)

        -- Limitar giro brusco + suavizado lerp
        local current = cam.CFrame
        local rel = current:Inverse() * targetCF
        local _,_,_, r00,r01,r02, r10,r11,r12, r20,r21,r22 = rel:components()
        local angle = math.acos(math.clamp((r00+r11+r22-1)/2, -1, 1))
        local maxStep = math.rad(LOCK_MAX_DEG_PER_SEC) * math.max(dt, 0.016)
        local alphaStep = (angle > 1e-6) and math.clamp(maxStep/angle, 0, 1) or 1
        local soft = 1 - (1-LOCK_SMOOTH_ALPHA)^(math.max(dt,0.016)*60)
        cam.CFrame = current:Lerp(targetCF, math.min(alphaStep, soft))
    end)
end
local function stopLock()
    if lockConnection then lockConnection:Disconnect(); lockConnection=nil end
    lockActive=false; logEvent("Lock: OFF")
end

--==================================================
-- NOCLIP
--==================================================
local function startNoclip()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp  = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    setCharacterCollision(false)
    noclipBodyGyro = Instance.new("BodyGyro", hrp); noclipBodyGyro.P=9e4; noclipBodyGyro.MaxTorque=Vector3.new(math.huge,math.huge,math.huge); markOurs(noclipBodyGyro)
    noclipBodyVel  = Instance.new("BodyVelocity", hrp); noclipBodyVel.MaxForce=Vector3.new(math.huge,math.huge,math.huge); noclipBodyVel.P=9e4; markOurs(noclipBodyVel)
    noclipConnection = RunService.RenderStepped:Connect(function()
        local dir = Vector3.new(); local hum=char:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude>0 then dir += hum.MoveDirection end
        if ascend then dir += Vector3.new(0,1,0) end; if descend then dir += Vector3.new(0,-1,0) end
        if dir.Magnitude>0 then dir=dir.Unit end
        noclipBodyVel.Velocity = dir * noclipSpeed
        local cam=Workspace.CurrentCamera; if cam then noclipBodyGyro.CFrame = cam.CFrame end
    end)
    noclipCollisionConn = RunService.Stepped:Connect(function() if noclipEnabled and localPlayer.Character then setCharacterCollision(false) end end)
end
local function stopNoclip()
    setCharacterCollision(true)
    if noclipConnection    then noclipConnection:Disconnect();    noclipConnection=nil end
    if noclipCollisionConn then noclipCollisionConn:Disconnect(); noclipCollisionConn=nil end
    if noclipBodyGyro then noclipBodyGyro:Destroy(); knownOurBodyMovers[noclipBodyGyro]=nil; noclipBodyGyro=nil end
    if noclipBodyVel  then noclipBodyVel:Destroy();  knownOurBodyMovers[noclipBodyVel]=nil;  noclipBodyVel=nil end
end

--==================================================
-- ANTI-HIT MEJORADO (no flotar, no salir disparado; respeta salto)
--==================================================
local function enableAntiHit()
    local char = localPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); if not hum then return end

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
            if antiHitEnabled and (new==Enum.HumanoidStateType.FallingDown or new==Enum.HumanoidStateType.Physics or new==Enum.HumanoidStateType.Ragdoll) then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
    if not antiKnockConn then
        antiKnockConn = RunService.Heartbeat:Connect(function(dt)
            if not antiHitEnabled then return end
            local char = localPlayer.Character; hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart"); if not (hum and root) then return end

            purgeForeignBodyMovers() -- limpia empujes raros
            local isFlyingOrNoclip = flying or noclipEnabled
            local onGround = hum.FloorMaterial ~= Enum.Material.Air
            local jumping  = hum:GetState()==Enum.HumanoidStateType.Jumping or hum.Jump

            local move = hum.MoveDirection
            local base = (noclipEnabled and noclipSpeed) or (currentSpeed or hum.WalkSpeed)
            local desiredH = (move.Magnitude>0) and (move.Unit*base) or Vector3.new()

            local v = root.AssemblyLinearVelocity
            local targetY = v.Y

            if not isFlyingOrNoclip then
                if jumping and v.Y > 0 then
                    targetY = math.min(v.Y, AH_JUMP_UP_CAP) -- permitir salto
                else
                    if onGround then
                        targetY = math.clamp(v.Y, AH_MAX_FALL_SPEED/3, AH_UPWARD_CAP_GROUND)
                    else
                        -- en aire: si no saltas, no dejes subir casi nada; acelera bajada controlada
                        targetY = math.clamp(v.Y, AH_MAX_FALL_SPEED, AH_UPWARD_CAP_AIR)
                        -- si está "flotando" (subiendo muy lento o 0) sin salto ni ascend/descend, empújalo suave hacia abajo
                        if not jumping and not ascend and not descend and v.Y > -6 then
                            targetY = -12
                        end
                    end
                end
            end

            -- Componer y limitar aceleración
            local targetVel = Vector3.new(desiredH.X, targetY, desiredH.Z)
            local maxDelta = AH_MAX_ACCEL_PER_SEC * math.max(dt, 0.016)
            local dv = targetVel - v
            local mag = dv.Magnitude
            if mag > maxDelta then dv = dv.Unit * maxDelta end

            root.AssemblyLinearVelocity = v + dv
        end)
    end
end
local function disableAntiHit()
    if antiDamageConn then antiDamageConn:Disconnect(); antiDamageConn=nil end
    if platformConn  then platformConn:Disconnect();  platformConn=nil end
    if stateConn     then stateConn:Disconnect();     stateConn=nil end
    if antiKnockConn then antiKnockConn:Disconnect(); antiKnockConn=nil end
end

--==================================================
-- KNOCKBACK
--==================================================
local function enableKnockback()
    local char = localPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            knockbackConnections[part] = part.Touched:Connect(function(hit)
                if not knockbackEnabled then return end
                local otherChar = hit:FindFirstAncestorOfClass("Model")
                if otherChar and otherChar ~= char then
                    local otherHum = otherChar:FindFirstChildOfClass("Humanoid")
                    local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
                    if otherHum and otherHum.Health>0 and otherRoot and root then
                        local dir = otherRoot.Position - root.Position; dir = (dir.Magnitude>0) and dir.Unit or Vector3.new()
                        local bv = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.P=1e4; bv.Velocity = dir*knockbackPower + Vector3.new(0,upwardPower,0)
                        bv.Parent = otherRoot; Debris:AddItem(bv, 0.3)
                    end
                end
            end)
        end
    end
end
local function disableKnockback()
    for _,c in pairs(knockbackConnections) do if c then c:Disconnect() end end
    knockbackConnections = {}
end

--==================================================
-- FLOOR
--==================================================
local function spawnFloorPlate()
    local char = localPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local p = Instance.new("Part"); p.Size=Vector3.new(6,1,6); p.Anchored=true; p.Color=Color3.fromRGB(255,200,0)
        p.Position = root.Position - Vector3.new(0,3.5,0); p.Parent=workspace; Debris:AddItem(p,2)
    end
end
local function enableFloor()  floorConnection = RunService.Heartbeat:Connect(spawnFloorPlate) end
local function disableFloor() if floorConnection then floorConnection:Disconnect(); floorConnection=nil end end

--==================================================
-- AJUSTES (sliders compactos)
--==================================================
local settingsFrame = Instance.new("Frame", screenGui)
settingsFrame.Name, settingsFrame.Size, settingsFrame.Position, settingsFrame.BackgroundColor3, settingsFrame.Visible, settingsFrame.Active, settingsFrame.ZIndex =
    "SettingsPanel", UDim2.new(0,300,0,240), UDim2.new(0.54,-150,0.46,-120), Color3.fromRGB(22,24,28), false, true, 110
corner(settingsFrame, 10); makeDraggable(settingsFrame)

local setTop = Instance.new("Frame", settingsFrame)
setTop.Size, setTop.Position, setTop.BackgroundColor3, setTop.BorderSizePixel, setTop.ZIndex =
    UDim2.new(1,0,0,40), UDim2.new(0,0,0,0), Color3.fromRGB(28,30,36), 0, 111
corner(setTop, 10)

local setTitle = Instance.new("TextLabel", setTop)
setTitle.BackgroundTransparency, setTitle.Text, setTitle.TextColor3, setTitle.Font, setTitle.TextSize, setTitle.TextXAlignment,
setTitle.Size, setTitle.Position, setTitle.ZIndex =
    1, "Ajustes", COL_TXT, Enum.Font.GothamBold, 18, Enum.TextXAlignment.Left, UDim2.new(1,-40,1,0), UDim2.new(0,12,0,0), 111

local setClose = Instance.new("TextButton", setTop)
setClose.Size, setClose.Position, setClose.BackgroundColor3, setClose.TextColor3, setClose.Text, setClose.Font, setClose.TextSize, setClose.BorderSizePixel, setClose.ZIndex =
    UDim2.new(0,26,0,26), UDim2.new(1,-32,0,7), COL_RED, Color3.new(1,1,1), "×", Enum.Font.GothamBold, 18, 0, 111
corner(setClose, 8)

local function slider(parent, y, labelText, minVal, maxVal, defaultVal, decimals)
    local holder = Instance.new("Frame", parent); holder.Size=UDim2.new(1,-20,0,52); holder.Position=UDim2.new(0,10,0,y); holder.BackgroundTransparency=1; holder.ZIndex=111
    local lbl = Instance.new("TextLabel", holder); lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.GothamSemibold; lbl.TextSize=14; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.TextColor3=COL_TXT; lbl.Text=labelText; lbl.Size=UDim2.new(1,-70,0,18); lbl.Position=UDim2.new(0,0,0,0); lbl.ZIndex=111
    local valueLbl = Instance.new("TextLabel", holder); valueLbl.BackgroundTransparency=1; valueLbl.Font=Enum.Font.GothamSemibold; valueLbl.TextSize=14
    valueLbl.TextXAlignment=Enum.TextXAlignment.Right; valueLbl.TextColor3=COL_TXT; valueLbl.Size=UDim2.new(0,70,0,18); valueLbl.Position=UDim2.new(1,-70,0,0); valueLbl.ZIndex=111
    local bar = Instance.new("Frame", holder); bar.Size=UDim2.new(1,0,0,8); bar.Position=UDim2.new(0,0,0,28); bar.BackgroundColor3=Color3.fromRGB(40,44,52); bar.BorderSizePixel=0; bar.ZIndex=111; corner(bar, 4)
    local fill = Instance.new("Frame", bar); fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=COL_ACC; fill.BorderSizePixel=0; fill.ZIndex=112; corner(fill, 4)
    local knob = Instance.new("Frame", holder); knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(0,0,0,21); knob.BackgroundColor3=COL_ACC; knob.BorderSizePixel=0; knob.ZIndex=113; corner(knob, 8)

    local dragging=false; local value=defaultVal
    local function setVisualByValue(v)
        local t=(v-minVal)/(maxVal-minVal); t=math.clamp(t,0,1)
        fill.Size=UDim2.new(t,0,1,0); knob.Position=UDim2.new(t,-8,0,21)
        valueLbl.Text = decimals==0 and string.format("%d", math.floor(v+0.5)) or string.format("%."..decimals.."f", v)
    end
    local function setFromX(x)
        local rel=(x-bar.AbsolutePosition.X)/math.max(1, bar.AbsoluteSize.X)
        local v=minVal+math.clamp(rel,0,1)*(maxVal-minVal); if decimals==0 then v=math.floor(v+0.5) end
        value=v; setVisualByValue(v)
    end
    setVisualByValue(value)
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; setFromX(i.Position.X) end end)
    bar.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setFromX(i.Position.X) end end)
    bar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    return { get=function() return value end, set=function(v) value=v; setVisualByValue(v) end }
end

local walkSlider   = slider(settingsFrame,  44, "Walk Speed", 10, WALK_MAX_SPEED,  32, 0)
local noclipSlider = slider(settingsFrame, 100, "Noclip Speed",10, NOCLIP_MAX_SPEED, NOCLIP_DEFAULT_SPEED, 0)
local fovSlider    = slider(settingsFrame, 156, "Lock FOV",   60, 160, LOCK_FOV_DEG, 0)

local function applySettings(fromWhere)
    local ws  = walkSlider.get()
    local ncs = noclipSlider.get()
    local fov = fovSlider.get()

    if speedEnabled then
        local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then currentSpeed=math.clamp(ws,10,WALK_MAX_SPEED); hum.WalkSpeed=currentSpeed; logEvent(("Speed set → %d (%s)"):format(currentSpeed, fromWhere or "Ajustes")) end
    end
    noclipSpeed = math.clamp(ncs,10,NOCLIP_MAX_SPEED)
    LOCK_FOV_DEG = math.clamp(fov,60,160)
    logEvent(("Lock FOV → %d°"):format(LOCK_FOV_DEG))
end
setClose.MouseButton1Click:Connect(function() settingsFrame.Visible=false; applySettings("cierre Ajustes") end)
settingsBtn.MouseButton1Click:Connect(function() settingsFrame.Visible = not settingsFrame.Visible; if not settingsFrame.Visible then applySettings("Ajustes") end end)

--==================================================
-- REAPARECER
--==================================================
localPlayer.CharacterAdded:Connect(function()
    if knockbackEnabled then disableKnockback(); enableKnockback() end
    if antiHitEnabled  then enableAntiHit() end
    if speedEnabled    then maintainSpeed(); applySettings("respawn") end
    if floorEnabled    then enableFloor() end
end)

--==================================================
-- CONEXIONES DE BOTONES
--==================================================
flyToggleBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyToggleBtn.Text = flying and "Fly ON" or "Fly OFF"
    if flying then
        if noclipEnabled then noclipEnabled=false; noclipToggleBtn.Text="Noclip OFF"; stopNoclip() end
        startFly()
    else
        ascend=false; descend=false; stopFly()
    end
    -- mostrar controles verticales solo cuando aplica
    local showAD = flying or noclipEnabled
    ascendBtn.Visible, descendBtn.Visible = showAD, showAD
    logEvent("Fly: "..(flying and "ON" or "OFF"))
end)

espToggleBtn.MouseButton1Click:Connect(function()
    if espEnabled then espEnabled=false; disableESP(); espToggleBtn.Text="ESP OFF"
    else espEnabled=true; enableESP(); espToggleBtn.Text="ESP ON" end
    logEvent("ESP: "..(espEnabled and "ON" or "OFF"))
end)

speedToggleBtn.MouseButton1Click:Connect(function()
    if speedEnabled then
        speedEnabled=false; disableSpeed(); speedToggleBtn.Text="Speed OFF"
        if not noclipEnabled then speedUpBtn.Visible=false; speedDownBtn.Visible=false end
        speedTarget = noclipEnabled and "noclip" or nil
    else
        speedEnabled=true; enableSpeed(); speedToggleBtn.Text="Speed ON"; speedTarget="walk"
    end
    logEvent("Speed: "..(speedEnabled and "ON" or "OFF"))
end)

-- Lock Button (mostrar/ocultar botón rápido en esquina)
local quickLockBtn = Instance.new("TextButton", screenGui)
quickLockBtn.Size, quickLockBtn.Position, quickLockBtn.BackgroundColor3, quickLockBtn.TextColor3, quickLockBtn.Font, quickLockBtn.TextSize,
quickLockBtn.Text, quickLockBtn.BorderSizePixel, quickLockBtn.Visible, quickLockBtn.ZIndex =
    UDim2.new(0,68,0,68), UDim2.new(0.82,0,0.76,0), COL_ACC, Color3.new(1,1,1), Enum.Font.GothamBold, 16, "LOCK", 0, false, 101
corner(quickLockBtn, 12); makeDraggable(quickLockBtn)

lockToggleBtn.MouseButton1Click:Connect(function()
    lockBtnVisible = not lockBtnVisible
    quickLockBtn.Visible = lockBtnVisible
    lockToggleBtn.Text = lockBtnVisible and "Lock Btn ON" or "Lock Btn OFF"
    if not lockBtnVisible and lockActive then stopLock() end
    logEvent("Lock Button: "..(lockBtnVisible and "VISIBLE" or "OCULTO"))
end)

noclipToggleBtn.MouseButton1Click:Connect(function()
    if noclipEnabled then
        noclipEnabled=false; noclipToggleBtn.Text="Noclip OFF"; stopNoclip()
        if not speedEnabled then speedUpBtn.Visible=false; speedDownBtn.Visible=false end
        if not flying then ascendBtn.Visible=false; descendBtn.Visible=false end
        speedTarget = speedEnabled and "walk" or nil
    else
        noclipEnabled=true; noclipToggleBtn.Text="Noclip ON"
        if flying then flying=false; flyToggleBtn.Text="Fly OFF"; ascend=false; descend=false; stopFly() end
        if speedEnabled then speedEnabled=false; disableSpeed(); speedToggleBtn.Text="Speed OFF" end
        startNoclip()
        ascendBtn.Visible, descendBtn.Visible = true, true
        speedUpBtn.Visible, speedDownBtn.Visible = true, true
        speedTarget="noclip"
    end
    logEvent("Noclip: "..(noclipEnabled and "ON" or "OFF"))
end)

antiHitToggleBtn.MouseButton1Click:Connect(function()
    if antiHitEnabled then antiHitEnabled=false; disableAntiHit(); antiHitToggleBtn.Text="Anti-Hit OFF"
    else antiHitEnabled=true; enableAntiHit(); antiHitToggleBtn.Text="Anti-Hit ON" end
    logEvent("Anti-Hit: "..(antiHitEnabled and "ON" or "OFF"))
end)

knockToggleBtn.MouseButton1Click:Connect(function()
    if knockbackEnabled then knockbackEnabled=false; disableKnockback(); knockToggleBtn.Text="Knockback OFF"
    else knockbackEnabled=true; enableKnockback(); knockToggleBtn.Text="Knockback ON" end
    logEvent("Knockback: "..(knockbackEnabled and "ON" or "OFF"))
end)

floorToggleBtn.MouseButton1Click:Connect(function()
    if floorEnabled then floorEnabled=false; disableFloor(); floorToggleBtn.Text="Floor OFF"
    else floorEnabled=true; enableFloor(); floorToggleBtn.Text="Floor ON" end
    logEvent("Floor: "..(floorEnabled and "ON" or "OFF"))
end)

hudToggleBtn.MouseButton1Click:Connect(function()
    hudEnabled = not hudEnabled
    hudFrame.Visible = hudEnabled
    hudToggleBtn.Text = hudEnabled and "HUD ON" or "HUD OFF"
    if hudEnabled then logEvent("HUD visible") end
end)

-- Quick Lock button (Aim Assist toggle)
quickLockBtn.MouseButton1Click:Connect(function()
    if not lockActive then startLock() else stopLock() end
end)

-- Side buttons: Speed +/- y ↑/↓
speedUpBtn.MouseButton1Click:Connect(function()
    if speedTarget=="walk" and speedEnabled then
        local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then currentSpeed=math.min((hum.WalkSpeed or 16)+speedIncrement, WALK_MAX_SPEED); hum.WalkSpeed=currentSpeed; walkSlider.set(currentSpeed); logEvent(("Speed + → %d"):format(currentSpeed)) end
    elseif speedTarget=="noclip" and noclipEnabled then
        noclipSpeed=math.min(noclipSpeed+speedIncrement, NOCLIP_MAX_SPEED); noclipSlider.set(noclipSpeed); logEvent(("Noclip Speed + → %d"):format(noclipSpeed))
    end
end)
speedDownBtn.MouseButton1Click:Connect(function()
    if speedTarget=="walk" and speedEnabled then
        local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local baseMin = originalWalkSpeed or 10
            currentSpeed = math.max((hum.WalkSpeed or 16)-speedIncrement, baseMin); currentSpeed=math.min(currentSpeed, WALK_MAX_SPEED)
            hum.WalkSpeed=currentSpeed; walkSlider.set(currentSpeed); logEvent(("Speed - → %d"):format(currentSpeed))
        end
    elseif speedTarget=="noclip" and noclipEnabled then
        noclipSpeed=math.max(noclipSpeed-speedIncrement,10); noclipSlider.set(noclipSpeed); logEvent(("Noclip Speed - → %d"):format(noclipSpeed))
    end
end)
ascendBtn.MouseButton1Down:Connect(function() ascend=true end)
ascendBtn.MouseButton1Up:Connect(function()   ascend=false end)
descendBtn.MouseButton1Down:Connect(function() descend=true end)
descendBtn.MouseButton1Up:Connect(function()   descend=false end)

-- Menú open/close
openBtn.MouseButton1Click:Connect(function() dragFrame.Visible=false; menuFrame.Visible=true end)
closeBtn.MouseButton1Click:Connect(function() menuFrame.Visible=false; dragFrame.Visible=true end)

--==================================================
-- TP-Server (exactamente como lo pediste anteriormente)
--==================================================
tpBtn.MouseButton1Click:Connect(function()
    -- === INICIO CÓDIGO EXACTO DEL TP ===
    local accesscode = "" -- paste your access code
    local placeid = game.PlaceId
    game.RobloxReplicatedStorage.ContactListIrisInviteTeleport:FireServer(placeid, "", accesscode)

    local md5 = {}
    local hmac = {}
    local base64 = {}

    do
    	do
    		local T = {
    			0xd76aa478,0xe8c7b756,0x242070db,0xc1bdceee,0xf57c0faf,0x4787c62a,0xa8304613,0xfd469501,
    			0x698098d8,0x8b44f7af,0xffff5bb1,0x895cd7be,0x6b901122,0xfd987193,0xa679438e,0x49b40821,
    			0xf61e2562,0xc040b340,0x265e5a51,0xe9b6c7aa,0xd62f105d,0x02441453,0xd8a1e681,0xe7d3fbc8,
    			0x21e1cde6,0xc33707d6,0xf4d50d87,0x455a14ed,0xa9e3e905,0xfcefa3f8,0x676f02d9,0x8d2a4c8a,
    			0xfffa3942,0x8771f681,0x6d9d6122,0xfde5380c,0xa4beea44,0x4bdecfa9,0xf6bb4b60,0xbebfbc70,
    			0x289b7ec6,0xeaa127fa,0xd4ef3085,0x04881d05,0xd9d4d039,0xe6db99e5,0x1fa27cf8,0xc4ac5665,
    			0xf4292244,0x432aff97,0xab9423a7,0xfc93a039,0x655b59c3,0x8f0ccc92,0xffeff47d,0x85845dd1,
    			0x6fa87e4f,0xfe2ce6e0,0xa3014314,0x4e0811a1,0xf7537e82,0xbd3af235,0x2ad7d2bb,0xeb86d391,
    		}
    		local function add(a,b) local lsw=bit32.band(a,0xFFFF)+bit32.band(b,0xFFFF); local msw=bit32.rshift(a,16)+bit32.rshift(b,16)+bit32.rshift(lsw,16); return bit32.bor(bit32.lshift(msw,16), bit32.band(lsw,0xFFFF)) end
    		local function rol(x,n) return bit32.bor(bit32.lshift(x,n), bit32.rshift(x,32-n)) end
    		local function F(x,y,z) return bit32.bor(bit32.band(x,y), bit32.band(bit32.bnot(x),z)) end
    		local function G(x,y,z) return bit32.bor(bit32.band(x,z), bit32.band(y, bit32.bnot(z))) end
    		local function H(x,y,z) return bit32.bxor(x, bit32.bxor(y,z)) end
    		local function I(x,y,z) return bit32.bxor(y, bit32.bor(x, bit32.bnot(z))) end
    		function md5.sum(message)
    			local a,b,c,d=0x67452301,0xefcdab89,0x98badcfe,0x10325476
    			local message_len=#message; local padded_message=message.."\128"
    			while #padded_message%64~=56 do padded_message=padded_message.."\0" end
    			local len_bytes=""; local len_bits=message_len*8
    			for i=0,7 do len_bytes=len_bytes..string.char(bit32.band(bit32.rshift(len_bits,i*8),0xFF)) end
    			padded_message=padded_message..len_bytes
    			for i=1,#padded_message,64 do
    				local chunk=padded_message:sub(i,i+63); local X={}
    				for j=0,15 do local b1,b2,b3,b4=chunk:byte(j*4+1,j*4+4); X[j]=bit32.bor(b1, bit32.lshift(b2,8), bit32.lshift(b3,16), bit32.lshift(b4,24)) end
    				local aa,bb,cc,dd=a,b,c,d; local s={7,12,17,22,5,9,14,20,4,11,16,23,6,10,15,21}
    				for j=0,63 do
    					local f,k,si
    					if j<16 then f=F(b,c,d); k=j; si=j%4
    					elseif j<32 then f=G(b,c,d); k=(1+5*j)%16; si=4+(j%4)
    					elseif j<48 then f=H(b,c,d); k=(5+3*j)%16; si=8+(j%4)
    					else f=I(b,c,d); k=(7*j)%16; si=12+(j%4) end
    					local temp=add(a,f); temp=add(temp,X[k]); temp=add(temp,T[j+1]); temp=rol(temp,s[si+1]); local new_b=add(b,temp); a,b,c,d=d,new_b,b,c
    				end
    				a,b,c,d=add(a,aa),add(b,bb),add(c,cc),add(d,dd)
    			end
    			local function to_le_hex(n) local s=""; for i=0,3 do s=s..string.char(bit32.band(bit32.rshift(n,i*8),0xFF)) end; return s end
    			return to_le_hex(a)..to_le_hex(b)..to_le_hex(c)..to_le_hex(d)
    		end
    	end
    	do
    		function hmac.new(key,msg,hash_func)
    			if #key>64 then key=hash_func(key) end
    			local o,i="",""
    			for idx=1,64 do local byte=(idx<=#key and string.byte(key,idx)) or 0; o=o..string.char(bit32.bxor(byte,0x5C)); i=i..string.char(bit32.bxor(byte,0x36)) end
    			return hash_func(o..hash_func(i..msg))
    		end
    	end
    	do
    		local b="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    		function base64.encode(data)
    			return ((data:gsub(".", function(x) local r,bv="",x:byte(); for i=8,1,-1 do r=r..(bv%2^i-bv%2^(i-1)>0 and "1" or "0") end; return r end).."0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
    				if #x<6 then return "" end; local c=0; for i=1,6 do c=c+((x:sub(i,i)=="1") and 2^(6-i) or 0) end; return b:sub(c+1,c+1)
    			end)..({"","==","="})[#data%3+1])
    		end
    	end
    end
    local function GenerateReservedServerCode(placeId)
    	local uuid={}; for i=1,16 do uuid[i]=math.random(0,255) end
    	uuid[7]=bit32.bor(bit32.band(uuid[7],0x0F),0x40); uuid[9]=bit32.bor(bit32.band(uuid[9],0x3F),0x80)
    	local fb=""; for i=1,16 do fb=fb..string.char(uuid[i]) end
    	local placeIdBytes=""; local pIdRec=placeId; for _=1,8 do placeIdBytes=placeIdBytes..string.char(pIdRec%256); pIdRec=math.floor(pIdRec/256) end
    	local content=fb..placeIdBytes
    	local KEY="e4Yn8ckbCJtw2sv7qmbg"
    	local signature=hmac.new(KEY, content, md5.sum)
    	local ac = base64.encode(signature..content); ac=ac:gsub("+","-"):gsub("/","_")
    	local pad=0; ac=ac:gsub("=", function() pad=pad+1; return "" end); ac=ac..tostring(pad)
    	return ac
    end
    local accessCode = GenerateReservedServerCode(game.PlaceId)
    game.RobloxReplicatedStorage.ContactListIrisInviteTeleport:FireServer(game.PlaceId, "", accessCode)
    -- === FIN CÓDIGO EXACTO DEL TP ===
    logEvent("TP-Server solicitado")
end)

--==================================================
-- AUTO: Anti-Hit ON al cargar
--==================================================
enableAntiHit()
print("✅ UI simple cargada + Anti-Hit mejorado + Lock (aim assist) estable + TP-Server")

--==================================================
-- FIN
--==================================================
