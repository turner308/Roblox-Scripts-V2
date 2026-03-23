---@diagnostic disable
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/turner308/Roblox-Scripts/refs/heads/master/UwUware"))()
--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local RaceEventRE = ReplicatedStorage.Remotes.Race.RaceEvent
-- Anti AFK
for _, v in next, getconnections(LocalPlayer.Idled) do v:Disable() end
-- GUI
local Window = UI:CreateWindow("Drift 36")
Window:AddToggle({text = "Auto Solo Race", flag = "solo_race"})
Window:AddButton({text = "By aturner @v3rm"})
UI:Init()
-- Main Loop
while true do
    if UI.flags.solo_race then
        local PlayerCar = workspace.Araclar:FindFirstChild(LocalPlayer.Name .. "_spcar")

        if PlayerCar then
            local ClientObjects = workspace:FindFirstChild("SoloRace_ClientObjects")

            if not ClientObjects then
                RaceEventRE:FireServer({
                    action = "EnterRaceZone",
                    raceId = "SoloRace"
                })
            else
                local TrackObjects = workspace:FindFirstChild("SoloRace_TrackObjects")

                if TrackObjects then
                    local Checkpoints = workspace:FindFirstChild("SoloRace_ServerCheckpoints")

                    if Checkpoints then
                        local CurrentPoint = PlayerGui.General.Modules.RaceGui.checkpoint.InfoText.Text:split("/")
                        local CurLap, LapMax = tonumber(CurrentPoint[1]), tonumber(CurrentPoint[2])

                        if CurLap == LapMax then
                            PlayerCar:PivotTo(Checkpoints.ServerFinishLine.CFrame)
                        else
                            local LapFound = Checkpoints:FindFirstChild(CurLap + 1)

                            if LapFound then
                                PlayerCar:PivotTo(LapFound.CFrame)
                            end
                        end
                    end
                end
            end
        end
    end

    task.wait(1)
end
