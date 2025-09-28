--[[
    Mobile Admin Panel — Red & Black theme
    Requirements:
        * Single LocalScript under StarterGui creating UI under PlayerGui.
        * Sidebar tabs (Main, Teleport, Visuals, Info) with cards.
        * Permission gated via BoolValue "CanAdmin" under the player.
        * Optional remotes: TeleportTo (RemoteEvent), SetGodMode (RemoteEvent).
        * Client-only features (walk speed, fly, noclip) apply only to LocalPlayer.
        * Visual aids only for developer-owned NPCs inside Workspace.NPCs.
        * Touch-friendly controls (switches, sliders, big buttons) with Gotham fonts.
]]

-------------------- Services --------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-------------------- Constants --------------------
local PANEL_TOP = 0.04
local PANEL_HEIGHT = 0.88
local SIDEBAR_WIDTH_SCALE = 0.28
local PANEL_ZINDEX = 25

local Theme = {
    background = Color3.fromRGB(10, 10, 14),
    panel = Color3.fromRGB(16, 16, 20),
    sidebar = Color3.fromRGB(18, 18, 24),
    card = Color3.fromRGB(26, 26, 34),
    cardStroke = Color3.fromRGB(60, 60, 80),
    text = Color3.fromRGB(240, 240, 240),
    subtext = Color3.fromRGB(180, 180, 190),
    accent = Color3.fromRGB(220, 30, 30),
    accentDim = Color3.fromRGB(150, 20, 20),
    scrim = Color3.fromRGB(0, 0, 0),
    shadow = Color3.fromRGB(0, 0, 0)
}

local TAB_NAMES = {"Main", "Teleport", "Visuals", "Info"}

-------------------- State --------------------
local State = {
    activeTab = "Main",
    canAdmin = false,
    teleportPoints = {},
    toasts = {},
    fly = false,
    flyAscend = 0,
    flyForce = nil,
    flyAlign = nil,
    flyAttachment = nil,
    flyConnection = nil,
    noclip = false,
    noclipConnection = nil,
    walkspeedEnabled = false,
    walkspeedValue = 16,
    visualsEnabled = false,
    espEnabled = false,
    espFontSize = 22,
    espFolder = nil,
    espConnections = {},
    godModeEnabled = false,
    godRemoteAvailable = false,
    teleportRemoteAvailable = false,
    currentCharacter = nil,
    currentHumanoid = nil,
    reapplyConnection = nil,
    ascendButton = nil,
    descendButton = nil,
    flyButtonContainer = nil,
    uiMounted = false,
    switchSetters = {}
}

-------------------- Utility --------------------
local function getBoolValue(parent, name)
    local object = parent:FindFirstChild(name)
    if object and object:IsA("BoolValue") then
        return object.Value
    end
    return nil
end

local function hasPermission()
    if LocalPlayer and LocalPlayer.Parent then
        return State.canAdmin
    end
    return false
end

local function showToast(title, text)
    task.spawn(function()
        local ok, err = pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 2,
                Button1 = "OK"
            })
        end)
        if not ok then
            warn("Notification failed:", err)
        end
    end)
end

local function tween(instance, props, info)
    local tweenInfo = info or TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenObject = TweenService:Create(instance, tweenInfo, props)
    tweenObject:Play()
    return tweenObject
end

local function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = instance
end

local function addStroke(instance, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.cardStroke
    stroke.Thickness = thickness or 1
    stroke.Transparency = 0.3
    stroke.Parent = instance
end

local function addPadding(instance, left, top, right, bottom)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.Parent = instance
end

local function createLabel(parent, text, size, weight, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = weight or Enum.Font.GothamSemibold
    label.TextSize = size or 16
    label.TextColor3 = color or Theme.text
    label.Text = text or ""
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function makeSwitch(defaultOn, onChanged)
    local switch = Instance.new("Frame")
    switch.BackgroundColor3 = defaultOn and Theme.accent or Theme.cardStroke
    switch.BorderSizePixel = 0
    switch.Size = UDim2.new(0, 64, 0, 28)
    addCorner(switch, 14)
    addStroke(switch, 1)

    local knob = Instance.new("Frame")
    knob.Parent = switch
    knob.Size = UDim2.new(0, 24, 0, 24)
    knob.BackgroundColor3 = Theme.panel
    knob.BorderSizePixel = 0
    knob.Position = defaultOn and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2)
    addCorner(knob, 12)
    addStroke(knob, 1)

    local button = Instance.new("TextButton")
    button.Parent = switch
    button.BackgroundTransparency = 1
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Text = ""

    local value = defaultOn

    local function setValue(newValue, animated)
        value = newValue
        if animated then
            tween(knob, {Position = newValue and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2)}, TweenInfo.new(0.15))
            tween(switch, {BackgroundColor3 = newValue and Theme.accent or Theme.cardStroke}, TweenInfo.new(0.15))
        else
            knob.Position = newValue and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2)
            switch.BackgroundColor3 = newValue and Theme.accent or Theme.cardStroke
        end
        if onChanged then
            onChanged(value)
        end
    end

    button.MouseButton1Click:Connect(function()
        setValue(not value, true)
    end)

    return switch, setValue
