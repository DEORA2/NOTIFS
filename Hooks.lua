--Games
local Loaded, LoadError = true
library.flagprefix = GameTitle

Loaded, LoadError = pcall(function()

	if GameTitle == "Counter Blox" then
        local CBTab = library:AddTab"Counter Blox"
        local MainColumn = CBTab:AddColumn()
        local MainColumn1 = CBTab:AddColumn()
        local e1 = MainColumn:AddSection"Rage"
        local e2 = tick()
        local CBClient = {}
        for i,v in next, getgc() do
        	if typeof(v) == "function" then
        		local info = debug.getinfo(v)
        		if info.name == "resetaccuracy" then
        			CBClient.resetaccuracy = v
        		elseif info.name == "firebullet" then
        			CBClient.firebullet = v
        		end
        	end
        end
        
        local eE = MainColumn1:AddSection"Misc Cheats"
        local eV = MainColumn1:AddSection"Visuals"
        local eM = MainColumn:AddSection"Anti Aim"
        local eA = MainColumn:AddSection"Gun Mods"
        local eF = MainColumn:AddSection"Exploits"
        
        library.options["Aimbot Mode"]:AddValue"Silent"
        eE:AddToggle({text = "Wallbang"})
        
        eM:AddToggle({text = "Bhop", callback = function(cc)
        	if cc then
        		while library and library.flags[GameTitle .. " Bhop"] and wait() do
        			if Client.Character and FFCoC(Client.Character, "Humanoid") then
        				if inputService:IsKeyDown(Enum.KeyCode.Space) then
        					Client.Character.Humanoid.Jump = true
        				end
        			end
        		end
        	end
        end}):AddSlider({text = "Speed", flag = "Bhop Speed", min = 20, max = 150})
        
        eF:AddButton({text = "Inf Cash", callback = function()
            game.Players.LocalPlayer.Cash.Value = 6000
            game.Players.LocalPlayer.Cash.Changed:Connect(function()
                game.Players.LocalPlayer.Cash.Value = 6000
            end)
        end})
        
        eM:AddToggle({text = "Anti-Aim", flag = "Anti-aim", callback = function(State)
        	if State == true  then
        		library:AddConnection(runService.RenderStepped, "Anti-aim", function(Step)
        		    game.Players.LocalPlayer.Character.Humanoid.AutoRotate = false
                    game.ReplicatedStorage.Events.ControlTurn:FireServer(library.flags[GameTitle .. " pitchamount"], false)
        		end)
        	else
        	    game.Players.LocalPlayer.Character.Humanoid.AutoRotate = true
        	    game.ReplicatedStorage.Events.ControlTurn.RobloxLocked = true
        	    library.connections["Anti-aim"]:Disconnect()
        	end
        end}):AddSlider({text = "AA Pitch", flag = "pitchamount", min = 0, max = 10, float = 0.5})
        
        eM:AddToggle({text = "AA Spin", flag = "AA-Spin", callback = function(State)
            if State == true then
        		library:AddConnection(runService.RenderStepped, "AA-Spin", function(Step)
                    --game.ReplicatedStorage.Events.ControlTurn.RobloxLocked = false
                    game.Players.LocalPlayer.Character.Humanoid.AutoRotate = false
        	        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(library.flags[GameTitle .. " antiaimspeed"]), 0)
        		end)
        	else
        	    game.Players.LocalPlayer.Character.Humanoid.AutoRotate = true
        	    game.ReplicatedStorage.Events.ControlTurn.RobloxLocked = true
        	    library.connections["AA-Spin"]:Disconnect()
            end
        end}):AddSlider({text = "Spin Speed", flag = "antiaimspeed", min = 0, max = 40, float = 2})
        
        eM:AddToggle({text = "AA Crazy", flag = "AA-Crazy", callback = function(State)
            if State == true  then
        		library:AddConnection(runService.RenderStepped, "AA-Crazy", function(Step)
                    game.Players.LocalPlayer.Character.Humanoid.AutoRotate = false
                    game.ReplicatedStorage.Events.ControlTurn.RobloxLocked = false
        	        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.random(1,50), 0)
        	        game.ReplicatedStorage.Events.ControlTurn:FireServer(math.random(1,20), false)
        		end)
        	else
        	    game.Players.LocalPlayer.Character.Humanoid.AutoRotate = true
        	    game.ReplicatedStorage.Events.ControlTurn.RobloxLocked = true
        	    library.connections["AA-Crazy"]:Disconnect()
            end
        end})
        
        function replace(part, weldName)	
			local weld = part:FindFirstChild(weldName)
			if weld then
				local clone = weld:Clone()
				clone.Part1 = nil
				part[weldName]:Destroy()
				clone.Parent = part
			end
		end
        
        eM:AddToggle({text = "AA Best (DEAGLE ONLY)", flag = "AA-Best", callback = function(State)
            if State == true  then
                replace(game.Players.LocalPlayer.Character.UpperTorso, "Waist")
    			replace(game.Players.LocalPlayer.Character.LowerTorso, "Root")
        		library:AddConnection(runService.RenderStepped, "AA-Best", function(Step)
        			for _, v in pairs(Player.Character:GetChildren()) do
        				if v:IsA("BasePart") then
        					if v.Name ~= "HumanoidRootPart" and not v.Name:find("Left") and not v.Name:find("Right") and not v.Name == "Head" then
        						v.CanCollide = false
        						v.Velocity = Vector3.new(0, 0, 0)
        						v.Anchored = not v.Anchored
        					else
        						v.CanCollide = false
        					end
        				end
        			end
        			game.Players.LocalPlayer.Character.UpperTorso.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
        			game.Players.LocalPlayer.Character.LowerTorso.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
        		end)
        	else
        	    game.Players.LocalPlayer.Character.Humanoid.AutoRotate = true
        	    game.ReplicatedStorage.Events.ControlTurn.RobloxLocked = true
        	    library.connections["AA-Best"]:Disconnect()
            end
        end})
        
        eF:AddToggle({text = "Anti-Kick", flag = "antikick", callback = function(K)
            if K == true then
                game.ReplicatedStorage.Events.SendMsg.OnClientEvent:Connect(function(message)
                    local msg = string.split(message, " ")
                    if game.Players:FindFirstChild(msg[1]) and msg[7] == "2" and msg[12] == game.Players.LocalPlayer.Name then
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                    end
                end)
            end
        end})
        
        eA:AddToggle({text = "No Recoil", flag = "norecoil", callback = function(K)
            if K == true then
                library:AddConnection(runService.RenderStepped, "norecoil", function(Step)
                    CBClient.resetaccuracy()
                    CBClient.RecoilX = 0
                    CBClient.RecoilY = 0
                end)
            elseif K == false then
                library.connections["norecoil"]:Disconnect()
            end
        end})
        
        local function ez(aS, eA, G)
        	if aS then
        		for V, v in next, RepStorage.Weapons:GetDescendants() do
        			if v.Name == eA then
        				ey[v] = {value = v.Value}
        				v.Value = G
        				for eC, eD in next, v:GetChildren() do
        					ey[eD] = {value = eD.Value}
        					eD.Value = G
        				end
        			end
        		end
        	else
        		for V, v in next, RepStorage.Weapons:GetDescendants() do
        			if v.Name == eA and ey[v] then
        				v.Value = ey[v].value
        				for eC, eD in next, v:GetChildren() do
        					eD.Value = ey[eD].value
        				end
        			end
        		end
        	end
        end
        
        eA:AddToggle({text = "Inf Ammo", flag = "infammo"})
        eA:AddToggle({text = "Inf Penetration", flag = "infpen"})
        eA:AddToggle({text = "Instant Reload", flag = "instreload"})
        eA:AddToggle({text = "Rapid Fire", flag = "rapidfire"})
        eA:AddToggle({text = "Fast Equip", flag = "instequip"})
        eA:AddToggle({text = "Full Auto", flag = "fullauto"})
        eF:AddToggle({text = "Shop Forever", flag = "buytime"})
        eF:AddToggle({text = "Kill Say", flag = "killsay"})
        
        local chatmessages = {
        "Daddyware Forever <3",
        "DaddyWare disco = uMxJ8QGpar",
        "Daddyware = [Best Private CB Cheat]",
        "DaddyWare :o",
        "Tired of dying? Too bad",
        "AYO!! can yours do that??",
        "Daddyware back at it again",
        "DW TAPPED YOU",
        "Daddyware be poppin",
        "Counter Blox needs an anti cheat",
        "Im not cheating im just really comfortable",
        "Kill me already kid",
        "kode is kinda cool",
        "Invicta Was Here ;)"
        }
        
        local chatplr = game:GetService"Players".LocalPlayer
        
        local function IsAlive(plr)
        	if plr and plr.Character and plr.Character.FindFirstChild(plr.Character, "Humanoid") and plr.Character.Humanoid.Health > 0 then
        		return true
        	end
        
        	return false
        end
        
        game.Players.LocalPlayer.Status.Kills.Changed:Connect(function(val)
        	if library.flags[GameTitle .. " killsay"] == true and IsAlive(chatplr)then
                game:GetService("ReplicatedStorage").Events.PlayerChatted:FireServer(
        			chatmessages[math.random(1,table.getn(chatmessages))],
        			false,
        			"Innocent",
        			false,
        			false
        		)
        	end
        end)
        
        eF:AddToggle({text = "Inf Crouch", flag = "infcrouch", callback = function(K)
            if K == true then
        		library:AddConnection(runService.RenderStepped, "infcrouch", function(Step)
        			if cbClient.crouchcooldown ~= 0 then
        				cbClient.crouchcooldown = 0
        			end
        		end)
        	end
        end})
        
        eV:AddToggle({text = "Backtrack", flag = "backtrackesp"}):AddColor({flag = "backtrackcolor"})
        eV:AddSlider({text = "Transparency", flag = "bttrans", min = 0, max = 1, float = 0.1})
        
        local backtrackfolder = Instance.new('Folder',workspace)
        backtrackfolder.Name = 'backtrackfolder'
        
        local function backtrack(character)
        	pcall(function()
        		if not character:FindFirstChild("backtrack") then
        			Instance.new("Sky",character).Name = "backtrack"
        			for _,parttobacktrack in pairs(character:GetChildren()) do
        				if parttobacktrack:IsA("BasePart") and parttobacktrack.Name ~= 'Gun' then
        					spawn(function()
        						for i = 1,2 do
        							local backtrackPART = Instance.new("Part",backtrackfolder)
        							backtrackPART.Size = parttobacktrack.Size * 0.9
        							backtrackPART.Color = library.flags[GameTitle .. " backtrackcolor"]
        							backtrackPART.CanCollide = false
        							backtrackPART.Anchored = true
        							backtrackPART.Position = Vector3.new(0, 0, 2)
        							backtrackPART.Material = Enum.Material.ForceField
        							backtrackPART.Transparency = library.flags[GameTitle .. " bttrans"]
        							backtrackPART.Name = "backtrackPART"
        							local thing = Instance.new("ObjectValue")
        							thing.Parent = backtrackPART
        							thing.Name = "thing"
        							thing.Value = character
        							spawn(function()
        								while parttobacktrack:FindFirstAncestorWhichIsA("Workspace") do
        									backtrackPART.CFrame = parttobacktrack.CFrame
        									wait(1.5)
        								end
        								backtrackPART:Destroy()
        							end)
        						end	
        					end)
        				end
        			end
        		end
        	end)
        end
        
        spawn(function()
        	while wait(0.2) do
        		for _,player in pairs(game.Players:GetPlayers()) do
        			if player.Character then
        				if player ~= game.Players.LocalPlayer then
        					if player.Team ~= game.Players.LocalPlayer.Team then
        						if library.flags[GameTitle .. " backtrackesp"] == true then
        							backtrack(player.Character)
        						elseif player.Character:FindFirstChild("backtrack") then
        							player.Character:FindFirstChild("backtrack"):Destroy()
        							backtrackfolder:ClearAllChildren()
        						end
        					end
        				end
        			end
        		end
        	end
        end)
        
        eV:AddToggle({text = "Dropped ESP", flag = "Droppedesp"})
        
        
        eV:AddToggle({text = "No Scope",flag = "noscope",callback = function(ree)
            if ree == true then
                local a = game:GetService("Players")
                local c = a.LocalPlayer
                pcall(function()
                    c.PlayerGui.GUI.Crosshairs.Scope.ImageTransparency = 1
                    c.PlayerGui.GUI.Crosshairs.Scope.Scope.ImageTransparency = 1
                    c.PlayerGui.GUI.Crosshairs.Scope.Scope.Blur.ImageTransparency = 1
                    c.PlayerGui.GUI.Crosshairs.Scope.Scope.Blur.Blur.ImageTransparency = 1
                    c.PlayerGui.GUI.Crosshairs.Frame1.Transparency = 1
                    c.PlayerGui.GUI.Crosshairs.Frame2.Transparency = 1
                    c.PlayerGui.GUI.Crosshairs.Frame3.Transparency = 1
                    c.PlayerGui.GUI.Crosshairs.Frame4.Transparency = 1
                end)
            else
                pcall(function()
                    c.PlayerGui.GUI.Crosshairs.Scope.ImageTransparency = 0
                    c.PlayerGui.GUI.Crosshairs.Scope.Scope.ImageTransparency = 0
                    c.PlayerGui.GUI.Crosshairs.Scope.Scope.Blur.ImageTransparency = 1
                    c.PlayerGui.GUI.Crosshairs.Scope.Scope.Blur.Blur.ImageTransparency = 1
                    c.PlayerGui.GUI.Crosshairs.Frame1.Transparency = 0
                    c.PlayerGui.GUI.Crosshairs.Frame2.Transparency = 0
                    c.PlayerGui.GUI.Crosshairs.Frame3.Transparency = 0
                    c.PlayerGui.GUI.Crosshairs.Frame4.Transparency = 0
                end)
            end
        end})
        
        eV:AddToggle({text = "Anti Spectate", flag = "anti spectate"})
        
        local Camera = workspace.CurrentCamera
        local ClientScript2 = game.Players.LocalPlayer.PlayerGui.Client      
        local Client2 = getsenv(ClientScript2) 
        
        Camera.ChildAdded:Connect(function(obj)      
        	if library.flags[GameTitle .. " infammo"] then      
        		Client2.ammocount = 99999     
        		Client2.primarystored = 99999    
        		Client2.ammocount2 = 99999      
        		Client2.secondarystored = 99999      
        	end      
        	RunService.RenderStepped:Wait()
        end) 
        
        local function addEsp(object, parent, size, identifier)
        	local billboard = Instance.new("BillboardGui", parent)
        	billboard.Size = size
        	if identifier == "object" then
        		billboard.Adornee = object
        	end
        	billboard.AlwaysOnTop = true
        	billboard.Name = object.Name
        	
        	local lines = Instance.new("Frame", billboard)
        	lines.Name = "lines"
        	lines.Size = UDim2.new(1,-2,1,-2)
        	lines.Position = UDim2.new(0,1,0,1)
        	lines.BackgroundTransparency = 1
        	
        	local outlines = Instance.new("Folder", lines)
        	outlines.Name = "outlines"
        	local inlines = Instance.new("Folder", lines)
        	inlines.Name = "inlines"
        	
        	local outline1 = Instance.new("Frame", outlines)
        	outline1.Name = "left"
        	outline1.BorderSizePixel = 0
        	outline1.BackgroundColor3 = Color3.new(0,0,0)
        	outline1.Size = UDim2.new(0,-1,1,0)
        	
        	local outline2 = Instance.new("Frame", outlines)
        	outline2.Name = "right"
        	outline2.BorderSizePixel = 0
        	outline2.BackgroundColor3 = Color3.new(0,0,0)
        	outline2.Position = UDim2.new(1,0,0,0)
        	outline2.Size = UDim2.new(0,1,1,0)
        	
        	local outline3 = Instance.new("Frame", outlines)
        	outline3.Name = "up"
        	outline3.BorderSizePixel = 0
        	outline3.BackgroundColor3 = Color3.new(0,0,0)
        	outline3.Size = UDim2.new(1,0,0,-1)
        	
        	local outline4 = Instance.new("Frame", outlines)
        	outline4.Name = "down"
        	outline4.BorderSizePixel = 0
        	outline4.BackgroundColor3 = Color3.new(0,0,0)
        	outline4.Position = UDim2.new(0,0,1,0)
        	outline4.Size = UDim2.new(1,0,0,1)
        	
        	local inline1 = Instance.new("Frame", inlines)
        	inline1.Name = "left"
        	inline1.BorderSizePixel = 0
        	inline1.Size = UDim2.new(0,1,1,0)
        	
        	local inline2 = Instance.new("Frame", inlines)
        	inline2.Name = "right"
        	inline2.BorderSizePixel = 0
        	inline2.Position = UDim2.new(1,0,0,0)
        	inline2.Size = UDim2.new(0,-1,1,0)
        	
        	local inline3 = Instance.new("Frame", inlines)
        	inline3.Name = "up"
        	inline3.BorderSizePixel = 0
        	inline3.Size = UDim2.new(1,0,0,1)
        	
        	local inline4 = Instance.new("Frame", inlines)
        	inline4.Name = "down"
        	inline4.BorderSizePixel = 0
        	inline4.Position = UDim2.new(0,0,1,0)
        	inline4.Size = UDim2.new(1,0,0,-1)
        	
        	if identifier == "object" then
        		local label = Instance.new("TextLabel", billboard)
        		label.Name = "label"
        		label.Size = UDim2.new(1,0,1,0)
        		label.BackgroundTransparency = 1
        		label.TextStrokeTransparency = 0
        		label.TextColor3 = Color3.fromRGB(255, 255, 255)
        		label.Text = object.Name
        		label.Font = Enum.Font.Code
        		label.TextSize = 16
        		object.AncestryChanged:connect(function()
        			if object.Name ~= "C4" then
        				if object.Parent ~= workspace.Debris then
        					billboard:Destroy()
        				end
        			end
        		end)
        	end
        end
        
        local function objectInWorkspace(child)
        	if library.flags[GameTitle .. " Droppedesp"] then
        		local primaries = {semis, heavies, rifles}
        		for _,v in pairs(primaries) do
        			for _,w in pairs(v) do
        				if child.Name == w then
        				    child.Material = "ForceField"
        					child.Color = Color3.fromRGB(0, 255, 255)
        					child.Transparency = 0.2
        					local size = UDim2.new(2,4,2,4)
        					addEsp(child, bombfolder, size, "object")
        				end
        			end
        		end
        		for _,v in pairs(pistols) do
        			if child.Name == v then
        			    child.Material = "ForceField"
        				child.Color = Color3.fromRGB(0, 255, 255)
        				child.Transparency = 0.2
        				local size = UDim2.new(2,4,2,4)
        				addEsp(child, bombfolder, size, "object")
        			end
        		end
        	end
        	if child.Name == "C4" then
        		if library.flags[GameTitle .. " Droppedesp"] then
        			if bombfolder:FindFirstChild"C4" then
        				bombfolder.C4.Adornee = child
        			else
        				local size = UDim2.new(2,4,2,4)
        				addEsp(child, bombfolder, size, "object")
        				child.Material = "ForceField"
        				child.Color = Color3.fromRGB(0, 255, 255)
        				child.Transparency = 0.2
        				for _,v in pairs(bombfolder.C4.lines.inlines:GetChildren()) do
        					v.BackgroundColor3 = Color3.new(0,255,255)
        				end
        			end
        			if child.Parent == workspace then
        				for i=38,0,-1 do
        					wait(1)
        					bombfolder.C4.label.Text = "C4 - "..i
        				end
        				bombfolder.C4.label.Text = "C4"
        			end
        		end
        	end
        end
        
        game.workspace.Debris.DescendantAdded:connect(function(child)
        	objectInWorkspace(child, false)
        end)
        
        game.workspace.DescendantAdded:connect(function(child)
        	objectInWorkspace(child, true)
        end)
        
        eV:AddToggle({text = "Spectator List", flag = "speclist", callback = function(K)
            if K ==  true then
                local SpectatorsList = Instance.new("ScreenGui")
                local Spectators = Instance.new("Frame")
                local Container = Instance.new("Frame")
                local UIPadding = Instance.new("UIPadding")
                local Text = Instance.new("TextLabel")
                local Players = Instance.new("TextLabel")
                local Background = Instance.new("Frame")
                local UIGradient = Instance.new("UIGradient")
                local Color = Instance.new("Frame")
                local UIGradient_2 = Instance.new("UIGradient")
        
                SpectatorsList.Parent = game.CoreGui
                SpectatorsList.Name = "SpectatorsList"
                SpectatorsList.Enabled = true
        
                Spectators.Name = "Spectators"
                Spectators.Parent = SpectatorsList
                Spectators.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
                Spectators.BackgroundTransparency = 1.000
                Spectators.BorderColor3 = Color3.fromRGB(20, 20, 20)
                Spectators.Position = UDim2.new(0.00800000038, 0, 0.400000006, 49)
                Spectators.Size = UDim2.new(0, 200, 0, 20)
        
                Container.Name = "Container"
                Container.Parent = Spectators
                Container.BackgroundTransparency = 1.000
                Container.BorderSizePixel = 0
                Container.Position = UDim2.new(0, 0, 0, 4)
                Container.Size = UDim2.new(1, 0, 0, 14)
                Container.ZIndex = 3
        
                UIPadding.Parent = Container
                UIPadding.PaddingLeft = UDim.new(0, 4)
        
                Text.Name = "Text"
                Text.Parent = Container
                Text.BackgroundTransparency = 1.000
                Text.Size = UDim2.new(1, 0, 1, 0)
                Text.ZIndex = 4
                Text.Font = Enum.Font.Code
                Text.Text = "Spectators"
                Text.TextColor3 = Color3.fromRGB(65025, 65025, 65025)
                Text.TextSize = 14.000
                Text.TextStrokeTransparency = 0.000
        
                Players.Name = "Players"
                Players.Parent = Container
                Players.BackgroundTransparency = 1.000
                Players.Position = UDim2.new(0.0196080022, 0, 1.14285719, 0)
                Players.Size = UDim2.new(0.980391979, 0, 1.14285719, 0)
                Players.ZIndex = 4
                Players.Font = Enum.Font.Code
                Players.Text = "loading..."
                Players.TextColor3 = Color3.fromRGB(65025, 65025, 65025)
                Players.TextSize = 14.000
                Players.TextStrokeTransparency = 0.000
                Players.TextYAlignment = Enum.TextYAlignment.Top
        
                Background.Name = "Background"
                Background.Parent = Spectators
                Background.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
                Background.BorderColor3 = Color3.fromRGB(20, 20, 20)
                Background.Size = UDim2.new(1, 0, 1, 0)
        
                UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(90, 90, 90))}
                UIGradient.Rotation = 90
                UIGradient.Parent = Background
        
                Color.Name = "Color"
                Color.Parent = Spectators
                Color.BackgroundColor3 = Color3.fromRGB(83, 49, 127)
                Color.BorderSizePixel = 0
                Color.Size = UDim2.new(1, 0, 0, 2)
                Color.ZIndex = 2
        
                UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(60, 60, 60))}
                UIGradient_2.Rotation = 90
                UIGradient_2.Parent = Color
        
                function GetSpectators()
                    local CurrentSpectators = ""
                    for i,v in pairs(game.Players:GetChildren()) do 
                        pcall(function()
                            if v ~= game.Players.LocalPlayer then
                                if not v.Character then 
                                    if (v.CameraCF.Value.p - game.Workspace.CurrentCamera.CFrame.p).Magnitude < 10 then 
                                        if CurrentSpectators == "" then
                                                CurrentSpectators = v.Name
                                            else
                                                CurrentSpectators = CurrentSpectators.. "\n" ..v.Name
                                            end
                                        end
                                    end
                                end
                            end)
                        end
                    return CurrentSpectators
                end
        
                spawn(function()
                    while wait(0.1) do
                        if SpectatorsList.Enabled then
                            Players.Text = GetSpectators()
                        end
                    end
                end)
            
                local function SCUAM_fake_script() -- Spectators.LocalScript 
                    local script = Instance.new('LocalScript', Spectators)
                    local gui = script.Parent
                    gui.Draggable = true
                    gui.Active = true
                end
                coroutine.wrap(SCUAM_fake_script)()
            
            elseif K ==  false then
                game.CoreGui.SpectatorsList:Destroy()
            end
        end})            
        
        local eJ
        eV:AddToggle({text = "Thirdperson", callback = function(State)
        	if eJ then
        		eJ = false
        		if Client.Character then
        			Client.CameraMinZoomDistance = 0
        			Client.CameraMaxZoomDistance = 0
        		end
        	else
        		library.options[GameTitle .. " TP Bind"].callback()
        	end
        end}):AddSlider({text = "Distance", flag = "TP Distance", min = 10, max = 30}):AddBind({flag = "TP Bind", callback = function()
        	if library.flags[GameTitle .. " Thirdperson"] then
        		eJ = not eJ
        		if eJ then
        			while library and library.flags[GameTitle .. " Thirdperson"] and eJ and wait() do
        				if Client.Character then
        					Client.CameraMinZoomDistance = library.flags[GameTitle .. " TP Distance"]
        					Client.CameraMaxZoomDistance = library.flags[GameTitle .. " TP Distance"]
        				end
        			end
        			if Client.Character then
        				Client.CameraMinZoomDistance = 0
        				Client.CameraMaxZoomDistance = 0
        			end
        		end
        	end
        end})
        eV:AddToggle({text = "Transparent Arms"}):AddColor({flag = "Arms Color"})
        eV:AddToggle({text = "Transparent Weapon"}):AddColor({flag = "Weapon Color"})
        library:AddConnection(Camera.ChildAdded, function(di)
        	if di.Name == "Arms" then
        		wait()
        		if not FFC(di, "HumanoidRootPart") then return end
        		di.HumanoidRootPart.Transparency = 1
        		if library.flags[GameTitle .. " Transparent Arms"] then
        			for u, di in next, di:GetChildren() do
        				if string.find(di.Name, "Arms") then
        					for u, eK in next, di:GetChildren() do
        						eK.Material = "ForceField"
        						eK.Color = library.flags[GameTitle .. " Arms Color"]
        						eK.Transparency = 0.6
        						local eL =
        							FFC(eK, "Glove") or FFC(eK, "LGlove") or
        							FFC(eK, "RGlove")
        						if eL then
        							eL.Material = "ForceField"
        							eL.Mesh.VertexColor = Vector3.new(eK.Color.r, eK.Color.g, eK.Color.b)
        							eL.Transparency = 0.4
        						end
        						if FFC(eK, "Sleeve") then
        							eK.Sleeve.Mesh.VertexColor = Vector3.new(eK.Color.r, eK.Color.g, eK.Color.b)
        							eK.Sleeve.Material = "ForceField"
        							eK.Sleeve.Transparency = 0.6
        						end
        					end
        				end
        			end
        		end
        		if library.flags[GameTitle .. " Transparent Weapon"] then
        			for u, d1 in next, di:GetChildren() do
        				if d1:IsA "MeshPart" or d1:IsA "Part" then
        					d1.Material = "ForceField"
        					d1.Color = library.flags[GameTitle .. " Weapon Color"]
        				end
        			end
        		end
        	end
        end)
        eV:AddToggle({text = "Viewmodel Changer"})
        eV:AddSlider({text = "X Offset", value = 0, min = -20, max = 20})
        eV:AddSlider({text = "Y Offset", value = 0, min = -20, max = 20})
        eV:AddSlider({text = "Z Offset", value = 0, min = -20, max = 20})
        eV:AddToggle({text = "Flip Y"})
        eV:AddToggle({text = "Flip Z"})
        local eN
        eV:AddToggle({text = "Color Correction", callback = function(cc)
        	eN = FFC(Lighting, "Niggapenis")
        	if not eN then
        		eN = library:Create("ColorCorrectionEffect", {
        			Name = "Niggapenis",
        			TintColor = library.flags[GameTitle .. " Tint Color"],
        			Brightness = 0,
        			Parent = Lighting
        		})
        	end
        	eN.Enabled = cc
        end}):AddColor({flag = "Tint Color", callback = function(aD)
        	if eN then
        		eN.TintColor = aD
        	end
        end})
        local eP
        
        eV:AddToggle({text = "Nightmode", callback = function(cc)
        	eP = FFC(Lighting, "Nightmode")
        	if not eP then
        		eP = library:Create("ColorCorrectionEffect", {
        			Name = "Nightmode",
        			TintColor = Color3.fromRGB(255, 255, 255),
        			Brightness = -0.2,
        			Contrast = -0.2,
        			Parent = Lighting
        		})
        	end
        	eP.Enabled = cc
        	while library and library.flags[GameTitle .. " Nightmode"] and wait() do
        		Lighting.ClockTime = 4
        	end
        	Lighting.ClockTime = 12
        end})
    end
end)