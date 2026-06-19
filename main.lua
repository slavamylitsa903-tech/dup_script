-- =====================================================
-- SWILL "GOD OF THE FOREST" v1.0
-- ДЛЯ ИГРЫ "99 НОЧЕЙ В ЛЕСУ"
-- =====================================================

-- =================== НАСТРОЙКИ =======================
local Settings = {
    FlySpeed = 50,        -- Скорость полёта (по умолчанию)
    WalkSpeed = 32,       -- Скорость ходьбы
    JumpPower = 70,       -- Сила прыжка
    AutoCollectRange = 100, -- Радиус автоподбора
}

-- =================== СЕРВИСЫ ===========================
local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Humanoid = Char:WaitForChild("Humanoid")
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- =================== СОСТОЯНИЯ ========================
local state = {
    fly = false,
    menuOpen = false,
    autoCollect = false,
    espEnabled = false,
    teleportTarget = nil,
    speedMultiplier = 1,
}

-- =================== GUI ===============================
local function CreateMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SwillMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Player.PlayerGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 350, 0, 500)
    main.Position = UDim2.new(0.5, -175, 0.5, -250)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    main.BorderSizePixel = 0
    main.Parent = screenGui
    Instance.new("UICorner").Parent = main

    -- ЗАГОЛОВОК
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    header.BorderSizePixel = 0
    header.Parent = main
    Instance.new("UICorner").Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "🌲 GOD OF THE FOREST"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -17)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    Instance.new("UICorner").Parent = closeBtn

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -70)
    scroll.Position = UDim2.new(0, 10, 0, 60)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 5
    scroll.Parent = main

    local function createButton(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamMedium
        btn.Parent = scroll
        Instance.new("UICorner").Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local function createSlider(text, min, max, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 60)
        container.BackgroundTransparency = 1
        container.Parent = scroll

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. default
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 6)
        slider.Position = UDim2.new(0, 0, 0, 30)
        slider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        slider.BorderSizePixel = 0
        slider.Parent = container
        Instance.new("UICorner").Parent = slider

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(40, 180, 120)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        Instance.new("UICorner").Parent = fill

        local thumb = Instance.new("TextButton")
        thumb.Size = UDim2.new(0, 20, 0, 20)
        thumb.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
        thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        thumb.BorderSizePixel = 0
        thumb.Text = ""
        thumb.Parent = container
        Instance.new("UICorner").Parent = thumb

        local dragging = false
        thumb.MouseButton1Down:Connect(function()
            dragging = true
        end)
        Mouse.Button1Up:Connect(function()
            dragging = false
        end)

        Mouse.Move:Connect(function()
            if dragging then
                local pos = math.clamp((Mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                local value = min + pos * (max - min)
                value = math.round(value * 10) / 10
                label.Text = text .. ": " .. value
                fill.Size = UDim2.new(pos, 0, 1, 0)
                thumb.Position = UDim2.new(pos, -10, 0.5, -10)
                callback(value)
            end
        end)
    end

    -- ========== КНОПКИ ==========
    createButton("🚀 ВКЛ/ВЫКЛ ПОЛЁТ", Color3.fromRGB(40, 120, 200), function()
        state.fly = not state.fly
        if state.fly then
            Humanoid.PlatformStand = true
            Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
        else
            Humanoid.PlatformStand = false
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)

    createButton("📦 ПРИНЕСТИ ВСЕ ПРЕДМЕТЫ", Color3.fromRGB(200, 160, 40), function()
        for _, item in ipairs(workspace:GetChildren()) do
            if item:IsA("Tool") or item:IsA("Item") or item:IsA("Model") then
                if item:FindFirstChild("Handle") or item:FindFirstChild("Humanoid") == nil then
                    item.Parent = Player.Backpack
                    wait(0.02)
                end
            end
        end
    end)

    createButton("🏠 ТЕЛЕПОРТ НА БАЗУ", Color3.fromRGB(40, 200, 120), function()
        local base = nil
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name:lower():find("base") or obj.Name:lower():find("house") or obj.Name:lower():find("дом") then
                base = obj
                break
            end
        end
        if base and base:FindFirstChild("HumanoidRootPart") then
            Root.CFrame = base.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        elseif base then
            Root.CFrame = base.CFrame + Vector3.new(0, 3, 0)
        else
            Root.CFrame = CFrame.new(0, 10, 0)
        end
    end)

    createButton("👁️ ESP (ВСЕ ИГРОКИ)", Color3.fromRGB(180, 40, 200), function()
        state.espEnabled = not state.espEnabled
        if state.espEnabled then
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= Player and player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        else
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= Player and player.Character then
                    local h = player.Character:FindFirstChild("Highlight")
                    if h then h:Destroy() end
                end
            end
        end
    end)

    createButton("🌀 АВТОСБОР ПРЕДМЕТОВ", Color3.fromRGB(40, 200, 200), function()
        state.autoCollect = not state.autoCollect
        if state.autoCollect then
            game:GetService("RunService").Heartbeat:Connect(function()
                if state.autoCollect then
                    for _, item in ipairs(workspace:GetChildren()) do
                        if item:IsA("Tool") or item:IsA("Item") then
                            if (item.Position - Root.Position).Magnitude < Settings.AutoCollectRange then
                                item.Parent = Player.Backpack
                            end
                        end
                    end
                end
            end)
        end
    end)

    -- ========== СЛАЙДЕРЫ ==========
    createSlider("🚀 Скорость полёта", 10, 200, Settings.FlySpeed, function(value)
        Settings.FlySpeed = value
        if state.fly then
            Humanoid.WalkSpeed = value * state.speedMultiplier
        end
    end)

    createSlider("🏃 Скорость бега", 16, 100, Settings.WalkSpeed, function(value)
        Settings.WalkSpeed = value
        Humanoid.WalkSpeed = value * state.speedMultiplier
    end)

    createSlider("🦘 Сила прыжка", 30, 150, Settings.JumpPower, function(value)
        Settings.JumpPower = value
        Humanoid.JumpPower = value
    end)

    -- ========== УПРАВЛЕНИЕ ==========
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        state.menuOpen = false
    end)

    return screenGui
end

-- =================== ПОЛЁТ ==============================
local function Fly()
    local flying = false
    local speed = Settings.FlySpeed

    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F and state.menuOpen == false then
            state.fly = not state.fly
            if state.fly then
                Humanoid.PlatformStand = true
                Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
            else
                Humanoid.PlatformStand = false
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
        if input.KeyCode == Enum.KeyCode.RightShift then
            state.menuOpen = not state.menuOpen
            if state.menuOpen then
                CreateMenu()
            else
                local gui = Player.PlayerGui:FindFirstChild("SwillMenu")
                if gui then gui:Destroy() end
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if state.fly then
            local camera = workspace.CurrentCamera
            local forward = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            local up = camera.CFrame.UpVector
            
            local move = Vector3.new(0, 0, 0)
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then move = move + forward * speed end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then move = move - forward * speed end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then move = move - right * speed end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then move = move + right * speed end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then move = move + up * speed end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then move = move - up * speed end
            
            Root.Velocity = move
        end
    end)
