--[[
Admin Panel Mobile Refinado (Rojo/Negro)
 - Panel móvil con navegación vertical y tarjetas compactas.
 - Funcionalidades: WalkSpeed constante, Fly con botones dedicados (↑/↓), Noclip, GodMode, Teleport.
 - Visuals con ESP avanzado: nombres y salud, silueta visible a través de paredes, línea guía.
 - Incluye botón “X” para cerrar el panel y UI optimizada para móviles.
⚠️ Puede violar los Términos de Servicio de Roblox. Úsalo bajo tu responsabilidad.
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local Workspace        = game:GetService("Workspace")

local LP = Players.LocalPlayer

-- Config panel
local SHEET_TOP    = 0.08
local SHEET_HEIGHT = 0.85

-- Colores
local Theme = {
    bg        = Color3.fromRGB(10,10,14),
    sheet     = Color3.fromRGB(20,20,26),
    left      = Color3.fromRGB(18,18,22),
    card      = Color3.fromRGB(30,30,38),
    text      = Color3.fromRGB(245,245,245),
    subtext   = Color3.fromRGB(200,200,210),
    accent    = Color3.fromRGB(220,45,45),
    accentDim = Color3.fromRGB(160,25,25),
    railOff   = Color3.fromRGB(70,70,80),
    stroke    = Color3.fromRGB(70,70,90)
}

-- Estado de toggles
local S = {
    visuals   = true,
    esp       = false,
    espSize   = 22,
    god       = false,
    noclip    = false,
    fly       = false,
    walkspeed = false,
    speed     = 120
}

-------------------- Helpers --------------------
local function round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = inst
end

local function stroke(inst, th)
    local s = Instance.new("UIStroke")
    s.Thickness = th or 1
    s.Color = Theme.stroke
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
end

-- Interruptor con animación
local function makeSwitch(defaultOn, onChanged)
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 56, 0, 26)
    switch.BackgroundColor3 = defaultOn and Theme.accent or Theme.railOff
    switch.BorderSizePixel = 0
    round(switch, 13)
    stroke(switch, 1)

    local knob = Instance.new("Frame", switch)
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = defaultOn and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Theme.sheet
    knob.BorderSizePixel = 0
    round(knob, 11)
    stroke(knob, 1)

    local btn = Instance.new("TextButton", switch)
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""

    local val = defaultOn
    local function set(v, anim)
        val = v
        local g1 = {Position = v and UDim2.new(1,-24,0,2) or UDim2.new(0,2,0,2)}
        local g2 = {BackgroundColor3 = v and Theme.accent or Theme.railOff}
        if anim then
            TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), g1):Play()
            TweenService:Create(switch, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), g2):Play()
        else
            knob.Position = g1.Position
            switch.BackgroundColor3 = g2.BackgroundColor3
        end
        if onChanged then onChanged(val) end
    end

    btn.MouseButton1Click:Connect(function()
        set(not val, true)
    end)
    return switch, set
end

