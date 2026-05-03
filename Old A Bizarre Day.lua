---@diagnostic disable
-- Libraries
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/turner308/Roblox-Scripts/refs/heads/master/UwUware"))()
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
-- Other Locals
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Camera = workspace.CurrentCamera
-- Remotes
local PurchaseRE = ReplicatedStorage.Purchase
-- Get Character
local Character = nil -- i think this might be better than my PlayerAlive() function from previous scripts
local ItemsAbleToBeReparented = {}

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

        -- Keep item from switching outta hand
        Character.ChildAdded:Connect(function(Child)
            if Child:IsA("Tool") and ItemsAbleToBeReparented[Child] then
                task.wait()
                Child.Parent = LocalPlayer.Backpack
                ItemsAbleToBeReparented[Child] = nil
            end
        end)
    end

    OnCharacterAdded()

    LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
end)
-- Optimized Get Items
local Items = {}
local Banknotes = {}

do
    local ItemRayParams = RaycastParams.new()
    local DownRayDirection = Vector3.new(0, -100, 0)

    local function OnItemAdded(Child: Instance)
        local IsBanknote = Child.Name == "Banknote"

        if Child:IsA("Tool") or IsBanknote then
            task.spawn(function()
                local Handle = Child:WaitForChild("Handle", 3)

                if Handle then
                    -- You can do a mag check for < 2000 but I like this more
                    ItemRayParams.IncludeInstances = { workspace.Map }
                    local DownRay = workspace:Raycast(Handle.Position + Vector3.new(0, 10, 0), DownRayDirection, ItemRayParams)

                    if DownRay and DownRay.Instance then
                        local Items = IsBanknote and Banknotes or Items

                        table.insert(Items, Handle)

                        -- Store in reparentable list
                        ItemsAbleToBeReparented[Child] = Child.Parent

                        -- When removed from workspace, remove the table entry
                        Child.AncestryChanged:Once(function()               
                            local TablePos = table.find(Items, Handle)

                            if TablePos then
                                table.remove(Items, TablePos)
                            end
                        end)
                    end
                end
            end)
        end
    end

    -- Items dropped are stored in workspace.Items, spawned are in workspace
    for _, ItemFolder in { workspace, workspace.Items } do
        -- Connections
        ItemFolder.ChildAdded:Connect(OnItemAdded)

        -- Check if any already exist
        for _, Child in ItemFolder:GetChildren() do
            OnItemAdded(Child)
        end
    end
end
-- Send Damage Function
local SendDamage = nil
local DamageCD = 0.2
local DamageCDTick = 1

do
    local DamageRE = ReplicatedStorage.DamageOHWS

    SendDamage = function(Entity: Model)
        if not Character or Character:GetAttribute("Timestopped") then return end

        local Humanoid = Entity:FindFirstChildWhichIsA("Humanoid")

        if not Humanoid or Humanoid.Health <= 0 then return end

        local EntityPivot = Entity:GetPivot()

        DamageRE:FireServer(
            Humanoid,
            EntityPivot,
            80,
            0.25,
            Vector3.zero,
            0.075,
            "rbxassetid://9122060057",
            1,
            0.36
        )

        return true
    end
end
-- Get Enemies
local Bosses = {}
local RewardEnemies = {}

do
    local function OnEntityAdded(Entity)
        local AppendedTable = nil

        if Entity:GetAttribute("isBoss") then
            AppendedTable = Bosses
        else
            if Entity:GetAttribute("NPC") and not Entity:GetAttribute("Dummy") then
                AppendedTable = RewardEnemies
            end
        end

        if not AppendedTable then return end

        task.spawn(function()
            local Humanoid: Humanoid = Entity:WaitForChild("Humanoid", 5)

            if not Humanoid then return end

            table.insert(AppendedTable, Entity)

            local Removed = false
            local function RemoveFromTable()
                if Removed then return end

                local TablePos = table.find(AppendedTable, Entity)

                if TablePos then
                    table.remove(AppendedTable, TablePos)
                    Removed = true
                end
            end

            local DeathSignal = nil
            DeathSignal = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if Humanoid.Health <= 0 then
                    RemoveFromTable()
                    DeathSignal:Disconnect()
                end
            end)

            local AncestrySignal = nil
            AncestrySignal = Entity.AncestryChanged:Connect(function(_, Parent)
                if Parent ~= workspace.Entities then
                    RemoveFromTable()
                    AncestrySignal:Disconnect()
                end
            end)
        end)
    end
    
    workspace.Entities.ChildAdded:Connect(OnEntityAdded)

    for _, v in workspace.Entities:GetChildren() do
        OnEntityAdded(v)
    end
