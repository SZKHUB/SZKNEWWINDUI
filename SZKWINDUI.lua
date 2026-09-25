-- =========================================================
-- MADE BY SZK — SZKWINDUI v1.4.0 (CONFIG TAB)
-- =========================================================

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local parent
if gethui then
    parent = gethui()
else
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok then parent = core
    else parent = LocalPlayer:WaitForChild("PlayerGui") end
end

local camera = workspace.CurrentCamera
local vp = camera.ViewportSize
local screenW, screenH = vp.X, vp.Y

-- TAMAÑO
local WIN_W = math.min(420, math.floor(screenW * 0.9))
local WIN_H = math.min(440, math.floor(screenH * 0.85))
local BALL_SIZE = 44
local SIDEBAR_W = 100

-- IDS
local OWNER_ID = 11155411784
local HELPER_ID = 11646115930
local DISCORD_ICON_ID = 16584754901
local WELCOME_IMG_ID = 90479305978009
local DISCORD_LINK = "https://discord.gg/UkB7Ujabue"

-- STAFF A DETECTAR
local STAFF_LIST = {
    {name = "SZKOFFICIAL", display = "SZKOFFICIAL", color = Color3.fromRGB(255, 215, 0), role = "👑 OWNER"},
    {name = "ANDIPAPIRIN", display = "ANDIPAPIRIN", color = Color3.fromRGB(90, 225, 255), role = "⚡ DEV"},
}

-- =========================================================
-- TEMA
-- =========================================================
local Theme = {
    Background    = Color3.fromRGB(10, 10, 12),
    Background2   = Color3.fromRGB(18, 18, 22),
    Sidebar       = Color3.fromRGB(15, 15, 18),
    Card          = Color3.fromRGB(22, 22, 28),
    Border        = Color3.fromRGB(45, 45, 55),
    Text          = Color3.fromRGB(250, 250, 255),
    TextDim       = Color3.fromRGB(150, 150, 160),
    TextMuted     = Color3.fromRGB(100, 100, 110),
    Accent        = Color3.fromRGB(255, 255, 255),
    Accent2       = Color3.fromRGB(20, 20, 20),
    Hover         = Color3.fromRGB(40, 40, 50),
    Close         = Color3.fromRGB(240, 75, 75),
    Minimize      = Color3.fromRGB(250, 200, 45),
    Success       = Color3.fromRGB(70, 220, 140),
    Warning       = Color3.fromRGB(250, 200, 45),
    Cyan          = Color3.fromRGB(90, 225, 255),
    Purple        = Color3.fromRGB(180, 110, 255),
}

local ThemedElements = {
    Strokes = {},
    Fills = {},
    Labels = {},
    Buttons = {},
    Gradients = {},
}

local function registerStroke(stroke, isAccent) table.insert(ThemedElements.Strokes, {stroke = stroke, isAccent = isAccent}) end
local function registerFill(frame, isAccent) table.insert(ThemedElements.Fills, {frame = frame, isAccent = isAccent}) end
local function registerLabel(label, isAccent) table.insert(ThemedElements.Labels, {label = label, isAccent = isAccent}) end
local function registerButton(button, isAccent) table.insert(ThemedElements.Buttons, {button = button, isAccent = isAccent}) end
local function registerGradient(gradient, gtype) table.insert(ThemedElements.Gradients, {gradient = gradient, gtype = gtype}) end

-- =========================================================
-- HELPERS
-- =========================================================
local function addCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function addStroke(p, color, thickness, transparency, isAccent)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    if isAccent ~= nil then registerStroke(s, isAccent) end
    return s
end

local function addGradient(p, c1, c2, rotation, gtype)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rotation or 90
    g.Parent = p
    if gtype then registerGradient(g, gtype) end
    return g
end

local function createLabel(parent, text, size, pos, color, font, textSize, isAccent)
    local l = Instance.new("TextLabel")
    l.Size = size
    l.Position = pos
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Theme.Text
    l.Font = font or Enum.Font.Gotham
    l.TextSize = textSize or 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    if isAccent ~= nil then registerLabel(l, isAccent) end
    return l
end

local function tween(obj, props, time, style, dir)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

-- =========================================================
-- CACHE DE INFO DE JUEGOS
-- =========================================================
local gameInfoCache = {}
local function getGameInfo(placeId)
    if not placeId then return nil end
    if gameInfoCache[placeId] then return gameInfoCache[placeId] end
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Asset)
    end)
    if ok and info then
        local result = {
            name = (info.Name ~= "UGC" and info.Name ~= "") and info.Name or nil,
            universeId = info.UniverseId,
        }
        gameInfoCache[placeId] = result
        return result
    end
    return nil
end

-- =========================================================
-- SISTEMA DE TEMAS OPTIMIZADO (THROTTLED)
-- =========================================================
local currentTheme = "BW"
local themeSpeed = 1
local animPhase = 0
local themeUpdateAccum = 0
local THEME_UPDATE_RATE = 1 / 30

local function applyBWColors(phase)
    local t = (math.sin(phase) + 1) / 2
    local c1 = Color3.fromRGB(
        math.floor(10 + t * 245),
        math.floor(10 + t * 245),
        math.floor(10 + t * 245)
    )
    local c2 = Color3.fromRGB(
        math.floor(255 - t * 245),
        math.floor(255 - t * 245),
        math.floor(255 - t * 245)
    )

    Theme.Accent = c1
    Theme.Accent2 = c2

    for _, data in ipairs(ThemedElements.Strokes) do
        if data.isAccent then data.stroke.Color = c1 end
    end
    for _, data in ipairs(ThemedElements.Fills) do
        if data.isAccent then data.frame.BackgroundColor3 = c1 end
    end
    for _, data in ipairs(ThemedElements.Labels) do
        if data.isAccent then data.label.TextColor3 = c1 end
    end
    for _, data in ipairs(ThemedElements.Buttons) do
        if data.isAccent then
            data.button.BackgroundColor3 = c1
            data.button.TextColor3 = c2
        end
    end
    for _, data in ipairs(ThemedElements.Gradients) do
        if data.gtype == "bw" then
            data.gradient.Color = ColorSequence.new(c1, c2)
        end
    end
end

local function applyRainbowColors(hue)
    local c1 = Color3.fromHSV(hue, 0.85, 1)
    local c2 = Color3.fromHSV((hue + 0.5) % 1, 0.85, 1)
    local c3 = Color3.fromHSV((hue + 0.25) % 1, 0.85, 1)
    local c4 = Color3.fromHSV((hue + 0.75) % 1, 0.85, 1)

    Theme.Accent = c1
    Theme.Accent2 = Color3.fromRGB(15, 15, 18)

    for _, data in ipairs(ThemedElements.Strokes) do
        if data.isAccent then data.stroke.Color = Color3.fromHSV((hue + 0.1) % 1, 0.85, 1) end
    end
    for _, data in ipairs(ThemedElements.Fills) do
        if data.isAccent then data.frame.BackgroundColor3 = Color3.fromHSV((hue + 0.2) % 1, 0.85, 1) end
    end
    for _, data in ipairs(ThemedElements.Labels) do
        if data.isAccent then data.label.TextColor3 = Color3.fromHSV((hue + 0.3) % 1, 0.85, 1) end
    end
    for _, data in ipairs(ThemedElements.Buttons) do
        if data.isAccent then
            data.button.BackgroundColor3 = Color3.fromHSV((hue + 0.4) % 1, 0.85, 1)
            data.button.TextColor3 = Color3.fromRGB(0, 0, 0)
        end
    end
    for _, data in ipairs(ThemedElements.Gradients) do
        if data.gtype == "rainbow" then
            data.gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, c1),
                ColorSequenceKeypoint.new(0.33, c3),
                ColorSequenceKeypoint.new(0.66, c2),
                ColorSequenceKeypoint.new(1, c4),
            })
        end
    end
end

local function applyNeonColors(phase)
    local hue = (phase * 0.1) % 1
    local base = Color3.fromHSV(hue, 1, 1)
    for _, d in ipairs(ThemedElements.Strokes) do
        if d.isAccent then d.stroke.Color = base end
    end
    for _, d in ipairs(ThemedElements.Fills) do
        if d.isAccent then d.frame.BackgroundColor3 = base end
    end
    for _, d in ipairs(ThemedElements.Labels) do
        if d.isAccent then d.label.TextColor3 = base end
    end
    for _, d in ipairs(ThemedElements.Buttons) do
        if d.isAccent then
            d.button.BackgroundColor3 = base
            d.button.TextColor3 = Color3.fromRGB(0, 0, 0)
        end
    end
end

local function applyGlassColors()
    local c = Color3.fromRGB(180, 220, 255)
    for _, d in ipairs(ThemedElements.Strokes) do
        if d.isAccent then
            d.stroke.Color = c
            d.stroke.Transparency = 0.4
        end
    end
    for _, d in ipairs(ThemedElements.Labels) do
        if d.isAccent then d.label.TextColor3 = c end
    end
    for _, d in ipairs(ThemedElements.Fills) do
        if d.isAccent then d.frame.BackgroundColor3 = c end
    end
    for _, d in ipairs(ThemedElements.Buttons) do
        if d.isAccent then
            d.button.BackgroundColor3 = c
            d.button.TextColor3 = Color3.fromRGB(15, 20, 30)
        end
    end
end

RunService.Heartbeat:Connect(function(dt)
    themeUpdateAccum = themeUpdateAccum + dt
    if themeUpdateAccum < THEME_UPDATE_RATE then return end
    local frameDt = themeUpdateAccum
    themeUpdateAccum = 0

    if currentTheme == "BW" then
        animPhase = animPhase + frameDt * 1.2 * themeSpeed
        applyBWColors(animPhase)
    elseif currentTheme == "Rainbow" then
        animPhase = (animPhase + frameDt * 0.25 * themeSpeed) % 1
        applyRainbowColors(animPhase)
    elseif currentTheme == "Neon" then
        animPhase = animPhase + frameDt * 0.5 * themeSpeed
        applyNeonColors(animPhase)
    end
end)

local function setTheme(mode)
    currentTheme = mode
    if mode == "Glass" then applyGlassColors() end
end

-- =========================================================
-- GUI PRINCIPAL
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SZKWINDUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = parent

-- =========================================================
-- NOTIFICATION GUI ÚNICO + POOL
-- =========================================================
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "SZKNotifications"
NotifGui.ResetOnSpawn = false
NotifGui.IgnoreGuiInset = true
NotifGui.DisplayOrder = 1000
NotifGui.Parent = parent