-- Slider
local function makeSlider(maxValue, step, defaultValue, onChanged)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,32)
    holder.BackgroundTransparency = 1

    local bar = Instance.new("Frame", holder)
    bar.AnchorPoint = Vector2.new(0,0.5)
    bar.Position = UDim2.new(0,0,0.5,0)
    bar.Size = UDim2.new(1, -65, 0, 6)
    bar.BackgroundColor3 = Theme.railOff
    bar.BorderSizePixel = 0
    round(bar,3)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(math.clamp(defaultValue / maxValue, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Theme.accent
    fill.BorderSizePixel = 0
    round(fill,3)

    local knob = Instance.new("Frame", bar)
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Position = UDim2.new(math.clamp(defaultValue / maxValue, 0, 1), 0, 0.5, 0)
    knob.Size = UDim2.new(0,12,0,12)
    knob.BackgroundColor3 = Theme.sheet
    knob.BorderSizePixel = 0
    round(knob,6)
    stroke(knob,1)

    local valueLabel = Instance.new("TextLabel", holder)
    valueLabel.AnchorPoint = Vector2.new(1,0.5)
    valueLabel.Position = UDim2.new(1,0,0.5,0)
    valueLabel.Size = UDim2.new(0,55,0,20)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = Theme.text
    valueLabel.Text = tostring(defaultValue)

    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X)/math.max(1, bar.AbsoluteSize.X), 0, 1)
        local raw = rel * maxValue
        local stepped = math.floor((raw / step) + 0.5) * step
        stepped = math.clamp(stepped, 0, maxValue)
        fill.Size = UDim2.new(stepped / maxValue, 0, 1, 0)
        knob.Position = UDim2.new(stepped / maxValue, 0, 0.5, 0)
        valueLabel.Text = tostring(stepped)
        if onChanged then onChanged(stepped) end
    end
    local function beginInput(i) dragging = true; setFromX(i.Position.X) end
    local function finishInput() dragging = false end
    local function moveInput(i) if dragging then setFromX(i.Position.X) end end

    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then beginInput(i) end end)
    bar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then finishInput() end end)
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then beginInput(i) end end)
    knob.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then finishInput() end end)
    UserInputService.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement then moveInput(i) end end)

    return holder
end

local function makeCard(parent, title, subtitle)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0, subtitle and 68 or 52)
    card.BackgroundColor3 = Theme.card
    card.BorderSizePixel = 0
    round(card,10)
    stroke(card,1)
    card.Parent = parent

    local t = Instance.new("TextLabel", card)
    t.BackgroundTransparency = 1
    t.Position = UDim2.new(0,10,0,8)
    t.Size = UDim2.new(1,-20,0,18)
    t.Text = title
    t.Font = Enum.Font.GothamBold
    t.TextSize = 15
    t.TextColor3 = Theme.text
    t.TextXAlignment = Enum.TextXAlignment.Left

    if subtitle then
        local s = Instance.new("TextLabel", card)
        s.BackgroundTransparency = 1
        s.Position = UDim2.new(0,10,0,26)
        s.Size = UDim2.new(1,-20,0,16)
        s.Text = subtitle
        s.Font = Enum.Font.Gotham
        s.TextSize = 12
        s.TextColor3 = Theme.subtext
        s.TextXAlignment = Enum.TextXAlignment.Left
    end
    return card
end

-------------------- UI Principales --------------------
local Root = Instance.new("ScreenGui")
Root.Name = "AdminPanelMobile"
Root.ResetOnSpawn = false
Root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Root.Parent = CoreGui

-- Separar ESP en dos carpetas: una en Workspace para highlight y línea, y otra en PlayerGui para nombre/vida
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "ESP_UI"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.Parent = LP:WaitForChild("PlayerGui")

-- Botón de menú flotante
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenMenu"
openBtn.Size = UDim2.new(0,60,0,60)
openBtn.Position = UDim2.new(0.04,0,0.4,0)
openBtn.Text = "Menu"
openBtn.TextSize = 16
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextColor3 = Theme.text
openBtn.BackgroundColor3 = Theme.accent
openBtn.BorderSizePixel = 0
round(openBtn,30)
stroke(openBtn,1)
openBtn.ZIndex = 30
openBtn.Parent = Root

-- Permitir arrastrar el botón en móviles
do
    local dragging=false; local startPos; local startInputPos
    openBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            startInputPos = i.Position
            startPos = openBtn.Position
        end
    end)
    openBtn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.Touch then
            local delta = i.Position - startInputPos
            openBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Panel superior (sheet)
local sheet = Instance.new("Frame", Root)
sheet.Visible = false
sheet.Size = UDim2.new(1,0,SHEET_HEIGHT,0)
sheet.Position = UDim2.new(0,0,1,0)
sheet.BackgroundColor3 = Theme.sheet
sheet.BorderSizePixel = 0
round(sheet,16)
stroke(sheet,1)
sheet.ZIndex = 20
sheet.Active = true

