-- [[ Redz UI Library Setup ]]
local RedzLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDZ7/Extremum/main/JuiceLib.lua"))()

local Window = RedzLib:CreateWindow({
    Name = "Mobile Automation",
    SubName = "by Gemini",
    Discord = ""
})

-- [[ Services & Remotes ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GrabBatteryRemote = Remotes:WaitForChild("GrabBatteryRemote") [cite: 1]
local UseBatteryOnCrateRemote = Remotes:WaitForChild("UseBatteryOnCrateRemote") [cite: 1]
local Terrain = Workspace:WaitForChild("Terrain") [cite: 1]

-- [[ Global State ]]
getgenv().EventFarmActive = false

-- [[ Safe Teleportation Mechanics ]]
local function teleportTo(attachment)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart") [cite: 1]
    
    if rootPart and attachment then [cite: 1]
        -- Offset to prevent mobile physics clipping or rubberbanding
        rootPart.CFrame = CFrame.new(attachment.WorldPosition + Vector3.new(0, 2, 0)) [cite: 1]
        task.wait(0.1) [cite: 2]
        return true
    end
    return false [cite: 2]
end

-- [[ Dedicated Farming Thread ]]
task.spawn(function()
    while true do
        if getgenv().EventFarmActive then
            -- Phase 1: Retrieve Battery
            local batteryAttachment = Terrain:FindFirstChild("BatterySpawnAttachment") [cite: 2]
            if batteryAttachment and getgenv().EventFarmActive then
                if teleportTo(batteryAttachment) then [cite: 2]
                    GrabBatteryRemote:FireServer(batteryAttachment) [cite: 3]
                    task.wait(0.5) [cite: 3]
                end
            end

            -- Phase 2: Deposit Battery
            local crateAttachment = Terrain:FindFirstChild("EggCrateSpawnAttachment") [cite: 3]
            if crateAttachment and getgenv().EventFarmActive then
                if teleportTo(crateAttachment) then [cite: 4]
                    UseBatteryOnCrateRemote:FireServer(crateAttachment) [cite: 4]
                    task.wait(0.5) [cite: 4]
                end
            end
        end
        task.wait(0.2) -- Low-overhead idle throttle for mobile performance [cite: 4]
    end
end)

-- [[ UI Elements Construction ]]
local MainTab = Window:CreateTab("Main")

MainTab:CreateSection("Event Farm")

MainTab:CreateToggle({
    Name = "Auto Farm Batteries",
    Default = false,
    Callback = function(Value)
        getgenv().EventFarmActive = Value
    end
})
