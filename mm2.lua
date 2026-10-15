-- ==============================================================================
-- DELTA HUB - MM2 ULTIMATE MASTER PRO EDITION (Aura 200m Map-Wide)
-- ==============================================================================

if not Drawing or not getgenv then
    print("Executor ของคุณไม่รองรับ Drawing API")
    return
end

-- ป้องกันการรันซ้ำและเคลียร์ของเก่า
if getgenv().MM2_LoadedUI then
    pcall(function()
        getgenv().MM2_LoadedUI:Destroy()
    end)
end

if getgenv().MM2_Connection then getgenv().MM2_Connection:Disconnect() end
if getgenv().MM2_NoclipConnection then getgenv().MM2_NoclipConnection:Disconnect() end
if getgenv().MM2_CoinConnection then getgenv().MM2_CoinConnection:Disconnect() end
if getgenv().MM2_SpeedConnection then getgenv().MM2_SpeedConnection:Disconnect() end
if getgenv().MM2_AuraConnection then getgenv().MM2_AuraConnection:Disconnect() end
if getgenv().MM2_GunFetchConnection then getgenv().MM2_GunFetchConnection:Disconnect() end
if getgenv().MM2_PlayerRemoving then getgenv().MM2_PlayerRemoving:Disconnect() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ค่าการตั้งค่า (Settings)
local Settings = {
    Noclip = false,
    AutoCoin = false,
    WalkSpeed = false,
    AuraKill = false,     -- ⚙️ สถานะ Aura Kill
    SmartGunFetch = true, -- ⚙️ ระบบบินเก็บปืนเมื่อปลอดภัย
    SpeedValue = 27,      -- ⚙️ ความเร็วเดิน (27)
    CoinSpeed = 28,       -- ⚙️ ความเร็วในการเก็บเหรียญ
    AuraRange = 200       -- ⚙️ รัศมี Aura Kill (ปรับเป็น 200 เมตร ครอบคลุมเกือบทั้งแมพ)
}

-- สร้าง ScreenGui สำหรับปุ่มเปิด/ปิด
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_ESP_Gui"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end
getgenv().MM2_LoadedUI = ScreenGui

-- ปุ่มลอยเปิด/ปิดเมนู ESP
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 52, 0, 52)
FloatingBtn.Position = UDim2.new(0, 30, 0.4, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
FloatingBtn.Text = "🔪"
FloatingBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
FloatingBtn.TextSize = 24
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.Active = true
FloatingBtn.Draggable = true
FloatingBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner", FloatingBtn)
FloatCorner.CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Color = Color3.fromRGB(231, 76, 60)
FloatStroke.Thickness = 2.5

-- หน้าต่างควบคุมสถานะ
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 350)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "MM2 ULTIMATE HUB"
Title.TextColor3 = Color3.fromRGB(231, 76, 60)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 35)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
StatusLabel.Text = "บทบาท: กำลังตรวจสอบ..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner", StatusLabel)
StatusCorner.CornerRadius = UDim.new(0, 8)

-- ปุ่มเปิด/ปิด Noclip
local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(1, -20, 0, 38)
NoclipBtn.Position = UDim2.new(0, 10, 0, 85)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
NoclipBtn.Text = "Noclip: ปิด ❌"
NoclipBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
NoclipBtn.TextSize = 13
NoclipBtn.Font = Enum.Font.GothamBold
NoclipBtn.Parent = MainFrame
Instance.new("UICorner", NoclipBtn).CornerRadius = UDim.new(0, 8)

NoclipBtn.MouseButton1Click:Connect(function()
    Settings.Noclip = not Settings.Noclip
    if Settings.Noclip then
        NoclipBtn.Text = "Noclip: เปิด ✅"
        NoclipBtn.TextColor3 = Color3.fromRGB(46, 204, 113)
    else
        NoclipBtn.Text = "Noclip: ปิด ❌"
        NoclipBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- ปุ่มเปิด/ปิด เพิ่มสปีด (27)
local OriginalWalkSpeed = 16
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(1, -20, 0, 38)
SpeedBtn.Position = UDim2.new(0, 10, 0, 130)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
SpeedBtn.Text = "WalkSpeed (27): ปิด ❌"
SpeedBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
SpeedBtn.TextSize = 13
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 8)

