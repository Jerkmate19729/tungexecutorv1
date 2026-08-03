--[[
    Tung Executor v2 – Ultra‑Robust for Delta Mobile
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create a ScreenGui with the highest display order
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TungExecutorGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

-- ========================================================================
-- MAIN FRAME – large, centered, fully opaque
-- ========================================================================

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.8, 0, 0.75, 0)   -- 80% width, 75% height
mainFrame.Position = UDim2.new(0.1, 0, 0.125, 0) -- centered
mainFrame.BackgroundColor3 = Color3.fromHex("1A1A1A")
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Orange border
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromHex("FF5E00")
stroke.Thickness = 3
stroke.Parent = mainFrame

-- ========================================================================
-- TITLE BAR (solid)
-- ========================================================================

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
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
titleLabel.TextSize = 20
titleLabel.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 35, 1, 0)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.BackgroundColor3 = Color3.fromHex("CC3333")
closeButton.BackgroundTransparency = 0
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = titleBar

-- ========================================================================
-- CONTENT: Simple layout with big text for visibility
-- ========================================================================

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- A big label to show it's working
local bigLabel = Instance.new("TextLabel")
bigLabel.Size = UDim2.new(1, 0, 0.3, 0)
bigLabel.Position = UDim2.new(0, 0, 0.1, 0)
bigLabel.BackgroundTransparency = 1
bigLabel.Text = "TUNG EXECUTOR"
bigLabel.TextColor3 = Color3.fromHex("FF5E00")
bigLabel.TextScaled = true
bigLabel.Font = Enum.Font.GothamBold
bigLabel.Parent = contentFrame

-- Subtitle
local subLabel = Instance.new("TextLabel")
subLabel.Size = UDim2.new(1, 0, 0.15, 0)
subLabel.Position = UDim2.new(0, 0, 0.45, 0)
subLabel.BackgroundTransparency = 1
subLabel.Text = "Ready"
subLabel.TextColor3 = Color3.fromRGB(200,200,200)
subLabel.TextScaled = true
subLabel.Font = Enum.Font.Gotham
subLabel.Parent = contentFrame

-- A button to toggle the full UI later (placeholder)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.3, 0, 0.1, 0)
toggleBtn.Position = UDim2.new(0.35, 0, 0.7, 0)
toggleBtn.BackgroundColor3 = Color3.fromHex("00E676")
toggleBtn.BackgroundTransparency = 0
toggleBtn.Text = "Open Console"
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextScaled = true
toggleBtn.Parent = contentFrame

-- ========================================================================
--  MINIMAL FUNCTIONS (for demonstration)
-- ========================================================================

local function toggleFullUI()
    -- For now, just print to console
    print("Tung Executor: Opening full console...")
    -- Here you would show the full input/output panels
    -- For now, we just show a message on the big label
    bigLabel.Text = "Full UI Coming Soon"
    subLabel.Text = "Tap the floating ⚡ button to reopen"
end

toggleBtn.MouseButton1Click:Connect(toggleFullUI)

-- ========================================================================
--  FLOATING MOBILE BUTTON (to toggle GUI)
-- ========================================================================

local mobileBtn = Instance.new("TextButton")
mobileBtn.Size = UDim2.new(0, 60, 0, 60)
mobileBtn.Position = UDim2.new(1, -75, 1, -75)
mobileBtn.AnchorPoint = Vector2.new(1, 1)
mobileBtn.BackgroundColor3 = Color3.fromHex("FF5E00")
mobileBtn.BackgroundTransparency = 0
mobileBtn.Text = "⚡"
mobileBtn.TextColor3 = Color3.fromRGB(255,255,255)
mobileBtn.Font = Enum.Font.GothamBold
mobileBtn.TextSize = 32
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = mobileBtn
mobileBtn.Parent = screenGui

-- Draggable for mobile
local dragData = {dragging = false, startX = 0, startY = 0, startPos = Vector2.new()}

mobileBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = true
        dragData.startX = input.Position.X
        dragData.startY = input.Position.Y
        dragData.startPos = mobileBtn.Position.Offset
    end
end)

mobileBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragData.dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local deltaX = input.Position.X - dragData.startX
        local deltaY = input.Position.Y - dragData.startY
        local newX = dragData.startPos.X + deltaX
        local newY = dragData.startPos.Y + deltaY
        local screenSize = playerGui.AbsoluteSize
        local btnSize = mobileBtn.AbsoluteSize
        newX = math.clamp(newX, 0, screenSize.X - btnSize.X)
        newY = math.clamp(newY, 0, screenSize.Y - btnSize.Y)
        mobileBtn.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- Toggle GUI visibility
local guiVisible = true

mobileBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
end)

mobileBtn.TouchTap:Connect(function()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
end)

-- Close button hides main frame
closeButton.MouseButton1Click:Connect(function()
    guiVisible = false
    mainFrame.Visible = false
end)

-- ========================================================================
--  FINAL INIT – show a console message
-- ========================================================================

print("⚡ Tung Executor v2 loaded successfully on Delta!")

-- Make sure the main frame is visible
mainFrame.Visible = true

-- Optional: show a message in the big label
bigLabel.Text = "Tung Executor v2"
subLabel.Text = "Tap 'Open Console' to expand"

-- Done