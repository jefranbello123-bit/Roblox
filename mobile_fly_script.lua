--[[
    Admin Panel Mobile (Rojo/Negro) — POSICIÓN ALTA + FIX TOUCH
    - Panel tipo "bottom sheet" que abre alto (top=10% por defecto).
    - ZIndex/Active configurados para que todos los controles se puedan tocar.
    - Oculta Menu y botones Fly cuando el panel está abierto (evita superposición).
    - Incluye: ESP (Highlight + nombres), WalkSpeed, Fly (↑/↓), GodMode, Noclip, Teleport, Visuals.
    ⚠️ Puede violar TOS de Roblox. Úsalo bajo tu responsabilidad.
]]

-------------------- Services --------------------
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService       = game:GetService("GuiService")
local CoreGui          = game:GetService("CoreGui")
local Workspace        = game:GetService("Workspace")
local LP = Players.LocalPlayer

-------------------- Config de posición del panel --------------------
-- Sube/baja el panel cambiando estos dos:
local SHEET_TOP    = 0.10   -- 0.10 = 10% desde arriba (más pequeño = más alto)
local SHEET_HEIGHT = 0.82   -- 82% de alto

-------------------- Tema --------------------
local Theme = {
    bg        = Color3.fromRGB(10,10,14),
    sheet     = Color3.fromRGB(20,20,26),
    card      = Color3.fromRGB(30,30,38),
    text      = Color3.fromRGB(245,245,245),
    subtext   = Color3.fromRGB(200,200,210),
    accent    = Color3.fromRGB(220,45,45),
    accentDim = Color3.fromRGB(160,25,25),
    railOff   = Color3.fromRGB(70,70,80),
    stroke    = Color3.fromRGB(70,70,90)
}

-------------------- Estado --------------------
local S = { esp=false, god=false, noclip=false, fly=false, walkspeed=false, speed=100, espSize=22 }

-------------------- Helpers UI --------------------
local function round(inst, r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12) c.Parent=inst end
local function stroke(inst, th) local s=Instance.new("UIStroke") s.Thickness=th or 1 s.Color=Theme.stroke s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=inst end
local function pad(inst,l,t,r,b) local p=Instance.new("UIPadding") p.PaddingLeft=UDim.new(0,l or 0) p.PaddingTop=UDim.new(0,t or 0) p.PaddingRight=UDim.new(0,r or 0) p.PaddingBottom=UDim.new(0,b or 0) p.Parent=inst end

-- Switch
local function makeSwitch(parent, defaultOn, onChanged)
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 72, 0, 32)
    switch.BackgroundColor3 = defaultOn and Theme.accent or Theme.railOff
    switch.BorderSizePixel = 0
    round(switch, 16); stroke(switch,1); switch.ZIndex = 22

    local knob = Instance.new("Frame", switch)
    knob.Size = UDim2.new(0, 26, 0, 26)
    knob.Position = defaultOn and UDim2.new(1, -29, 0, 3) or UDim2.new(0, 3, 0, 3)
    knob.BackgroundColor3 = Theme.sheet
    knob.BorderSizePixel = 0
    round(knob, 13); stroke(knob,1); knob.ZIndex = 23

    local btn = Instance.new("TextButton", switch)
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1,0,1,0)
    btn.Text = ""
    btn.ZIndex = 24

    local val = defaultOn
    local function set(on, animate)
        val = on
        local g1 = {Position = on and UDim2.new(1, -29, 0, 3) or UDim2.new(0, 3, 0, 3)}
        local g2 = {BackgroundColor3 = on and Theme.accent or Theme.railOff}
        if animate then
            TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), g1):Play()
            TweenService:Create(switch, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), g2):Play()
        else
            knob.Position = g1.Position
            switch.BackgroundColor3 = g2.BackgroundColor3
        end
        if onChanged then onChanged(val) end
    end
    btn.MouseButton1Click:Connect(function() set(not val, true) end)
    return switch, set
end

