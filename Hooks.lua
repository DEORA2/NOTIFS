--Aimbot Module
	local AimbotRayParams = RaycastParams.new()
	AimbotRayParams.FilterType = Enum.RaycastFilterType.Whitelist
	AimbotRayParams.IgnoreWater = true

	local AimbotHitboxes = {}

	library.Aimbot = {
		Target = nil,
		Player = nil,
		Distance = nil,
		Position = nil,
		Position3d = nil,
		LastPosition = V3Empty,
		PositionOffset = nil,
		PositionOffset2d = nil,
		Part = nil,
		OnScreen = false,
		LastVisible = false,
		Step = 0,
		OldStep = 0,
		AutoShootStep = 0
	}

	library.Aimbot.Reset = function()
		library.Aimbot.Target = nil
		library.Aimbot.Player = nil
		library.Aimbot.Distance = 9e9
		library.Aimbot.Position = nil
		library.Aimbot.Position3d = nil
		library.Aimbot.LastPosition = V3Empty
		library.Aimbot.PositionOffset = nil
		library.Aimbot.PositionOffset2d = nil
		library.Aimbot.Part = nil
		library.Aimbot.OnScreen = false
		library.Aimbot.LastVisible = false
		library.Aimbot.Step = 0
		library.Aimbot.SwitchStep = 0
		library.Aimbot.AutoShootStep = 0
	end

	library.Aimbot.Check = function(Player, Steady, Step)
		if not Players[Player] then return end
		local Character, ClientChar = Players[Player].Character, Players[Client].Character
		if Players[Player].Health > 0.1 and Character and ClientChar then
			local MX, MY = Mouse.X, Mouse.Y
			if library.flags["Mouse Offset"] then
				MX = MX + library.flags["MXO Amount"]
				MY = MY + library.flags["MYO Amount"]
			end

			local Target
			local OldDist = 9e9
			if library.flags["Aimbot Randomize Hitbox"] then
				if library.Aimbot.Part then
					Target = GetHitboxFromChar(Character, library.Aimbot.Part)
				else
					if not Target then
						local PartName = AimbotHitboxes[math.random(1, #AimbotHitboxes)]
						Target = GetHitboxFromChar(Character, PartName)
						library.Aimbot.Part = PartName
					end
				end
			else
				for i,v in next, library.flags["Aimbot Hitboxes"] do
					if not v then continue end

					local Part = GetHitboxFromChar(Character, i)
					if not Part then continue end

					local ScreenPos = WTSP(Camera, Part.Position)
					local Dist = (Vector2.new(MX, MY) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude

					if Dist > OldDist then continue end

					OldDist = Dist
					Target = Part			
				end
			end
			if not Target then return end

			local Position, OnScreen = WTSP(Camera, Target.Position)
			if library.flags["Aimbot Mode"] ~= "Silent" then
				if not OnScreen then
					return
				end
			end

			local DistanceFromCharacter = (Target.Position - Camera.CFrame.p).Magnitude
			if DistanceFromCharacter > library.flags["Aimbot Max Distance"] then return end

			local DistanceFromMouse = (Vector2.new(MX, MY) - Vector2.new(Position.X, Position.Y)).Magnitude
			if library.flags["Use FOV"] then
				local FoVSize = library.flags["FOV Size"]
				if DistanceFromMouse > FoVSize + (library.flags["Dynamic FOV"] and ((120 - Camera.FieldOfView) * 4) or FoVSize) then
					return
				end
			end

			local Hit
			if library.flags["Aimbot Vis Check"] or library.flags["Auto Shoot"] or library.flags["Aimbot Prioritize"] then
				Hit = RayCheck(ClientChar, Target.Position, library.flags["Aimbot Max Distance"])
				Hit = Hit and Hit.Instance and FFA(Hit.Instance, Character.Name) == Character
				if Hit then
					if library.flags["Auto Shoot"] then
						library.Aimbot.AutoShootStep = library.Aimbot.AutoShootStep + Step
						if library.Aimbot.AutoShootStep > library.flags["Auto Shoot Interval"] * 0.001 then
							library.Aimbot.AutoShootStep = 0
							if library.flags["Aimbot Mode"] == "Silent" then
								mouse1click()
							else
								AimbotRayParams.FilterDescendantsInstances = {Character}
								local Pos = Camera.CFrame.p
								if workspace:Raycast(Pos, (Camera:ScreenPointToRay(MX, MY, 10000).Origin - Pos).Unit * library.flags["Aimbot Max Distance"], AimbotRayParams) then
									mouse1click()
								end
							end
						end
					end
				else
					if library.flags["Aimbot Vis Check"] then
						return
					end
					if library.flags[GameTitle .. " Wallbang"] and library.flags["Auto Shoot"] then
						library.Aimbot.AutoShootStep = library.Aimbot.AutoShootStep + Step
						if library.Aimbot.AutoShootStep > library.flags["Auto Shoot Interval"] * 0.001 then
							library.Aimbot.AutoShootStep = 0
							mouse1click()
						end
					end
				end
			end

			library.Aimbot.PositionOffset = library.Aimbot.PositionOffset or V3Empty
			library.Aimbot.PositionOffset2d = library.Aimbot.PositionOffset2d or V3Empty
			if library.flags["Velocity Prediction"] then
				local Diff = (Target.Position - library.Aimbot.LastPosition)
				if Diff.Magnitude > (library.flags["Aimbot Mode"] == "Legit" and 0.05 or 0.01) then
					library.Aimbot.PositionOffset = Diff.Unit * library.flags["Velocity Prediction Multiplier"]
					library.Aimbot.PositionOffset2d = WTSP(Camera, Target.Position + library.Aimbot.PositionOffset) - Position
				else
					library.Aimbot.PositionOffset = V3Empty
					library.Aimbot.PositionOffset2d = V3Empty
				end
			end

			if Players[Player].Priority then
				library.Aimbot.Target = Target
				library.Aimbot.Player = Player
				library.Aimbot.Position3d = Target.Position + library.Aimbot.PositionOffset
				library.Aimbot.Position = Position + library.Aimbot.PositionOffset2d
				library.Aimbot.OnScreen = OnScreen
				return true
			end

			if not Steady then
				if library.flags["Aimbot Priority"] == "Mouse" then
					if DistanceFromMouse <= library.Aimbot.Distance then
						library.Aimbot.Distance = DistanceFromMouse
					else
						return
					end
				else
					if DistanceFromCharacter <= library.Aimbot.Distance then
						library.Aimbot.Distance = DistanceFromCharacter
					else
						return
					end
				end
			end

			if library.flags["Aimbot Prioritize"] then
				if not Hit then
					if library.Aimbot.LastVisible then
						return
					end
				end
			end

			library.Aimbot.Target = Target
			library.Aimbot.Player = Player
			library.Aimbot.Position3d = Target.Position + library.Aimbot.PositionOffset
			library.Aimbot.Position = Position + library.Aimbot.PositionOffset2d
			library.Aimbot.OnScreen = OnScreen
			return true
		end
	end

	library.Aimbot.Run = function(Step)
		if library.Aimbot.Check(library.Aimbot.Player, true, Step) then
			if library.flags["Aimbot Mode"] == "Legit" then
				local AimAtX, AimAtY = library.Aimbot.Position.X, library.Aimbot.Position.Y
				local MX, MY = Mouse.X, Mouse.Y

				if library.flags["Mouse Offset"] then
					MX = MX + library.flags["MXO Amount"]
					MY = MY + library.flags["MYO Amount"]
				end

				AimAtX, AimAtY = AimAtX - MX, AimAtY - MY

				--local MinDist = 10
				--local mouseSens = UserSettings():GetService"UserGameSettings".MouseSensitivity
				local Smoothness = library.flags["Aimbot Smoothness"]
				if library.flags["Aimbot Snap"] then
					if math.abs(AimAtX) >= Smoothness or math.abs(AimAtY) >= Smoothness then
						AimAtX = AimAtX / Smoothness
						AimAtY = AimAtY / Smoothness
					end
				else
					if Smoothness > 1 then
						AimAtX = AimAtX / Smoothness
						AimAtY = AimAtY / Smoothness
					end
				end

				mousemoverel(AimAtX, AimAtY)
			end

			library.Aimbot.LastPosition = library.Aimbot.Target.Position
			if library.flags["Aim Lock"] then
				return
			end
		else
			library.Aimbot.Reset()
		end
		library.Aimbot.SwitchStep = library.Aimbot.SwitchStep + Step
		if library.Aimbot.Player then
			if library.Aimbot.SwitchStep < library.flags["Aimbot Switch Delay"] * 0.001 then return end
		end
		library.Aimbot.SwitchStep = 0
		library.Aimbot.Distance = 9e9
		for Player, Data in next, Players do
			if Player == Client or Data.Whitelist then continue end
			if (library.flags["Aimbot At Teammates"] or Data.Enemy) then
				if library.Aimbot.Check(Player, false, 0) and Data.Priority then
					break
				end
			end
		end
	end

	local TriggerStep = 0
	local function RunTriggerbot()
		local ClientChar = Players[Client].Character
		if not ClientChar then return end
		for _, Data in next, Players do
			local Character = Data.Character
			if Character and (library.flags["Triggerbot Teammates"] or Data.Enemy) then
				local MX, MY = Mouse.X, Mouse.Y
				if library.flags["Mouse Offset"] then
					MX = MX + library.flags["MXO Amount"]
					MY = MY + library.flags["MYO Amount"]
				end
				local Hit = RayCheck(ClientChar, Camera:ScreenPointToRay(MX, MY, 2000).Origin, 2000)
				if Hit and Hit.Instance then
					if library.flags["Triggerbot Hitbox"] == "Character" and Hit.Instance:IsDescendantOf(Character) or Hit.Instance.Name == library.flags["Triggerbot Hitbox"] then
						--if library.flags["Triggerbot Magnet"] then
						--	local ScreenPos = WTSP(Camera, Hit.Instance.Position)
						--	local AimAtX, AimAtY = (ScreenPos.X - Mouse.X) - MX, (ScreenPos.Y - Mouse.Y) - MY
						--	mousemoverel(AimAtX, AimAtY)
						--end
						--print"click"
						mouse1click()
					end
				end
			end
		end
	end

	local AimbotTab = library:AddTab"Aimbot"
	local AimbotColumn = AimbotTab:AddColumn()
	local AimbotColumn1 = AimbotTab:AddColumn()

	local AimbotMain = AimbotColumn:AddSection"Main"
	local AimbotTargeting = AimbotColumn:AddSection"Targeting"
	local AimbotMisc = AimbotColumn1:AddSection"Misc"
	local TriggerbotMain = AimbotColumn1:AddSection"Triggerbot"

	AimbotMain:AddToggle({text = "Enabled", flag = "Aimbot", callback = function(State)
		Draw.Visible = State and library.flags["Use FOV"] and library.flags["Draw Circle"]
		if library.flags["Aimbot Always On"] then
			library.options["Aimbot Always On"]:SetState(true)
		end
	end}):AddList({text = "Mode", flag = "Aimbot Mode", values = {"Legit", "Rage"}, callback = function(Value)
		library.options["Aimbot Smoothness"].main.Visible = Value == "Legit"
		library.options["Aimbot Snap"].main.Visible = Value == "Legit"
		library.options["Mouse Offset"].main.Visible = Value == "Legit"
		library.options["MXO Amount"].main.Visible = Value == "Legit" and library.flags["Mouse Offset"]
		library.options["MYO Amount"].main.Visible = Value == "Legit" and library.flags["Mouse Offset"]
	end}):AddBind({flag = "Aimbot Key", mode = "hold", callback = function(Ended, Step)
		if library.flags["Aimbot"] and not library.flags["Aimbot Always On"] then
			if library.open or Ended then
				library.Aimbot.Reset()
			else
				library.Aimbot.Step = library.Aimbot.Step + Step
				if library.Aimbot.Step > 0.016 then
					library.Aimbot.Step = 0
					library.Aimbot.Run(Step)
				end
			end
		end
	end})
	AimbotMain:AddToggle({text = "Always On", flag = "Aimbot Always On", callback = function(State)
		if not State then return end

		library:AddConnection(runService.RenderStepped, "Aimbot", function(Step)
			if library.open then library.Aimbot.Reset() return end
			if library.flags["Aimbot"] and library.flags["Aimbot Always On"] then
				library.Aimbot.Step = library.Aimbot.Step + Step
				if library.Aimbot.Step > 0.016 then
					library.Aimbot.Step = 0
					library.Aimbot.Run(Step)
				end
			else
				library.connections["Aimbot"]:Disconnect()
				library.Aimbot.Reset()
			end
		end)
	end})
	AimbotMain:AddSlider({text = "Smoothness", flag = "Aimbot Smoothness", min = 1, max = 40})
	AimbotMain:AddToggle({text = "Velocity Prediction", state = false, callback = function(State)
		library.options["Velocity Prediction Multiplier"].main.Visible = State
	end})
	AimbotMain:AddSlider({text = "Multiplier", textpos = 2, flag = "Velocity Prediction Multiplier", min = 1, max = 5, float = 0.1})
	--AimbotMain:AddSlider({text = "Prediction Interval", min = 1, max = 1000})
	AimbotMain:AddToggle({text = "Snap Near Target", flag = "Aimbot Snap"})--:AddSlider({text = "Snap Range" flag = "Aimbot Snap Range", min = 5, max = 50})
	--AimbotMain:AddToggle({text = "Curve", flag = "Aimbot Curve"}):AddSlider({text = "Size", flag = "Aimbot Curve Size", min = 1, max = 50})
	AimbotMain:AddToggle({text = "Lock Target", flag = "Aim Lock"})
	AimbotMain:AddToggle({text = "Auto Shoot", callback = function(State)
		library.options["Auto Shoot Interval"].main.Visible = State
		if State then
			library.options["Triggerbot"]:SetState()
		end
	end})
	AimbotMain:AddSlider({text = "Interval", textpos = 2, flag = "Auto Shoot Interval", min = 1, max = 10, float = 0.5, suffix = "ms"})
	--AimbotMain:AddToggle({text = "Randomization"})
	--AimbotMain:AddSlider({text = "Amount", flag = "Randomize Amount", min = 40, max = 100})
	AimbotMain:AddSlider({text = "Target Switch Delay", flag = "Aimbot Switch Delay", min = 5, max = 500, suffix = "ms"})
	AimbotMain:AddToggle({text = "Ignore Spawn Protection", flag = "Aimbot Ignore Spawn Protection"})

	AimbotTargeting:AddToggle({text = "Visible Only", flag = "Aimbot Vis Check", callback = function(State)
		if State then
			--library.options["Aimbot Prioritize"]:SetState()
		end
	end})
	--AimbotTargeting:AddToggle({text = "Prioritize Visible", flag = "Aimbot Prioritize", callback = function(State)
	--	if State then
	--		library.options["Aimbot Vis Check"]:SetState()
	--	end
	--end})
	AimbotTargeting:AddToggle({text = "At Teammates", flag = "Aimbot At Teammates"})
	AimbotTargeting:AddList({text = "Priority", flag = "Aimbot Priority", values = {"Mouse", "Distance"}})
	AimbotTargeting:AddList({text = "Hitboxes", flag = "Aimbot Hitboxes", max = 6, multiselect = true, values = UseBodyParts, callback = function(Values)
		for i,v in next, Values do
			if v then
				if table.find(AimbotHitboxes, i) then continue end
				table.insert(AimbotHitboxes, i)
			else
				local pos = table.find(AimbotHitboxes, i)
				if not pos then continue end
				table.remove(AimbotHitboxes, pos)
			end
		end
	end})
	AimbotTargeting:AddToggle({text = "Randomize Hitbox", flag = "Aimbot Randomize Hitbox"})

	AimbotTargeting:AddSlider({text = "Max Distance", flag = "Aimbot Max Distance", value = 10000, min = 0, max = 10000})

	AimbotMisc:AddToggle({text = "Mouse Offset", callback = function(State)
		if library.flags["Aimbot Mode"] == "Legit" then
			library.options["MXO Amount"].main.Visible = State
			library.options["MYO Amount"].main.Visible = State
		end
	end})
	AimbotMisc:AddSlider({text = "X", textpos = 2, flag = "MXO Amount", min = -100, max = 100, value = 0})
	AimbotMisc:AddSlider({text = "Y", textpos = 2, flag = "MYO Amount", min = -100, max = 100, value = 0})
	AimbotMisc:AddToggle({text = "Highlight Target"}):AddColor({flag = "Aimbot Highlight Color", color = Color3.fromRGB(240, 20, 255)})
	AimbotMisc:AddToggle({text = "Use FOV", callback = function(State) Draw.Visible = State and library.flags["Aimbot"] and library.flags["Draw Circle"] end}):AddSlider({text = "Size", flag = "FOV Size", min = 10, max = 900, callback = function(Value) if not library.flags["Dynamic FOV"] then Draw.Radius = Value * 2 end end})
	AimbotMisc:AddToggle({text = "Dynamic", flag = "Dynamic FOV", callback = function(State)
		if State then
			library:AddConnection(runService.RenderStepped, "Dynamic FOV", function()
				if library and library.flags["Dynamic FOV"] then
					Draw.Radius = library.flags["FOV Size"] + ((120 - Camera.FieldOfView) * 4)
				else
					library.connections["Dynamic FOV"]:Disconnect()
					Draw.Radius = library.flags["FOV Size"] * 2
				end
			end)
		end
	end})
	AimbotMisc:AddToggle({text = "Draw Circle", callback = function(State) Draw.Visible = State and library.flags["Aimbot"] and library.flags["Use FOV"] end}):AddColor({flag = "FOV Circle Color", Color3.fromRGB(240, 20, 255), trans = 1, callback = function(Color) Draw.Color = Color end, calltrans = function(Value) Draw.Transparency = Value end})
	AimbotMisc:AddToggle({text = "Fill", flag = "FOV Fill", callback = function(State) Draw.Filled = State end})

	TriggerbotMain:AddToggle({text = "Enabled", flag = "Triggerbot", callback = function(State)
		if State then
			library.options["Auto Shoot"]:SetState()
			if library.flags["Triggerbot Always On"] then
				library.options["Triggerbot Always On"]:SetState(true)
			end
		end
	end}):AddSlider({text = "Delay", flag = "Triggerbot Delay", min = 5, max = 1000, suffix = "ms"}):AddBind({flag = "Triggerbot Key", mode = "hold", callback = function(Ended, Step)
		if library.flags["Triggerbot"] and not library.flags["Triggerbot Always On"] then
			if not library.open then
				TriggerStep = TriggerStep + Step
				if TriggerStep > library.flags["Triggerbot Delay"] * 0.001 then
					TriggerStep = 0
					RunTriggerbot()
				end
			end
		end
	end})
	TriggerbotMain:AddToggle({text = "Always On", flag = "Triggerbot Always On", callback = function(State)
		if State then
			library:AddConnection(runService.RenderStepped, "Triggerbot", function(Step)
				if library.open then return end
				if library.flags["Triggerbot"] and library.flags["Triggerbot Always On"] then
					TriggerStep = TriggerStep + Step
					if TriggerStep > library.flags["Triggerbot Delay"] * 0.001 then
						TriggerStep = 0
						RunTriggerbot(Step)
					end
				else
					library.connections["Triggerbot"]:Disconnect()
				end
			end)
		end
	end})
	--TriggerbotMain:AddToggle({text = "Magnet", flag = "Triggerbot Magnet"})
	TriggerbotMain:AddList({text = "Hitbox", flag = "Triggerbot Hitbox", values = {"Head", "Torso", "Character"}})
	TriggerbotMain:AddToggle({text = "At Teammates", flag = "Triggerbot Teammates"})