end
-- Get Tool
local function GetTool(ToolName: Tool)
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    return (Backpack and Backpack:FindFirstChild(ToolName)) or (Character and Character:FindFirstChild(ToolName))
end
-- Watch Subject
local WasViewing = false
local function ViewSubject(Entity, FlagTable, FlagName)
    if Camera.CameraSubject == Entity or not FlagTable or not FlagTable[FlagName] then
        -- Unview
        WasViewing = false
        Camera.CameraSubject = Character and Character.Humanoid
        return
    else
        -- View
        WasViewing = true
        Camera.CameraSubject = Entity
    end
end
-- Fight Entity
local function FightEntity(Entity: Model)
    if not Entity then return end

    local Humanoid = Entity:FindFirstChildWhichIsA("Humanoid")

    if not Humanoid or Humanoid.Health <= 0 then return end

    if (tick() - DamageCDTick) > DamageCD then
        DamageCDTick = tick()
        SendDamage(Entity)
    end

    return Entity
end
-- Inventory Sorter
local SortInventory

do
    local CoreBackpack = CoreGui.RobloxGui.Backpack
    local GridFrame = CoreBackpack.Inventory.ScrollingFrame.UIGridFrame
    local LastSortTick = 1
    local SortDelay = 0.1

    SortInventory = function()
        if not UI.flags.auto_sort_inventory then return end

        if (tick() - LastSortTick) <= SortDelay then return end

        LastSortTick = tick()

        local Sorted = {}

        for _, v in GridFrame:GetChildren() do
            if v:IsA("TextButton") then
                table.insert(Sorted, v)
            end
        end

        table.sort(Sorted, function(A, B)
            return A.ToolName.Text < B.ToolName.Text
        end)

        for i, v in Sorted do
            v.LayoutOrder = i
        end
    end

    GridFrame.ChildAdded:Connect(SortInventory)
    GridFrame.ChildRemoved:Connect(SortInventory)
end
-- Get Data Value
local function GetData(DataName: string)
    local Data = LocalPlayer:FindFirstChild("Data")

    if not Data then return end

    local DataFound = Data:FindFirstChild(DataName)

    return DataFound and DataFound.Value
end
-- Remove 99 Warning
local RemoveWarning = nil

do
    local WarningUI = nil
    local EnabledSignal = nil

    RemoveWarning = function(Element)
        if typeof(Element) == "Instance" and Element.Name == "WARNING" then
            WarningUI = Element
        end

        if not WarningUI then return end

        WarningUI.Enabled = not UI.flags.item_warn

        if EnabledSignal then return end

        EnabledSignal = WarningUI:GetPropertyChangedSignal("Enabled"):Connect(function()
            local Desired = not UI.flags.item_warn
            
            if WarningUI.Enabled ~= Desired then
                WarningUI.Enabled = Desired
            end
        end)

        WarningUI.Destroying:Connect(function()
            EnabledSignal:Disconnect()
        end)
    end

    RemoveWarning(PlayerGui:FindFirstChild("WARNING"))
    PlayerGui.ChildAdded:Connect(RemoveWarning)