local activeNotifs = {}
local MAX_NOTIFS = 4
local notificationCooldown = {}
local COOLDOWN_TIME = 60

local function canNotify(key)
    local last = notificationCooldown[key]
    if last and (tick() - last) < COOLDOWN_TIME then return false end
    notificationCooldown[key] = tick()
    return true
end

local function registerNotif(frame)
    if #activeNotifs >= MAX_NOTIFS then
        local oldest = table.remove(activeNotifs, 1)
        if oldest and oldest.Parent then oldest:Destroy() end
    end
    table.insert(activeNotifs, frame)
    task.delay(6, function()
        for i, n in ipairs(activeNotifs) do
            if n == frame then table.remove(activeNotifs, i) break end
        end
    end)
end

-- =========================================================
-- WELCOME NOTIFICATION
-- =========================================================
local function ShowWelcomeNotification()
    local welcomeFrame = Instance.new("Frame")
    welcomeFrame.Size = UDim2.new(0, 300, 0, 68)
    welcomeFrame.Position = UDim2.new(1, 40, 0, 20)
    welcomeFrame.BackgroundColor3 = Theme.Card
    welcomeFrame.BackgroundTransparency = 0.05
    welcomeFrame.BorderSizePixel = 0
    welcomeFrame.ZIndex = 1
    welcomeFrame.Parent = NotifGui
    addCorner(welcomeFrame, 14)

    local welcomeStroke = Instance.new("UIStroke")
    welcomeStroke.Color = Theme.Accent
    welcomeStroke.Thickness = 1.5
    welcomeStroke.Transparency = 0.2
    welcomeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    welcomeStroke.Parent = welcomeFrame

    local welcomeGradient = Instance.new("UIGradient")
    welcomeGradient.Color = ColorSequence.new(Theme.Card, Theme.Background2)
    welcomeGradient.Rotation = 90
    welcomeGradient.Parent = welcomeFrame

    local imgFrame = Instance.new("Frame")
    imgFrame.Size = UDim2.new(0, 52, 0, 52)
    imgFrame.Position = UDim2.new(0, 8, 0.5, -26)
    imgFrame.BackgroundColor3 = Theme.Background2
    imgFrame.BackgroundTransparency = 0.2
    imgFrame.BorderSizePixel = 0
    imgFrame.ZIndex = 2
    imgFrame.Parent = welcomeFrame
    addCorner(imgFrame, 11)

    local imgStroke = Instance.new("UIStroke")
    imgStroke.Color = Theme.Accent
    imgStroke.Thickness = 1.5
    imgStroke.Transparency = 0.15
    imgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    imgStroke.Parent = imgFrame

    local welcomeImg = Instance.new("ImageLabel")
    welcomeImg.Size = UDim2.new(1, -4, 1, -4)
    welcomeImg.Position = UDim2.new(0, 2, 0, 2)
    welcomeImg.BackgroundTransparency = 1
    welcomeImg.Image = "rbxthumb://type=Asset&id=" .. WELCOME_IMG_ID .. "&w=150&h=150"
    welcomeImg.ZIndex = 3
    welcomeImg.Parent = imgFrame
    addCorner(welcomeImg, 9)

    local welcomeText = Instance.new("TextLabel")
    welcomeText.Size = UDim2.new(1, -75, 1, 0)
    welcomeText.Position = UDim2.new(0, 68, 0, 0)
    welcomeText.BackgroundTransparency = 1
    welcomeText.Text = "WELCOME " .. string.upper(LocalPlayer.DisplayName) .. " TO SZKHUB"
    welcomeText.TextColor3 = Theme.Text
    welcomeText.Font = Enum.Font.GothamBold
    welcomeText.TextSize = 12
    welcomeText.TextXAlignment = Enum.TextXAlignment.Left
    welcomeText.TextWrapped = true
    welcomeText.ZIndex = 2
    welcomeText.Parent = welcomeFrame

    local barUnder = Instance.new("Frame")
    barUnder.Size = UDim2.new(1, -20, 0, 2)
    barUnder.Position = UDim2.new(0, 10, 1, -6)
    barUnder.BackgroundColor3 = Theme.Background2
    barUnder.BorderSizePixel = 0
    barUnder.ZIndex = 2
    barUnder.Parent = welcomeFrame
    addCorner(barUnder, 1)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = Theme.Accent
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 3
    barFill.Parent = barUnder
    addCorner(barFill, 1)

    tween(welcomeFrame, {
        Position = UDim2.new(1, -320, 0, 20),
        BackgroundTransparency = 0.05
    }, 0.6, Enum.EasingStyle.Back)

    task.spawn(function()
        while welcomeFrame.Parent do
            task.wait(0.05)
            welcomeStroke.Color = Theme.Accent
            imgStroke.Color = Theme.Accent
            barFill.BackgroundColor3 = Theme.Accent
        end
    end)

    tween(barFill, {Size = UDim2.new(0, 0, 1, 0)}, 3.5, Enum.EasingStyle.Linear)

    task.delay(3.5, function()
        if welcomeFrame.Parent then
            tween(welcomeFrame, {
                Position = UDim2.new(1, 40, 0, 20),
                BackgroundTransparency = 1
            }, 0.5, Enum.EasingStyle.Quint)
            task.wait(0.7)
            if welcomeFrame.Parent then welcomeFrame:Destroy() end
        end
    end)

    registerNotif(welcomeFrame)
end

-- =========================================================
-- STAFF NOTIFICATION
-- =========================================================
local function ShowStaffNotification(staffName, staffRole, staffColor, userId)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 280, 0, 64)
    notifFrame.Position = UDim2.new(1, 40, 0, 100)
    notifFrame.BackgroundColor3 = Theme.Card
    notifFrame.BackgroundTransparency = 0.05
    notifFrame.BorderSizePixel = 0
    notifFrame.ZIndex = 1
    notifFrame.Parent = NotifGui
    addCorner(notifFrame, 12)

    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = staffColor
    notifStroke.Thickness = 1.5
    notifStroke.Transparency = 0.2
    notifStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    notifStroke.Parent = notifFrame

    local notifGradient = Instance.new("UIGradient")
    notifGradient.Color = ColorSequence.new(Theme.Card, Theme.Background2)
    notifGradient.Rotation = 90
    notifGradient.Parent = notifFrame

    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 48, 0, 48)
    avatarFrame.Position = UDim2.new(0, 8, 0.5, -24)
    avatarFrame.BackgroundColor3 = Theme.Background2
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ZIndex = 2
    avatarFrame.Parent = notifFrame
    addCorner(avatarFrame, 10)
    addStroke(avatarFrame, staffColor, 1.4, 0.1)

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(1, -4, 1, -4)
    avatarImg.Position = UDim2.new(0, 2, 0, 2)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"
    avatarImg.ZIndex = 3
    avatarImg.Parent = avatarFrame
    addCorner(avatarImg, 8)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -75, 0, 14)
    titleLbl.Position = UDim2.new(0, 64, 0, 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "🔔 STAFF CONECTADO"
    titleLbl.TextColor3 = staffColor
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 10
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 2
    titleLbl.Parent = notifFrame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -75, 0, 16)
    nameLbl.Position = UDim2.new(0, 64, 0, 26)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = staffName
    nameLbl.TextColor3 = Theme.Text
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 12
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 2
    nameLbl.Parent = notifFrame

    local roleLbl = Instance.new("TextLabel")
    roleLbl.Size = UDim2.new(1, -75, 0, 10)
    roleLbl.Position = UDim2.new(0, 64, 0, 44)
    roleLbl.BackgroundTransparency = 1
    roleLbl.Text = staffRole .. " • Se ha unido"
    roleLbl.TextColor3 = Theme.TextMuted
    roleLbl.Font = Enum.Font.Gotham
    roleLbl.TextSize = 8
    roleLbl.TextXAlignment = Enum.TextXAlignment.Left
    roleLbl.ZIndex = 2
    roleLbl.Parent = notifFrame

    local barUnder = Instance.new("Frame")
    barUnder.Size = UDim2.new(1, -20, 0, 2)
    barUnder.Position = UDim2.new(0, 10, 1, -5)
    barUnder.BackgroundColor3 = Theme.Background2
    barUnder.BorderSizePixel = 0
    barUnder.ZIndex = 2
    barUnder.Parent = notifFrame
    addCorner(barUnder, 1)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = staffColor
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 3
    barFill.Parent = barUnder
    addCorner(barFill, 1)

    tween(notifFrame, {
        Position = UDim2.new(1, -300, 0, 100),
        BackgroundTransparency = 0.05
    }, 0.6, Enum.EasingStyle.Back)

    tween(barFill, {Size = UDim2.new(0, 0, 1, 0)}, 4, Enum.EasingStyle.Linear)

    task.delay(4, function()
        if notifFrame.Parent then
            tween(notifFrame, {
                Position = UDim2.new(1, 40, 0, 100),
                BackgroundTransparency = 1
            }, 0.5, Enum.EasingStyle.Quint)
            task.wait(0.7)
            if notifFrame.Parent then notifFrame:Destroy() end
        end
    end)

    registerNotif(notifFrame)
end

-- =========================================================
-- DETECCIÓN DE STAFF ONLINE
-- =========================================================
local staffOnlineCache = {}

task.spawn(function()
    task.wait(2)

    for _, staffData in ipairs(STAFF_LIST) do
        staffOnlineCache[staffData.name] = false
    end

    while true do
        for _, staffData in ipairs(STAFF_LIST) do
            local foundPlayer = nil
            for _, plr in ipairs(Players:GetPlayers()) do
                if string.lower(plr.Name) == string.lower(staffData.name) or string.lower(plr.DisplayName) == string.lower(staffData.display) then
                    foundPlayer = plr
                    break
                end
            end

            local isOnline = foundPlayer ~= nil

            if isOnline and not staffOnlineCache[staffData.name] and foundPlayer and canNotify("staff_" .. staffData.name) then
                ShowStaffNotification(staffData.display, staffData.role, staffData.color, foundPlayer.UserId)
            end

            staffOnlineCache[staffData.name] = isOnline
        end
        task.wait(3)
    end
end)

-- =========================================================
-- MINI HUD
-- =========================================================
local MiniHUD = Instance.new("Frame")
MiniHUD.Name = "MiniHUD"
MiniHUD.Size = UDim2.new(0, 108, 0, 34)
MiniHUD.Position = UDim2.new(0, 14, 0, 14)
MiniHUD.BackgroundColor3 = Theme.Card
MiniHUD.BackgroundTransparency = 0.05
MiniHUD.BorderSizePixel = 0
MiniHUD.Active = true
MiniHUD.Parent = ScreenGui
addCorner(MiniHUD, 9)
addStroke(MiniHUD, Theme.Accent, 1.2, 0.15, true)