end

local function isPlayerOwnedPlace()
    local ok, result = pcall(function()
        return game.CreatorType, game.CreatorId
    end)
    if not ok or not result then
        return false
    end
    local creatorType, creatorId = game.CreatorType, game.CreatorId
    if creatorType == Enum.CreatorType.User then
        return creatorId == LocalPlayer.UserId
    end
    return false
end

local function makeSlider(maxValue, step, defaultValue, onChanged)
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(1, 0, 0, 40)

    local bar = Instance.new("Frame")
    bar.Parent = holder
    bar.AnchorPoint = Vector2.new(0, 0.5)
    bar.Position = UDim2.new(0, 0, 0.5, 0)
    bar.Size = UDim2.new(1, -70, 0, 6)
    bar.BackgroundColor3 = Theme.cardStroke
    bar.BorderSizePixel = 0
    addCorner(bar, 3)

    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Theme.accent
    fill.BorderSizePixel = 0
    addCorner(fill, 3)

    local knob = Instance.new("Frame")
    knob.Parent = bar
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.BackgroundColor3 = Theme.panel
    knob.BorderSizePixel = 0
    addCorner(knob, 8)
    addStroke(knob, 1)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = holder
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextSize = 16
    valueLabel.TextColor3 = Theme.text
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.AnchorPoint = Vector2.new(1, 0.5)
    valueLabel.Position = UDim2.new(1, 0, 0.5, 0)
    valueLabel.Size = UDim2.new(0, 60, 1, 0)

    local value = defaultValue or 0
    local function updateVisual(animated)
        local fraction = math.clamp(value / maxValue, 0, 1)
        local newWidth = UDim2.new(fraction, 0, 1, 0)
        local knobPosition = UDim2.new(fraction, 0, 0.5, 0)
        valueLabel.Text = tostring(math.floor(value + 0.5))
        if animated then
            tween(fill, {Size = newWidth}, TweenInfo.new(0.1))
            tween(knob, {Position = knobPosition}, TweenInfo.new(0.1))
        else
            fill.Size = newWidth
            knob.Position = knobPosition
        end
    end

    updateVisual(false)

    local function setValue(newValue, animated)
        newValue = math.clamp(newValue, 0, maxValue)
        newValue = math.floor(newValue / step + 0.5) * step
        value = newValue
        updateVisual(animated)
        if onChanged then
            onChanged(value)
        end
    end

    local dragging = false

    local function positionToValue(x)
        local barSize = bar.AbsoluteSize.X
        if barSize <= 0 then
            return value
        end
        local relative = math.clamp((x - bar.AbsolutePosition.X) / barSize, 0, 1)
        return relative * maxValue
    end

    local function beginDrag()
        dragging = true
    end

    local function endDrag()
        dragging = false
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag()
        end
    end)

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local targetValue = positionToValue(input.Position.X)
            setValue(targetValue, true)
            beginDrag()
        end
    end)

    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local targetValue = positionToValue(input.Position.X)
            setValue(targetValue, false)
        end
    end)

    return holder, setValue
end

local function makeCard(title, subtitle)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Theme.card
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, -12, 0, subtitle and 140 or 120)
    card.AutomaticSize = Enum.AutomaticSize.Y
    addCorner(card, 16)
    addStroke(card, 1)
    addPadding(card, 16, 16, 16, 16)

    local layout = Instance.new("UIListLayout")
    layout.Parent = card
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    local titleLabel = createLabel(card, title or "Card Title", 20, Enum.Font.GothamBold)
    titleLabel.LayoutOrder = 1

    if subtitle then
        local subtitleLabel = createLabel(card, subtitle, 16, Enum.Font.Gotham, Theme.subtext)
        subtitleLabel.LayoutOrder = 2
    end

    return card
end

local function ensurePlayerGui()
    if not LocalPlayer then
        return nil
    end
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    return playerGui
end

local function cleanConnections(tableToClean)
    if not tableToClean then
        return
    end
    for key, connection in pairs(tableToClean) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
            tableToClean[key] = nil
        elseif typeof(connection) == "table" and connection.Disconnect then
            connection:Disconnect()
            tableToClean[key] = nil
        end
    end
end

-------------------- Remotes & Teleport Points --------------------
local Remotes = {}
local TeleportTargets = {}

local function detectRemotes()
    local remoteFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if remoteFolder then
        Remotes.teleport = remoteFolder:FindFirstChild("TeleportTo")
        Remotes.godMode = remoteFolder:FindFirstChild("SetGodMode")
    else
        Remotes.teleport = ReplicatedStorage:FindFirstChild("TeleportTo")
        Remotes.godMode = ReplicatedStorage:FindFirstChild("SetGodMode")
    end
    State.teleportRemoteAvailable = Remotes.teleport ~= nil
    State.godRemoteAvailable = Remotes.godMode ~= nil
    if not State.teleportRemoteAvailable then
        showToast("Admin Panel", "TeleportTo remote not found")
    end
    if not State.godRemoteAvailable then
        showToast("Admin Panel", "SetGodMode remote not found")
    end
