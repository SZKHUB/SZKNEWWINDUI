local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Lib = {}

Lib.Version = "1.1.0"

local THEME_KEYS = { "Background", "Sidebar", "Element", "Hover", "Stroke", "Accent", "Text", "SubText", "OnAccent" }
local Themes = {}
local ThemeName = "White"

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local function sameColor(a, b)
    return math.abs(a.R - b.R) < 0.002 and math.abs(a.G - b.G) < 0.002 and math.abs(a.B - b.B) < 0.002
end

local function MakeUnique(colors)
    local used = { Color3.new(1, 1, 1), Color3.new(0, 0, 0) }
    for _, key in ipairs(THEME_KEYS) do
        local c, tries = colors[key], 0
        local i = 1
        while i <= #used do
            if sameColor(c, used[i]) then
                tries = tries + 1
                local step = (c.B > 0.5 and -tries or tries) / 255
                c = Color3.new(c.R, c.G, math.clamp(colors[key].B + step, 0, 1))
                i = 1
            else
                i = i + 1
            end
        end
        colors[key] = c
        table.insert(used, c)
    end
    return colors
end

local function Register(name, data, base)
    local colors = {}
    for _, key in ipairs(THEME_KEYS) do
        colors[key] = data[key] or (base and base[key])
    end
    if not data.OnAccent and data.Accent then
        local a = data.Accent
        local light = (0.299 * a.R + 0.587 * a.G + 0.114 * a.B) > 0.55
        colors.OnAccent = light and rgb(14, 11, 4) or rgb(250, 250, 250)
    end
    Themes[name] = MakeUnique(colors)
    return Themes[name]
end

Register("White", {
    Background = rgb(11, 11, 12), Sidebar = rgb(15, 15, 17), Element = rgb(23, 23, 25),
    Hover = rgb(44, 44, 48), Stroke = rgb(58, 58, 63), Accent = rgb(252, 252, 252),
    Text = rgb(236, 236, 238), SubText = rgb(148, 148, 154), OnAccent = rgb(14, 14, 15),
})
Register("Dark", {
    Background = rgb(13, 13, 15), Sidebar = rgb(18, 18, 21), Element = rgb(26, 26, 30),
    Hover = rgb(40, 40, 46), Stroke = rgb(55, 55, 63), Accent = rgb(110, 130, 255),
    Text = rgb(240, 240, 245), SubText = rgb(145, 145, 158), OnAccent = rgb(250, 250, 252),
})
Register("Light", {
    Background = rgb(244, 244, 247), Sidebar = rgb(234, 234, 239), Element = rgb(252, 252, 253),
    Hover = rgb(218, 218, 226), Stroke = rgb(198, 198, 208), Accent = rgb(70, 90, 220),
    Text = rgb(25, 25, 32), SubText = rgb(95, 95, 110), OnAccent = rgb(250, 250, 251),
})

local T = {}
for k, v in pairs(Themes[ThemeName]) do T[k] = v end
Lib.Theme = T

local Guis = {}
local FontFamily = nil

local function IsText(o)
    return o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")
end

local function ApplyFont(o)
    if FontFamily and IsText(o) then
        o.FontFace = Font.new(FontFamily, o.FontFace.Weight, o.FontFace.Style)
    end
end

local function EachGuiObject(fn)
    for i = #Guis, 1, -1 do
        local g = Guis[i]
        if not g.Parent then
            table.remove(Guis, i)
        else
            for _, d in ipairs(g:GetDescendants()) do fn(d) end
        end
    end
end

local PanelT = 0

local function New(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = o end
    ApplyFont(o)
    return o
end

local function Corner(r)
    return New("UICorner", { CornerRadius = UDim.new(0, r) })
end

local function Stroke(color, th, trans)
    return New("UIStroke", {
        Color = color or T.Stroke,
        Thickness = th or 1,
        Transparency = trans or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function Pad(l, t, r, b)
    return New("UIPadding", {
        PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t),
        PaddingRight = UDim.new(0, r), PaddingBottom = UDim.new(0, b),
    })
end

local function List(gap, dir)
    return New("UIListLayout", {
        Padding = UDim.new(0, gap or 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = dir or Enum.FillDirection.Vertical,
    })
end

local function Tween(o, t, p)
    TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play()
end

local function TweenEx(o, t, p, style, dir)
    local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), p)
    tw:Play()
    return tw
end

local function FadeOut(root, t)
    local info = TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local function go(o)
        local p = {}
        if o:IsA("GuiObject") then
            if o.BackgroundTransparency < 1 then p.BackgroundTransparency = 1 end
            if o:IsA("TextLabel") or o:IsA("TextButton") then p.TextTransparency = 1 end
            if o:IsA("ImageLabel") then p.ImageTransparency = 1 end
        elseif o:IsA("UIStroke") then
            p.Transparency = 1
        end
        if next(p) then TweenService:Create(o, info, p):Play() end
    end
    go(root)
    for _, d in ipairs(root:GetDescendants()) do go(d) end
end

local function Label(parent, text, size, color, font, xalign)
    return New("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextSize = size or 14,
        TextColor3 = color or T.Text,
        Font = font or Enum.Font.GothamMedium,
        TextXAlignment = xalign or Enum.TextXAlignment.Left,
        Parent = parent,
    })
end

local Fluid = {}

local function FluidColors(dim)
    local black, white = Color3.new(0, 0, 0), Color3.new(1, 1, 1)
    local c1, c2, c3
    if dim then
        c1, c2, c3 = T.Accent:Lerp(black, 0.5), T.Accent:Lerp(black, 0.82), T.Accent:Lerp(black, 0.36)
    else
        c1, c2, c3 = T.Accent:Lerp(white, 0.18), T.Accent:Lerp(black, 0.5), T.Accent:Lerp(white, 0.5)
    end
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(0.35, c2),
        ColorSequenceKeypoint.new(0.65, c3),
        ColorSequenceKeypoint.new(1, c1),
    })
end

local function FluidStroke(stroke, dim)
    stroke.Color = Color3.new(1, 1, 1)
    local g = New("UIGradient", { Color = FluidColors(dim), Parent = stroke })
    table.insert(Fluid, { Gradient = g, Dim = dim })
    return g
end

RunService.RenderStepped:Connect(function()
    local t = os.clock()
    for i = #Fluid, 1, -1 do
        local g = Fluid[i].Gradient
        if not g:IsDescendantOf(game) then
            table.remove(Fluid, i)
        else
            g.Rotation = (t * 70) % 360
            g.Offset = Vector2.new(math.sin(t * 1.2) * 0.25, 0)
        end
    end
end)

