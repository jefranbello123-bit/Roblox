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
-local SHEET_TOP    = 0.10   -- 0.10 = 10% desde arriba (más pequeño = más alto)
+local SHEET_TOP    = 0.06   -- 0.06 = 6% desde arriba (más pequeño = más alto)
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
diff --git a/mobile_fly_script.lua b/mobile_fly_script.lua
index 0b388cfbbf25028853dcf9409c63e34b53ac5291..d249abe51d61eeab12b583d00d0a1e2ca50f917c 100644
--- a/mobile_fly_script.lua
+++ b/mobile_fly_script.lua
@@ -260,50 +260,51 @@ end
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
+local ascendBtn, descendBtn
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
 
diff --git a/mobile_fly_script.lua b/mobile_fly_script.lua
index 0b388cfbbf25028853dcf9409c63e34b53ac5291..d249abe51d61eeab12b583d00d0a1e2ca50f917c 100644
--- a/mobile_fly_script.lua
+++ b/mobile_fly_script.lua
@@ -339,51 +340,57 @@ local function toggleESP(on)
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
-    local sw4,_=makeSwitch(c4,false,function(v) S.fly=v; if v then startFly() else stopFly() end _G.__Ascend=false; _G.__Descend=false; ascendBtn.Visible=v and not sheet.Visible; descendBtn.Visible=v and not sheet.Visible end); sw4.AnchorPoint=Vector2.new(1,0.5); sw4.Position=UDim2.new(1,-14,0.5,0); sw4.Parent=c4
+    local sw4,_=makeSwitch(c4,false,function(v)
+        S.fly=v
+        if v then startFly() else stopFly() end
+        _G.__Ascend=false; _G.__Descend=false
+        if ascendBtn then ascendBtn.Visible=v and not sheet.Visible end
+        if descendBtn then descendBtn.Visible=v and not sheet.Visible end
+    end); sw4.AnchorPoint=Vector2.new(1,0.5); sw4.Position=UDim2.new(1,-14,0.5,0); sw4.Parent=c4
 
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
diff --git a/mobile_fly_script.lua b/mobile_fly_script.lua
index 0b388cfbbf25028853dcf9409c63e34b53ac5291..d249abe51d61eeab12b583d00d0a1e2ca50f917c 100644
--- a/mobile_fly_script.lua
+++ b/mobile_fly_script.lua
@@ -407,57 +414,57 @@ end
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
-    ascendBtn.Visible = S.fly and false
-    descendBtn.Visible = S.fly and false
+    if ascendBtn then ascendBtn.Visible = S.fly and false end
+    if descendBtn then descendBtn.Visible = S.fly and false end
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
-        ascendBtn.Visible = S.fly
-        descendBtn.Visible = S.fly
+        if ascendBtn then ascendBtn.Visible = S.fly end
+        if descendBtn then descendBtn.Visible = S.fly end
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
-    if S.fly       then startFly() ascendBtn.Visible=true; descendBtn.Visible=true end
+    if S.fly       then startFly(); if ascendBtn then ascendBtn.Visible=true end; if descendBtn then descendBtn.Visible=true end end
 end)
 
 print("✅ Admin Panel Mobile POSICIÓN ALTA listo. Ajusta SHEET_TOP/SHEET_HEIGHT si quieres más arriba/abajo.")
