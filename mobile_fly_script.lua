--[[
    Admin Panel MOBILE — Sidebar + Cards pequeñas (Rojo/Negro)
    - Panel alto (arriba), nav vertical a la izquierda y contenido a la derecha.
    - Cards compactas, separadas y con toggles/slider.
    - FIX: WalkSpeed forzado cada frame cuando ON (algunos juegos lo resetean).
    - Visuals: toggle general + ESP (Highlight + nombre AlwaysOnTop) + tamaño de fuente.
    - Noclip (wallhack), Fly (↑/↓), GodMode, Teleport.

    ⚠️ Puede violar TOS de Roblox. Úsalo bajo tu responsabilidad.
]]

-------------------- Services --------------------
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local Workspace        = game:GetService("Workspace")
local LP = Players.LocalPlayer

-------------------- Posición del panel --------------------
local SHEET_TOP    = 0.06   -- MÁS ARRIBA que antes (6% desde arriba)
local SHEET_HEIGHT = 0.88   -- ocupa 88% de la pantalla

-------------------- Tema --------------------
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

-------------------- Estado --------------------
local S = {
    visuals   = true,   -- nuevo toggle maestro de Visuals
    esp       = true,   -- ESP interno (se respeta visuals)
    espSize   = 22,
    god       = false,
    noclip    = false,
    fly       = false,
    walkspeed = false,
    speed     = 120
}

-------------------- Helpers UI --------------------
local function round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = inst
end

local function stroke(inst, th)
    local s = Instance.new("UIStroke")
    s.Thickness = th or 1
    s.Color = Theme.stroke
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
end

local function pad(inst, l, t, r, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = inst
end

local function makeSwitch(defaultOn, onChanged)
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 64, 0, 28)
    switch.BackgroundColor3 = defaultOn and Theme.accent or Theme.railOff
    switch.BorderSizePixel = 0
    round(switch, 14)
    stroke(switch, 1)

    local knob = Instance.new("Frame", switch)
    knob.Size = UDim2.new(0, 24, 0, 24)
    knob.Position = defaultOn and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Theme.sheet
    knob.BorderSizePixel = 0
    round(knob, 12)
    stroke(knob, 1)

    local btn = Instance.new("TextButton", switch)
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""

    local val = defaultOn
    local function set(v, anim)
        val = v
        local g1 = {Position = v and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2)}
        local g2 = {BackgroundColor3 = v and Theme.accent or Theme.railOff}
        if anim then
            TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), g1):Play()
            TweenService:Create(switch, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), g2):Play()
        else
            knob.Position = g1.Position
            switch.BackgroundColor3 = g2.BackgroundColor3
        end
        if onChanged then
            onChanged(val)
        end
    end

    btn.MouseButton1Click:Connect(function()
        set(not val, true)
    end)

    return switch, set
end

local function makeSlider(maxValue, step, defaultValue, onChanged)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 34)
    holder.BackgroundTransparency = 1

    local bar = Instance.new("Frame", holder)
    bar.AnchorPoint = Vector2.new(0, 0.5)
    bar.Position = UDim2.new(0, 0, 0.5, 0)
    bar.Size = UDim2.new(1, -70, 0, 6)
    bar.BackgroundColor3 = Theme.railOff
    bar.BorderSizePixel = 0
    round(bar, 3)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(math.clamp(defaultValue / maxValue, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Theme.accent
    fill.BorderSizePixel = 0
    round(fill, 3)

    local knob = Instance.new("Frame", bar)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(math.clamp(defaultValue / maxValue, 0, 1), 0, 0.5, 0)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.BackgroundColor3 = Theme.sheet
    knob.BorderSizePixel = 0
    round(knob, 7)
    stroke(knob, 1)

    local valueLabel = Instance.new("TextLabel", holder)
    valueLabel.AnchorPoint = Vector2.new(1, 0.5)
    valueLabel.Position = UDim2.new(1, 0, 0.5, 0)
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = Theme.text
    valueLabel.Text = tostring(defaultValue)

    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
        local raw = rel * maxValue
        local stepped = math.floor((raw / step) + 0.5) * step
        stepped = math.clamp(stepped, 0, maxValue)
        fill.Size = UDim2.new(stepped / maxValue, 0, 1, 0)
        knob.Position = UDim2.new(stepped / maxValue, 0, 0.5, 0)
        valueLabel.Text = tostring(stepped)
        if onChanged then
            onChanged(stepped)
        end
    end

    local function begin(input)
        dragging = true
        setFromX(input.Position.X)
    end

    local function finish()
        dragging = false
    end

    local function move(input)
        if dragging then
            setFromX(input.Position.X)
        end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            begin(input)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            finish()
        end
    end)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            begin(input)
        end
    end)
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            finish()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            move(input)
        end
    end)

    return holder
