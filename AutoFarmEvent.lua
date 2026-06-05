-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Remotes (From gemini-code-1780661205300.lua.txt)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GrabBatteryRemote = Remotes:WaitForChild("GrabBatteryRemote")
local UseBatteryOnCrateRemote = Remotes:WaitForChild("UseBatteryOnCrateRemote")

-- Targets
local Terrain = Workspace:WaitForChild("Terrain")

--------------------------------------------------------------------
-- UI INITIALIZATION ("IDIOT HUB")
--------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IdiotHubMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Panel Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 240)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Slightly darker theme
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Top Bar / Hub Title
local hubTitle = Instance.new("TextLabel")
hubTitle.Size = UDim2.new(1, -20, 0, 35)
hubTitle.Position = UDim2.new(0, 12, 0, 5)
hubTitle.BackgroundTransparency = 1
hubTitle.Text = "IDIOT HUB"
hubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
hubTitle.Font = Enum.Font.FredokaOne -- Clean, bold styling
hubTitle.TextSize = 22
hubTitle.TextXAlignment = Enum.TextXAlignment.Left
hubTitle.Parent = mainFrame

-- Divider Line
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -24, 0, 2)
divider.Position = UDim2.new(0, 12, 0, 40)
divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

-- Section Label ("Main Tab" -> "Event Farm")
local sectionLabel = Instance.new("TextLabel")
sectionLabel.Size = UDim2.new(1, -20, 0, 25)
sectionLabel.Position = UDim2.new(0, 12, 0, 50)
sectionLabel.BackgroundTransparency = 1
sectionLabel.Text = "Main Tab > Event Farm"
sectionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
sectionLabel.Font = Enum.Font.SourceSansBold
sectionLabel.TextSize = 14
sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
sectionLabel.Parent = mainFrame

-- Interaction Action Button
local actionButton = Instance.new("TextButton")
actionButton.Size = UDim2.new(0, 260, 0, 50)
actionButton.Position = UDim2.new(0.5, -130, 0.5, 10)
actionButton.Text = "Event Farm: OFF"
actionButton.Font = Enum.Font.SourceSansBold
actionButton.TextSize = 18
actionButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- Red for inactive
actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
actionButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = actionButton

--------------------------------------------------------------------
-- FARMING & TOGGLE LOGIC
--------------------------------------------------------------------
local isEnabled = false -- Tracks toggle state

-- Helper function to safely teleport the character (From gemini-code-1780661205300.lua.txt)
local function teleportTo(attachment)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if rootPart and attachment then
        rootPart.CFrame = CFrame.new(attachment.WorldPosition + Vector3.new(0, 2, 0))[cite: 1]
        task.wait(0.1) -- Sync delay[cite: 1]
        return true
    end
    return false
end

-- Main Automation Loop
task.spawn(function()
    while true do
        -- Only attempt farming routes if the toggle state is true
        if isEnabled then
            -- 1. Grab Battery[cite: 1]
            local batteryAttachment = Terrain:FindFirstChild("BatterySpawnAttachment")[cite: 1]
            if batteryAttachment and isEnabled then
                print("[IDIOT HUB] Moving to Battery...")
                if teleportTo(batteryAttachment) then[cite: 1]
                    GrabBatteryRemote:FireServer(batteryAttachment)[cite: 1]
                    task.wait(0.5) -- Cooldown[cite: 1]
                end
            end

            -- 2. Deposit Battery into Crate[cite: 1]
            local crateAttachment = Terrain:FindFirstChild("EggCrateSpawnAttachment")[cite: 1]
            if crateAttachment and isEnabled then
                print("[IDIOT HUB] Moving to Deposit Crate...")
                if teleportTo(crateAttachment) then[cite: 1]
                    UseBatteryOnCrateRemote:FireServer(crateAttachment)[cite: 1]
                    task.wait(0.5) -- Cooldown[cite: 1]
                end
            end
        end

        task.wait(0.1) -- Performance throttle loop[cite: 1]
    end
end)

-- Button Event Handler
actionButton.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    
    if isEnabled then
        actionButton.BackgroundColor3 = Color3.fromRGB(0, 150, 136) -- Teal for active
        actionButton.Text = "Event Farm: ON"
    else
        actionButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- Red for inactive
        actionButton.Text = "Event Farm: OFF"
    end
end)
