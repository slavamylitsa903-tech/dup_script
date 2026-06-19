-- ========================================
-- SWILL DUP v7.0 FOR XENO (GROW: ETERNAL GARDEN)
-- ДЮП ВСЕХ САЖЕНЦЕВ + СВОРАЧИВАНИЕ
-- ========================================

local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage")
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Inventory = Player:FindFirstChild("Inventory") or Player:FindFirstChild("Backpack")
local RemoteEvent = Services.ReplicatedStorage:FindFirstChild("UpdateInventory") 
                    or Services.ReplicatedStorage:FindFirstChild("ItemEvent")
                    or Player:FindFirstChild("PlayerGui"):FindFirstChild("Remote")

-- ========================================
-- КОНФИГ
-- ========================================
local Config = {
    DupDelay = 0.15,          -- Задержка между копиями
    MaxCopiesPerItem = 50,    -- Максимум копий одного саженца
    AutoDetectSaplings = true -- Автоматически искать саженцы
}

-- ========================================
-- СОСТОЯНИЕ
-- ========================================
local State = {
    DupRunning = false,
    IsMinimized = false,
    GUI = nil,
    Container = nil,
    MinimizedButton = nil,
    StatusLabel = nil,
    ProgressLabel = nil,
    DupButton = nil,
    MinimizeButton = nil
}

-- ========================================
-- ЦВЕТА
-- ========================================
local Colors = {
    Background = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(30, 30, 35),
    Primary = Color3.fromRGB(40, 180, 120),
    PrimaryHover = Color3.fromRGB(50, 210, 140),
    TextPrimary = Color3.fromRGB(220, 220, 225),
    TextSecondary = Color3.fromRGB(140, 140, 150),
    Success = Color3.fromRGB(25, 135, 84),
    Error = Color3.fromRGB(180, 50, 50),
    Border = Color3.fromRGB(45, 45, 50)
}

-- ========================================
-- ФУНКЦИИ ПОИСКА САЖЕНЦЕВ
-- ========================================
local function isSapling(item)
    if not item then return false end
    local name = item.Name:lower()
    -- Список ключевых слов для саженцев (можно расширить)
    local saplingKeywords = {
        "sapling", "seedling", "seed", "росток", "саженец", "tree", "plant",
        "grow", "sprout", "cutting", "черенок"
    }
    for _, keyword in ipairs(saplingKeywords) do
        if name:find(keyword) then
            return true
        end
    end
    -- Проверяем атрибуты
    if item:GetAttribute("Type") == "Sapling" or item:GetAttribute("IsSapling") then
        return true
    end
    return false
end

local function getAllSaplings()
    local saplings = {}
    if not Inventory then return saplings end
    for _, child in ipairs(Inventory:GetChildren()) do
        if isSapling(child) then
            table.insert(saplings, child)
        end
    end
    return saplings
end

-- ========================================
-- ФУНКЦИЯ ДЮПА
-- ========================================
local function duplicateItem(original)
    if not original or not RemoteEvent then return false end
    
    local clone = original:Clone()
    clone.Name = original.Name .. "_dup"
    clone.Parent = Inventory
    
    local newId = tostring(math.random(100000, 999999)) .. os.time()
    if clone:IsA("Tool") then
        clone.ToolHandle = newId
    end
    clone:SetAttribute("ItemId", newId)
    clone:SetAttribute("IsDuped", true)
    
    local freeSlot = #Inventory:GetChildren() + 1
    clone.Position = freeSlot
    clone:SetAttribute("Slot", freeSlot)
    
    if RemoteEvent then
        RemoteEvent:FireServer({
            action = "addItem",
            item = clone,
            slot = freeSlot,
            count = 64
        })
    end
    
    return true
end

