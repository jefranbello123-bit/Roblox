-- Simple Fly Toggle Script para móviles con menú movible y botón circular
-- Este script amplía el script de vuelo original añadiendo un menú compacto.
-- ⚠️ El uso de scripts de vuelo puede violar los Términos de Servicio de Roblox.
-- Úsalo bajo tu responsabilidad.

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local LP                 = Players.LocalPlayer

-- Esperar a que PlayerGui esté disponible
local playerGui = LP:WaitForChild("PlayerGui")

-- Crear contenedor de GUI
local flyGui = Instance.new("ScreenGui")
flyGui.Name = "SimpleFlyGUI"
flyGui.ResetOnSpawn = false
flyGui.IgnoreGuiInset = true
flyGui.Parent = playerGui

-- Contenedor principal que se puede arrastrar
local dragFrame = Instance.new("Frame")
dragFrame.Name = "DragFrame"
dragFrame.Size = UDim2.new(0, 60, 0, 60)
dragFrame.Position = UDim2.new(0.04, 0, 0.8, 0)
dragFrame.BackgroundTransparency = 1
dragFrame.Active = true
dragFrame.Parent = flyGui

-- Botón circular para abrir el menú
local circleBtn = Instance.new("TextButton")
circleBtn.Name = "CircleButton"
circleBtn.Size = UDim2.new(1, 0, 1, 0)
circleBtn.BackgroundColor3 = Color3.fromRGB(220, 45, 45)
circleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
circleBtn.Font = Enum.Font.GothamBold
circleBtn.TextSize = 28
circleBtn.Text = "☰"
circleBtn.BorderSizePixel = 0
circleBtn.Parent = dragFrame

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(0.5, 0)
circleCorner.Parent = circleBtn

-- Menú emergente (inicialmente oculto)
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 180, 0, 200)
menuFrame.Position = UDim2.new(0, -60, 0, -140)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.Visible = false
menuFrame.Parent = dragFrame

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 8)
menuCorner.Parent = menuFrame

-- Título del menú
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 0, 24)
titleLabel.Position = UDim2.new(0, 20, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.Text = "Menú"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = menuFrame

-- Botón para cerrar el menú (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -32, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 45, 45)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Text = "×"
closeBtn.BorderSizePixel = 0
closeBtn.Parent = menuFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0.5, 0)
closeCorner.Parent = closeBtn

-- Botón de activación/desactivación del modo Fly
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleFly"
toggleBtn.Size = UDim2.new(0, 120, 0, 40)
toggleBtn.Position = UDim2.new(0.5, -60, 0, 50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 45, 45)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Text = "Fly OFF"
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = true
toggleBtn.Parent = menuFrame

-- Botón de ascenso
local ascendBtn = Instance.new("TextButton")
ascendBtn.Name = "AscendButton"
ascendBtn.Size = UDim2.new(0, 50, 0, 50)
ascendBtn.Position = UDim2.new(0.5, -60, 0, 100)
ascendBtn.BackgroundColor3 = Color3.fromRGB(220, 45, 45)
ascendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ascendBtn.Font = Enum.Font.GothamBold
ascendBtn.TextSize = 22
ascendBtn.Text = "↑"
ascendBtn.BorderSizePixel = 0
ascendBtn.Visible = false
ascendBtn.Parent = menuFrame

-- Botón de descenso
local descendBtn = Instance.new("TextButton")
descendBtn.Name = "DescendButton"
descendBtn.Size = UDim2.new(0, 50, 0, 50)
descendBtn.Position = UDim2.new(0.5, 10, 0, 100)
descendBtn.BackgroundColor3 = Color3.fromRGB(160, 25, 25)
descendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
descendBtn.Font = Enum.Font.GothamBold
descendBtn.TextSize = 22
descendBtn.Text = "↓"
descendBtn.BorderSizePixel = 0
descendBtn.Visible = false
descendBtn.Parent = menuFrame

-- Variables internas de vuelo
local flying   = false
local bodyGyro, bodyVel, flyConn
local ascend = false
local descend = false

-- Funciones de vuelo
local function startFly()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    bodyGyro = Instance.new("BodyGyro", root)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyVel = Instance.new("BodyVelocity", root)
    bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVel.P = 9e4

    flyConn = RunService.RenderStepped:Connect(function()
        local dir = Vector3.new()
        local char2 = LP.Character
        if char2 then
            local hum = char2:FindFirstChildOfClass("Humanoid")
            if hum then
                local move = hum.MoveDirection
                if move.Magnitude > 0 then
                    dir = dir + move
                end
            end
        end
        if ascend then dir = dir + Vector3.new(0, 1, 0) end
        if descend then dir = dir + Vector3.new(0, -1, 0) end
        if dir.Magnitude > 0 then dir = dir.Unit end
        bodyVel.Velocity = dir * 50
        if workspace.CurrentCamera then
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        end
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if bodyVel then bodyVel:Destroy(); bodyVel = nil end
end

-- Eventos de ascenso/descenso
ascendBtn.MouseButton1Down:Connect(function() ascend = true end)
ascendBtn.MouseButton1Up:Connect(function() ascend = false end)
descendBtn.MouseButton1Down:Connect(function() descend = true end)
descendBtn.MouseButton1Up:Connect(function() descend = false end)

-- Activar/desactivar el vuelo
toggleBtn.MouseButton1Click:Connect(function()
    flying = not flying
    toggleBtn.Text = flying and "Fly ON" or "Fly OFF"
    ascendBtn.Visible  = flying
    descendBtn.Visible = flying
    if flying then
        startFly()
    else
        ascend  = false
        descend = false
        stopFly()
    end
end)

-- Abrir el menú
circleBtn.MouseButton1Click:Connect(function()
    circleBtn.Visible = false
    menuFrame.Visible = true
end)

-- Cerrar el menú
closeBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    circleBtn.Visible = true
end)

-- Lógica de arrastre (mouse o toque):contentReference[oaicite:1]{index=1}
local dragging   = false
local dragStartPos
local uiStartPos

local function inputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging     = true
        dragStartPos = input.Position
        uiStartPos   = dragFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

local function inputChanged(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        local newPos = UDim2.new(uiStartPos.X.Scale, uiStartPos.X.Offset + delta.X,
                                 uiStartPos.Y.Scale, uiStartPos.Y.Offset + delta.Y)
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
        local guiSize  = dragFrame.AbsoluteSize
        local maxX     = viewport.X - guiSize.X
        local maxY     = viewport.Y - guiSize.Y
        local clampedX = math.clamp(newPos.X.Offset, 0, maxX)
        local clampedY = math.clamp(newPos.Y.Offset, 0, maxY)
        dragFrame.Position = UDim2.new(0, clampedX, 0, clampedY)
    end
end

dragFrame.InputBegan:Connect(inputBegan)
dragFrame.InputChanged:Connect(inputChanged)

print("✅ Simple Fly script con menú y arrastre cargado.")
