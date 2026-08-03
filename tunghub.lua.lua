--[[
    Tung Executor v2
    A premium, standalone command console and script execution environment.
    Features: Acrylic/Glassmorphism UI, command history, global print/warn redirection,
    custom Tung API, execution safety with kill switch, and persistence.
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Save original print/warn to preserve them for internal use
local _originalPrint = print
local _originalWarn = warn

-- ============================================================================
--  GUI Construction
-- ============================================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TungExecutorGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame (Glassmorphism)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 700, 0, 500)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromHex("0F0F0F")
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- UI Corner & Stroke
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromHex("2A2A2A")
stroke.Thickness = 2
stroke.Transparency = 0.5
stroke.Parent = mainFrame

-- UIScale for animations
local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ Tung Executor v2"
titleLabel.TextColor3 = Color3.fromHex("FF5E00")
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = titleBar

local minButton = Instance.new("TextButton")
minButton.Size = UDim2.new(0, 30, 1, 0)
minButton.Position = UDim2.new(1, -60, 0, 0)
minButton.BackgroundTransparency = 1
minButton.Text = "─"
minButton.TextColor3 = Color3.fromRGB(200, 200, 200)
minButton.Font = Enum.Font.GothamBold
minButton.TextSize = 16
minButton.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 1, 0)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = titleBar

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.FillDirection = Enum.FillDirection.Vertical
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 0)
contentLayout.Parent = contentFrame

-- Input Panel (60%)
local inputPanel = Instance.new("Frame")
inputPanel.Size = UDim2.new(1, 0, 0.6, -15) -- 60% minus half of controls gap
inputPanel.BackgroundTransparency = 1
inputPanel.LayoutOrder = 1
inputPanel.Parent = contentFrame

local inputScrolling = Instance.new("ScrollingFrame")
inputScrolling.Size = UDim2.new(1, 0, 1, 0)
inputScrolling.BackgroundTransparency = 1
inputScrolling.ScrollBarThickness = 4
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
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.PlaceholderText = "Enter your Luau script here..."
inputBox.ClearTextOnFocus = false
inputBox.MultiLine = true
inputBox.Parent = inputScrolling

-- Control Strip
local controlsStrip = Instance.new("Frame")
controlsStrip.Size = UDim2.new(1, 0, 0, 30)
controlsStrip.BackgroundTransparency = 1
controlsStrip.LayoutOrder = 2
controlsStrip.Parent = contentFrame

local controlsLayout = Instance.new("UIListLayout")
controlsLayout.FillDirection = Enum.FillDirection.Horizontal
controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
controlsLayout.Padding = UDim.new(0, 10)
controlsLayout.Parent = controlsStrip

-- Helper to create a button
local function createButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 24)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.1
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = true
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    btn.Parent = controlsStrip
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local executeBtn = createButton("Execute", Color3.fromHex("00E676"), function()
    executeScript()
end)
-- Glow effect for execute
local glowStroke = Instance.new("UIStroke")
glowStroke.Color = Color3.fromHex("00E676")
glowStroke.Thickness = 1
glowStroke.Transparency = 0.5
glowStroke.Parent = executeBtn

local clearBtn = createButton("Clear", Color3.fromHex("D32F2F"), function()
    clearConsole()
end)

local killBtn = createButton("Kill", Color3.fromHex("FFB300"), function()
    killScript()
end)

-- Output Panel (40%)
local outputPanel = Instance.new("Frame")
outputPanel.Size = UDim2.new(1, 0, 0.4, -15)
outputPanel.BackgroundTransparency = 1
outputPanel.LayoutOrder = 3
outputPanel.Parent = contentFrame

local outputScrolling = Instance.new("ScrollingFrame")
outputScrolling.Size = UDim2.new(1, 0, 1, 0)
outputScrolling.BackgroundTransparency = 1
outputScrolling.ScrollBarThickness = 4
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
outputLabel.TextSize = 14
outputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
outputLabel.Parent = outputScrolling

-- Status Bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 20)
statusBar.Position = UDim2.new(0, 0, 1, -20)
statusBar.BackgroundColor3 = Color3.fromHex("1A1A1A")
statusBar.BackgroundTransparency = 0.5
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

-- ============================================================================
--  Persistence (Input Save)
-- ============================================================================

local inputSave = Instance.new("StringValue")
inputSave.Name = "InputSave"
inputSave.Value = ""
inputSave.Parent = screenGui