end

local function loadTeleportPoints()
    table.clear(TeleportTargets)
    local folder = Workspace:FindFirstChild("TeleportPoints")
    if not folder then
        return
    end
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(TeleportTargets, child)
        end
    end
    table.sort(TeleportTargets, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)
end

-------------------- ESP Helpers --------------------
local ESPObjects = {}

local function clearESP()
    for model, data in pairs(ESPObjects) do
        if data.connections then
            for _, conn in ipairs(data.connections) do
                conn:Disconnect()
            end
        end
        if data.highlight then
            data.highlight:Destroy()
        end
        if data.billboard then
            data.billboard:Destroy()
        end
        ESPObjects[model] = nil
    end
end

local function isModelOwnedNPC(model)
    if not model or not model:IsA("Model") then
        return false
    end
    local parent = model.Parent
    while parent do
        if parent == Workspace then
            break
        end
        parent = parent.Parent
    end
    if not parent then
        return false
    end
    local npcsFolder = Workspace:FindFirstChild("NPCs")
    if not npcsFolder then
        return false
    end
    return model:IsDescendantOf(npcsFolder)
end

local function applyESPToModel(model)
    if not model:IsA("Model") then
        return
    end
    if ESPObjects[model] then
        return
    end

    local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "AdminPanelHighlight"
    highlight.FillColor = Theme.accent
    highlight.OutlineColor = Theme.accentDim
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AdminPanelESP"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 500
    billboard.Adornee = model
    billboard.Parent = primaryPart

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Theme.accent
    label.TextStrokeTransparency = 0.5
    label.Text = model.Name
    label.Parent = billboard

    local function updateFontSize()
        label.TextSize = State.espFontSize
    end

    updateFontSize()

    local connections = {}
    table.insert(connections, model.AncestryChanged:Connect(function(_, parent)
        if not parent or not model:IsDescendantOf(Workspace) then
            clearESP()
        end
    end))

    ESPObjects[model] = {
        highlight = highlight,
        billboard = billboard,
        label = label,
        connections = connections
    }
end

local function refreshESP()
    clearESP()
    if not State.visualsEnabled or not State.espEnabled then
        return
    end
    local folder = Workspace:FindFirstChild("NPCs")
    if not folder then
        return
    end
    for _, model in ipairs(folder:GetChildren()) do
        if isModelOwnedNPC(model) then
            applyESPToModel(model)
        end
    end
end

local function setEspSize(size)
    State.espFontSize = size
    for _, data in pairs(ESPObjects) do
        if data.label then
            data.label.TextSize = size
        end
    end
end

local function setVisualsEnabled(enabled)
    State.visualsEnabled = enabled
    if not enabled then
        clearESP()
    else
        refreshESP()
    end
end

local function setEspEnabled(enabled)
    State.espEnabled = enabled
    refreshESP()
end

-------------------- Noclip Tracking --------------------
local noclipOriginalCollide = {}

local function clearNoclipTracking()
    for part, _ in pairs(noclipOriginalCollide) do
        noclipOriginalCollide[part] = nil
    end
end

-------------------- UI Elements --------------------
local ScreenGui
local FloatingButton
local Scrim
local Panel
local Sidebar
local ContentFrame
local TabButtons = {}
local CardsByTab = {}

-------------------- UI Construction --------------------
local function createFloatingButton(parent)
    local button = Instance.new("ImageButton")
    button.Name = "AdminPanelMenuButton"
    button.Size = UDim2.new(0, 64, 0, 64)
    button.Position = UDim2.new(0, 12, 0.5, -32)
    button.BackgroundColor3 = Theme.accent
    button.BorderSizePixel = 0
    button.Image = "rbxassetid://0"
    addCorner(button, 32)
    addStroke(button, 1)

    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.Font = Enum.Font.GothamBold
    icon.Text = "Menu"
    icon.TextColor3 = Theme.text
    icon.TextSize = 18
    icon.Parent = button

    local dragging = false
    local dragOffset = Vector2.new()

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragOffset = button.AbsolutePosition - input.Position
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragOffset = button.AbsolutePosition - input.Position
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local newPosition = input.Position + dragOffset
            button.Position = UDim2.new(0, math.clamp(newPosition.X, 0, parent.AbsoluteSize.X - button.AbsoluteSize.X), 0, math.clamp(newPosition.Y, 0, parent.AbsoluteSize.Y - button.AbsoluteSize.Y))
        end
    end)

    return button
end

local function createScrim(parent)
    local scrim = Instance.new("TextButton")
    scrim.Name = "AdminPanelScrim"
    scrim.BackgroundColor3 = Theme.scrim
    scrim.BackgroundTransparency = 1
    scrim.BorderSizePixel = 0
    scrim.Size = UDim2.new(1, 0, 1, 0)
    scrim.Text = ""
    scrim.Visible = false
    scrim.ZIndex = PANEL_ZINDEX - 1
    scrim.AutoButtonColor = false
    scrim.Parent = parent
    return scrim
