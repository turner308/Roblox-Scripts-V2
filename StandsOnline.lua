                                                                                 local v0=loadstring(  
                                                                        game:HttpGet(                                   
                                                                                                                                  
                                                                                                                                        
                                                                                                                                          
                                                                                                                                            
                                                                                                                                              
                                                      "https://raw.githubusercontent.com/turner308/Roblox-Scripts/refs/heads/master/UwUware"))( 
                                                    );local v1=game:GetService("RunService");local v2=game:GetService("ReplicatedStorage");local  
                                                  v3=v2.Events;local v4=game:GetService("Players");local v5=v4.LocalPlayer;local v6=v5.PlayerGui;   
                                                  local v7=workspace.Items;local v8=v5.Inventory;local v9={};local v10={"DespairStone","rageStone",   
                                                "JoyStone"};local v11=v2.GameSettings.MaxStorageSlots;local v12=(game:GetService("MarketplaceService"): 
                                                UserOwnsGamePassAsync(v5.UserId,869791407) and (v11.Value * 2)) or v11.Value ;for v26,v27 in next,        
                                              getconnections(v5.Idled) do v27:Disable();end local function v13() local v28=v5.Character;if v28 then local   
                                              v47=v28:FindFirstChildWhichIsA("Humanoid");return v47 and (v47.Health>0) and v28 ;end end local function v14( 
                                            ) local v29=v13();if v29 then v29.Humanoid.PlatformStand=false;end end local function v15(v30,v31) local v32=v31  
                                            or v13() ;if v32 then v32.PrimaryPart.AssemblyAngularVelocity=Vector3.zero;v32.PrimaryPart.AssemblyLinearVelocity=  
                                          Vector3.zero;v32:PivotTo(v30);end end local v16=v0:CreateWindow("Farm");v16:AddToggle({text="Level Farm",flag=          
                                          "level_farm",state=false,callback=v14});v16:AddToggle({text="Auto Strength",flag="auto_strength",state=false});v16:       
                                          AddToggle({text="Auto Prestige",flag="auto_prestige",state=false});v16:AddToggle({text="Item Farm",flag="item_farm",state=  
                                          false,callback=v14});v16:AddToggle({text="Include Nodes",flag="node_farm",state=false});local v17=v0:CreateWindow("Remote") 
                                        ;local v18=v17:AddFolder("Buy Items");local v19={};local v20={};for v33,v34 in next,workspace.Purchasable:GetChildren() do      
                                        local v35=v34.Nametag.NameLabel.Text;if  not table.find(v20,v34.Name) --[[==============================]] then table.insert(v20, 
                                        v34.Name);table.insert(v19,{Price=tonumber(v35:split(">")[2 --[[============================================]]]:gsub(",",""):     
                                        match("%d+")),Text=v35,ClickDetector=v34.ClickDetector} --[[======================================================]]);end end table 
                                      .sort(v19,function(v36,v37) return v36.Price<v37.     --[[==========================================================]]Price ;end);for   
                                      v38,v39 in ipairs(v19) do v18:AddButton({text=v39.  --[[==============================================================]]Text,callback=  
                                      function() fireclickdetector(v39.ClickDetector);end --[[================================================================]]});end v0:Init( 
                                      );local v21={Mask={Name="Vampire Mask",ActualCap=30 --[[==================================================================]]},Ceasers={   
                                      Name="Hamon Headband",ActualCap=30}};local v22={{   --[[==================================================================]]Level=1,Enemy=    
                                    "Thug",Giver="Thug Quest"},{Level=10,Enemy="Brute",   --[[====================================================================]]Giver=        
                    "Brute Quest"},{Level=20,Enemy="🦍",Giver="🦍😡💢 Quest",InternalName --[[====================================================================]]="GorillaQuest" 
              },{Level=30,Enemy="Werewolf",Giver="Werewolf Quest"},{Level=45,Enemy=       --[[======================================================================]]"Zombie",     
            Giver="Zombie Quest"},{Level=60,Enemy="Vampire",Giver="Vampire Quest"},{Level --[[======================================================================]]=80,Enemy=    
          "HamonGolem",Giver="Golem Quest"}};local function v23() local v40=v6:           --[[======================================================================]]              
        FindFirstChild("CoreGUI");if  not v40 then return;end local v41=v40.Frame.EXPBAR. --[[======================================================================]]Status.Level. 
        Value;local v42=nil;for v43,v44 in ipairs(v22) do if (v44.Level<=v41) then v42=   --[[======================================================================]]v44;else      
      break;end end return v42;end local function v24() for v45,v46 in next,v6:           --[[======================================================================]]GetChildren() 
       do if (v46.Name=="Quest") then local v52=v46.Quest:FindFirstChild("Client",true);if  --[[==================================================================]]v52 then return 
       v52.Parent and (v52.Parent.Name~="RepeatQuest") and v52.Parent.Name ;end end end end --[[================================================================]] task.spawn(      
    function() while true do task.wait(120);table.clear(v9);end end);task.spawn(function()  --[[==============================================================]]while true do if  
    v0.flags.auto_strength then local v53=v6:FindFirstChild("CoreGUI");if v53 then v53.Stats. --[[==========================================================]]Stats.Stats:        
    InvokeServer("Strength",v53.Stats.Stats.aSkillPoints.Text:match("%d+"));end end if v0.flags --[[====================================================]].auto_prestige then     
    local v54=v6:FindFirstChild("CoreGUI");if v54 then local v57=v54.Frame.EXPBAR.Status.Level.   --[[==============================================]]Value;if (v57==100) then  
    v3.Prestige:InvokeServer();end end end task.wait(2);end end);local v25=1;task.spawn(function()    --[[====================================]]while true do if v0.flags.    
    item_farm then local v55=v13();if v55 then local v58={};local v59={};for v62,v63 in next,v7:          --[[========================]]GetChildren() do local v64=v63:       
    FindFirstChildWhichIsA("Model") or ( not v63.Name:match("%d") and v63) ;if (v64 and  not table.find(v10,v64.Name)) then local v70=v64.Name;local v71=false;local v72=   
  v12;local v73=nil;for v77,v78 in next,v21 do if ((v77==v70) or (v78.Name==v70)) then v73=v78;break;end end if v73 then v70=v73.Name or v70 ;v72=v73.ActualCap;end local 
   v74=v8:FindFirstChild(v70);if (v74 and (v74.Value>=v72)) then v71=true;end if ( not v71 and  not table.find(v9,v64)) then table.insert(((v64.Name=="MiningNode") and 
   v59) or v58 ,v64);end end end local v60=( #v58>0) and v58[ #v58] ;if v60 then local v65=true;local v66=tick();local v67=v55:GetPivot();while v65 and v60:              
  IsDescendantOf(workspace) and v0.flags.item_farm  do task.wait();v65=(tick() -v66)<3 ;v55=v13();if  not v55 then break;end v15(v60:GetPivot(),v55);local v75=v60:       
  FindFirstChildWhichIsA("TouchTransmitter",true);if v75 then for v84=0,1 do firetouchinterest(v55.PrimaryPart,v75.Parent,v84);end continue;end local v76=v60:            
  FindFirstChildWhichIsA("ClickDetector",true);if v76 then fireclickdetector(v76);continue;end end if  not v65 then table.insert(v9,v60);end elseif (v0.flags.node_farm   
  and ( #v59>0)) then for v82,v83 in next,v59 do if v83:FindFirstChild("ItemSpawn") then v55=v13();if v55 then local v92=v5.Backpack:FindFirstChild("Pickaxe") or v55:    
  FindFirstChild("Pickaxe") ;if v92 then local v94=v83:FindFirstChildWhichIsA("ProximityPrompt",true);local v95=true;local v96=tick();while v95 and v94 and v94.Enabled   
  and v0.flags.item_farm and v0.flags.node_farm  do v95=(tick() -v96)<7 ;v55=v13();if  not v55 then break;end v15(v83:GetPivot(),v55);v92.Parent=v55;fireproximityprompt( 
  v94);task.wait();end end end end end end end end if v0.flags.level_farm then local v56=v13();if v56 then local v61=v23();if v61 then local v68=v24();local v69=v61.     
  InternalName or v61.Giver:gsub(" ","") ;if ( not v68 or (v68~=v69)) then local v79=workspace[v61.Giver];v56:PivotTo(v79:GetPivot());fireproximityprompt(v79.            
  ProximityPrompt);else local v80=v56.Status.StandOut.Value;if  not v80 then v6.CoreGUI.Events.SummonStand:InvokeServer();else local v85=nil;local v86=math.huge;for v87,   
  v88 in next,workspace:GetChildren() do if (v88.Name==v61.Enemy) then local v93=v88:FindFirstChildWhichIsA("Humanoid");if (v93 and (v93.Health>0)) then if (v93.Health<v86 
  ) then v86=v93.Health;v85=v88;end end end end if v85 then v56.Humanoid.PlatformStand=true;v56.PrimaryPart.AssemblyLinearVelocity=Vector3.zero;v56:PivotTo(v85:GetPivot()  
  * CFrame.new(0,0,7) * CFrame.Angles(0,0,0) );if ((tick() -v25)>0.3) then v25=tick();task.spawn(function() v6.CoreGUI.StandMoves.Punch.Fire:InvokeServer();end);end end    
  end end end end end task.wait();end end);