-- Load saved input when GUI opens
inputBox.Text = inputSave.Value

-- Save input on change
inputBox:GetPropertyChangedSignal("Text"):Connect(function()
    inputSave.Value = inputBox.Text
    -- Update canvas size for scrolling
    updateInputCanvas()
end)

-- Also save on close
local function saveInput()
    inputSave.Value = inputBox.Text
end

-- ============================================================================
--  Console Output Functions
-- ============================================================================

-- Timestamp formatter
local function getTimestamp()
    return os.date("[%H:%M:%S]")
end

-- Add a line to the console with optional color (hex string)
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
    -- Auto-scroll to bottom
    task.wait(0.01) -- allow update
    outputScrolling.CanvasPosition = Vector2.new(0, outputScrolling.CanvasSize.Y.Offset)
end

-- Clear console
local function clearConsole()
    outputLabel.Text = ""
    outputScrolling.CanvasPosition = Vector2.new(0, 0)
end

-- Update input scrolling canvas
local function updateInputCanvas()
    -- Wait for layout to update
    task.wait(0.01)
    inputScrolling.CanvasSize = UDim2.new(0, 0, 0, inputBox.AbsoluteSize.Y)
    -- Keep scroll at bottom if near bottom, else stay
    -- We'll just set to top initially, but user can scroll.
end

-- Listen to input size changes (triggered by text changes)
inputBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateInputCanvas)

-- ============================================================================
--  Override print and warn globally
-- ============================================================================

-- Store original overrides in local variables
local originalPrint = print
local originalWarn = warn

-- Override print
_G.print = function(...)
    local args = {...}
    local msg = table.concat(args, " ")
    addConsoleLine("> " .. msg, "FFFFFF") -- white
end

-- Override warn
_G.warn = function(...)
    local args = {...}
    local msg = table.concat(args, " ")
    addConsoleLine("⚠ " .. msg, "FFB300") -- yellow/orange
end

-- ============================================================================
--  Custom Tung API
-- ============================================================================

_G.tung = {
    log = function(msg)
        addConsoleLine("ℹ " .. tostring(msg), "00E5FF") -- cyan
    end,
    clear = function()
        clearConsole()
    end,
    getexecutor = function()
        return "Tung Executor v2"
    end
}

-- ============================================================================
--  Execution Engine
-- ============================================================================

local currentCoroutine = nil
local isExecuting = false
local commandHistory = {}
local historyIndex = 0

-- Status update
local function setStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color
end

-- Kill current script
local function killScript()
    if currentCoroutine and coroutine.status(currentCoroutine) ~= "dead" then
        coroutine.close(currentCoroutine)
        currentCoroutine = nil
        isExecuting = false
        setStatus("● Killed", Color3.fromRGB(255, 179, 0))
        addConsoleLine("✖ Script killed by user", "FFB300")
    else
        setStatus("● No script running", Color3.fromRGB(255, 179, 0))
    end
end

-- Execute script
local function executeScript()
    local code = inputBox.Text
    if code == "" then
        setStatus("● No code to execute", Color3.fromRGB(255, 179, 0))
        return
    end

    -- Save to history (avoid duplicates)
    if #commandHistory == 0 or commandHistory[#commandHistory] ~= code then
        table.insert(commandHistory, code)
        if #commandHistory > 10 then
            table.remove(commandHistory, 1)
        end
    end
    historyIndex = #commandHistory

    -- Kill any previous running script
    if currentCoroutine and coroutine.status(currentCoroutine) ~= "dead" then
        coroutine.close(currentCoroutine)
        currentCoroutine = nil
    end

    setStatus("● Executing...", Color3.fromRGB(255, 94, 0))
    addConsoleLine("▶ Executing script...", "FF5E00")
    isExecuting = true

    -- Compile code
    local fn, err = loadstring(code)
    if not fn then
        addConsoleLine("✖ Compilation error: " .. err, "FF3333")
        setStatus("● Error", Color3.fromRGB(255, 51, 51))
        isExecuting = false
        return
    end

    -- Spawn the coroutine
    currentCoroutine = task.spawn(function()
        local success, result = pcall(fn)
        isExecuting = false
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

-- ============================================================================
--  Keyboard Shortcuts
-- ============================================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Ctrl + Enter: Execute
    if input.KeyCode == Enum.KeyCode.Return and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        executeScript()
        return
    end

    -- Ctrl + L: Clear console
    if input.KeyCode == Enum.KeyCode.L and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        clearConsole()
        return
    end

    -- Up / Down: History cycling (only if input box is focused?)
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

    -- RightShift + T: Toggle GUI visibility (reopen if hidden)
    if input.KeyCode == Enum.KeyCode.T and UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
        toggleGUI(not mainFrame.Visible)
        return
    end
end)

