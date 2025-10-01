--[[
=================================================================
--  Autoclicker con Botón Móvil para Roblox (Móvil)
--
--  Instrucciones:
--  1. Coloca este script dentro de 'StarterPlayerScripts'.
--  2. Al entrar al juego, aparecerá un botón en la pantalla.
--  3. Arrastra el botón para moverlo donde quieras.
--  4. Toca el botón para activar/desactivar el autoclicker.
--
=================================================================
]]

-- Servicios
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Variables de configuración
local delay = 0.1 -- Tiempo en segundos entre cada clic
local autoclickerEnabled = false -- Estado del autoclicker

-- Jugador local y mouse
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Crear la GUI del botón
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local dragButton = Instance.new("TextButton", screenGui)
dragButton.Size = UDim2.new(0, 80, 0, 80) -- Tamaño del botón (80x80 píxeles)
dragButton.Position = UDim2.new(0.5, -40, 0.5, -40) -- Posición inicial (centro de la pantalla)
dragButton.Text = "Click"
dragButton.Font = Enum.Font.SourceSansBold
dragButton.TextSize = 24
dragButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255) -- Color azul
dragButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
dragButton.BorderSizePixel = 2
dragButton.Draggable = true -- Permite que el botón se pueda arrastrar
dragButton.Active = true -- Permite que detecte clics mientras se arrastra

-- Función para simular un clic
local function performClick()
	-- Simula un toque en la posición actual del cursor
	game:GetService("VirtualInputManager"):SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
	wait(0.05)
	game:GetService("VirtualInputManager"):SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
end

-- Bucle principal del autoclicker
spawn(function()
	while true do
		wait(delay)
		if autoclickerEnabled then
			performClick()
		end
	end
end)

-- Activar/desactivar con un toque
dragButton.MouseButton1Click:Connect(function()
	autoclickerEnabled = not autoclickerEnabled
	
	if autoclickerEnabled then
		print("Autoclicker Móvil: Activado")
		dragButton.BackgroundColor3 = Color3.fromRGB(85, 255, 127) -- Cambia a color verde
		dragButton.Text = "ON"
	else
		print("Autoclicker Móvil: Desactivado")
		dragButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85) -- Cambia a color rojo
		dragButton.Text = "OFF"
	end
end)