SpeedBtn.MouseButton1Click:Connect(function()
    Settings.WalkSpeed = not Settings.WalkSpeed
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChild("Humanoid")

    if Settings.WalkSpeed then
        SpeedBtn.Text = "WalkSpeed (27): เปิด ✅"
        SpeedBtn.TextColor3 = Color3.fromRGB(46, 204, 113)
        if humanoid then
            OriginalWalkSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = Settings.SpeedValue
        end
    else
        SpeedBtn.Text = "WalkSpeed (27): ปิด ❌"
        SpeedBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
        if humanoid then
            humanoid.WalkSpeed = OriginalWalkSpeed
        end
    end
end)

-- ปุ่มเปิด/ปิด Auto Coin
local CoinBtn = Instance.new("TextButton")
CoinBtn.Size = UDim2.new(1, -20, 0, 38)
CoinBtn.Position = UDim2.new(0, 10, 0, 175)
CoinBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
CoinBtn.Text = "Auto Coin: ปิด ❌"
CoinBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
CoinBtn.TextSize = 13
CoinBtn.Font = Enum.Font.GothamBold
CoinBtn.Parent = MainFrame
Instance.new("UICorner", CoinBtn).CornerRadius = UDim.new(0, 8)

CoinBtn.MouseButton1Click:Connect(function()
    Settings.AutoCoin = not Settings.AutoCoin
    if Settings.AutoCoin then
        CoinBtn.Text = "Auto Coin: เปิด ✅"
        CoinBtn.TextColor3 = Color3.fromRGB(46, 204, 113)
    else
        CoinBtn.Text = "Auto Coin: ปิด ❌"
        CoinBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- ปุ่มเปิด/ปิด Aura Kill (200m)
local AuraBtn = Instance.new("TextButton")
AuraBtn.Size = UDim2.new(1, -20, 0, 38)
AuraBtn.Position = UDim2.new(0, 10, 0, 220)
AuraBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
AuraBtn.Text = "Aura Kill (200m): ปิด ❌"
AuraBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
AuraBtn.TextSize = 13
AuraBtn.Font = Enum.Font.GothamBold
AuraBtn.Parent = MainFrame
Instance.new("UICorner", AuraBtn).CornerRadius = UDim.new(0, 8)

AuraBtn.MouseButton1Click:Connect(function()
    Settings.AuraKill = not Settings.AuraKill
    if Settings.AuraKill then
        AuraBtn.Text = "Aura Kill (200m): เปิด ✅"
        AuraBtn.TextColor3 = Color3.fromRGB(46, 204, 113)
    else
        AuraBtn.Text = "Aura Kill (200m): ปิด ❌"
        AuraBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- ควบคุมเปิด/ปิด UI ด้วยปุ่มลอย
local uiVisible = true
FloatingBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end)

-- ระบบแคชบทบาทผู้เล่นและ ESP
local RoleCache = {}
local ESPCache = {}
local GunCache = {}

local function RemoveESP(player)
    if ESPCache[player] then
        if ESPCache[player].Box then ESPCache[player].Box:Remove() end
        if ESPCache[player].NameText then ESPCache[player].NameText:Remove() end
        ESPCache[player] = nil
    end
    RoleCache[player] = nil
end

local function RemoveGunESP(gun)
    if GunCache[gun] then
        if GunCache[gun].Box then GunCache[gun].Box:Remove() end
        if GunCache[gun].Text then GunCache[gun].Text:Remove() end
        GunCache[gun] = nil
    end
end

-- ฟังก์ชันตรวจสอบบทบาทที่แม่นยำขึ้น
local function UpdatePlayerRole(player)
    local char = player.Character
    if not char then return "Innocent" end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return "Innocent" end

    local function checkContainer(container)
        if not container then return nil end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") or name:find("blade") or name:find("murderer") then
                    return "Murderer"
                elseif name:find("gun") or name:find("revolver") or name:find("sheriff") then
                    return "Sheriff"
                end
            end
        end
        return nil
    end

    local role = checkContainer(char)
    if role then return role end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        role = checkContainer(backpack)
        if role then return role end
    end
    
    return "Innocent"
end

-- ผูก Event ติดตามผู้เล่น
local function SetupPlayerTracking(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        RoleCache[player] = UpdatePlayerRole(player)
    end)
    if player.Character then
        RoleCache[player] = UpdatePlayerRole(player)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    SetupPlayerTracking(p)
end

Players.PlayerAdded:Connect(SetupPlayerTracking)
getgenv().MM2_PlayerRemoving = Players.PlayerRemoving:Connect(RemoveESP)

-- ระบบ Noclip
local OriginalCanCollide = {}
getgenv().MM2_NoclipConnection = RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end

    if Settings.Noclip or Settings.AutoCoin or Settings.IsFetchingGun then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if OriginalCanCollide[part] == nil then
                    OriginalCanCollide[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    else
        for part, canCollide in pairs(OriginalCanCollide) do
            if part and part:IsDescendantOf(Workspace) then
                part.CanCollide = canCollide
            end
        end
        table.clear(OriginalCanCollide)
    end
end)

-- ระบบ WalkSpeed Boost
getgenv().MM2_SpeedConnection = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health > 0 and Settings.WalkSpeed then
        humanoid.WalkSpeed = Settings.SpeedValue
    end
end)

