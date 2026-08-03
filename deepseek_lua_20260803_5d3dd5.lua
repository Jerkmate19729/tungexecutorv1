--[[
    Tung Executor v2 – Executor‑Ready (Mobile Optimised)
    Run via loadstring or as an injected script.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Choose parent: CoreGui first, fallback to PlayerGui
local parentGui = CoreGui
if not parentGui then
    parentGui = player:WaitForChild("PlayerGui")
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TungExecutorGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = parentGui

-- ============================================================
--  MAIN FRAME – large, solid, centered
-- ============================================================

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 750, 0, 550)
mainFrame.Position = UDim2.new(0.5, -375, 0.5, -275)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromHex("1A1A1A")
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Border
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromHex("FF5E00")
stroke.Thickness = 3
stroke.Parent = mainFrame

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = mainFrame

-- ============================================================
--  TITLE BAR
-- ============================================================

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromHex("2A2A2A")
titleBar.BackgroundTransparency = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -70, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ Tung Executor v2"
titleLabel.TextColor3 = Color3.fromHex("FF5E00")
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = titleBar

local function makeTitleButton(text, x, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 30, 1, 0)
    btn.Position = UDim2.new(1, x, 0, 0)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = titleBar
    return btn
end

local minButton = makeTitleButton("─", -60, Color3.fromHex("333333"))
local closeButton = makeTitleButton("✕", -30, Color3.fromHex("CC3333"))

-- ============================================================
--  CONTENT
-- ============================================================

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -35)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.FillDirection = Enum.FillDirection.Vertical
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 5)
contentLayout.Parent = contentFrame

-- Input Panel (60%)
local inputPanel = Instance.new("Frame")
inputPanel.Size = UDim2.new(1, 0, 0.6, -10)
inputPanel.BackgroundTransparency = 1
inputPanel.LayoutOrder = 1
inputPanel.Parent = contentFrame

local inputScrolling = Instance.new("ScrollingFrame")
inputScrolling.Size = UDim2.new(1, 0, 1, 0)
inputScrolling.BackgroundColor3 = Color3.fromHex("0F0F0F")
inputScrolling.BackgroundTransparency = 0
inputScrolling.ScrollBarThickness = 6
inputScrolling.Parent = inputPanel

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, 0, 0, 0)
inputBox.AutomaticSize = Enum.AutomaticSize.Y
inputBox.BackgroundTransparency = 1
inputBox.TextWrapped = true
inputBox.TextXAlignment = Enum.TextXAlignment.Left
inputBox.TextYAlignment = Enum.TextYAlignment.Top
inputBox.Font = Enum.Font.SourceCodePro
inputBox.TextSize = 14
inputBox.TextColor3 = Color3.fromRGB(255,255,255)
inputBox.PlaceholderText = "Enter your Luau script here..."
inputBox.ClearTextOnFocus = false
inputBox.MultiLine = true
inputBox.Parent = inputScrolling

-- Controls
local controlsStrip = Instance.new("Frame")
controlsStrip.Size = UDim2.new(1, 0, 0, 34)
controlsStrip.BackgroundTransparency = 1
controlsStrip.LayoutOrder = 2
controlsStrip.Parent = contentFrame

local controlsLayout = Instance.new("UIListLayout")
controlsLayout.FillDirection = Enum.FillDirection.Horizontal
controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
controlsLayout.Padding = UDim.new(0, 12)
controlsLayout.Parent = controlsStrip

local function createControlButton(text, bgColor, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 85, 0, 28)
    btn.BackgroundColor3 = bgColor
    btn.BackgroundTransparency = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    btn.Parent = controlsStrip
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Forward declarations
local executeScript, clearConsole, killScript

local execBtn = createControlButton("Execute", Color3.fromHex("00E676"), function() executeScript() end)
local clearBtn = createControlButton("Clear", Color3.fromHex("D32F2F"), function() clearConsole() end)
local killBtn = createControlButton("Kill", Color3.fromHex("FFB300"), function() killScript() end)

-- Output Panel (40%)
local outputPanel = Instance.new("Frame")
outputPanel.Size = UDim2.new(1, 0, 0.4, -5)
outputPanel.BackgroundTransparency = 1
outputPanel.LayoutOrder = 3
outputPanel.Parent = contentFrame

local outputScrolling = Instance.new("ScrollingFrame")
outputScrolling.Size = UDim2.new(1, 0, 1, 0)
outputScrolling.BackgroundColor3 = Color3.fromHex("0A0A0A")
outputScrolling.BackgroundTransparency = 0
outputScrolling.ScrollBarThickness = 6
outputScrolling.Parent = outputPanel

local outputLabel = Instance.new("TextLabel")
outputLabel.Size = UDim2.new(1, 0, 0, 0)
outputLabel.AutomaticSize = Enum.AutomaticSize.Y
outputLabel.BackgroundTransparency = 1
outputLabel.TextWrapped = true
outputLabel.TextXAlignment = Enum.TextXAlignment.Left
outputLabel.TextYAlignment = Enum.TextYAlignment.Top
outputLabel.RichText = true
outputLabel.Font = Enum.Font.SourceCodePro
outputLabel.TextSize = 13
outputLabel.TextColor3 = Color3.fromRGB(200,200,200)
outputLabel.Parent = outputScrolling

