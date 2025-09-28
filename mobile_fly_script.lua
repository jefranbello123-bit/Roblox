-- Simple Fly Toggle Script para móviles con menú movible y botón circular
-- Esta versión corrige la posición inicial y mejora la detección de arrastre.

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP               = Players.LocalPlayer

-- Espera a que PlayerGui esté disponible
local playerGui = LP:WaitForChild("PlayerGui")

-- Crear contenedor de GUI
local flyGui = Instance.new("ScreenGui")
flyGui.Name = "SimpleFlyGUI"
flyGui.ResetOnSpawn = false
flyGui.IgnoreGuiInset = true
flyGui.Parent = playerGui

-- Contenedor principal (botón circular)
local dragFrame = Instance.new("Frame")
dragFrame.Name = "DragFrame"
dragFrame.Size = UDim2.new(0, 60, 0, 60)
dragFrame.Position = UDim2.new(0.5, -30, 0.5, -30)  -- centrado
dragFrame.BackgroundTransparency = 1
dragFrame.Active = true
dragFrame.Parent = flyGui

-- Botón circular de apertura
local circleBtn = Instance.new("TextButton")
circleBtn.Name = "CircleButton"
circleBtn.Size = UDim2.new(1, 0, 1, 0)
circleBtn.BackgroundColor3 = Color3.fromRGB(220, 120, 30)
circleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
circleBtn.Font = Enum.Font.GothamBold
circleBtn.TextSize = 28
circleBtn.Text = "☰"
circleBtn.BorderSizePixel = 0
circleBtn.Parent = dragFrame

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(0.5, 0)
circleCorner.Parent = circleBtn

-- Menú emergente, parentado al ScreenGui
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 180, 0, 200)
menuFrame.Position = UDim2.new(0.5, -90, 0.5, -100)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.Parent = flyGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 8)
menuCorner.Parent = menuFrame

-- Encabezado y botones dentro del menú
-- (Fly ON/OFF, ascender y descender) …

-- Código de vuelo y conexiones de botones …
-- (idéntico al script previo)

-- Abrir y cerrar el menú
circleBtn.MouseButton1Click:Connect(function()
    dragFrame.Visible = false
    menuFrame.Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    dragFrame.Visible = true
end)

-- Lógica de arrastre para botón y menú
local dragging = false
local dragStart
local startPos

local function beginDrag(input, gui)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = gui.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end

local function updateDrag(input, gui)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                 startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
        local guiSize = gui.AbsoluteSize
        local maxX = viewport.X - guiSize.X
        local maxY = viewport.Y - guiSize.Y
        local clampedX = math.clamp(newPos.X.Offset, 0, maxX)
        local clampedY = math.clamp(newPos.Y.Offset, 0, maxY)
        gui.Position = UDim2.new(0, clampedX, 0, clampedY)
    end
end

local function makeDraggable(background)
    background.InputBegan:Connect(function(input)
        beginDrag(input, background)
    end)
    background.InputChanged:Connect(function(input)
        updateDrag(input, background)
    end)
end

makeDraggable(dragFrame)  -- arrastrar el círculo
makeDraggable(menuFrame)  -- arrastrar el fondo del menú

print("✅ Script de vuelo con menú corregido cargado.")
