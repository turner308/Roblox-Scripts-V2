---@diagnostic disable
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/turner308/Roblox-Scripts/refs/heads/master/UwUware"))()
--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
-- Lap UI
local RaceGui = PlayerGui.General.Modules.RaceGui
local LapUI = RaceGui:WaitForChild("lap")
-- Remotes
local Remotes = ReplicatedStorage.Remotes
local RaceEventRE = Remotes.Race.RaceEvent
local SpawnCarRE = Remotes.Car.SpawnCar
-- Anti AFK
for _, v in next, getconnections(LocalPlayer.Idled) do
    v:Disable()
end
-- Get Character
local Character = nil

task.spawn(function() -- spawned so :Wait does not yield
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
-- GUI
local Window = UI:CreateWindow("Drift 36")
Window:AddToggle({text = "Auto Solo Race", flag = "solo_race", tooltip = "will go in best order, highway, city"})
local Status = Window:AddLabel({text = "waiting..."})
Window:AddLabel({text = "by aturner"})
UI:Init()
-- Solo Race Function
-- local RaceNames = { "HighwayRace", "CityRace" } -- ordered from greatest money to least money
local RaceNames = { "CityRace" }

local function GetClientRaceData(DataName)
    for _, RaceName in RaceNames do
        local Found = workspace:FindFirstChild(RaceName .. DataName)

        if Found then
            return Found
        end
    end
end

local function SoloRace()
    if not Character then return end

    local PlayerCar = workspace.Araclar:FindFirstChild(LocalPlayer.Name .. "_spcar")

    if not PlayerCar then
        local OwnedCars = LocalPlayer:FindFirstChild("Cars")

        if not OwnedCars then 
            return "cars folder"
        end

        local AnyCar = OwnedCars:FindFirstChildWhichIsA("Model")

        if not AnyCar then 
            return "no owned cars"
        end

        SpawnCarRE:FireServer(
            AnyCar.Name,
            Character:GetPivot().Position
        )

        task.wait(1)

        return "spawning car"
    end

    local DriveSeat = PlayerCar:FindFirstChild("DriveSeat")

    if not DriveSeat then
        PlayerCar:Destroy() -- fix voided car
        return "waiting for seat"
    end

    if Character.Humanoid.SeatPart ~= DriveSeat then
        DriveSeat:Sit(Character.Humanoid)
        return "sitting"
    end

    local ClientObjects = GetClientRaceData("_ClientObjects")

    if not ClientObjects and not RaceGui.Visible then
        for _, RaceName in RaceNames do
            RaceEventRE:FireServer({
                solo = true,
                action = "EnterRaceZone",
                raceId = RaceName
            })
        end
        return "starting race"
    end

    local TrackObjects = GetClientRaceData("_TrackObjects")

    if not TrackObjects then
        return "getting track objects"
    end

    local Checkpoints = GetClientRaceData("_solo_ServerCheckpoints")

    if not Checkpoints then
        return "getting checkpoints"
    end

    local CurLap = tonumber(LapUI.LeftSideLabel.Text)
    local LapMax = tonumber(LapUI.RightSideLabel.Text:split("/")[2])

    if CurLap == LapMax then
        for _, v in PlayerCar:GetDescendants() do -- prevent car from glitching out
            if v:IsA("BasePart") then
                v.AssemblyLinearVelocity = Vector3.zero
				v.AssemblyAngularVelocity = Vector3.zero
            end    
        end

        PlayerCar:PivotTo(Checkpoints.ServerFinishLine.CFrame)
        return "finish race"
    end

    local LapFound = Checkpoints:FindFirstChild(CurLap + 1)

    if not LapFound then
        return "next point"
    end
    
    PlayerCar:PivotTo(LapFound.CFrame)

    task.wait(0.5) -- needs delay or it detects you
end
-- Main Loop
while UI.alive do
    if UI.flags.solo_race then
        Status.Text = SoloRace() or "waiting..."
    end

    task.wait()
end