end

local function makeCard(parent, title, subtitle)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, subtitle and 84 or 66)
    card.BackgroundColor3 = Theme.card
    card.BorderSizePixel = 0
    round(card, 12)
    stroke(card, 1)
    card.Parent = parent

    local t = Instance.new("TextLabel", card)
    t.BackgroundTransparency = 1
    t.Position = UDim2.new(0, 12, 0, 8)
    t.Size = UDim2.new(1, -24, 0, 20)
    t.Text = title
    t.Font = Enum.Font.GothamBold
    t.TextSize = 16
    t.TextColor3 = Theme.text
    t.TextXAlignment = Enum.TextXAlignment.Left

    if subtitle then
        local s = Instance.new("TextLabel", card)
        s.BackgroundTransparency = 1
        s.Position = UDim2.new(0, 12, 0, 30)
        s.Size = UDim2.new(1, -24, 0, 18)
        s.Text = subtitle
        s.Font = Enum.Font.Gotham
        s.TextSize = 13
        s.TextColor3 = Theme.subtext
        s.TextXAlignment = Enum.TextXAlignment.Left
    end

    return card
end

-------------------- Roots y capas --------------------
local Root = Instance.new("ScreenGui")
Root.Name = "AdminPanel_Mobile_RedBlack_Sidebar"
Root.ResetOnSpawn = false
Root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Root.Parent = CoreGui

-- Capa para ESP en PlayerGui
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "ESP_Layer"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.Parent = LP:WaitForChild("PlayerGui")

-------------------- Botón Menu (izquierda media) + draggable --------------------
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenMenu"
openBtn.Size = UDim2.new(0, 64, 0, 64)
openBtn.Position = UDim2.new(0.04, 0, 0.40, 0)
openBtn.Text = "Menu"
openBtn.TextSize = 16
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextColor3 = Theme.text
openBtn.BackgroundColor3 = Theme.accent
openBtn.BorderSizePixel = 0
round(openBtn, 32)
stroke(openBtn, 1)
openBtn.ZIndex = 30
openBtn.Parent = Root

do -- drag
    local dragging = false
    local startPos
    local start
    openBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start = input.Position
            startPos = openBtn.Position
        end
    end)
    openBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - start
            openBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-------------------- Panel (alto) --------------------
local sheet = Instance.new("Frame", Root)
sheet.Visible = false
sheet.Size = UDim2.new(1, 0, SHEET_HEIGHT, 0)
sheet.Position = UDim2.new(0, 0, 1, 0)
sheet.BackgroundColor3 = Theme.sheet
sheet.BorderSizePixel = 0
round(sheet, 18)
stroke(sheet, 1)
sheet.ZIndex = 20
sheet.Active = true

local dim = Instance.new("Frame", Root)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 1
dim.Size = UDim2.new(1, 0, 1, 0)
dim.Visible = false
dim.ZIndex = 10
dim.Active = true

-- Contenedor interior: izquierda (nav) + derecha (contenido)
local inner = Instance.new("Frame", sheet)
inner.BackgroundTransparency = 1
inner.Size = UDim2.new(1, 0, 1, 0)
inner.Position = UDim2.new(0, 0, 0, 0)

-- Left sidebar
local left = Instance.new("Frame", inner)
left.Size = UDim2.new(0, 150, 1, 0)
left.Position = UDim2.new(0, 0, 0, 0)
left.BackgroundColor3 = Theme.left
left.BorderSizePixel = 0
round(left, 18)
stroke(left, 1)

local leftTitle = Instance.new("TextLabel", left)
leftTitle.BackgroundTransparency = 1
leftTitle.Size = UDim2.new(1, 0, 0, 48)
leftTitle.Position = UDim2.new(0, 0, 0, 0)
leftTitle.Text = "Admin Panel"
leftTitle.Font = Enum.Font.GothamBlack
leftTitle.TextSize = 16
leftTitle.TextColor3 = Theme.text