end
-- GUI
-- Farming Section
local FarmingWindow = UI:CreateWindow("Farming")
local ItemSection = FarmingWindow:AddFolder("Items")
ItemSection.open = true
ItemSection:AddToggle({
    text = "Collect Items",
    flag = "collect_items"
})
ItemSection:AddToggle({
    text = "Collect Banknotes*",
    flag = "collect_banknotes"
})
ItemSection:AddToggle({
    text = "Auto Dig Sand*",
    flag = "auto_dig"
})
ItemSection:AddToggle({
    text = "No Item Cooldown",
    flag = "item_ncd"
})
ItemSection:AddToggle({
    text = "No 99 Warning",
    flag = "item_warn",
    state = true,
    callback = RemoveWarning
})
ItemSection:AddToggle({
    text = "Auto Sort Inventory",
    flag = "auto_sort_inventory",
    state = true,
    callback = SortInventory
})
local BossSection = FarmingWindow:AddFolder("Enemies")
BossSection.open = true
BossSection:AddToggle({
    text = "Kill Bosses*",
    flag = "bosses"
})
BossSection:AddToggle({
    text = "Kill Other Enemies*",
    flag = "reward_enemies"
})
BossSection:AddToggle({
    text = "Instant Kill*",
    flag = "instant_kill",
    tooltip = "Uses network ownership to insta kill",
    state = true
})
BossSection:AddToggle({
    text = "Spectate Enemy",
    flag = "view_when_killing"
})
local EnemyLabel = BossSection:AddLabel({
    text = "waiting..."
})
local PlayerWindow = UI:CreateWindow("Players")
local LocalSection = PlayerWindow:AddFolder("Local")
LocalSection.open = true
LocalSection:AddToggle({
    text = "No Move Cooldown*",
    flag = "move_ncd"
})
LocalSection:AddToggle({
    text = "Infinite Dodge*",
    flag = "inf_dodge",
    tooltip = "Does not bypass true damage"
})
local TrollSection = PlayerWindow:AddFolder("Trolling")
TrollSection.open = true
TrollSection:AddToggle({
    text = "Knock All**",
    flag = "knock_all",
    tooltip = "they all slip on the banan peel lol (this will get you banned if you are not careful)"
})
local MiscWindow = UI:CreateWindow("Misc")
local TeleportSection = MiscWindow:AddFolder("Teleports")
TeleportSection.open = true
do
    local LocationNames = {}

    for _, Location in workspace.Map:GetChildren() do
        if Location:IsA("Model") then
            table.insert(LocationNames, Location.Name)
        end
    end

    TeleportSection:AddList({
        text = "Map Locations",
        values = LocationNames,
        callback = function(Value)
            if Character then
                Character:PivotTo(workspace.Map[Value]:GetBoundingBox())
            end
        end
    })
end
do
    local NPCNames = {}
    
    for _, NPC in workspace.NPCs:GetChildren() do
        if NPC:IsA("Model") then
            table.insert(NPCNames, NPC.Name)
        end
    end

    TeleportSection:AddList({
        text = "NPCs",
        values = NPCNames,
        callback = function(Value)
            if Character then
                Character:PivotTo(workspace.NPCs[Value]:GetPivot())
            end
        end
    })
