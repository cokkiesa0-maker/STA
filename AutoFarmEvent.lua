-- [[ UI Library Initialization ]]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))() -- Example using Orion
local Window = Library:MakeWindow({Name = "Mobile Script", HidePremium = false, SaveConfig = true, ConfigFolder = "EventFarmConfig"})

-- [[ Services & Remotes ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GrabBatteryRemote = Remotes:WaitForChild("GrabBatteryRemote")
local UseBatteryOnCrateRemote = Remotes:WaitForChild("UseBatteryOnCrateRemote")
local Terrain = Workspace:WaitForChild("Terrain")

-- [[ State Management ]]
local _G = getgenv and getgenv() or _G
_G.EventFarmEnabled = false

-- [[ Core Functions ]]
local function teleportTo(attachment)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if rootPart and attachment then
        rootPart.CFrame = CFrame.new(attachment.WorldPosition + Vector3.new(0, 2, 0))
        task.wait(0.1) 
        return true
    end
    return false
end

-- [[ Automation Worker ]]
task.spawn(function()
    while true do
        if _G.EventFarmEnabled then
            -- 1. Grab Battery
            local batteryAttachment = Terrain:FindFirstChild("BatterySpawnAttachment")
            if batteryAttachment and _G.EventFarmEnabled then
                if teleportTo(batteryAttachment) then
                    GrabBatteryRemote:FireServer(batteryAttachment)
                    task.wait(0.5)
                end
            end

            -- 2. Deposit Battery
            local crateAttachment = Terrain:FindFirstChild("EggCrateSpawnAttachment")
            if crateAttachment and _G.EventFarmEnabled then
                if teleportTo(crateAttachment) then
                    UseBatteryOnCrateRemote:FireServer(crateAttachment)
                    task.wait(0.5)
                end
            end
        end
        task.wait(0.2) -- Throttled idle rate when toggled off
    end
end)

-- [[ UI Construction ]]
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998"
})

local EventFarmSection = MainTab:AddSection({
    Name = "Event Farm"
})

EventFarmSection:AddToggle({
    Name = "Auto Farm Batteries",
    Default = false,
    Callback = function(Value)
        _G.EventFarmEnabled = Value
    end    
})

Library:Init()