-- Slider (bar + knob draggable)
local function makeSlider(parent, maxValue, step, defaultValue, onChanged)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,-10,0,44)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 21

    local bar = Instance.new("Frame", holder)
    bar.AnchorPoint = Vector2.new(0, 0.5)
    bar.Position = UDim2.new(0,0,0.5,0)
    bar.Size = UDim2.new(1, -72, 0, 8)
    bar.BackgroundColor3 = Theme.railOff
    bar.BorderSizePixel = 0
    round(bar,4); stroke(bar,1); bar.ZIndex=21
    bar.Active = true

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(math.clamp(defaultValue/maxValue,0,1),0,1,0)
    fill.BackgroundColor3 = Theme.accent
    fill.BorderSizePixel = 0
    round(fill,4); fill.ZIndex=22

    local knob = Instance.new("Frame", bar)
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Position = UDim2.new(math.clamp(defaultValue/maxValue,0,1),0,0.5,0)
    knob.Size = UDim2.new(0,18,0,18)
    knob.BackgroundColor3 = Theme.sheet
    knob.BorderSizePixel = 0
    round(knob,9); stroke(knob,1); knob.ZIndex=23
    knob.Active = true

    local valueLabel = Instance.new("TextLabel", holder)
    valueLabel.Size = UDim2.new(0,64,1,0)
    valueLabel.AnchorPoint = Vector2.new(1,0)
    valueLabel.Position = UDim2.new(1,0,0,0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 16
    valueLabel.TextColor3 = Theme.text
    valueLabel.Text = tostring(defaultValue)
    valueLabel.ZIndex = 21

    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local raw = rel * maxValue
        local stepped = math.floor((raw / step) + 0.5) * step
        stepped = math.clamp(stepped, 0, maxValue)
        fill.Size = UDim2.new(stepped/maxValue,0,1,0)
        knob.Position = UDim2.new(stepped/maxValue,0,0.5,0)
        valueLabel.Text = tostring(stepped)
        if onChanged then onChanged(stepped) end
    end

    local function begin(i) dragging=true; setFromX(i.Position.X) end
    local function finish() dragging=false end
    local function move(i) if dragging then setFromX(i.Position.X) end end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then begin(i) end
    end)
    bar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then finish() end
    end)
    knob.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then begin(i) end
    end)
    knob.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then finish() end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then move(i) end
    end)

    return holder
end

-- Card
local function makeCard(parent, title, subtitle)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,-24,0, subtitle and 92 or 74)
    card.BackgroundColor3 = Theme.card; card.BorderSizePixel=0
    round(card,14); stroke(card,1); card.Parent=parent; card.ZIndex=21

    local t = Instance.new("TextLabel", card)
    t.BackgroundTransparency=1; t.Position=UDim2.new(0,16,0,10); t.Size=UDim2.new(1,-32,0,22)
    t.Text=title; t.Font=Enum.Font.GothamBold; t.TextSize=18; t.TextColor3=Theme.text; t.TextXAlignment=Enum.TextXAlignment.Left; t.ZIndex=22

    if subtitle then
        local s = Instance.new("TextLabel", card)
        s.BackgroundTransparency=1; s.Position=UDim2.new(0,16,0,36); s.Size=UDim2.new(1,-32,0,20)
        s.Text=subtitle; s.Font=Enum.Font.Gotham; s.TextSize=14; s.TextColor3=Theme.subtext; s.TextXAlignment=Enum.TextXAlignment.Left; s.ZIndex=22
    end
    return card
end

-------------------- Roots y capas --------------------
local Root = Instance.new("ScreenGui")
Root.Name="AdminPanel_Mobile_RedBlack"; Root.ResetOnSpawn=false
Root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Root.Parent = CoreGui

-- Capa para ESP en PlayerGui
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name="ESP_Layer"; ESPGui.ResetOnSpawn=false; ESPGui.IgnoreGuiInset=true
ESPGui.Parent = LP:WaitForChild("PlayerGui")

-------------------- Botón Menu (izquierda-media) + draggable --------------------
local openBtn = Instance.new("TextButton")
openBtn.Name="OpenMenu"; openBtn.Size=UDim2.new(0,64,0,64)
openBtn.Position=UDim2.new(0.04,0,0.40,0)
openBtn.Text="Menu"; openBtn.TextSize=16; openBtn.Font=Enum.Font.GothamBlack
openBtn.TextColor3=Theme.text; openBtn.BackgroundColor3=Theme.accent; openBtn.BorderSizePixel=0
round(openBtn,32); stroke(openBtn,1); openBtn.ZIndex=30; openBtn.Parent=Root

