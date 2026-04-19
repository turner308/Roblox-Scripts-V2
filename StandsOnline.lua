---@diagnostic disable
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/turner308/Roblox-Scripts/refs/heads/master/UwUware"))()
--
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage.Events
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Items = workspace.Items
local Inventory =  LocalPlayer.Inventory
local TriedCollect = {}
local IgnoreItems = { "DespairStone", "rageStone", "JoyStone" }
-- Max Storage Slots (869791407 if user owns 2x gamepass, double the cap)
local MaxStorageSlots = ReplicatedStorage.GameSettings.MaxStorageSlots
local StorageCap = game:GetService("MarketplaceService"):UserOwnsGamePassAsync(LocalPlayer.UserId, 869791407) and MaxStorageSlots.Value * 2 or MaxStorageSlots.Value
-- Anti AFK
for _, v in next, getconnections(LocalPlayer.Idled) do v:Disable() end
-- Player Alive
local function PlayerAlive()
	local Character = LocalPlayer.Character

	if Character then
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")

		return Humanoid and Humanoid.Health > 0 and Character
	end
end
-- Disable PlatformStand
local function DisablePlatformStand()
	local Character = PlayerAlive()

	if Character then
		Character.Humanoid.PlatformStand = false
	end
end
-- Teleport
local function MoveCharacter(Destination, Char)
	local Character = Char or PlayerAlive()

	if Character then
		Character.PrimaryPart.AssemblyAngularVelocity = Vector3.zero
		Character.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
		Character:PivotTo(Destination)
	end
end
-- UI
local Window = UI:CreateWindow("Farm")
Window:AddToggle({text = "Level Farm", flag = "level_farm", state = false, callback = DisablePlatformStand})
Window:AddToggle({text = "Auto Strength", flag = "auto_strength", state = false})
Window:AddToggle({text = "Auto Prestige", flag = "auto_prestige", state = false})
Window:AddToggle({text = "Item Farm", flag = "item_farm", state = false, callback = DisablePlatformStand})
Window:AddToggle({text = "Include Nodes", flag = "node_farm", state = false})
local Remote = UI:CreateWindow("Remote")
local Purchase = Remote:AddFolder("Buy Items")
local ItemsPriced = {}
local AlreadyFound = {}
for _, v in next, workspace.Purchasable:GetChildren() do
	local Nametag = v.Nametag.NameLabel.Text
	if not table.find(AlreadyFound, v.Name) then
		table.insert(AlreadyFound, v.Name)
		table.insert(ItemsPriced, { Price = tonumber(Nametag:split(">")[2]:gsub(",", ""):match("%d+")), Text = Nametag, ClickDetector = v.ClickDetector })
	end
end
table.sort(ItemsPriced, function(A, B)
	return A.Price < B.Price
end)
for _, v in ipairs(ItemsPriced) do
	Purchase:AddButton({text = v.Text, callback = function() fireclickdetector(v.ClickDetector) end})
end
UI:Init()
-- Item Additional Data
local MoreItemData = {
	Mask = { Name = "Vampire Mask", ActualCap = 30 },
	Ceasers = { Name = "Hamon Headband", ActualCap = 30 }
}
-- Enemy Data
local QuestLevel = {
	{ Level = 1, Enemy = "Thug", Giver = "Thug Quest" },
	{ Level = 10, Enemy = "Brute", Giver = "Brute Quest" },
	{ Level = 20, Enemy = "🦍", Giver = "🦍😡💢 Quest", InternalName = "GorillaQuest" },
	{ Level = 30, Enemy = "Werewolf", Giver = "Werewolf Quest" },
	{ Level = 45, Enemy = "Zombie", Giver = "Zombie Quest" },
	{ Level = 60, Enemy = "Vampire", Giver = "Vampire Quest" },
	{ Level = 80, Enemy = "HamonGolem", Giver = "Golem Quest" },
}
-- Get Best Quest
local function GetBestQuest()
	local PlayerCore = PlayerGui:FindFirstChild("CoreGUI")

	if not PlayerCore then return end
	
	local LevelValue = PlayerCore.Frame.EXPBAR.Status.Level.Value
	local Best = nil

	for _, v in ipairs(QuestLevel) do
		if v.Level <= LevelValue then
			Best = v
		else
			break
		end
	end

	return Best
end
-- Get Active Quest
local function GetActiveQuest()
	for _, v in next, PlayerGui:GetChildren() do
		if v.Name == "Quest" then
			local FindClient = v.Quest:FindFirstChild("Client", true)

			if FindClient then
				return FindClient.Parent and FindClient.Parent.Name ~= "RepeatQuest" and FindClient.Parent.Name
			end
		end
	end
end
-- Clear TriedCollect
task.spawn(function()
	while true do
		task.wait(120)
		table.clear(TriedCollect)
	end
end)
-- Level Strength For Auto Farm
task.spawn(function()
	while true do
		if UI.flags.auto_strength then
			local CoreGUI = PlayerGui:FindFirstChild("CoreGUI")

			if CoreGUI then
				CoreGUI.Stats.Stats.Stats:InvokeServer("Strength", CoreGUI.Stats.Stats.aSkillPoints.Text:match("%d+"))
			end
		end

		if UI.flags.auto_prestige then
			local PlayerCore = PlayerGui:FindFirstChild("CoreGUI")

			if PlayerCore then
				local LevelValue = PlayerCore.Frame.EXPBAR.Status.Level.Value

				if LevelValue == 100 then
					Events.Prestige:InvokeServer()
				end
			end
		end

		task.wait(2)
	end
end)
-- Main Loop
-- Attack Loop
local PunchTimer = 1

