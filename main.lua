-- =====================================================
-- SWILL DUP v9.0 FOR GROW: ETERNAL GARDEN 2
-- АВТОПОКУПКА СЕМЯН + ДЮП САЖЕНЦЕВ + СВОРАЧИВАНИЕ
-- =====================================================

-- =================== СЕРВИСЫ ==========================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- =================== ПЕРЕМЕННЫЕ =======================
local Inventory = Player:FindFirstChild("Inventory") or Player:FindFirstChild("Backpack")
local RemoteEvent = nil
if ReplicatedStorage then
    RemoteEvent = ReplicatedStorage:FindFirstChild("UpdateInventory") 
                  or ReplicatedStorage:FindFirstChild("ItemEvent")
                  or ReplicatedStorage:FindFirstChild("Remote")
end
if not RemoteEvent then
    RemoteEvent = Player:FindFirstChild("PlayerGui"):FindFirstChild("Remote")
end

-- =================== СОСТОЯНИЕ ========================
local state = {
    isRunning = false,
    isMinimized = false,
    gui = nil,
    mainFrame = nil,
    miniFrame = nil,
    statusLabel = nil,
    progressLabel = nil,
    dupButton = nil,
    buyButton = nil,
}

-- =================== ФУНКЦИИ ==========================

-- ПОИСК САЖЕНЦЕВ
local function isSapling(item)
    if not item then return false end
    local name = item.Name:lower()
    local keywords = {"sapling", "seedling", "seed", "росток", "саженец", "sprout", "plant", "tree", "grow"}
    for _, kw in ipairs(keywords) do
        if name:find(kw) then return true end
    end
    if item:GetAttribute("Type") == "Sapling" then return true end
    if item:GetAttribute("IsSapling") then return true end
    return false
end

local function getAllSaplings()
    local list = {}
    if not Inventory then return list end
    for _, child in ipairs(Inventory:GetChildren()) do
        if isSapling(child) then
            table.insert(list, child)
        end
    end
    return list
end

-- ПОИСК МАГАЗИНА
local function findShop()
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and (child.Name:lower():find("shop") or child.Name:lower():find("store") or child.Name:lower():find("market")) then
            return child
        end
    end
    return nil
end

-- АВТОПОКУПКА СЕМЯН
local function buySeeds()
    local shop = findShop()
    if not shop then
        state.statusLabel.Text = "❌ Магазин не найден!"
        return
    end
    
    local seedItem = nil
    for _, child in ipairs(shop:GetChildren()) do
        if child:IsA("Tool") or child:IsA("Item") then
            if child.Name:lower():find("seed") or child.Name:lower():find("sem") then
                seedItem = child
                break
            end
        end
    end
    
    if not seedItem then
        state.statusLabel.Text = "❌ Семена не найдены в магазине!"
        return
    end
    
    -- Покупаем 10 раз (можно изменить)
    local bought = 0
    for i = 1, 10 do
        if RemoteEvent then
            RemoteEvent:FireServer({action = "buyItem", item = seedItem, count = 1})
            bought = bought + 1
            state.statusLabel.Text = "🛒 Куплено: " .. bought .. " семян"
            wait(0.3)
        end
    end
    state.statusLabel.Text = "✅ Куплено " .. bought .. " семян!"
end

-- ДЮП
local function duplicateItem(item)
    if not item then return false end
    local clone = item:Clone()
    clone.Name = item.Name .. "_dup"
    clone.Parent = Inventory
    local newId = tostring(math.random(100000, 999999)) .. os.time()
    if clone:IsA("Tool") then clone.ToolHandle = newId end
    clone:SetAttribute("ItemId", newId)
    local freeSlot = #Inventory:GetChildren() + 1
    clone.Position = freeSlot
    clone:SetAttribute("Slot", freeSlot)
    if RemoteEvent then
        RemoteEvent:FireServer({action = "addItem", item = clone, slot = freeSlot, count = 64})
    end
    return true
end

local function startDup()
    if state.isRunning then
        state.statusLabel.Text = "⏳ Уже работает!"
        return
    end
    local saplings = getAllSaplings()
    if #saplings == 0 then
        state.statusLabel.Text = "❌ Саженцы не найдены!"
        return
    end
    state.isRunning = true
    state.dupButton.Text = "⏳ Дюпаю..."
    state.dupButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    state.statusLabel.Text = "🌱 Найдено: " .. #saplings .. ". Дюпаю..."
    
    task.spawn(function()
        local total = 0
        for i, sapling in ipairs(saplings) do
            if not state.isRunning then break end
            for j = 1, 20 do -- по 20 копий на саженец
                if not state.isRunning then break end
                local ok = duplicateItem(sapling)
                if ok then
                    total = total + 1
                    state.progressLabel.Text = "Скопировано: " .. total .. " | Обработано: " .. i .. "/" .. #saplings
                end
                wait(0.1)
            end
        end
        state.isRunning = false
        state.dupButton.Text = "🌱 Дюпнуть всё"
        state.dupButton.BackgroundColor3 = Color3.fromRGB(40, 180, 120)
        state.statusLabel.Text = "✅ Готово! Создано копий: " .. total
        state.progressLabel.Text = "Саженцев: " .. #saplings .. " | Копий: " .. total
    end)