end

local function createPanel(parent)
    local panel = Instance.new("Frame")
    panel.Name = "AdminPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0)
    panel.Position = UDim2.new(0.5, 0, PANEL_TOP - 1, 0)
    panel.Size = UDim2.new(0.92, 0, PANEL_HEIGHT, 0)
    panel.BackgroundColor3 = Theme.panel
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.ZIndex = PANEL_ZINDEX
    addCorner(panel, 20)
    addStroke(panel, 1)
    addPadding(panel, 12, 12, 12, 12)
    panel.Parent = parent

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.2
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0.5, -15, 0.5, -15)
    shadow.ZIndex = PANEL_ZINDEX - 1
    shadow.Parent = panel

    local layout = Instance.new("UIListLayout")
    layout.Parent = panel
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)

    return panel
end

local function createSidebar(parent)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundColor3 = Theme.sidebar
    sidebar.BorderSizePixel = 0
    sidebar.LayoutOrder = 1
    sidebar.Size = UDim2.new(SIDEBAR_WIDTH_SCALE, 0, 1, -12)
    addCorner(sidebar, 18)
    addStroke(sidebar, 1)
    addPadding(sidebar, 12, 12, 12, 12)
    sidebar.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Parent = sidebar
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    return sidebar
end

local function createContent(parent)
    local holder = Instance.new("Frame")
    holder.Name = "ContentHolder"
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = 2
    holder.Size = UDim2.new(1 - SIDEBAR_WIDTH_SCALE, -12, 1, -12)
    holder.Parent = parent

    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = holder

    local layout = Instance.new("UIListLayout")
    layout.Parent = content
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)

    return holder, content
end

local function setActiveTab(tabName)
    if State.activeTab == tabName then
        return
    end
    State.activeTab = tabName
    for name, button in pairs(TabButtons) do
        if name == tabName then
            tween(button, {BackgroundColor3 = Theme.accent}, TweenInfo.new(0.15))
            button.Icon.TextColor3 = Theme.text
        else
            tween(button, {BackgroundColor3 = Theme.sidebar}, TweenInfo.new(0.15))
            button.Icon.TextColor3 = Theme.subtext
        end
    end
    for name, container in pairs(CardsByTab) do
        container.Visible = name == tabName
    end
end

local function createSidebarButton(sidebar, tabName)
    local button = Instance.new("TextButton")
    button.Name = tabName .. "Button"
    button.BackgroundColor3 = tabName == State.activeTab and Theme.accent or Theme.sidebar
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 48)
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = PANEL_ZINDEX
    addCorner(button, 14)
    addStroke(button, 1)
    button.Parent = sidebar

    local label = createLabel(button, tabName, 18, Enum.Font.GothamBold)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.TextColor3 = tabName == State.activeTab and Theme.text or Theme.subtext
    label.Name = "Icon"
    button.Icon = label

    button.MouseButton1Click:Connect(function()
        setActiveTab(tabName)
    end)

    TabButtons[tabName] = button
end

local function buildTabs(content)
    for _, tabName in ipairs(TAB_NAMES) do
        local container = Instance.new("Frame")
        container.Name = tabName .. "Tab"
        container.BackgroundTransparency = 1
        container.Size = UDim2.new(1, 0, 0, 0)
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.Visible = tabName == State.activeTab
        container.Parent = content

        local layout = Instance.new("UIListLayout")
        layout.Parent = container
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 12)

        CardsByTab[tabName] = container
    end
end

local function buildPanel()
    local playerGui = ensurePlayerGui()
    if not playerGui then
        return
    end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileAdminPanel"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = playerGui

    FloatingButton = createFloatingButton(ScreenGui)
    FloatingButton.Parent = ScreenGui
    FloatingButton.ZIndex = PANEL_ZINDEX

    Scrim = createScrim(ScreenGui)
    Scrim.Parent = ScreenGui

    Panel = createPanel(ScreenGui)
    Sidebar = createSidebar(Panel)
    local contentHolder
    contentHolder, ContentFrame = createContent(Panel)
    buildTabs(ContentFrame)

    for _, tab in ipairs(TAB_NAMES) do
        createSidebarButton(Sidebar, tab)
    end

    Scrim.MouseButton1Click:Connect(function()
        if Panel.Visible then
            tween(Scrim, {BackgroundTransparency = 1}, TweenInfo.new(0.2))
            tween(Panel, {Position = UDim2.new(0.5, 0, PANEL_TOP - 1, 0)}, TweenInfo.new(0.25))
            task.delay(0.25, function()
                Panel.Visible = false
                Scrim.Visible = false
                FloatingButton.Visible = true
            end)
        end
    end)

    FloatingButton.MouseButton1Click:Connect(function()
        FloatingButton.Visible = false
        Scrim.Visible = true
        Panel.Visible = true
        Panel.Position = UDim2.new(0.5, 0, PANEL_TOP - 1, 0)
        Scrim.BackgroundTransparency = 1
        tween(Scrim, {BackgroundTransparency = 0.25}, TweenInfo.new(0.2))
        tween(Panel, {Position = UDim2.new(0.5, 0, PANEL_TOP, 0)}, TweenInfo.new(0.25))
    end)
