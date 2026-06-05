-- [[ CUSTOM SELF-CONTAINED MOBILE LIBRARY ]]
local CustomLib = {}
function CustomLib:CreateWindow(titleText)
    local CoreGui = game:GetService("CoreGui")
    -- Protect against UI deletion on execution
    if CoreGui:FindFirstChild("MobileAutomationHub") then
        CoreGui.MobileAutomationHub:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileAutomationHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    -- Main Container Panel
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 360, 0, 220)
    MainFrame.Position = UDim2.new(0.5, -180, 0.4, -110)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 38)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Title Bar
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 35)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.SourceSansBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = MainFrame

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 2)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(240, 80, 80)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = MainFrame
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Content Scroll Frame
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.Position = UDim2.new(0, 10, 0, 45)
    Container.BackgroundTransparency = 1
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.ScrollBarThickness = 4
    Container.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.Parent = Container

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    local LibraryAPI = {}
    
    function LibraryAPI:CreateSection(sectionName)
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, 0, 0, 20)
        SectionLabel.Text = "--- " .. sectionName .. " ---"
        SectionLabel.TextColor3 = Color3.fromRGB(130, 135, 165)
        SectionLabel.TextSize = 13
        SectionLabel.Font = Enum.Font.SourceSansBold
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Parent = Container
    end

    function LibraryAPI:CreateToggle(toggleName, default, callback)
        local Enabled = default
        
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(33, 35, 50)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = Container
        
        local TFCorner = Instance.new("UICorner")
        TFCorner.CornerRadius = UDim.new(0, 6)
        TFCorner.Parent = ToggleFrame

        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Size = UDim2.new(1, -70, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
        ToggleLabel.Text = toggleName
        ToggleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        ToggleLabel.TextSize = 15
        ToggleLabel.Font = Enum.Font.SourceSans
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Parent = ToggleFrame

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 50, 0, 26)
        Button.Position = UDim2.new(1, -62, 0.5, -13)
        Button.BackgroundColor3 = Enabled and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(60, 65, 85)
        Button.Text = ""
        Button.Parent = ToggleFrame

        local BCorner = Instance.new("UICorner")
        BCorner.CornerRadius = UDim.new(0, 13)
        BCorner.Parent = Button

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 20, 0, 20)
        Indicator.Position = Enabled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.Parent = Button
        
        local ICorner = Instance.new("UICorner")
        ICorner.CornerRadius = UDim.new(1, 0)
        ICorner.Parent = Indicator

        local function update()
            Button.BackgroundColor3 = Enabled and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(60, 65, 85)
            Indicator.Position = Enabled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            task.spawn(callback, Enabled)
        end

        Button.MouseButton1Click:Connect(function()
            Enabled = not Enabled
            update()
        end)
    end

    return LibraryAPI
end

-- [[ ENVIRONMENT SETUP & CORE GAME LOGIC ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GrabBatteryRemote = Remotes:WaitForChild("GrabBatteryRemote")[cite: 1]
local UseBatteryOnCrateRemote = Remotes:WaitForChild("UseBatteryOnCrateRemote")[cite: 1]
local Terrain = Workspace:WaitForChild("Terrain")[cite: 1]

getgenv().EventFarmActive = false

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

-- Execution Loop
task.spawn(function()
    while true do
        if getgenv().EventFarmActive then
            -- Phase 1: Grab
            local batteryAttachment = Terrain:FindFirstChild("BatterySpawnAttachment")[cite: 1]
            if batteryAttachment and getgenv().EventFarmActive then
                if teleportTo(batteryAttachment) then[cite: 1]
                    GrabBatteryRemote:FireServer(batteryAttachment)[cite: 1]
                    task.wait(0.5)[cite: 1]
                end
            end

            -- Phase 2: Deposit
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

-- [[ UI INITIALIZATION ]]
local Window = CustomLib:CreateWindow("Main Tab")
Window:CreateSection("Event Farm")

Window:CreateToggle("Auto Farm Batteries", false, function(Value)
    getgenv().EventFarmActive = Value
end)
