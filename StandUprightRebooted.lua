--[[
Not my best or most optimized work. However, hopefully you can see the amount of time I put into it. Who cares if it's for a shitty jojo game. I did it for the love of the game.
Love you silly dudes. 
I think I will work on bridger western next.
- aturner
]]
---@diagnostic disable
if not game:IsLoaded() then
    game.Loaded:Wait()
end
--
local Library, Options, Toggles, Labels, Buttons, SaveManager, ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/turner308/Roblox-Scripts/refs/heads/master/User%20Interfaces/ObsidianUI.lua"))()
--
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer: Player = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Stats = {
    ItemsCollected = 0
}
local SelfData = LocalPlayer:WaitForChild("Data", 9e9)
local StandNameConvert = ReplicatedStorage.StandNameConvert
local ItemDataModule = require(ReplicatedStorage.Modules.ItemData)
local ItemMaxes = {}
for ItemName, ItemData in ItemDataModule do
    ItemMaxes[ItemName] = ItemData.MaxCapacity or "unknown"
end
local BossNames = {
    "Jotaro Over Heaven",
    "JohnnyJoestar"
}
local IgnoreStandMoves = {
    "ToggleRespawn",
    "TogglePilot",
    "Quote",
    "Block",
    "Pose",
    "Summon",
    "Jump",
    "Heal",
    "Wall",
    "Comms"
}
local IgnoreStandInfo = {
    "Sloppy",
    "Lethargic",
    "Tragic"
}
local Events = ReplicatedStorage.Events
-- Press play
Events.PressedPlay:FireServer()
task.spawn(function()
    local Menu = PlayerGui:WaitForChild("MenuGUI")

    repeat
        firesignal(Menu:WaitForChild("Play").MouseButton1Click)
        task.wait(1)
    until not Menu.Enabled
end)
-- wait for skills
local SkillTreeEvent = Events:WaitForChild("SkillTreeEvent", 9e9)
-- Stand Moves if they use the stupid new system (fuck these stupid devs)
local StandMoveOverrides = {
    ["TheHand"] = {
        ["Barrage"] = Enum.KeyCode.E,
        ["Heavy Punch"] = Enum.KeyCode.R,
        ["Erasure"] = Enum.KeyCode.X,
        ["Right Hand Swipe"] = Enum.KeyCode.Z
    },
    ["Anubis"] = {
        ["Barrage"] = Enum.KeyCode.E,
        ["Slashing Hit"] = Enum.KeyCode.R,
        ["Cursed Blade"] = Enum.KeyCode.T,
        ["Cursed Slash"] = Enum.KeyCode.Y
    }
}
StandMoveOverrides["TheHandRequiem"] = StandMoveOverrides["TheHand"]
-- Table Match String
local function FindStringInTable(Table, String)
    for _, v in Table do
        if v:find(String) then
            return true
        end
    end
end
-- Admin Detection
local function IsPlayerAdmin(Player)
    if not Player then return end

    local GroupRank = nil
    
    pcall(function()
        GroupRank = Player:GetRankInGroupAsync(10885371)
    end)

    if GroupRank and GroupRank > 1 then
        LocalPlayer:Kick("Admin in game... Safe kick")
    end
end

for _, Player in Players:GetPlayers() do
    IsPlayerAdmin(Player)
end

Players.PlayerAdded:Connect(IsPlayerAdmin)
-- roblox disconnect rejoin
local promptOverlay = CoreGui.RobloxPromptGui.promptOverlay

local function OnRobloxPrompt(Title, Message)
    if Message:find("Egg") then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
        return
    end

    if Message:lower():find("ban") then
        print(game.JobId)
        return
    end

    TeleportService:Teleport(game.PlaceId)
end

local function CheckForPrompts(Object)
    local ErrorPrompt = Object.Name == "ErrorPrompt" and Object or Object:FindFirstChild("ErrorPrompt")

    if ErrorPrompt then
        OnRobloxPrompt(
            ErrorPrompt.TitleFrame.ErrorTitle.Text,
            ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text
        )
    end
end

task.delay(3, function()
    CheckForPrompts(promptOverlay) -- i dont remember why exactly i did 3 seconds
end)

promptOverlay.ChildAdded:Connect(CheckForPrompts)
-- Get Stand Names, Attributes, Chances , yeah I know its kind of a nightmare the way I got the stand data lol
local StandInfo = {}
local RawStandInfo = {}
local UnRawStandInfo = {}
local ChancesBoards = nil

repeat
    ChancesBoards = workspace.Map.ChancesBoards
    task.wait(0.1)
until #ChancesBoards:GetChildren() >= 6