local function Icon(name, parent, size, color)
    color = color or T.Text
    local holder = New("Frame", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size, size),
        Parent = parent,
    })

    if type(name) == "string" and name:find("rbxasset") then
        local img = New("ImageLabel", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
            Image = name, ImageColor3 = color, Parent = holder,
        })
        return holder, function(c) img.ImageColor3 = c end
    end

    local fills, strokes = {}, {}

    local function rect(x, y, w, h, rot, round)
        local f = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(x, y),
            Size = UDim2.fromScale(w, h),
            Rotation = rot or 0,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = holder,
        }, { New("UICorner", { CornerRadius = UDim.new(round or 0, 0) }) })
        table.insert(fills, f)
        return f
    end

    local function ring(x, y, d)
        local f = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(x, y),
            Size = UDim2.fromScale(d, d),
            BackgroundTransparency = 1,
            Parent = holder,
        }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
        local s = New("UIStroke", { Color = color, Thickness = math.max(1.5, size * 0.09), Parent = f })
        table.insert(strokes, s)
        return f
    end

    if name == "x" then
        rect(0.5, 0.5, 0.95, 0.12, 45, 0.5)
        rect(0.5, 0.5, 0.95, 0.12, -45, 0.5)
    elseif name == "minus" then
        rect(0.5, 0.5, 0.8, 0.12, 0, 0.5)
    elseif name == "grid" then
        rect(0.28, 0.28, 0.34, 0.34, 0, 0.22)
        rect(0.72, 0.28, 0.34, 0.34, 0, 0.22)
        rect(0.28, 0.72, 0.34, 0.34, 0, 0.22)
        rect(0.72, 0.72, 0.34, 0.34, 0, 0.22)
    elseif name == "sliders" or name == "settings" then
        rect(0.5, 0.25, 0.84, 0.1, 0, 0.5)
        rect(0.5, 0.5, 0.84, 0.1, 0, 0.5)
        rect(0.5, 0.75, 0.84, 0.1, 0, 0.5)
        rect(0.30, 0.25, 0.26, 0.26, 0, 1)
        rect(0.68, 0.5, 0.26, 0.26, 0, 1)
        rect(0.42, 0.75, 0.26, 0.26, 0, 1)
    elseif name == "home" then
        rect(0.5, 0.36, 0.46, 0.46, 45, 0.08)
        rect(0.5, 0.7, 0.58, 0.44, 0, 0.1)
    elseif name == "user" then
        rect(0.5, 0.3, 0.36, 0.36, 0, 1)
        rect(0.5, 0.78, 0.72, 0.38, 0, 0.5)
    elseif name == "info" then
        ring(0.5, 0.5, 0.86)
        rect(0.5, 0.3, 0.1, 0.1, 0, 1)
        rect(0.5, 0.58, 0.1, 0.3, 0, 0.5)
    elseif name == "search" then
        ring(0.43, 0.43, 0.56)
        rect(0.8, 0.8, 0.3, 0.1, 45, 0.5)
    elseif name == "terminal" then
        rect(0.3, 0.38, 0.34, 0.12, 45, 0.5)
        rect(0.3, 0.62, 0.34, 0.12, -45, 0.5)
        rect(0.72, 0.78, 0.3, 0.12, 0, 0.5)
    elseif name == "tag" then
        rect(0.5, 0.5, 0.6, 0.6, 45, 0.16)
        rect(0.5, 0.3, 0.15, 0.15, 0, 1).BackgroundColor3 = T.Element
    elseif name == "check" then
        rect(0.3, 0.6, 0.34, 0.13, 45, 0.5)
        rect(0.6, 0.5, 0.64, 0.13, -45, 0.5)
    elseif name == "chevron" then
        rect(0.37, 0.5, 0.52, 0.12, 45, 0.5)
        rect(0.63, 0.5, 0.52, 0.12, -45, 0.5)
    elseif name == "lock" then
        ring(0.5, 0.34, 0.46)
        rect(0.5, 0.68, 0.72, 0.5, 0, 0.18)
    else
        rect(0.5, 0.5, 0.5, 0.5, 0, 0.2)
    end

    return holder, function(c)
        for _, f in ipairs(fills) do f.BackgroundColor3 = c end
        for _, s in ipairs(strokes) do s.Color = c end
    end
end

local function MakeDraggable(handle, target)
    local dragging, startInput, startPos, moved = false, nil, nil, false

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            startInput, startPos = i.Position, target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startInput
            if d.Magnitude > 6 then moved = true end
            if moved then
                target.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end
    end)

    return function() return moved end
end

local function Row(parent, h)
    local r = New("Frame", {
        BackgroundColor3 = T.Element,
        BackgroundTransparency = PanelT,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, h or 40),
        ClipsDescendants = true,
        Parent = parent,
    }, { Corner(8), Stroke(T.Stroke) })
    FluidStroke(r:FindFirstChildOfClass("UIStroke"), true)
    return r
end

local function Lockable(api, row, opt, onLock)
    local overlay
    function api:IsLocked() return overlay ~= nil end
    function api:Lock(title)
        if overlay then return end
        overlay = New("TextButton", {
            Name = "LockOverlay", BackgroundColor3 = T.Background, BackgroundTransparency = 0.15,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false, Active = true,
            Size = UDim2.fromScale(1, 1), ZIndex = 20, Parent = row,
        }, {
            Corner(8),
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })
        local ic = Icon("lock", overlay, 12, T.SubText)
        ic.LayoutOrder = 1
        local tl = Label(overlay, title or opt.LockedTitle or "Locked", 11, T.SubText, Enum.Font.GothamBold)
        tl.AutomaticSize = Enum.AutomaticSize.X
        tl.Size = UDim2.new(0, 0, 1, 0)
        tl.LayoutOrder = 2
        if onLock then onLock(true) end
    end
    function api:Unlock()
        if not overlay then return end
        overlay:Destroy()
        overlay = nil
        if onLock then onLock(false) end
    end
    if opt.Locked then api:Lock() end
    return api
end

