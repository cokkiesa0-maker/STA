-- [[ Services ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes") [cite: 1]
local GrabBatteryRemote = Remotes:WaitForChild("GrabBatteryRemote") [cite: 1]
local UseBatteryOnCrateRemote = Remotes:WaitForChild("UseBatteryOnCrateRemote") [cite: 1]
local Terrain = Workspace:WaitForChild("Terrain") [cite: 1]

-- [[ Global Controls ]]
getgenv().EventFarmActive = false

-- [[ Teleport Logic ]]
local function teleportTo(attachment)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart") [cite: 1]
    
    if rootPart and attachment then [cite: 1]
        rootPart.CFrame = CFrame.new(attachment.WorldPosition + Vector3.new(0, 2, 0)) [cite: 1]
        task.wait(0.1) [cite: 2]
        return true [cite: 2]
    end
    return false [cite: 2]
end

-- [[ Automation Worker ]]
task.spawn(function()
    while true do
        if getgenv().EventFarmActive then
            -- 1. Grab Battery
            local batteryAttachment = Terrain:FindFirstChild("BatterySpawnAttachment") [cite: 2]
            if batteryAttachment and getgenv().EventFarmActive then
                if teleportTo(batteryAttachment) then [cite: 2]
                    GrabBatteryRemote:FireServer(batteryAttachment) [cite: 3]
                    task.wait(0.5) [cite: 3]
                end
            end

            -- 2. Deposit Battery
            local crateAttachment = Terrain:FindFirstChild("EggCrateSpawnAttachment") [cite: 3]
            if crateAttachment and getgenv().EventFarmActive then
                if teleportTo(crateAttachment) then [cite: 4]
                    UseBatteryOnCrateRemote:FireServer(crateAttachment) [cite: 4]
                    task.wait(0.5) [cite: 4]
                end
            end
        end
        task.wait(0.2)
    end
end)

-- [[ UI Setup ]]
local VenyxLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venyx-UI-Library/main/source.lua"))()
local UI = VenyxLib.new("Mobile Interface", 5013109572)

-- Main Tab & Event Farm Section
local MainTab = UI:addPage("Main", 5012544693)
local EventFarmSection = MainTab:addSection("Event Farm")

EventFarmSection:addToggle("Auto Farm Batteries", false, function(Value)
    getgenv().EventFarmActive = Value
end)

-- Select first page by default
UI:SelectPage(MainTab, true)
