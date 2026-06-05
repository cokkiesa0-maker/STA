-- [[ Rayfield UI Bootstrapper ]]
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Automation Hub",
    LoadingTitle = "Mobile Interface",
    LoadingSubtitle = "by Gemini",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

-- [[ Services & Remotes ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GrabBatteryRemote = Remotes:WaitForChild("GrabBatteryRemote")[cite: 1]
local UseBatteryOnCrateRemote = Remotes:WaitForChild("UseBatteryOnCrateRemote")[cite: 1]
local Terrain = Workspace:WaitForChild("Terrain")[cite: 1]

-- [[ State Control ]]
getgenv().EventFarmActive = false

-- [[ Teleport Mechanical Helper ]]
local function teleportTo(attachment)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")[cite: 1]
    
    if rootPart and attachment then[cite: 1]
        rootPart.CFrame = CFrame.new(attachment.WorldPosition + Vector3.new(0, 2, 0))[cite: 1]
        task.wait(0.1)[cite: 1]
        return true
    end
    return false
end

-- [[ Dedicated Worker Loop ]]
task.spawn(function()
    while true do
        if getgenv().EventFarmActive then
            -- 1. Grab Battery Sequence
            local batteryAttachment = Terrain:FindFirstChild("BatterySpawnAttachment")[cite: 1]
            if batteryAttachment and getgenv().EventFarmActive then
                if teleportTo(batteryAttachment) then[cite: 1]
                    GrabBatteryRemote:FireServer(batteryAttachment)[cite: 1]
                    task.wait(0.5)[cite: 1]
                end
            end

            -- 2. Deposit Battery Sequence
            local crateAttachment = Terrain:FindFirstChild("EggCrateSpawnAttachment")[cite: 1]
            if crateAttachment and getgenv().EventFarmActive then
                if teleportTo(crateAttachment) then[cite: 1]
                    UseBatteryOnCrateRemote:FireServer(crateAttachment)[cite: 1]
                    task.wait(0.5)[cite: 1]
                end
            end
        end
        task.wait(0.1)[cite: 1]
    end
end)

-- [[ UI Tab & Section Setup ]]
local MainTab = Window:CreateTab("Main", 4483363487)
local EventFarmSection = MainTab:CreateSection("Event Farm")

EventFarmSection:CreateToggle({
    Name = "Auto Farm Batteries",
    CurrentValue = false,
    Flag = "BatteryFarmToggle",
    Callback = function(Value)
        getgenv().EventFarmActive = Value
    end,
})
