-- CreateWindow -> CreatePanel -> AddButton/AddToggle/AddSlider/AddInput/AddDropdown.
-- Window modes: normal, island, and button.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Library = {
    Version = "1.0.0",
}

local Theme = {
    Background = Color3.fromRGB(13, 16, 22),
    Surface = Color3.fromRGB(21, 25, 34),
    SurfaceHover = Color3.fromRGB(29, 35, 46),
    SurfaceActive = Color3.fromRGB(35, 43, 57),
    Border = Color3.fromRGB(62, 72, 91),
    Text = Color3.fromRGB(241, 244, 249),
    Muted = Color3.fromRGB(149, 159, 178),
    Accent = Color3.fromRGB(69, 157, 255),
    Success = Color3.fromRGB(76, 205, 142),
    Warning = Color3.fromRGB(245, 183, 76),
    Danger = Color3.fromRGB(242, 91, 103),
}

local function create(className, properties, children)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do
        object[key] = value
    end
    for _, child in ipairs(children or {}) do
        child.Parent = object
    end
    return object
end

local function corner(radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(color, transparency)
    return create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color or Theme.Border,
        Thickness = 1,
        Transparency = transparency or 0,
    })
end

local function padding(left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
    })
end

local function tween(object, duration, goal, style, direction)
    local animation = TweenService:Create(object, TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    ), goal)
    animation:Play()
    return animation
end

