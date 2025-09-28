--[[
    ESP + WalkHack Script (Improved)

    This script adds two clientâ€‘side cheats for Roblox: an ESP (Extra
    Sensory Perception) that highlights other players, and a simple speed
    hack that adjusts the player's WalkSpeed.  The original version
    exhibited a few issues:

      * Player connections were never disconnected, potentially causing
        memory leaks when toggling ESP on/off repeatedly.  We now store
        event connections in variables and disconnect them when no longer
        needed.
      * ESP objects did not update when a player respawned.  The update
        loop now queries the player's character on every frame instead of
        capturing an outdated reference.
      * ESP elements were not removed when a player left the game.  A
        PlayerRemoving event has been added.
      * Dragging the menu on desktop only worked with touch input.  The
        drag logic now also responds to mouse input (UserInputType.MouseButton1).

    The core behaviour remains the same: clicking the orange eye icon
    toggles a menu where players can enable/disable ESP and the speed
    hack and adjust the walk speed.  When ESP is enabled the script
    draws a red box, a floating name/health label and a yellow tracer line
    from your character to every other player.

    Note: Using this script likely violates Robloxâ€™s terms of service.
    Always respect the rules of the games you play.
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- State flags
local espEnabled     = false
local walkhackEnabled = false
local currentSpeed   = 100

-- Storage for ESP data
local espFolders         = {}      -- [player] = Folder
local espUpdateConnections = {}    -- [player] = RBXScriptConnection

-- Connections for player added/removed events (so they can be disconnected)
local playerAddedConnection   = nil
local playerRemovingConnection = nil

-- Create main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name   = "ESPWalkhackMenu"
screenGui.Parent = CoreGui

-- Main button (orange eye)
local mainButton = Instance.new("TextButton")
mainButton.Size            = UDim2.new(0, 70, 0, 70)
mainButton.Position        = UDim2.new(0.5, -35, 0.1, 0)
-- Use plain text to avoid font issues with emojis
mainButton.Text            = "MENÃš"
mainButton.TextSize        = 30
mainButton.Font            = Enum.Font.GothamBold
mainButton.TextColor3      = Color3.new(1, 1, 1)
mainButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
mainButton.BorderSizePixel = 0
mainButton.ZIndex          = 2
mainButton.Parent          = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(1, 0)
mainCorner.Parent       = mainButton

-- Menu frame
local menuFrame = Instance.new("Frame")
menuFrame.Size              = UDim2.new(0, 220, 0, 200)
menuFrame.Position          = UDim2.new(0.5, -110, 0.1, 0)
menuFrame.BackgroundColor3  = Color3.fromRGB(40, 40, 40)
menuFrame.BorderSizePixel   = 0
menuFrame.Visible           = false
menuFrame.ZIndex            = 1
menuFrame.Parent            = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 15)
menuCorner.Parent       = menuFrame

-- Title label
local title = Instance.new("TextLabel")
title.Size            = UDim2.new(1, 0, 0, 30)
title.Position        = UDim2.new(0, 0, 0, 0)
-- Plain title to avoid emoji rendering issues
title.Text            = "ESP + WALKHACK"
title.TextSize        = 16
title.Font            = Enum.Font.GothamBold
title.TextColor3      = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.BorderSizePixel = 0
title.Parent          = menuFrame

-- Close button (X) to hide the menu and restore the main button
local closeButton = Instance.new("TextButton")
closeButton.Size              = UDim2.new(0, 25, 0, 25)
closeButton.Position          = UDim2.new(1, -30, 0, 5)
closeButton.Text              = "X"
closeButton.TextSize          = 16
closeButton.Font              = Enum.Font.GothamBold
closeButton.TextColor3        = Color3.new(1, 1, 1)
closeButton.BackgroundColor3  = Color3.fromRGB(200, 60, 60)
closeButton.BorderSizePixel   = 0
closeButton.Parent            = menuFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent       = closeButton

-- ESP button
local espButton = Instance.new("TextButton")
espButton.Size              = UDim2.new(0.9, 0, 0, 40)
espButton.Position          = UDim2.new(0.05, 0, 0.2, 0)
espButton.Text              = "ESP: OFF"
espButton.TextSize          = 14
espButton.Font              = Enum.Font.GothamBold
espButton.TextColor3        = Color3.new(1, 1, 1)
espButton.BackgroundColor3  = Color3.fromRGB(200, 60, 60)
espButton.BorderSizePixel   = 0
espButton.Parent            = menuFrame

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 8)
espCorner.Parent       = espButton