-- Status Bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 22)
statusBar.Position = UDim2.new(0, 0, 1, -22)
statusBar.BackgroundColor3 = Color3.fromHex("111111")
statusBar.BackgroundTransparency = 0
statusBar.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 1, 0)
statusLabel.Position = UDim2.new(0, 5, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "● Ready"
statusLabel.TextColor3 = Color3.fromRGB(0, 230, 118)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = statusBar

-- ============================================================
--  PERSISTENCE
-- ============================================================

local inputSave = Instance.new("StringValue")
inputSave.Name = "InputSave"
inputSave.Value = ""
inputSave.Parent = screenGui

inputBox.Text = inputSave.Value

inputBox:GetPropertyChangedSignal("Text"):Connect(function()
    inputSave.Value = inputBox.Text
    updateInputCanvas()
end)

local function saveInput()
    inputSave.Value = inputBox.Text
end

-- ============================================================
--  CONSOLE FUNCTIONS
-- ============================================================

local function getTimestamp()
    return os.date("[%H:%M:%S]")
end

local function addConsoleLine(text, colorHex)
    if not text or text == "" then return end
    local timestamp = getTimestamp()
    local coloredText = text
    if colorHex then
        coloredText = string.format('<font color="#%s">%s</font>', colorHex, text)
    end
    local newLine = string.format("%s %s", timestamp, coloredText)
    local current = outputLabel.Text
    if current == "" then
        outputLabel.Text = newLine
    else
        outputLabel.Text = current .. "\n" .. newLine
    end
    task.wait(0.01)
    outputScrolling.CanvasPosition = Vector2.new(0, outputScrolling.CanvasSize.Y.Offset)
end

clearConsole = function()
    outputLabel.Text = ""
    outputScrolling.CanvasPosition = Vector2.new(0, 0)
end

local function updateInputCanvas()
    task.wait(0.01)
    inputScrolling.CanvasSize = UDim2.new(0, 0, 0, inputBox.AbsoluteSize.Y)
end
inputBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateInputCanvas)

-- ============================================================
--  GLOBAL OVERRIDES
-- ============================================================

_G.print = function(...)
    local args = {...}
    local msg = table.concat(args, " ")
    addConsoleLine("> " .. msg, "FFFFFF")
end

_G.warn = function(...)
    local args = {...}
    local msg = table.concat(args, " ")
    addConsoleLine("⚠ " .. msg, "FFB300")
end

_G.tung = {
    log = function(msg)
        addConsoleLine("ℹ " .. tostring(msg), "00E5FF")
    end,
    clear = clearConsole,
    getexecutor = function()
        return "Tung Executor v2"
    end
}

-- ============================================================
--  EXECUTION ENGINE
-- ============================================================

local currentCoroutine = nil
local commandHistory = {}
local historyIndex = 0

local function setStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color
end

killScript = function()
    if currentCoroutine and coroutine.status(currentCoroutine) ~= "dead" then
        coroutine.close(currentCoroutine)
        currentCoroutine = nil
        setStatus("● Killed", Color3.fromRGB(255, 179, 0))
        addConsoleLine("✖ Script killed by user", "FFB300")
    else
        setStatus("● No script running", Color3.fromRGB(255, 179, 0))
    end
end

executeScript = function()
    local code = inputBox.Text
    if code == "" then
        setStatus("● No code to execute", Color3.fromRGB(255, 179, 0))
        return
    end

    if #commandHistory == 0 or commandHistory[#commandHistory] ~= code then
        table.insert(commandHistory, code)
        if #commandHistory > 10 then
            table.remove(commandHistory, 1)
        end
    end
    historyIndex = #commandHistory

    if currentCoroutine and coroutine.status(currentCoroutine) ~= "dead" then
        coroutine.close(currentCoroutine)
        currentCoroutine = nil
    end

    setStatus("● Executing...", Color3.fromRGB(255, 94, 0))
    addConsoleLine("▶ Executing script...", "FF5E00")

    local fn, err = loadstring(code)
    if not fn then
        addConsoleLine("✖ Compilation error: " .. err, "FF3333")
        setStatus("● Error", Color3.fromRGB(255, 51, 51))
        return
    end

    currentCoroutine = task.spawn(function()
        local success, result = pcall(fn)
        if not success then
            addConsoleLine("✖ Runtime error: " .. tostring(result), "FF3333")
            setStatus("● Error", Color3.fromRGB(255, 51, 51))
        else
            addConsoleLine("✓ Execution finished", "00E676")
            setStatus("● Ready", Color3.fromRGB(0, 230, 118))
        end
        currentCoroutine = nil
    end)
end