-- ========================================
-- ОСНОВНАЯ ФУНКЦИЯ ДЮПА
-- ========================================
local function startDuplication()
    if State.DupRunning then
        updateStatus("Дюп уже запущен!", true)
        return
    end

    local saplings = getAllSaplings()
    if #saplings == 0 then
        updateStatus("Саженцы не найдены в инвентаре!", true)
        return
    end

    State.DupRunning = true
    State.DupButton.Text = "Дюпаю..."
    State.DupButton.BackgroundColor3 = Colors.Error
    State.DupButton.Selectable = false
    
    updateStatus("Найдено саженцев: " .. #saplings .. ". Начинаю дюп...", false)
    updateProgress(0, #saplings)

    task.spawn(function()
        local totalDuplicated = 0
        for i, sapling in ipairs(saplings) do
            if not State.DupRunning then break end
            
            -- Дюпаем один саженец несколько раз (до MaxCopiesPerItem)
            for j = 1, Config.MaxCopiesPerItem do
                if not State.DupRunning then break end
                local success = duplicateItem(sapling)
                if success then
                    totalDuplicated = totalDuplicated + 1
                    updateStatus("Дюп " .. totalDuplicated .. " | " .. sapling.Name, false)
                    updateProgress(i, #saplings)
                else
                    updateStatus("Ошибка на " .. sapling.Name, true)
                end
                wait(Config.DupDelay)
            end
        end
        
        State.DupRunning = false
        State.DupButton.Text = "Дюпнуть всё"
        State.DupButton.BackgroundColor3 = Colors.Primary
        State.DupButton.Selectable = true
        
        if totalDuplicated > 0 then
            updateStatus("ГОТОВО! Создано копий: " .. totalDuplicated, false, true)
        else
            updateStatus("Не удалось создать копии. Проверьте соединение.", true)
        end
    end)
end

-- ========================================
-- UI: СОЗДАНИЕ GUI
-- ========================================
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SwillDupGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 100
    screenGui.Parent = PlayerGui
    State.GUI = screenGui

    -- ОСНОВНОЙ КОНТЕЙНЕР
    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.new(0, 320, 0, 200)
    container.Position = UDim2.new(0.5, -160, 0.5, -100)
    container.BackgroundColor3 = Colors.Background
    container.BorderSizePixel = 0
    container.ZIndex = 110
    container.Selectable = false
    container.Parent = screenGui
    State.Container = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = container

    -- ЗАГОЛОВОК
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Colors.Surface
    header.BorderSizePixel = 0
    header.ZIndex = 111
    header.Parent = container

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 14)
    headerCorner.Parent = header

    -- Только верхние углы скруглены
    local headerCorner2 = Instance.new("UICorner")
    headerCorner2.CornerRadius = UDim.new(0, 14)
    headerCorner2.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🌱 SWILL DUP"
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 112
    title.Parent = header

    -- КНОПКА СВОРАЧИВАНИЯ (маленький минус)
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -70, 0.5, -15)
    minimizeBtn.BackgroundColor3 = Colors.Surface
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Colors.TextPrimary
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.ZIndex = 112
    minimizeBtn.Selectable = true
    minimizeBtn.Parent = header
    State.MinimizeButton = minimizeBtn

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minimizeBtn

    -- КНОПКА ЗАКРЫТИЯ (крестик)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundColor3 = Colors.Surface
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Colors.Error
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 112
    closeBtn.Selectable = true
    closeBtn.Parent = header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    -- СТАТУС
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, 50)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Готов к дюпу"
    statusLabel.TextColor3 = Colors.TextSecondary
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 112
    statusLabel.Parent = container
    State.StatusLabel = statusLabel

    -- ПРОГРЕСС
    local progressLabel = Instance.new("TextLabel")
    progressLabel.Size = UDim2.new(1, -20, 0, 30)
    progressLabel.Position = UDim2.new(0, 10, 0, 85)
    progressLabel.BackgroundTransparency = 1
    progressLabel.Text = "Саженцев: 0 | Скопировано: 0"
    progressLabel.TextColor3 = Colors.TextSecondary
    progressLabel.TextSize = 13
    progressLabel.Font = Enum.Font.Gotham
    progressLabel.TextXAlignment = Enum.TextXAlignment.Left
    progressLabel.ZIndex = 112
    progressLabel.Parent = container
    State.ProgressLabel = progressLabel

    -- КНОПКА ДЮПА
    local dupBtn = Instance.new("TextButton")
    dupBtn.Size = UDim2.new(0.9, 0, 0, 45)
    dupBtn.Position = UDim2.new(0.05, 0, 1, -55)
    dupBtn.BackgroundColor3 = Colors.Primary
    dupBtn.BorderSizePixel = 0
    dupBtn.Text = "🌱 Дюпнуть всё"
    dupBtn.TextColor3 = Colors.TextPrimary
    dupBtn.TextSize = 16
    dupBtn.Font = Enum.Font.GothamMedium
    dupBtn.ZIndex = 112
    dupBtn.Selectable = true
    dupBtn.Parent = container
    State.DupButton = dupBtn

    local dupCorner = Instance.new("UICorner")
    dupCorner.CornerRadius = UDim.new(0, 10)
    dupCorner.Parent = dupBtn

    -- ========================================
    -- МИНИМИЗИРОВАННАЯ ВЕРСИЯ (маленькая иконка)
    -- ========================================
    local minimizedFrame = Instance.new("Frame")
    minimizedFrame.Size = UDim2.new(0, 60, 0, 60)
    minimizedFrame.Position = UDim2.new(0.9, -70, 0.9, -70)
    minimizedFrame.BackgroundColor3 = Colors.Background
    minimizedFrame.BorderSizePixel = 0
    minimizedFrame.ZIndex = 200
    minimizedFrame.Visible = false
    minimizedFrame.Parent = screenGui
    State.MinimizedButton = minimizedFrame

    local minCorner2 = Instance.new("UICorner")
    minCorner2.CornerRadius = UDim.new(0, 30)
    minCorner2.Parent = minimizedFrame

    local minStroke = Instance.new("UIStroke")
    minStroke.Color = Colors.Primary
    minStroke.Thickness = 2
    minStroke.Transparency = 0.3
    minStroke.Parent = minimizedFrame

    local minIcon = Instance.new("TextLabel")
    minIcon.Size = UDim2.new(1, 0, 1, 0)
    minIcon.BackgroundTransparency = 1
    minIcon.Text = "🌱"
    minIcon.TextColor3 = Colors.TextPrimary
    minIcon.TextSize = 30
    minIcon.Font = Enum.Font.GothamBold
    minIcon.ZIndex = 201
    minIcon.Parent = minimizedFrame

    -- ========================================
    -- СОБЫТИЯ
    -- ========================================
    
    -- СВОРАЧИВАНИЕ
    minimizeBtn.MouseButton1Click:Connect(function()
        State.IsMinimized = true
        container.Visible = false
        minimizedFrame.Visible = true
    end)

    -- РАЗВОРАЧИВАНИЕ (по клику на иконку)
    minimizedFrame.MouseButton1Click:Connect(function()
        State.IsMinimized = false
        container.Visible = true
        minimizedFrame.Visible = false
    end)

    -- ЗАКРЫТИЕ (полное удаление GUI)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        State.GUI = nil
    end)

    -- ДЮП
    dupBtn.MouseButton1Click:Connect(function()
        startDuplication()
    end)

    -- ОБНОВЛЕНИЕ СТАТУСА ПРИ ОТКРЫТИИ
    updateSaplingCount()

    return screenGui