-- Capa de oscurecimiento detrás
local dim = Instance.new("Frame", Root)
dim.BackgroundColor3 = Color3.new(0,0,0)
dim.BackgroundTransparency = 1
dim.Size = UDim2.new(1,0,1,0)
dim.Visible = false
dim.ZIndex = 10
dim.Active = true

-- Contenedor: izquierda (nav) + derecha (contenido)
local inner = Instance.new("Frame", sheet)
inner.BackgroundTransparency = 1
inner.Size = UDim2.new(1,0,1,0)
inner.Position = UDim2.new(0,0,0,0)

-- Sidebar
local left = Instance.new("Frame", inner)
left.Size = UDim2.new(0,140,1,0)
left.BackgroundColor3 = Theme.left
left.BorderSizePixel = 0
round(left,16)
stroke(left,1)

local leftTitle = Instance.new("TextLabel", left)
leftTitle.BackgroundTransparency=1
leftTitle.Size = UDim2.new(1,0,0,44)
leftTitle.Position = UDim2.new(0,0,0,0)
leftTitle.Text = "Admin"
leftTitle.Font = Enum.Font.GothamBlack
leftTitle.TextSize = 16
leftTitle.TextColor3 = Theme.text

local navList = Instance.new("UIListLayout", left)
navList.Padding = UDim.new(0,6)
navList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function makeNavBtn(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-18,0,32)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Theme.text
    b.BackgroundColor3 = Theme.card
    b.BorderSizePixel = 0
    round(b,8)
    stroke(b,1)
    b.Parent = left
    return b
end

-- Área de contenido scrollable
local right = Instance.new("ScrollingFrame", inner)
right.Position = UDim2.new(0,150,0,0)
right.Size = UDim2.new(1,-160,1,0)
right.BackgroundTransparency=1
right.ScrollBarThickness = 5
right.CanvasSize = UDim2.new(0,0,0,0)
right.AutomaticCanvasSize = Enum.AutomaticSize.Y
right.Active = true

local rightList = Instance.new("UIListLayout", right)
rightList.Padding = UDim.new(0,8)
rightList.HorizontalAlignment = Enum.HorizontalAlignment.Left

-- Secciones
local Sections = {}
local function showSection(name)
    for n,f in pairs(Sections) do
        f.Visible = (n == name)
    end
end
local function createSection(name)
    local frame = Instance.new("Frame", right)
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1,-10,0,0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    Sections[name] = frame
    return frame
end

local btnMain     = makeNavBtn("Main")
local btnTeleport = makeNavBtn("Teleport")
local btnVisuals  = makeNavBtn("Visuals")
local btnInfo     = makeNavBtn("Info")

-------------------- Funciones de Gameplay --------------------
-- Walkspeed
local walkConn
local function ensureWalk()
    if walkConn then walkConn:Disconnect(); walkConn=nil end
    if S.walkspeed then
        walkConn = RunService.RenderStepped:Connect(function()
            local char=LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = S.speed end
        end)
    else
        local char=LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end

-- Fly
local flyGyro, flyVel, flyConn
_G.__Ascend=false; _G.__Descend=false
local function startFly()
    local char=LP.Character
    if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    flyGyro=Instance.new("BodyGyro",root); flyGyro.P=9e4; flyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9)
    flyVel=Instance.new("BodyVelocity",root); flyVel.MaxForce=Vector3.new(9e9,9e9,9e9); flyVel.P=9e4
    flyConn=RunService.RenderStepped:Connect(function()
        local dir=Vector3.new()
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then local mv=hum.MoveDirection; if mv.Magnitude>0 then dir+=mv end end
        if _G.__Ascend then dir+=Vector3.new(0,1,0) end
        if _G.__Descend then dir+=Vector3.new(0,-1,0) end
        if dir.Magnitude>0 then dir=dir.Unit end
        flyVel.Velocity=dir*50
        flyGyro.CFrame=Workspace.CurrentCamera.CFrame
    end)
