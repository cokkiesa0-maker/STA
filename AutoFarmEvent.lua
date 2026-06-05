local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local grabRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GrabBombRemote")

-- Configuration
local AUTO_FARM = true
local CHECK_DELAY = 1 -- Seconds to check between spawns

print("[Auto-Farm] Script initialized.")

task.spawn(function()
    while AUTO_FARM do
        -- 1. Locate the bomb attachment / green block target
        local terrain = Workspace:WaitForChild("Terrain", 5)
        local targetAttachment = terrain and terrain:FindFirstChild("CarryableBombSpawnAttachment")

        if targetAttachment and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = localPlayer.Character.HumanoidRootPart
            
            -- 2. Smoothly or instantly teleport to the object's position
            print("[Auto-Farm] Bomb detected! Teleporting...")
            rootPart.CFrame = CFrame.new(targetAttachment.WorldPosition)
            
            task.wait(0.2) -- Small delay to allow the game to register physics/presence

            -- 3. Fire the server remote to interact/grab the item
            local args = {
                [1] = targetAttachment
            }
            grabRemote:FireServer(unpack(args))
            print("[Auto-Farm] Successfully interacted with the target block.")
            
            -- Optional delay to prevent instantly spamming the remote if the asset doesn't clear immediately
            task.wait(2) 
        end
        
        task.wait(CHECK_DELAY)
    end
end)