local fpsIcon = createLabel(MiniHUD, "🎯", UDim2.new(0, 10, 0, 12), UDim2.new(0, 5, 0, 3), Theme.Text, Enum.Font.GothamBold, 8)
fpsIcon.TextXAlignment = Enum.TextXAlignment.Center
local fpsValue = createLabel(MiniHUD, "60", UDim2.new(0, 20, 0, 12), UDim2.new(0, 16, 0, 3), Theme.Success, Enum.Font.GothamBold, 10)
fpsValue.TextXAlignment = Enum.TextXAlignment.Center

local hudDivider = Instance.new("Frame")
hudDivider.Size = UDim2.new(0, 1, 0, 10)
hudDivider.Position = UDim2.new(0, 40, 0, 3)
hudDivider.BackgroundColor3 = Theme.Border
hudDivider.BorderSizePixel = 0
hudDivider.Parent = MiniHUD

local pingIcon = createLabel(MiniHUD, "📡", UDim2.new(0, 10, 0, 12), UDim2.new(0, 46, 0, 3), Theme.Text, Enum.Font.GothamBold, 8)
pingIcon.TextXAlignment = Enum.TextXAlignment.Center
local pingValue = createLabel(MiniHUD, "45", UDim2.new(0, 24, 0, 12), UDim2.new(0, 55, 0, 3), Theme.Cyan, Enum.Font.GothamBold, 10)
pingValue.TextXAlignment = Enum.TextXAlignment.Center

local madeByLabel = createLabel(MiniHUD, "MADE BY SZK", UDim2.new(1, 0, 0, 8), UDim2.new(0, 0, 0, 23), Theme.TextMuted, Enum.Font.GothamBold, 6)
madeByLabel.TextXAlignment = Enum.TextXAlignment.Center

local hudDragging = false
local hudDragStart, hudStartPos = nil, nil
MiniHUD.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hudDragging = true
        hudDragStart = input.Position
        hudStartPos = MiniHUD.Position
    end
end)
MiniHUD.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then hudDragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if hudDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - hudDragStart
        MiniHUD.Position = UDim2.new(hudStartPos.X.Scale, hudStartPos.X.Offset + delta.X, hudStartPos.Y.Scale, hudStartPos.Y.Offset + delta.Y)
    end
end)

task.spawn(function()
    while true do
        local ping = 0
        local ok = pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
        if ok and ping and ping > 0 then
            pingValue.Text = tostring(ping)
            local c = Theme.Success
            if ping >= 120 then c = Theme.Close elseif ping >= 60 then c = Theme.Warning end
            pingValue.TextColor3 = c
        else
            pingValue.Text = "--"
            pingValue.TextColor3 = Theme.TextMuted
        end
        task.wait(1.5)
    end
end)

task.spawn(function()
    local frames = 0
    local lastTime = os.clock()
    RunService.RenderStepped:Connect(function() frames = frames + 1 end)
    while true do
        local now = os.clock()
        local elapsed = now - lastTime
        if elapsed >= 1 then
            local fps = math.floor(frames / elapsed)
            fpsValue.Text = tostring(fps)
            local c = Theme.Success
            if fps < 30 then c = Theme.Close elseif fps < 50 then c = Theme.Warning end
            fpsValue.TextColor3 = c
            frames = 0
            lastTime = now
        end
        task.wait(0.1)
    end
end)

-- =========================================================
-- VENTANA PRINCIPAL
-- =========================================================
local HOME_POS = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainWindow"
MainFrame.Size = UDim2.new(0, WIN_W, 0, WIN_H)
MainFrame.Position = HOME_POS
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
addCorner(MainFrame, 14)

local BgOverlay = Instance.new("Frame")
BgOverlay.Size = UDim2.new(1, 0, 1, 0)
BgOverlay.BackgroundColor3 = Theme.Background
BgOverlay.BackgroundTransparency = 0.05
BgOverlay.BorderSizePixel = 0
BgOverlay.ZIndex = 1
BgOverlay.Parent = MainFrame
addCorner(BgOverlay, 14)
addGradient(BgOverlay, Theme.Background, Theme.Background2, 135)

local mainStroke = addStroke(MainFrame, Theme.Border, 1.2)
mainStroke.ZIndex = 6

-- =========================================================
-- BOLA TOGGLE
-- =========================================================
local BallBtn = Instance.new("TextButton")
BallBtn.Name = "ToggleBall"
BallBtn.Size = UDim2.new(0, BALL_SIZE, 0, BALL_SIZE)
BallBtn.Position = UDim2.new(0, 14, 0.5, -BALL_SIZE/2)
BallBtn.BackgroundColor3 = Theme.Accent
BallBtn.Text = "S"
BallBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
BallBtn.TextSize = 20
BallBtn.Font = Enum.Font.GothamBold
BallBtn.AutoButtonColor = false
BallBtn.Active = true
BallBtn.Parent = ScreenGui
addCorner(BallBtn, BALL_SIZE/2)
addStroke(BallBtn, Color3.fromRGB(255, 255, 255), 1.6, 0.25)
registerButton(BallBtn, true)

local windowOpen = false
local function setWindow(state)
    windowOpen = state
    if state then
        MainFrame.Visible = true
        MainFrame.Position = UDim2.new(HOME_POS.X.Scale, HOME_POS.X.Offset, HOME_POS.Y.Scale, HOME_POS.Y.Offset + 30)
        MainFrame.Size = UDim2.new(0, WIN_W * 0.9, 0, WIN_H * 0.9)
        tween(MainFrame, {
            Position = HOME_POS,
            Size = UDim2.new(0, WIN_W, 0, WIN_H),
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        BallBtn.Visible = false
    else
        tween(MainFrame, {
            Size = UDim2.new(0, WIN_W * 0.85, 0, WIN_H * 0.85),
        }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.2, function()
            MainFrame.Visible = false
            BallBtn.Visible = true
        end)
    end
end

local ballDragging = false
local ballDragStart, ballStartPos = nil, nil
local ballMoved = false
local ballPressTime = 0

BallBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ballDragging = true
        ballMoved = false
        ballPressTime = tick()
        ballDragStart = input.Position
        ballStartPos = BallBtn.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                ballDragging = false
                if not ballMoved and (tick() - ballPressTime) < 0.5 then
                    setWindow(true)
                end
                ballMoved = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if ballDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - ballDragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then ballMoved = true end
        BallBtn.Position = UDim2.new(
            ballStartPos.X.Scale, ballStartPos.X.Offset + delta.X,
            ballStartPos.Y.Scale, ballStartPos.Y.Offset + delta.Y
        )
    end
end)

-- =========================================================
-- HEADER
-- =========================================================
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = Theme.Sidebar
Header.BackgroundTransparency = 0.25
Header.BorderSizePixel = 0
Header.Active = true
Header.ZIndex = 3
Header.Parent = MainFrame
addCorner(Header, 14)
addGradient(Header, Theme.Sidebar, Theme.Background2, 90)

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, -28, 0, 1)
headerLine.Position = UDim2.new(0, 14, 1, -1)
headerLine.BackgroundColor3 = Theme.Border
headerLine.BorderSizePixel = 0
headerLine.BackgroundTransparency = 0.5
headerLine.ZIndex = 4
headerLine.Parent = Header

local iconFrame = Instance.new("Frame")
iconFrame.Size = UDim2.new(0, 30, 0, 30)
iconFrame.Position = UDim2.new(0, 11, 0.5, -15)
iconFrame.BackgroundColor3 = Theme.Accent
iconFrame.BorderSizePixel = 0
iconFrame.ZIndex = 4
iconFrame.Parent = Header
addCorner(iconFrame, 9)
addStroke(iconFrame, Color3.fromRGB(255, 255, 255), 1, 0.6)
registerFill(iconFrame, true)

local iconLabel = createLabel(iconFrame, "S", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(0, 0, 0), Enum.Font.GothamBold, 16)
iconLabel.TextXAlignment = Enum.TextXAlignment.Center
iconLabel.ZIndex = 4

local Title = createLabel(Header, "SZKHUB", UDim2.new(1, -150, 0, 16), UDim2.new(0, 49, 0, 11), Theme.Text, Enum.Font.GothamBold, 13)
Title.ZIndex = 4
local Subtitle = createLabel(Header, "MADE BY SZK • v1.4.0", UDim2.new(1, -150, 0, 11), UDim2.new(0, 49, 0, 27), Theme.TextDim, Enum.Font.Gotham, 8)
Subtitle.ZIndex = 4

local CenterBtn = Instance.new("TextButton")
CenterBtn.Size = UDim2.new(0, 26, 0, 26)
CenterBtn.Position = UDim2.new(1, -96, 0.5, -13)
CenterBtn.BackgroundTransparency = 1
CenterBtn.Text = "📍"
CenterBtn.TextSize = 12
CenterBtn.Font = Enum.Font.GothamMedium
CenterBtn.TextColor3 = Theme.Text
CenterBtn.ZIndex = 4
CenterBtn.Parent = Header
addCorner(CenterBtn, 7)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -66, 0.5, -13)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "−"
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamMedium
MinBtn.TextColor3 = Theme.Text
MinBtn.ZIndex = 4
MinBtn.Parent = Header
addCorner(MinBtn, 7)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -13)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Theme.Text
CloseBtn.ZIndex = 4
CloseBtn.Parent = Header
addCorner(CloseBtn, 7)

local function setupHeaderBtn(btn, hoverColor, action)
    btn.MouseEnter:Connect(function() tween(btn, {BackgroundTransparency = 0, BackgroundColor3 = hoverColor}, 0.2) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundTransparency = 1}, 0.2) end)
    btn.MouseButton1Click:Connect(action)
end

setupHeaderBtn(CenterBtn, Theme.Hover, function()
    tween(MainFrame, {Position = HOME_POS}, 0.5, Enum.EasingStyle.Back)
end)
setupHeaderBtn(CloseBtn, Theme.Close, function()
    setWindow(false)
end)
setupHeaderBtn(MinBtn, Theme.Minimize, function()
    MiniHUD.Visible = not MiniHUD.Visible
end)

local dragging = false
local dragStart = nil
local startOffsetX = 0
local startOffsetY = 0

local function isHeaderButton(target)
    if not target then return false end
    return target == CloseBtn or target == CenterBtn or target == MinBtn
        or target:IsDescendantOf(CloseBtn) or target:IsDescendantOf(CenterBtn)
        or target:IsDescendantOf(MinBtn)
