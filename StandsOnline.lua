                                                                                 local v0=loadstring(  
                                                                        game:HttpGet(                                   
                                                                                                                                  
                                                                                                                                        
                                                                                                                                          
                                                                                                                                            
                                                                                                                                              
                                                      "https://raw.githubusercontent.com/turner308/Roblox-Scripts/refs/heads/master/UwUware"))( 
                                                    );local v1=game:GetService("RunService");local v2=game:GetService("ReplicatedStorage");local  
                                                  v3=v2.Events;local v4=game:GetService("Players");local v5=v4.LocalPlayer;local v6=v5.PlayerGui;   
                                                  local v7=workspace.Items;local v8=v5.Inventory;local v9=0;local v10={};local v11={"DespairStone",   
                                                "rageStone","JoyStone"};local v12=v2.GameSettings.MaxStorageSlots;local v13=(game:GetService(           
                                                "MarketplaceService"):UserOwnsGamePassAsync(v5.UserId,869791407) and (v12.Value * 2)) or v12.Value ;for   
                                              v25,v26 in next,getconnections(v5.Idled) do v26:Disable();end local function v14() local v27=v5.Character;if  
                                              v27 then local v42=v27:FindFirstChildWhichIsA("Humanoid");return v42 and (v42.Health>0) and v27 ;end end      
                                            local v15=v0:CreateWindow("Farm");v15:AddToggle({text="Level Farm",flag="level_farm",state=false});v15:AddToggle( 
                                            {text="Auto Strength",flag="auto_strength",state=false});v15:AddToggle({text="Auto Prestige",flag="auto_prestige",  
                                          state=false});v15:AddToggle({text="Item Farm",flag="item_farm",state=false});v15:AddToggle({text="Include Nodes",flag=  
                                          "node_farm",state=false});local v16=v0:CreateWindow("Remote");local v17=v16:AddFolder("Buy Items");local v18={};local v19 
                                          ={};for v28,v29 in next,workspace.Purchasable:GetChildren() do local v30=v29.Nametag.NameLabel.Text;if  not table.find(v19, 
                                          v29.Name) then table.insert(v19,v29.Name);table.insert(v18,{Price=tonumber(v30:split(">")[2]:gsub(",",""):match("%d+")),    
                                        Text=v30,ClickDetector=v29.ClickDetector});end end table.sort(v18,function(v31,v32) return v31.Price<v32.Price ;end);for v33,   
                                        v34 in ipairs(v18) do v17:AddButton({text=v34.Text,callback=function( --[[==============================]]) fireclickdetector(v34 
                                        .ClickDetector);end});end v0:Init();local v20={{Level=1,    --[[============================================]]Enemy="Thug",Giver= 
                                        "Thug Quest"},{Level=10,Enemy="Brute",Giver=            --[[======================================================]]"Brute Quest"}, 
                                      {Level=20,Enemy="🦍",Giver="🦍😡💢 Quest",            --[[==========================================================]]InternalName=     
                                      "GorillaQuest"},{Level=30,Enemy="Werewolf",Giver=   --[[==============================================================]]                
                                      "Werewolf Quest"},{Level=45,Enemy="Zombie",Giver=   --[[================================================================]]"Zombie Quest"} 
                                      ,{Level=60,Enemy="Vampire",Giver="Vampire Quest"},{ --[[==================================================================]]Level=80,     
                                      Enemy="HamonGolem",Giver="Golem Quest"}};local      --[[==================================================================]]function v21()    
                                    local v35=v6:FindFirstChild("CoreGUI");if  not v35    --[[====================================================================]]then return;  
                    end local v36=v35.Frame.EXPBAR.Status.Level.Value;local v37=nil;for   --[[====================================================================]]v38,v39 in      
              ipairs(v20) do if (v39.Level<=v36) then v37=v39;else break;end end return   --[[======================================================================]]v37;end local 
             function v22() for v40,v41 in next,v6:GetChildren() do if (v41.Name=="Quest" --[[======================================================================]]) then local  
          v43=v41.Quest:FindFirstChild("Client",true);if v43 then return v43.Parent and ( --[[======================================================================]]v43.Parent.   
        Name~="RepeatQuest") and v43.Parent.Name ;end end end end task.spawn(function()   --[[======================================================================]]while true do 
         if v0.flags.auto_strength then local v44=v6:FindFirstChild("CoreGUI");if v44     --[[======================================================================]]then v44.     
      Stats.Stats.Stats:InvokeServer("Strength",v44.Stats.Stats.aSkillPoints.Text:match(  --[[======================================================================]]"%d+"));end   
      end if v0.flags.auto_prestige then local v45=v6:FindFirstChild("CoreGUI");if v45 then --[[==================================================================]] local v53=v45. 
      Frame.EXPBAR.Status.Level.Value;if (v53==100) then v3.Prestige:InvokeServer();end end --[[================================================================]] end task.wait(2) 
    ;end end);local v23=1;local v24={Mask={Name="Vampire Mask",ActualCap=30},Ceasers={Name= --[[==============================================================]]"Hamon Headband", 
    ActualCap=30}};task.spawn(function() while true do if v0.flags.item_farm then local v46={ --[[==========================================================]]};local v47={};for  
    v50,v51 in next,v7:GetChildren() do local v52=v51:FindFirstChildWhichIsA("Model") or ( not  --[[====================================================]]v51.Name:match("%d")    
    and v51) ;if (v52 and  not table.find(v11,v52.Name)) then local v56=v52.Name;local v57=false; --[[==============================================]]local v58=v13;local v59=  
    nil;for v65,v66 in next,v24 do if ((v65==v56) or (v66.Name==v56)) then v59=v66;break;end end if   --[[====================================]]v59 then v56=v59.Name or v56  
    ;v58=v59.ActualCap;end local v60=v8:FindFirstChild(v56);if (v60 and (v60.Value>=v58)) then v57=true;  --[[========================]]end if ( not v57 and  not table.find( 
    v10,v52)) then if (v52.Name=="MiningNode") then table.insert(v47,v52);else table.insert(v46,v52);end end end end local v48=( #v46>0) and v46[ #v46] ;if v48 then v9=    
  tick();local v54=v5.Character:GetPivot();while ((tick() -v9)<3) and v48:IsDescendantOf(workspace) and v0.flags.item_farm  do task.wait();v5.Character.Humanoid:         
  SetStateEnabled(Enum.HumanoidStateType.FallingDown,false);v5.Character.PrimaryPart.AssemblyLinearVelocity=Vector3.zero;v5.Character:PivotTo(v48:GetPivot());local v63 
  =v48:FindFirstChildWhichIsA("TouchTransmitter",true);if v63 then for v72=0,1 do firetouchinterest(v5.Character.PrimaryPart,v63.Parent,v72);end continue;end local v64=  
  v48:FindFirstChildWhichIsA("ClickDetector",true);if v64 then fireclickdetector(v64);continue;end end if  not InTimeLimit then table.insert(v10,v48);end elseif (v0.     
  flags.node_farm and ( #v47>0)) then for v70,v71 in next,v47 do if v71:FindFirstChild("ItemSpawn") then local v75=v5.Backpack:FindFirstChild("Pickaxe") or v5.Character: 
  FindFirstChild("Pickaxe") ;if v75 then local v78=v71:FindFirstChildWhichIsA("ProximityPrompt",true);while v78 and v78.Enabled and v0.flags.item_farm and v0.flags.      
  node_farm  do v5.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false);v5.Character.PrimaryPart.AssemblyLinearVelocity=Vector3.zero;v5.Character 
  :PivotTo(v71:GetPivot());v75.Parent=v5.Character;fireproximityprompt(v78);task.wait();end end end end end end if v0.flags.level_farm then local v49=v14();if v49 then   
  local v55=v21();if v55 then local v67=v22();local v68=v55.InternalName or v55.Giver:gsub(" ","") ;if ( not v67 or (v67~=v68)) then local v73=workspace[v55.Giver];v49:  
  PivotTo(v73:GetPivot());fireproximityprompt(v73.ProximityPrompt);else local v74=v49.Status.StandOut.Value;if  not v74 then v6.CoreGUI.Events.SummonStand:InvokeServer() 
  ;else local v76=nil;local v77=math.huge;for v79,v80 in next,workspace:GetChildren() do if (v80.Name==v55.Enemy) then local v87=v80:FindFirstChildWhichIsA("Humanoid");  
  if (v87 and (v87.Health>0)) then if (v87.Health<v77) then v77=v87.Health;v76=v80;end end end end if v76 then v5.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType 
  .FallingDown,false);v5.Character.PrimaryPart.AssemblyLinearVelocity=Vector3.zero;v49:PivotTo(v76:GetPivot() * CFrame.new(0,0,7) * CFrame.Angles(0,0,0) );task.spawn(      
  function() if ((tick() -v23)>0.3) then v23=tick();v6.CoreGUI.StandMoves.Punch.Fire:InvokeServer();end end);end end end end end end task.wait();end end);