end

-------------------- Fly Controls --------------------
local function createFlyButtons(parent)
    local container = Instance.new("Frame")
    container.Name = "FlyButtons"
    container.Size = UDim2.new(0, 120, 0, 150)
    container.Position = UDim2.new(1, -130, 1, -160)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Parent = container
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)

    local ascend = Instance.new("TextButton")
    ascend.Name = "AscendButton"
    ascend.Size = UDim2.new(0, 100, 0, 50)
    ascend.BackgroundColor3 = Theme.accent
    ascend.BorderSizePixel = 0
    ascend.TextColor3 = Theme.text
    ascend.Font = Enum.Font.GothamBold
    ascend.TextSize = 24
    ascend.Text = "↑"
    addCorner(ascend, 12)
    addStroke(ascend, 1)
    ascend.Parent = container

    local descend = Instance.new("TextButton")
    descend.Name = "DescendButton"
    descend.Size = UDim2.new(0, 100, 0, 50)
    descend.BackgroundColor3 = Theme.accent
    descend.BorderSizePixel = 0
    descend.TextColor3 = Theme.text
    descend.Font = Enum.Font.GothamBold
    descend.TextSize = 24
    descend.Text = "↓"
    addCorner(descend, 12)
    addStroke(descend, 1)
    descend.Parent = container

    ascend.MouseButton1Down:Connect(function()
        State.flyAscend = 1
    end)
    ascend.MouseButton1Up:Connect(function()
        State.flyAscend = 0
    end)
    ascend.MouseLeave:Connect(function()
        if State.flyAscend == 1 then
            State.flyAscend = 0
        end
    end)

    descend.MouseButton1Down:Connect(function()
        State.flyAscend = -1
    end)
    descend.MouseButton1Up:Connect(function()
        State.flyAscend = 0
    end)
    descend.MouseLeave:Connect(function()
        if State.flyAscend == -1 then
            State.flyAscend = 0
        end
    end)

    State.ascendButton = ascend
    State.descendButton = descend
    State.flyButtonContainer = container
end

-------------------- Permission & Character Tracking --------------------
local function onCharacterAdded(character)
    State.currentCharacter = character
    local humanoid = character:WaitForChild("Humanoid", 10)
    State.currentHumanoid = humanoid
    clearNoclipTracking()
    if State.noclip and hasPermission() and isPlayerOwnedPlace() then
        local function applyNoclipToParts(part)
            if part:IsA("BasePart") and part.CanCollide then
                noclipOriginalCollide[part] = part.CanCollide
                part.CanCollide = false
            end
        end
        for _, part in ipairs(character:GetDescendants()) do
            applyNoclipToParts(part)
        end
    end
    if State.walkspeedEnabled and State.walkspeedValue then
        if humanoid then
            humanoid.WalkSpeed = State.walkspeedValue
        end
    end
    if State.fly then
        -- Delay to ensure attachments are created after character is ready
        task.defer(function()
            State.fly = false
            State.flyAscend = 0
            if State.flyButtonContainer then
                State.flyButtonContainer.Visible = true
            end
            -- Re-enable to create attachments for new character
            State.fly = true
        end)
    end
end

local function onCharacterRemoving()
    clearNoclipTracking()
    State.currentCharacter = nil
    State.currentHumanoid = nil
end

local function getHumanoid()
    local character = LocalPlayer.Character or State.currentCharacter
    if not character then
        return nil
    end
    return character:FindFirstChildOfClass("Humanoid")
end

-------------------- Walkspeed Logic --------------------
local walkspeedConnection

local function enableWalkspeed()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = State.walkspeedValue
        if walkspeedConnection then
            walkspeedConnection:Disconnect()
            walkspeedConnection = nil
        end
        walkspeedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if State.walkspeedEnabled then
                humanoid.WalkSpeed = State.walkspeedValue
            end
        end)
    end
end

local function disableWalkspeed()
    if walkspeedConnection then
        walkspeedConnection:Disconnect()
        walkspeedConnection = nil
    end
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end

-------------------- Fly Logic --------------------
local function stopFly(keepState)
    if State.flyConnection then
        State.flyConnection:Disconnect()
        State.flyConnection = nil
    end
    if State.flyForce then
        State.flyForce:Destroy()
        State.flyForce = nil
    end
    if State.flyAlign then
        State.flyAlign:Destroy()
        State.flyAlign = nil
    end
    if State.flyAttachment then
        State.flyAttachment:Destroy()
        State.flyAttachment = nil
    end
    if State.flyButtonContainer then
        State.flyButtonContainer.Visible = false
    end
    if not keepState then
        State.fly = false
    end
    State.flyAscend = 0
end