end

-- =================== СОЗДАНИЕ GUI =====================
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SwillDupGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
    state.gui = screenGui

    -- ОСНОВНОЕ ОКНО (БОЛЬШЕ)
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 360, 0, 260)
    main.Position = UDim2.new(0.5, -180, 0.5, -130)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    main.BorderSizePixel = 0
    main.Parent = screenGui
    state.mainFrame = main
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = main

    -- ШАПКА
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    header.BorderSizePixel = 0
    header.Parent = main

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 14)
    headerCorner.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🌱 SWILL DUP"
    title.TextColor3 = Color3.fromRGB(220, 220, 225)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- КНОПКА СВОРАЧИВАНИЯ
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -70, 0.5, -15)
    minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    minBtn.BorderSizePixel = 0
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(220, 220, 225)
    minBtn.TextSize = 20
    minBtn.Font = Enum.Font.GothamBold
    minBtn.AutoButtonColor = false
    minBtn.Parent = header
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minBtn

    -- КНОПКА ЗАКРЫТИЯ
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    -- СТАТУС
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "Готов к работе"
    status.TextColor3 = Color3.fromRGB(180, 180, 185)
    status.TextSize = 14
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = main
    state.statusLabel = status

    -- ПРОГРЕСС
    local progress = Instance.new("TextLabel")
    progress.Size = UDim2.new(1, -20, 0, 30)
    progress.Position = UDim2.new(0, 10, 0, 85)
    progress.BackgroundTransparency = 1
    progress.Text = "Саженцев: 0 | Копий: 0"
    progress.TextColor3 = Color3.fromRGB(150, 150, 155)
    progress.TextSize = 13
    progress.Font = Enum.Font.Gotham
    progress.TextXAlignment = Enum.TextXAlignment.Left
    progress.Parent = main
    state.progressLabel = progress

    -- КНОПКА КУПИТЬ СЕМЕНА
    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.new(0.42, 0, 0, 40)
    buyBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
    buyBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    buyBtn.BorderSizePixel = 0
    buyBtn.Text = "🛒 Купить семена"
    buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    buyBtn.TextSize = 14
    buyBtn.Font = Enum.Font.GothamMedium
    buyBtn.AutoButtonColor = false
    buyBtn.Parent = main
    state.buyButton = buyBtn
    local buyCorner = Instance.new("UICorner")
    buyCorner.CornerRadius = UDim.new(0, 10)
    buyCorner.Parent = buyBtn

    -- КНОПКА ДЮПА
    local dup = Instance.new("TextButton")
    dup.Size = UDim2.new(0.42, 0, 0, 40)
    dup.Position = UDim2.new(0.53, 0, 0.75, 0)
    dup.BackgroundColor3 = Color3.fromRGB(40, 180, 120)
    dup.BorderSizePixel = 0
    dup.Text = "🌱 Дюпнуть всё"
    dup.TextColor3 = Color3.fromRGB(255, 255, 255)
    dup.TextSize = 14
    dup.Font = Enum.Font.GothamMedium
    dup.AutoButtonColor = false
    dup.Parent = main
    state.dupButton = dup
    local dupCorner = Instance.new("UICorner")
    dupCorner.CornerRadius = UDim.new(0, 10)
    dupCorner.Parent = dup

    -- МИНИМИЗИРОВАННАЯ ИКОНКА
    local mini = Instance.new("Frame")
    mini.Size = UDim2.new(0, 60, 0, 60)
    mini.Position = UDim2.new(0.9, -70, 0.9, -70)
    mini.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mini.BorderSizePixel = 0
    mini.Visible = false
    mini.Parent = screenGui
    state.miniFrame = mini
    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(0, 30)
    miniCorner.Parent = mini
    local miniStroke = Instance.new("UIStroke")
    miniStroke.Color = Color3.fromRGB(40, 180, 120)
    miniStroke.Thickness = 2
    miniStroke.Parent = mini

    local miniLabel = Instance.new("TextLabel")
    miniLabel.Size = UDim2.new(1, 0, 1, 0)
    miniLabel.BackgroundTransparency = 1
    miniLabel.Text = "🌱"
    miniLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    miniLabel.TextSize = 30
    miniLabel.Font = Enum.Font.GothamBold
    miniLabel.Parent = mini

    -- ============ СОБЫТИЯ КНОПОК ============
    minBtn.MouseButton1Click:Connect(function()
        state.isMinimized = true
        main.Visible = false
        mini.Visible = true
    end)

    mini.MouseButton1Click:Connect(function()
        state.isMinimized = false
        main.Visible = true
        mini.Visible = false
    end)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        state.gui = nil
    end)

    buyBtn.MouseButton1Click:Connect(function()
        buySeeds()
    end)

    dup.MouseButton1Click:Connect(function()
        startDup()
    end)

    -- ОБНОВЛЕНИЕ СЧЁТЧИКА
    local saplings = getAllSaplings()
    progress.Text = "Саженцев: " .. #saplings .. " | Копий: 0"
end

-- =================== ЗАПУСК ====================
createGUI()
print("[SWILL] ✅ GUI создан!")
