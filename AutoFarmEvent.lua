-- Auto Farm Event Script
-- Automatically teleports to batteries, grabs them, rides dragon to egg crates, and uses batteries to farm event rewards

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
    local TELEPORT_OFFSET = Vector3.new(0, 5, 0) -- Offset above the attachment point
    
    local iteration = 0
    local dragonMounted = false
    
    -- Helper function to find and mount dragon
    local function mountDragon()
        print("Attempting to mount dragon...")
        
        local dragon = nil
        
        -- Search for dragon in workspace
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("dragon") or obj.Name:lower():find("pet")) then
                if obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Humanoid") then
                    dragon = obj
                    break
                end
            end
        end
        
        if dragon then
            print("Dragon found: " .. dragon.Name)
            local dragonRoot = dragon:FindFirstChild("HumanoidRootPart")
            
            if dragonRoot then
                -- Teleport to dragon
                HumanoidRootPart.CFrame = dragonRoot.CFrame + Vector3.new(0, 3, 0)
                wait(0.3)
                
                -- Try to interact with mount remote if available
                if Remotes:FindFirstChild("MountDragonRemote") then
                    Remotes:FindFirstChild("MountDragonRemote"):FireServer(dragon)
                    print("Mounted dragon via remote")
                    dragonMounted = true
                elseif Remotes:FindFirstChild("RideDragonRemote") then
                    Remotes:FindFirstChild("RideDragonRemote"):FireServer(dragon)
                    print("Mounted dragon via ride remote")
                    dragonMounted = true
                else
                    -- Just position on the dragon
                    print("Positioned on dragon (no mount remote found)")
                    dragonMounted = true
                end
                
                return true
            end
        else
            print("Warning: Dragon not found in workspace")
            return false
        end
    end
    
    -- Helper function to find attachment
    local function findAttachment(attachmentName)
        -- Try Terrain first
        if Terrain:FindFirstChild(attachmentName) then
            return Terrain:FindFirstChild(attachmentName)
        end
        
        -- Search workspace
        for _, part in pairs(Workspace:GetDescendants()) do
            if part.Name == attachmentName then
                return part
            end
        end
        
        return nil
    end
    
    print("Starting farm loop...")
    
    while iteration < MAX_ITERATIONS do
        iteration = iteration + 1
        print("--- Iteration " .. iteration .. " ---")
        
        -- Update character reference in case of respawn
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then
            Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        end
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or HumanoidRootPart
        
        -- Step 1: Mount Dragon at start or if dismounted
        if not dragonMounted then
            local dragonSuccess, dragonErr = pcall(function()
                mountDragon()
                wait(0.5)
            end)
            
            if not dragonSuccess then
                print("Error mounting dragon: " .. tostring(dragonErr))
            end
        end
        
        -- Step 2: Teleport to Battery and Grab it
        local success1, err1 = pcall(function()
            print("Teleporting to battery...")
            
            local batteryAttachment = findAttachment(BATTERY_SPAWN_ATTACHMENT)
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
        
        -- Step 3: Remount dragon if needed
        if dragonMounted then
            local remountSuccess, remountErr = pcall(function()
                local dragon = nil
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("dragon") or obj.Name:lower():find("pet")) then
                        if obj:FindFirstChild("HumanoidRootPart") then
                            dragon = obj
                            break
                        end
                    end
                end
                
                if dragon then
                    local dragonRoot = dragon:FindFirstChild("HumanoidRootPart")
                    HumanoidRootPart.CFrame = dragonRoot.CFrame + Vector3.new(0, 3, 0)
                    print("Repositioned on dragon")
                end
            end)
        end
        
        -- Step 4: Teleport to Egg Crate and Use Battery
        local success2, err2 = pcall(function()
            print("Teleporting to egg crate...")
            
            local crateAttachment = findAttachment(EGG_CRATE_SPAWN_ATTACHMENT)
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