local function startFly()
    local character = LocalPlayer.Character
    if not character then
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then
        return
    end

    local attachment = Instance.new("Attachment")
    attachment.Name = "FlyAttachment"
    attachment.Parent = root

    local align = Instance.new("AlignOrientation")
    align.Attachment0 = attachment
    align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    align.Responsiveness = 50
    align.MaxTorque = math.huge
    align.Parent = root

    local force = Instance.new("VectorForce")
    force.ApplyAtCenterOfMass = true
    force.Attachment0 = attachment
    force.RelativeTo = Enum.ActuatorRelativeTo.World
    force.Force = Vector3.zero
    force.Parent = root

    State.flyAttachment = attachment
    State.flyAlign = align
    State.flyForce = force
    State.fly = true

    if State.flyButtonContainer then
        State.flyButtonContainer.Visible = true
    end

    State.flyConnection = RunService.Heartbeat:Connect(function()
        local currentCharacter = LocalPlayer.Character
        if not State.fly or not currentCharacter then
            return
        end
        local currentHumanoid = currentCharacter:FindFirstChildOfClass("Humanoid")
        local currentRoot = currentCharacter:FindFirstChild("HumanoidRootPart")
        if not currentHumanoid or not currentRoot then
            return
        end

        currentHumanoid:ChangeState(Enum.HumanoidStateType.Physics)

        local camera = Workspace.CurrentCamera
        local direction = Vector3.new()
        if camera then
            local moveDir = currentHumanoid.MoveDirection
            local lookVector = camera.CFrame.LookVector
            local rightVector = camera.CFrame.RightVector
            local forward = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            if forward.Magnitude < 1e-3 then
                forward = Vector3.new(0, 0, -1)
            end
            local right = Vector3.new(rightVector.X, 0, rightVector.Z).Unit
            if right.Magnitude < 1e-3 then
                right = Vector3.new(1, 0, 0)
            end

            local projected = forward * moveDir.Z + right * moveDir.X
            direction = projected.Unit * (projected.Magnitude > 0 and projected.Magnitude or 0)
        end

        local ascend = State.flyAscend
        local finalVelocity = (direction * State.walkspeedValue) + Vector3.new(0, ascend * State.walkspeedValue, 0)
        local requiredForce = finalVelocity * currentRoot.AssemblyMass
        force.Force = requiredForce
        align.CFrame = camera and camera.CFrame or currentRoot.CFrame
    end)
end

-------------------- Noclip Logic --------------------
local function startNoclip()
    if State.noclipConnection then
        State.noclipConnection:Disconnect()
        State.noclipConnection = nil
    end
    local function applyNoclip(character)
        if not character then
            return
        end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if noclipOriginalCollide[part] == nil then
                    noclipOriginalCollide[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end

    State.noclipConnection = RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if character then
            applyNoclip(character)
        end
    end)

    local character = LocalPlayer.Character
    if character then
        applyNoclip(character)
    end
end

local function stopNoclip()
    if State.noclipConnection then
        State.noclipConnection:Disconnect()
        State.noclipConnection = nil
    end
    for part, originalValue in pairs(noclipOriginalCollide) do
        if part and part.Parent then
            part.CanCollide = originalValue
        end
        noclipOriginalCollide[part] = nil
    end
end

-------------------- Teleport Logic --------------------
local function teleportToTarget(target)
    if not hasPermission() then
        showToast("Admin Panel", "No permission")
        return
    end
    if not State.teleportRemoteAvailable or not Remotes.teleport then
        showToast("Admin Panel", "Teleport remote missing")
        return
    end
    if target and target:IsA("BasePart") then
        Remotes.teleport:FireServer(target.CFrame)
    end
end

-------------------- God Mode Logic --------------------
local function setGodMode(enabled)
    if not State.godRemoteAvailable or not Remotes.godMode then
        showToast("Admin Panel", "Server-side only")
        return
    end
    State.godModeEnabled = enabled
    Remotes.godMode:FireServer(enabled)
end