-- ============================================================================
--  Dragging (Title Bar)
-- ============================================================================

local dragData = {dragging = false, startX = 0, startY = 0, startPos = Vector2.new()}

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = true
        dragData.startX = input.Position.X
        dragData.startY = input.Position.Y
        dragData.startPos = mainFrame.Position.Offset
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragData.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local deltaX = input.Position.X - dragData.startX
        local deltaY = input.Position.Y - dragData.startY
        local newX = dragData.startPos.X + deltaX
        local newY = dragData.startPos.Y + deltaY
        -- Clamp to screen edges (respect IgnoreGuiInset = true)
        local screenSize = playerGui.AbsoluteSize
        local frameSize = mainFrame.AbsoluteSize
        newX = math.clamp(newX, 0, screenSize.X - frameSize.X)
        newY = math.clamp(newY, 0, screenSize.Y - frameSize.Y)
        mainFrame.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- ============================================================================
--  GUI Visibility & Animations
-- ============================================================================

local guiVisible = true

local function toggleGUI(show)
    guiVisible = show
    if show then
        mainFrame.Visible = true
        -- Tween in: scale from 0.9 to 1, opacity from 0 to 1
        uiScale.Scale = 0.9
        mainFrame.BackgroundTransparency = 0.8
        local tween1 = TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1})
        local tween2 = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15})
        tween1:Play()
        tween2:Play()
        -- Load saved input
        inputBox.Text = inputSave.Value
        updateInputCanvas()
        setStatus("● Ready", Color3.fromRGB(0, 230, 118))
    else
        -- Tween out: scale to 0.8 and fade
        uiScale.Scale = 1
        local tween1 = TweenService:Create(uiScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.8})
        local tween2 = TweenService:Create(mainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 0.8})
        tween1:Play()
        tween2:Play()
        tween1.Completed:Wait()
        mainFrame.Visible = false
        saveInput()
    end
end

-- Close / Minimize buttons
closeButton.MouseButton1Click:Connect(function()
    toggleGUI(false)
end)

minButton.MouseButton1Click:Connect(function()
    toggleGUI(false)
end)

-- ============================================================================
--  Mobile Toggle Button (Floating, draggable)
-- ============================================================================

local mobileBtn = Instance.new("TextButton")
mobileBtn.Size = UDim2.new(0, 50, 0, 50)
mobileBtn.Position = UDim2.new(1, -60, 1, -60)
mobileBtn.AnchorPoint = Vector2.new(1, 1)
mobileBtn.BackgroundColor3 = Color3.fromHex("FF5E00")
mobileBtn.BackgroundTransparency = 0.2
mobileBtn.Text = "⚡"
mobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileBtn.Font = Enum.Font.GothamBold
mobileBtn.TextSize = 24
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = mobileBtn
local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromHex("FF5E00")
btnStroke.Thickness = 2
btnStroke.Transparency = 0.5
btnStroke.Parent = mobileBtn
mobileBtn.Parent = screenGui

-- Mobile button draggable (same logic)
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
        local screenSize = playerGui.AbsoluteSize
        local btnSize = mobileBtn.AbsoluteSize
        newX = math.clamp(newX, 0, screenSize.X - btnSize.X)
        newY = math.clamp(newY, 0, screenSize.Y - btnSize.Y)
        mobileBtn.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- Toggle GUI on click
mobileBtn.MouseButton1Click:Connect(function()
    toggleGUI(not mainFrame.Visible)
end)

-- Also handle touch
mobileBtn.TouchTap:Connect(function()
    toggleGUI(not mainFrame.Visible)
end)

-- ============================================================================
--  Initial Setup & Cleanup
-- ============================================================================

-- Ensure GUI is visible initially
mainFrame.Visible = true
setStatus("● Ready", Color3.fromRGB(0, 230, 118))

-- Update input canvas after a moment
task.wait(0.1)
updateInputCanvas()

-- When GUI is closed via close button, save input
screenGui.AncestryChanged:Connect(function()
    if not screenGui.Parent then
        saveInput()
    end
end)

-- Override the Close button to also save
closeButton.MouseButton1Click:Connect(saveInput)

-- Done