-- Drag del botón Menu
do
    local dragging=false; local startPos; local start
    openBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then dragging=true; start=i.Position; startPos=openBtn.Position end
    end)
    openBtn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.Touch then
            local delta=i.Position-start
            openBtn.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
        end
    end)
end

-------------------- Panel (abre alto) --------------------
local sheet = Instance.new("Frame", Root)
sheet.Visible=false
sheet.Size=UDim2.new(1,0,SHEET_HEIGHT,0)
sheet.Position=UDim2.new(0,0,1,0) -- fuera de pantalla (cierra)
sheet.BackgroundColor3=Theme.sheet; sheet.BorderSizePixel=0
round(sheet,18); stroke(sheet,1); sheet.ZIndex=20
sheet.Active = true -- captura toques

local dim = Instance.new("Frame", Root)
dim.BackgroundColor3=Color3.new(0,0,0); dim.BackgroundTransparency=1
dim.Size=UDim2.new(1,0,1,0); dim.Visible=false; dim.ZIndex=10
dim.Active = true

-- Topbar
local topbar = Instance.new("Frame", sheet)
topbar.Size=UDim2.new(1,0,0,50); topbar.BackgroundColor3=Theme.bg; topbar.BorderSizePixel=0
round(topbar,18); stroke(topbar,1); topbar.ZIndex=21

local title = Instance.new("TextLabel", topbar)
title.BackgroundTransparency=1; title.Position=UDim2.new(0,16,0,0); title.Size=UDim2.new(1,-92,1,0)
title.Text="Admin Panel"; title.Font=Enum.Font.GothamBlack; title.TextSize=18; title.TextColor3=Theme.text
title.TextXAlignment=Enum.TextXAlignment.Left; title.ZIndex=22

local closeBtn = Instance.new("TextButton", topbar)
closeBtn.AnchorPoint=Vector2.new(1,0.5); closeBtn.Position=UDim2.new(1,-8,0.5,0); closeBtn.Size=UDim2.new(0,40,0,34)
closeBtn.BackgroundColor3=Theme.accentDim; closeBtn.Text="×"; closeBtn.TextColor3=Theme.text; closeBtn.BorderSizePixel=0
closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=20; round(closeBtn,10); closeBtn.ZIndex=23

-- Nav horizontal
local nav = Instance.new("ScrollingFrame", sheet)
nav.Position=UDim2.new(0,0,0,50); nav.Size=UDim2.new(1,0,0,48)
nav.CanvasSize=UDim2.new(0,0,0,0); nav.AutomaticCanvasSize=Enum.AutomaticSize.X
nav.ScrollBarThickness=4; nav.BackgroundColor3=Theme.bg; nav.BorderSizePixel=0; nav.ZIndex=21
nav.Active = true; nav.ClipsDescendants = true
local navList = Instance.new("UIListLayout", nav); navList.FillDirection=Enum.FillDirection.Horizontal; navList.Padding=UDim.new(0,8)

local function makeNavBtn(text)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(0,120,0,36); b.Text=text
    b.Font=Enum.Font.GothamBold; b.TextSize=14; b.TextColor3=Theme.text
    b.BackgroundColor3=Theme.card; b.BorderSizePixel=0; round(b,10); stroke(b,1); b.Parent=nav; b.ZIndex=22
    return b
end

-- Content
local content = Instance.new("ScrollingFrame", sheet)
content.Position=UDim2.new(0,0,0,98); content.Size=UDim2.new(1,0,1,-98)
content.CanvasSize=UDim2.new(0,0,0,0); content.AutomaticCanvasSize=Enum.AutomaticSize.Y
content.ScrollBarThickness=6; content.BackgroundColor3=Theme.sheet; content.BorderSizePixel=0; content.ZIndex=21
content.Active = true; content.ClipsDescendants = true
local contentList = Instance.new("UIListLayout", content); contentList.Padding=UDim.new(0,12); contentList.HorizontalAlignment=Enum.HorizontalAlignment.Center