local function Attach(obj, container, isPage)
    function obj:AddLabel(text)
        local row = Row(container, 26)
        row.AutomaticSize = Enum.AutomaticSize.Y
        Pad(12, 5, 12, 5).Parent = row
        local l = Label(row, text, 13, T.SubText)
        l.Size = UDim2.new(1, 0, 0, 0)
        l.AutomaticSize = Enum.AutomaticSize.Y
        l.TextWrapped = true
        l.TextYAlignment = Enum.TextYAlignment.Top
        local api = {}
        function api:Set(t) l.Text = t end
        return api
    end

    function obj:AddBanner(opt)
        local H = opt.Height or 90
        local mode = opt.ScaleType or "Fit"
        local row = Row(container, H)

        local back
        if mode == "Fit" then
            local br = opt.BackdropBrightness or 0.4
            back = New("ImageLabel", {
                BackgroundColor3 = T.Hover, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
                Image = opt.Image or "", ScaleType = Enum.ScaleType.Crop,
                ImageColor3 = Color3.new(br, br, br), Parent = row,
            }, { Corner(8) })
        end

        local img = New("ImageLabel", {
            BackgroundTransparency = (mode == "Fit") and 1 or 0,
            BackgroundColor3 = T.Hover, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
            Image = opt.Image or "",
            ScaleType = (mode == "Crop" and Enum.ScaleType.Crop)
                or (mode == "Stretch" and Enum.ScaleType.Stretch)
                or Enum.ScaleType.Fit,
            Parent = row,
        }, { Corner(8) })

        if opt.Title then
            New("Frame", {
                Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0, Parent = img,
            }, { Corner(8), New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.15),
                }),
            }) })
            local t1 = Label(img, opt.Title, 14, T.Text, Enum.Font.GothamBold)
            t1.Position = UDim2.new(0, 10, 1, -38)
            t1.Size = UDim2.new(1, -20, 0, 18)
            t1.TextTruncate = Enum.TextTruncate.AtEnd
            local t2 = Label(img, opt.Subtitle or "", 11, T.SubText, Enum.Font.Gotham)
            t2.Position = UDim2.new(0, 10, 1, -20)
            t2.Size = UDim2.new(1, -20, 0, 14)
            t2.TextTruncate = Enum.TextTruncate.AtEnd
        end
        local api = {}
        function api:SetImage(id)
            img.Image = id
            if back then back.Image = id end
        end
        return api
    end

    function obj:AddLogo(opt)
        local row = Row(container, 52)
        local img = New("ImageLabel", {
            BackgroundColor3 = T.Hover, BorderSizePixel = 0,
            Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(36, 36),
            Image = opt.Image or "", ScaleType = Enum.ScaleType.Crop, Parent = row,
        }, { Corner(8) })
        local t1 = Label(row, opt.Title or "", 14, T.Text, Enum.Font.GothamBold)
        t1.Position = UDim2.fromOffset(52, 9)
        t1.Size = UDim2.new(1, -60, 0, 18)
        t1.TextTruncate = Enum.TextTruncate.AtEnd
        local t2 = Label(row, opt.Subtitle or "", 11, T.SubText, Enum.Font.Gotham)
        t2.Position = UDim2.fromOffset(52, 27)
        t2.Size = UDim2.new(1, -60, 0, 14)
        t2.TextTruncate = Enum.TextTruncate.AtEnd
        local api = {}
        function api:SetImage(id) img.Image = id end
        return api
    end

    function obj:AddButton(opt)
        local row = Row(container, 32)
        local btn = New("TextButton", {
            BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = row,
        })
        local l = Label(btn, opt.Name or "Button", 13)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Size = UDim2.new(1, -52, 1, 0)
        l.Position = UDim2.fromOffset(12, 0)
        local ic, setC = Icon(opt.Icon or "chevron", btn, 13, T.SubText)
        ic.AnchorPoint = Vector2.new(1, 0.5)
        ic.Position = UDim2.new(1, -12, 0.5, 0)
        ic.Rotation = -90

        local api = {}
        btn.MouseEnter:Connect(function()
            if api:IsLocked() then return end
            Tween(row, 0.15, { BackgroundColor3 = T.Hover }) setC(T.Accent)
        end)
        btn.MouseLeave:Connect(function() Tween(row, 0.15, { BackgroundColor3 = T.Element }) setC(T.SubText) end)
        btn.MouseButton1Click:Connect(function()
            if not api:IsLocked() and opt.Callback then task.spawn(opt.Callback) end
        end)
        function api:SetTitle(t) l.Text = t end
        return Lockable(api, row, opt, function(locked)
            if locked then
                row.BackgroundColor3 = T.Element
                setC(T.SubText)
            end
        end)
    end

    function obj:AddToggle(opt)
        local state = opt.Default or false
        local row = Row(container, 32)
        local btn = New("TextButton", {
            BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = row,
        })
        local l = Label(btn, opt.Name or "Toggle", 13)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Size = UDim2.new(1, -70, 1, 0)
        l.Position = UDim2.fromOffset(12, 0)

        local sw = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(34, 18), BackgroundColor3 = T.Hover, Parent = btn,
        }, { Corner(9) })
        local knob = New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
            Size = UDim2.fromOffset(12, 12), BackgroundColor3 = T.Text, Parent = sw,
        }, { Corner(6) })

        local api = {}
        local function render(anim)
            local pos = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            local col = state and T.Accent or T.Hover
            local knobCol = state and T.OnAccent or T.Text
            if anim then
                Tween(knob, 0.18, { Position = pos, BackgroundColor3 = knobCol })
                Tween(sw, 0.18, { BackgroundColor3 = col })
            else
                knob.Position, knob.BackgroundColor3, sw.BackgroundColor3 = pos, knobCol, col
            end
        end
        function api:Set(v, silent)
            state = v and true or false
            render(true)
            if not silent and opt.Callback then task.spawn(opt.Callback, state) end
        end
        function api:Get() return state end
        btn.MouseButton1Click:Connect(function()
            if not api:IsLocked() then api:Set(not state) end
        end)
        render(false)
        return Lockable(api, row, opt)
    end

    function obj:AddSlider(opt)
        local min, max = opt.Min or 0, opt.Max or 100
        local inc = opt.Increment or 1
        local value = math.clamp(opt.Default or min, min, max)

        local row = Row(container, 44)
        local l = Label(row, opt.Name or "Slider", 13)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Size = UDim2.new(1, -90, 0, 20)
        l.Position = UDim2.fromOffset(12, 4)
        local vl = Label(row, tostring(value), 13, T.SubText, Enum.Font.Gotham, Enum.TextXAlignment.Right)
        vl.Size = UDim2.fromOffset(70, 20)
        vl.Position = UDim2.new(1, -82, 0, 4)

        local track = New("Frame", {
            Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(1, -24, 0, 5),
            BackgroundColor3 = T.Hover, Parent = row,
        }, { Corner(3) })
        local fill = New("Frame", {
            Size = UDim2.fromScale(0, 1), BackgroundColor3 = T.Accent, Parent = track,
        }, { Corner(3) })
        local knob = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
            Size = UDim2.fromOffset(12, 12), BackgroundColor3 = T.Text, Parent = track,
        }, { Corner(6) })
        local hit = New("TextButton", {
            BackgroundTransparency = 1, Text = "",
            Position = UDim2.new(0, 0, 0, 20), Size = UDim2.new(1, 0, 0, 24), Parent = row,
        })

        local api = {}
        local function set(v, silent)
            v = math.clamp(math.floor(v / inc + 0.5) * inc, min, max)
            value = v
            local p = (v - min) / (max - min)
            fill.Size = UDim2.fromScale(p, 1)
            knob.Position = UDim2.fromScale(p, 0.5)
            vl.Text = tostring(v)
            if not silent and opt.Callback then task.spawn(opt.Callback, v) end
        end
        function api:Set(v) set(v) end
        function api:Get() return value end

        local dragging = false
        local function fromX(x)
            local p = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            set(min + p * (max - min))
        end
        hit.InputBegan:Connect(function(i)
            if api:IsLocked() then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                fromX(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                fromX(i.Position.X)
            end
        end)
        set(value, true)
        return Lockable(api, row, opt, function(locked)
            if locked then dragging = false end
        end)
    end

    function obj:AddInput(opt)
        local row = Row(container, 32)
        local l = Label(row, opt.Name or "Input", 13)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Size = UDim2.new(0.5, -12, 1, 0)
        l.Position = UDim2.fromOffset(12, 0)
        local box = New("TextBox", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.new(0.5, -16, 0, 22), BackgroundColor3 = T.Hover,
            Text = opt.Default or "", PlaceholderText = opt.Placeholder or "",
            PlaceholderColor3 = T.SubText, TextColor3 = T.Text, TextSize = 12,
            Font = Enum.Font.Gotham, ClearTextOnFocus = false, Parent = row,
        }, { Corner(6), Pad(8, 0, 8, 0) })
        local api = {}
        box.FocusLost:Connect(function(enter)
            if not api:IsLocked() and opt.Callback then task.spawn(opt.Callback, box.Text, enter) end
        end)
        function api:Set(t) box.Text = t end
        function api:Get() return box.Text end
        return Lockable(api, row, opt, function(locked)
            box.TextEditable = not locked
            if locked and box:IsFocused() then box:ReleaseFocus() end
        end)
    end

    function obj:AddDropdown(opt)
        local options = opt.Options or {}
        local selected = opt.Default
        local open = false
        local LIST_H = math.min(#options, 5) * 26 + (math.min(#options, 5) - 1) * 2

        local row = Row(container, 32)
        local head = New("TextButton", {
            BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 32), Parent = row,
        })
        local l = Label(head, opt.Name or "Dropdown", 13)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Size = UDim2.new(0.5, -12, 1, 0)
        l.Position = UDim2.fromOffset(12, 0)
        local cur = Label(head, selected or "Select", 12, T.SubText, Enum.Font.Gotham, Enum.TextXAlignment.Right)
        cur.Size = UDim2.new(0.5, -40, 1, 0)
        cur.Position = UDim2.new(0.5, 0, 0, 0)
        cur.TextTruncate = Enum.TextTruncate.AtEnd
        local chev = Icon("chevron", head, 13, T.SubText)
        chev.AnchorPoint = Vector2.new(1, 0.5)
        chev.Position = UDim2.new(1, -12, 0.5, 0)

        local list = New("ScrollingFrame", {
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.fromOffset(8, 36), Size = UDim2.new(1, -16, 0, LIST_H),
            ScrollBarThickness = 2, ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = row,
        }, { List(2) })

        local api = {}
        local function select(v, silent)
            selected = v
            cur.Text = tostring(v)
            if not silent and opt.Callback then task.spawn(opt.Callback, v) end
        end

        local function build()
            for _, c in ipairs(list:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for _, o in ipairs(options) do
                local b = New("TextButton", {
                    BackgroundColor3 = T.Hover, BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, 26), Text = tostring(o), TextColor3 = T.Text,
                    TextSize = 12, Font = Enum.Font.Gotham, AutoButtonColor = false, Parent = list,
                }, { Corner(6) })
                b.MouseEnter:Connect(function() Tween(b, 0.12, { BackgroundTransparency = 0 }) end)
                b.MouseLeave:Connect(function() Tween(b, 0.12, { BackgroundTransparency = 0.4 }) end)
                b.MouseButton1Click:Connect(function()
                    if api:IsLocked() then return end
                    select(o)
                    open = false
                    Tween(row, 0.2, { Size = UDim2.new(1, 0, 0, 32) })
                    Tween(chev, 0.2, { Rotation = 0 })
                end)
            end
        end

        head.MouseButton1Click:Connect(function()
            if api:IsLocked() then return end
            open = not open
            Tween(row, 0.2, { Size = UDim2.new(1, 0, 0, open and (32 + 4 + LIST_H + 4) or 32) })
            Tween(chev, 0.2, { Rotation = open and 180 or 0 })
        end)

        function api:Set(v) select(v) end
        function api:Get() return selected end
        function api:Refresh(newOptions)
            options = newOptions
            LIST_H = math.min(#options, 5) * 26 + (math.min(#options, 5) - 1) * 2
            list.Size = UDim2.new(1, -16, 0, LIST_H)
            build()
        end
        build()
        return Lockable(api, row, opt, function(locked)
            if locked and open then
                open = false
                Tween(row, 0.2, { Size = UDim2.new(1, 0, 0, 32) })
                Tween(chev, 0.2, { Rotation = 0 })
            end
        end)
    end

    if isPage then
        local cols, colL, colR
        local orderPage, orderL, orderR = 0, 0, 0
        local nextSide = "left"

        local function newCols()
            orderPage = orderPage + 1
            cols = New("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = orderPage, Parent = container,
            }, { New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
            }) })
            local function col(o)
                return New("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(0.5, -4, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = o, Parent = cols,
                }, { New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
            end
            colL, colR = col(1), col(2)
            orderL, orderR = 0, 0
            nextSide = "left"
        end

        function obj:AddSection(name, icon, side)
            if icon == "left" or icon == "right" or icon == "full" then
                side, icon = icon, nil
            end

            local parent, lo
            if side == "full" then
                orderPage = orderPage + 1
                parent, lo = container, orderPage
                cols = nil
            else
                if not cols then newCols() end
                if side ~= "left" and side ~= "right" then
                    side = nextSide
                    nextSide = (side == "left") and "right" or "left"
                end
                if side == "left" then
                    orderL = orderL + 1
                    parent, lo = colL, orderL
                else
                    orderR = orderR + 1
                    parent, lo = colR, orderR
                end
            end

            local card = New("Frame", {
                BackgroundColor3 = T.Sidebar, BackgroundTransparency = PanelT, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true,
                LayoutOrder = lo, Parent = parent,
            }, { Corner(10), Stroke(T.Stroke, 1, 0.3), List(0) })

            local head = New("Frame", {
                BackgroundColor3 = T.Element, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 1, Parent = card,
            }, { Corner(10) })
            New("Frame", {
                AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = T.Element,
                BorderSizePixel = 0, Parent = head,
            })
            New("Frame", {
                AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Stroke,
                BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 2, Parent = head,
            })
            local hx = 12
            if icon then
                local ic = Icon(icon, head, 13, T.Accent)
                ic.AnchorPoint = Vector2.new(0, 0.5)
                ic.Position = UDim2.new(0, 11, 0.5, 0)
                hx = 31
            end
            local ttl = Label(head, string.upper(name or "SECTION"), 11, T.Text, Enum.Font.GothamBold)
            ttl.Position = UDim2.fromOffset(hx, 0)
            ttl.Size = UDim2.new(1, -(hx + 8), 1, 0)
            ttl.TextTruncate = Enum.TextTruncate.AtEnd

            local body = New("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = card,
            }, { List(6), Pad(6, 6, 6, 6) })

            local sec = {}
            Attach(sec, body)
            return sec
        end
    end
