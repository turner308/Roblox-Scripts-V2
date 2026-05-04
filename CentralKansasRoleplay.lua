-- Libraries
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/turner308/Roblox-Scripts/refs/heads/master/UwUware"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeliveryFolder = workspace:WaitForChild("Buildings"):WaitForChild("ElisworthMcDonald's"):WaitForChild("Delivery")
local DeliveryEvent = DeliveryFolder:WaitForChild("Events"):WaitForChild("Deliver")
local DeliveryComputer = DeliveryFolder:WaitForChild("McDonaldsDelivery")
local DeliveryPrompt = DeliveryComputer:WaitForChild("ProximityPrompt")
-- Anti AFK
for _, v in getconnections(LocalPlayer.Idled) do
    v:Disable()
end
-- Character Var
local Character = nil

task.spawn(function()
    local function OnCharacterAdded(Char: Players)
        Char = Char or LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

        local Humanoid: Humanoid = Char:FindFirstChild("Humanoid") or Char:WaitForChild("Humanoid", 3)

        if not Humanoid then return end

        local HealthSignal = nil
        HealthSignal = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if Humanoid.Health <= 0 then
                Character = nil
                HealthSignal:Disconnect()
            end
        end)

        local HumanoidRootPart = Char:FindFirstChild("HumanoidRootPart") or Char:WaitForChild("HumanoidRootPart", 3)

        if not HumanoidRootPart then return end

        Character = Char
    end

    OnCharacterAdded()

    LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
end)
-- Auto Job
local JobLabel = nil
local FireTick = 1
local FireTickDelay = 0.5
local OldPos = nil

local function AutoJob()
    if not Character then
        OldPos = nil
        return "character"
    end

    if LocalPlayer.Team ~= Teams.WConalds and (tick() - FireTick) > FireTickDelay then -- unemployed bitch ass
        ReplicatedStorage.Job:FireServer("MD")
        FireTick = tick()
        return
    end

    local DeliveryUI = PlayerGui:FindFirstChild("DeliveryUI")

    if not OldPos then
        OldPos = Character:GetPivot()
    end

    if not DeliveryUI then -- get delivery objective
        Character:PivotTo(DeliveryComputer.CFrame)
        fireproximityprompt(DeliveryPrompt)
        return
    end

    local DeliveryTimer = DeliveryUI:FindFirstChild("StartTimer")

    if not DeliveryTimer then return "timer" end

    local TimeLeft = (workspace:GetServerTimeNow() - DeliveryTimer.Value)

    if JobLabel then
        JobLabel.Text = string.format("Time Before Delivery: %.1fs", 30 - TimeLeft)
    end

    if TimeLeft < 28.5 then return "waiting for timer" end

    local DeliveryPart = DeliveryUI:FindFirstChild("DeliveryPart")

    if not DeliveryPart or not DeliveryPart.Value then return "delivery part" end

    DeliveryPart = DeliveryPart.Value
    
    if not OldPos then
        OldPos = Character:GetPivot()
    end

    Character:PivotTo(DeliveryPart.CFrame) -- goto delivery marker

    local DeliverPrompt = DeliveryPart:FindFirstChild("Deliver")

    if not DeliverPrompt then return "delivery prompt" end

    if (tick() - FireTick) > FireTickDelay then
        DeliveryEvent:FireServer("delivered", DeliveryPart) -- fire deliver remote
        FireTick = tick()
    end
end
-- GUI
local FarmingWindow = UI:CreateWindow("Main")
local JobSection = FarmingWindow:AddFolder("Auto Job")
JobSection.open = true
JobSection:AddToggle({
    text = "Auto McDonalds Job",
    flag = "auto_job"
})
JobLabel = JobSection:AddLabel({
    text = "Time Before Delivery: ...",
})
UI:Init()
-- Main loop
task.spawn(function()
    while UI.alive do
        if UI.flags.auto_job then
            local Step = AutoJob()

            if Step == "waiting for timer" and OldPos then
                Character:PivotTo(OldPos)
                OldPos = nil
            end
        end

        task.wait()
    end
end)