-------------------- Secciones --------------------
local Sections, Current = {}, nil
local function showSection(name) for k,f in pairs(Sections) do f.Visible=(k==name) end Current=name end
local function makeSection(name) local f=Instance.new("Frame",content); f.Size=UDim2.new(1,-8,0,0); f.BackgroundTransparency=1; f.AutomaticSize=Enum.AutomaticSize.Y; f.ZIndex=21; Sections[name]=f; return f end

local navOrder={"Main","Teleport","Visuals","Info"}
local navButtons={}
for _,n in ipairs(navOrder) do navButtons[n]=makeNavBtn(n) end
for k,btn in pairs(navButtons) do btn.MouseButton1Click:Connect(function() showSection(k) end) end

-------------------- Features (hooks) --------------------
local function applyWalk()
    local char=LP.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = S.walkspeed and S.speed or 16 end
end

-- Fly
local flyGyro, flyVel, flyConn; _G.__Ascend=false; _G.__Descend=false
local function startFly()
    local char=LP.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
    flyGyro=Instance.new("BodyGyro",root); flyGyro.P=9e4; flyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9)
    flyVel=Instance.new("BodyVelocity",root); flyVel.MaxForce=Vector3.new(9e9,9e9,9e9); flyVel.P=9e4
    flyConn=RunService.RenderStepped:Connect(function()
        local hum=char:FindFirstChildOfClass("Humanoid"); local dir=Vector3.new()
        if hum then local mv=hum.MoveDirection; if mv.Magnitude>0 then dir+=mv end end
        if _G.__Ascend then dir+=Vector3.new(0,1,0) end; if _G.__Descend then dir+=Vector3.new(0,-1,0) end
        if dir.Magnitude>0 then dir=dir.Unit end; flyVel.Velocity=dir*50; flyGyro.CFrame=Workspace.CurrentCamera.CFrame
    end)
end
local function stopFly() if flyConn then flyConn:Disconnect() flyConn=nil end if flyGyro then flyGyro:Destroy() flyGyro=nil end if flyVel then flyVel:Destroy() flyVel=nil end end

-- GodMode
local godConn, originalMaxHealth
local function applyGod()
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    originalMaxHealth=originalMaxHealth or hum.MaxHealth; hum.MaxHealth=math.huge; hum.Health=hum.MaxHealth
    if godConn then godConn:Disconnect() end
    godConn=hum.HealthChanged:Connect(function() if hum.Health<hum.MaxHealth then hum.Health=hum.MaxHealth end end)
end
local function removeGod() local char=LP.Character; if not char then return end local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end if godConn then godConn:Disconnect() godConn=nil end if originalMaxHealth then hum.MaxHealth=originalMaxHealth end hum.Health=hum.MaxHealth end

-- Noclip
local noclipConn, savedCollide={}
local function setCharCollision(char, collide) for _,o in ipairs(char:GetDescendants()) do if o:IsA("BasePart") then savedCollide[o]=savedCollide[o]==nil and o.CanCollide or savedCollide[o]; o.CanCollide=collide end end end
local function enableNoclip() local char=LP.Character; if not char then return end savedCollide={}; setCharCollision(char,false); noclipConn=RunService.Stepped:Connect(function() local c=LP.Character; if not c then return end for _,o in ipairs(c:GetDescendants()) do if o:IsA("BasePart") then o.CanCollide=false end end end) end
local function disableNoclip() if noclipConn then noclipConn:Disconnect() noclipConn=nil end for p,prev in pairs(savedCollide) do if p and p.Parent then p.CanCollide=prev end end savedCollide={} end