for _, Board in ChancesBoards:GetChildren() do
    for _, Chance in Board.newSurface.ScrollFrame:GetChildren() do
        if Chance:IsA("TextLabel") then
            local ChanceText = Chance.Text
            local RawName = ChanceText

            if ChanceText:find("%%") then
                local SText = ChanceText:split(" ")
                RawName = table.concat(table.move(SText, 1, #SText - 1, 1, {}), " ")
            end

            if table.find(IgnoreStandInfo, RawName) then
                continue
            end

            if not RawStandInfo[ChanceText] then
                RawStandInfo[ChanceText] = RawName
            end

            if not UnRawStandInfo[RawName] then
                UnRawStandInfo[RawName] = ChanceText
            end

            if not StandInfo[Board.Name] then
                StandInfo[Board.Name] = {}
            end

            table.insert(StandInfo[Board.Name], ChanceText)
        end
    end
end

for _, Info in StandInfo do
    if not Info[1]:find("%%") then
        continue
    end

    table.sort(Info, function(A, B)
        local PercA = tonumber(string.match(A, "(%d+%.?%d*)%s*%%")) -- get percentage chance
        local PercB = tonumber(string.match(B, "(%d+%.?%d*)%s*%%"))

        return PercA < PercB -- sort by chance
    end)
end
-- Remove Percentages from attributes
for i, Attribute in StandInfo.AttributeChances do
    StandInfo.AttributeChances[i] = Attribute:gsub(" (%d+%.?%d*)%s*%%", "")
end
-- Anti afk
for _, v in getconnections(LocalPlayer.Idled) do v:Disable() end
-- Get Quests
local Quests = {
    { NPC = "Giorno", Level = 1 },
    { NPC = "Scared Noob", Level = 10 },
    { NPC = "Koichi", Level = 20 },
    { NPC = "Okayasu", Level = 40 },
    { NPC = "Joseph Joestar", Level = 50 },
    { NPC = "Josuke", Level = 75 },
    { NPC = "Rohan", Level = 100 },
    { NPC = "DIO", Level = 125 },
    { NPC = "Muhammed Avdol", Level = 150 },
    { NPC = "Giorno", Level = 175 },
    { NPC = "Young Joseph", Level = 275 },
    { NPC = "Diavolo", Level = 500 }
}

-- GetBestQuest
local NPCLevelCache = {}
local function GetBestQuestNPC()
    local BestQuest = nil
    local BestQuestLevel = 0
    local PlayerLevel = SelfData.Level.Value

    for i = 1, #Quests do 
        local QuestData = Quests[i]
        
        if PlayerLevel < QuestData.Level then continue end

        -- i did it this way because when you spawn in the npcs dont have any tags until rendered, i had a more "optimized" version before but this works good enough
        for _, NPC in workspace.Map.NPCs:GetChildren() do
            if NPC.Name == QuestData.NPC then
                local CacheLevel = NPCLevelCache[NPC]
                if CacheLevel and CacheLevel ~= QuestData.Level then
                    continue
                end

                local Head = NPC:FindFirstChild("Head")

                if not Head then continue end

                local MainTag = Head:FindFirstChild("Main")
                local SubTag = Head:FindFirstChild("Sub")

                if not MainTag or not SubTag then continue end

                local MainText = MainTag.Text.Text
                local SubText = SubTag:FindFirstChildWhichIsA("TextBox") or SubTag:FindFirstChildWhichIsA("TextLabel")

                if not SubText then continue end

                SubText = SubText.Text
                
                if not MainText:find("Lvl") then continue end

                local Level = tonumber(MainText:split("Lvl")[2]:match("%d+"))

                if Level ~= QuestData.Level then continue end

                NPCLevelCache[NPC] = Level
                BestQuest = NPC
                BestQuestLevel = QuestData.Level
            end
        end
    end

    return BestQuest, BestQuestLevel
end
-- Player Alive, yeah I made a better system than this but this works
local function PlayerAlive(Func)
	local Character = LocalPlayer.Character
    
	if Character then
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		local IsAlive = Humanoid and Humanoid.Health > 0 and Character, Humanoid

        if Func and IsAlive then
            return Func(IsAlive)
        end

        return IsAlive
	end
end
-- Teleport
local function MoveCharacter(Destination, Char)
	local Character = Char or PlayerAlive()
    
	if Character and Character.PrimaryPart then
		Character.PrimaryPart.AssemblyAngularVelocity = Vector3.zero
		Character.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
		Character:PivotTo(Destination)
	end
end
-- Check stand enabled, this function is questionable but I didnt see any easier methods, there probably is a better way
local function IsStandEnabled()
    local Stand = LocalPlayer.Character:FindFirstChild("Stand")

    if Stand then
        local TotalBaseParts = 0
        local TotalEnabled = 0

        for _, v in Stand:GetChildren() do
            if v:IsA("BasePart") then
                if v.Transparency < 1 then
                    TotalEnabled += 1
                end

                TotalBaseParts += 1
            end
        end

        local PercentageEnabled = (TotalEnabled / TotalBaseParts) * 100
        
        return PercentageEnabled > 50
    end
end
--#endregion
--#region GUI
--region quotes, if you dont liek them then fuck you
local JoJoQuotes = {
    "It was me, Dio!",
    "Za Warudo! Toki wo tomare!",
    "MUDA MUDA MUDA MUDA MUDA!",
    "Yare yare daze.",
    "ORA ORA ORA ORA ORA!",
    "You truly are the lowest scum in history. You can't pay back what you owe with money.",
    "Your next line is: 'How did you know what I was going to say?!'",
    "OH MY GOD!",
    "I, Giorno Giovanna, have a dream.",
    "You may have outsmarted me, but I outsmarted your outsmarting!",
    "What’d you say about my hair?!",
    "Arrivederci.",
    "Yare yare dawa.",
    "Made in Heaven!",
    "My name is Yoshikage Kira. I’m 33 years old...",
    "Bites the Dust!",
    "I’m going to make you pay for what you did... with your life!",
    "Even Speedwagon is afraid!",
    "The only thing you can trust is the thickness of your own muscles.",
    "I can’t beat the crap out of you without getting closer.",
    "You’re approaching me? Instead of running away, you're coming right to me?",
    "I have no weakness. I am perfection.",
    "Reality is whatever I want it to be.",
    "Go ahead and shoot me! My Stand will punch the bullets away!",
    "This is the taste of a liar, Giorno Giovanna!",
    "Heaven will be mine. That is fate.",
    "Everything I did, I did for my peace and quiet.",
    "You thought your first kiss would be JoJo, but it was I, Dio!",
    "My Stand is the strongest — it has no weaknesses.",
    "Golden Experience Requiem… will never let you reach the truth.",
}
--#endregion
local Window = Library:CreateWindow({
    Title = "Stand Upright",
    Footer = JoJoQuotes[math.random(1, #JoJoQuotes)],
    ToggleKeybind = Enum.KeyCode.RightControl,
    Center = true,
    AutoShow = true
})
local MainTab = Window:AddTab("Main")
local ItemSection = MainTab:AddLeftTabbox()
local ItemFarm = ItemSection:AddTab("Item Farm")
ItemFarm:AddToggle("Easter Eggs", {
    Text = "Easter Eggs"
})
ItemFarm:AddToggle("Item Farm", {
    Text = "Item Farm"
})
ItemFarm:AddLabel("Items Collected", {
    Text = "Items Collected: 0"
})
ItemFarm:AddLabel("Spawned Items", {
    Text = "Spawned Items: 0"
})
ItemFarm:AddToggle("Sell Ketchup", {
    Text = "Sell Ketchup (Lvl 55+)",
    Value = true
})
local Inventory = ItemSection:AddTab("Inventory")
Inventory:AddLabel("Inventory", {
    Text = "Loading...",
    DoesWrap = true
})
local function UpdateInventoryLabel()
    local Backpack = LocalPlayer:FindFirstChild("Backpack")

    if not Backpack then
        Backpack = LocalPlayer:WaitForChild("Backpack", 3)

        if not Backpack then
            return
        end
    end

    local LabelText = {}
    local OwnedItems = {}

    for _, Item in Backpack:GetChildren() do
        if Item:GetAttribute("ItemAmount") then
            table.insert(LabelText, `<font color="rgb(100, 200, 100)">{Item.Name}: {Item:GetAttribute("ItemAmount")}/{ItemMaxes[Item.Name]}</font>`)
            table.insert(OwnedItems, Item.Name)
        end
    end

    if LocalPlayer.Character then
        for _, Item in LocalPlayer.Character:GetChildren() do
            if Item:GetAttribute("ItemAmount") then
                table.insert(LabelText, `<font color="rgb(100, 200, 100)">(Held) {Item.Name}: {Item:GetAttribute("ItemAmount")}/{ItemMaxes[Item.Name]}</font>`)
                table.insert(OwnedItems, Item.Name)
            end
        end
    end

    table.sort(LabelText)

    local GrayText = {}

    for ItemName, ItemMax in ItemMaxes do
        if not table.find(OwnedItems, ItemName) then
            table.insert(GrayText, `<font color="rgb(100, 100, 100)">{ItemName}: 0/{ItemMax}</font>`)
        end
    end

    table.sort(GrayText)

    Labels["Inventory"]:SetText(table.concat(LabelText, "\n") .. "\n" .. table.concat(GrayText, "\n"))
end
local EntityFarm = MainTab:AddRightGroupbox("Entity Farming")
EntityFarm:AddLabel("Level Farm Info", {
    Text = "Loading..."
})
EntityFarm:AddToggle("Level Farm", {
    Text = "Level Farm",
    Callback = function(Value)
        if not Value then
            PlayerAlive(function(Character)
                Character.HumanoidRootPart.Anchored = false
            end)
        end

        LocalPlayer.DevCameraOcclusionMode = Value and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom
    end
})
EntityFarm:AddToggle("Boss Farm", {
    Text = "Boss Farm (1st Priority)",
    Callback = function(Value)
        LocalPlayer.DevCameraOcclusionMode = Value and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom
    end
})
EntityFarm:AddDropdown("Boss Farm Select", {
    Text = "Boss Selection",
    Multi = false,
    Values = {"All", "Jotaro Over Heaven", "Johnny Joestar"},
    Default = "All",
    Callback = function(Value)
        -- i will fix this later, hacky solution
        if Options["Boss Farm Select"].Value["Johnny Joestar"] then
            Options["Boss Farm Select"].Value["JohnnyJoestar"] = true
        else
            Options["Boss Farm Select"].Value["JohnnyJoestar"] = nil
        end
    end
})
EntityFarm:AddToggle("Use Moves", {
    Text = "Use Moves"
})
EntityFarm:AddDropdown("Selected Moves", {
    Text = "Select Moves",
    Multi = true
})
local LastStand = nil
local function UpdateStandMoves()
    local StandValue = SelfData.Stand.Value
    if LastStand == StandValue then return end

    if StandMoveOverrides[StandValue] then
        local Names = {}

        for MoveName, _ in StandMoveOverrides[StandValue] do
            table.insert(Names, MoveName)
        end

        Options["Selected Moves"]:SetValues(Names)
        return
    end

    LastStand = SelfData.Stand.Value

    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local StandEvents = LocalPlayer.Character:WaitForChild("StandEvents", 3)
    local StandMoves = {}

    if StandEvents then
        for _, v in StandEvents:GetChildren() do
            if not table.find(IgnoreStandMoves, v.Name) then
                table.insert(StandMoves, v.Name)
            end
        end
    end

    Options["Selected Moves"]:SetValues(StandMoves)
end
EntityFarm:AddToggle("Auto Skill Tree", {
    Text = "Auto Skill Tree"
})
local OtherSection = MainTab:AddRightTabbox()
local InteractSection = OtherSection:AddTab("Interacts")
InteractSection:AddButton("Stand Storage", function()
    workspace.Map.NPCs.admpn.Done:FireServer()
end)
local StandSection = MainTab:AddLeftTabbox()
local StandFarmingSection = StandSection:AddTab("Primary")
StandFarmingSection:AddDropdown("Desired Attributes", {
    Text = "Desired Attributes",
    Multi = true,
    Values = {"Any", unpack(StandInfo.AttributeChances)}
})
StandFarmingSection:AddDropdown("Desired Charged Stands", {
    Text = "Charged Arrow Stands",
    Multi = true,
    Values = {"Any", unpack(StandInfo.ChargedArrowChances)}
})
StandFarmingSection:AddDropdown("Desired Normal Stands", {
    Text = "Normal Arrow Stands",
    Multi = true,
    Values = {"Any", unpack(StandInfo.NormalArrowChances)}
})
StandFarmingSection:AddDropdown("Roll Type", {
    Text = "Roll Type",
    Multi = false,
    Values = {"Normal Arrows", "Both (Normal First)", "Charged Arrows", "Both (Charged First)"},
    Default = 4
})
StandFarmingSection:AddToggle("Sure Roll", {
    Text = "Are You Sure?"
})
StandFarmingSection:AddToggle("Auto Roll Stand", {
    Text = "Auto Roll Stand"
})
StandFarmingSection:AddLabel("Stand Info Label", {
    Text = "Stand Info Loading...",
    DoesWrap = true
})
local StandRollTimes = 0
local function UpdateStandInfoLabel()
    local ConvertedStandName = StandNameConvert:FindFirstChild(SelfData.Stand.Value)
    ConvertedStandName = ConvertedStandName and ConvertedStandName.Value or SelfData.Stand.Value
    Labels["Stand Info Label"]:SetText(`Stand: {ConvertedStandName}\nAttribute: {SelfData.Attri.Value}\nSpec: {SelfData.Spec.Value}\nRolls Done: {StandRollTimes}`)
end
SelfData.Stand.Changed:Connect(UpdateStandInfoLabel)
SelfData.Attri.Changed:Connect(UpdateStandInfoLabel)
SelfData.Spec.Changed:Connect(UpdateStandInfoLabel)
UpdateStandInfoLabel()
local StandFarming2 = StandSection:AddTab("Secondary")
StandFarming2:AddDropdown("Desired Attributes 2", {
    Text = "Desired Attributes",
    Multi = true,
    Values = {"Any", unpack(StandInfo.AttributeChances)}
})
StandFarming2:AddDropdown("Desired Charged Stands 2", {
    Text = "Charged Arrow Stands",
    Multi = true,
    Values = {"Any", unpack(StandInfo.ChargedArrowChances)}
})
StandFarming2:AddDropdown("Desired Normal Stands 2", {
    Text = "Normal Arrow Stands",
    Multi = true,
    Values = {"Any", unpack(StandInfo.NormalArrowChances)}
})
StandFarming2:AddLabel("Double Farm", {
    Text = "Example Usage: Farm for multiple stand types at the same time.",
    DoesWrap = true
})
local MainTabInfoSection = MainTab:AddRightTabbox()
local MainInfoLeft = MainTabInfoSection:AddTab("Other Info")
MainInfoLeft:AddLabel("Server Time", {
    Text = "Server Time"
})
local ServerTimeLabel = PlayerGui.newStatsGUI.StatsMenu.SubStats.B_ServerTime
ServerTimeLabel:GetPropertyChangedSignal("Text"):Connect(function()
    Labels["Server Time"]:SetText(ServerTimeLabel.Text:gsub(" hour", "H"):gsub(" hours", "H"):gsub(" minutes", "M"):gsub(" seconds", "S"))
end)
--#endregion
--#region UI Settings
local UISettings = Window:AddTab("Settings")
local MenuGroup = UISettings:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end
})
Library.ShowCustomCursor = false
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Library.Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
Library.LibrarySet = true
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("aturner_scripts")
SaveManager:SetFolder("aturner_scripts/JoJo Hub")
SaveManager:SetSubFolder("JoJo Hub" .. game.PlaceId)
SaveManager:BuildConfigSection(UISettings)
ThemeManager:ApplyToTab(UISettings)
SaveManager:LoadAutoloadConfig()
-- persist data on rejoin
LocalPlayer.OnTeleport:Connect(function()
    local p1 = [[while not Library do
        task.wait()
    end

    while not Library.LibrarySet do
        task.wait()
    end

    task.wait(2)

    Library.SaveManager:Load(nil, [[]]
    queue_on_teleport(p1 .. SaveManager:GetEncodedData() .. ']])')
end)
--
local Debug = UISettings:AddRightGroupbox("Debug")
Debug:AddLabel("Debug", {
    Text = "Loading..."
})
--#endregion
--#region Item Farm Optimization
-- workspace cons
local ItemPrompts = {}
local function FindItemPrompts(Child)
    if Child:IsA("Tool") or Child.Name == "ItemPromptHolder" or Child:IsA("ProximityPrompt") then
        Child.ChildAdded:Connect(FindItemPrompts)

        local Prompt: ProximityPrompt = Child:IsA("ProximityPrompt") and Child or Child:FindFirstChildWhichIsA("ProximityPrompt", true)

        if Prompt then
            table.insert(ItemPrompts, Prompt)

            Prompt.Destroying:Once(function()
                table.remove(ItemPrompts, table.find(ItemPrompts, Prompt))
            end)

            Labels["Spawned Items"]:SetText(`Spawned Items: {#ItemPrompts}`)
        end
    end
end
workspace.ChildAdded:Connect(FindItemPrompts)
workspace.ChildRemoved:Connect(FindItemPrompts)
for _, Child in workspace:GetChildren() do
    FindItemPrompts(Child)
end
-- Vfx folder cons
workspace.Vfx.ChildAdded:Connect(FindItemPrompts)
workspace.Vfx.ChildRemoved:Connect(FindItemPrompts)
for _, Child in workspace.Vfx:GetChildren() do
    FindItemPrompts(Child)
end
-- Easter Eggs
local EasterEggs = {}
local function FindEggs(Child)
    if Child.Name == "ActiveEgg" then
        table.insert(EasterEggs, Child)
    end
end
for _, Child in workspace.EasterEggs:GetChildren() do
    FindEggs(Child)
end
workspace.EasterEggs.ChildAdded:Connect(FindEggs)
workspace.EasterEggs.ChildRemoved:Connect(function(Child)
    if Child.Name == "ActiveEgg" then
        table.remove(EasterEggs, table.find(EasterEggs, Child))
    end
end)
-- Get Item Total
local LastTotal = nil
local function GetItemTotal()
    local Total = 0

    for _, Folder in {LocalPlayer.Backpack, LocalPlayer.Character} do
        for _, v in Folder:GetChildren() do
            local ItemAmount = v:GetAttribute("ItemAmount")
    
            if ItemAmount then
                Total += ItemAmount
            end
        end
    end

    return Total
end
LastTotal = GetItemTotal()
--#endregion
--#region Fight Entity
local AttackTick = 1
local ItemMagnitudeLoadTick = 3
local QuestFireTick = 1
local function FightEntity(Entity)
    local Humanoid = Entity:FindFirstChildWhichIsA("Humanoid")

    if not (Humanoid and Humanoid.Health > 0) then
        return
    end

    local Character = PlayerAlive()

    if not Character then
        return
    end

    local Humanoid = Character.Humanoid
    
    -- stupid ass thinks he can take a break
    if Humanoid.Sit and Humanoid.SeatPart then
        Humanoid.SeatPart:Destroy()
        Humanoid.Sit = false
    end

    MoveCharacter(CFrame.lookAt(
        (Entity:GetPivot() * CFrame.new(0, -7, 6)).Position,
        Entity:GetPivot().Position
    ))
    Labels["Debug"]:SetText("teleporting to enemy")

    local StandEvents = Character:FindFirstChild("StandEvents")

    if StandEvents then
        local Standless = StandEvents:FindFirstChild("Comms")

        if not Standless then
            local StandEquipped = Character.Aura.Value or IsStandEnabled()
            local StandInput = StandEvents:FindFirstChild("Input")

            if not StandEquipped then
                if StandInput then
                    StandInput:FireServer({
                        State = "Begin",
                        Type = Enum.UserInputType.Keyboard,
                        Key = Enum.KeyCode.Q
                    })
                    StandInput:FireServer({
                        State = "End",
                        Type = Enum.UserInputType.Keyboard,
                        Key = Enum.KeyCode.Q
                    })
                else 
                    StandEvents.Summon:FireServer()
                end
            else
                if not Character.MoveCD.Value then
                    local StandModel = Character:FindFirstChild("Stand")

                    if StandModel and (tick() - AttackTick) >= 0.2 then

                        AttackTick = tick()

                        if Toggles["Use Moves"].Value then
                            if StandInput then
                                local StandName = SelfData.Stand.Value
                                local StandMoves = StandMoveOverrides[StandName]

                                if StandMoves then 
                                    StandInput:FireServer({
                                        State = "Begin",
                                        Type = Enum.UserInputType.MouseButton1,
                                        Key = Enum.KeyCode.Unknown
                                    })
                                    StandInput:FireServer({
                                        State = "End",
                                        Type = Enum.UserInputType.MouseButton1,
                                        Key = Enum.KeyCode.Unknown
                                    })

                                    for MoveName, _ in Options["Selected Moves"].Value do
                                        local MoveKey = StandMoves[MoveName]

                                        if MoveKey then
                                            StandInput:FireServer({
                                                State = "Begin",
                                                Type = Enum.UserInputType.Keyboard,
                                                Key = MoveKey
                                            })
                                            StandInput:FireServer({
                                                State = "End",
                                                Type = Enum.UserInputType.Keyboard,
                                                Key = MoveKey
                                            })
                                        end
                                    end
                                end
                            else
                                StandEvents.M1:FireServer()

                                for _, Event in StandEvents:GetChildren() do
                                    if Options["Selected Moves"].Value[Event.Name] then
                                        Event:FireServer()
                                    end
                                end
                            end

                            Labels["Debug"]:SetText("attacking")
                        else
                            if StandInput then
                                StandInput:FireServer({
                                    State = "Begin",
                                    Type = Enum.UserInputType.MouseButton1,
                                    Key = Enum.KeyCode.Unknown
                                })
                                StandInput:FireServer({
                                    State = "End",
                                    Type = Enum.UserInputType.MouseButton1,
                                    Key = Enum.KeyCode.Unknown
                                })
                            else
                                StandEvents.M1:FireServer()
                            end
                        end
                    end
                end
            end
        else
            -- Standless m1
            Standless:FireServer("Beg", Enum.UserInputType.MouseButton1)
        end
    end

    return true
end
--#endregion
-- Can Roll function
local function IsRollingSetup()
    return (#Options["Desired Normal Stands"]:GetActiveValues() > 0 or #Options["Desired Charged Stands"]:GetActiveValues() > 0) and #Options["Desired Attributes"]:GetActiveValues() > 0
end
-- Secondary Roll Setup
local function IsRollingSetup2()
    return (#Options["Desired Normal Stands 2"]:GetActiveValues() > 0 or #Options["Desired Charged Stands 2"]:GetActiveValues() > 0) and #Options["Desired Attributes 2"]:GetActiveValues() > 0
end
-- Check Player For Item
local function GetItem(ItemName)
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(ItemName) or LocalPlayer.Backpack:FindFirstChild(ItemName)
end
-- Put Away Items
local function PutAwayItems(CharacterReference, Ignore)
    for _, v in CharacterReference and CharacterReference:GetChildren() or LocalPlayer.Character:GetChildren() do
        if v:IsA("Tool") and v ~= Ignore then
            v.Parent = LocalPlayer.Backpack
        end
    end
end
-- #region Roll Stand Function
local function RollStand()
    while SelfData.Stand.Value ~= "None" and Toggles["Auto Roll Stand"].Value and Toggles["Sure Roll"].Value and IsRollingSetup() do
        local Character = PlayerAlive()

        if not Character then
            break
        end

        local Roka = GetItem("Rokakaka")

        if Roka then
            PutAwayItems(Character, Roka)
            Roka.Parent = Character
            task.wait(0.5)
            Events.UseItem:FireServer()
        else
            break
        end

        task.wait()
    end

    local ArrowDone = false
    while SelfData.Stand.Value == "None" and Toggles["Auto Roll Stand"].Value and Toggles["Sure Roll"].Value and IsRollingSetup() do
        local Character = PlayerAlive()

        if not Character then
            break
        end

        local PlayerLevel = SelfData.Level.Value
        local ArrowFound = 
        (Options["Roll Type"].Value == "Both (Charged First)" and (PlayerLevel >= 30 and GetItem("Charged Arrow")) or GetItem("Stand Arrow")) or
        (Options["Roll Type"].Value == "Both (Normal First)" and GetItem("Stand Arrow") or (PlayerLevel >= 30 and GetItem("Charged Arrow"))) or
        (Options["Roll Type"].Value == "Normal Arrows" and GetItem("Stand Arrow")) or
        (Options["Roll Type"].Value == "Charged Arrows" and GetItem("Charged Arrow"))

        if ArrowFound then
            PutAwayItems(Character, ArrowFound)
            ArrowFound.Parent = Character
            task.wait(0.5)
            Events.UseItem:FireServer()
            ArrowDone = true
        else
            break
        end

        task.wait()
    end

    if ArrowDone then
        StandRollTimes += 1
    end
end 
-- #endregion
-- Slow Loop
task.spawn(function()
    while Library do
        UpdateStandMoves()

        if Toggles["Auto Skill Tree"].Value then
            SkillTreeEvent:FireServer(
                "PurchaseAll",
                "Stand"
            )
        end

        if SelfData.Level.Value >= 55 then
            Toggles["Sell Ketchup"]:SetText("Sell Ketchup (Lvl 55+)")

            if Toggles["Sell Ketchup"].Value and LocalPlayer.Backpack:FindFirstChild("Ketchup") then
                Events.SellKetchup:FireServer("Lots")
            end
        else
            Toggles["Sell Ketchup"]:SetText('<font color="rgb(255, 50, 50)">Sell Ketchup (Lvl 55+)</font>')
        end

        local BestQuestNPC, QuestLevel = GetBestQuestNPC()
        if BestQuestNPC then
            Labels["Level Farm Info"]:SetText(`{BestQuestNPC} {QuestLevel}+`)
        end

        task.wait(0.5)
    end
end)
-- semi fast loop
task.spawn(function()
    while Library do
        UpdateInventoryLabel()
        task.wait(0.1)
    end
end)
--#region Main Loop
task.spawn(function()
    while Library do
        if Toggles["Easter Eggs"].Value and #EasterEggs > 0 then
            local Character = PlayerAlive()

            if Character then
                for _, Egg in EasterEggs do
                    if Egg.Transparency == 0 then
                        local ClickDetector = Egg:FindFirstChildWhichIsA("ClickDetector")
                        local PreviousLoc = Character:GetPivot()

                        local StartTick = tick()
                        while (tick() - StartTick) < 3 and ClickDetector:IsDescendantOf(workspace) and Toggles["Easter Eggs"].Value and Egg.Transparency == 0 do
                            MoveCharacter(Egg.CFrame, Character)

                            task.wait(0.1)

                            if (Character:GetPivot().Position - Egg.Position).Magnitude < 10 then
                                MoveCharacter(Egg.CFrame, Character)
                                fireclickdetector(ClickDetector)
                            end

                            task.wait(0.1)
                        end

                        if Character then
                            MoveCharacter(PreviousLoc, Character)
                        end
                    end
                end
            end
        else
            if Toggles["Boss Farm"].Value then
                for _, BossName in BossNames do
                    if Options["Boss Farm Select"].Value == BossName or Options["Boss Farm Select"].Value == "All" then
                        local FoundBoss = workspace.Living:FindFirstChild(BossName)

                        while FoundBoss and Toggles["Boss Farm"].Value do
                            if not FightEntity(FoundBoss) then
                                break
                            end

                            task.wait()
                        end
                    end
                end
            end

            if Toggles["Item Farm"].Value then
                local Character = PlayerAlive()

                if Character then
                    Labels["Debug"]:SetText("Finding item")

                    while #ItemPrompts ~= 0 and Toggles["Item Farm"].Value and Character and not (Toggles["Easter Eggs"].Value and #EasterEggs > 0) do
                        for _, Prompt: ProximityPrompt in ItemPrompts do
                            if not Toggles["Item Farm"].Value or not Character then
                                break
                            end

                            if Prompt.Enabled and Prompt.MaxActivationDistance > 0 then
                                local Handle = Prompt:FindFirstAncestorWhichIsA("BasePart")
                                local OldPos = Character:GetPivot()
                                local WentToCollect = false

                                Prompt.Destroying:Once(function()
                                    if WentToCollect then
                                        MoveCharacter(OldPos, Character)
                                        Stats.ItemsCollected += 1
                                        Labels["Items Collected"]:SetText(`Items Collected: {Stats.ItemsCollected}`)
                                        Labels["Spawned Items"]:SetText(`Spawned Items: {math.max(#ItemPrompts - 1, 0)}`)
                                    end
                                end)

                                local StartTick = tick()
                                while (tick() - StartTick) < 3 and Handle and Prompt:IsDescendantOf(workspace) and Prompt.Enabled and Toggles["Item Farm"].Value do
                                    Character = PlayerAlive()

                                    if not Character then break end

                                    WentToCollect = true
                                    MoveCharacter(Handle:GetPivot() * CFrame.new(0, 3, 0), Character)
                                    task.wait(0.05)
                                    fireproximityprompt(Prompt)
                                    task.wait(0.05)
                                    Labels["Debug"]:SetText("Grabbing item")
                                end
                            end
                        end

                        task.wait()
                    end
                end
            end

            if Toggles["Level Farm"].Value then
                local Character = PlayerAlive()

                if Character then
                    local QuestFolder = SelfData.Quests:FindFirstChildWhichIsA("Folder")

                    if QuestFolder then
                        local Completed = QuestFolder:FindFirstChild("Completed")

                        if Completed and Completed.Value then
                            if (tick() - QuestFireTick) >= 1 then
                                QuestFireTick = tick()

                                for _, NPC in workspace.Map.NPCs:GetChildren() do
                                    local QuestDone = NPC:FindFirstChild("QuestDone")

                                    if QuestDone then
                                        QuestDone:FireServer()
                                    end
                                end
                            end

                            Labels["Debug"]:SetText("Getting quest")
                        else
                            local Type = QuestFolder.Type.Value

                            if Type == "Kill" then
                                local EnemyName = QuestFolder.Enemy.Value
                                local BestEnemy = nil
                                local LowestHealth = math.huge
                                
                                for _, v in workspace.Living:GetChildren() do
                                    if v.Name == EnemyName then
                                        local Humanoid = v:FindFirstChildWhichIsA("Humanoid")

                                        if Humanoid and Humanoid.Health > 0 and Humanoid.Health < LowestHealth then
                                            LowestHealth = Humanoid.Health
                                            BestEnemy = v
                                        end
                                    end
                                end

                                Labels["Debug"]:SetText(`finding enemy {BestEnemy}`)

                                while BestEnemy and Toggles["Level Farm"].Value do
                                    if not FightEntity(BestEnemy) then
                                        break
                                    end

                                    task.wait()
                                end
                            end
                        end
                    else
                        local BestQuestNPC, QuestLevel = GetBestQuestNPC()

                        if BestQuestNPC then
                            BestQuestNPC.Done:FireServer()
                        end
                    end
                end
            end
        end

        task.wait()
    end
end)
-- Roll Stand Loop
task.spawn(function()
    while Library do
        if Toggles["Auto Roll Stand"].Value and Toggles["Sure Roll"].Value and IsRollingSetup() then
            -- Desired Stand
            local NormalStandSelections = Options["Desired Normal Stands"].Value
            local ChargedStandSelections = Options["Desired Charged Stands"].Value
            local CurrentStand = StandNameConvert:FindFirstChild(SelfData.Stand.Value)

            -- If no stand then roll
            if not CurrentStand then
                RollStand()
            else
                CurrentStand = CurrentStand.Value
                local UnRawCurrentStand = UnRawStandInfo[CurrentStand]
                local DesiredStand =
                (NormalStandSelections["Any"] and FindStringInTable(StandInfo.NormalArrowChances, CurrentStand)) or
                (ChargedStandSelections["Any"] and FindStringInTable(StandInfo.ChargedArrowChances, CurrentStand)) or
                (NormalStandSelections[UnRawCurrentStand] or ChargedStandSelections[UnRawCurrentStand])

                if IsRollingSetup2() then
                    local NormalStandSelections2 = Options["Desired Normal Stands 2"].Value
                    local ChargedStandSelections2 = Options["Desired Charged Stands 2"].Value
                    local DesiredStand2 = 
                    (NormalStandSelections2["Any"] and FindStringInTable(StandInfo.NormalArrowChances, CurrentStand)) or
                    (ChargedStandSelections2["Any"] and FindStringInTable(StandInfo.ChargedArrowChances, CurrentStand)) or
                    (NormalStandSelections2[UnRawCurrentStand] or ChargedStandSelections2[UnRawCurrentStand])

                    if DesiredStand2 then
                        -- Obtained desired stand so turn toggle off
                        Toggles["Auto Roll Stand"]:SetValue(false)
                        Toggles["Sure Roll"]:SetValue(false)
                        continue
                    end
                end

                if not DesiredStand then
                    RollStand()
                else
                    -- Desired Attribute
                    local AttrSelections = Options["Desired Attributes"].Value
                    local DesiredAttribute = AttrSelections["Any"] or AttrSelections[SelfData.Attri.Value] or Options["Desired Attributes"]:GetActiveValues() == 0

                    if not DesiredAttribute then
                        RollStand()
                    else
                        -- Obtained desired stand so turn toggle off
                        Toggles["Auto Roll Stand"]:SetValue(false)
                        Toggles["Sure Roll"]:SetValue(false)
                    end
                end
            end
        end
        
        task.wait()
    end
end)
Labels["Debug"]:SetText("Loaded")
--#endregion

-- notes to self --
-- make moves persist
-- optimize level farm if you can, I think its fine tbh

-- if u made it this far then thanks for reading 😎