end
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn=nil end
    if flyGyro then flyGyro:Destroy(); flyGyro=nil end
    if flyVel then flyVel:Destroy(); flyVel=nil end
end

-- GodMode
local godConn; local originalMaxHealth
local function applyGod()
    local char=LP.Character
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not originalMaxHealth then originalMaxHealth=hum.MaxHealth end
    hum.MaxHealth=math.huge; hum.Health=hum.MaxHealth
    if godConn then godConn:Disconnect() end
    godConn=hum.HealthChanged:Connect(function()
        if hum.Health<hum.MaxHealth then hum.Health=hum.MaxHealth end
    end)
end
local function removeGod()
    local char=LP.Character
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if godConn then godConn:Disconnect(); godConn=nil end
    if originalMaxHealth then hum.MaxHealth=originalMaxHealth end
    hum.Health=hum.MaxHealth
end

-- Noclip
local noclipConn; local savedCollide={}
local function setCharCollision(char, disable)
    for _,o in ipairs(char:GetDescendants()) do
        if o:IsA("BasePart") then
            if savedCollide[o] == nil then savedCollide[o] = o.CanCollide end
            o.CanCollide = disable and false or savedCollide[o]
        end
    end
end
local function enableNoclip()
    local char=LP.Character; if not char then return end
    savedCollide={}
    setCharCollision(char,true)
    noclipConn = RunService.Stepped:Connect(function()
        local c=LP.Character; if not c then return end
        for _,o in ipairs(c:GetDescendants()) do
            if o:IsA("BasePart") then o.CanCollide=false end
        end
    end)
end
local function disableNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
    for part, prev in pairs(savedCollide) do
        if part and part.Parent then part.CanCollide = prev end
    end
    savedCollide={}
end

-- ESP Avanzado (silueta a través de paredes + línea guía + nombre)
local ESPWorldFolders, ESPGuiFolders, ESPConns = {}, {}, {}
local pAddConn, pRemConn
local function clearESP(plr)
    if ESPConns[plr] then ESPConns[plr]:Disconnect(); ESPConns[plr]=nil end
    if ESPGuiFolders[plr] then ESPGuiFolders[plr]:Destroy(); ESPGuiFolders[plr]=nil end
    if ESPWorldFolders[plr] then ESPWorldFolders[plr]:Destroy(); ESPWorldFolders[plr]=nil end
end
local function createESP(plr)
    if not (S.visuals and S.esp) then return end
    if plr == LP or ESPConns[plr] then return end

    local worldFolder = Instance.new("Folder", workspace)
    worldFolder.Name = "ESPWorld_"..plr.Name
    ESPWorldFolders[plr] = worldFolder

    local guiFolder = Instance.new("Folder", ESPGui)
    guiFolder.Name = "ESPUI_"..plr.Name
    ESPGuiFolders[plr] = guiFolder

    ESPConns[plr] = RunService.Heartbeat:Connect(function()
        if not (S.visuals and S.esp) then
            worldFolder:ClearAllChildren()
            guiFolder:ClearAllChildren()
            return
        end
        local char = plr.Character
        if not char or not char.Parent then
            worldFolder:ClearAllChildren()
            guiFolder:ClearAllChildren()
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then
            worldFolder:ClearAllChildren()
            guiFolder:ClearAllChildren()
            return
        end
        -- limpiar
        worldFolder:ClearAllChildren()
        guiFolder:ClearAllChildren()

        -- Highlight en mundo (visible a través de paredes)
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillColor = Color3.fromRGB(255,0,0)
        hl.FillTransparency = 0.85
        hl.OutlineColor = Color3.fromRGB(255,0,0)
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = worldFolder

        -- billboard para nombre/vida
        local bb = Instance.new("BillboardGui")
        bb.Adornee = root
        bb.Size = UDim2.new(0,220,0,48)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 2000
        bb.StudsOffset = Vector3.new(0,4,0)
        bb.Parent = guiFolder

        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextColor3 = Theme.text
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.fromRGB(10,10,10)
        lbl.TextSize = S.espSize
        lbl.Text = ("%s [%d HP]"):format(plr.Name, math.floor(hum.Health))

        -- Línea guía
        local myChar = LP.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local distance = (myRoot.Position - root.Position).Magnitude
            local line = Instance.new("Part")
            line.Anchored = true
            line.CanCollide = false
            line.Material = Enum.Material.Neon
            line.Color = Color3.fromRGB(255,0,0)
            line.Transparency = 0.4
            line.Size = Vector3.new(0.05, 0.05, distance)
            line.CFrame = CFrame.new(myRoot.Position, root.Position) * CFrame.new(0,0,-distance/2)
            line.Parent = worldFolder
        end
    end)
