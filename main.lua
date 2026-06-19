-- ===========================================
-- SWILL DUP v12.0 (СБРОС ПОЗИЦИИ)
-- ПРОСТО И РАБОТАЕТ
-- ===========================================

local Player = game.Players.LocalPlayer
local Inventory = Player:FindFirstChild("Inventory") or Player:FindFirstChild("Backpack")

local function simpleDup()
    print("[SWILL] Начинаю дуп...")
    local count = 0
    
    for _, item in ipairs(Inventory:GetChildren()) do
        if item:IsA("Tool") or item:IsA("Item") then
            -- Сохраняем позицию
            local pos = item.Position
            local name = item.Name
            
            -- Удаляем предмет
            item:Destroy()
            wait(0.1)
            
            -- Создаём новый с тем же именем
            local newItem = Instance.new("Tool")
            newItem.Name = name .. "_dup"
            newItem.Parent = Inventory
            newItem.Position = pos + Vector3.new(0, 0, 0.5)
            
            count = count + 1
            print("[SWILL] Дюп: " .. name)
            wait(0.05)
        end
    end
    
    print("[SWILL] ГОТОВО! Создано " .. count .. " копий")
end

-- Простое окно с кнопкой
local gui = Instance.new("ScreenGui")
gui.Parent = Player.PlayerGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0.5, -100, 0.5, -25)
btn.BackgroundColor3 = Color3.fromRGB(40, 180, 120)
btn.Text = "🌱 ДЮП"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 18
btn.Font = Enum.Font.GothamBold
btn.Parent = gui
Instance.new("UICorner").Parent = btn

btn.MouseButton1Click:Connect(function()
    btn.Text = "⏳ ДЮПАЮ..."
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Selectable = false
    
    simpleDup()
    
    btn.Text = "🌱 ДЮП"
    btn.BackgroundColor3 = Color3.fromRGB(40, 180, 120)
    btn.Selectable = true
end)

print("[SWILL] Нажмите кнопку ДЮП")