end

local function NewGui(name, order)
    local gui = New("ScreenGui", {
        Name = name, ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = order or 0,
    })
    local parentGui = (gethui and gethui()) or CoreGui
    if not pcall(function() gui.Parent = parentGui end) then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    table.insert(Guis, gui)
    return gui
end

function Lib:SetFont(font)
    if typeof(font) == "EnumItem" then
        FontFamily = Font.fromEnum(font).Family
    elseif typeof(font) == "Font" then
        FontFamily = font.Family
    else
        assert(type(font) == "string", "SetFont: expected Enum.Font, Font or string")
        FontFamily = font
    end
    EachGuiObject(ApplyFont)
end

function Lib:AddTheme(theme)
    assert(type(theme) == "table" and type(theme.Name) == "string", "AddTheme: theme.Name is required")
    local colors = Register(theme.Name, theme, Themes.Dark)
    if theme.Name == ThemeName then self:SetTheme(theme.Name) end
    return colors
end

function Lib:GetThemes()
    local copy = {}
    for name, colors in pairs(Themes) do copy[name] = table.clone(colors) end
    return copy
end

function Lib:GetCurrentTheme()
    return ThemeName
end

function Lib:SetTheme(name)
    local new = Themes[name]
    if not new then
        warn("STARZKUI: unknown theme '" .. tostring(name) .. "'")
        return false
    end
    local old = table.clone(T)
    for k, v in pairs(new) do T[k] = v end
    ThemeName = name

    local function swap(o, prop)
        local value = o[prop]
        for _, key in ipairs(THEME_KEYS) do
            if sameColor(value, old[key]) then
                o[prop] = new[key]
                return
            end
        end
    end
    EachGuiObject(function(o)
        if o:IsA("GuiObject") then
            swap(o, "BackgroundColor3")
            if IsText(o) then swap(o, "TextColor3") end
            if o:IsA("TextBox") then swap(o, "PlaceholderColor3") end
            if o:IsA("ImageLabel") then swap(o, "ImageColor3") end
            if o:IsA("ScrollingFrame") then swap(o, "ScrollBarImageColor3") end
        elseif o:IsA("UIStroke") then
            swap(o, "Color")
        end
    end)
    for _, f in ipairs(Fluid) do f.Gradient.Color = FluidColors(f.Dim) end
    return true