end
local function toggleESP(on)
    if not on then
        for plr,_ in pairs(ESPGuiFolders) do clearESP(plr) end
        if pAddConn then pAddConn:Disconnect(); pAddConn=nil end
        if pRemConn then pRemConn:Disconnect(); pRemConn=nil end
        return
    end
    for _,plr in ipairs(Players:GetPlayers()) do createESP(plr) end
    if not pAddConn then pAddConn = Players.PlayerAdded:Connect(createESP) end
    if not pRemConn then pRemConn = Players.PlayerRemoving:Connect(function(p) clearESP(p) end) end
end

-------------------- Crear secciones --------------------
local secMain   = createSection("Main")
local secTP     = createSection("Teleport")
local secVis    = createSection("Visuals")
local secInfo   = createSection("Info")

-- Botones de vuelo (en pantalla, cerca del salto)
local ascendBtn = Instance.new("TextButton", Root)
ascendBtn.Size = UDim2.new(0,42,0,42)
ascendBtn.Position = UDim2.new(0.86,0,0.60,0)
ascendBtn.Text = "↑"
ascendBtn.TextSize = 20
ascendBtn.Font = Enum.Font.GothamBold
ascendBtn.TextColor3 = Theme.text
ascendBtn.BackgroundColor3 = Theme.accent
ascendBtn.BorderSizePixel = 0
round(ascendBtn,10)
stroke(ascendBtn,1)
ascendBtn.Visible = false
ascendBtn.ZIndex = 25
ascendBtn.MouseButton1Down:Connect(function() _G.__Ascend=true end)
ascendBtn.MouseButton1Up:Connect(function() _G.__Ascend=false end)

local descendBtn = Instance.new("TextButton", Root)
descendBtn.Size = UDim2.new(0,42,0,42)
descendBtn.Position = UDim2.new(0.86,0,0.71,0)
descendBtn.Text = "↓"
descendBtn.TextSize = 20
descendBtn.Font = Enum.Font.GothamBold
descendBtn.TextColor3 = Theme.text
descendBtn.BackgroundColor3 = Theme.accentDim
descendBtn.BorderSizePixel = 0
round(descendBtn,10)
stroke(descendBtn,1)
descendBtn.Visible = false
descendBtn.ZIndex = 25
descendBtn.MouseButton1Down:Connect(function() _G.__Descend=true end)
descendBtn.MouseButton1Up:Connect(function() _G.__Descend=false end)

