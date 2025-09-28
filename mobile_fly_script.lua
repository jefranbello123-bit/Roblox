-- Fly Script Alternativo para Móvil
-- Método directo que suele funcionar en clients hack

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")

local plr = Players.LocalPlayer
local mouse = plr:GetMouse()

-- Configuración
local flyEnabled = false
local flySpeed = 50
local bv, bg

-- Crear GUI simple
local gui = Instance.new("ScreenGui", CG)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 10, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local flyBtn = Instance.new("TextButton", frame)
flyBtn.Size = UDim2.new(0.9, 0, 0, 40)
flyBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
flyBtn.Text = "ACTIVAR FLY"
flyBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)

local spdLabel = Instance.new("TextLabel", frame)
spdLabel.Size = UDim2.new(0.9, 0, 0, 30)
spdLabel.Position = UDim2.new(0.05, 0, 0.4, 0)
spdLabel.Text = "Speed: " .. flySpeed
spdLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

-- Función de vuelo directa
local function fly()
    if flyEnabled then
        local chr = plr.Character
        if chr and chr:FindFirstChild("HumanoidRootPart") then
            local hrp = chr.HumanoidRootPart
            
            -- Método directo que suele funcionar
            local cam = workspace.CurrentCamera
            local moveVec = Vector3.new(0, 0, 0)
            
            -- Intentar detectar movimiento del joystick
            if UIS.TouchEnabled then
                -- Para móvil, intentar detectar inputs básicos
                if UIS:IsKeyDown(Enum.KeyCode.Thumbstick1) then
                    -- Aquí necesito ver cómo detectan el joystick en el script que encuentres
                end
            end
            
            if bv then bv.Velocity = moveVec * flySpeed end
        end
    end
end

flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    if flyEnabled then
        flyBtn.Text = "FLY ACTIVADO"
        flyBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        -- Inicializar fly
        local chr = plr.Character
        if chr then
            local hrp = chr:FindFirstChild("HumanoidRootPart")
            if hrp then
                bv = Instance.new("BodyVelocity", hrp)
                bg = Instance.new("BodyGyro", hrp)
                bv.MaxForce = Vector3.new(40000, 40000, 40000)
                bg.MaxTorque = Vector3.new(40000, 40000, 40000)
                chr.Humanoid.PlatformStand = true
            end
        end
    else
        flyBtn.Text = "ACTIVAR FLY"
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        if plr.Character then
            plr.Character.Humanoid.PlatformStand = false
        end
    end
end)

RS.Heartbeat:Connect(fly)

print("Fly script cargado - Esperando tu script de ejemplo")