end

local notifHolder

function Lib:Notify(opt)
    opt = opt or {}
    if not (notifHolder and notifHolder.Parent and notifHolder.Parent.Parent) then
        notifHolder = New("Frame", {
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10),
            Size = UDim2.new(0, 190, 1, -20), BackgroundTransparency = 1,
            Parent = NewGui("STARZKUI_Notifications", 20),
        }, { List(5) })
    end

    local wrap = New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, Parent = notifHolder,
    })
    local card = New("TextButton", {
        Position = UDim2.new(1, 30, 0, 0), Size = UDim2.new(1, 0, 0, 0), Text = "", AutoButtonColor = false,
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.Background, Parent = wrap,
    }, { Corner(8), Stroke(T.Stroke), Pad(8, 6, 8, 6), List(2) })
    FluidStroke(card:FindFirstChildOfClass("UIStroke"), true)

    local head = New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 1, Parent = card,
    })
    local tx = 0
    if opt.Icon ~= false and opt.Icon ~= "" then
        local hi = Icon(opt.Icon or "info", head, 11, T.Accent)
        hi.AnchorPoint = Vector2.new(0, 0.5)
        hi.Position = UDim2.new(0, 0, 0.5, 0)
        tx = 16
    end
    local nt = Label(head, opt.Title or "Notice", 11, T.Text, Enum.Font.GothamBold)
    nt.Position = UDim2.fromOffset(tx, 0)
    nt.Size = UDim2.new(1, -tx, 1, 0)
    nt.TextTruncate = Enum.TextTruncate.AtEnd

    if opt.Content and opt.Content ~= "" then
        local nc = Label(card, opt.Content, 10, T.SubText, Enum.Font.Gotham)
        nc.Size = UDim2.new(1, 0, 0, 0)
        nc.AutomaticSize = Enum.AutomaticSize.Y
        nc.TextWrapped = true
        nc.TextYAlignment = Enum.TextYAlignment.Top
        nc.LayoutOrder = 2
    end

    local api, closed = {}, false
    function api:Close()
        if closed then return end
        closed = true
        Tween(card, 0.3, { Position = UDim2.new(1, 30, 0, 0) })
        task.delay(0.32, function() wrap:Destroy() end)
    end
    card.MouseButton1Click:Connect(function() api:Close() end)

    Tween(card, 0.3, { Position = UDim2.new(0, 0, 0, 0) })
    local duration = opt.Duration or 4
    if duration > 0 then
        task.delay(duration, function() api:Close() end)
    end
    return api
end