local navList = Instance.new("UIListLayout", left)
navList.Padding = UDim.new(0, 8)
navList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function makeNavBtn(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Theme.text
    b.BackgroundColor3 = Theme.card
    b.BorderSizePixel = 0
    round(b, 8)
    stroke(b, 1)
    b.Parent = left
    return b
end

-- Right content
local right = Instance.new("ScrollingFrame", inner)
right.Position = UDim2.new(0, 160, 0, 0)
right.Size = UDim2.new(1, -170, 1, 0)
right.CanvasSize = UDim2.new(0, 0, 0, 0)
right.AutomaticCanvasSize = Enum.AutomaticSize.Y
right.ScrollBarThickness = 6
right.BackgroundTransparency = 1
right.Active = true

local rightList = Instance.new("UIListLayout", right)
rightList.Padding = UDim.new(0, 10)
rightList.HorizontalAlignment = Enum.HorizontalAlignment.Left

-------------------- Secciones --------------------
local Sections = {}
local function showSection(name)
    for n, frame in pairs(Sections) do
        frame.Visible = (n == name)
    end
end
local function createSection(name)
    local frame = Instance.new("Frame", right)
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, -10, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    Sections[name] = frame
    return frame
end

local btnMain     = makeNavBtn("Main")
local btnTeleport = makeNavBtn("Teleport")
local btnVisuals  = makeNavBtn("Visuals")
local btnInfo     = makeNavBtn("Info")

-------------------- FEATURES --------------------
-- WalkSpeed (fuerza constante mientras ON)
local walkConn
local function ensureWalk()
    if walkConn then
        walkConn:Disconnect()
        walkConn = nil
    end
    if S.walkspeed then
        walkConn = RunService.RenderStepped:Connect(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = S.speed
            end
        end)
    else
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
        end
    end
end

-- Fly
local flyGyro, flyVel, flyConn
_G.__Ascend = false
_G.__Descend = false
local ascendBtn, descendBtn
local function startFly()
    local char = LP.Character
    if not char then
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    flyGyro = Instance.new("BodyGyro", root)
    flyGyro.P = 9e4
    flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyVel = Instance.new("BodyVelocity", root)
    flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyVel.P = 9e4
    flyConn = RunService.RenderStepped:Connect(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        local dir = Vector3.new()
        if hum then
            local mv = hum.MoveDirection
            if mv.Magnitude > 0 then
                dir += mv
            end
        end
        if _G.__Ascend then
            dir += Vector3.new(0, 1, 0)
        end
        if _G.__Descend then
            dir += Vector3.new(0, -1, 0)
        end
        if dir.Magnitude > 0 then
            dir = dir.Unit
        end
        flyVel.Velocity = dir * 50
        flyGyro.CFrame = Workspace.CurrentCamera.CFrame
    end)
end
local function stopFly()
    if flyConn then
        flyConn:Disconnect()
        flyConn = nil
    end
    if flyGyro then
        flyGyro:Destroy()
        flyGyro = nil
    end
    if flyVel then
        flyVel:Destroy()
        flyVel = nil
    end
end

-- GodMode
local godConn, originalMaxHealth
local function applyGod()
    local char = LP.Character
    if not char then
        return
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        return
    end
    originalMaxHealth = originalMaxHealth or hum.MaxHealth
    hum.MaxHealth = math.huge
    hum.Health = hum.MaxHealth
    if godConn then
        godConn:Disconnect()
    end
    godConn = hum.HealthChanged:Connect(function()
        if hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)
end
local function removeGod()
    local char = LP.Character
    if not char then
        return
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        return
    end
    if godConn then
        godConn:Disconnect()
        godConn = nil
    end
    if originalMaxHealth then
        hum.MaxHealth = originalMaxHealth
    end
    hum.Health = hum.MaxHealth
end

-- Noclip (wallhack)
local noclipConn
local savedCollide = {}
local function setCharCollision(char, collide)
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            savedCollide[obj] = savedCollide[obj] == nil and obj.CanCollide or savedCollide[obj]
            obj.CanCollide = not collide and savedCollide[obj] or false
        end
    end
end
local function enableNoclip()
    local char = LP.Character
    if not char then
        return
    end
    savedCollide = {}
    setCharCollision(char, true)
    noclipConn = RunService.Stepped:Connect(function()
        local c = LP.Character
        if not c then
            return
        end
        for _, obj in ipairs(c:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CanCollide = false
            end
        end
    end)
end
local function disableNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    for part, prev in pairs(savedCollide) do
        if part and part.Parent then
            part.CanCollide = prev
        end
    end
    savedCollide = {}
end

-- ESP (respetando S.visuals)
local ESPFolders, ESPConns = {}, {}
local pAddConn, pRemConn
local function clearESP(plr)
    if ESPConns[plr] then
        ESPConns[plr]:Disconnect()
        ESPConns[plr] = nil
    end
    if ESPFolders[plr] then
        ESPFolders[plr]:Destroy()
        ESPFolders[plr] = nil
    end
end
local function createESP(plr)
    if not (S.visuals and S.esp) or plr == LP or ESPFolders[plr] then
        return
    end
    local folder = Instance.new("Folder", ESPGui)
    folder.Name = "ESP_" .. plr.Name
    ESPFolders[plr] = folder
    ESPConns[plr] = RunService.Heartbeat:Connect(function()
        if not (S.visuals and S.esp) then
            return
        end
        local char = plr.Character
        if not char or not char.Parent then
            for _, c in ipairs(folder:GetChildren()) do
                c:Destroy()
            end
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then
            for _, c in ipairs(folder:GetChildren()) do
                c:Destroy()
            end
            return
        end
        pcall(function()
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end)
        for _, c in ipairs(folder:GetChildren()) do
            c:Destroy()
        end
        local hl = Instance.new("Highlight", folder)
        hl.Adornee = char
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.FillTransparency = 0.85
        hl.OutlineColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineTransparency = 0
        local bb = Instance.new("BillboardGui", folder)
        bb.Adornee = root
        bb.Size = UDim2.new(0, 240, 0, 50)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 2000
        bb.StudsOffset = Vector3.new(0, 4, 0)
        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextColor3 = Theme.text
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.fromRGB(10, 10, 10)
        lbl.TextSize = S.espSize
        lbl.Text = ("%s [%d HP]"):format(plr.Name, math.floor(hum.Health))
    end)
end
local function toggleESP(on)
    if not on then
        for plr in pairs(ESPFolders) do
            clearESP(plr)
        end
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        createESP(p)
    end
end

-------------------- UI: MAIN --------------------
local secMain = createSection("Main")
do
    local c1 = makeCard(secMain, "WalkSpeed", "Velocidad del personaje")
    local sw1, _ = makeSwitch(S.walkspeed, function(v)
        S.walkspeed = v
        ensureWalk()
    end)
    sw1.AnchorPoint = Vector2.new(1, 0.5)
    sw1.Position = UDim2.new(1, -12, 0, 20)
    sw1.Parent = c1
    local s1 = makeSlider(500, 10, S.speed, function(v)
        S.speed = v
        if S.walkspeed then
            ensureWalk()
        end
    end)
    s1.Position = UDim2.new(0, 12, 0, 40)
    s1.Parent = c1

    local c2 = makeCard(secMain, "Fly", "Botones ↑/↓ en pantalla")
    local sw2, _ = makeSwitch(S.fly, function(v)
        S.fly = v
        if v then
            startFly()
        else
            stopFly()
        end
        _G.__Ascend = false
        _G.__Descend = false
        if ascendBtn then
            ascendBtn.Visible = v and not sheet.Visible
        end
        if descendBtn then
            descendBtn.Visible = v and not sheet.Visible
        end
    end)
    sw2.AnchorPoint = Vector2.new(1, 0.5)
    sw2.Position = UDim2.new(1, -12, 0, 20)
    sw2.Parent = c2

    local c3 = makeCard(secMain, "Noclip (Wallhack)", "Atraviesa paredes/estructuras")
    local sw3, _ = makeSwitch(S.noclip, function(v)
        S.noclip = v
        if v then
            enableNoclip()
        else
            disableNoclip()
        end
    end)
    sw3.AnchorPoint = Vector2.new(1, 0.5)
    sw3.Position = UDim2.new(1, -12, 0, 20)
    sw3.Parent = c3

    local c4 = makeCard(secMain, "GodMode", "Mantiene la salud al máximo")
    local sw4, _ = makeSwitch(S.god, function(v)
        S.god = v
        if v then
            applyGod()
        else
            removeGod()
        end
    end)
    sw4.AnchorPoint = Vector2.new(1, 0.5)
    sw4.Position = UDim2.new(1, -12, 0, 20)
    sw4.Parent = c4
end

-------------------- UI: TELEPORT --------------------
local secTP = createSection("Teleport")
do
    local c = makeCard(secTP, "Jugadores", "Toca un nombre y pulsa TP")
    c.Size = UDim2.new(1, 0, 0, 230)
    local list = Instance.new("ScrollingFrame", c)
    list.Position = UDim2.new(0, 12, 0, 40)
    list.Size = UDim2.new(1, -24, 1, -90)
    list.BackgroundColor3 = Theme.bg
    list.BorderSizePixel = 0
    round(list, 8)
    stroke(list, 1)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.ScrollBarThickness = 4
    local ll = Instance.new("UIListLayout", list)
    ll.Padding = UDim.new(0, 6)
    local selected

    local function refresh()
        for _, ch in ipairs(list:GetChildren()) do
            if ch:IsA("TextButton") then
                ch:Destroy()
            end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local b = Instance.new("TextButton", list)
                b.Size = UDim2.new(1, -8, 0, 30)
                b.Text = p.Name
                b.Font = Enum.Font.Gotham
                b.TextSize = 14
                b.TextColor3 = Theme.text
                b.BackgroundColor3 = Theme.card
                b.BorderSizePixel = 0
                round(b, 8)
                stroke(b, 1)
                b.MouseButton1Click:Connect(function()
                    selected = p
                    for _, o in ipairs(list:GetChildren()) do
                        if o:IsA("TextButton") then
                            o.BackgroundColor3 = Theme.card
                        end
                    end
                    b.BackgroundColor3 = Theme.accentDim
                end)
            end
        end
    end

    local row = Instance.new("Frame", c)
    row.BackgroundTransparency = 1
    row.Position = UDim2.new(0, 12, 1, -44)
    row.Size = UDim2.new(1, -24, 0, 32)
    local upd = Instance.new("TextButton", row)
    upd.Size = UDim2.new(0.48, 0, 1, 0)
    upd.Text = "Actualizar"
    upd.Font = Enum.Font.GothamBold
    upd.TextSize = 14
    upd.TextColor3 = Theme.text
    upd.BackgroundColor3 = Theme.accent
    upd.BorderSizePixel = 0
    round(upd, 8)
    local tp = Instance.new("TextButton", row)
    tp.AnchorPoint = Vector2.new(1, 0)
    tp.Position = UDim2.new(1, 0, 0, 0)
    tp.Size = UDim2.new(0.48, 0, 1, 0)
    tp.Text = "TP"
    tp.Font = Enum.Font.GothamBold
    tp.TextSize = 14
    tp.TextColor3 = Theme.text
    tp.BackgroundColor3 = Theme.accentDim
    tp.BorderSizePixel = 0
    round(tp, 8)

    upd.MouseButton1Click:Connect(refresh)
    tp.MouseButton1Click:Connect(function()
        if not selected then
            return
        end
        local me = LP.Character
        local tar = selected.Character
        if me and tar then
            local myR = me:FindFirstChild("HumanoidRootPart")
            local tR = tar:FindFirstChild("HumanoidRootPart")
            if myR and tR then
                myR.CFrame = tR.CFrame * CFrame.new(0, 3, 0)
            end
        end
    end)
    refresh()
end

-------------------- UI: VISUALS --------------------
local secVis = createSection("Visuals")
do
    local c0 = makeCard(secVis, "Visuals Enabled", "Activa/Desactiva todos los visuales")
    local sw0, _ = makeSwitch(S.visuals, function(v)
        S.visuals = v
        toggleESP(v and S.esp)
    end)
    sw0.AnchorPoint = Vector2.new(1, 0.5)
    sw0.Position = UDim2.new(1, -12, 0, 20)
    sw0.Parent = c0

    local c1 = makeCard(secVis, "ESP", "Highlight rojo + nombres AlwaysOnTop")
    local sw1, _ = makeSwitch(S.esp, function(v)
        S.esp = v
        if S.visuals then
            toggleESP(v)
        else
            toggleESP(false)
        end
    end)
    sw1.AnchorPoint = Vector2.new(1, 0.5)
    sw1.Position = UDim2.new(1, -12, 0, 20)
    sw1.Parent = c1

    local c2 = makeCard(secVis, "Tamaño de nombre", "10–50")
    local s2 = makeSlider(50, 2, S.espSize, function(v)
        S.espSize = v
    end)
    s2.Position = UDim2.new(0, 12, 0, 38)
    s2.Parent = c2
end

-------------------- UI: INFO --------------------
local secInfo = createSection("Info")
do
    makeCard(secInfo, "Tema", "Rojo/Negro. Sidebar + panel derecho, móvil.")
end

-------------------- Nav wiring --------------------
btnMain.MouseButton1Click:Connect(function()
    showSection("Main")
end)
btnTeleport.MouseButton1Click:Connect(function()
    showSection("Teleport")
end)
btnVisuals.MouseButton1Click:Connect(function()
    showSection("Visuals")
end)
btnInfo.MouseButton1Click:Connect(function()
    showSection("Info")
end)
showSection("Main")

-------------------- Botones Fly ↑/↓ --------------------
ascendBtn = Instance.new("TextButton", Root)
ascendBtn.Size = UDim2.new(0, 48, 0, 48)
ascendBtn.Position = UDim2.new(0.88, 0, 0.30, 0)
ascendBtn.Text = "↑"
ascendBtn.TextSize = 22
ascendBtn.Font = Enum.Font.GothamBold
ascendBtn.TextColor3 = Theme.text
ascendBtn.BackgroundColor3 = Theme.accent
ascendBtn.BorderSizePixel = 0
round(ascendBtn, 12)
stroke(ascendBtn, 1)
ascendBtn.Visible = false
ascendBtn.ZIndex = 25
ascendBtn.MouseButton1Down:Connect(function()
    _G.__Ascend = true
end)
ascendBtn.MouseButton1Up:Connect(function()
    _G.__Ascend = false
end)

descendBtn = Instance.new("TextButton", Root)
descendBtn.Size = UDim2.new(0, 48, 0, 48)
descendBtn.Position = UDim2.new(0.88, 0, 0.42, 0)
descendBtn.Text = "↓"
descendBtn.TextSize = 22
descendBtn.Font = Enum.Font.GothamBold
descendBtn.TextColor3 = Theme.text
descendBtn.BackgroundColor3 = Theme.accentDim
descendBtn.BorderSizePixel = 0
round(descendBtn, 12)
stroke(descendBtn, 1)
descendBtn.Visible = false
descendBtn.ZIndex = 25
descendBtn.MouseButton1Down:Connect(function()
    _G.__Descend = true
end)
descendBtn.MouseButton1Up:Connect(function()
    _G.__Descend = false
end)

-------------------- Abrir / Cerrar --------------------
local function openSheet()
    sheet.Visible = true
    dim.Visible = true
    openBtn.Visible = false
    ascendBtn.Visible = S.fly and false
    descendBtn.Visible = S.fly and false
    TweenService:Create(dim, TweenInfo.new(0.15), {BackgroundTransparency = 0.35}):Play()
    TweenService:Create(sheet, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, SHEET_TOP, 0)
    }):Play()
end
local function closeSheet()
    TweenService:Create(dim, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
    TweenService:Create(sheet, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0, 0, 1, 0)
    }):Play()
    task.delay(0.20, function()
        sheet.Visible = false
        dim.Visible = false
        openBtn.Visible = true
        ascendBtn.Visible = S.fly
        descendBtn.Visible = S.fly
    end)
end
openBtn.MouseButton1Click:Connect(openSheet)
dim.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        closeSheet()
    end
end)

-------------------- Respawn reaplicar --------------------
LP.CharacterAdded:Connect(function()
    task.wait(0.8)
    ensureWalk()
    if S.god then
        applyGod()
    end
    if S.noclip then
        enableNoclip()
    end
    if S.visuals and S.esp then
        toggleESP(true)
    end
    if S.fly then
        startFly()
        ascendBtn.Visible = true
        descendBtn.Visible = true
    end
end)

print("✅ Admin Panel (Sidebar móvil) cargado. Ajusta SHEET_TOP/SHEET_HEIGHT si lo quieres aún más arriba.")