-------------------- UI Population --------------------
local function populateMainTab()
    local container = CardsByTab.Main
    if not container then
        return
    end

    -- WalkSpeed Card
    local walkspeedCard = makeCard("WalkSpeed", "Adjust your walking speed")
    walkspeedCard.Parent = container

    local switchRow = Instance.new("Frame")
    switchRow.BackgroundTransparency = 1
    switchRow.Size = UDim2.new(1, 0, 0, 40)
    switchRow.Parent = walkspeedCard

    local switchLabel = createLabel(switchRow, "Enabled", 16, Enum.Font.GothamBold)
    switchLabel.Size = UDim2.new(0.6, 0, 1, 0)

    local walkSwitch, setWalkSwitch = makeSwitch(false, function(value)
        if not hasPermission() then
            setWalkSwitch(false)
            showToast("Admin Panel", "No permission")
            return
        end
        State.walkspeedEnabled = value
        if value then
            enableWalkspeed()
        else
            disableWalkspeed()
        end
    end)
    walkSwitch.AnchorPoint = Vector2.new(1, 0.5)
    walkSwitch.Position = UDim2.new(1, 0, 0.5, 0)
    walkSwitch.Parent = switchRow
    State.switchSetters.walkspeed = setWalkSwitch

    local sliderRow = Instance.new("Frame")
    sliderRow.BackgroundTransparency = 1
    sliderRow.Size = UDim2.new(1, 0, 0, 40)
    sliderRow.Parent = walkspeedCard

    local sliderLabel = createLabel(sliderRow, "Speed", 16, Enum.Font.GothamBold)
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)

    local walkSlider, setWalkSlider = makeSlider(200, 1, 16, function(value)
        State.walkspeedValue = math.clamp(value, 16, 200)
        if State.walkspeedEnabled then
            enableWalkspeed()
        end
    end)
    walkSlider.Parent = walkspeedCard
    walkSlider:SetAttribute("MinValue", 16)
    State.walkspeedValue = 16
    State.sliderSetters = State.sliderSetters or {}
    State.sliderSetters.walkspeed = setWalkSlider

    -- Fly Card
    local flyCard = makeCard("Fly", "Client-side flight controls")
    flyCard.Parent = container

    local flyRow = Instance.new("Frame")
    flyRow.BackgroundTransparency = 1
    flyRow.Size = UDim2.new(1, 0, 0, 40)
    flyRow.Parent = flyCard

    local flyLabel = createLabel(flyRow, "Enabled", 16, Enum.Font.GothamBold)
    flyLabel.Size = UDim2.new(0.6, 0, 1, 0)

    local flySwitch, setFlySwitch = makeSwitch(false, function(value)
        if not hasPermission() then
            setFlySwitch(false)
            showToast("Admin Panel", "No permission")
            return
        end
        if value then
            startFly()
        else
            stopFly()
        end
        State.fly = value
    end)
    flySwitch.AnchorPoint = Vector2.new(1, 0.5)
    flySwitch.Position = UDim2.new(1, 0, 0.5, 0)
    flySwitch.Parent = flyRow
    State.switchSetters.fly = setFlySwitch

    -- Noclip Card
    local noclipCard = makeCard("Noclip", "Disable collisions for your character")
    noclipCard.Parent = container

    local noclipRow = Instance.new("Frame")
    noclipRow.BackgroundTransparency = 1
    noclipRow.Size = UDim2.new(1, 0, 0, 40)
    noclipRow.Parent = noclipCard

    local noclipLabel = createLabel(noclipRow, "Enabled", 16, Enum.Font.GothamBold)
    noclipLabel.Size = UDim2.new(0.6, 0, 1, 0)

    local noclipSwitch, setNoclipSwitch = makeSwitch(false, function(value)
        if not hasPermission() or not isPlayerOwnedPlace() then
            setNoclipSwitch(false)
            showToast("Admin Panel", "No permission")
            return
        end
        State.noclip = value
        if value then
            startNoclip()
        else
            stopNoclip()
        end
    end)
    noclipSwitch.AnchorPoint = Vector2.new(1, 0.5)
    noclipSwitch.Position = UDim2.new(1, 0, 0.5, 0)
    noclipSwitch.Parent = noclipRow
    State.switchSetters.noclip = setNoclipSwitch

    -- God Mode Card
    local godCard = makeCard("God Mode", "Requires server support")
    godCard.Parent = container

    local godRow = Instance.new("Frame")
    godRow.BackgroundTransparency = 1
    godRow.Size = UDim2.new(1, 0, 0, 40)
    godRow.Parent = godCard

    local godLabel = createLabel(godRow, "Enabled", 16, Enum.Font.GothamBold)
    godLabel.Size = UDim2.new(0.6, 0, 1, 0)

    local godSwitch, setGodSwitch = makeSwitch(false, function(value)
        if not hasPermission() then
            setGodSwitch(false)
            showToast("Admin Panel", "No permission")
            return
        end
        if not State.godRemoteAvailable then
            setGodSwitch(false)
            showToast("Admin Panel", "Server-side only")
            return
        end
        setGodMode(value)
    end)
    godSwitch.AnchorPoint = Vector2.new(1, 0.5)
    godSwitch.Position = UDim2.new(1, 0, 0.5, 0)
    godSwitch.Parent = godRow
    godSwitch.Active = State.godRemoteAvailable
    godSwitch.Visible = true
    State.switchSetters.god = setGodSwitch

    if not State.godRemoteAvailable then
        setGodSwitch(false)
    end
end

local function populateTeleportTab()
    local container = CardsByTab.Teleport
    if not container then
        return
    end

    local teleportCard = makeCard("Teleport Points", "Jump to predefined locations")
    teleportCard.Parent = container

    if #TeleportTargets == 0 then
        local emptyLabel = createLabel(teleportCard, "No teleport points found", 16, Enum.Font.Gotham, Theme.subtext)
        emptyLabel.TextWrapped = true
        emptyLabel.Size = UDim2.new(1, 0, 0, 40)
        return
    end

    for _, part in ipairs(TeleportTargets) do
        local button = Instance.new("TextButton")
        button.Name = "Teleport_" .. part.Name
        button.Text = part.Name
        button.Font = Enum.Font.GothamBold
        button.TextSize = 16
        button.TextColor3 = Theme.text
        button.BackgroundColor3 = Theme.accentDim
        button.BorderSizePixel = 0
        button.Size = UDim2.new(1, 0, 0, 40)
        button.AutoButtonColor = false
        addCorner(button, 12)
        addStroke(button, 1)
        button.Parent = teleportCard

        button.MouseButton1Click:Connect(function()
            teleportToTarget(part)
        end)
    end