-- ESP
local ESPFolders, ESPConns = {}, {}
local pAddConn, pRemConn
local function clearESP(plr) if ESPConns[plr] then ESPConns[plr]:Disconnect() ESPConns[plr]=nil end if ESPFolders[plr] then ESPFolders[plr]:Destroy() ESPFolders[plr]=nil end end
local function createESP(plr)
    if not S.esp or plr==LP or ESPFolders[plr] then return end
    local folder=Instance.new("Folder",ESPGui); folder.Name="ESP_"..plr.Name; ESPFolders[plr]=folder
    ESPConns[plr]=RunService.Heartbeat:Connect(function()
        if not S.esp then return end
        local char=plr.Character; if not char or not char.Parent then for _,c in ipairs(folder:GetChildren()) do c:Destroy() end return end
        local root=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health<=0 then for _,c in ipairs(folder:GetChildren()) do c:Destroy() end return end
        pcall(function() hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end)
        for _,c in ipairs(folder:GetChildren()) do c:Destroy() end
        local hl=Instance.new("Highlight",folder); hl.Adornee=char; hl.FillColor=Color3.fromRGB(255,0,0); hl.FillTransparency=0.85; hl.OutlineColor=Color3.fromRGB(255,0,0); hl.OutlineTransparency=0
        local bb=Instance.new("BillboardGui",folder); bb.Adornee=root; bb.Size=UDim2.new(0,260,0,54); bb.AlwaysOnTop=true; bb.MaxDistance=2000; bb.StudsOffset=Vector3.new(0,4,0)
        local lbl=Instance.new("TextLabel",bb); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.GothamBlack; lbl.TextColor3=Theme.text; lbl.TextStrokeTransparency=0; lbl.TextStrokeColor3=Color3.fromRGB(10,10,10); lbl.TextSize=S.espSize; lbl.Text=("%s [%d HP]"):format(plr.Name, math.floor(hum.Health))
        local distL=Instance.new("TextLabel",bb); distL.AnchorPoint=Vector2.new(0.5,0); distL.Position=UDim2.new(0.5,0,1,-16); distL.Size=UDim2.new(1,0,0,16); distL.BackgroundTransparency=1; distL.Font=Enum.Font.GothamBold; distL.TextSize=math.clamp(S.espSize-6,10,30); distL.TextColor3=Color3.fromRGB(255,230,150)
        local myC=LP.Character; local myR=myC and myC:FindFirstChild("HumanoidRootPart"); if myR then distL.Text=tostring(math.floor((root.Position-myR.Position).Magnitude)).." studs" end
    end)
end
local function toggleESP(on)
    S.esp=on
    if on then
        for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
        if not pAddConn then pAddConn=Players.PlayerAdded:Connect(function(p) task.delay(1,function() createESP(p) end) end) end
        if not pRemConn then pRemConn=Players.PlayerRemoving:Connect(function(p) clearESP(p) end) end
    else
        for p,_ in pairs(ESPFolders) do clearESP(p) end
        if pAddConn then pAddConn:Disconnect() pAddConn=nil end
        if pRemConn then pRemConn:Disconnect() pRemConn=nil end
    end
end

-------------------- Sección: Main --------------------
local secMain = makeSection("Main")
do
    local c1=makeCard(secMain,"ESP","Highlight + nombre visible a través de paredes")
    c1.Position=UDim2.new(0,12,0,0)
    local sw,_=makeSwitch(c1,false,function(v) toggleESP(v) end); sw.AnchorPoint=Vector2.new(1,0.5); sw.Position=UDim2.new(1,-14,0.5,0); sw.Parent=c1

    local c2=makeCard(secMain,"GodMode","Mantiene la salud al máximo")
    local sw2,_=makeSwitch(c2,false,function(v) S.god=v; if v then applyGod() else removeGod() end end); sw2.AnchorPoint=Vector2.new(1,0.5); sw2.Position=UDim2.new(1,-14,0.5,0); sw2.Parent=c2

    local c3=makeCard(secMain,"Noclip","Atraviesa paredes/estructuras")
    local sw3,_=makeSwitch(c3,false,function(v) S.noclip=v; if v then enableNoclip() else disableNoclip() end end); sw3.AnchorPoint=Vector2.new(1,0.5); sw3.Position=UDim2.new(1,-14,0.5,0); sw3.Parent=c3

    local c4=makeCard(secMain,"Fly","W/A/S/D + botones ↑/↓")
    local sw4,_=makeSwitch(c4,false,function(v) S.fly=v; if v then startFly() else stopFly() end _G.__Ascend=false; _G.__Descend=false; ascendBtn.Visible=v and not sheet.Visible; descendBtn.Visible=v and not sheet.Visible end); sw4.AnchorPoint=Vector2.new(1,0.5); sw4.Position=UDim2.new(1,-14,0.5,0); sw4.Parent=c4

    local c5=makeCard(secMain,"WalkSpeed","Velocidad del personaje")
    local sw5,_=makeSwitch(c5,false,function(v) S.walkspeed=v; applyWalk() end); sw5.AnchorPoint=Vector2.new(1,0.5); sw5.Position=UDim2.new(1,-14,0.5,0); sw5.Parent=c5
    local slider=makeSlider(c5,400,10,S.speed,function(v) S.speed=v; applyWalk() end); slider.Position=UDim2.new(0,16,0,40); slider.Parent=c5