-------------------- Rellenar sección Main --------------------
do
    -- WalkSpeed
    local card1 = makeCard(secMain, "WalkSpeed", "Controla la velocidad")
    local sw1,_ = makeSwitch(S.walkspeed, function(v)
        S.walkspeed=v; ensureWalk()
    end)
    sw1.AnchorPoint=Vector2.new(1,0.5)
    sw1.Position=UDim2.new(1,-10,0,20)
    sw1.Parent=card1
    local slider1 = makeSlider(500,10,S.speed,function(v)
        S.speed=v; if S.walkspeed then ensureWalk() end
    end)
    slider1.Position = UDim2.new(0,10,0,36)
    slider1.Parent = card1

    -- Fly
    local card2 = makeCard(secMain, "Fly", "Activa vuelo (↑/↓)")
    local sw2,_ = makeSwitch(S.fly,function(v)
        S.fly=v; if v then startFly() else stopFly() end
        ascendBtn.Visible = v and not sheet.Visible
        descendBtn.Visible = v and not sheet.Visible
    end)
    sw2.AnchorPoint=Vector2.new(1,0.5)
    sw2.Position=UDim2.new(1,-10,0,20)
    sw2.Parent=card2

    -- Noclip
    local card3 = makeCard(secMain, "Noclip", "Atraviesa estructuras")
    local sw3,_ = makeSwitch(S.noclip, function(v)
        S.noclip=v; if v then enableNoclip() else disableNoclip() end
    end)
    sw3.AnchorPoint=Vector2.new(1,0.5)
    sw3.Position=UDim2.new(1,-10,0,20)
    sw3.Parent=card3

    -- GodMode
    local card4 = makeCard(secMain, "GodMode", "Salud infinita")
    local sw4,_ = makeSwitch(S.god,function(v)
        S.god=v; if v then applyGod() else removeGod() end
    end)
    sw4.AnchorPoint=Vector2.new(1,0.5)
    sw4.Position=UDim2.new(1,-10,0,20)
    sw4.Parent=card4
end

