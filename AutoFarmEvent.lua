-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GrabBatteryRemote = Remotes:WaitForChild("GrabBatteryRemote")
local UseBatteryOnCrateRemote = Remotes:WaitForChild("UseBatteryOnCrateRemote")

-- Targets
local Terrain = Workspace:WaitForChild("Terrain")

--------------------------------------------------------------------
-- UI INITIALIZATION (Main Tab -> Event Farm Section)
--------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameSettingsMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Panel Frame ("Main Tab" container)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 220)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Section Title Label ("Event Farm")
local sectionLabel = Instance.new("TextLabel")
sectionLabel.Size = UDim2.new(1, -20, 0, 30)
sectionLabel.Position = UDim2.new(0, 10, 0, 10)
sectionLabel.BackgroundTransparency = 1
sectionLabel.Text = "Main Tab — Event Farm"
sectionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
sectionLabel.Font = Enum.Font.SourceSansBold
sectionLabel.TextSize = 18
sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
sectionLabel.Parent = mainFrame

-- Action Button for Toggle
local actionButton = Instance.new("TextButton")
actionButton.Size = UDim2.new(0, 240, 0, 50)
actionButton.Position = UDim2.new(0.5, -120, 0.5, -10)
actionButton.Text = "Farm Status: OFF"
actionButton.Font = Enum.Font.SourceSansBold
actionButton.TextSize = 18
actionButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- Start red for OFF
actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
actionButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = actionButton

--------------------------------------------------------------------
-- FARMING LOGIC
--------------------------------------------------------------------
local isEnabled = false -- Global control state for the farm loop

-- Helper function to safely teleport the character
local function teleportTo(attachment)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if rootPart and attachment then
        -- Teleport slightly above the attachment position to prevent clipping
        rootPart.CFrame = CFrame.new(attachment.WorldPosition + Vector3.new(0, 2, 0))
        task.wait(0.1) -- Small delay to allow physics/position to sync
        return true
    end
    return false
end

-- Main Automation Loop
task.spawn(function()
    while true do
        -- Only execute farm actions if the UI switch is turned ON
        if isEnabled then
            -- 1. Grab Battery
            local batteryAttachment = Terrain:FindFirstChild("BatterySpawnAttachment")
            if batteryAttachment and isEnabled then -- Secondary check if toggled off mid-loop
                print("Teleporting to Battery...")
                if teleportTo(batteryAttachment) then
                    GrabBatteryRemote:FireServer(batteryAttachment)
                    task.wait(0.5) -- Cooldown after picking up
                end
            end

            -- 2. Deposit Battery into Crate
            local crateAttachment = Terrain:FindFirstChild("EggCrateSpawnAttachment")
            if crateAttachment and isEnabled then -- Secondary check if toggled off mid-loop
                print("Teleporting to Deposit Crate...")
                if teleportTo(crateAttachment) then
                    UseBatteryOnCrateRemote:FireServer(crateAttachment)
                    task.wait(0.5) -- Cooldown after depositing
                end
            end
        end

        task.wait(0.1) -- Loop throttle to prevent game crashes
    end
end)

--------------------------------------------------------------------
-- UI INTERACTION LINKING
--------------------------------------------------------------------
actionButton.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    
    if isEnabled then
        actionButton.BackgroundColor3 = Color3.fromRGB(0, 150, 136) -- Teal color accent for ON
        actionButton.Text = "Farm Status: ON"
        print("Event Farm Activated.")
    else
        actionButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- Red for OFF
        actionButton.Text = "Farm Status: OFF"
        print("Event Farm Deactivated.")
    end
end)