-- ==============================================================================
-- ระบบ AURA KILL (รัศมี 200 เมตร ครอบคลุมเกือบทั้งแมพ)
-- ==============================================================================
getgenv().MM2_AuraConnection = RunService.Heartbeat:Connect(function()
    if not Settings.AuraKill then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    for _, p in ipairs(Players:GetPlayers()) do
        RoleCache[p] = UpdatePlayerRole(p)
    end
    local myRole = RoleCache[LocalPlayer] or UpdatePlayerRole(LocalPlayer)

    local activeTool = char:FindFirstChildOfClass("Tool")
    local toolName = activeTool and activeTool.Name:lower() or ""
    local holdingKnife = (myRole == "Murderer") or (toolName:find("knife") or toolName:find("blade"))
    local holdingGun = (myRole == "Sheriff") or (toolName:find("gun") or toolName:find("revolver"))

    if holdingKnife then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local pChar = player.Character
                local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart")
                local pHumanoid = pChar and pChar:FindFirstChild("Humanoid")
                
                if pHrp and pHumanoid and pHumanoid.Health > 0 then
                    local dist = (hrp.Position - pHrp.Position).Magnitude
                    if dist <= Settings.AuraRange then
                        pcall(function()
                            if activeTool and activeTool:FindFirstChild("Handle") then
                                firetouchinterest(activeTool.Handle, pHrp, 0)
                                firetouchinterest(activeTool.Handle, pHrp, 1)
                            end
                        end)
                    end
                end
            end
        end
    elseif holdingGun then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local targetRole = RoleCache[player] or "Innocent"
                if targetRole == "Murderer" then
                    local pChar = player.Character
                    local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart")
                    local pHumanoid = pChar and pChar:FindFirstChild("Humanoid")
                    
                    if pHrp and pHumanoid and pHumanoid.Health > 0 then
                        local dist = (hrp.Position - pHrp.Position).Magnitude
                        if dist <= Settings.AuraRange then
                            pcall(function()
                                for _, descendant in ipairs(activeTool:GetDescendants()) do
                                    if descendant:IsA("RemoteEvent") then
                                        descendant:FireServer(pHrp.Position)
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- ==============================================================================
-- ระบบ SMART GUN FETCHER (บินเก็บปืนเมื่อฆาตกรอยู่ห่าง >= 50m)
-- ==============================================================================
Settings.IsFetchingGun = false

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Settings.IsFetchingGun = false
end)

getgenv().MM2_GunFetchConnection = RunService.Heartbeat:Connect(function()
    local myRole = RoleCache[LocalPlayer] or UpdatePlayerRole(LocalPlayer)
    if myRole ~= "Innocent" or Settings.IsFetchingGun then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    local murdererHrp = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (RoleCache[player] == "Murderer") then
            local pChar = player.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChild("Humanoid") and pChar.Humanoid.Health > 0 then
                murdererHrp = pChar.HumanoidRootPart
                break
            end
        end
    end

    local droppedGunPart = nil
    for _, obj in ipairs(Workspace:GetChildren()) do
        local objName = obj.Name:lower()
        if objName == "gundrop" or objName == "gun" or objName:find("gun") then
            local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("Tool") and obj:FindFirstChild("Handle") or obj)
            if targetPart and targetPart:IsA("BasePart") then
                droppedGunPart = targetPart
                break
            end
        end
    end

    if droppedGunPart then
        local safeToFetch = true
        if murdererHrp then
            local distMurdererToGun = (murdererHrp.Position - droppedGunPart.Position).Magnitude
            if distMurdererToGun < 50 then
                safeToFetch = false
            end
        end

        if safeToFetch then
            Settings.IsFetchingGun = true
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not droppedGunPart or not droppedGunPart.Parent or not hrp or not humanoid or humanoid.Health <= 0 then
                    if connection then connection:Disconnect() end
                    Settings.IsFetchingGun = false
                    return
                end

                local targetPos = droppedGunPart.Position
                local direction = (targetPos - hrp.Position)
                local distance = direction.Magnitude

                if distance < 3 then
                    if connection then connection:Disconnect() end
                    humanoid:Move(Vector3.new(0, 0, 0))
                    Settings.IsFetchingGun = false
                else
                    hrp.Velocity = direction.Unit * 27
                    humanoid:Move(direction.Unit)
                end
            end)
        end
    end