-- Walkhack button
local walkButton = Instance.new("TextButton")
walkButton.Size              = UDim2.new(0.9, 0, 0, 40)
walkButton.Position          = UDim2.new(0.05, 0, 0.45, 0)
walkButton.Text              = "WALKHACK: OFF"
walkButton.TextSize          = 14
walkButton.Font              = Enum.Font.GothamBold
walkButton.TextColor3        = Color3.new(1, 1, 1)
walkButton.BackgroundColor3  = Color3.fromRGB(200, 60, 60)
walkButton.BorderSizePixel   = 0
walkButton.Parent            = menuFrame

local walkCorner = Instance.new("UICorner")
walkCorner.CornerRadius = UDim.new(0, 8)
walkCorner.Parent       = walkButton

-- Speed label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size             = UDim2.new(0.9, 0, 0, 25)
speedLabel.Position         = UDim2.new(0.05, 0, 0.7, 0)
speedLabel.Text             = "VELOCIDAD: " .. currentSpeed
speedLabel.TextSize         = 12
speedLabel.Font             = Enum.Font.Gotham
speedLabel.TextColor3       = Color3.new(1, 1, 1)
speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedLabel.BorderSizePixel  = 0
speedLabel.Parent           = menuFrame

local labelCorner = Instance.new("UICorner")
labelCorner.CornerRadius = UDim.new(0, 8)
labelCorner.Parent       = speedLabel

-- Speed adjustment buttons
local upButton = Instance.new("TextButton")
upButton.Size             = UDim2.new(0.4, 0, 0, 25)
upButton.Position         = UDim2.new(0.05, 0, 0.85, 0)
upButton.Text             = "+50"
upButton.TextSize         = 12
upButton.Font             = Enum.Font.GothamBold
upButton.TextColor3       = Color3.new(1, 1, 1)
upButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
upButton.BorderSizePixel  = 0
upButton.Parent           = menuFrame

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 8)
upCorner.Parent       = upButton

local downButton = Instance.new("TextButton")
downButton.Size             = UDim2.new(0.4, 0, 0, 25)
downButton.Position         = UDim2.new(0.55, 0, 0.85, 0)
downButton.Text             = "-50"
downButton.TextSize         = 12
downButton.Font             = Enum.Font.GothamBold
downButton.TextColor3       = Color3.new(1, 1, 1)
downButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
downButton.BorderSizePixel  = 0
downButton.Parent           = menuFrame

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 8)
downCorner.Parent       = downButton

-- Internal flag for menu state
local menuOpen = false

-----------------------------------------------------------
-- Speed Hack Logic
-----------------------------------------------------------

-- Applies the current walk speed to the player's humanoid.  When the
-- walkhack is disabled the speed resets to Roblox's default (16).
-- Keeps track of a connection used to continuously apply the walk speed.
local walkUpdateConnection = nil

-- Applies the current walk speed once.  When the walkhack is enabled a
-- RenderStepped connection will continuously enforce this value to
-- override any attempts by the game to reset it.
local function applyWalkhack()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if walkhackEnabled then
        humanoid.WalkSpeed = currentSpeed
    else
        humanoid.WalkSpeed = 16
    end
end

-- Toggles the walkhack state and updates the UI accordingly.
local function toggleWalkhack()
    walkhackEnabled = not walkhackEnabled
    if walkhackEnabled then
        walkButton.Text             = "WALKHACK: ON"
        walkButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        -- Immediately apply the new speed
        applyWalkhack()
        -- Continuously enforce the walkspeed every frame.  Some games
        -- overwrite WalkSpeed, so updating it each RenderStepped frame
        -- keeps the speed hack active.
        if not walkUpdateConnection then
            walkUpdateConnection = RunService.RenderStepped:Connect(function()
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = currentSpeed
                    end
                end
            end)
        end
    else
        walkButton.Text             = "WALKHACK: OFF"
        walkButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        -- Disconnect continuous updater and reset speed
        if walkUpdateConnection then
            walkUpdateConnection:Disconnect()
            walkUpdateConnection = nil
        end
        applyWalkhack()
    end
