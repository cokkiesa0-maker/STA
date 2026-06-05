-- Auto Farm Event Script - DIAGNOSTIC VERSION
-- With enhanced debugging to find the issue

print("=== AUTO FARM EVENT STARTED (DIAGNOSTIC MODE) ===")

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
    
    -- DIAGNOSTIC: Print all workspace items
    print("\n=== WORKSPACE CONTENTS ===")
    for _, item in pairs(Workspace:GetChildren()) do
        print("- " .. item.Name .. " (" .. item.ClassName .. ")")
        
        -- Print children of each item
        for _, child in pairs(item:GetChildren()) do
            print("  └─ " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    end
    
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
                print("  ✓ Found: " .. objectName .. " at position " .. tostring(part.Position))
                return part
            end
        end
        
        -- Also check direct children
        if Workspace:FindFirstChild(objectName) then
            print("  ✓ Found (direct child): " .. objectName)
            return Workspace:FindFirstChild(objectName)
        end
        
        print("  ✗ NOT FOUND: " .. objectName)
        return nil
    end
    
    -- Helper function to lock player at specific position
    local function lockAtPosition(targetCFrame, duration)
        if duration and duration > 0 then
            local startTime = tick()
            
            while tick() - startTime < duration do
                if HumanoidRootPart then
                    HumanoidRootPart.CFrame = targetCFrame
                end
                wait(0.01)
            end
        end
    end
    
    print("\nStarting farm loop...")
    
    while iteration < MAX_ITERATIONS do
        iteration = iteration + 1
        print("\n=== Iteration " .. iteration .. " ===")
        
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
                print("\n[STEP 1] Finding battery...")
                
                local batteryObject = findObject(BATTERY_SPAWN_ATTACHMENT)
                if not batteryObject then
                    print("  Trying alternative names...")
                    batteryObject = findObject("Battery")
                    if not batteryObject then
                        batteryObject = findObject("BatterySpawn")
                    end
                end
                
                if batteryObject then
                    print("[STEP 1] ✓ Battery found!")
                    
                    -- Teleport to battery location
                    local targetPosition = batteryObject.Position + TELEPORT_OFFSET
                    local targetCFrame = CFrame.new(targetPosition)
                    HumanoidRootPart.CFrame = targetCFrame
                    print("[STEP 1] Teleported to: " .. tostring(targetPosition))
                    
                    -- Grab battery - try different argument formats
                    print("[STEP 1] Firing GrabBatteryRemote...")
                    print("  Battery object type: " .. batteryObject.ClassName)
                    
                    -- Try sending the battery object itself
                    if batteryObject:IsA("Attachment") then
                        print("  Sending as Attachment")
                        GrabBatteryRemote:FireServer(batteryObject)
                    elseif batteryObject:FindFirstChild("Attachment") then
                        print("  Found child Attachment, sending that")
                        GrabBatteryRemote:FireServer(batteryObject:FindFirstChild("Attachment"))
                    else
                        print("  Sending battery object directly")
                        GrabBatteryRemote:FireServer(batteryObject)
                    end
                    
                    print("[STEP 1] ✓ Remote fired! Battery should be grabbed")
                    
                    -- Lock at battery position to prevent being pushed back
                    lockAtPosition(targetCFrame, 0.5)
                    
                    batteryGrabbed = true
                    
                else
                    print("[STEP 1] ✗ Battery not found!")
                end
            end)
            
            if not success1 then
                print("[STEP 1] ✗ ERROR: " .. tostring(err1))
            end
        end
        
        -- Step 2: If battery was grabbed, INSTANTLY teleport to deposit
        if batteryGrabbed then
            local success2, err2 = pcall(function()
                print("\n[STEP 2] Finding egg crate deposit...")
                
                local crateObject = findObject(EGG_CRATE_SPAWN_ATTACHMENT)
                if not crateObject then
                    print("  Trying alternative names...")
                    crateObject = findObject("EggCrate")
                    if not crateObject then
                        crateObject = findObject("CrateSpawn")
                    end
                end
                
                if crateObject then
                    print("[STEP 2] ✓ Crate found!")
                    
                    -- INSTANT Teleport to crate location
                    local targetPosition = crateObject.Position + TELEPORT_OFFSET
                    local targetCFrame = CFrame.new(targetPosition)
                    HumanoidRootPart.CFrame = targetCFrame
                    print("[STEP 2] Teleported to: " .. tostring(targetPosition))
                    
                    -- Use battery on crate
                    print("[STEP 2] Firing UseBatteryOnCrateRemote...")
                    print("  Crate object type: " .. crateObject.ClassName)
                    
                    if crateObject:IsA("Attachment") then
                        print("  Sending as Attachment")
                        UseBatteryOnCrateRemote:FireServer(crateObject)
                    elseif crateObject:FindFirstChild("Attachment") then
                        print("  Found child Attachment, sending that")
                        UseBatteryOnCrateRemote:FireServer(crateObject:FindFirstChild("Attachment"))
                    else
                        print("  Sending crate object directly")
                        UseBatteryOnCrateRemote:FireServer(crateObject)
                    end
                    
                    print("[STEP 2] ✓ Remote fired!")
                    
                    -- Wait 3-5 seconds after depositing battery while locked at deposit position
                    local waitTime = math.random(30, 50) / 10
                    print("[STEP 2] Waiting " .. tostring(waitTime) .. " seconds...")
                    lockAtPosition(targetCFrame, waitTime)
                    print("[STEP 2] ✓ Wait complete!")
                    
                    batteryGrabbed = false
                    
                else
                    print("[STEP 2] ✗ Crate not found!")
                end
            end)
            
            if not success2 then
                print("[STEP 2] ✗ ERROR: " .. tostring(err2))
            end
        end
        
        -- Wait before next iteration
        print("\nWaiting " .. LOOP_DELAY .. " second(s) before next cycle...")
        wait(LOOP_DELAY)
    end
    
    print("\n=== AUTO FARM EVENT COMPLETED ===")
    
end)

-- Error handling
if not success then
    print("\n=== CRITICAL ERROR ===")
    print("Error: " .. tostring(err))
    print("Traceback:")
    print(debug.traceback())
end