-- ============================================================
--  KEYBOARD SHORTCUTS
-- ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Return and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        executeScript()
        return
    end

    if input.KeyCode == Enum.KeyCode.L and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        clearConsole()
        return
    end

    if input.KeyCode == Enum.KeyCode.UpArrow and input.UserInputType == Enum.UserInputType.Keyboard then
        if #commandHistory > 0 then
            historyIndex = math.max(1, historyIndex - 1)
            inputBox.Text = commandHistory[historyIndex]
            inputBox.CursorPosition = -1
        end
        return
    end
    if input.KeyCode == Enum.KeyCode.DownArrow and input.UserInputType == Enum.UserInputType.Keyboard then
        if #commandHistory > 0 then
            historyIndex = math.min(#commandHistory, historyIndex + 1)
            inputBox.Text = commandHistory[historyIndex]
            inputBox.CursorPosition = -1
        end
        return
    end

    if input.KeyCode == Enum.KeyCode.T and UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
        toggleGUI(not mainFrame.Visible)
        return
    end
end)

-- ============================================================
--  DRAGGING (touch & mouse)
-- ============================================================

local dragData = {dragging = false, startX = 0, startY = 0, startPos = Vector2.new()}

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragData.dragging = true
        dragData.startX = input.Position.X
        dragData.startY = input.Position.Y
        dragData.startPos = mainFrame.Position.Offset
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragData.dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragData.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local deltaX = input.Position.X - dragData.startX
        local deltaY = input.Position.Y - dragData.startY
        local newX = dragData.startPos.X + deltaX
        local newY = dragData.startPos.Y + deltaY
        local screenSize = parentGui.AbsoluteSize
        local frameSize = mainFrame.AbsoluteSize
        newX = math.clamp(newX, 0, screenSize.X - frameSize.X)
        newY = math.clamp(newY, 0, screenSize.Y - frameSize.Y)
        mainFrame.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- ============================================================
--  TOGGLE GUI
-- ============================================================

local guiVisible = true

local function toggleGUI(show)
    guiVisible = show
    if show then
        mainFrame.Visible = true
        uiScale.Scale = 0.9
        local t1 = TweenService:Create(uiScale, TweenInfo.new(0.2), {Scale = 1})
        t1:Play()
        inputBox.Text = inputSave.Value
        updateInputCanvas()
        setStatus("● Ready", Color3.fromRGB(0, 230, 118))
    else
        uiScale.Scale = 1
        local t1 = TweenService:Create(uiScale, TweenInfo.new(0.15), {Scale = 0.8})
        t1:Play()
        t1.Completed:Wait()
        mainFrame.Visible = false
        saveInput()
    end
end

closeButton.MouseButton1Click:Connect(function() toggleGUI(false) end)
minButton.MouseButton1Click:Connect(function() toggleGUI(false) end)

-- ============================================================
--  FLOATING MOBILE BUTTON
-- ============================================================

local mobileBtn = Instance.new("TextButton")
mobileBtn.Size = UDim2.new(0, 56, 0, 56)
mobileBtn.Position = UDim2.new(1, -68, 1, -68)
mobileBtn.AnchorPoint = Vector2.new(1, 1)
mobileBtn.BackgroundColor3 = Color3.fromHex("FF5E00")
mobileBtn.BackgroundTransparency = 0
mobileBtn.Text = "⚡"
mobileBtn.TextColor3 = Color3.fromRGB(255,255,255)
mobileBtn.Font = Enum.Font.GothamBold
mobileBtn.TextSize = 28
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = mobileBtn
mobileBtn.Parent = screenGui

-- Drag for mobile button
local mobileDrag = {dragging = false, startX = 0, startY = 0, startPos = Vector2.new()}

mobileBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mobileDrag.dragging = true
        mobileDrag.startX = input.Position.X
        mobileDrag.startY = input.Position.Y
        mobileDrag.startPos = mobileBtn.Position.Offset
    end
end)

mobileBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mobileDrag.dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if mobileDrag.dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local deltaX = input.Position.X - mobileDrag.startX
        local deltaY = input.Position.Y - mobileDrag.startY
        local newX = mobileDrag.startPos.X + deltaX
        local newY = mobileDrag.startPos.Y + deltaY
        local screenSize = parentGui.AbsoluteSize
        local btnSize = mobileBtn.AbsoluteSize
        newX = math.clamp(newX, 0, screenSize.X - btnSize.X)
        newY = math.clamp(newY, 0, screenSize.Y - btnSize.Y)
        mobileBtn.Position = UDim2.new(0, newX, 0, newY)
    end
end)

mobileBtn.MouseButton1Click:Connect(function() toggleGUI(not mainFrame.Visible) end)
mobileBtn.TouchTap:Connect(function() toggleGUI(not mainFrame.Visible) end)

-- ============================================================
--  FINAL INIT
-- ============================================================

mainFrame.Visible = true
setStatus("● Ready", Color3.fromRGB(0, 230, 118))
task.wait(0.1)
updateInputCanvas()

-- Welcome message
addConsoleLine("⚡ Tung Executor v2 loaded successfully!", "FF5E00")
addConsoleLine("Type your script and press Execute, or use Ctrl+Enter.", "AAAAAA")
addConsoleLine("Tap the ⚡ button to reopen if closed.", "AAAAAA")

-- Save on close
screenGui.AncestryChanged:Connect(function()
    if not screenGui.Parent then
        saveInput()
    end
end)