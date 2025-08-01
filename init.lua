local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ModuleListGUI = {}
ModuleListGUI.__index = ModuleListGUI

local CONFIG = {
    ITEM_HEIGHT = 35,
    ITEM_PADDING = 2,
    HEADER_HEIGHT = 40,
    WINDOW_WIDTH = 200,
    WINDOW_SPACING = 220,
    ANIMATION_TIME = 0.3,
    COLORS = {
        BACKGROUND = Color3.fromRGB(25, 25, 35),
        HEADER = Color3.fromRGB(120, 70, 200),
        ITEM = Color3.fromRGB(40, 40, 50),
        ITEM_HOVER = Color3.fromRGB(50, 50, 60),
        TEXT = Color3.fromRGB(255, 255, 255),
        TEXT_SECONDARY = Color3.fromRGB(200, 200, 200),
        DOTS = Color3.fromRGB(150, 150, 150)
    }
}

function ModuleListGUI.new(title)
    title = title or "Modules"
    local self = setmetatable({}, ModuleListGUI)
    self.title = title
    self.categories = {}
    self.gui = nil
    self.isVisible = false
    self:createMainGUI()
    return self
end

function ModuleListGUI:createMainGUI()
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "ModuleListGUI"
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.gui.Parent = playerGui
end

function ModuleListGUI:createCategoryWindow(categoryName, windowIndex)
    local startX = 0.1 + (windowIndex * 0.15)
    local startY = 0.2

    local windowFrame = Instance.new("Frame")
    windowFrame.Name = "CategoryWindow_" .. categoryName
    windowFrame.Size = UDim2.new(0, CONFIG.WINDOW_WIDTH, 0, 400)
    windowFrame.Position = UDim2.new(startX, 0, startY, 0)
    windowFrame.BackgroundColor3 = CONFIG.COLORS.BACKGROUND
    windowFrame.BorderSizePixel = 0
    windowFrame.Parent = self.gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = windowFrame

    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 4, 1, 4)
    shadow.Position = UDim2.new(0, -2, 0, -2)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.ZIndex = windowFrame.ZIndex - 1
    shadow.Parent = windowFrame

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadow

    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.Size = UDim2.new(1, 0, 0, CONFIG.HEADER_HEIGHT)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundColor3 = CONFIG.COLORS.HEADER
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = windowFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = headerFrame

    local headerBottomFix = Instance.new("Frame")
    headerBottomFix.Size = UDim2.new(1, 0, 0, 10)
    headerBottomFix.Position = UDim2.new(0, 0, 1, -10)
    headerBottomFix.BackgroundColor3 = CONFIG.COLORS.HEADER
    headerBottomFix.BorderSizePixel = 0
    headerBottomFix.Parent = headerFrame

    local headerLabel = Instance.new("TextLabel")
    headerLabel.Name = "HeaderLabel"
    headerLabel.Size = UDim2.new(1, -20, 1, 0)
    headerLabel.Position = UDim2.new(0, 10, 0, 0)
    headerLabel.BackgroundTransparency = 1
    headerLabel.Text = categoryName
    headerLabel.TextColor3 = CONFIG.COLORS.TEXT
    headerLabel.TextSize = 16
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.Font = Enum.Font.SourceSansBold
    headerLabel.Parent = headerFrame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ModuleList"
    scrollFrame.Size = UDim2.new(1, -10, 1, -CONFIG.HEADER_HEIGHT - 10)
    scrollFrame.Position = UDim2.new(0, 5, 0, CONFIG.HEADER_HEIGHT + 5)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = CONFIG.COLORS.HEADER
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = windowFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, CONFIG.ITEM_PADDING)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrollFrame

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentHeight = listLayout.AbsoluteContentSize.Y
        local windowHeight = math.min(contentHeight + CONFIG.HEADER_HEIGHT + 20, 500)
        windowFrame.Size = UDim2.new(0, CONFIG.WINDOW_WIDTH, 0, windowHeight)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 10)
    end)

    self:makeDraggable(windowFrame, headerFrame)

    return {
        windowFrame = windowFrame,
        scrollFrame = scrollFrame,
        listLayout = listLayout,
        modules = {},
        moduleCount = 0,
        isVisible = false
    }
end

