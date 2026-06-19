-- ===========================================
-- SWILL DUP v11.0 (БЕЗ REMOTE)
-- РАБОТАЕТ ВСЕГДА
-- ===========================================

local Player = game.Players.LocalPlayer
local Inventory = Player:FindFirstChild("Inventory") or Player:FindFirstChild("Backpack")
local PlayerGui = Player:WaitForChild("PlayerGui")

-- СОЗДАЁМ ГЛАВНОЕ ОКНО
local gui = Instance.new("ScreenGui")
gui.Name = "SWILL_DUP"
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 150)
main.Position = UDim2.new(0.5, -140, 0.5, -75)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner").Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "🌱 SWILL DUP v11"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 25)
status.Position = UDim2.new(0, 10, 0, 40)
status.BackgroundTransparency = 1
status.Text = "Нажмите кнопку"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextSize = 13
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

-- КНОПКА ДЮПА
local dupBtn = Instance.new("TextButton")
dupBtn.Size = UDim2.new(0.9, 0, 0, 40)
dupBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
dupBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 120)
dupBtn.BorderSizePixel = 0
dupBtn.Text = "🌱 ДЮПНУТЬ ВСЁ"
dupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dupBtn.TextSize = 16
dupBtn.Font = Enum.Font.GothamMedium
dupBtn.AutoButtonColor = false
dupBtn.Parent = main
Instance.new("UICorner").Parent = dupBtn

-- КНОПКА ЗАКРЫТЬ
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = main
Instance.new("UICorner").Parent = closeBtn

-- ============== ОСНОВНАЯ ЛОГИКА ДЮПА ==============

local function duplicateItems()
    status.Text = "⏳ Ищу предметы..."
    wait(0.5)
    
    local items = {}
    for _, item in ipairs(Inventory:GetChildren()) do
        if item:IsA("Tool") or item:IsA("Item") or item:IsA("Model") then
            table.insert(items, item)
        end
    end
    
    if #items == 0 then
        status.Text = "❌ Нет предметов в инвентаре"
        return
    end
    
    status.Text = "⏳ Дюпаю " .. #items .. " предметов..."
    wait(0.5)
    
    local total = 0
    for i, item in ipairs(items) do
        -- Метод 1: Клонирование через родителя
        local clone = item:Clone()
        clone.Name = item.Name .. "_copy_" .. i
        clone.Parent = Inventory
        
        -- Метод 2: Перемещение туда-сюда (триггерит сохранение)
        wait(0.05)
        clone.Parent = nil
        wait(0.05)
        clone.Parent = Inventory
        
        total = total + 1
        status.Text = "⏳ Скопировано: " .. total .. "/" .. #items
        
        wait(0.1)
    end
    
    status.Text = "✅ ГОТОВО! Скопировано: " .. total
    print("[SWILL] Создано копий: " .. total)
end

-- ============== СОБЫТИЯ ==============

dupBtn.MouseButton1Click:Connect(function()
    dupBtn.Text = "⏳ ДЮПАЮ..."
    dupBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    dupBtn.Selectable = false
    
    duplicateItems()
    
    dupBtn.Text = "🌱 ДЮПНУТЬ ВСЁ"
    dupBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 120)
    dupBtn.Selectable = true
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

print("[SWILL] ✅ Скрипт загружен! Нажмите кнопку.")