function Lib:Popup(opt)
    opt = opt or {}
    local gui = NewGui("STARZKUI_Popup", 10)
    local overlay = New("TextButton", {
        BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
        Text = "", AutoButtonColor = false, Modal = true, Size = UDim2.fromScale(1, 1), Parent = gui,
    })
    Tween(overlay, 0.2, { BackgroundTransparency = 0.45 })

    local card = New("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(270, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.Background, Text = "", AutoButtonColor = false, Parent = overlay,
    }, { Corner(12), Stroke(T.Stroke, 1.5), Pad(14, 12, 14, 12), List(8) })
    FluidStroke(card:FindFirstChildOfClass("UIStroke"))
    local cs = New("UIScale", { Scale = 0.6, Parent = card })
    TweenEx(cs, 0.35, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local head = New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1, Parent = card,
    })
    local tx = 0
    if opt.Icon then
        local ic = Icon(opt.Icon, head, 15, T.Accent)
        ic.AnchorPoint = Vector2.new(0, 0.5)
        ic.Position = UDim2.fromScale(0, 0.5)
        tx = 22
    end
    local title = Label(head, opt.Title or "STARZKUI", 15, T.Text, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(tx, 0)
    title.Size = UDim2.new(1, -tx, 1, 0)
    title.TextTruncate = Enum.TextTruncate.AtEnd

    if opt.Content and opt.Content ~= "" then
        local body = Label(card, opt.Content, 12, T.SubText, Enum.Font.Gotham)
        body.Size = UDim2.new(1, 0, 0, 0)
        body.AutomaticSize = Enum.AutomaticSize.Y
        body.TextWrapped = true
        body.TextYAlignment = Enum.TextYAlignment.Top
        body.LayoutOrder = 2
    end

    local bar = New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 3, Parent = card,
    }, { List(6, Enum.FillDirection.Horizontal) })

    local api, closed = {}, false
    function api:Close()
        if closed then return end
        closed = true
        TweenEx(cs, 0.18, { Scale = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        Tween(overlay, 0.18, { BackgroundTransparency = 1 })
        task.delay(0.2, function() gui:Destroy() end)
    end

    local buttons = opt.Buttons
    if not buttons or #buttons == 0 then buttons = { { Title = "OK", Variant = "Primary" } } end
    local n = #buttons
    for i, info in ipairs(buttons) do
        local primary = info.Variant == "Primary"
        local fg = primary and T.OnAccent or T.Text
        local b = New("TextButton", {
            Size = UDim2.new(1 / n, -math.ceil(6 * (n - 1) / n), 1, 0), LayoutOrder = i,
            BackgroundColor3 = primary and T.Accent or T.Element,
            Text = "", AutoButtonColor = false, Parent = bar,
        }, {
            Corner(8),
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })
        if not primary then Stroke(T.Stroke).Parent = b end
        if info.Icon then
            local ic = Icon(info.Icon, b, 11, fg)
            ic.LayoutOrder = 1
        end
        local tl = Label(b, info.Title or "Button", 12, fg, Enum.Font.GothamBold)
        tl.AutomaticSize = Enum.AutomaticSize.X
        tl.Size = UDim2.new(0, 0, 1, 0)
        tl.LayoutOrder = 2
        b.MouseButton1Click:Connect(function()
            if closed then return end
            api:Close()
            if info.Callback then task.spawn(info.Callback) end
        end)
    end

    return api
end

function Lib:CreateWindow(cfg)
    cfg = cfg or {}
    if cfg.Theme then Lib:SetTheme(cfg.Theme) end
    if cfg.Font then Lib:SetFont(cfg.Font) end
    local Window = {}
    local tabs, current = {}, nil

    local gui = NewGui("STARZKUI")
    Window.Gui = gui

    local BASE = cfg.Scale or 0.75
    local baseSize = cfg.Size or UDim2.fromOffset(520, 340)
    local main = New("Frame", {
        Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(baseSize.X.Offset * BASE, baseSize.Y.Offset * BASE),
        BackgroundColor3 = T.Background, BorderSizePixel = 0, Parent = gui,
    }, { Corner(14), Stroke(T.Stroke) })
    local scale = New("UIScale", { Scale = 1, Parent = main })
    local mainStroke = main:FindFirstChildOfClass("UIStroke")
    mainStroke.Thickness = 1.5
    FluidStroke(mainStroke)

    local hasBg = cfg.Background ~= nil and cfg.Background ~= ""
    PanelT = hasBg and 0.25 or 0
    if hasBg then
        local br = cfg.BackgroundBrightness or 0.55
        New("ImageLabel", {
            Name = "Background", ZIndex = 0, BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1), Image = cfg.Background,
            ImageColor3 = Color3.new(br, br, br), ScaleType = Enum.ScaleType.Crop,
            Parent = main,
        }, { Corner(14) })
    end

    local body = New("Frame", {
        Name = "Body", BackgroundTransparency = 1, Size = baseSize, Parent = main,
    }, { New("UIScale", { Scale = BASE }) })

    local top = New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Parent = body,
    })
    New("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Stroke, BorderSizePixel = 0, Parent = top,
    })

    local logo = New("Frame", {
        Position = UDim2.fromOffset(10, 8), Size = UDim2.fromOffset(24, 24),
        BackgroundColor3 = T.Accent, Parent = top,
    }, { Corner(8) })
    local lg = Icon(cfg.Icon or "grid", logo, 13, T.OnAccent)
    lg.AnchorPoint = Vector2.new(0.5, 0.5)
    lg.Position = UDim2.fromScale(0.5, 0.5)

    local title = Label(top, cfg.Title or "STARZKUI", 13, T.Text, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(42, 4)
    title.Size = UDim2.fromOffset(200, 16)
    local sub = Label(top, cfg.Subtitle or "", 10, T.SubText, Enum.Font.Gotham)
    sub.Position = UDim2.fromOffset(53, 20)
    sub.Size = UDim2.fromOffset(150, 12)
    if (cfg.Subtitle or "") ~= "" then
        New("Frame", {
            Position = UDim2.fromOffset(43, 23), Size = UDim2.fromOffset(6, 6),
            BackgroundColor3 = Color3.fromRGB(70, 210, 120), Parent = top,
        }, { Corner(3) })
    end

    local function topButton(iconName, offsetX)
        local b = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, offsetX, 0.5, 0),
            Size = UDim2.fromOffset(22, 22), BackgroundColor3 = T.Element,
            Text = "", AutoButtonColor = false, Parent = top,
        }, { Corner(8) })
        local ic, setC = Icon(iconName, b, 11, T.SubText)
        ic.AnchorPoint = Vector2.new(0.5, 0.5)
        ic.Position = UDim2.fromScale(0.5, 0.5)
        b.MouseEnter:Connect(function() Tween(b, 0.15, { BackgroundColor3 = T.Hover }) setC(T.Text) end)
        b.MouseLeave:Connect(function() Tween(b, 0.15, { BackgroundColor3 = T.Element }) setC(T.SubText) end)
        return b
    end
    local closeBtn = topButton("x", -10)
    local minBtn = topButton("minus", -36)

    local chipHolder = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -64, 0.5, 0),
        Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, Parent = top,
    }, { New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5),
        VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
    }) })

    local function chip(iconName, text, order)
        local c = New("Frame", {
            Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = T.Element, LayoutOrder = order, Parent = chipHolder,
        }, {
            Corner(6), Stroke(T.Stroke), Pad(7, 0, 8, 0),
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5),
                VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })
        FluidStroke(c:FindFirstChildOfClass("UIStroke"), true)
        local ic = Icon(iconName, c, 11, T.Accent)
        ic.LayoutOrder = 1
        local tl = Label(c, text, 10, T.Text, Enum.Font.GothamBold)
        tl.AutomaticSize = Enum.AutomaticSize.X
        tl.Size = UDim2.new(0, 0, 1, 0)
        tl.LayoutOrder = 2
    end

    local ver = cfg.Version
    if ver == nil then ver = "v1.0" end
    local tg = cfg.Tag
    if tg == nil then tg = "BETA" end
    if ver then chip("terminal", ver, 1) end
    if tg then chip("tag", tg, 2) end

    MakeDraggable(top, main)

    local side = New("Frame", {
        Position = UDim2.fromOffset(0, 41), Size = UDim2.new(0, 112, 1, -41),
        BackgroundColor3 = T.Sidebar, BackgroundTransparency = hasBg and 1 or 0, BorderSizePixel = 0, Parent = body,
    }, { New("UICorner", { CornerRadius = UDim.new(0, 14) }) })
    New("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundColor3 = T.Sidebar, BackgroundTransparency = hasBg and 1 or 0, BorderSizePixel = 0, Parent = side })
    New("Frame", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 16, 1, 0), BackgroundColor3 = T.Sidebar, BackgroundTransparency = hasBg and 1 or 0, BorderSizePixel = 0, Parent = side,
    })

    if hasBg then
        New("Frame", {
            Position = UDim2.fromOffset(112, 41), Size = UDim2.new(0, 1, 1, -55),
            BackgroundColor3 = T.Stroke, BackgroundTransparency = 0.35, BorderSizePixel = 0, Parent = body,
        })
    end

    local tabList = New("ScrollingFrame", {
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 1, -50),
        ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = side,
    }, { List(3), Pad(6, 6, 6, 6) })

    local prof = New("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 6, 1, -6),
        Size = UDim2.new(1, -12, 0, 38), BackgroundColor3 = T.Element, Parent = side,
    }, { Corner(10), Stroke(T.Stroke) })
    FluidStroke(prof:FindFirstChildOfClass("UIStroke"), true)
    local av = New("ImageLabel", {
        Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = T.Hover, Parent = prof,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    task.spawn(function()
        local ok, img = pcall(Players.GetUserThumbnailAsync, Players, LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        if ok then av.Image = img end
    end)
    local pn = Label(prof, LocalPlayer.DisplayName, 11, T.Text, Enum.Font.GothamBold)
    pn.Position = UDim2.fromOffset(38, 5)
    pn.Size = UDim2.new(1, -42, 0, 14)
    pn.TextTruncate = Enum.TextTruncate.AtEnd
    local pu = Label(prof, "@" .. LocalPlayer.Name, 10, T.SubText, Enum.Font.Gotham)
    pu.Position = UDim2.fromOffset(38, 19)
    pu.Size = UDim2.new(1, -42, 0, 12)
    pu.TextTruncate = Enum.TextTruncate.AtEnd

    local content = New("Frame", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(112, 41),
        Size = UDim2.new(1, -112, 1, -41), ClipsDescendants = true, Parent = body,
    })

    local function Confirm()
        if body:FindFirstChild("ConfirmOverlay") then return end
        local ov = New("TextButton", {
            Name = "ConfirmOverlay", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), ZIndex = 50, Parent = body,
        }, { Corner(14) })
        Tween(ov, 0.2, { BackgroundTransparency = 0.4 })

        local card = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(190, 86), BackgroundColor3 = T.Background, Parent = ov,
        }, { Corner(10), Stroke(T.Stroke) })
        FluidStroke(card:FindFirstChildOfClass("UIStroke"), true)

        local cs = New("UIScale", { Scale = 0.6, Parent = card })
        TweenEx(cs, 0.35, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        local q = Label(card, "Close STARZKUI?", 13, T.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        q.Position = UDim2.fromOffset(0, 10)
        q.Size = UDim2.new(1, 0, 0, 18)
        local qs = Label(card, "The interface will be deleted", 10, T.SubText, Enum.Font.Gotham, Enum.TextXAlignment.Center)
        qs.Position = UDim2.fromOffset(0, 29)
        qs.Size = UDim2.new(1, 0, 0, 14)

        local function cbtn(text, iconName, x, primary)
            local fg = primary and T.OnAccent or T.Text
            local b = New("TextButton", {
                Position = UDim2.fromOffset(x, 52), Size = UDim2.fromOffset(78, 26),
                BackgroundColor3 = primary and T.Accent or T.Element,
                Text = "", AutoButtonColor = false, Parent = card,
            }, {
                Corner(8),
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }),
            })
            if not primary then Stroke(T.Stroke).Parent = b end
            local ic = Icon(iconName, b, 11, fg)
            ic.LayoutOrder = 1
            local tl = Label(b, text, 12, fg, Enum.Font.GothamBold)
            tl.AutomaticSize = Enum.AutomaticSize.X
            tl.Size = UDim2.new(0, 0, 1, 0)
            tl.LayoutOrder = 2
            return b
        end

        local yes = cbtn("Yes", "check", 12, true)
        local no = cbtn("No", "x", 100, false)

        yes.MouseButton1Click:Connect(function() Window:Destroy() end)
        no.MouseButton1Click:Connect(function()
            TweenEx(cs, 0.18, { Scale = 0.6 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            Tween(ov, 0.18, { BackgroundTransparency = 1 })
            task.wait(0.18)
            ov:Destroy()
        end)
    end

    local openBtn = New("TextButton", {
        Name = "OpenButton", AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 14), Size = UDim2.fromOffset(0, 38),
        AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = T.Background,
        Text = "", AutoButtonColor = false, Visible = false, Parent = gui,
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Pad(15, 0, 17, 0),
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    local obStroke = Stroke(Color3.new(1, 1, 1), 2)
    obStroke.Parent = openBtn
    FluidStroke(obStroke)
    local oi = Icon(cfg.Icon or "grid", openBtn, 18, T.Accent)
    oi.LayoutOrder = 1
    local ot = Label(openBtn, cfg.Title or "STARZKUI", 14, T.Text, Enum.Font.GothamBold)
    ot.AutomaticSize = Enum.AutomaticSize.X
    ot.Size = UDim2.new(0, 0, 1, 0)
    ot.LayoutOrder = 2
    local obScale = New("UIScale", { Scale = 1, Parent = openBtn })
    local wasMoved = MakeDraggable(openBtn, openBtn)

    local visible = true
    local busy = false
    local destroying = false

    local tabsShown = (cfg.Intro == false)
    local function ShowTabs(show)
        tabsShown = show
        for i, t in ipairs(tabs) do
            local delay = math.min(i - 1, 6) * (show and 0.06 or 0.025)
            local target = show and UDim2.new(0, 0, 0, 0) or UDim2.new(-1, 0, 0, 0)
            task.delay(delay, function()
                if t.Btn and t.Btn.Parent and tabsShown == show then
                    TweenEx(t.Btn, show and 0.5 or 0.2, { Position = target },
                        show and Enum.EasingStyle.Quint or Enum.EasingStyle.Quad,
                        show and Enum.EasingDirection.Out or Enum.EasingDirection.In)
                end
            end)
        end
    end

    local cover = New("Frame", {
        Name = "Cover", BackgroundColor3 = T.Background, BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), ZIndex = 200, Visible = false, Parent = body,
    }, { Corner(14) })

    local BACK_OUT = Enum.EasingStyle.Back
    local BACK_IN = Enum.EasingStyle.Back

    function Window:Toggle(v)
        if busy or destroying then return end
        if v == nil then v = not visible end
        if v == visible then return end
        visible = v
        busy = true

        if v then
            TweenEx(obScale, 0.2, { Scale = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.2, function() openBtn.Visible = false end)

            main.Visible = true
            scale.Scale = 0.55
            cover.Visible = true
            cover.BackgroundTransparency = 0
            TweenEx(scale, 0.5, { Scale = 1 }, BACK_OUT, Enum.EasingDirection.Out)
            TweenEx(cover, 0.4, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            task.delay(0.38, function() ShowTabs(true) end)
            task.delay(0.5, function()
                cover.Visible = false
                busy = false
            end)
        else
            ShowTabs(false)
            task.delay(0.22, function()
                cover.Visible = true
                cover.BackgroundTransparency = 1
                TweenEx(cover, 0.25, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                TweenEx(scale, 0.32, { Scale = 0.5 }, BACK_IN, Enum.EasingDirection.In)
                task.delay(0.32, function()
                    main.Visible = false
                    scale.Scale = 1
                    cover.Visible = false
                    obScale.Scale = 0
                    openBtn.Visible = true
                    TweenEx(obScale, 0.45, { Scale = 1 }, BACK_OUT, Enum.EasingDirection.Out)
                    busy = false
                end)
            end)
        end
    end

    local keyConn
    function Window:Destroy()
        if destroying then return end
        destroying = true
        busy = true
        if keyConn then keyConn:Disconnect() end
        openBtn.Visible = false

        cover.Visible = true
        cover.BackgroundTransparency = 1
        TweenEx(cover, 0.3, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenEx(main, 0.5, { Rotation = -8 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenEx(scale, 0.5, { Scale = 0 }, BACK_IN, Enum.EasingDirection.In)
        task.delay(0.55, function() gui:Destroy() end)
    end

    openBtn.MouseButton1Click:Connect(function()
        if not wasMoved() then Window:Toggle() end
    end)
    minBtn.MouseButton1Click:Connect(function() Window:Toggle(false) end)
    closeBtn.MouseButton1Click:Connect(Confirm)
    if cfg.ToggleKey then
        keyConn = UIS.InputBegan:Connect(function(i, gp)
            if not gp and i.KeyCode == cfg.ToggleKey then Window:Toggle() end
        end)
    end

    function Window:Notify(opt)
        return Lib:Notify(opt)
    end

    local function select(tab)
        if current == tab then return end
        for _, t in ipairs(tabs) do
            local on = (t == tab)
            t.Page.Visible = on
            Tween(t.Btn, 0.18, { BackgroundTransparency = on and 0.82 or 1 })
            Tween(t.Bar, 0.18, { BackgroundTransparency = on and 0 or 1 })
            t.SetIcon(on and T.Accent or T.SubText)
            Tween(t.Name, 0.18, { TextColor3 = on and T.Text or T.SubText })
        end
        current = tab
    end

    function Window:AddTab(name, icon)
        local tab = {}

        local holder = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
            ClipsDescendants = true, Parent = tabList,
        })
        local btn = New("TextButton", {
            BackgroundColor3 = T.Accent, BackgroundTransparency = 1,
            Position = tabsShown and UDim2.new(0, 0, 0, 0) or UDim2.new(-1, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0), Text = "", AutoButtonColor = false, Parent = holder,
        }, { Corner(8) })
        local bar = New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(3, 12), BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1, Parent = btn,
        }, { Corner(2) })
        local ic, setIc = Icon(icon or "grid", btn, 14, T.SubText)
        ic.AnchorPoint = Vector2.new(0, 0.5)
        ic.Position = UDim2.new(0, 10, 0.5, 0)
        local nm = Label(btn, name, 12, T.SubText)
        nm.Position = UDim2.fromOffset(32, 0)
        nm.Size = UDim2.new(1, -36, 1, 0)

        local page = New("ScrollingFrame", {
            BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
            Size = UDim2.fromScale(1, 1), ScrollBarThickness = 2, ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = content,
        }, { List(8), Pad(8, 8, 10, 8) })

        tab.Btn, tab.Bar, tab.Name, tab.Page, tab.SetIcon = btn, bar, nm, page, setIc
        Attach(tab, page, true)

        btn.MouseButton1Click:Connect(function() select(tab) end)
        btn.MouseEnter:Connect(function()
            if current ~= tab then Tween(btn, 0.15, { BackgroundTransparency = 0.92 }) end
        end)
        btn.MouseLeave:Connect(function()
            if current ~= tab then Tween(btn, 0.15, { BackgroundTransparency = 1 }) end
        end)

        table.insert(tabs, tab)
        if #tabs == 1 then select(tab) end
        return tab
    end

    local function PlayIntro()
        busy = true
        local splash = New("Frame", {
            Name = "Splash", BackgroundColor3 = T.Background, Size = UDim2.fromScale(1, 1),
            ZIndex = 100, Active = true, Parent = body,
        }, { Corner(14) })

        local BLOCK, GAP = 20, 4
        local grid = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, -26),
            Size = UDim2.fromOffset(BLOCK * 2 + GAP, BLOCK * 2 + GAP),
            BackgroundTransparency = 1, Parent = splash,
        })
        local slots = {
            UDim2.fromOffset(0, 0),
            UDim2.fromOffset(BLOCK + GAP, 0),
            UDim2.fromOffset(BLOCK + GAP, BLOCK + GAP),
            UDim2.fromOffset(0, BLOCK + GAP),
        }
        local blocks, scales = {}, {}
        for i = 1, 4 do
            local sc = New("UIScale", { Scale = 0 })
            blocks[i] = New("Frame", {
                Position = slots[i], Size = UDim2.fromOffset(BLOCK, BLOCK),
                BackgroundColor3 = T.Accent:Lerp(T.Hover, (i - 1) * 0.25),
                BorderSizePixel = 0, Parent = grid,
            }, { Corner(6), sc })
            scales[i] = sc
        end

        local loadLbl = Label(splash, "LOADING", 13, T.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        loadLbl.Position = UDim2.new(0, 0, 0.5, 8)
        loadLbl.Size = UDim2.new(1, 0, 0, 18)
        loadLbl.TextTransparency = 1

        local pctLbl = Label(splash, "0%", 12, T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        pctLbl.Position = UDim2.new(0, 0, 0.5, 28)
        pctLbl.Size = UDim2.new(1, 0, 0, 16)
        pctLbl.TextTransparency = 1

        scale.Scale = 0.55
        TweenEx(scale, 0.5, { Scale = 1 }, BACK_OUT, Enum.EasingDirection.Out)
        task.wait(0.25)

        for i = 1, 4 do
            task.delay((i - 1) * 0.07, function()
                TweenEx(scales[i], 0.4, { Scale = 1 }, BACK_OUT, Enum.EasingDirection.Out)
            end)
        end
        TweenEx(loadLbl, 0.4, { TextTransparency = 0 }, Enum.EasingStyle.Quad)
        TweenEx(pctLbl, 0.4, { TextTransparency = 0 }, Enum.EasingStyle.Quad)
        task.wait(0.35)

        local loading = true
        task.spawn(function()
            local step = 0
            while loading and splash.Parent do
                step = step + 1
                for i, blk in ipairs(blocks) do
                    local slot = slots[((i - 1 + step) % 4) + 1]
                    task.delay((i - 1) * 0.05, function()
                        TweenEx(blk, 0.35, { Position = slot }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
                    end)
                end
                task.wait(0.55)
            end
        end)

        local DURATION = 2.6
        local t0 = os.clock()
        while true do
            local a = math.clamp((os.clock() - t0) / DURATION, 0, 1)
            local e = (a < 0.5) and (2 * a * a) or (1 - ((-2 * a + 2) ^ 2) / 2)
            pctLbl.Text = tostring(math.floor(e * 100 + 0.5)) .. "%"
            if a >= 1 then break end
            task.wait()
        end
        pctLbl.Text = "100%"
        task.wait(0.3)
        loading = false

        FadeOut(splash, 0.4)
        task.wait(0.45)
        splash:Destroy()
        ShowTabs(true)
        busy = false
    end

    if cfg.Intro ~= false then task.spawn(PlayIntro) end

    return Window
end

return Lib