end

local function startDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if input.Target and isHeaderButton(input.Target) then return end
        dragging = true
        dragStart = input.Position
        startOffsetX = MainFrame.Position.X.Offset
        startOffsetY = MainFrame.Position.Y.Offset
    end
end
local function endDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end
Header.InputBegan:Connect(startDrag)
Header.InputEnded:Connect(endDrag)
Title.InputBegan:Connect(startDrag)
Title.InputEnded:Connect(endDrag)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(0, startOffsetX + delta.X, 0, startOffsetY + delta.Y)
    end
end)

-- =========================================================
-- SIDEBAR
-- =========================================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -46)
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.35
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = MainFrame

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.Parent = Sidebar

local sidebarPad = Instance.new("UIPadding")
sidebarPad.PaddingTop = UDim.new(0, 12)
sidebarPad.PaddingLeft = UDim.new(0, 7)
sidebarPad.PaddingRight = UDim.new(0, 7)
sidebarPad.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -SIDEBAR_W, 1, -46)
ContentArea.Position = UDim2.new(0, SIDEBAR_W, 0, 46)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 3
ContentArea.Parent = MainFrame

local Pages = {}
local currentPage = "Home"

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.ZIndex = 3
    page.Visible = false
    page.Parent = ContentArea

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 9)
    pad.PaddingRight = UDim.new(0, 9)
    pad.Parent = page

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 7)
    layout.Parent = page

    Pages[name] = page
    return page
end

local HomePage = createPage("Home")
local ThemesPage = createPage("Themes")
local ConfigPage = createPage("Config")

local tabButtons = {}

local function switchPage(pageName)
    currentPage = pageName
    for name, page in pairs(Pages) do
        page.Visible = (name == pageName)
    end
    for name, btn in pairs(tabButtons) do
        local lbl = btn:FindFirstChildOfClass("TextLabel")
        if name == pageName then
            btn.BackgroundColor3 = Theme.Accent
            if lbl then lbl.TextColor3 = Theme.Accent2 end
        else
            btn.BackgroundColor3 = Theme.Sidebar
            if lbl then lbl.TextColor3 = Theme.TextDim end
        end
    end
end

local tabs = {
    {name = "Home",   icon = "🏠"},
    {name = "Themes", icon = "🎨"},
    {name = "Config", icon = "⚙️"},
}