function ModuleListGUI:makeDraggable(windowFrame, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = windowFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            windowFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function ModuleListGUI:addCategory(name)
    if not name or name == "" then return false end

    for _, cat in pairs(self.categories) do
        if cat.name == name then return false end
    end

    local windowIndex = #self.categories
    local categoryWindow = self:createCategoryWindow(name, windowIndex)

    table.insert(self.categories, {
        name = name,
        window = categoryWindow,
        modules = {}
    })

    return true
end

function ModuleListGUI:addModule(categoryName, moduleName, callback, enabled)
    if not categoryName or categoryName == "" then return false end
    if not moduleName or moduleName == "" then return false end

    enabled = enabled or false
    callback = callback or function() end

    local categoryData
    for _, cat in pairs(self.categories) do
        if cat.name == categoryName then
            categoryData = cat
            break
        end
    end
    if not categoryData then return false end

    local window = categoryData.window
    window.moduleCount = window.moduleCount + 1

    local moduleFrame = Instance.new("TextButton")
    moduleFrame.Name = "Module_" .. moduleName
    moduleFrame.Size = UDim2.new(1, 0, 0, CONFIG.ITEM_HEIGHT)
    moduleFrame.BackgroundColor3 = CONFIG.COLORS.ITEM
    moduleFrame.BorderSizePixel = 0
    moduleFrame.Text = ""
    moduleFrame.LayoutOrder = window.moduleCount
    moduleFrame.Parent = window.scrollFrame

    local moduleCorner = Instance.new("UICorner")
    moduleCorner.CornerRadius = UDim.new(0, 4)
    moduleCorner.Parent = moduleFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -50, 1, 0)
    nameLabel.Position = UDim2.new(0, 15, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = moduleName
    nameLabel.TextColor3 = CONFIG.COLORS.TEXT
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.Parent = moduleFrame

    local dotsLabel = Instance.new("TextLabel")
    dotsLabel.Name = "DotsLabel"
    dotsLabel.Size = UDim2.new(0, 30, 1, 0)
    dotsLabel.Position = UDim2.new(1, -35, 0, 0)
    dotsLabel.BackgroundTransparency = 1
    dotsLabel.Text = "⋮"
    dotsLabel.TextColor3 = CONFIG.COLORS.DOTS
    dotsLabel.TextSize = 16
    dotsLabel.TextXAlignment = Enum.TextXAlignment.Center
    dotsLabel.Font = Enum.Font.SourceSansBold
    dotsLabel.Parent = moduleFrame

    local moduleData = {
        name = moduleName,
        callback = callback,
        enabled = enabled,
        frame = moduleFrame,
        nameLabel = nameLabel,
        category = categoryName
    }

    table.insert(window.modules, moduleData)
    table.insert(categoryData.modules, moduleData)

    self:addHoverEffect(moduleFrame, moduleData)

    moduleFrame.MouseButton1Click:Connect(function()
        self:toggleModule(moduleData)
    end)

    self:updateModuleAppearance(moduleData)

    return true
end

function ModuleListGUI:toggleModule(moduleData)
    if not moduleData then return end
    moduleData.enabled = not moduleData.enabled
    if moduleData.callback then
        pcall(moduleData.callback, moduleData.enabled)
    end
    self:updateModuleAppearance(moduleData)
end

function ModuleListGUI:updateModuleAppearance(moduleData)
    if not moduleData or not moduleData.frame or not moduleData.nameLabel then return end
    if moduleData.enabled then
        moduleData.frame.BackgroundColor3 = Color3.new(0.47, 0.27, 0.78)
        moduleData.nameLabel.TextColor3 = CONFIG.COLORS.TEXT
    else
        moduleData.frame.BackgroundColor3 = CONFIG.COLORS.ITEM
        moduleData.nameLabel.TextColor3 = CONFIG.COLORS.TEXT_SECONDARY
    end
end

function ModuleListGUI:addHoverEffect(frame, moduleData)
    if not frame or not moduleData then return end

    frame.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = CONFIG.COLORS.ITEM_HOVER
        }):Play()
    end)

    frame.MouseLeave:Connect(function()
        local targetColor = moduleData.enabled and Color3.new(0.47, 0.27, 0.78) or CONFIG.COLORS.ITEM
        TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = targetColor
        }):Play()
    end)
end

function ModuleListGUI:show()
    if self.isVisible then return end
    self.isVisible = true

    for _, categoryData in pairs(self.categories) do
        local window = categoryData.window
        if window and window.windowFrame then
            local targetPos = window.windowFrame.Position
            window.windowFrame.Position = UDim2.new(-1, 0, targetPos.Y.Scale, targetPos.Y.Offset)
            TweenService:Create(window.windowFrame, TweenInfo.new(CONFIG.ANIMATION_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = targetPos
            }):Play()
            window.isVisible = true
        end
    end
end

function ModuleListGUI:hide()
    if not self.isVisible then return end
    self.isVisible = false

    for _, categoryData in pairs(self.categories) do
        local window = categoryData.window
        if window and window.windowFrame and window.isVisible then
            TweenService:Create(window.windowFrame, TweenInfo.new(CONFIG.ANIMATION_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(-1, 0, window.windowFrame.Position.Y.Scale, window.windowFrame.Position.Y.Offset)
            }):Play()
            window.isVisible = false
        end
    end
end

function ModuleListGUI:toggle()
    if self.isVisible then
        self:hide()
    else
        self:show()
    end
end

function ModuleListGUI:toggleCategory(categoryName)
    for _, categoryData in pairs(self.categories) do
        if categoryData.name == categoryName then
            local window = categoryData.window
            if window.isVisible then
                TweenService:Create(window.windowFrame, TweenInfo.new(CONFIG.ANIMATION_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Position = UDim2.new(-1, 0, window.windowFrame.Position.Y.Scale, window.windowFrame.Position.Y.Offset)
                }):Play()
                window.isVisible = false
            else
                local targetPos = window.windowFrame.Position
                window.windowFrame.Position = UDim2.new(-1, 0, targetPos.Y.Scale, targetPos.Y.Offset)
                TweenService:Create(window.windowFrame, TweenInfo.new(CONFIG.ANIMATION_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = targetPos
                }):Play()
                window.isVisible = true
            end
            break
        end
    end
end

return ModuleListGUI