end
UI:Init()
-- No Item Cooldown
local OldWait
OldWait = hookfunction(getrenv().task.wait, function(...)
    local CallingScript = getcallingscript()
    local ScriptParent = CallingScript and CallingScript.Parent
    
    if ScriptParent and (UI.flags.item_ncd and ScriptParent:IsA("Tool")) or (UI.flags.move_ncd and ScriptParent == LocalPlayer.Backpack) then
        return OldWait()
    end

    return OldWait(...)
end)
-- No Move Cooldown
task.spawn(function()
    local Found = false

    while not Found do
        for _, v in getgc(true) do
            if type(v) == "table" and rawget(v, "GetCoolDowns") then
                Found = true

                local OldCooldown
                OldCooldown = hookfunction(v.GetCoolDowns, function(...)
                    if UI.flags.move_ncd then
                        return false
                    else
                        return OldCooldown(...)
                    end
                end)
            end
        end

        task.wait(1)
    end
end)
-- Item Loop
task.spawn(function()
    while UI.alive do
        -- Collect Items
        if UI.flags.collect_items and #Items > 0 and Character then
            for _, Handle in Items do
                for i = 0, 1 do
                    firetouchinterest(Handle, Character.HumanoidRootPart, i)
                end
            end
        end

        task.wait()
    end
end)
-- Kill Loop
task.spawn(function()
    while UI.alive do
        for Flag, EnemyTable in { bosses = Bosses, reward_enemies = RewardEnemies } do
            if not UI.flags[Flag] or #EnemyTable <= 0 then continue end

            local OldPos = Character and Character:GetPivot()
            local WentToEnemy = false

            while UI.flags[Flag] do
                local Entity = UI.flags.instant_kill and EnemyTable[1] or FightEntity(EnemyTable[1])

                if not Entity then break end

                local Humanoid = Entity:FindFirstChildWhichIsA("Humanoid")

                if not Humanoid then break end

                if UI.flags.instant_kill and Character then
                    local HumanoidRootPart = Entity:FindFirstChild("HumanoidRootPart")

                    if HumanoidRootPart then
                        if isnetworkowner(HumanoidRootPart) then
                            Entity:BreakJoints()     
                        else
                            Character:PivotTo(Entity:GetPivot() * CFrame.new(0, -5, 0))
                            WentToEnemy = true
                        end
                    end
                end
                
                EnemyLabel.Text = `{Entity.Name} ({math.round(Humanoid.Health - 0.5)}/{math.round(Humanoid.MaxHealth - 0.5)})`

                ViewSubject(Entity, UI.flags, "view_when_killing")

                task.wait()
            end

            EnemyLabel.Text = "waiting..."

            -- End View
            if WasViewing then
                ViewSubject()
            end
            
            if WentToEnemy and OldPos then
                Character:PivotTo(OldPos)
            end
        end

        task.wait()
    end
end)
-- Collect Banknote
task.spawn(function()
    while UI.alive do
        if UI.flags.collect_banknotes and #Banknotes > 0 and Character then
            local Banknote = Banknotes[1]
            local OldPos = Character:GetPivot()

            local StartTick = tick()
            while UI.flags.collect_banknotes and Banknote:IsDescendantOf(workspace) and (tick() - StartTick) < 1 and Character do
                -- Touch the banknote with yo feetsies
                Character:PivotTo(CFrame.new(Banknote:GetPivot().Position)--[[remove rotation if u were curious]] * CFrame.new(0, -2, 0) * CFrame.Angles(math.rad(-180), 0, 0))
                
                task.wait()
            end

            if Character then
                Character:PivotTo(OldPos)
            end
        end

        if UI.flags.auto_dig and Character then
            local OldPos = Character:GetPivot()
            local WentToSand = false

            for _, v in workspace.Interactable:GetChildren() do
                if not UI.flags.auto_dig or v.Name ~= "Sand" or v.Transparency > 0 or not Character then continue end

                local StartTick = tick()
                local Trowel: Tool = nil
                while UI.flags.auto_dig and Character and v.Transparency == 0 and (tick() - StartTick) < 2 do
                    Trowel = GetTool("Trowel")

                    if not Trowel then
                        local Money = GetData("Money")

                        if Money and Money >= 3500 then
                            PurchaseRE:FireServer("Trowel")
                            task.wait(0.5)
                        end

                        break
                    end

                    Trowel.Parent = Character
                    Character:PivotTo(v.CFrame * CFrame.new(0, -5, 0))
                    Trowel:Activate()
                    WentToSand = true

                    task.wait()
                end

            end

            if Character and WentToSand then
                Character:PivotTo(OldPos)
            end
        end

        task.wait()
    end
end)
-- Inf Dodge
task.spawn(function()
    while UI.alive do
        if UI.flags.inf_dodge then
            ReplicatedStorage.Dodge:FireServer() -- firing remote 5 quadrillion time so silly
        end

        RunService.RenderStepped:Wait()
    end
end)
-- Trolling
task.spawn(function()
    while UI.alive do
        if UI.flags.knock_all then
            for _, Player in Players:GetPlayers() do
                if Player == LocalPlayer then continue end

                local Humanoid = Player.Character and Player.Character:FindFirstChildWhichIsA("Humanoid")

                if not Humanoid then continue end

                ReplicatedStorage.Knock:FireServer(Humanoid)
            end
        end

        task.wait(0.5)
    end
end)