end

-------------------- Sección: Teleport --------------------
local secTP = makeSection("Teleport")
do
    local listCard=makeCard(secTP,"Jugadores","Toca un nombre y pulsa TP"); listCard.Size=UDim2.new(1,-24,0,240)
    local list=Instance.new("ScrollingFrame",listCard); list.Position=UDim2.new(0,16,0,42); list.Size=UDim2.new(1,-32,1,-92)
    list.BackgroundColor3=Theme.bg; list.BorderSizePixel=0; round(list,10); stroke(list,1)
    list.CanvasSize=UDim2.new(0,0,0,0); list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.ScrollBarThickness=4; list.ZIndex=21
    list.Active = true; list.ClipsDescendants = true
    local ll=Instance.new("UIListLayout",list); ll.Padding=UDim.new(0,6)

    local selected
    local function refresh()
        for _,c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then
                local b=Instance.new("TextButton",list); b.Size=UDim2.new(1,-8,0,34); b.Text=p.Name; b.Font=Enum.Font.Gotham; b.TextSize=16; b.TextColor3=Theme.text; b.BackgroundColor3=Theme.card; b.BorderSizePixel=0; round(b,8); stroke(b,1); b.ZIndex=22
                b.MouseButton1Click:Connect(function() selected=p; for _,o in ipairs(list:GetChildren()) do if o:IsA("TextButton") then o.BackgroundColor3=Theme.card end end; b.BackgroundColor3=Theme.accentDim end)
            end
        end
    end
    local row=Instance.new("Frame",listCard); row.BackgroundTransparency=1; row.Size=UDim2.new(1,-32,0,40); row.Position=UDim2.new(0,16,1,-46); row.ZIndex=21
    local refreshBtn=Instance.new("TextButton",row); refreshBtn.Size=UDim2.new(0.48,0,1,0); refreshBtn.Text="Actualizar"; refreshBtn.Font=Enum.Font.GothamBold; refreshBtn.TextSize=16; refreshBtn.TextColor3=Theme.text; refreshBtn.BackgroundColor3=Theme.accent; refreshBtn.BorderSizePixel=0; round(refreshBtn,10); refreshBtn.ZIndex=22
    local tpBtn=Instance.new("TextButton",row); tpBtn.AnchorPoint=Vector2.new(1,0); tpBtn.Position=UDim2.new(1,0,0,0); tpBtn.Size=UDim2.new(0.48,0,1,0); tpBtn.Text="TP"; tpBtn.Font=Enum.Font.GothamBold; tpBtn.TextSize=16; tpBtn.TextColor3=Theme.text; tpBtn.BackgroundColor3=Theme.accentDim; tpBtn.BorderSizePixel=0; round(tpBtn,10); tpBtn.ZIndex=22
    refreshBtn.MouseButton1Click:Connect(refresh)
    tpBtn.MouseButton1Click:Connect(function() if not selected then return end local me=LP.Character; local tar=selected.Character; if me and tar then local myR=me:FindFirstChild("HumanoidRootPart"); local tR=tar:FindFirstChild("HumanoidRootPart"); if myR and tR then myR.CFrame=tR.CFrame*CFrame.new(0,3,0) end end end)
    refresh()