end)

-- ==============================================================================
-- ระบบ AUTO COIN
-- ==============================================================================
local processedCoins = {}
local isFlyingToCoin = false

LocalPlayer.CharacterAdded:Connect(function(newChar)
    table.clear(processedCoins)
    isFlyingToCoin = false
end)

getgenv().MM2_CoinConnection = RunService.Heartbeat:Connect(function()
    if not Settings.AutoCoin or isFlyingToCoin or Settings.IsFetchingGun then return end

    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or humanoid.Health <= 0 or not hrp then return end

    local coinContainer = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("CoinContainer")
    if not coinContainer then
        for _, v in ipairs(Workspace:GetChildren()) do
            if v:FindFirstChild("CoinContainer") then
                coinContainer = v.CoinContainer
                break
            end
        end
    end

    if coinContainer then
        local coinChildren = coinContainer:GetChildren()
        if #coinChildren == 0 then table.clear(processedCoins) return end

        local closestCoin = nil
        local shortestDist = math.huge

        for _, coin in ipairs(coinChildren) do
            if (coin.Name == "Coin" or coin:FindFirstChild("CoinVisual")) and not processedCoins[coin] then
                local coinPart = coin:IsA("BasePart") and coin or coin:FindFirstChildWhichIsA("BasePart")
                if coinPart then
                    local dist = (hrp.Position - coinPart.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestCoin = coin
                    end
                end
            end
        end

        if closestCoin then
            local coinPart = closestCoin:IsA("BasePart") and closestCoin or closestCoin:FindFirstChildWhichIsA("BasePart")
            if coinPart then
                processedCoins[closestCoin] = true
                isFlyingToCoin = true
                
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if not Settings.AutoCoin or not coinPart.Parent or not hrp or not humanoid or humanoid.Health <= 0 or Settings.IsFetchingGun then
                        if connection then connection:Disconnect() end
                        isFlyingToCoin = false
                        return
                    end

                    local dir = (coinPart.Position - hrp.Position)
                    if dir.Magnitude < 3 then
                        if connection then connection:Disconnect() end
                        humanoid:Move(Vector3.new(0, 0, 0))
                        isFlyingToCoin = false
                    else
                        hrp.Velocity = dir.Unit * Settings.CoinSpeed
                        humanoid:Move(dir.Unit)
                    end
                end)
            end
        end
    end
end)