for _, tabData in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Name = tabData.name .. "Tab"
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Theme.Sidebar
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = (#tabButtons + 1)
    btn.ZIndex = 4
    btn.Parent = Sidebar
    addCorner(btn, 9)

    local lbl = createLabel(btn, "  " .. tabData.icon .. "  " .. tabData.name, UDim2.new(1, 0, 1, 0), UDim2.new(0, 5, 0, 0), Theme.TextDim, Enum.Font.GothamBold, 12)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 4

    btn.MouseEnter:Connect(function()
        if currentPage ~= tabData.name then
            tween(btn, {BackgroundColor3 = Theme.Hover}, 0.15)
            tween(lbl, {TextColor3 = Theme.Text}, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentPage ~= tabData.name then
            tween(btn, {BackgroundColor3 = Theme.Sidebar}, 0.15)
            tween(lbl, {TextColor3 = Theme.TextDim}, 0.15)
        end
    end)
    btn.MouseButton1Click:Connect(function() switchPage(tabData.name) end)

    tabButtons[tabData.name] = btn
end

-- =========================================================
-- PÁGINA HOME
-- =========================================================
local HomeTitle = createLabel(HomePage, "🏠  HOME", UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 0), Theme.Accent, Enum.Font.GothamBold, 11)
HomeTitle.ZIndex = 4
registerLabel(HomeTitle, true)

local WelcomeFrame = Instance.new("Frame")
WelcomeFrame.Size = UDim2.new(1, 0, 0, 72)
WelcomeFrame.BackgroundColor3 = Theme.Card
WelcomeFrame.BackgroundTransparency = 0.2
WelcomeFrame.BorderSizePixel = 0
WelcomeFrame.LayoutOrder = 1
WelcomeFrame.ZIndex = 4
WelcomeFrame.Parent = HomePage
addCorner(WelcomeFrame, 12)
addStroke(WelcomeFrame, Theme.Border, 1, 0.4)
addGradient(WelcomeFrame, Theme.Card, Theme.Background2, 90)

createLabel(WelcomeFrame, "Bienvenido", UDim2.new(1, -85, 0, 12), UDim2.new(0, 13, 0, 9), Theme.TextMuted, Enum.Font.GothamMedium, 9).ZIndex = 5
createLabel(WelcomeFrame, LocalPlayer.DisplayName or "Usuario", UDim2.new(1, -85, 0, 18), UDim2.new(0, 13, 0, 23), Theme.Text, Enum.Font.GothamBold, 13).ZIndex = 5
createLabel(WelcomeFrame, "@" .. LocalPlayer.Name, UDim2.new(1, -85, 0, 11), UDim2.new(0, 13, 0, 43), Theme.TextDim, Enum.Font.Gotham, 8).ZIndex = 5

local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.new(0, 54, 0, 54)
AvatarFrame.Position = UDim2.new(1, -67, 0.5, -27)
AvatarFrame.BackgroundColor3 = Theme.Card
AvatarFrame.BorderSizePixel = 0
AvatarFrame.ZIndex = 5
AvatarFrame.Parent = WelcomeFrame
addCorner(AvatarFrame, 10)
addStroke(AvatarFrame, Theme.Accent, 1.6, 0.15, true)

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(1, -4, 1, -4)
AvatarImg.Position = UDim2.new(0, 2, 0, 2)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
AvatarImg.ZIndex = 5
AvatarImg.Parent = AvatarFrame
addCorner(AvatarImg, 9)

-- =========================================================
-- GAME INFO CARD
-- =========================================================
local GameInfoCard = Instance.new("Frame")
GameInfoCard.Size = UDim2.new(1, 0, 0, 86)
GameInfoCard.BackgroundColor3 = Theme.Card
GameInfoCard.BackgroundTransparency = 0.2
GameInfoCard.BorderSizePixel = 0
GameInfoCard.LayoutOrder = 1.5
GameInfoCard.ZIndex = 4
GameInfoCard.Parent = HomePage
addCorner(GameInfoCard, 12)
addStroke(GameInfoCard, Theme.Border, 1, 0.4)
addGradient(GameInfoCard, Theme.Card, Theme.Background2, 90)

local gameTitle = createLabel(GameInfoCard, "🎮  JUEGO ACTUAL", UDim2.new(1, -20, 0, 16), UDim2.new(0, 13, 0, 9), Theme.Accent, Enum.Font.GothamBold, 10)
gameTitle.ZIndex = 5
registerLabel(gameTitle, true)

local gameIconFrame = Instance.new("Frame")
gameIconFrame.Size = UDim2.new(0, 50, 0, 50)
gameIconFrame.Position = UDim2.new(0, 11, 0, 30)
gameIconFrame.BackgroundColor3 = Theme.Background2
gameIconFrame.BackgroundTransparency = 0.2
gameIconFrame.BorderSizePixel = 0
gameIconFrame.ZIndex = 5
gameIconFrame.Parent = GameInfoCard
addCorner(gameIconFrame, 10)
addStroke(gameIconFrame, Theme.Accent, 1.4, 0.2, true)

local gameIcon = Instance.new("ImageLabel")
gameIcon.Size = UDim2.new(1, -4, 1, -4)
gameIcon.Position = UDim2.new(0, 2, 0, 2)
gameIcon.BackgroundTransparency = 1
gameIcon.Image = ""
gameIcon.ZIndex = 6
gameIcon.Parent = gameIconFrame
addCorner(gameIcon, 8)

local gameNameLbl = createLabel(GameInfoCard, "Cargando...", UDim2.new(1, -80, 0, 16), UDim2.new(0, 70, 0, 32), Theme.Text, Enum.Font.GothamBold, 11)
gameNameLbl.ZIndex = 5

local gameIdLbl = createLabel(GameInfoCard, "ID: ...", UDim2.new(1, -80, 0, 12), UDim2.new(0, 70, 0, 50), Theme.TextMuted, Enum.Font.Gotham, 8)
gameIdLbl.ZIndex = 5

task.spawn(function()
    local placeId = game.PlaceId
    local universeId = game.GameId

    gameIdLbl.Text = "ID: " .. tostring(placeId)

    local info = getGameInfo(placeId)
    local realName = info and info.name

    if not realName and universeId and universeId > 0 then
        local ok2, info2 = pcall(function()
            return MarketplaceService:GetProductInfo(universeId, Enum.InfoType.Game)
        end)
        if ok2 and info2 and info2.Name and info2.Name ~= "" and info2.Name ~= "UGC" then
            realName = info2.Name
        end
    end

    if not realName or realName == "" then
        realName = game.Name or "Juego desconocido"
    end

    gameNameLbl.Text = realName

    if universeId and universeId > 0 then
        gameIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(universeId) .. "&w=150&h=150"
    else
        gameIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(placeId) .. "&w=150&h=150"
    end
end)

-- =========================================================
-- SERVER INFO CARD
-- =========================================================
local ServerCard = Instance.new("Frame")
ServerCard.Size = UDim2.new(1, 0, 0, 72)
ServerCard.BackgroundColor3 = Theme.Card
ServerCard.BackgroundTransparency = 0.2
ServerCard.BorderSizePixel = 0
ServerCard.LayoutOrder = 1.6
ServerCard.ZIndex = 4
ServerCard.Parent = HomePage
addCorner(ServerCard, 12)
addStroke(ServerCard, Theme.Border, 1, 0.4)
addGradient(ServerCard, Theme.Card, Theme.Background2, 90)

local serverTitle = createLabel(ServerCard, "🌐  SERVER INFO", UDim2.new(1, -20, 0, 16), UDim2.new(0, 13, 0, 9), Theme.Accent, Enum.Font.GothamBold, 10)
serverTitle.ZIndex = 5
registerLabel(serverTitle, true)

local playersIcon = createLabel(ServerCard, "👥", UDim2.new(0, 20, 0, 20), UDim2.new(0, 13, 0, 32), Theme.Text, Enum.Font.GothamBold, 12)
playersIcon.TextXAlignment = Enum.TextXAlignment.Center
playersIcon.ZIndex = 5

local playersValue = createLabel(ServerCard, "0/0", UDim2.new(0, 60, 0, 16), UDim2.new(0, 34, 0, 34), Theme.Text, Enum.Font.GothamBold, 12)
playersValue.ZIndex = 5

local playersLbl = createLabel(ServerCard, "Jugadores", UDim2.new(0, 60, 0, 10), UDim2.new(0, 34, 0, 50), Theme.TextMuted, Enum.Font.Gotham, 7)
playersLbl.ZIndex = 5

local serverDivider = Instance.new("Frame")
serverDivider.Size = UDim2.new(0, 1, 0, 30)
serverDivider.Position = UDim2.new(0, 105, 0.5, -15)
serverDivider.BackgroundColor3 = Theme.Border
serverDivider.BorderSizePixel = 0
serverDivider.BackgroundTransparency = 0.5
serverDivider.ZIndex = 5
serverDivider.Parent = ServerCard

local timeIcon = createLabel(ServerCard, "⏱️", UDim2.new(0, 20, 0, 20), UDim2.new(0, 118, 0, 32), Theme.Text, Enum.Font.GothamBold, 12)
timeIcon.TextXAlignment = Enum.TextXAlignment.Center
timeIcon.ZIndex = 5

local timeValue = createLabel(ServerCard, "00:00:00", UDim2.new(0, 120, 0, 16), UDim2.new(0, 140, 0, 34), Theme.Cyan, Enum.Font.GothamBold, 12)
timeValue.ZIndex = 5

local timeLbl = createLabel(ServerCard, "Tiempo del server", UDim2.new(0, 120, 0, 10), UDim2.new(0, 140, 0, 50), Theme.TextMuted, Enum.Font.Gotham, 7)
timeLbl.ZIndex = 5

task.spawn(function()
    while ServerCard.Parent do
        local count = #Players:GetPlayers()
        local max = Players.MaxPlayers
        playersValue.Text = tostring(count) .. "/" .. tostring(max)
        if count >= max * 0.8 then
            playersValue.TextColor3 = Theme.Close
        elseif count >= max * 0.5 then
            playersValue.TextColor3 = Theme.Warning
        else
            playersValue.TextColor3 = Theme.Success
        end
        task.wait(2)
    end
end)

task.spawn(function()
    task.wait(1)
    while ServerCard.Parent do
        local serverTime = nil
        local ok = pcall(function()
            serverTime = Workspace.DistributedGameTime
        end)

        if ok and serverTime then
            local hours = math.floor(serverTime / 3600)
            local minutes = math.floor((serverTime % 3600) / 60)
            local seconds = math.floor(serverTime % 60)
            timeValue.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        else
            if not timeValue:GetAttribute("FallbackStart") then
                timeValue:SetAttribute("FallbackStart", tick())
            end
            local elapsed = tick() - timeValue:GetAttribute("FallbackStart")
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = math.floor(elapsed % 60)
            timeValue.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end

        task.wait(1)
    end
end)

-- =========================================================
-- STAFF ONLINE CARD
-- =========================================================
local StaffCard = Instance.new("Frame")
StaffCard.Size = UDim2.new(1, 0, 0, 72)
StaffCard.BackgroundColor3 = Theme.Card
StaffCard.BackgroundTransparency = 0.2
StaffCard.BorderSizePixel = 0
StaffCard.LayoutOrder = 1.7
StaffCard.ZIndex = 4
StaffCard.Parent = HomePage
addCorner(StaffCard, 12)
addStroke(StaffCard, Theme.Border, 1, 0.4)
addGradient(StaffCard, Theme.Card, Theme.Background2, 90)

local staffTitle = createLabel(StaffCard, "👑  STAFF ONLINE", UDim2.new(1, -20, 0, 16), UDim2.new(0, 13, 0, 9), Theme.Accent, Enum.Font.GothamBold, 10)
staffTitle.ZIndex = 5
registerLabel(staffTitle, true)

local StaffList = Instance.new("Frame")
StaffList.Size = UDim2.new(1, -22, 0, 40)
StaffList.Position = UDim2.new(0, 11, 0, 28)
StaffList.BackgroundTransparency = 1
StaffList.ZIndex = 5
StaffList.Parent = StaffCard

local StaffLayout = Instance.new("UIListLayout")
StaffLayout.SortOrder = Enum.SortOrder.LayoutOrder
StaffLayout.Padding = UDim.new(0, 4)
StaffLayout.Parent = StaffList

local function createStaffRow(staffData)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Theme.Background2
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.ZIndex = 6
    row.Parent = StaffList
    addCorner(row, 8)
    addStroke(row, staffData.color, 1, 0.4)

    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 28, 0, 28)
    avatarFrame.Position = UDim2.new(0, 4, 0.5, -14)
    avatarFrame.BackgroundColor3 = Theme.Card
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ZIndex = 7
    avatarFrame.Parent = row
    addCorner(avatarFrame, 7)
    addStroke(avatarFrame, staffData.color, 1.2, 0.1)

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(1, -4, 1, -4)
    avatarImg.Position = UDim2.new(0, 2, 0, 2)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150"
    avatarImg.ZIndex = 7
    avatarImg.Parent = avatarFrame
    addCorner(avatarImg, 6)

    local nameLbl = createLabel(row, staffData.display, UDim2.new(0, 90, 0, 12), UDim2.new(0, 38, 0, 4), Theme.Text, Enum.Font.GothamBold, 9)
    nameLbl.ZIndex = 7

    local gameLbl = createLabel(row, "Detectando...", UDim2.new(0, 90, 0, 10), UDim2.new(0, 38, 0, 19), Theme.TextMuted, Enum.Font.Gotham, 7)
    gameLbl.ZIndex = 7

    local statusBadge = Instance.new("Frame")
    statusBadge.Size = UDim2.new(0, 60, 0, 18)
    statusBadge.Position = UDim2.new(1, -66, 0.5, -9)
    statusBadge.BackgroundColor3 = Theme.TextMuted
    statusBadge.BackgroundTransparency = 0.85
    statusBadge.BorderSizePixel = 0
    statusBadge.ZIndex = 7
    statusBadge.Parent = row
    addCorner(statusBadge, 5)
    addStroke(statusBadge, Theme.TextMuted, 1, 0.3)

    local statusLbl = createLabel(statusBadge, "OFFLINE", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Theme.TextMuted, Enum.Font.GothamBold, 7)
    statusLbl.TextXAlignment = Enum.TextXAlignment.Center
    statusLbl.ZIndex = 7

    local gameIconFrame = Instance.new("Frame")
    gameIconFrame.Size = UDim2.new(0, 24, 0, 24)
    gameIconFrame.Position = UDim2.new(1, -94, 0.5, -12)
    gameIconFrame.BackgroundColor3 = Theme.Card
    gameIconFrame.BorderSizePixel = 0
    gameIconFrame.ZIndex = 7
    gameIconFrame.Parent = row
    addCorner(gameIconFrame, 6)
    addStroke(gameIconFrame, staffData.color, 1, 0.3)

    local gameMiniIcon = Instance.new("ImageLabel")
    gameMiniIcon.Size = UDim2.new(1, -2, 1, -2)
    gameMiniIcon.Position = UDim2.new(0, 1, 0, 1)
    gameMiniIcon.BackgroundTransparency = 1
    gameMiniIcon.Image = ""
    gameMiniIcon.ZIndex = 8
    gameMiniIcon.Parent = gameIconFrame
    addCorner(gameMiniIcon, 5)

    task.spawn(function()
        while row.Parent do
            local targetPlayer = nil
            for _, plr in ipairs(Players:GetPlayers()) do
                if string.lower(plr.Name) == string.lower(staffData.name) or string.lower(plr.DisplayName) == string.lower(staffData.display) then
                    targetPlayer = plr
                    break
                end
            end

            if targetPlayer then
                avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. targetPlayer.UserId .. "&w=150&h=150"
                statusBadge.BackgroundColor3 = Theme.Success
                statusBadge.BackgroundTransparency = 0.8
                statusLbl.Text = "ONLINE"
                statusLbl.TextColor3 = Theme.Success

                local ok, placeId = pcall(function()
                    return Players:GetPlayerPlaceInstanceAsync(targetPlayer.UserId)
                end)

                if ok and placeId then
                    local info = getGameInfo(placeId)
                    gameLbl.Text = (info and info.name) or ("Juego ID: " .. tostring(placeId))

                    local universeId = info and info.universeId
                    if universeId and universeId > 0 then
                        gameMiniIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(universeId) .. "&w=150&h=150"
                    else
                        gameMiniIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(placeId) .. "&w=150&h=150"
                    end
                else
                    gameLbl.Text = "En el mismo juego"
                    local currentUniverseId = game.GameId
                    if currentUniverseId and currentUniverseId > 0 then
                        gameMiniIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(currentUniverseId) .. "&w=150&h=150"
                    else
                        gameMiniIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.PlaceId) .. "&w=150&h=150"
                    end
                end
            else
                avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150"
                statusBadge.BackgroundColor3 = Theme.TextMuted
                statusBadge.BackgroundTransparency = 0.85
                statusLbl.Text = "OFFLINE"
                statusLbl.TextColor3 = Theme.TextMuted
                gameLbl.Text = "No conectado"
                gameMiniIcon.Image = ""
            end

            task.wait(5)
        end
    end)
end

for _, staffData in ipairs(STAFF_LIST) do
    createStaffRow(staffData)
end

task.spawn(function()
    while StaffCard.Parent do
        task.wait(0.5)
        local count = #STAFF_LIST
        local newHeight = 28 + (count * 40) + 8
        if StaffCard.Size.Y.Offset ~= newHeight then
            tween(StaffCard, {Size = UDim2.new(1, 0, 0, newHeight)}, 0.3)
        end
    end
end)

-- =========================================================
-- PÁGINA CONFIGURACIÓN (Toggles: FPS, Ping, Anti-AFK)
-- =========================================================
local ConfigTitle = createLabel(ConfigPage, "⚙️  CONFIGURACIÓN", UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 0), Theme.Accent, Enum.Font.GothamBold, 11)
ConfigTitle.ZIndex = 4
registerLabel(ConfigTitle, true)

local BoosterCard = Instance.new("Frame")
BoosterCard.Size = UDim2.new(1, 0, 0, 136)
BoosterCard.BackgroundColor3 = Theme.Card
BoosterCard.BackgroundTransparency = 0.2
BoosterCard.BorderSizePixel = 0
BoosterCard.LayoutOrder = 1
BoosterCard.ZIndex = 4
BoosterCard.Parent = ConfigPage
addCorner(BoosterCard, 12)
addStroke(BoosterCard, Theme.Border, 1, 0.4)
addGradient(BoosterCard, Theme.Card, Theme.Background2, 90)