end

-------------------- Sección: Visuals --------------------
local secVis = makeSection("Visuals")
do
    local c=makeCard(secVis,"Tamaño del nombre del ESP","Ajusta la fuente (10–50)")
    local slider=makeSlider(c,50,2,S.espSize,function(v) S.espSize=v end); slider.Position=UDim2.new(0,16,0,40); slider.Parent=c
end

-------------------- Sección: Info --------------------
local secInfo = makeSection("Info")
do local c=makeCard(secInfo,"Tema","Rojo/Negro. Controles touch grandes."); c.Size=UDim2.new(1,-24,0,74) end

-------------------- Sección inicial + tabs --------------------
local function setActiveTab(name) for n,btn in pairs(navButtons) do btn.BackgroundColor3 = (n==name) and Theme.accentDim or Theme.card end end
showSection("Main"); setActiveTab("Main")
for n,btn in pairs(navButtons) do btn.MouseButton1Click:Connect(function() setActiveTab(n) end) end

-------------------- Botones Fly ↑/↓ --------------------
ascendBtn = Instance.new("TextButton", Root)
ascendBtn.Size=UDim2.new(0,48,0,48); ascendBtn.Position=UDim2.new(0.88,0,0.32,0)
ascendBtn.Text="↑"; ascendBtn.TextSize=22; ascendBtn.Font=Enum.Font.GothamBold; ascendBtn.TextColor3=Theme.text
ascendBtn.BackgroundColor3=Theme.accent; ascendBtn.BorderSizePixel=0; round(ascendBtn,12); stroke(ascendBtn,1); ascendBtn.Visible=false; ascendBtn.ZIndex=25
ascendBtn.MouseButton1Down:Connect(function() _G.__Ascend=true end); ascendBtn.MouseButton1Up:Connect(function() _G.__Ascend=false end)

descendBtn = Instance.new("TextButton", Root)
descendBtn.Size=UDim2.new(0,48,0,48); descendBtn.Position=UDim2.new(0.88,0,0.44,0)
descendBtn.Text="↓"; descendBtn.TextSize=22; descendBtn.Font=Enum.Font.GothamBold; descendBtn.TextColor3=Theme.text
descendBtn.BackgroundColor3=Theme.accentDim; descendBtn.BorderSizePixel=0; round(descendBtn,12); stroke(descendBtn,1); descendBtn.Visible=false; descendBtn.ZIndex=25
descendBtn.MouseButton1Down:Connect(function() _G.__Descend=true end); descendBtn.MouseButton1Up:Connect(function() _G.__Descend=false end)

-------------------- Abrir / Cerrar panel (alto) --------------------
local function openSheet()
    sheet.Visible=true; dim.Visible=true
    openBtn.Visible=false
    ascendBtn.Visible = S.fly and false
    descendBtn.Visible = S.fly and false
    TweenService:Create(dim, TweenInfo.new(0.15), {BackgroundTransparency = 0.35}):Play()
    TweenService:Create(sheet, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0,0, SHEET_TOP, 0)}):Play()
end
local function closeSheet()
    TweenService:Create(dim, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
    TweenService:Create(sheet, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(0,0, 1, 0)}):Play()
    task.delay(0.20, function()
        sheet.Visible=false; dim.Visible=false
        openBtn.Visible=true
        ascendBtn.Visible = S.fly
        descendBtn.Visible = S.fly
    end)
end
openBtn.MouseButton1Click:Connect(openSheet)
closeBtn.MouseButton1Click:Connect(closeSheet)
dim.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then closeSheet() end end)

-------------------- Respawn reaplicar --------------------
LP.CharacterAdded:Connect(function()
    task.wait(0.8)
    if S.walkspeed then applyWalk() end
    if S.god       then applyGod() end
    if S.noclip    then enableNoclip() end
    if S.esp       then toggleESP(true) end
    if S.fly       then startFly() ascendBtn.Visible=true; descendBtn.Visible=true end
end)

print("✅ Admin Panel Mobile POSICIÓN ALTA listo. Ajusta SHEET_TOP/SHEET_HEIGHT si quieres más arriba/abajo.")