end

local function populateVisualsTab()
    local container = CardsByTab.Visuals
    if not container then
        return
    end

    local masterCard = makeCard("Visuals", "Manage ESP for owned NPCs")
    masterCard.Parent = container

    local layout = masterCard:FindFirstChildOfClass("UIListLayout")
    layout.Padding = UDim.new(0, 10)

    local masterRow = Instance.new("Frame")
    masterRow.BackgroundTransparency = 1
    masterRow.Size = UDim2.new(1, 0, 0, 32)
    masterRow.Parent = masterCard

    local masterLabel = createLabel(masterRow, "Visuals Enabled", 16, Enum.Font.GothamBold)
    masterLabel.Size = UDim2.new(0.6, 0, 1, 0)

    local masterSwitch, setMasterSwitch = makeSwitch(State.visualsEnabled, function(value)
        setVisualsEnabled(value)
    end)
    masterSwitch.AnchorPoint = Vector2.new(1, 0.5)
    masterSwitch.Position = UDim2.new(1, 0, 0.5, 0)
    masterSwitch.Parent = masterRow
    State.switchSetters.visuals = setMasterSwitch

    local espRow = Instance.new("Frame")
    espRow.BackgroundTransparency = 1
    espRow.Size = UDim2.new(1, 0, 0, 32)
    espRow.Parent = masterCard

    local espLabel = createLabel(espRow, "NPC ESP", 16, Enum.Font.GothamBold)
    espLabel.Size = UDim2.new(0.6, 0, 1, 0)

    local espSwitch, setEspSwitch = makeSwitch(State.espEnabled, function(value)
        setEspEnabled(value)
    end)
    espSwitch.AnchorPoint = Vector2.new(1, 0.5)
    espSwitch.Position = UDim2.new(1, 0, 0.5, 0)
    espSwitch.Parent = espRow
    State.switchSetters.esp = setEspSwitch

    local sizeRow = Instance.new("Frame")
    sizeRow.BackgroundTransparency = 1
    sizeRow.Size = UDim2.new(1, 0, 0, 40)
    sizeRow.Parent = masterCard

    local sizeLabel = createLabel(sizeRow, "Name Font Size", 16, Enum.Font.GothamBold)
    sizeLabel.Size = UDim2.new(1, 0, 0, 20)

    local sizeSlider = makeSlider(50, 2, State.espFontSize, function(value)
        setEspSize(math.clamp(value, 10, 50))
    end)
    sizeSlider.Parent = masterCard
    sizeSlider:SetAttribute("MinValue", 10)
end

local function populateInfoTab()
    local container = CardsByTab.Info
    if not container then
        return
    end

    local infoCard = makeCard("Information", "Usage and credits")
    infoCard.Size = UDim2.new(1, -12, 0, 160)
    infoCard.Parent = container

    local infoLabel = createLabel(infoCard, "This panel is for your personal Roblox experience.\nPermissions are required to modify gameplay settings.", 14, Enum.Font.Gotham)
    infoLabel.TextWrapped = true
    infoLabel.Size = UDim2.new(1, 0, 0, 60)

    local creditsLabel = createLabel(infoCard, "Design: Red & Black Admin UI\nControls optimized for touch.", 14, Enum.Font.Gotham)
    creditsLabel.TextWrapped = true
    creditsLabel.Size = UDim2.new(1, 0, 0, 60)
end

-------------------- Permission Monitoring --------------------
local function updatePermission()
    State.canAdmin = getBoolValue(LocalPlayer, "CanAdmin") == true
end

local function monitorPermission()
    local canAdminValue = LocalPlayer:FindFirstChild("CanAdmin")
    if canAdminValue and canAdminValue:IsA("BoolValue") then
        canAdminValue.Changed:Connect(function()
            updatePermission()
        end)
    end
    LocalPlayer.ChildAdded:Connect(function(child)
        if child.Name == "CanAdmin" and child:IsA("BoolValue") then
            updatePermission()
            child.Changed:Connect(function()
                updatePermission()
            end)
        end
    end)
    LocalPlayer.ChildRemoved:Connect(function(child)
        if child.Name == "CanAdmin" then
            updatePermission()
        end
    end)
    updatePermission()
end

-------------------- Initialization --------------------
local function initialize()
    detectRemotes()
    loadTeleportPoints()
    buildPanel()
    populateMainTab()
    populateTeleportTab()
    populateVisualsTab()
    populateInfoTab()
    setActiveTab("Main")
    monitorPermission()
    State.uiMounted = true
end

initialize()

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
LocalPlayer.CharacterRemoving:Connect(onCharacterRemoving)
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

showToast("Admin Panel", "Loaded mobile admin controls")
