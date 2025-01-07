local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Anti AFK
local AFKRemote = ReplicatedStorage.Packages.Knit.Services.PlayerService.RE:FindFirstChild("AFK")

if AFKRemote then
    AFKRemote:Destroy()
end

for _, v in next, getconnections(LocalPlayer.Idled) do
    v:Disable()
end

local function PlayerAlive()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    if Humanoid and Humanoid.Health > 0 then
        return Character
    end
end

local function GetRandomBall()
    local Balls = {}
    for _, v in next, workspace:GetChildren() do
        if v.Name == "Ball" and v.Transparency == 0 and (not v:FindFirstChild("Trail") or not v.Trail.Enabled) and v:GetAttribute("Team") == LocalPlayer.TeamColor then
            table.insert(Balls, v)
        end
    end
    return #Balls > 0 and Balls[math.random(1, #Balls)]
end

local function GetClosestPlayer()
    local Distance = math.huge
    local Player = nil

    for _, player in next, Players:GetPlayers() do
        if player == LocalPlayer or player.TeamColor == LocalPlayer.TeamColor then continue end

        local Character = player.Character

        if Character then
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")

            if Humanoid and Humanoid.Health > 0 then
                local DistFrom = LocalPlayer:DistanceFromCharacter(Character.PrimaryPart.Position)

                if DistFrom < Distance then
                    Distance = DistFrom
                    Player = player
                end
            end
        end
    end

    return Player
end

local function IsBallHeld()
    local GameObjects = LocalPlayer.Character:FindFirstChild("GAMEOBJECTS")

    return GameObjects and GameObjects:FindFirstChild("Ball")
end

while enabled do
    if tostring(LocalPlayer.Team) ~= "Lobby" then
        local Character = PlayerAlive()

        if workspace:FindFirstChild("Ball") and Character then
            if not IsBallHeld() then
                local BallFound = GetRandomBall()

                if BallFound then
                    Character:MoveTo(BallFound.Position)
                end
            else
                local ClosestPlayer = GetClosestPlayer()

                if ClosestPlayer then
                    local Head = ClosestPlayer.Character:FindFirstChild("Head")

                    if Head then
                        ReplicatedStorage.Packages.Knit.Services.ControlService.RE.Throw:FireServer(Head.Position, Head.Position)
                    end
                end
            end
        end
    end

    task.wait()
end
