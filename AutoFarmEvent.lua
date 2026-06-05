-- Auto Farm Event Script - FIXED
-- Automatically teleports to batteries, grabs them, and uses them on egg crates

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
    
    -- Configuration
    local BATTERY_SPAWN_ATTACHMENT = "BatterySpawnAttachment"
    local EGG_CRATE_SPAWN_ATTACHMENT = "EggCrateSpawnAttachment"
    local DELAY_BETWEEN_ACTIONS = 0.5
    local LOOP_DELAY = 1
    local MAX_ITERATIONS = math.huge
    local TELEPORT_OFFSET = Vector3.new(0, 3, 0)
    
    local iteration = 0
    local batteryGrabbed = false
    
    -- Helper function to find attachment or part in workspace
    local function findObject(objectName)
        -- Search workspace descendants
        for _, part in pairs(Workspace:GetDescendants()) do
            if part.Name == objectName then
                return part
            end
        end
        
        -- Also check direct children
        if Workspace:FindFirstChild(objectName) then
            return Workspace:FindFirstChild(objectName)
        end
        
        return nil
    end
    
    -- Helper function to keep player in place (prevent teleport back to spawn)
    local function lockPosition(duration)
        if duration then
            local startTime = tick()
            local lastPosition = HumanoidRootPart.CFrame
            
            while tick() - startTime < duration do
                if HumanoidRootPart then
                    HumanoidRootPart.CFrame = lastPosition
                end
                wait(0.01)
            end
        end
    end
    
    print("Starting farm loop...")
    
    while iteration < MAX_ITERATIONS do
        iteration = iteration + 1
        print("--- Iteration " .. iteration .. " ---")
        
        -- Update character reference in case of respawn
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then
            Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
        end
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or HumanoidRootPart
        
        -- Reset battery grabbed flag at start of cycle
        batteryGrabbed = false
        
        -- Step 1: Teleport to Battery and Grab it
        if not batteryGrabbed then
            local success1, err1 = pcall(function()
                print("Finding battery...")
                
                local batteryObject = findObject(BATTERY_SPAWN_ATTACHMENT)
                if not batteryObject then
                    -- Try to find battery spawn location or battery itself
                    batteryObject = findObject("Battery")
                    if not batteryObject then
                        batteryObject = findObject("BatterySpawn")
                    end
                end
                
                if batteryObject then
                    print("Battery found at: " .. batteryObject.Name)
                    
                    -- Teleport to battery location
                    local targetPosition = batteryObject.Position + TELEPORT_OFFSET
                    HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                    print("Teleported to battery")
                    
                    -- Lock position briefly to prevent being pushed back
                    lockPosition(0.5)
                    
                    -- Grab battery - try different argument formats
                    print("Grabbing battery...")
                    
                    -- Try sending the battery object itself
                    if batteryObject:IsA("Attachment") then
                        GrabBatteryRemote:FireServer(batteryObject)
                    elseif batteryObject:FindFirstChild("Attachment") then
                        GrabBatteryRemote:FireServer(batteryObject:FindFirstChild("Attachment"))
                    else
                        GrabBatteryRemote:FireServer(batteryObject)
                    end
                    
                    print("Battery grabbed! Marking as grabbed and preparing to deposit...")
                    batteryGrabbed = true
                    
                else
                    print("Warning: Battery not found - checking available objects")
                    -- List available objects for debugging
                    for _, child in pairs(Workspace:GetChildren()) do
                        print("  Available: " .. child.Name)
                    end
                end
            end)
            
            if not success1 then
                print("Error grabbing battery: " .. tostring(err1))
            end
        end
        
        -- Step 2: If battery was grabbed, INSTANTLY teleport to deposit (NO MORE BATTERY SEARCHING)
        if batteryGrabbed then
            local success2, err2 = pcall(function()
                print("Battery is grabbed! Finding egg crate deposit...")
                
                local crateObject = findObject(EGG_CRATE_SPAWN_ATTACHMENT)
                if not crateObject then
                    -- Try alternative names
                    crateObject = findObject("EggCrate")
                    if not crateObject then
                        crateObject = findObject("CrateSpawn")
                    end
                end
                
                if crateObject then
                    print("Egg crate found at: " .. crateObject.Name)
                    
                    -- INSTANT Teleport to crate location
                    local targetPosition = crateObject.Position + TELEPORT_OFFSET
                    HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                    print("Instantly teleported to egg crate deposit")
                    
                    -- Lock position to prevent teleport back to spawn
                    lockPosition(1.5)
                    
                    -- Use battery on crate - try different argument formats
                    print("Using battery on egg crate...")
                    
                    if crateObject:IsA("Attachment") then
                        UseBatteryOnCrateRemote:FireServer(crateObject)
                    elseif crateObject:FindFirstChild("Attachment") then
                        UseBatteryOnCrateRemote:FireServer(crateObject:FindFirstChild("Attachment"))
                    else
                        UseBatteryOnCrateRemote:FireServer(crateObject)
                    end
                    
                    print("Battery deposited on crate!")
                    wait(DELAY_BETWEEN_ACTIONS)
                    
                    -- Wait 3-5 seconds after depositing battery (while staying locked in place)
                    local waitTime = math.random(30, 50) / 10 -- Random between 3.0 and 5.0 seconds
                    print("Waiting " .. tostring(waitTime) .. " seconds for battery to process...")
                    lockPosition(waitTime)
                    print("Wait time complete, ready for next cycle...")
                    
                    -- Mark battery as no longer grabbed for next cycle
                    batteryGrabbed = false
                    
                else
                    print("Warning: Egg crate not found")
                end
            end)
            
            if not success2 then
                print("Error using battery on crate: " .. tostring(err2))
            end
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
    
    -- Additional debugging
    print("\n=== DEBUGGING INFO ===")
    local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if Remotes then
        print("Remotes found. Contents:")
        for _, remote in pairs(Remotes:GetChildren()) do
            print("  - " .. remote.Name)
        end
    end
end