local function bindPress(button, callback)
    local scale = create("UIScale", { Scale = 1, Parent = button })
    button.MouseButton1Down:Connect(function()
        tween(scale, 0.08, { Scale = 0.97 }, Enum.EasingStyle.Quad)
    end)
    button.MouseButton1Up:Connect(function()
        tween(scale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
    end)
    button.MouseLeave:Connect(function()
        tween(scale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
    end)
    button.MouseButton1Click:Connect(callback)
end

local function makeDraggable(handle, target, onMoved)
    local dragging = false
    local dragInput
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if onMoved then
                        onMoved(target.Position)
                    end
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

local function safeParent()
    local player = Players.LocalPlayer
    local parent
    pcall(function()
        if gethui then
            parent = gethui()
        end
    end)
    if not parent then
        pcall(function()
            parent = game:GetService("CoreGui")
        end)
    end
    if not parent and player then
        parent = player:WaitForChild("PlayerGui")
    end
    return parent
end

function Library:CreateWindow(options)
    options = options or {}
    local window = {
        Panels = {},
        Mode = "normal",
        MinimizeMode = options.MinimizeMode == "button" and "button" or "island",
        Status = options.Status or "准备就绪",
        Mobile = UserInputService.TouchEnabled,
        Theme = Theme,
        Accent = options.Accent or Theme.Accent,
        BackdropEffects = {
            Blur = options.BackgroundBlur ~= false,
            Particles = options.BackgroundParticles ~= false,
            Gradient = options.BackgroundGradient ~= false,
        },
    }

    for key, value in pairs(options.Theme or {}) do
        Theme[key] = value
    end

    local parent = options.Parent or safeParent()
    local guiName = options.Name or "UGIK_UI"
    local old = parent and parent:FindFirstChild(guiName)
    if old then
        old:Destroy()
    end

    local gui = create("ScreenGui", {
        Name = guiName,
        DisplayOrder = options.DisplayOrder or 40,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parent,
    })
    pcall(function()
        if protectgui then
            protectgui(gui)
        end
    end)
    window.Gui = gui
    local baseTransparencies = setmetatable({}, { __mode = "k" })

    local oldBlur = Lighting:FindFirstChild(guiName .. "_Blur")
    if oldBlur then
        oldBlur:Destroy()
    end
    local blur = create("BlurEffect", {
        Name = guiName .. "_Blur",
        Size = 0,
        Parent = Lighting,
    })

    local shade = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 1,
        Parent = gui,
    })

    local gradientLayer = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 72, 138),
        BackgroundTransparency = 0.68,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Visible = window.BackdropEffects.Gradient,
        ZIndex = 2,
        Parent = shade,
    })
    local backdropGradient = create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 14, 27)),
            ColorSequenceKeypoint.new(0.48, Color3.fromRGB(20, 86, 164)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 25, 50)),
        }),
        Rotation = 0,
        Parent = gradientLayer,
    })

    local particleLayer = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Visible = window.BackdropEffects.Particles,
        ZIndex = 3,
        Parent = shade,
    })
    local particles = {}
    local particleCount = window.Mobile and 12 or 22
    for index = 1, particleCount do
        local size = math.random(3, 8)
        local particle = create("Frame", {
            BackgroundColor3 = index % 3 == 0 and Color3.fromRGB(121, 202, 255) or Color3.fromRGB(48, 143, 255),
            BackgroundTransparency = math.random(20, 62) / 100,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(math.random(), math.random()),
            Size = UDim2.fromOffset(size, size),
            ZIndex = 4,
            Parent = particleLayer,
        }, { corner(size) })
        particles[#particles + 1] = particle
    end

    task.spawn(function()
        while gui.Parent do
            if shade.Visible and window.BackdropEffects.Gradient then
                tween(backdropGradient, 5, { Rotation = backdropGradient.Rotation + 120 }, Enum.EasingStyle.Linear)
            end
            if shade.Visible and window.BackdropEffects.Particles then
                for _, particle in ipairs(particles) do
                    tween(particle, math.random(30, 65) / 10, {
                        Position = UDim2.fromScale(math.random(), math.random()),
                    }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                end
            end
            task.wait(4.5)
        end
    end)

    local toastContainer = create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -14, 1, -14),
        Size = UDim2.fromOffset(window.Mobile and 270 or 330, 420),
        ZIndex = 120,
        Parent = gui,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = toastContainer,
    })

    local dockWidth = window.Mobile and 132 or 152
    local dock = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.fromOffset(dockWidth, window.Mobile and 290 or 420),
        ZIndex = 10,
        Parent = gui,
    }, {
        corner(8),
        stroke(Theme.Border, 0.25),
    })
    window.Dock = dock
    local scalableRoots = { dock }
    create("UIScale", { Name = "UGIKScale", Scale = 1, Parent = dock })

    local dockAccent = create("Frame", {
        BackgroundColor3 = options.Accent or Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 3),
        ZIndex = 11,
        Parent = dock,
    }, { corner(8) })

    local dockTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(window.Mobile and 6 or 12, 10),
        Size = UDim2.new(1, window.Mobile and -12 or -24, 0, 38),
        Font = Enum.Font.GothamBold,
        Text = options.Title or "UGIK UI",
        TextColor3 = Theme.Text,
        TextSize = window.Mobile and 13 or 16,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
        Parent = dock,
    })

    local dockList = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(7, 54),
        ScrollBarThickness = 0,
        Size = UDim2.new(1, -14, 1, -108),
        ZIndex = 11,
        Parent = dock,
    })
    local dockLayout = create("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = dockList,
    })
    dockLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        dockList.CanvasSize = UDim2.fromOffset(0, dockLayout.AbsoluteContentSize.Y + 4)
    end)

    local dockActions = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 7, 1, -48),
        Size = UDim2.new(1, -14, 0, 40),
        ZIndex = 11,
        Parent = dock,
    })
    local actionLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = dockActions,
    })

    local function actionButton(text, color)
        return create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = color or Theme.SurfaceActive,
            BorderSizePixel = 0,
            Size = UDim2.new(0.5, -3, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = text,
            TextColor3 = Theme.Text,
            TextSize = window.Mobile and 11 or 12,
            ZIndex = 12,
            Parent = dockActions,
        }, { corner(7) })
    end

    local islandAction = actionButton("DI", Color3.fromRGB(44, 55, 72))
    local minimizeAction = actionButton("MIN", Color3.fromRGB(44, 55, 72))

    local island = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(5, 6, 9),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0.5, 0, 0, 10),
        Size = UDim2.fromOffset(window.Mobile and 254 or 292, 54),
        Visible = false,
        ZIndex = 80,
        Parent = gui,
    }, {
        corner(27),
        stroke(Color3.fromRGB(67, 72, 83), 0.35),
    })
    window.Island = island
    scalableRoots[#scalableRoots + 1] = island
    create("UIScale", { Name = "UGIKScale", Scale = 1, Parent = island })

    local statusDot = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Success,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(16, 27),
        Size = UDim2.fromOffset(8, 8),
        ZIndex = 82,
        Parent = island,
    }, { corner(8) })

    local islandTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(34, 8),
        Size = UDim2.new(1, -76, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = options.ShortTitle or "UGIK",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 82,
        Parent = island,
    })

    local islandStatus = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(34, 26),
        Size = UDim2.new(1, -76, 0, 16),
        Font = Enum.Font.GothamMedium,
        Text = window.Status,
        TextColor3 = Theme.Muted,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 82,
        Parent = island,
    })

    local islandToggle = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0, 7),
        Size = UDim2.fromOffset(34, 36),
        Font = Enum.Font.GothamBold,
        Text = "+",
        TextColor3 = Theme.Muted,
        TextSize = 20,
        ZIndex = 83,
        Parent = island,
    })

    local islandMenu = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 61),
        Size = UDim2.new(1, -24, 0, 38),
        Visible = false,
        ZIndex = 82,
        Parent = island,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 7),
        Parent = islandMenu,
    })

    local function islandMenuButton(text, color)
        return create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = color or Theme.SurfaceActive,
            BorderSizePixel = 0,
            Size = UDim2.new(0.333, -5, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = text,
            TextColor3 = Theme.Text,
            TextSize = 11,
            ZIndex = 83,
            Parent = islandMenu,
        }, { corner(9) })
    end

    local restoreButton = islandMenuButton("恢复")
    local floatButton = islandMenuButton("悬浮")
    local closeButton = islandMenuButton("关闭", Color3.fromRGB(116, 47, 55))

    local restore = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(18, 22, 30),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -18, 0.55, 0),
        Size = UDim2.fromOffset(52, 52),
        Font = Enum.Font.GothamBold,
        Text = options.RestoreText or "UG",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Visible = false,
        ZIndex = 90,
        Parent = gui,
    }, {
        corner(26),
        stroke(options.Accent or Theme.Accent, 0.1),
    })
    window.RestoreButton = restore
    scalableRoots[#scalableRoots + 1] = restore
    create("UIScale", { Name = "UGIKScale", Scale = 1, Parent = restore })

    makeDraggable(dockTitle, dock)
    makeDraggable(islandTitle, island)
    makeDraggable(restore, restore)

    local islandExpanded = false
    local changingMode = false

    local function setBackdrop(visible)
        if visible then
            shade.Visible = true
            tween(shade, 0.3, { BackgroundTransparency = 0.78 }, Enum.EasingStyle.Quint)
            tween(blur, 0.38, { Size = window.BackdropEffects.Blur and (options.BlurSize or 12) or 0 }, Enum.EasingStyle.Quint)
        else
            tween(shade, 0.24, { BackgroundTransparency = 1 })
            tween(blur, 0.28, { Size = 0 })
            task.delay(0.29, function()
                if window.Mode ~= "normal" and shade.Parent then
                    shade.Visible = false
                end
            end)
        end
    end

    function window:SetBackdropEffects(settings)
        settings = settings or {}
        for key, value in pairs(settings) do
            if self.BackdropEffects[key] ~= nil then
                self.BackdropEffects[key] = value == true
            end
        end
        gradientLayer.Visible = self.BackdropEffects.Gradient
        particleLayer.Visible = self.BackdropEffects.Particles
        if self.Mode == "normal" then
            tween(blur, 0.25, { Size = self.BackdropEffects.Blur and (options.BlurSize or 12) or 0 })
        end
    end

    function window:SetMinimizeMode(mode)
        if mode == "island" or mode == "button" then
            self.MinimizeMode = mode
        end
    end

    function window:SetScale(value)
        local scale = math.clamp(tonumber(value) or 1, 0.7, 1.3)
        self.Scale = scale
        for _, root in ipairs(scalableRoots) do
            local scaler = root:FindFirstChild("UGIKScale")
            if scaler then scaler.Scale = scale end
        end
    end

    function window:SetTransparency(value)
        local amount = math.clamp(tonumber(value) or 0, 0, 0.65)
        self.Transparency = amount
        for _, object in ipairs(gui:GetDescendants()) do
            if object:IsA("GuiObject") and object.ZIndex >= 10 and not object:IsA("TextLabel") and not object:IsA("TextButton") and not object:IsA("TextBox") then
                if baseTransparencies[object] == nil then
                    baseTransparencies[object] = object.BackgroundTransparency
                end
                local base = baseTransparencies[object]
                object.BackgroundTransparency = base >= 1 and 1 or math.clamp(base + amount, 0, 0.92)
            end
        end
    end

    function window:SetAccent(color)
        if typeof(color) ~= "Color3" then return end
        local previous = self.Accent
        self.Accent = color
        Theme.Accent = color
        for _, object in ipairs(gui:GetDescendants()) do
            if object:IsA("GuiObject") and object.BackgroundColor3 == previous then
                object.BackgroundColor3 = color
            elseif object:IsA("TextLabel") and object.TextColor3 == previous then
                object.TextColor3 = color
            elseif object:IsA("UIStroke") and object.Color == previous then
                object.Color = color
            end
        end
    end

    function window:SetTheme(name)
        local presets = {
            ["深色"] = { Background = Color3.fromRGB(13, 16, 22), Surface = Color3.fromRGB(21, 25, 34), Text = Color3.fromRGB(241, 244, 249), Muted = Color3.fromRGB(149, 159, 178) },
            ["浅色"] = { Background = Color3.fromRGB(225, 230, 238), Surface = Color3.fromRGB(245, 247, 250), Text = Color3.fromRGB(25, 30, 39), Muted = Color3.fromRGB(91, 101, 117) },
            ["霓虹"] = { Background = Color3.fromRGB(8, 12, 18), Surface = Color3.fromRGB(18, 26, 35), Text = Color3.fromRGB(231, 255, 249), Muted = Color3.fromRGB(126, 177, 181) },
        }
        local preset = presets[name]
        if not preset then return end
        for key, nextColor in pairs(preset) do
            local previous = Theme[key]
            Theme[key] = nextColor
            for _, object in ipairs(gui:GetDescendants()) do
                if object:IsA("GuiObject") and object.BackgroundColor3 == previous then object.BackgroundColor3 = nextColor end
                if (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) and object.TextColor3 == previous then object.TextColor3 = nextColor end
            end
        end
        self.ThemeName = name
    end

    local function setPanelsVisible(visible)
        for _, panel in ipairs(window.Panels) do
            panel.Frame.Visible = visible and panel.Visible
        end
    end

    function window:SetMode(mode)
        if changingMode or (mode ~= "normal" and mode ~= "island" and mode ~= "button") then
            return
        end
        changingMode = true
        self.Mode = mode
        islandExpanded = false
        islandMenu.Visible = false
        islandToggle.Text = "+"

        if mode == "normal" then
            restore.Visible = false
            island.Visible = false
            dock.Visible = true
            setPanelsVisible(true)
            setBackdrop(true)
            dock.Size = UDim2.fromOffset(dockWidth, 0)
            tween(dock, 0.34, { Size = UDim2.fromOffset(dockWidth, window.Mobile and 290 or 420) }, Enum.EasingStyle.Quint)
        elseif mode == "island" then
            restore.Visible = false
            setPanelsVisible(false)
            dock.Visible = false
            island.Visible = true
            setBackdrop(false)
            island.Size = UDim2.fromOffset(window.Mobile and 210 or 228, 44)
            tween(island, 0.34, { Size = UDim2.fromOffset(window.Mobile and 254 or 292, 54) }, Enum.EasingStyle.Back)
        else
            setPanelsVisible(false)
            dock.Visible = false
            island.Visible = false
            setBackdrop(false)
            restore.Visible = true
            restore.Size = UDim2.fromOffset(0, 0)
            tween(restore, 0.32, { Size = UDim2.fromOffset(52, 52) }, Enum.EasingStyle.Back)
        end

        task.delay(0.36, function()
            changingMode = false
        end)
    end

    function window:SetStatus(text, color)
        self.Status = tostring(text or "")
        islandStatus.Text = self.Status
        statusDot.BackgroundColor3 = color or Theme.Success
        tween(statusDot, 0.12, { Size = UDim2.fromOffset(12, 12) }, Enum.EasingStyle.Back)
        task.delay(0.13, function()
            if statusDot.Parent then
                tween(statusDot, 0.2, { Size = UDim2.fromOffset(8, 8) })
            end
        end)
    end

    function window:Notify(title, text, duration, color)
        self:SetStatus((title and (title .. ": ") or "") .. tostring(text or ""))
        local lifetime = tonumber(duration) or 4
        local toast = create("Frame", {
            BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 0.04,
            BorderSizePixel = 0,
            LayoutOrder = math.floor(os.clock() * 1000),
            Size = UDim2.fromOffset(0, 72),
            ZIndex = 121,
            Parent = toastContainer,
        }, { corner(8), stroke(color or Theme.Accent, 0.12) })
        create("Frame", {
            BackgroundColor3 = color or Theme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(3, 72),
            ZIndex = 122,
            Parent = toast,
        }, { corner(3) })
        create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 9),
            Size = UDim2.new(1, -26, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = tostring(title or options.Title or "UGIK"),
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 122,
            Parent = toast,
        })
        create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 31),
            Size = UDim2.new(1, -26, 0, 31),
            Font = Enum.Font.GothamMedium,
            Text = tostring(text or ""),
            TextColor3 = Theme.Muted,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 122,
            Parent = toast,
        })
        tween(toast, 0.32, { Size = UDim2.fromOffset(window.Mobile and 270 or 330, 72) }, Enum.EasingStyle.Back)
        task.delay(lifetime, function()
            if toast.Parent then
                tween(toast, 0.24, { Size = UDim2.fromOffset(0, 72), BackgroundTransparency = 1 })
                task.delay(0.26, function()
                    if toast.Parent then toast:Destroy() end
                end)
            end
        end)
        return toast
    end

    local function expandIsland()
        if window.Mode ~= "island" then
            return
        end
        islandExpanded = not islandExpanded
        islandMenu.Visible = islandExpanded
        islandToggle.Text = islandExpanded and "-" or "+"
        tween(island, 0.3, {
            Size = UDim2.fromOffset(window.Mobile and 276 or 310, islandExpanded and 112 or 54),
        }, Enum.EasingStyle.Quint)
    end

    bindPress(islandAction, function()
        window:SetMode("island")
    end)
    bindPress(minimizeAction, function()
        window:SetMode(window.MinimizeMode)
    end)
    bindPress(islandToggle, expandIsland)
    bindPress(restoreButton, function()
        window:SetMode("normal")
    end)
    bindPress(floatButton, function()
        window:SetMode("button")
    end)
    bindPress(closeButton, function()
        gui:Destroy()
    end)

    restore.Activated:Connect(function()
        window:SetMode("normal")
    end)

    function window:Destroy()
        if blur then
            blur:Destroy()
        end
        gui:Destroy()
    end

    function window:Show()
        self:SetMode("normal")
    end

    function window:Minimize(useIsland)
        if useIsland == nil then
            self:SetMode(self.MinimizeMode)
        else
            self:SetMode(useIsland and "island" or "button")
        end
    end

    function window:CreatePanel(panelOptions)
        panelOptions = panelOptions or {}
        local panel = {
            Window = self,
            Visible = panelOptions.Visible ~= false,
            Collapsed = false,
            Items = {},
            Accent = panelOptions.Accent or options.Accent or Theme.Accent,
        }
        local index = #self.Panels + 1
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
        local width = window.Mobile and math.clamp(viewport.X - dockWidth - 42, 210, 330) or (panelOptions.Width or 294)
        local height = window.Mobile and math.clamp(viewport.Y - 110, 280, 470) or (panelOptions.Height or 480)
        local availableColumns = math.max(1, math.floor((viewport.X - dockWidth - 42) / (width + 12)))
        local column = ((index - 1) % availableColumns) + 1
        panel.Slot = column
        local startX = 0
        local startXOffset = dockWidth + 28 + (column - 1) * (width + 12)
        local startY = window.Mobile and 0.5 or 0
        local startYOffset = window.Mobile and 0 or 28

        local frame = create("Frame", {
            AnchorPoint = window.Mobile and Vector2.new(0, 0.5) or Vector2.new(0, 0),
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Position = UDim2.new(startX, startXOffset, startY, startYOffset),
            Size = UDim2.fromOffset(width, height),
            Visible = panel.Visible,
            ZIndex = 20 + index,
            Parent = gui,
        }, {
            corner(8),
            stroke(Theme.Border, 0.2),
        })
        panel.Frame = frame
        scalableRoots[#scalableRoots + 1] = frame
        create("UIScale", { Name = "UGIKScale", Scale = window.Scale or 1, Parent = frame })
        panel.ExpandedSize = UDim2.fromOffset(width, height)

        local header = create("Frame", {
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 48),
            ZIndex = frame.ZIndex + 1,
            Parent = frame,
        })
        local accentLine = create("Frame", {
            BackgroundColor3 = panel.Accent,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(4, 48),
            ZIndex = header.ZIndex + 1,
            Parent = header,
        }, { corner(4) })
        TweenService:Create(accentLine, TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            BackgroundTransparency = 0.48,
        }):Play()

        local panelTitle = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 6),
            Size = UDim2.new(1, -86, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = panelOptions.Title or ("Panel " .. index),
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = header.ZIndex + 1,
            Parent = header,
        })

        local panelSubtitle = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 25),
            Size = UDim2.new(1, -86, 0, 16),
            Font = Enum.Font.GothamMedium,
            Text = panelOptions.Subtitle or "0 items",
            TextColor3 = Theme.Muted,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = header.ZIndex + 1,
            Parent = header,
        })
        panel.Subtitle = panelSubtitle

        local collapse = create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            AutoButtonColor = false,
            BackgroundColor3 = Theme.SurfaceActive,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(30, 28),
            Font = Enum.Font.GothamBold,
            Text = "-",
            TextColor3 = Theme.Muted,
            TextSize = 18,
            ZIndex = header.ZIndex + 2,
            Parent = header,
        }, { corner(7) })

        local search = create("TextBox", {
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Font = Enum.Font.GothamMedium,
            PlaceholderColor3 = Theme.Muted,
            PlaceholderText = panelOptions.SearchPlaceholder or "搜索名称或作用...",
            Position = UDim2.fromOffset(8, 56),
            Size = UDim2.new(1, -16, 0, 34),
            Text = "",
            TextColor3 = Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = panelOptions.Search ~= false,
            ZIndex = frame.ZIndex + 1,
            Parent = frame,
        }, {
            corner(7),
            stroke(Theme.Border, 0.45),
            padding(11, 11),
        })
        panel.SearchBox = search

        local contentTop = panelOptions.Search == false and 56 or 98
        local content = create("ScrollingFrame", {
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromOffset(0, 0),
            Position = UDim2.fromOffset(8, contentTop),
            ScrollBarImageColor3 = panel.Accent,
            ScrollBarThickness = window.Mobile and 3 or 4,
            Size = UDim2.new(1, -16, 1, -contentTop - 8),
            ZIndex = frame.ZIndex + 1,
            Parent = frame,
        })
        local contentLayout = create("UIListLayout", {
            Padding = UDim.new(0, 7),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = content,
        })
        create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            Parent = content,
        })

        local function refreshContent()
            content.CanvasSize = UDim2.fromOffset(0, contentLayout.AbsoluteContentSize.Y + 8)
        end
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshContent)

        local function updateCount()
            local shown = 0
            for _, item in ipairs(panel.Items) do
                if item.Root.Visible then
                    shown = shown + 1
                end
            end
            panelSubtitle.Text = tostring(shown) .. "/" .. tostring(#panel.Items) .. " items"
        end

        function panel:Filter(query)
            query = tostring(query or ""):lower()
            for _, item in ipairs(self.Items) do
                item.Root.Visible = query == "" or item.SearchText:find(query, 1, true) ~= nil
                if item.Root.Visible then
                    item.Root.BackgroundTransparency = 0.2
                    tween(item.Root, 0.18, { BackgroundTransparency = item.BaseTransparency or 0 })
                end
            end
            updateCount()
            refreshContent()
        end
        search:GetPropertyChangedSignal("Text"):Connect(function()
            panel:Filter(search.Text)
        end)

        function panel:SetCollapsed(collapsed)
            self.Collapsed = collapsed
            collapse.Text = collapsed and "+" or "-"
            search.Visible = not collapsed and panelOptions.Search ~= false
            content.Visible = not collapsed
            tween(frame, 0.3, {
                Size = collapsed and UDim2.fromOffset(width, 48) or self.ExpandedSize,
            }, Enum.EasingStyle.Quint)
        end

        function panel:SetVisible(visible)
            self.Visible = visible
            if visible then
                if window.Mobile or self.Slot then
                    for _, other in ipairs(window.Panels) do
                        if other ~= self and (window.Mobile or other.Slot == self.Slot) then
                            other.Visible = false
                            other.Frame.Visible = false
                            tween(other.DockButton, 0.18, {
                                BackgroundColor3 = Theme.Surface,
                                TextColor3 = Theme.Muted,
                            })
                        end
                    end
                end
                frame.Visible = true
                frame.BackgroundTransparency = 1
                frame.Size = UDim2.fromOffset(width, 48)
                tween(frame, 0.28, {
                    BackgroundTransparency = 0,
                    Size = self.Collapsed and UDim2.fromOffset(width, 48) or self.ExpandedSize,
                }, Enum.EasingStyle.Quint)
            else
                tween(frame, 0.18, { BackgroundTransparency = 1, Size = UDim2.fromOffset(width, 48) })
                task.delay(0.19, function()
                    if not self.Visible and frame.Parent then
                        frame.Visible = false
                    end
                end)
            end
        end

        bindPress(collapse, function()
            panel:SetCollapsed(not panel.Collapsed)
        end)
        makeDraggable(header, frame)

        local dockButton = create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = panel.Visible and panel.Accent or Theme.Surface,
            BorderSizePixel = 0,
            LayoutOrder = index,
            Size = UDim2.new(1, 0, 0, window.Mobile and 42 or 38),
            Font = Enum.Font.GothamSemibold,
            Text = panelOptions.Title or ("Panel " .. index),
            TextColor3 = panel.Visible and Color3.fromRGB(255, 255, 255) or Theme.Muted,
            TextSize = 12,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Visible = panelOptions.ShowInDock ~= false,
            ZIndex = 12,
            Parent = dockList,
        }, { corner(7), padding(6, 6) })
        panel.DockButton = dockButton

        bindPress(dockButton, function()
            local nextVisible = not panel.Visible
            if window.Mobile then
                nextVisible = true
            end
            panel:SetVisible(nextVisible)
            tween(dockButton, 0.2, {
                BackgroundColor3 = nextVisible and panel.Accent or Theme.Surface,
                TextColor3 = nextVisible and Color3.fromRGB(255, 255, 255) or Theme.Muted,
            })
        end)

        local function addItem(root, searchText, baseTransparency)
            local item = {
                Root = root,
                SearchText = tostring(searchText or ""):lower(),
                BaseTransparency = baseTransparency or 0,
            }
            panel.Items[#panel.Items + 1] = item
            root.LayoutOrder = #panel.Items
            updateCount()
            refreshContent()
            return item
        end

        function panel:AddButton(itemOptions)
            itemOptions = itemOptions or {}
            local root = create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, itemOptions.Description and 56 or 42),
                Text = "",
                ZIndex = content.ZIndex + 1,
                Parent = content,
            }, { corner(7), stroke(Theme.Border, 0.55) })
            local label = create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(11, itemOptions.Description and 7 or 0),
                Size = UDim2.new(1, -48, 0, itemOptions.Description and 20 or 42),
                Font = Enum.Font.GothamSemibold,
                Text = itemOptions.Title or "Button",
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = root.ZIndex + 1,
                Parent = root,
            })
            if itemOptions.Description then
                create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(11, 28),
                    Size = UDim2.new(1, -48, 0, 18),
                    Font = Enum.Font.GothamMedium,
                    Text = itemOptions.Description,
                    TextColor3 = Theme.Muted,
                    TextSize = 10,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = root.ZIndex + 1,
                    Parent = root,
                })
            end
            create("TextLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -11, 0.5, 0),
                Size = UDim2.fromOffset(24, 24),
                Font = Enum.Font.GothamBold,
                Text = itemOptions.ActionText or ">",
                TextColor3 = itemOptions.Accent or panel.Accent,
                TextSize = 15,
                ZIndex = root.ZIndex + 1,
                Parent = root,
            })

            root.MouseEnter:Connect(function()
                tween(root, 0.16, { BackgroundColor3 = Theme.SurfaceHover })
            end)
            root.MouseLeave:Connect(function()
                tween(root, 0.16, { BackgroundColor3 = Theme.Surface })
            end)
            bindPress(root, function()
                window:SetStatus("运行: " .. (itemOptions.Title or "Button"), panel.Accent)
                local ok, result = pcall(itemOptions.Callback or function() end)
                if not ok then
                    window:SetStatus("错误: " .. tostring(result), Theme.Danger)
                end
            end)
            addItem(root, (itemOptions.Title or "") .. " " .. (itemOptions.Description or "") .. " " .. (itemOptions.SearchText or ""))
            return root
        end

        function panel:AddToggle(itemOptions)
            itemOptions = itemOptions or {}
            local state = itemOptions.Default == true
            local root = create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, 44),
                Text = "",
                ZIndex = content.ZIndex + 1,
                Parent = content,
            }, { corner(7) })
            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(11, 0),
                Size = UDim2.new(1, -65, 1, 0),
                Font = Enum.Font.GothamSemibold,
                Text = itemOptions.Title or "Toggle",
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = root.ZIndex + 1,
                Parent = root,
            })
            local track = create("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = state and panel.Accent or Color3.fromRGB(54, 61, 74),
                BorderSizePixel = 0,
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(40, 22),
                ZIndex = root.ZIndex + 1,
                Parent = root,
            }, { corner(11) })
            local knob = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(250, 251, 253),
                BorderSizePixel = 0,
                Position = state and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0),
                Size = UDim2.fromOffset(16, 16),
                ZIndex = root.ZIndex + 2,
                Parent = track,
            }, { corner(8) })

            local function setState(value, fire)
                state = value == true
                tween(track, 0.2, { BackgroundColor3 = state and panel.Accent or Color3.fromRGB(54, 61, 74) })
                tween(knob, 0.22, { Position = state and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0) }, Enum.EasingStyle.Back)
                if fire and itemOptions.Callback then
                    local ok, result = pcall(itemOptions.Callback, state)
                    if not ok then
                        window:SetStatus("错误: " .. tostring(result), Theme.Danger)
                    end
                end
            end
            bindPress(root, function()
                setState(not state, true)
            end)
            addItem(root, (itemOptions.Title or "") .. " " .. (itemOptions.Description or ""))
            return { Set = function(_, value) setState(value, true) end, Get = function() return state end }
        end

        function panel:AddSlider(itemOptions)
            itemOptions = itemOptions or {}
            local minimum = itemOptions.Min or 0
            local maximum = itemOptions.Max or 100
            local step = itemOptions.Step or 1
            local value = math.clamp(itemOptions.Default or minimum, minimum, maximum)
            local root = create("Frame", {
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, 62),
                ZIndex = content.ZIndex + 1,
                Parent = content,
            }, { corner(7) })
            local valueLabel = create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(11, 5),
                Size = UDim2.new(1, -22, 0, 22),
                Font = Enum.Font.GothamSemibold,
                Text = (itemOptions.Title or "Slider") .. ": " .. tostring(value),
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = root.ZIndex + 1,
                Parent = root,
            })
            local track = create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(47, 53, 65),
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(11, 38),
                Size = UDim2.new(1, -22, 0, 8),
                Text = "",
                ZIndex = root.ZIndex + 1,
                Parent = root,
            }, { corner(4) })
            local fill = create("Frame", {
                BackgroundColor3 = panel.Accent,
                BorderSizePixel = 0,
                Size = UDim2.fromScale((value - minimum) / (maximum - minimum), 1),
                ZIndex = track.ZIndex + 1,
                Parent = track,
            }, { corner(4) })

            local sliding = false
            local function update(inputX, fire)
                local ratio = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = math.floor((minimum + (maximum - minimum) * ratio) / step + 0.5) * step
                value = math.clamp(value, minimum, maximum)
                valueLabel.Text = (itemOptions.Title or "Slider") .. ": " .. tostring(value)
                tween(fill, 0.08, { Size = UDim2.fromScale((value - minimum) / (maximum - minimum), 1) }, Enum.EasingStyle.Linear)
                if fire and itemOptions.Callback then
                    pcall(itemOptions.Callback, value)
                end
            end
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    update(input.Position.X, true)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input.Position.X, true)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            addItem(root, itemOptions.Title or "Slider")
            return { Get = function() return value end }
        end

        function panel:AddInput(itemOptions)
            itemOptions = itemOptions or {}
            local root = create("Frame", {
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, 68),
                ZIndex = content.ZIndex + 1,
                Parent = content,
            }, { corner(7) })
            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(11, 4),
                Size = UDim2.new(1, -22, 0, 20),
                Font = Enum.Font.GothamSemibold,
                Text = itemOptions.Title or "Input",
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = root.ZIndex + 1,
                Parent = root,
            })
            local box = create("TextBox", {
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                Font = Enum.Font.GothamMedium,
                PlaceholderText = itemOptions.Placeholder or "输入内容",
                PlaceholderColor3 = Theme.Muted,
                Position = UDim2.fromOffset(9, 29),
                Size = UDim2.new(1, -18, 0, 30),
                Text = itemOptions.Default or "",
                TextColor3 = Theme.Text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = root.ZIndex + 1,
                Parent = root,
            }, { corner(6), padding(9, 9) })
            box.FocusLost:Connect(function(enterPressed)
                if itemOptions.Callback then
                    pcall(itemOptions.Callback, box.Text, enterPressed)
                end
            end)
            addItem(root, (itemOptions.Title or "") .. " " .. (itemOptions.Placeholder or ""))
            return box
        end

        function panel:AddDropdown(itemOptions)
            itemOptions = itemOptions or {}
            local values = itemOptions.Values or {}
            local selected = itemOptions.Default or values[1] or "无选项"
            local searchValues = {}
            for _, value in ipairs(values) do
                searchValues[#searchValues + 1] = tostring(value)
            end
            local open = false
            local root = create("Frame", {
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Size = UDim2.new(1, -5, 0, 44),
                ZIndex = content.ZIndex + 2,
                Parent = content,
            }, { corner(7) })
            local button = create("TextButton", {
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 44),
                Font = Enum.Font.GothamSemibold,
                Text = (itemOptions.Title or "Dropdown") .. ": " .. tostring(selected),
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = root.ZIndex + 1,
                Parent = root,
            }, { padding(11, 11) })
            local choices = create("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(8, 44),
                Size = UDim2.new(1, -16, 0, #values * 32),
                ZIndex = root.ZIndex + 1,
                Parent = root,
            })
            create("UIListLayout", { Padding = UDim.new(0, 4), Parent = choices })

            local function setOpen(value)
                open = value
                tween(root, 0.25, { Size = UDim2.new(1, -5, 0, open and (48 + #values * 32) or 44) }, Enum.EasingStyle.Quint)
                task.delay(0.26, refreshContent)
            end
            bindPress(button, function()
                setOpen(not open)
            end)
            local function rebuildChoices()
                for _, child in ipairs(choices:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                choices.Size = UDim2.new(1, -16, 0, #values * 32)
                for _, choice in ipairs(values) do
                    local currentChoice = choice
                    local choiceButton = create("TextButton", {
                        AutoButtonColor = false,
                        BackgroundColor3 = Theme.Background,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 28),
                        Font = Enum.Font.GothamMedium,
                        Text = tostring(currentChoice),
                        TextColor3 = Theme.Muted,
                        TextSize = 11,
                        ZIndex = root.ZIndex + 2,
                        Parent = choices,
                    }, { corner(6) })
                    bindPress(choiceButton, function()
                        selected = currentChoice
                        button.Text = (itemOptions.Title or "Dropdown") .. ": " .. tostring(selected)
                        setOpen(false)
                        if itemOptions.Callback then pcall(itemOptions.Callback, selected) end
                    end)
                end
            end
            rebuildChoices()
            addItem(root, (itemOptions.Title or "") .. " " .. table.concat(searchValues, " "))
            return {
                Get = function() return selected end,
                SetValues = function(_, nextValues)
                    values = nextValues or {}
                    selected = values[1] or "无选项"
                    button.Text = (itemOptions.Title or "Dropdown") .. ": " .. tostring(selected)
                    setOpen(false)
                    rebuildChoices()
                end,
            }
        end

        function panel:AddLabel(text)
            local root = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -5, 0, 28),
                Font = Enum.Font.GothamMedium,
                Text = tostring(text or ""),
                TextColor3 = Theme.Muted,
                TextSize = 11,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = content.ZIndex + 1,
                Parent = content,
            })
            addItem(root, text or "", 1)
            return root
        end

        self.Panels[#self.Panels + 1] = panel
        if window.Mobile and index > 1 then
            panel.Visible = false
            frame.Visible = false
            dockButton.BackgroundColor3 = Theme.Surface
            dockButton.TextColor3 = Theme.Muted
        end
        return panel
    end

    setBackdrop(true)

    gui.AncestryChanged:Connect(function(_, newParent)
        if not newParent and blur and blur.Parent then
            blur:Destroy()
        end
    end)

    dock.Size = UDim2.fromOffset(dockWidth, 0)
    tween(dock, 0.42, { Size = UDim2.fromOffset(dockWidth, window.Mobile and 290 or 420) }, Enum.EasingStyle.Back)
    return window
end

return Library