end

-- =================== ТЕЛЕПОРТ НА КАРТУ =================
local function TeleportToPOI()
    local pois = {
        {"🪵 База", nil, "base"},
        {"🌲 Лес", nil, "forest"},
        {"🏔️ Гора", nil, "mountain"},
        {"🌊 Озеро", nil, "lake"},
        {"🏚️ Дом", nil, "house"}
    }
    -- Поиск объектов в мире
    for _, obj in ipairs(workspace:GetChildren()) do
        for i, poi in ipairs(pois) do
            if obj.Name:lower():find(poi[3]) then
                pois[i][2] = obj
            end
        end
    end
    -- Выводим в консоль для выбора
    for i, poi in ipairs(pois) do
        print(i .. ". " .. poi[1] .. (poi[2] and " ✅" or " ❌"))
    end
    print("Введите номер места для телепортации:")
    -- Ждём ввод через консоль Xeno
    local choice = tonumber(input:Wait(""))
    if choice and pois[choice] and pois[choice][2] then
        local target = pois[choice][2]
        local pos = target:FindFirstChild("HumanoidRootPart") and target.HumanoidRootPart.CFrame or target.CFrame
        Root.CFrame = pos + Vector3.new(0, 3, 0)
    end
end

-- =================== ИНФИНИТНЫЙ ИНВЕНТАРЬ ==============
local function InfiniteInventory()
    for _, tool in ipairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool:Clone().Parent = Player.Backpack
        end
    end
end

-- =================== ЗАПУСК ============================
CreateMenu()
Fly()
print("🌲 GOD OF THE FOREST ACTIVATED!")
print("⚡ F - Вкл/Выкл полёт")
print("⚡ RightShift - Открыть меню")
print("⚡ Все настройки в меню!")