-------------------- Rellenar sección Teleport --------------------
do
    local card = makeCard(secTP, "Jugadores", "Selecciona y pulsa TP")
    card.Size = UDim2.new(1,0,0,280)
    local list = Instance.new("ScrollingFrame", card)
    list.Position = UDim2.new(0,10,0,40)
    list.Size = UDim2.new(1,-20,1,-80)
    list.BackgroundColor3 = Theme.bg
    list.BorderSizePixel = 0
    round(list,8)
    stroke(list,1)
    list.CanvasSize = UDim2.new(0,0,0,0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.ScrollBarThickness = 3

    local ll = Instance.new("UIListLayout", list)
    ll.Padding = UDim.new(0,4)

    local selected
    local function refresh()
        for _,ch in ipairs(list:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then
                local b=Instance.new("TextButton", list)
                b.Size=UDim2.new(1,-6,0,30)
                b.Text=p.Name
                b.Font=Enum.Font.Gotham
                b.TextSize=14
                b.TextColor3=Theme.text
                b.BackgroundColor3=Theme.card
                b.BorderSizePixel=0
                round(b,7); stroke(b,1)
                b.MouseButton1Click:Connect(function()
                    selected=p
                    for _,o in ipairs(list:GetChildren()) do
                        if o:IsA("TextButton") then o.BackgroundColor3=Theme.card end
                    end
                    b.BackgroundColor3=Theme.accentDim
                end)
            end
        end
    end

    local row=Instance.new("Frame",card)
    row.BackgroundTransparency=1
    row.Position=UDim2.new(0,10,1,-36)
    row.Size=UDim2.new(1,-20,0,30)

    local upd=Instance.new("TextButton",row)
    upd.Size=UDim2.new(0.48,0,1,0)
    upd.Text="Actualizar"
    upd.Font=Enum.Font.GothamBold
    upd.TextSize=14
    upd.TextColor3=Theme.text
    upd.BackgroundColor3=Theme.accent
    upd.BorderSizePixel=0
    round(upd,7)

    local tp=Instance.new("TextButton",row)
    tp.AnchorPoint=Vector2.new(1,0)
    tp.Position=UDim2.new(1,0,0,0)
    tp.Size=UDim2.new(0.48,0,1,0)
    tp.Text="TP"
    tp.Font=Enum.Font.GothamBold
    tp.TextSize=14
    tp.TextColor3=Theme.text
    tp.BackgroundColor3=Theme.accentDim
    tp.BorderSizePixel=0
    round(tp,7)

    upd.MouseButton1Click:Connect(refresh)
    tp.MouseButton1Click:Connect(function()
        if not selected then return end
        local me=LP.Character
        local tar=selected.Character
        if me and tar then
            local myR=me:FindFirstChild("HumanoidRootPart")
            local tR=tar:FindFirstChild("HumanoidRootPart")
            if myR and tR then myR.CFrame = tR.CFrame*CFrame.new(0,3,0) end
        end
    end)
    refresh()
end

-------------------- Rellenar sección Visuals --------------------
do
    local card1 = makeCard(secVis, "Visuals", "Activar o desactivar todos")
    local swVis,_ = makeSwitch(S.visuals,function(v)
        S.visuals=v; toggleESP(v and S.esp)
    end)
    swVis.AnchorPoint=Vector2.new(1,0.5)
    swVis.Position=UDim2.new(1,-10,0,20)
    swVis.Parent=card1

    local card2 = makeCard(secVis, "Wallhack (ESP)", "Silueta & línea")
    local swEsp,_ = makeSwitch(S.esp,function(v)
        S.esp=v; if S.visuals then toggleESP(v) else toggleESP(false) end
    end)
    swEsp.AnchorPoint=Vector2.new(1,0.5)
    swEsp.Position=UDim2.new(1,-10,0,20)
    swEsp.Parent=card2

    local card3 = makeCard(secVis, "Nombre tamaño", "Ajusta el tamaño")
    local slider = makeSlider(50,2,S.espSize,function(v) S.espSize=v end)
    slider.Position = UDim2.new(0,10,0,36)
    slider.Parent=card3
end

-------------------- Sección Info --------------------
do
    makeCard(secInfo, "Tema", "Rojo/Negro. UI móvil.")
    makeCard(secInfo, "Aviso", "Puede violar los TOS de Roblox.")
end

-------------------- Navegación --------------------
btnMain.MouseButton1Click:Connect(function() showSection("Main") end)
btnTeleport.MouseButton1Click:Connect(function() showSection("Teleport") end)
btnVisuals.MouseButton1Click:Connect(function() showSection("Visuals") end)
btnInfo.MouseButton1Click:Connect(function() showSection("Info") end)
showSection("Main")

-------------------- Abrir/Cerrar panel --------------------
local function openSheet()
    sheet.Visible=true; dim.Visible=true; openBtn.Visible=false
    ascendBtn.Visible=false; descendBtn.Visible=false
    TweenService:Create(dim, TweenInfo.new(0.15), {BackgroundTransparency=0.35}):Play()
    TweenService:Create(sheet, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position=UDim2.new(0,0,SHEET_TOP,0)}):Play()
end
local function closeSheet()
    TweenService:Create(dim, TweenInfo.new(0.12), {BackgroundTransparency=1}):Play()
    TweenService:Create(sheet, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position=UDim2.new(0,0,1,0)}):Play()
    task.delay(0.20,function()
        sheet.Visible=false; dim.Visible=false; openBtn.Visible=true
        ascendBtn.Visible=S.fly; descendBtn.Visible=S.fly
    end)
end

openBtn.MouseButton1Click:Connect(openSheet)
dim.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch then closeSheet() end
end)

-- Botón X para cerrar
local closeBtn = Instance.new("TextButton", sheet)
closeBtn.Size = UDim2.new(0,26,0,26)
closeBtn.AnchorPoint = Vector2.new(1,0)
closeBtn.Position = UDim2.new(1,-8,0,8)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Theme.text
closeBtn.BackgroundColor3 = Theme.accent
closeBtn.BorderSizePixel = 0
round(closeBtn,13)
stroke(closeBtn,1)
closeBtn.ZIndex = 21
closeBtn.MouseButton1Click:Connect(closeSheet)

-------------------- Reaplicar en respawn --------------------
LP.CharacterAdded:Connect(function()
    task.wait(0.7)
    ensureWalk()
    if S.god then applyGod() end
    if S.noclip then enableNoclip() end
    if S.visuals and S.esp then toggleESP(true) end
    if S.fly then startFly(); ascendBtn.Visible=true; descendBtn.Visible=true end
end)

print("✅ Admin Panel mobile refinado cargado.")