local boosterTitle = createLabel(BoosterCard, "🚀  BOOSTER", UDim2.new(1, -20, 0, 18), UDim2.new(0, 13, 0, 11), Theme.Accent, Enum.Font.GothamBold, 10)
boosterTitle.ZIndex = 5
registerLabel(boosterTitle, true)

local function MakeBoosterButton(title, desc, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -22, 0, 46)
    btn.Position = UDim2.new(0, 11, 0, yPos)
    btn.BackgroundColor3 = Theme.Background2
    btn.BackgroundTransparency = 0.25
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 5
    btn.Parent = BoosterCard
    addCorner(btn, 10)
    addStroke(btn, color, 1.1, 0.4)

    local iconBox = Instance.new("Frame")
    iconBox.Size = UDim2.new(0, 24, 0, 24)
    iconBox.Position = UDim2.new(0, 9, 0.5, -12)
    iconBox.BackgroundColor3 = color
    iconBox.BackgroundTransparency = 0.85
    iconBox.BorderSizePixel = 0
    iconBox.ZIndex = 6
    iconBox.Parent = btn
    addCorner(iconBox, 7)

    local iconTxt = createLabel(iconBox, "⚡", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), color, Enum.Font.GothamBold, 11)
    iconTxt.TextXAlignment = Enum.TextXAlignment.Center
    iconTxt.ZIndex = 6

    createLabel(btn, title, UDim2.new(1, -70, 0, 14), UDim2.new(0, 40, 0, 7), Theme.Text, Enum.Font.GothamBold, 10).ZIndex = 6
    createLabel(btn, desc, UDim2.new(1, -70, 0, 11), UDim2.new(0, 40, 0, 24), Theme.TextMuted, Enum.Font.Gotham, 7).ZIndex = 6

    local stateLbl = createLabel(btn, "OFF", UDim2.new(0, 34, 0, 14), UDim2.new(1, -42, 0, 16), Theme.TextMuted, Enum.Font.GothamBold, 9)
    stateLbl.TextXAlignment = Enum.TextXAlignment.Right
    stateLbl.ZIndex = 6

    local active = false
    local busy = false

    local function setState(newState, fireCallback)
        if busy then return end
        active = newState
        if active then
            stateLbl.Text = "ON"
            stateLbl.TextColor3 = color
            iconBox.BackgroundTransparency = 0.5
        else
            stateLbl.Text = "OFF"
            stateLbl.TextColor3 = Theme.TextMuted
            iconBox.BackgroundTransparency = 0.85
        end
        if fireCallback and callback then
            busy = true
            task.spawn(function()
                callback(active)
                task.wait(0.3)
                busy = false
            end)
        end
    end

    btn.MouseEnter:Connect(function() tween(btn, {BackgroundTransparency = 0.1}, 0.2) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundTransparency = 0.25}, 0.2) end)
    btn.MouseButton1Click:Connect(function()
        setState(not active, true)
    end)

    return btn, stateLbl, iconBox, setState
end

MakeBoosterButton("FPS Booster", "Optimiza gráficos", 34, Theme.Success, function(state) end)
MakeBoosterButton("Ping Booster", "Optimiza la red", 84, Theme.Cyan, function(state) end)

local AntiAfkButton, AntiAfkStateLbl, AntiAfkIconBox, AntiAfkSetState

-- =========================================================
-- ANTI-AFK SYSTEM + PANEL FLOTANTE MINI
-- =========================================================
local antiAfkActive = false
local antiAfkStartTime = 0
local antiAfkConnections = {}

local function formatTime(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return days, hours, minutes, secs
end

local function stopAntiAfk()
    antiAfkActive = false
    for _, conn in ipairs(antiAfkConnections) do
        pcall(function() conn:Disconnect() end)
    end
    antiAfkConnections = {}
end

local function startAntiAfk()
    if antiAfkActive then return end
    antiAfkActive = true
    antiAfkStartTime = tick()

    table.insert(antiAfkConnections, LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end))

    task.spawn(function()
        while antiAfkActive do
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
            end)
            task.wait(60)
        end
    end)
end

-- Panel flotante
local AntiAfkPanel = Instance.new("Frame")
AntiAfkPanel.Name = "AntiAfkPanel"
AntiAfkPanel.Size = UDim2.new(0, 160, 0, 0)
AntiAfkPanel.Position = UDim2.new(1, -180, 0, 20)
AntiAfkPanel.BackgroundColor3 = Theme.Card
AntiAfkPanel.BackgroundTransparency = 0.05
AntiAfkPanel.BorderSizePixel = 0
AntiAfkPanel.ClipsDescendants = true
AntiAfkPanel.Visible = false
AntiAfkPanel.Active = true
AntiAfkPanel.ZIndex = 500
AntiAfkPanel.Parent = ScreenGui
addCorner(AntiAfkPanel, 10)

local antiPanelStroke = Instance.new("UIStroke")
antiPanelStroke.Color = Theme.Purple
antiPanelStroke.Thickness = 1.4
antiPanelStroke.Transparency = 0.2
antiPanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
antiPanelStroke.Parent = AntiAfkPanel

local antiPanelGradient = Instance.new("UIGradient")
antiPanelGradient.Color = ColorSequence.new(Theme.Card, Theme.Background2)
antiPanelGradient.Rotation = 90
antiPanelGradient.Parent = AntiAfkPanel

local panelHeader = Instance.new("Frame")
panelHeader.Size = UDim2.new(1, 0, 0, 22)
panelHeader.BackgroundTransparency = 1
panelHeader.Active = true
panelHeader.ZIndex = 501
panelHeader.Parent = AntiAfkPanel

local pulseDot = Instance.new("Frame")
pulseDot.Size = UDim2.new(0, 7, 0, 7)
pulseDot.Position = UDim2.new(0, 8, 0, 7)
pulseDot.BackgroundColor3 = Theme.Success
pulseDot.BorderSizePixel = 0
pulseDot.ZIndex = 502
pulseDot.Parent = panelHeader
addCorner(pulseDot, 4)

local pulseGlow = Instance.new("UIStroke")
pulseGlow.Color = Theme.Success
pulseGlow.Thickness = 1.6
pulseGlow.Transparency = 0.4
pulseGlow.Parent = pulseDot

local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, -70, 0, 10)
panelTitle.Position = UDim2.new(0, 20, 0, 3)
panelTitle.BackgroundTransparency = 1
panelTitle.Text = "ANTI-AFK"
panelTitle.TextColor3 = Theme.Success
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextSize = 8
panelTitle.TextXAlignment = Enum.TextXAlignment.Left
panelTitle.ZIndex = 502
panelTitle.Parent = panelHeader

local panelMadeBy = Instance.new("TextLabel")
panelMadeBy.Size = UDim2.new(1, -70, 0, 8)
panelMadeBy.Position = UDim2.new(0, 20, 0, 12)
panelMadeBy.BackgroundTransparency = 1
panelMadeBy.Text = "MADE BY SZK"
panelMadeBy.TextColor3 = Theme.TextMuted
panelMadeBy.Font = Enum.Font.GothamBold
panelMadeBy.TextSize = 6
panelMadeBy.TextXAlignment = Enum.TextXAlignment.Left
panelMadeBy.ZIndex = 502
panelMadeBy.Parent = panelHeader

local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 18, 0, 18)
collapseBtn.Position = UDim2.new(1, -42, 0, 2)
collapseBtn.BackgroundTransparency = 1
collapseBtn.Text = "−"
collapseBtn.TextSize = 14
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.TextColor3 = Theme.TextDim
collapseBtn.AutoButtonColor = false
collapseBtn.ZIndex = 502
collapseBtn.Parent = panelHeader
addCorner(collapseBtn, 5)

collapseBtn.MouseEnter:Connect(function()
    tween(collapseBtn, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Hover}, 0.15)
    tween(collapseBtn, {TextColor3 = Theme.Text}, 0.15)
end)
collapseBtn.MouseLeave:Connect(function()
    tween(collapseBtn, {BackgroundTransparency = 1}, 0.15)
    tween(collapseBtn, {TextColor3 = Theme.TextDim}, 0.15)
end)

local closeBtnPanel = Instance.new("TextButton")
closeBtnPanel.Size = UDim2.new(0, 18, 0, 18)
closeBtnPanel.Position = UDim2.new(1, -21, 0, 2)
closeBtnPanel.BackgroundTransparency = 1
closeBtnPanel.Text = "✕"
closeBtnPanel.TextSize = 10
closeBtnPanel.Font = Enum.Font.GothamBold
closeBtnPanel.TextColor3 = Theme.TextDim
closeBtnPanel.AutoButtonColor = false
closeBtnPanel.ZIndex = 502
closeBtnPanel.Parent = panelHeader
addCorner(closeBtnPanel, 5)

closeBtnPanel.MouseEnter:Connect(function()
    tween(closeBtnPanel, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Close}, 0.15)
    tween(closeBtnPanel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
end)
closeBtnPanel.MouseLeave:Connect(function()
    tween(closeBtnPanel, {BackgroundTransparency = 1}, 0.15)
    tween(closeBtnPanel, {TextColor3 = Theme.TextDim}, 0.15)
end)

local reopenBtn = Instance.new("TextButton")
reopenBtn.Name = "AntiAfkReopen"
reopenBtn.Size = UDim2.new(0, 28, 0, 28)
reopenBtn.Position = UDim2.new(1, -44, 0, 20)
reopenBtn.BackgroundColor3 = Theme.Card
reopenBtn.BackgroundTransparency = 0.05
reopenBtn.Text = "🛡️"
reopenBtn.TextSize = 13
reopenBtn.Font = Enum.Font.GothamBold
reopenBtn.AutoButtonColor = false
reopenBtn.Visible = false
reopenBtn.ZIndex = 500
reopenBtn.Parent = ScreenGui
addCorner(reopenBtn, 8)

local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = Theme.Purple
reopenStroke.Thickness = 1.3
reopenStroke.Transparency = 0.2
reopenStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
reopenStroke.Parent = reopenBtn