task.spawn(function()
    while true do
		if UI.flags.item_farm then
			local Character = PlayerAlive()

			if Character then
				-- Prioritize other than Mining Nodes
				local FoundItems = {}
				local MiningNodes = {}

				for _, v in next, Items:GetChildren() do
					local FoundModel = v:FindFirstChildWhichIsA("Model") or not v.Name:match("%d") and v

					if FoundModel and not table.find(IgnoreItems, FoundModel.Name) then
						local ItemName = FoundModel.Name
						local HitItemCap = false
						local ActualCap = StorageCap
						local MoreData = nil

						for i, v in next, MoreItemData do
							if i == ItemName or v.Name == ItemName then
								MoreData = v
								break
							end
						end

						if MoreData then
							ItemName = MoreData.Name or ItemName
							ActualCap = MoreData.ActualCap
						end

						local ItemInInventory = Inventory:FindFirstChild(ItemName)

						if ItemInInventory and ItemInInventory.Value >= ActualCap then
							HitItemCap = true
						end

						if not HitItemCap and not table.find(TriedCollect, FoundModel) then
							table.insert(FoundModel.Name == "MiningNode" and MiningNodes or FoundItems, FoundModel)
						end
					end
				end

				local FoundModel = #FoundItems > 0 and FoundItems[#FoundItems]

				if FoundModel then
					local InTimeLimit = true
					local TimeSpentAtItem = tick()
					local OG_Pivot = Character:GetPivot()
					
					while InTimeLimit and FoundModel:IsDescendantOf(workspace) and UI.flags.item_farm do
						task.wait()
						InTimeLimit = (tick() - TimeSpentAtItem) < 3
						Character = PlayerAlive()
						if not Character then break end
						MoveCharacter(FoundModel:GetPivot(), Character)

						local TouchInterest = FoundModel:FindFirstChildWhichIsA("TouchTransmitter", true)
						
						if TouchInterest then
							for i = 0, 1 do
								firetouchinterest(Character.PrimaryPart, TouchInterest.Parent, i)
							end
							continue
						end
						
						local ClickDetector = FoundModel:FindFirstChildWhichIsA("ClickDetector", true)
						
						if ClickDetector then
							fireclickdetector(ClickDetector)
							continue
						end
					end

					if not InTimeLimit then
						table.insert(TriedCollect, FoundModel)
					end
				else
					if UI.flags.node_farm and #MiningNodes > 0 then
						for _, MiningNode in next, MiningNodes do
							if MiningNode:FindFirstChild("ItemSpawn") then
								Character = PlayerAlive()

								if Character then
									local Pickaxe = LocalPlayer.Backpack:FindFirstChild("Pickaxe") or Character:FindFirstChild("Pickaxe")

									if Pickaxe then
										local ProximityPrompt = MiningNode:FindFirstChildWhichIsA("ProximityPrompt", true)
										local InTimeLimit = true
										local TimeSpentAtItem = tick()
										
										while InTimeLimit and ProximityPrompt and ProximityPrompt.Enabled and UI.flags.item_farm and UI.flags.node_farm do
											InTimeLimit = (tick() - TimeSpentAtItem) < 7
											Character = PlayerAlive()
											if not Character then break end
											MoveCharacter(MiningNode:GetPivot(), Character)
											Pickaxe.Parent = Character
											fireproximityprompt(ProximityPrompt)
											task.wait()
										end
									end
								end
							end
						end
					end
				end
			end
		end

		if UI.flags.level_farm then
			local Character = PlayerAlive()
			
			if Character then
				local BestQuest = GetBestQuest()

				if BestQuest then
					local ActiveQuest = GetActiveQuest()
					local InternalName = BestQuest.InternalName or BestQuest.Giver:gsub(" ", "")

					if not ActiveQuest or ActiveQuest ~= InternalName then
						local Giver = workspace[BestQuest.Giver]
						Character:PivotTo(Giver:GetPivot())
						fireproximityprompt(Giver.ProximityPrompt)
					else
						local IsStandOut = Character.Status.StandOut.Value

						if not IsStandOut then
							PlayerGui.CoreGUI.Events.SummonStand:InvokeServer()
						else
							local BestEnemy = nil
							local LowestHealth = math.huge

							for _, v in next, workspace:GetChildren() do
								if v.Name == BestQuest.Enemy then
									local Humanoid = v:FindFirstChildWhichIsA("Humanoid")

									if Humanoid and Humanoid.Health > 0 then
										if Humanoid.Health < LowestHealth then
											LowestHealth = Humanoid.Health
											BestEnemy = v
										end
									end
								end
							end

							if BestEnemy then
								Character.Humanoid.PlatformStand = true
								Character.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
								Character:PivotTo(BestEnemy:GetPivot() * CFrame.new(0, 0, 7) * CFrame.Angles(0, 0, 0))
								-- Punch
								if (tick() - PunchTimer) > 0.3 then
									PunchTimer = tick()

									task.spawn(function()
										PlayerGui.CoreGUI.StandMoves.Punch.Fire:InvokeServer()
									end)
								end
							end
						end
					end
				end
			end
		end

        task.wait()
    end
end)