-- ลูปหลัก RenderStepped (ESP ผู้เล่น และ Dropped Gun พร้อมระยะทาง)
local lastUpdate = 0
getgenv().MM2_Connection = RunService.RenderStepped:Connect(function()
    local tickTime = tick()
    
    if tickTime - lastUpdate >= 0.2 then
        lastUpdate = tickTime
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                RoleCache[player] = UpdatePlayerRole(player)
            end
        end
    end

    local myRole = RoleCache[LocalPlayer] or UpdatePlayerRole(LocalPlayer)
    StatusLabel.Text = "บทบาทของคุณ: " .. myRole

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- 1. จัดการ ESP ผู้เล่น (พร้อมระยะทาง)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pChar = player.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChild("Humanoid") and pChar.Humanoid.Health > 0 then
                
                local targetRole = RoleCache[player] or "Innocent"
                local showBox = false
                local boxColor = Color3.fromRGB(231, 76, 60)

                if myRole == "Innocent" then
                    if targetRole == "Murderer" then showBox = true; boxColor = Color3.fromRGB(231, 76, 60)
                    elseif targetRole == "Sheriff" then showBox = true; boxColor = Color3.fromRGB(52, 152, 219) end
                elseif myRole == "Murderer" then
                    if targetRole == "Sheriff" then showBox = true; boxColor = Color3.fromRGB(52, 152, 219)
                    elseif targetRole == "Innocent" then showBox = true; boxColor = Color3.fromRGB(231, 76, 60) end
                elseif myRole == "Sheriff" then
                    if targetRole == "Murderer" then showBox = true; boxColor = Color3.fromRGB(231, 76, 60) end
                end

                if not ESPCache[player] then
                    local box = Drawing.new("Square")
                    box.Visible = false; box.Thickness = 1.5; box.Filled = false
                    local nameText = Drawing.new("Text")
                    nameText.Visible = false; nameText.Size = 13; nameText.Center = true; nameText.Outline = true
                    ESPCache[player] = {Box = box, NameText = nameText}
                end

                local cache = ESPCache[player]

                if showBox then
                    cache.Box.Color = boxColor
                    cache.NameText.Color = boxColor

                    local rootPart = pChar.HumanoidRootPart
                    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

                    if onScreen then
                        local head = pChar:FindFirstChild("Head")
                        local topPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or vector
                        local bottomPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

                        local height = math.abs(topPos.Y - bottomPos.Y)
                        local width = height / 2

                        cache.Box.Size = Vector2.new(width, height)
                        cache.Box.Position = Vector2.new(vector.X - width / 2, topPos.Y)
                        cache.Box.Visible = true

                        local distStr = myHrp and (" [" .. math.floor((myHrp.Position - rootPart.Position).Magnitude) .. "m]") or ""
                        cache.NameText.Text = "[" .. targetRole .. "]" .. distStr
                        cache.NameText.Position = Vector2.new(vector.X, topPos.Y - 16)
                        cache.NameText.Visible = true
                    else
                        cache.Box.Visible = false
                        cache.NameText.Visible = false
                    end
                else
                    cache.Box.Visible = false
                    cache.NameText.Visible = false
                end
            else
                RemoveESP(player)
            end
        end
    end

    -- 2. จัดการ Dropped Gun ESP (ปืนที่ตกพื้น สีชมพู พร้อมระยะทาง)
    local activeGuns = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        local objName = obj.Name:lower()
        if objName == "gundrop" or objName == "gun" or objName:find("gun") then
            if obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool") then
                activeGuns[obj] = true
                
                if not GunCache[obj] then
                    local box = Drawing.new("Square")
                    box.Visible = false; box.Color = Color3.fromRGB(255, 105, 180); box.Thickness = 1.5; box.Filled = false
                    local text = Drawing.new("Text")
                    text.Visible = false; text.Color = Color3.fromRGB(255, 105, 180); text.Size = 13; text.Center = true; text.Outline = true
                    GunCache[obj] = {Box = box, Text = text}
                end

                local gunCache = GunCache[obj]
                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("Tool") and obj:FindFirstChild("Handle") or obj)
                
                if targetPart and targetPart:IsA("BasePart") then
                    local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        gunCache.Box.Size = Vector2.new(22, 22)
                        gunCache.Box.Position = Vector2.new(vector.X - 11, vector.Y - 11)
                        gunCache.Box.Visible = true

                        local gunDistStr = myHrp and (" [" .. math.floor((myHrp.Position - targetPart.Position).Magnitude) .. "m]") or ""
                        gunCache.Text.Text = "[Dropped Gun]" .. gunDistStr
                        gunCache.Text.Position = Vector2.new(vector.X, vector.Y - 26)
                        gunCache.Text.Visible = true
                    else
                        gunCache.Box.Visible = false
                        gunCache.Text.Visible = false
                    end
                end
            end
        end
    end

    for gun, _ in pairs(GunCache) do
        if not activeGuns[gun] or not gun.Parent then
            RemoveGunESP(gun)
        end
    end
end)