end

-- ========================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ========================================
function updateStatus(text, isError, isSuccess)
    if State.StatusLabel then
        State.StatusLabel.Text = text
        if isSuccess then
            State.StatusLabel.TextColor3 = Colors.Success
        elseif isError then
            State.StatusLabel.TextColor3 = Colors.Error
        else
            State.StatusLabel.TextColor3 = Colors.TextSecondary
        end
    end
end

function updateProgress(current, total)
    if State.ProgressLabel then
        local saplings = getAllSaplings()
        State.ProgressLabel.Text = "Саженцев: " .. #saplings .. " | Обработано: " .. current .. "/" .. total
    end
end

function updateSaplingCount()
    local saplings = getAllSaplings()
    if State.ProgressLabel then
        State.ProgressLabel.Text = "Саженцев: " .. #saplings .. " | Готов к дюпу"
    end
end

-- ========================================
-- ЗАПУСК
-- ========================================
local function Initialize()
    print("[SWILL] Запуск...")
    createGUI()
    print("[SWILL] GUI создан. Нажмите 'Дюпнуть всё' для старта.")
    updateStatus("Готов к дюпу. Нажмите кнопку.", false)
end

Initialize()

-- Команда для ручного обновления списка саженцев
function refreshSaplings()
    updateSaplingCount()
    print("[SWILL] Список саженцев обновлён. Найдено: " .. #getAllSaplings())
end