end

-----------------------------------------------------------
-- ESP Logic
-----------------------------------------------------------

-- Destroys and cleans up ESP resources for a specific target player.
local function removeESP(targetPlayer)
    -- Remove folder
    if espFolders[targetPlayer] then
        espFolders[targetPlayer]:Destroy()
        espFolders[targetPlayer] = nil
    end
    -- Disconnect update connection
    if espUpdateConnections[targetPlayer] then
        espUpdateConnections[targetPlayer]:Disconnect()
        espUpdateConnections[targetPlayer] = nil
    end
end

-- Creates and continuously updates ESP adornments for a given player.
local function createESP(targetPlayer)
    -- Skip if ESP disabled or if the player is the local player
    if not espEnabled or targetPlayer == player then return end
    -- Prevent duplicate setups
    if espFolders[targetPlayer] then return end

    -- Create a container folder inside our ScreenGui.  All adornments
    -- belonging to this player will be parented here so they are easy
    -- to remove later.
    local espFolder = Instance.new("Folder")
    espFolder.Name   = targetPlayer.Name .. "_ESP"
    espFolder.Parent = screenGui
    espFolders[targetPlayer] = espFolder

    -- Update function called every frame (RenderStepped) to refresh the
    -- ESP components.  It reads the player's current character each
    -- time to handle respawns correctly.
    local function update()
        if not espEnabled then
            return
        end
        local char = targetPlayer.Character
        if not char or not char.Parent then
            -- Player has no character (may be respawning), clear any
            -- existing adornments but keep the folder for later reuse.
            for _, child in ipairs(espFolder:GetChildren()) do
                child:Destroy()
            end
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then
            -- Character doesn't have a valid root or is dead; clear adornments
            for _, child in ipairs(espFolder:GetChildren()) do
                child:Destroy()
            end
            return
        end
        -- Clear previous adornments each frame to refresh size/position/health
        for _, child in ipairs(espFolder:GetChildren()) do
            child:Destroy()
        end
        -- Box highlight (red)
        local box = Instance.new("BoxHandleAdornment")
        box.Name         = "ESP_Box"
        box.Adornee      = root
        box.AlwaysOnTop  = true
        box.ZIndex       = 1
        box.Size         = Vector3.new(4, 6, 2)
        box.Color3       = Color3.new(1, 0, 0)
        box.Transparency = 0.3
        box.Parent       = espFolder
        -- Floating name with health
        local billboard = Instance.new("BillboardGui")
        billboard.Name        = "ESP_Name"
        billboard.Adornee     = root
        -- Make the label taller so names are more visible
        billboard.Size        = UDim2.new(0, 200, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 1000
        billboard.Parent      = espFolder
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size               = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text               = targetPlayer.Name .. " [" .. math.floor(humanoid.Health) .. " HP]"
        nameLabel.TextColor3         = Color3.new(1, 1, 1)
        -- Increase the text size for better readability
        nameLabel.TextSize           = 20
        nameLabel.Font               = Enum.Font.GothamBold
        nameLabel.Parent             = billboard
        -- Tracer line (yellow) from our character to the target
        local line = Instance.new("LineHandleAdornment")
        line.Name        = "ESP_Line"
        line.Adornee     = workspace.Terrain
        line.ZIndex      = 0
        line.Thickness   = 2
        line.Color3      = Color3.new(1, 1, 0)
        line.Transparency = 0.5
        line.Parent      = espFolder
        local localChar  = player.Character
        local localRoot  = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if localRoot then
            line.Length = (root.Position - localRoot.Position).Magnitude
            line.CFrame = CFrame.new(localRoot.Position, root.Position)
        end
    end
    -- Use RenderStepped instead of Heartbeat for smoother UI updates.
    espUpdateConnections[targetPlayer] = RunService.RenderStepped:Connect(update)
end

-- Enables or disables ESP and sets up/removes connections.
local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        espButton.Text             = "ESP: ON"
        espButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        -- Setup existing players
        for _, other in ipairs(Players:GetPlayers()) do
            createESP(other)
        end
        -- Connect PlayerAdded to create ESP for new players
        if not playerAddedConnection then
            playerAddedConnection = Players.PlayerAdded:Connect(function(p)
                -- Delay to allow character to spawn
                task.delay(1, function()
                    createESP(p)
                end)
            end)
        end
        -- Connect PlayerRemoving to clean up when someone leaves
        if not playerRemovingConnection then
            playerRemovingConnection = Players.PlayerRemoving:Connect(function(p)
                removeESP(p)
            end)
        end
    else
        espButton.Text             = "ESP: OFF"
        espButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        -- Remove all ESP folders and connections
        for ply, _ in pairs(espFolders) do
            removeESP(ply)
        end
        espFolders = {}
        -- Disconnect PlayerAdded/Removing connections
        if playerAddedConnection then
            playerAddedConnection:Disconnect()
            playerAddedConnection = nil
        end
        if playerRemovingConnection then
            playerRemovingConnection:Disconnect()
            playerRemovingConnection = nil
        end
    end
end

-----------------------------------------------------------
-- UI / Menu Logic
-----------------------------------------------------------

-- Show the menu and hide the main button.  Called when the eye icon
-- is clicked.
local function openMenu()
    menuOpen            = true
    mainButton.Visible  = false
    menuFrame.Visible   = true
end

-- Hide the menu and restore the main button.  Called when the X
-- button is clicked.
local function closeMenu()
    menuOpen            = false
    menuFrame.Visible   = false
    mainButton.Visible  = true
end

-- Event connections
mainButton.MouseButton1Click:Connect(openMenu)
closeButton.MouseButton1Click:Connect(function()
    closeMenu()
end)
espButton.MouseButton1Click:Connect(toggleESP)
walkButton.MouseButton1Click:Connect(toggleWalkhack)
upButton.MouseButton1Click:Connect(function()
    currentSpeed = currentSpeed + 50
    speedLabel.Text = "VELOCIDAD: " .. currentSpeed
    applyWalkhack()
end)
downButton.MouseButton1Click:Connect(function()
    currentSpeed = math.max(50, currentSpeed - 50)
    speedLabel.Text = "VELOCIDAD: " .. currentSpeed
    applyWalkhack()
end)

-- When the player respawns, reapply the walkhack
player.CharacterAdded:Connect(function()
    task.wait(1)
    applyWalkhack()
end)

-- Apply walkhack on script start
applyWalkhack()

-----------------------------------------------------------
-- Dragging Logic
-----------------------------------------------------------
-- Allows the user to drag the main button and attached menu.  Supports
-- both touch and mouse input.  The menu follows the button with a
-- horizontal offset.
local dragging        = false
local dragStart       = nil
local startButtonPos  = nil
local startMenuPos    = nil
local dragInput       = nil

-- Begin dragging on touch or left mouse down
local function beginDrag(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging       = true
        dragStart      = input.Position
        startButtonPos = mainButton.Position
        startMenuPos   = menuFrame.Position
        dragInput      = input
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

-- Update drag input reference if a new touch/mouse movement is detected
local function updateDragInput(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end

-- Move the UI while dragging
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        -- Update positions by adding the delta to the original positions.
        if startButtonPos then
            mainButton.Position = UDim2.new(
                startButtonPos.X.Scale,
                startButtonPos.X.Offset + delta.X,
                startButtonPos.Y.Scale,
                startButtonPos.Y.Offset + delta.Y
            )
        end
        if startMenuPos then
            menuFrame.Position = UDim2.new(
                startMenuPos.X.Scale,
                startMenuPos.X.Offset + delta.X,
                startMenuPos.Y.Scale,
                startMenuPos.Y.Offset + delta.Y
            )
        end
    end
end)

-- Attach input handlers to the main button
-- Allow dragging from both the menu and the button
mainButton.InputBegan:Connect(beginDrag)
mainButton.InputChanged:Connect(updateDragInput)
menuFrame.InputBegan:Connect(beginDrag)
menuFrame.InputChanged:Connect(updateDragInput)

-- Debug messages (printed to developer console)
print("ðŸŽ¯ ESP + WALKHACK CARGADO!")
print("ðŸ‘ï¸ ESP: Ver jugadores a travÃ©s de paredes")
print("ðŸš€ WALKHACK: Velocidad aumentada")
print("ðŸ’¡ Toca el botÃ³n naranja para abrir el menÃº")