reopenBtn.MouseEnter:Connect(function()
    tween(reopenBtn, {BackgroundColor3 = Theme.Purple}, 0.15)
    tween(reopenBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
end)
reopenBtn.MouseLeave:Connect(function()
    tween(reopenBtn, {BackgroundColor3 = Theme.Card}, 0.15)
    tween(reopenBtn, {TextColor3 = Theme.Text}, 0.15)
end)

local panelSep = Instance.new("Frame")
panelSep.Size = UDim2.new(1, -14, 0, 1)
panelSep.Position = UDim2.new(0, 7, 0, 24)
panelSep.BackgroundColor3 = Theme.Border
panelSep.BackgroundTransparency = 0.5
panelSep.BorderSizePixel = 0
panelSep.ZIndex = 501
panelSep.Parent = AntiAfkPanel

local timeContainer = Instance.new("Frame")
timeContainer.Size = UDim2.new(1, -12, 0, 40)
timeContainer.Position = UDim2.new(0, 6, 0, 28)
timeContainer.BackgroundTransparency = 1
timeContainer.ZIndex = 501
timeContainer.Parent = AntiAfkPanel

local timeGrid = Instance.new("UIListLayout")
timeGrid.FillDirection = Enum.FillDirection.Horizontal
timeGrid.SortOrder = Enum.SortOrder.LayoutOrder
timeGrid.Padding = UDim.new(0, 3)
timeGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
timeGrid.VerticalAlignment = Enum.VerticalAlignment.Center
timeGrid.Parent = timeContainer

local function makeTimeBox(order, label)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 34, 0, 36)
    box.BackgroundColor3 = Theme.Background2
    box.BackgroundTransparency = 0.2
    box.BorderSizePixel = 0
    box.LayoutOrder = order
    box.ZIndex = 502
    box.Parent = timeContainer
    addCorner(box, 6)

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Theme.Purple
    boxStroke.Thickness = 1
    boxStroke.Transparency = 0.5
    boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    boxStroke.Parent = box

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(1, 0, 0, 18)
    valLbl.Position = UDim2.new(0, 0, 0, 3)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = "00"
    valLbl.TextColor3 = Theme.Purple
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.ZIndex = 503
    valLbl.Parent = box

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, 0, 0, 9)
    nameLbl.Position = UDim2.new(0, 0, 0, 24)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = label
    nameLbl.TextColor3 = Theme.TextMuted
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 6
    nameLbl.ZIndex = 503
    nameLbl.Parent = box

    return valLbl
end

local daysLbl = makeTimeBox(1, "DÍAS")
local hoursLbl = makeTimeBox(2, "HRS")
local minsLbl = makeTimeBox(3, "MIN")
local secsLbl = makeTimeBox(4, "SEG")

local panelState = "closed"

local function updateCollapseVisual()
    if panelState == "collapsed" then
        collapseBtn.Text = "＋"
    else
        collapseBtn.Text = "−"
    end
end

collapseBtn.MouseButton1Click:Connect(function()
    if panelState == "open" then
        panelState = "collapsed"
        updateCollapseVisual()
        tween(AntiAfkPanel, {Size = UDim2.new(0, 160, 0, 22)}, 0.3, Enum.EasingStyle.Quint)
    elseif panelState == "collapsed" then
        panelState = "open"
        updateCollapseVisual()
        tween(AntiAfkPanel, {Size = UDim2.new(0, 160, 0, 72)}, 0.3, Enum.EasingStyle.Back)
    end
end)

closeBtnPanel.MouseButton1Click:Connect(function()
    panelState = "closed"
    tween(AntiAfkPanel, {Size = UDim2.new(0, 160, 0, 0)}, 0.25, Enum.EasingStyle.Quint)
    task.delay(0.25, function()
        AntiAfkPanel.Visible = false
    end)

    reopenBtn.Position = UDim2.new(
        AntiAfkPanel.Position.X.Scale, AntiAfkPanel.Position.X.Offset + 132,
        AntiAfkPanel.Position.Y.Scale, AntiAfkPanel.Position.Y.Offset
    )
    reopenBtn.Visible = true
    reopenBtn.Size = UDim2.new(0, 0, 0, 28)
    tween(reopenBtn, {Size = UDim2.new(0, 28, 0, 28)}, 0.3, Enum.EasingStyle.Back)
end)

reopenBtn.MouseButton1Click:Connect(function()
    reopenBtn.Visible = false
    AntiAfkPanel.Visible = true
    panelState = "open"
    updateCollapseVisual()
    AntiAfkPanel.Size = UDim2.new(0, 160, 0, 0)
    tween(AntiAfkPanel, {Size = UDim2.new(0, 160, 0, 72)}, 0.35, Enum.EasingStyle.Back)
end)

local panelDragging = false
local panelDragStart = nil
local panelStartPos = nil

local function isPanelBtn(target)
    if not target then return false end
    return target == collapseBtn or target == closeBtnPanel
        or target:IsDescendantOf(collapseBtn) or target:IsDescendantOf(closeBtnPanel)
end

panelHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if input.Target and isPanelBtn(input.Target) then return end
        panelDragging = true
        panelDragStart = input.Position
        panelStartPos = AntiAfkPanel.Position
    end
end)

panelHeader.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        panelDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if panelDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - panelDragStart
        AntiAfkPanel.Position = UDim2.new(
            panelStartPos.X.Scale, panelStartPos.X.Offset + delta.X,
            panelStartPos.Y.Scale, panelStartPos.Y.Offset + delta.Y
        )
        if reopenBtn.Visible then
            reopenBtn.Position = UDim2.new(
                AntiAfkPanel.Position.X.Scale, AntiAfkPanel.Position.X.Offset + 132,
                AntiAfkPanel.Position.Y.Scale, AntiAfkPanel.Position.Y.Offset
            )
        end
    end
end)

task.spawn(function()
    while AntiAfkPanel.Parent do
        task.wait(1)
        if antiAfkActive then
            local elapsed = tick() - antiAfkStartTime
            local d, h, m, s = formatTime(elapsed)
            daysLbl.Text = string.format("%02d", d)
            hoursLbl.Text = string.format("%02d", h)
            minsLbl.Text = string.format("%02d", m)
            secsLbl.Text = string.format("%02d", s)
        end
    end
end)

task.spawn(function()
    while AntiAfkPanel.Parent do
        if antiAfkActive and AntiAfkPanel.Visible then
            tween(pulseGlow, {Transparency = 0.9}, 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tween(pulseDot, {BackgroundColor3 = Color3.fromRGB(100, 255, 180)}, 0.7)
            task.wait(0.7)
            tween(pulseGlow, {Transparency = 0.2}, 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tween(pulseDot, {BackgroundColor3 = Theme.Success}, 0.7)
            task.wait(0.7)
        else
            task.wait(0.5)
        end
    end
end)

AntiAfkButton, AntiAfkStateLbl, AntiAfkIconBox, AntiAfkSetState = MakeBoosterButton(
    "Anti-AFK",
    "Evita el kick por inactividad",
    134,
    Theme.Purple,
    function(state)
        if state then
            startAntiAfk()
            reopenBtn.Visible = false
            AntiAfkPanel.Visible = true
            panelState = "open"
            updateCollapseVisual()
            AntiAfkPanel.Size = UDim2.new(0, 160, 0, 0)
            task.wait(0.02)
            tween(AntiAfkPanel, {Size = UDim2.new(0, 160, 0, 72)}, 0.4, Enum.EasingStyle.Back)
        else
            stopAntiAfk()
            reopenBtn.Visible = false
            tween(AntiAfkPanel, {Size = UDim2.new(0, 160, 0, 0)}, 0.25, Enum.EasingStyle.Quint)
            task.delay(0.25, function()
                AntiAfkPanel.Visible = false
                panelState = "closed"
            end)
        end
    end
)

-- =========================================================
-- PÁGINA HOME - CREDITS CARD
-- =========================================================
local CreditsCard = Instance.new("Frame")
CreditsCard.Size = UDim2.new(1, 0, 0, 180)
CreditsCard.BackgroundColor3 = Theme.Card
CreditsCard.BackgroundTransparency = 0.2
CreditsCard.BorderSizePixel = 0
CreditsCard.LayoutOrder = 2
CreditsCard.ZIndex = 4
CreditsCard.Parent = HomePage
addCorner(CreditsCard, 12)
addStroke(CreditsCard, Theme.Border, 1, 0.4)
addGradient(CreditsCard, Theme.Card, Theme.Background2, 90)

local creditsTitle = createLabel(CreditsCard, "👑  CREDITS", UDim2.new(1, -20, 0, 18), UDim2.new(0, 13, 0, 11), Theme.Accent, Enum.Font.GothamBold, 10)
creditsTitle.ZIndex = 5
registerLabel(creditsTitle, true)

local function MakeCreditRow(parent, yPos, userId, roleText, roleColor)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -22, 0, 44)
    row.Position = UDim2.new(0, 11, 0, yPos)
    row.BackgroundColor3 = Theme.Background2
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.ZIndex = 5
    row.Parent = parent
    addCorner(row, 9)
    addStroke(row, roleColor, 1.1, 0.5)

    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 34, 0, 34)
    avatarFrame.Position = UDim2.new(0, 6, 0.5, -17)
    avatarFrame.BackgroundColor3 = Theme.Card
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ZIndex = 6
    avatarFrame.Parent = row
    addCorner(avatarFrame, 8)
    addStroke(avatarFrame, roleColor, 1.4, 0.1)

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(1, -4, 1, -4)
    avatarImg.Position = UDim2.new(0, 2, 0, 2)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"
    avatarImg.ZIndex = 6
    avatarImg.Parent = avatarFrame
    addCorner(avatarImg, 7)

    local nameLbl = createLabel(row, "Cargando...", UDim2.new(1, -100, 0, 14), UDim2.new(0, 46, 0, 6), Theme.Text, Enum.Font.GothamBold, 10)
    nameLbl.ZIndex = 6
    local userLbl = createLabel(row, "...", UDim2.new(1, -100, 0, 11), UDim2.new(0, 46, 0, 22), Theme.TextMuted, Enum.Font.Gotham, 8)
    userLbl.ZIndex = 6

    local roleBadge = Instance.new("Frame")
    roleBadge.Size = UDim2.new(0, 72, 0, 20)
    roleBadge.Position = UDim2.new(1, -80, 0.5, -10)
    roleBadge.BackgroundColor3 = roleColor
    roleBadge.BackgroundTransparency = 0.85
    roleBadge.BorderSizePixel = 0
    roleBadge.ZIndex = 6
    roleBadge.Parent = row
    addCorner(roleBadge, 6)
    addStroke(roleBadge, roleColor, 1, 0.3)

    local roleLbl = createLabel(roleBadge, roleText, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), roleColor, Enum.Font.GothamBold, 8)
    roleLbl.TextXAlignment = Enum.TextXAlignment.Center
    roleLbl.ZIndex = 6

    task.spawn(function()
        local success, nameResult = pcall(function() return Players:GetNameFromUserIdAsync(userId) end)
        if success and nameResult then
            nameLbl.Text = nameResult
            userLbl.Text = "@" .. nameResult
        else
            nameLbl.Text = "Usuario"
            userLbl.Text = "@" .. tostring(userId)
        end
    end)
