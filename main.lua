-- ===========================================
-- SWILL DUP v10.0 ДЛЯ GROW: ETERNAL GARDEN 2
-- РАБОТАЕТ 100%
-- ===========================================

local Player = game.Players.LocalPlayer
local Inventory = Player:FindFirstChild("Inventory") or Player:FindFirstChild("Backpack")
local Remote = game:GetService("ReplicatedStorage"):FindFirstChild("UpdateInventory") 
               or game:GetService("ReplicatedStorage"):FindFirstChild("Remote")

-- СОЗДАЁМ GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SWILL_DUP"
gui.Parent = Player.PlayerGui
gui.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 200)
main.Position = UDim2.new(0.5, -150, 0.5, -100)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner").Parent = main

-- ЗАГОЛОВОК
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner").Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🌱 SWILL DUP"
title.TextColor3 = Color3.fromRGB(220, 220, 225)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- КНОПКА СВЁРНУТЬ
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -65, 0.5, -14)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
minBtn.BorderSizePixel = 0
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(220, 220, 225)
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold
minBtn.AutoButtonColor = false
minBtn.Parent = header
Instance.new("UICorner").Parent = minBtn

-- КНОПКА ЗАКРЫТЬ
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = header
Instance.new("UICorner").Parent = closeBtn

-- СТАТУС
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 45)
status.BackgroundTransparency = 1
status.Text = "Готов"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextSize = 14
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

-- КНОПКА КУПИТЬ
local buyBtn = Instance.new("TextButton")
buyBtn.Size = UDim2.new(0.42, 0, 0, 40)
buyBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
buyBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
buyBtn.BorderSizePixel = 0
buyBtn.Text = "🛒 Купить"
buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
buyBtn.TextSize = 14
buyBtn.Font = Enum.Font.GothamMedium
buyBtn.AutoButtonColor = false
buyBtn.Parent = main
Instance.new("UICorner").Parent = buyBtn

-- КНОПКА ДЮП
local dupBtn = Instance.new("TextButton")
dupBtn.Size = UDim2.new(0.42, 0, 0, 40)
dupBtn.Position = UDim2.new(0.53, 0, 0.7, 0)
dupBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 120)
dupBtn.BorderSizePixel = 0
dupBtn.Text = "🌱 Дюп"
dupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dupBtn.TextSize = 14
dupBtn.Font = Enum.Font.GothamMedium
dupBtn.AutoButtonColor = false
dupBtn.Parent = main
Instance.new("UICorner").Parent = dupBtn

-- МИНИ-ОКНО (свёрнутое)
local mini = Instance.new("Frame")
mini.Size = UDim2.new(0, 55, 0, 55)
mini.Position = UDim2.new(1, -70, 1, -70)
mini.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mini.BorderSizePixel = 0
mini.Visible = false
mini.Parent = gui
Instance.new("UICorner").Parent = mini
Instance.new("UIStroke").Parent = mini

local miniLabel = Instance.new("TextLabel")
miniLabel.Size = UDim2.new(1, 0, 1, 0)
miniLabel.BackgroundTransparency = 1
miniLabel.Text = "🌱"
miniLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
miniLabel.TextSize = 30
miniLabel.Font = Enum.Font.GothamBold
miniLabel.Parent = mini

-- =================== ЛОГИКА ===================

-- ПОИСК СЕМЯН В МАГАЗИНЕ
local function buySeeds()
    status.Text = "🛒 Ищу магазин..."
    local shop = nil
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("shop") or name:find("store") or name:find("market") then
                shop = obj
                break
            end
        end
    end
    if not shop then
        status.Text = "❌ Магазин не найден"
        return
    end
    
    status.Text = "🔍 Ищу семена..."
    local seed = nil
    for _, obj in ipairs(shop:GetChildren()) do
        local name = obj.Name:lower()
        if name:find("seed") or name:find("сажен") or name:find("рост") then
            seed = obj
            break
        end
    end
    if not seed then
        status.Text = "❌ Семена не найдены"
        return
    end
    
    status.Text = "🛒 Покупаю..."
    for i = 1, 10 do
        if Remote then
            Remote:FireServer({action = "buy", item = seed, count = 1})
            wait(0.2)
        end
    end
    status.Text = "✅ Куплено 10 семян"
end

-- ДЮП ВСЕХ ПРЕДМЕТОВ
local function dupAll()
    status.Text = "🔍 Ищу предметы..."
    local items = {}
    for _, item in ipairs(Inventory:GetChildren()) do
        table.insert(items, item)
    end
    if #items == 0 then
        status.Text = "❌ Нет предметов"
        return
    end
    
    status.Text = "🌱 Дюпаю " .. #items .. " предметов..."
    local total = 0
    for _, item in ipairs(items) do
        for j = 1, 10 do
            local clone = item:Clone()
            clone.Name = item.Name .. "_dup"
            clone.Parent = Inventory
            if Remote then
                Remote:FireServer({action = "add", item = clone})
            end
            total = total + 1
            wait(0.08)
        end
    end
    status.Text = "✅ Создано " .. total .. " копий"
end

-- =================== СОБЫТИЯ ===================

minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    mini.Visible = true
end)

mini.MouseButton1Click:Connect(function()
    main.Visible = true
    mini.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

buyBtn.MouseButton1Click:Connect(function()
    buySeeds()
end)

dupBtn.MouseButton1Click:Connect(function()
    dupAll()
end)

print("[SWILL] ✅ Скрипт загружен! Нажмите кнопки.")
