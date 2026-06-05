-- Auto Farm Event Script
-- Automatically teleports to batteries, grabs them, and uses them on egg crates to farm event rewards

print("=== AUTO FARM EVENT STARTED ===")

local success, err = pcall(function()
    -- Get required services
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")
    
    -- Get local player
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
    
    print("LocalPlayer: " .. tostring(LocalPlayer.Name))
    print("Character loaded: " .. tostring(Character.Name))
    
    -- Get remotes
    local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
    local GrabBatteryRemote = Remotes:WaitForChild("GrabBatteryRemote", 10)
    local UseBatteryOnCrateRemote = Remotes:WaitForChild("UseBatteryOnCrateRemote", 10)
    
    print("Remotes loaded successfully")
    
    -- Get terrain for spawn attachments
    local Terrain = Workspace:WaitForChild("Terrain", 10)
    
    -- Configuration
    local BATTERY_SPAWN_ATTACHMENT = "BatterySpawnAttachment"
    local EGG_CRATE_SPAWN_ATTACHMENT = "EggCrateSpawnAttachment"
    local DELAY_BETWEEN_ACTIONS = 0.5 -- Delay between actions
    local LOOP_DELAY = 2 -- Delay between farm cycles
    local MAX_ITERATIONS = math.huge -- Run indefinitely
    local TELEPORT_OFFSET = Vector3.new(0, 3, 0) -- Offset above the attachment point
    
    local iteration = 0
    
    print("Starting farm loop...")
    
    while iteration < MAX_ITERATIONS do
        iteration = iteration + 1
        print("--- Iteration " .. iteration .. " ---")
        
        -- Step 1: Teleport to Battery and Grab it
        local success1, err1 = pcall(function()
            print("Teleporting to battery...")
            
            local batteryAttachment = Terrain:WaitForChild(BATTERY_SPAWN_ATTACHMENT, 5)
            if batteryAttachment then
                -- Teleport to battery location
                local targetPosition = batteryAttachment.Position + TELEPORT_OFFSET
                HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                print("Teleported to battery")
                wait(0.3)
                
                -- Grab battery
                print("Grabbing battery...")
                local args = {batteryAttachment}
                GrabBatteryRemote:FireServer(unpack(args))
                print("Battery grabbed!")
                wait(DELAY_BETWEEN_ACTIONS)
            else
                print("Warning: Battery attachment not found")
            end
        end)
        
        if not success1 then
            print("Error grabbing battery: " .. tostring(err1))
        end
        
        -- Step 2: Teleport to Egg Crate and Use Battery
        local success2, err2 = pcall(function()
            print("Teleporting to egg crate...")
            
            local crateAttachment = Terrain:WaitForChild(EGG_CRATE_SPAWN_ATTACHMENT, 5)
            if crateAttachment then
                -- Teleport to crate location
                local targetPosition = crateAttachment.Position + TELEPORT_OFFSET
                HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                print("Teleported to egg crate")
                wait(0.3)
                
                -- Use battery on crate
                print("Using battery on egg crate...")
                local args = {crateAttachment}
                UseBatteryOnCrateRemote:FireServer(unpack(args))
                print("Battery used on crate!")
            else
                print("Warning: Egg crate attachment not found")
            end
        end)
        
        if not success2 then
            print("Error using battery on crate: " .. tostring(err2))
        end
        
        -- Wait before next iteration
        print("Waiting for next cycle...")
        wait(LOOP_DELAY)
    end
    
    print("=== AUTO FARM EVENT COMPLETED ===")
    
end)

-- Error handling
if not success then
    print("=== CRITICAL ERROR ===")
    print("Error: " .. tostring(err))
    print("Traceback:")
    print(debug.traceback())
end
