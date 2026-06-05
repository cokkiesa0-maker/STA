-- Auto Farm Event Script
-- Automatically grabs batteries and uses them on egg crates to farm event rewards

print("=== AUTO FARM EVENT STARTED ===")

local success, err = pcall(function()
    -- Get required services
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")
    
    -- Get local player
    local LocalPlayer = Players.LocalPlayer
    print("LocalPlayer: " .. tostring(LocalPlayer.Name))
    
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
    local DELAY_BETWEEN_ACTIONS = 0.5 -- Delay between grab and use actions
    local LOOP_DELAY = 2 -- Delay between farm cycles
    local MAX_ITERATIONS = math.huge -- Run indefinitely (change to a number to limit)
    
    local iteration = 0
    
    print("Starting farm loop...")
    
    while iteration < MAX_ITERATIONS do
        iteration = iteration + 1
        print("--- Iteration " .. iteration .. " ---")
        
        -- Step 1: Grab Battery
        local success1, err1 = pcall(function()
            print("Grabbing battery...")
            
            local batteryAttachment = Terrain:WaitForChild(BATTERY_SPAWN_ATTACHMENT, 5)
            if batteryAttachment then
                local args = {batteryAttachment}
                GrabBatteryRemote:FireServer(unpack(args))
                print("Battery grab remote fired")
                wait(DELAY_BETWEEN_ACTIONS)
            else
                print("Warning: Battery attachment not found")
            end
        end)
        
        if not success1 then
            print("Error grabbing battery: " .. tostring(err1))
        end
        
        -- Step 2: Use Battery on Egg Crate
        local success2, err2 = pcall(function()
            print("Using battery on egg crate...")
            
            local crateAttachment = Terrain:WaitForChild(EGG_CRATE_SPAWN_ATTACHMENT, 5)
            if crateAttachment then
                local args = {crateAttachment}
                UseBatteryOnCrateRemote:FireServer(unpack(args))
                print("Battery on crate remote fired")
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
