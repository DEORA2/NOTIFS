--Esp module

	local VisualsTab = library:AddTab"Visuals"
	local VisualsColumn = VisualsTab:AddColumn()
	local VisualsColumn1 = VisualsTab:AddColumn()

	local HealthBarAddon = Vector2.new(3)
	local PlayerEspSection = VisualsColumn:AddSection"ESP"
	local OldStep = 0
	PlayerEspSection:AddToggle({text = "Enabled", flag = "Esp Enabled", callback = function(State)
		if not State then
			--RadarWindow.Visible = false
			if library.connections["Player ESP"] then
				library.connections["Player ESP"]:Disconnect()
				for _, v in next, ESPObjects do
					v.OOVArrow.Visible = false
					v.Invis()
					v.InvisChams()
					v.InvisChamsOutline()
				end
			end

			return
		end

		--RadarWindow.Visible = library.flags["Radar Enabled"]
		library:AddConnection(runService.RenderStepped, "Player ESP", function(Step)
			OldStep = OldStep + Step
			if OldStep < 0.016 then return end
			OldStep = 0

			for Player, Data in next, Players do
				if Player == Client then continue end
				local Objects = ESPObjects[Player]
				local Character = Data.Character

				local Show
				local Team = Data.Enemy
				if Data.Whitelist then
					Show = library.flags["Esp Show Whitelisted"]
				else
					Show = Data.Priority or library.flags["Esp Enabled For"][Team and "Enemies" or "Teammates"]
				end

				if Show and Character then
					local Health = Data.Health

					if Health > 0.1 then
						Team = Team and "Enemy" or "Team"

						local Pos, Size = GBB(Character)
						local RootPart = FFC(Character, "HumanoidRootPart")
						if RootPart and (Pos.Position - RootPart.Position).Magnitude > 5 then
							Pos = RootPart.CFrame
						end

						local Distance = (Camera.CFrame.p - Pos.Position).Magnitude
						if Distance < library.flags["Esp Max Distance"] then

							local ScreenPosition, OnScreen = WTVP(Camera, Pos.Position)

							local ClientChar = Players[Client].Character
							local Ignores = {Camera, ClientChar}
							if GameTitle == "Bad Business" then
								Ignores[3] = FFC(workspace, "Arms")
								--Ignores[4] = ClientChar and FFC(workspace, ClientChar.Backpack.Equipped.Value.Name)
								Ignores[5] = workspace.NonProjectileGeometry
								Ignores[6] = workspace.Effects
								Ignores[7] = workspace.Spawns
								Ignores[8] = workspace.Ragdolls
								Ignores[9] = workspace.Gameplay
								Ignores[10] = workspace.Throwables
							elseif GameTitle == "Phantom Forces" then
								Ignores[3] = workspace.Ignore
							end
							local Hit = RayCheck(ClientChar, Pos.Position, Distance)
							Hit = Hit and Hit.Instance and FFA(Hit.Instance, Character.Name)
							Hit = Hit and Hit == Character
							local Occluded = Hit and " " or " Occluded "

							local Visible = true
							if library.flags[Team .. " Visible Only"] then
								Visible = Hit ~= nil
							end

							local Color = (library.flags["Highlight Target"] and library.Aimbot.Player == Player and library.flags["Aimbot Highlight Color"])
							Color = Color or (Data.Priority and library.flags["Player Priority Color"] or Data.Whitelist and library.flags["Player Whitelist Color"])
							Color = Color or (GameTitle == "KAT" and (workspace.Gamemode.Value == "Murder" and ((FFC(Player.Backpack, "Knife") or FFC(Character, "Knife")) and library.flags[GameTitle .. " Murderer Color"] or (FFC(Player.Backpack, "Revolver") or FFC(Character, "Revolver")) or library.flags[GameTitle .. " Sheriff Color"])) or GameTitle == "MURDER" and ((Player.Status.Role.Value == "Murderer" and library.flags[GameTitle .. " Murderer Color"]) or (Player.Status.HasRevolver.Value and library.flags[GameTitle .. " Detective Color"])) or GameTitle == "Arsenal" and Player.NRPBS.EquippedTool.Value:find("Golden") and library.flags[GameTitle .. " Golden Weapon Color"])

							--
							if library.flags["Radar Enabled"] and Distance < RadarWindow.Radius then
								Objects.RadarBlip.Visible = true

								local RelativePos = Camera.CFrame:Inverse() * Pos.Position
								local Middle = Camera.ViewportSize / 2
								local Degrees = math.deg(math.atan2(-RelativePos.Y, RelativePos.X)) * math.pi / 180
								local EndPos = Middle + (Vector2.new(math.cos(Degrees), math.sin(Degrees)) * Distance)

								Objects.RadarBlip.Position = EndPos
								Objects.RadarBlip.Color = Color or Color3.new(1, 1, 1)

								if not Objects.Visible then
									continue
								end
							else
								Objects.RadarBlip.Visible = false
							end
							--]]

							if Visible then
								local Transparency = (library.Aimbot.Player == Player or Data.Priority) and 1 or 1 - (Distance / library.flags["Esp Max Distance"])

								if OnScreen then
									Objects.Visible = true
									Objects.OOVArrow.Visible = false

									--local xMin, yMin = 9e9, 9e9
									--local xMax, yMax = 0, 0

									local BoxColor = Color or library.flags[Team .. Occluded .. "Box Color"]
									local TextColor = Color or library.flags[Team .. Occluded .. "Info Color"]
									local LookColor = Color or library.flags[Team .. Occluded .. "Look Color"]
									local ChamsColor = Color or library.flags[Team .. Occluded .. "Chams Color"]
									local ChamsOutlineColor = Color or library.flags[Team .. Occluded .. "Chams Outline Color"]
									local DirectionColor = Color or library.flags[Team .. Occluded .. "Direction Color"]

									--Chams
									if library.flags[Team .. " Chams Enabled"] and Distance < 600 then
										Objects.ChamsVisible = true
										Objects.Chams.Parent = library.base
										Objects.ChamsStep = Objects.ChamsStep + Step
										if Objects.ChamsStep > 0.2 then
											Objects.ChamsStep = 0
											for _, PartName in next, UseBodyParts do
												local Part = FFC((GameTitle == "Bad Business" and Character.Body or Character), PartName, true)
												if Part then
													local Cham = FFC(Objects.Chams, PartName) or (function()
														return library:Create("BoxHandleAdornment", {
															Name = PartName,
															AlwaysOnTop = true,
															ZIndex = 2,
															Parent = Objects.Chams
														})
													end)()

													Cham.Size = Part.Size * 0.6
													Cham.Adornee = Part
													Cham.Transparency = library.flags[Team .. " Chams Transparency"]
													Cham.Color3 = ChamsColor

													if library.flags[Team .. " Chams Outline"] then
														Objects.ChamsOutlineVisible = true
														Objects.ChamsOutline.Parent = library.base
														Cham = FFC(Objects.ChamsOutline, PartName) or (function()
															return library:Create("BoxHandleAdornment", {
																Name = PartName,
																AlwaysOnTop = true,
																ZIndex = 1,
																Parent = Objects.ChamsOutline
															})
														end)()

														Cham.Size = Part.Size * 1.1
														Cham.Adornee = Part
														Cham.Transparency = library.flags[Team .. " Chams Transparency"]
														Cham.Color3 = ChamsOutlineColor
													else
														if Objects.ChamsOutlineVisible then
															Objects.InvisChamsOutline()
														end
													end
												else
													local Cham = FFC(Objects.Chams, PartName)
													if Cham then
														Cham.Visible = false
													end
													Cham = FFC(Objects.ChamsOutline, PartName)
													if Cham then
														Cham.Visible = true
													end
												end
											end
										end
									else
										if Objects.ChamsVisible then
											Objects.InvisChams()
											Objects.InvisChamsOutline()
										end
									end

									--ESP
									local Height = (Camera.CFrame - Camera.CFrame.p) * Vector3.new(0, (math.clamp(Size.Y, 1, 10) + 0.5) / 2, 0)
									Height = math.abs(WTSP(Camera, Pos.Position + Height).Y - WTSP(Camera, Pos.Position - Height).Y)
									--local ViewportSize = Camera.ViewportSize
									--local Size = ((ViewportSize.X + ViewportSize.Y) / Distance) * (1 - (Camera.FieldOfView / 200))
									Size = library.round(Vector2.new(Height / 2, Height))
									local Position = library.round(Vector2.new(ScreenPosition.X, ScreenPosition.Y) - (Size / 2))

									if library.flags[Team .. " Box Enabled"] then
										Objects.Box.Visible = true
										Objects.Box.Color = BoxColor
										Objects.Box.Size = Size
										Objects.Box.Position = Position
										Objects.Box.Transparency = Transparency

										Objects.BoxOutline.Visible = true
										Objects.BoxOutline.Size = Size + V222
										Objects.BoxOutline.Position = Position - V211
										Objects.BoxOutline.Transparency = Transparency

										Objects.BoxInline.Visible = true
										Objects.BoxInline.Size = Size - V222
										Objects.BoxInline.Position = Position + V211
										Objects.BoxInline.Transparency = Transparency
									else
										Objects.Box.Visible = false
										Objects.BoxOutline.Visible = false
										Objects.BoxInline.Visible = false
									end

									if library.flags[Team .. " Health Enabled"] then
										local MaxHealth = Data.MaxHealth
										local HealthPerc = Health / MaxHealth
										local Position = Position - HealthBarAddon
										local Size = Vector2.new(1, Size.Y)

										Objects.BarOutline.Visible = true
										Objects.BarOutline.Position = Position - V211
										Objects.BarOutline.Size = Size + V222
										Objects.BarOutline.Transparency = Transparency

										Objects.Bar.Visible = true
										Objects.Bar.Color = Color3.new(1 - HealthPerc, HealthPerc, 0.2)
										Objects.Bar.Position = Position + Vector2.new(0, Size.Y)
										Objects.Bar.Size = Vector2.new(1, -Size.Y * HealthPerc)
										Objects.Bar.Transparency = Transparency

										Objects.HealthText.Visible = HealthPerc < 0.99
										Objects.HealthText.Position = Objects.Bar.Position + Objects.Bar.Size - Vector2.new(0, 7)
										Objects.HealthText.Text = tostring(library.round(Health)) or ""
										Objects.HealthText.Transparency = Transparency
									else
										Objects.BarOutline.Visible = false
										Objects.Bar.Visible = false
										Objects.HealthText.Visible = false
									end

									if library.flags[Team .. " Info"] then
										Objects.NameText.Visible = true
										Objects.NameText.Text = Player.Name
										Objects.NameText.Position = Position + Vector2.new(Size.X / 2, -Objects.NameText.TextBounds.Y - 1)
										Objects.NameText.Color = TextColor
										Objects.NameText.Transparency = Transparency
                                        
										Objects.DistanceText.Visible = true
										Objects.DistanceText.Text = "[" .. library.round(Distance) .. "m]"
										--Objects.DistanceText.Text = "[" .. Player.Character.EquippedTool.Value .. "]"
										Objects.DistanceText.Position = Position + Vector2.new(Size.X / 5, Size.Y + 2)
										Objects.DistanceText.Color = TextColor
										Objects.DistanceText.Transparency = Transparency
									else
										Objects.NameText.Visible = false
										Objects.DistanceText.Visible = false
										Objects.WeaponText.Visible = false
									end

									if library.flags[Team .. " Look Enabled"] then
										HeadPosition = GetHitboxFromChar(Character, "Head")
										if HeadPosition then
											Objects.LookAt.Visible = true
											HeadPosition1 = WTVP(Camera, HeadPosition.Position)
											local To = WTVP(Camera, HeadPosition.Position + (HeadPosition.CFrame.LookVector * 8))

											Objects.LookAt.From = Vector2.new(HeadPosition1.X, HeadPosition1.Y)
											Objects.LookAt.To = Vector2.new(To.X, To.Y)
											Objects.LookAt.Color = LookColor
											Objects.LookAt.Transparency = Transparency
										else
											Objects.LookAt.Visible = false
										end
									else
										Objects.LookAt.Visible = false
									end

									if library.flags[Team .. " Direction Enabled"] then
										Objects.DirectionLine.Visible = true

										Position = Position + (Size / 2)
										local PositionOffset2d = V2Empty
										local Diff = (Pos.Position - Data.LastPosition)
										if Diff.Magnitude > 0.01 then
											PositionOffset2d = library.round(Vector2.new(WTSP(Camera, Pos.Position + (Diff.Unit * 4)).X, Position.Y) - Position)
										end

										Objects.DirectionLine.From = Position
										Objects.DirectionLine.To = Position + PositionOffset2d
										Objects.DirectionLine.Color = DirectionColor
										Objects.DirectionLine.Transparency = Transparency

										if Distance < 600 then
											Objects.DirectionDot.Visible = true
											Objects.DirectionDot.Position = Objects.DirectionLine.To - V233
											Objects.DirectionDot.Color = DirectionColor
											Objects.DirectionDot.Transparency = Transparency
										else
											Objects.DirectionDot.Visible = false
										end
									else
										Objects.DirectionLine.Visible = false
										Objects.DirectionDot.Visible = false
									end

									Data.LastPosition = Pos.Position
									continue
								end
								if library.flags[Team .. " OOV Arrows"] then
									Objects.OOVArrow.Visible = true
									Objects.OOVArrow.Color = Color or library.flags[Team .. Occluded .. "OOV Arrows Color"]

									local RelativePos = Camera.CFrame:Inverse() * Pos.Position
									local Middle = Camera.ViewportSize / 2
									local Degrees = math.deg(math.atan2(-RelativePos.Y, RelativePos.X)) * math.pi / 180
									local EndPos = Middle + (Vector2.new(math.cos(Degrees), math.sin(Degrees)) * library.flags[Team .. " Out Of View Scale"])

									Objects.OOVArrow.PointB = EndPos + (-(Middle - EndPos).Unit * 15)
									Objects.OOVArrow.PointA = EndPos
									Objects.OOVArrow.PointC = EndPos
									Objects.OOVArrow.Transparency = Transparency

									if not Objects.Visible then
										continue
									end
								end
							end
						end
					end
				end

				Objects.OOVArrow.Visible = false
				if Objects.Visible then
					Objects.Invis()
					Objects.InvisChams()
					Objects.InvisChamsOutline()
					Objects.InvisRadar()
				end
			end
		end)
	end}):AddList({flag = "Esp Enabled For", values = {"Enemies", "Teammates"}, multiselect = true}):AddBind({callback = function()
		library.options["Esp Enabled"]:SetState(not library.flags["Esp Enabled"])
	end})
	PlayerEspSection:AddSlider({text = "Max Distance", textpos = 2, flag = "Esp Max Distance", value = 999999, min = 0, max = 999999})
	PlayerEspSection:AddToggle({text = "Show Whitelisted Players", flag = "Esp Show Whitelisted"})
	local VisualsWorld = VisualsColumn:AddSection"Lighting"
	VisualsWorld:AddToggle({text = "Clock Time"}):AddSlider({flag = "Clock Time Amount", min = 0, max = 24, float = 0.1, value = LightingSpoof.ClockTime})
	VisualsWorld:AddToggle({text = "Brightness"}):AddSlider({flag = "Brightness Amount", min = 0, max = 100, float = 0.1, value = LightingSpoof.Brightness})
	VisualsWorld:AddToggle({text = "Ambient", flag = "Ambient Lighting"}):AddColor({flag = "Outdoor Ambient", color = LightingSpoof.OutdoorAmbient}):AddColor({flag = "Indoor Ambient", color = LightingSpoof.Ambient})
	VisualsWorld:AddToggle({text = "Color Shift"}):AddColor({flag = "Color Shift Top", color = LightingSpoof.ColorShift_Top})

	local VisualsMiscSection = VisualsColumn:AddSection"Misc"

	VisualsMiscSection:AddToggle({text = "FOV Changer", callback = function(State)
		library.options["Dynamic Custom FOV"].main.Visible = State
	end}):AddSlider({flag = "FOV Amount", min = 0, max = 120})
	VisualsMiscSection:AddToggle({text = "Dynamic", flag = "Dynamic Custom FOV"})
	VisualsMiscSection:AddToggle({text = "Zoom", flag = "FOV Zoom Enabled"}):AddSlider({flag = "FOV Zoom Amount", min = 5, max = 50}):AddBind({flag = "FOV Zoom Key", mode = "hold"})

	VisualsMiscSection:AddDivider"Crosshair"
	VisualsMiscSection:AddToggle({text = "Enabled", flag = "Crosshair Enabled", callback = function(State)
		library.options["Crosshair T-Shape"].main.Visible = State
		library.options["Crosshair Size"].main.Visible = State
		library.options["Crosshair Gap"].main.Visible = State
		library.options["Crosshair Thickness"].main.Visible = State
		CrosshairTop.Visible = State and not library.flags["Crosshair T-Shape"]
		CrosshairLeft.Visible = State
		CrosshairRight.Visible = State
		CrosshairBottom.Visible = State
	end}):AddColor({callback = function(Color)
		CrosshairTop.Color = Color
		CrosshairLeft.Color = Color
		CrosshairRight.Color = Color
		CrosshairBottom.Color = Color
	end, trans = 1, calltrans = function(Transparency)
		CrosshairTop.Transparency = Transparency
		CrosshairLeft.Transparency = Transparency
		CrosshairRight.Transparency = Transparency
		CrosshairBottom.Transparency = Transparency
	end})
	VisualsMiscSection:AddToggle({text = "T-Shape", flag = "Crosshair T-Shape", callback = function(State)
		CrosshairTop.Visible = library.flags["Crosshair Enabled"] and not State
	end})
	VisualsMiscSection:AddSlider({text = "Size", textpos = 2, flag = "Crosshair Size", min = 1, max = 500, callback = function(Value)
		local Thickness = library.flags["Crosshair Thickness"]
		CrosshairTop.Size = Vector2.new(Thickness, -Value)
		CrosshairLeft.Size = Vector2.new(-Value, Thickness)
		CrosshairRight.Size = Vector2.new(Value, Thickness)
		CrosshairBottom.Size = Vector2.new(Thickness, Value)
	end})
	VisualsMiscSection:AddSlider({text = "Gap", textpos = 2, flag = "Crosshair Gap", min = 0, max = 20, float = 0.5})
	VisualsMiscSection:AddSlider({text = "Thickness", textpos = 2, flag = "Crosshair Thickness", min = 1, max = 20, float = 0.5, callback = function(Value)
		local Size = library.flags["Crosshair Size"]
		CrosshairTop.Size = Vector2.new(Value, -Size)
		CrosshairLeft.Size = Vector2.new(-Size, Value)
		CrosshairRight.Size = Vector2.new(Size, Value)
		CrosshairBottom.Size = Vector2.new(Value, Size)
	end})
	
	VisualsMiscSection:AddDivider"Extras"
    VisualsMiscSection:AddToggle({text = "Player List", flag = "plrlist", callback = function(K)
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
            Container.BackgroundTransparency = 1
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
            Text.Text = "Player List"
            Text.TextColor3 = Color3.fromRGB(65025, 65025, 65025)
            Text.TextSize = 14.000
            Text.TextStrokeTransparency = 0.000
    
            Players.Name = "Players"
            Players.Parent = Container
            Players.BackgroundTransparency = 1
            Players.Position = UDim2.new(0, 0, 1.14285719, 0)
            Players.Size = UDim2.new(1, 0, 1.14285719, 0)
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
                    if v ~= game.Players.LocalPlayer then
                        if CurrentSpectators == "" then
                                CurrentSpectators = v.Name
                            else
                                CurrentSpectators = CurrentSpectators.. "\n" ..v.Name
                            end
                        end
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
	
    VisualsMiscSection:AddToggle({text = "Status Bar", flag = "stootus", callback = function(K)
        if K == true then
            local StatusBar = Instance.new("ScreenGui")
            local Frame = Instance.new("Frame")
            local Ping = Instance.new("TextLabel")
            local FPS = Instance.new("TextLabel")
            local YourPosition = Instance.new("TextLabel")
            local Health = Instance.new("TextLabel")
            local Spawntime = Instance.new("TextLabel")
            --Properties:
            StatusBar.Name = "StatusBar"
            StatusBar.Parent = game.CoreGui
            StatusBar.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            Frame.Parent = StatusBar
            Frame.BackgroundColor3 = Color3.new(1, 1, 1)
            Frame.BackgroundTransparency = 1
            Frame.BorderSizePixel = 0
            Frame.Position = UDim2.new(0, 200, 0, -36)
            Frame.Size = UDim2.new(0.725000024, 0, 0, 34)
            Frame.ZIndex = 100
            
            Ping.Name = "Ping"
            Ping.Parent = Frame
            Ping.BackgroundColor3 = Color3.new(0.00392157, 0.00392157, 0.00392157)
            Ping.BackgroundTransparency = 1
            Ping.Size = UDim2.new(0.200000003, 0, 0, 34)
            Ping.SizeConstraint = Enum.SizeConstraint.RelativeXX
            Ping.Font = Enum.Font.SourceSans
            Ping.Text = "Ping: nil"
            Ping.TextColor3 = Color3.new(1, 1, 1)
            Ping.TextSize = 40
            Ping.TextWrapped = true
            
            FPS.Name = "FPS"
            FPS.Parent = Frame
            FPS.BackgroundColor3 = Color3.new(1, 1, 1)
            FPS.BackgroundTransparency = 1
            FPS.Position = UDim2.new(0.200000003, 0, 0, 0)
            FPS.Size = UDim2.new(0.200000003, 0, 0, 34)
            FPS.SizeConstraint = Enum.SizeConstraint.RelativeXX
            FPS.Font = Enum.Font.SourceSans
            FPS.Text = "FPS: nil"
            FPS.TextColor3 = Color3.new(1, 1, 1)
            FPS.TextSize = 40
            FPS.TextWrapped = true
            
            YourPosition.Name = "YourPosition"
            YourPosition.Parent = Frame
            YourPosition.BackgroundColor3 = Color3.new(1, 1, 1)
            YourPosition.BackgroundTransparency = 1
            YourPosition.Position = UDim2.new(0.400000006, 0, 0, 0)
            YourPosition.Size = UDim2.new(0.200000003, 0, 0, 34)
            YourPosition.SizeConstraint = Enum.SizeConstraint.RelativeXX
            YourPosition.Font = Enum.Font.SourceSans
            YourPosition.Text = "Position: nil,nil,nil"
            YourPosition.TextColor3 = Color3.new(1, 1, 1)
            YourPosition.TextSize = 30
            YourPosition.TextWrapped = true
            
            Health.Name = "Health"
            Health.Parent = Frame
            Health.BackgroundColor3 = Color3.new(1, 1, 1)
            Health.BackgroundTransparency = 1
            Health.Position = UDim2.new(0.600000024, 0, 0, 0)
            Health.Size = UDim2.new(0.200000003, 0, 0, 34)
            Health.SizeConstraint = Enum.SizeConstraint.RelativeXX
            Health.Font = Enum.Font.SourceSans
            Health.Text = "Health: nil"
            Health.TextColor3 = Color3.new(1, 1, 1)
            Health.TextSize = 30
            
            Spawntime.Name = "Spawntime"
            Spawntime.Parent = Frame
            Spawntime.BackgroundColor3 = Color3.new(1, 1, 1)
            Spawntime.BackgroundTransparency = 1
            Spawntime.Position = UDim2.new(0.800000012, 0, 0, 0)
            Spawntime.Size = UDim2.new(0.200000003, 0, 0, 34)
            Spawntime.SizeConstraint = Enum.SizeConstraint.RelativeXX
            Spawntime.Font = Enum.Font.SourceSans
            Spawntime.Text = "Seconds since spawn: nil"
            Spawntime.TextColor3 = Color3.new(1, 1, 1)
            Spawntime.TextSize = 20
            -- Scripts:
            function SCRIPT_NDMS87_FAKESCRIPT() -- Frame.LocalScript 
            	local script = Instance.new('LocalScript')
            	script.Parent = Frame
            	repeat wait() until game:IsLoaded()
            	wait(1)
            	local labels = script.Parent
            	
            	function round(n)
            	    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
            	end
            	
            	function setsize()
            	local x = workspace.CurrentCamera.ViewportSize.X - 375
            	local old = script.Parent.Size
            	script.Parent.Size = UDim2.new(0, x, 0, old.Y.Offset)
            	end
            	setsize()
            	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            	setsize()
            	end)
            	spawntime = os.time()
            	game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
            	spawntime = os.time()
            	end)
            	local plr = game:GetService("Players").LocalPlayer
            	game:GetService("RunService").RenderStepped:Connect(function()
            		local pos = plr.Character.HumanoidRootPart.CFrame.Position
            		local health = plr.Character:FindFirstChildOfClass("Humanoid").Health
            		labels.Ping.Text = "Ping: " ..game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            		labels.FPS.Text = "FPS: " .. fps
            		labels.YourPosition.Text = "Position: " .. round(pos.x) .. ", " .. round(pos.y) .. ", " .. round(pos.z)
            		labels.Health.Text = "Health: " .. tostring(health)
            		labels.Spawntime.Text = "Seconds since spawn: " ..os.time() - spawntime
            	end)
            	while wait() do
            		fps = round(2/wait())
            	end
            
            end
            coroutine.resume(coroutine.create(SCRIPT_NDMS87_FAKESCRIPT))
        elseif K == false then
            game.CoreGui.StatusBar:Destroy()
        end
    end})
    
    VisualsMiscSection:AddToggle({text = "Watermark", flag = "watermark", callback = function(K)
        if K == true then
            local watermark = Instance.new("ScreenGui")
            local ScreenLabel = Instance.new("Frame")
            local Color = Instance.new("Frame")
            local UIGradient = Instance.new("UIGradient")
            local Container = Instance.new("Frame")
            local UIPadding = Instance.new("UIPadding")
            local Text = Instance.new("TextLabel")
            local Background = Instance.new("Frame")
            local UIGradient_2 = Instance.new("UIGradient")
    
            watermark.Name = "watermark"
            watermark.Parent = game.CoreGui
    
            ScreenLabel.Name = "ScreenLabel"
            ScreenLabel.Parent = watermark
            ScreenLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            ScreenLabel.BackgroundTransparency = 1.000
            ScreenLabel.BorderColor3 = Color3.fromRGB(28, 28, 28)
            ScreenLabel.Position = UDim2.new(0.00800000038, 0, 0.400000006, 26)
            ScreenLabel.Size = UDim2.new(0, 280, 0, 20)
    
            Color.Name = "Color"
            Color.Parent = ScreenLabel
            Color.BackgroundColor3 = Color3.fromRGB(83, 49, 127)
            Color.BorderSizePixel = 0
            Color.Size = UDim2.new(1.25, 0, 0, 2)
            Color.ZIndex = 2
    
            UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(60, 60, 60))}
            UIGradient.Rotation = 90
            UIGradient.Parent = Color
    
            Container.Name = "Container"
            Container.Parent = ScreenLabel
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
            Text.Position = UDim2.new(0.0230769236, 0, 0, 0)
            Text.Size = UDim2.new(1, 0, 1, 0)
            Text.ZIndex = 4
            Text.Font = Enum.Font.RobotoMono
            Text.Text = "Daddyware | 00:00:00 | Oct. 17, 2021"
            Text.TextColor3 = Color3.fromRGB(65025, 65025, 65025)
            Text.TextSize = 14.000
            Text.TextStrokeTransparency = 0.000
            Text.TextXAlignment = Enum.TextXAlignment.Left
    
            Background.Name = "Background"
            Background.Parent = ScreenLabel
            Background.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
            Background.BorderColor3 = Color3.fromRGB(20, 20, 20)
            Background.Size = UDim2.new(1.25, 0, 1, 0)
    
            UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(90, 90, 90))}
            UIGradient_2.Rotation = 90
            UIGradient_2.Parent = Background
            
            local function UQHM_fake_script() -- Text.LocalScript 
                local script = Instance.new('LocalScript', Text)
                local mo = "A.M."
                local mont = nil
                while wait() do
                    local l = math.fmod(tick(),86400)
                    local h = math.floor(l/3600)
                    local m = math.floor(l/60-h*60)
                    local s = math.floor(math.fmod(l,60))
                    local y = math.floor(1970+tick()/31579200)
                    local mon = {{"January",31,31},{"February",59,28},{"March",90,31},{"April",120,30},{"May",151,31},{"June",181,30},{"July",212,31},{"August",243,31},{"September",273,30},{"October",304,31},{"November",334,30},{"December",365,31}}
                    if y%4 == 0 then
                        mon[2][3] = 29
                        for i,v in pairs(mon) do
                            if i ~= 1 then
                                v[2] = v[2] + 1
                            end
                        end
                    end
                    local d = math.floor(tick()/86400%365.25+1)
                    for i,v in pairs(mon) do
                        if v[2]-v[3]<=d then
                            mont = i
                        end
                    end
                    d = d + mon[mont][3]-mon[mont][2]
                    if m <= 9 then
                        m = "0" ..m
                    end
                    if s <= 9 then
                        s = "0" ..s
                    end
                    if h >= 12 then
                        mo = "P.M."
                    else
                        mo = "A.M."
                    end
                    if h > 12 then
                        h = h - 12
                    end
                    script.Parent.Text = "Daddyware | "  ..h.. ":" ..m.. ":" ..s.. " " ..mo.. " | " ..mon[mont][1].. " " ..d.. ", " ..y
                end
            end
    
            coroutine.wrap(UQHM_fake_script)()
            local function QQXIOK_fake_script() -- ScreenLabel.LocalScript 
                local script = Instance.new('LocalScript', ScreenLabel)
                
                local gui = script.Parent
                gui.Draggable = true
                gui.Active = true
            end
            coroutine.wrap(QQXIOK_fake_script)()
        elseif K == false then
            game.CoreGui.watermark:Destroy()
        end
    end})

	local PlayerEspEnemySection = VisualsColumn1:AddSection"Enemies"
	PlayerEspEnemySection:AddToggle({text = "Visible Only", flag = "Enemy Visible Only"})

	PlayerEspEnemySection:AddToggle({text = "Box", flag = "Enemy Box Enabled"}):AddColor({flag = "Enemy Occluded Box Color", color = Color3.fromRGB(245, 120, 65)}):AddColor({flag = "Enemy Box Color", color = Color3.fromRGB(240, 40, 50)})

	PlayerEspEnemySection:AddToggle({text = "Info", flag = "Enemy Info"}):AddColor({flag = "Enemy Occluded Info Color", color = Color3.fromRGB(255, 140, 30)}):AddColor({flag = "Enemy Info Color", color = Color3.fromRGB(240, 30, 40)})

	PlayerEspEnemySection:AddToggle({text = "Health", flag = "Enemy Health Enabled"})

	PlayerEspEnemySection:AddToggle({text = "Out Of View", flag = "Enemy OOV Arrows", callback = function(State)
		library.options["Enemy Out Of View Scale"].main.Visible = State
	end}):AddColor({flag = "Enemy Occluded OOV Arrows Color", color = Color3.fromRGB(255, 140, 30)}):AddColor({flag = "Enemy OOV Arrows Color", color = Color3.fromRGB(240, 30, 40)})
	PlayerEspEnemySection:AddSlider({text = "Scale", textpos = 2, flag = "Enemy Out Of View Scale", min = 100, max = 500})

	PlayerEspEnemySection:AddToggle({text = "Look Direction", flag = "Enemy Look Enabled"}):AddColor({flag = "Enemy Occluded Look Color", color = Color3.fromRGB(240, 120, 80)}):AddColor({flag = "Enemy Look Color", color = Color3.fromRGB(240, 60, 20)})

	--PlayerEspEnemySection:AddToggle({text = "Velocity", flag = "Enemy Direction Enabled"}):AddColor({flag = "Enemy Occluded Direction Color", color = Color3.fromRGB(240, 120, 80)}):AddColor({flag = "Enemy Direction Color", color = Color3.fromRGB(240, 60, 20)})

	PlayerEspEnemySection:AddToggle({text = "Chams", flag = "Enemy Chams Enabled"}):AddSlider({text = "Transparency", flag = "Enemy Chams Transparency", min = 0, max = 1, float = 0.1}):AddColor({flag = "Enemy Occluded Chams Color", color = Color3.fromRGB(245, 120, 65)}):AddColor({flag = "Enemy Chams Color", color = Color3.fromRGB(240, 40, 50)})
	PlayerEspEnemySection:AddToggle({text = "Outline", flag = "Enemy Chams Outline"}):AddColor({flag = "Enemy Occluded Chams Outline Color", color = Color3.fromRGB(245, 120, 65)}):AddColor({flag = "Enemy Chams Outline Color", color = Color3.fromRGB(240, 40, 50)})

	local PlayerEspTeamSection = VisualsColumn1:AddSection"Teammates"
	PlayerEspTeamSection:AddToggle({text = "Visible Only", flag = "Team Visible Only"})

	PlayerEspTeamSection:AddToggle({text = "Box", flag = "Team Box Enabled"}):AddColor({flag = "Team Occluded Box Color", color = Color3.fromRGB(20, 50, 255)}):AddColor({flag = "Team Box Color", color = Color3.fromRGB(40, 255, 180)})

	PlayerEspTeamSection:AddToggle({text = "Info", flag = "Team Info"}):AddColor({flag = "Team Occluded Info Color", color = Color3.fromRGB(20, 120, 255)}):AddColor({flag = "Team Info Color", color = Color3.fromRGB(40, 240, 130)})

	PlayerEspTeamSection:AddToggle({text = "Health", flag = "Team Health Enabled"})

	PlayerEspTeamSection:AddToggle({text = "Out Of View", flag = "Team OOV Arrows", callback = function(State)
		library.options["Team Out Of View Scale"].main.Visible = State
	end}):AddColor({flag = "Team Occluded OOV Arrows Color", color = Color3.fromRGB(20, 120, 255)}):AddColor({flag = "Team OOV Arrows Color", color = Color3.fromRGB(40, 240, 130)})
	PlayerEspTeamSection:AddSlider({text = "Scale", textpos = 2, flag = "Team Out Of View Scale", min = 100, max = 500})

	PlayerEspTeamSection:AddToggle({text = "Look Direction", flag = "Team Look Enabled"}):AddColor({flag = "Team Occluded Look Color", color = Color3.fromRGB(40, 80, 230)}):AddColor({flag = "Team Look Color", color = Color3.fromRGB(40, 250, 100)})

	--PlayerEspTeamSection:AddToggle({text = "Velocity", flag = "Team Direction Enabled"}):AddColor({flag = "Team Occluded Direction Color", color = Color3.fromRGB(240, 120, 80)}):AddColor({flag = "Team Direction Color", color = Color3.fromRGB(240, 60, 20)})

	PlayerEspTeamSection:AddToggle({text = "Chams", flag = "Team Chams Enabled"}):AddSlider({text = "Transparency", flag = "Team Chams Transparency", min = 0, max = 1, float = 0.1}):AddColor({flag = "Team Occluded Chams Color", color = Color3.fromRGB(20, 50, 255)}):AddColor({flag = "Team Chams Color", color = Color3.fromRGB(40, 255, 180)})
	PlayerEspTeamSection:AddToggle({text = "Outline", flag = "Team Chams Outline"}):AddColor({flag = "Team Occluded Chams Outline Color", color = Color3.fromRGB(80, 100, 255)}):AddColor({flag = "Team Chams Outline Color", color = Color3.fromRGB(80, 255, 200)})