end

MakeCreditRow(CreditsCard, 36, OWNER_ID, "👑 OWNER", Color3.fromRGB(255, 215, 0))
MakeCreditRow(CreditsCard, 86, HELPER_ID, "⚡ DEV", Color3.fromRGB(90, 225, 255))

-- =========================================================
-- DISCORD CARD (Home)
-- =========================================================
local DiscordCard = Instance.new("Frame")
DiscordCard.Size = UDim2.new(1, 0, 0, 66)
DiscordCard.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordCard.BackgroundTransparency = 0.15
DiscordCard.BorderSizePixel = 0
DiscordCard.LayoutOrder = 3
DiscordCard.ZIndex = 4
DiscordCard.Parent = HomePage
addCorner(DiscordCard, 12)
addStroke(DiscordCard, Color3.fromRGB(120, 130, 255), 1.2, 0.3)
addGradient(DiscordCard, Color3.fromRGB(88, 101, 242), Color3.fromRGB(60, 70, 180), 90)

local discordAvatar = Instance.new("Frame")
discordAvatar.Size = UDim2.new(0, 46, 0, 46)
discordAvatar.Position = UDim2.new(0, 10, 0.5, -23)
discordAvatar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
discordAvatar.BackgroundTransparency = 0.85
discordAvatar.BorderSizePixel = 0
discordAvatar.ZIndex = 5
discordAvatar.Parent = DiscordCard
addCorner(discordAvatar, 10)
addStroke(discordAvatar, Color3.fromRGB(255, 255, 255), 1.2, 0.3)

local discordImg = Instance.new("ImageLabel")
discordImg.Size = UDim2.new(1, -4, 1, -4)
discordImg.Position = UDim2.new(0, 2, 0, 2)
discordImg.BackgroundTransparency = 1
discordImg.Image = "rbxthumb://type=Asset&id=" .. DISCORD_ICON_ID .. "&w=150&h=150"
discordImg.ZIndex = 5
discordImg.Parent = discordAvatar
addCorner(discordImg, 8)

local discordTitle = createLabel(DiscordCard, "💬  ÚNETE AL DISCORD", UDim2.new(1, -100, 0, 14), UDim2.new(0, 66, 0, 10), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 10)
discordTitle.ZIndex = 5
local discordLink = createLabel(DiscordCard, DISCORD_LINK, UDim2.new(1, -100, 0, 12), UDim2.new(0, 66, 0, 28), Color3.fromRGB(220, 220, 255), Enum.Font.Gotham, 8)
discordLink.ZIndex = 5

local discordArrow = createLabel(DiscordCard, "→", UDim2.new(0, 24, 0, 24), UDim2.new(1, -32, 0.5, -12), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 18)
discordArrow.TextXAlignment = Enum.TextXAlignment.Center
discordArrow.ZIndex = 5

local discordClick = Instance.new("TextButton")
discordClick.Size = UDim2.new(1, 0, 1, 0)
discordClick.BackgroundTransparency = 1
discordClick.Text = ""
discordClick.ZIndex = 6
discordClick.Parent = DiscordCard

discordClick.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then setclipboard(DISCORD_LINK) end
    end)
end)

-- =========================================================
-- PÁGINA THEMES
-- =========================================================
local ThemesTitle = createLabel(ThemesPage, "🎨  THEMES", UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 0), Theme.Accent, Enum.Font.GothamBold, 11)
ThemesTitle.ZIndex = 4
registerLabel(ThemesTitle, true)

local ModeCard = Instance.new("Frame")
ModeCard.Size = UDim2.new(1, 0, 0, 138)
ModeCard.BackgroundColor3 = Theme.Card
ModeCard.BackgroundTransparency = 0.2
ModeCard.BorderSizePixel = 0
ModeCard.LayoutOrder = 1
ModeCard.ZIndex = 4
ModeCard.Parent = ThemesPage
addCorner(ModeCard, 12)
addStroke(ModeCard, Theme.Border, 1, 0.4)
addGradient(ModeCard, Theme.Card, Theme.Background2, 90)

local modeTitle = createLabel(ModeCard, "🎯  MODO", UDim2.new(1, -20, 0, 18), UDim2.new(0, 13, 0, 11), Theme.Accent, Enum.Font.GothamBold, 10)
modeTitle.ZIndex = 5
registerLabel(modeTitle, true)

local ModeGrid = Instance.new("Frame")
ModeGrid.Size = UDim2.new(1, -22, 0, 96)
ModeGrid.Position = UDim2.new(0, 11, 0, 37)
ModeGrid.BackgroundTransparency = 1
ModeGrid.ZIndex = 5
ModeGrid.Parent = ModeCard

local ModeLayout = Instance.new("UIGridLayout")
ModeLayout.CellSize = UDim2.new(0.5, -3, 0, 44)
ModeLayout.CellPadding = UDim2.new(0, 6, 0, 6)
ModeLayout.SortOrder = Enum.SortOrder.LayoutOrder
ModeLayout.Parent = ModeGrid

local function makeModeButton(text, order)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Theme.Background2
    btn.BackgroundTransparency = 0.25
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = Theme.TextMuted
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.ZIndex = 6
    btn.Parent = ModeGrid
    addCorner(btn, 9)
    addStroke(btn, Theme.Border, 1, 0.3)
    return btn
end

local btnBW = makeModeButton("⚫ Negro & Blanco", 1)
local btnRainbow = makeModeButton("🌈 Arcoíris", 2)
local btnNeon = makeModeButton("💚 Neón", 3)
local btnGlass = makeModeButton("🪟 Cristal", 4)

local modeButtons = {
    BW = btnBW,
    Rainbow = btnRainbow,
    Neon = btnNeon,
    Glass = btnGlass,
}

local function updateModeButtons()
    for key, btn in pairs(modeButtons) do
        if key == currentTheme then
            btn.BackgroundColor3 = Theme.Accent
            btn.TextColor3 = (key == "BW" or key == "Glass") and Theme.Accent2 or Color3.fromRGB(0, 0, 0)
            btn.BackgroundTransparency = 0
        else
            btn.BackgroundColor3 = Theme.Background2
            btn.TextColor3 = Theme.TextMuted
            btn.BackgroundTransparency = 0.25
        end
    end
end

for key, btn in pairs(modeButtons) do
    btn.MouseButton1Click:Connect(function()
        setTheme(key)
        updateModeButtons()
    end)
end

local SpeedCard = Instance.new("Frame")
SpeedCard.Size = UDim2.new(1, 0, 0, 78)
SpeedCard.BackgroundColor3 = Theme.Card
SpeedCard.BackgroundTransparency = 0.2
SpeedCard.BorderSizePixel = 0
SpeedCard.LayoutOrder = 2
SpeedCard.ZIndex = 4
SpeedCard.Parent = ThemesPage
addCorner(SpeedCard, 12)
addStroke(SpeedCard, Theme.Border, 1, 0.4)
addGradient(SpeedCard, Theme.Card, Theme.Background2, 90)

local speedTitle = createLabel(SpeedCard, "⚡  VELOCIDAD DEL TEMA", UDim2.new(1, -20, 0, 16), UDim2.new(0, 13, 0, 10), Theme.Accent, Enum.Font.GothamBold, 10)
speedTitle.ZIndex = 5
registerLabel(speedTitle, true)

local speedValueLabel = createLabel(SpeedCard, "1.0x", UDim2.new(1, -20, 0, 16), UDim2.new(1, -50, 0, 10), Theme.Text, Enum.Font.GothamBold, 10)
speedValueLabel.TextXAlignment = Enum.TextXAlignment.Right
speedValueLabel.ZIndex = 5

local speedBar = Instance.new("Frame")
speedBar.Size = UDim2.new(1, -26, 0, 12)
speedBar.Position = UDim2.new(0, 13, 0, 46)
speedBar.BackgroundColor3 = Theme.Background2
speedBar.BorderSizePixel = 0
speedBar.ZIndex = 5
speedBar.Parent = SpeedCard
addCorner(speedBar, 6)

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0.2, 0, 1, 0)
speedFill.BackgroundColor3 = Theme.Accent
speedFill.BorderSizePixel = 0
speedFill.ZIndex = 6
speedFill.Parent = speedBar
addCorner(speedFill, 6)
registerFill(speedFill, true)

local speedKnob = Instance.new("Frame")
speedKnob.Size = UDim2.new(0, 14, 0, 14)
speedKnob.Position = UDim2.new(0.2, -7, 0.5, -7)
speedKnob.BackgroundColor3 = Theme.Accent
speedKnob.BorderSizePixel = 0
speedKnob.ZIndex = 7
speedKnob.Parent = speedBar
addCorner(speedKnob, 7)
addStroke(speedKnob, Color3.fromRGB(255, 255, 255), 2)
registerFill(speedKnob, true)

local draggingSpeed = false

local function updateSpeedFromX(x)
    local bx = speedBar.AbsolutePosition.X
    local bw = speedBar.AbsoluteSize.X
    local pct = math.clamp((x - bx) / bw, 0, 1)
    speedFill.Size = UDim2.new(pct, 0, 1, 0)
    speedKnob.Position = UDim2.new(pct, -7, 0.5, -7)
    themeSpeed = 0.1 + pct * 4.9
    speedValueLabel.Text = string.format("%.1fx", themeSpeed)
end

speedBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSpeed = true
        updateSpeedFromX(input.Position.X)
    end
end)
speedBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSpeed = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSpeed and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSpeedFromX(input.Position.X)
    end
end)

-- =========================================================
-- TOGGLE TECLA (RightShift)
-- =========================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setWindow(not windowOpen)
    end
end)

-- =========================================================
-- ESTADO INICIAL
-- =========================================================
switchPage("Home")
BallBtn.Visible = true
MainFrame.Visible = false

setTheme("BW")
updateModeButtons()

RunService.Heartbeat:Connect(function()
    if not modeButtons[currentTheme] then return end
    local btn = modeButtons[currentTheme]
    if btn.BackgroundColor3 ~= Theme.Accent then
        btn.BackgroundColor3 = Theme.Accent
        btn.TextColor3 = (currentTheme == "BW" or currentTheme == "Glass") and Theme.Accent2 or Color3.fromRGB(0, 0, 0)
    end
end)

task.wait(0.5)
ShowWelcomeNotification()
