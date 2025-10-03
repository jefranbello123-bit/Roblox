-- Delta Executor - Menú Moderno (iPhone) con Fly + Botón de Bajar
-- Fondo transparente + bordes rainbow
-- Autor: GPT Personalizado

if game.CoreGui:FindFirstChild("DeltaMenu") then
    game.CoreGui.DeltaMenu:Destroy()
end

local TweenService = game:GetService("TweenService")

local Library = Instance.new("ScreenGui")
Library.Name = "DeltaMenu"
Library.Parent = game.CoreGui

-- Marco principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 420)
MainFrame.Position = UDim2.new(0.5, -180, 0.4, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.3 -- semi-transparente
MainFrame.BorderSizePixel = 0
MainFrame.Parent = Library
MainFrame.Active = true
MainFrame.Draggable = true

-- Borde Rainbow
local RainbowBorder = Instance.new("UIStroke")
RainbowBorder.Thickness = 3
RainbowBorder.Parent = MainFrame

-- Animación de colores rainbow
spawn(function()
    while wait() do
        for i = 0, 1, 0.01 do
            RainbowBorder.Color = Color3.fromHSV(i, 1, 1)
            wait(0.02)
        end
    end
end)

-- Título
local Title = Instance.new("TextLabel")
Title.Text = "Delta Menu"
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 26
Title.Parent = MainFrame

-- Botón cerrar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 45, 0, 45)
CloseBtn.Position = UDim2.new(1, -50, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 22
CloseBtn.Parent = MainFrame

-- Botón flotante para abrir menú
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Text = "☰"
FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
FloatingBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.TextSize = 26
FloatingBtn.Parent = Library
FloatingBtn.Active = true
FloatingBtn.Draggable = true
FloatingBtn.Visible = false

-- Función crear botón
local function CreateButton(name, yPos, callback)
    local Btn = Instance.new("TextButton")
    Btn.Text = name.." [OFF]"
    Btn.Size = UDim2.new(0.9, 0, 0, 50)
    Btn.Position = UDim2.new(0.05, 0, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.BackgroundTransparency = 0.2
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 20
    Btn.Parent = MainFrame
    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = name.." ["..(state and "ON" or "OFF").."]"
        callback(state)
    end)
    return Btn
end

-- Estados
local flyEnabled = false
local flyDownBtn = nil
local florEnabled = false

-- Velocidad
CreateButton("Velocidad x3", 60, function(state)
    local plr = game.Players.LocalPlayer
    local hum = (plr.Character or plr.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
    hum.WalkSpeed = state and 48 or 16
end)

-- Super Salto
CreateButton("Super Salto", 120, function(state)
    local plr = game.Players.LocalPlayer
    local hum = (plr.Character or plr.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = state and 120 or 50
    end
end)

-- Fly con botón bajar
CreateButton("Fly", 180, function(state)
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    if state then
        flyEnabled = true
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0,0,0)
        bv.MaxForce = Vector3.new(4000,4000,4000)
        bv.Parent = root

        -- Botón extra para bajar
        flyDownBtn = Instance.new("TextButton")
        flyDownBtn.Text = "⬇"
        flyDownBtn.Size = UDim2.new(0, 60, 0, 60)
        flyDownBtn.Position = UDim2.new(0.8, 0, 0.8, 0)
        flyDownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        flyDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        flyDownBtn.Font = Enum.Font.GothamBold
        flyDownBtn.TextSize = 28
        flyDownBtn.Parent = Library
        flyDownBtn.Active = true
        flyDownBtn.Draggable = true

        local downPressed = false
        flyDownBtn.MouseButton1Down:Connect(function() downPressed = true end)
        flyDownBtn.MouseButton1Up:Connect(function() downPressed = false end)

        game:GetService("RunService").RenderStepped:Connect(function()
            if flyEnabled and bv.Parent then
                local move = hum.MoveDirection * 60
                local y = 0
                if hum.Jump then y = 60 end
                if downPressed then y = -60 end
                bv.Velocity = move + Vector3.new(0, y, 0)
            end
        end)
    else
        flyEnabled = false
        if root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
        if flyDownBtn then flyDownBtn:Destroy() flyDownBtn = nil end
    end
end)

-- ESP
CreateButton("ESP Jugadores", 240, function(state)
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character then
            if state then
                if not v.Character:FindFirstChild("ESPHighlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.Parent = v.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            else
                if v.Character:FindFirstChild("ESPHighlight") then
                    v.Character.ESPHighlight:Destroy()
                end
            end
        end
    end
end)

-- Flor optimizada
CreateButton("Flor", 300, function(state)
    florEnabled = state
    local plr = game.Players.LocalPlayer
    local root = plr.Character:WaitForChild("HumanoidRootPart")
    spawn(function()
        while florEnabled do
            local part = Instance.new("Part")
            part.Size = Vector3.new(7, 1, 7)
            part.Anchored = true
            part.CanCollide = true
            part.Color = Color3.fromRGB(0, 200, 255)
            part.CFrame = CFrame.new(root.Position - Vector3.new(0, 3, 0))
            part.Parent = workspace
            game:GetService("Debris"):AddItem(part, 1.5)
            wait(0.12)
        end
    end)
end)

-- Abrir/cerrar menú
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingBtn.Visible = true
end)
FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatingBtn.Visible = false
end)

print("Delta Menu Moderno cargado.")
