local OldCallingScript
OldCallingScript = hookfunction(getcallingscript, function()
	return OldCallingScript() or {}
end)

local Old_new
Old_new = hookmetamethod(game, "__newindex", function(t, i, v)
	if checkcaller() or not library then return Old_new(t, i, v) end

	if t == Camera then
		if i == "CFrame" then
			--CameraCF = v
			if library.flags["Freecam Enabled"] and library.flags["Freecam Key"] then
				--v = CFrame.new(FreecamPos, CameraCF.LookVector)
			else
				if library.flags["Aimbot Mode"] == "Rage" then
					if library.Aimbot.Position3d then
						v = CFrame.new(v.p, library.Aimbot.Position3d)
					end
				end
			end
		end
	end

	if GameTitle == "Counter Blox" then
		if i == "WalkSpeed" then
			if library.flags[GameTitle .. " Bhop"] and not inputService:GetFocusedTextBox() then
				if inputService:IsKeyDown(Enum.KeyCode.Space) then
					v = library.flags[GameTitle .. " Bhop Speed"]
				end
			end
		end
	end

	if t == Lighting then
		if i == "ClockTime" then
			LightingSpoof[i] = v
			v = library.flags["ClockTime"] and library.flags["Clock Time Amount"] or v
		elseif i == "Brightness" then
			LightingSpoof[i] = v
			v = library.flags["Brightness"] and library.flags["Brightness Amount"] or v
		elseif i == "Ambient" or i == "OutdoorAmbient" then
			LightingSpoof[i] = v
			v = library.flags["Ambient Lighting"] and (i == "Ambient" and library.flags["Indoor Ambient"] or library.flags["Outdoor Ambient"]) or v
		elseif i == "ColorShift_Top" then
			LightingSpoof[i] = v
			v = library.flags["Color Shift"] and library.flags["Color Shift Top"] or v
		end
	elseif t == Camera then
		if i == "FieldOfView" then
			CameraSpoof[i] = v
			v = (library.flags["FOV Zoom Enabled"] and library.flags["FOV Zoom Key"] and (50 - library.flags["FOV Zoom Amount"])) or library.flags["FOV Changer"] and (library.flags["Dynamic Custom FOV"] and (CameraSpoof.FieldOfView + library.flags["FOV Amount"]) or library.flags["FOV Amount"]) or v
		end
	end

	return Old_new(t, i, v)
end)

local Old_index
Old_index = hookmetamethod(game, "__index", function(t, i)
	if checkcaller() or not library then return Old_index(t, i) end

	if t == Camera then
		if i == "CFrame" then
			if library.flags["Freecam Enabled"] and library.flags["Freecam Key"] then
				--return CameraCF
			end
			if library.Aimbot.Position3d then
				if library.flags["Aimbot Mode"] == "Silent" then
					if GameTitle == "Bad Business" then
						if OldCallingScript().Name == "ItemControlScript" then
							local OldCF = Old_index(t, i)
							return CFrame.new(OldCF.Position, library.Aimbot.Position3d)
						end
					end
				elseif library.flags["Aimbot Mode"] == "Rage" then
					return CFrame.new(Old_index(t, i).Position, library.Aimbot.Position3d)
				end
			end
		elseif i == "CameraSubject" then
			--return CameraSubject
		elseif i == "CameraType" then
			--return CameraType
		end
	end

	if t == Lighting then
		if i == "ClockTime" or i == "Brightness" or i == "Ambient" or i == "OutdoorAmbient" or i == "ColorShift_Top" then
			return LightingSpoof[i]
		end
	elseif t == Camera then
		if i == "FieldOfView" then
			return CameraSpoof[i]
		end
	end

	return Old_index(t, i)
end)
    
local Old_call
Old_call= hookmetamethod(game, "__namecall", function(self, ...)
	if checkcaller() or not library then return Old_call(self, ...) end

	local Args = {...}
	local Method = getnamecallmethod()

	if Method == "FindPartOnRayWithWhitelist" then
	elseif Method == "FindPartOnRayWithIgnoreList" then
		if GameTitle == "Counter Blox" then
			if #Args[2] > 10 then
				if library.flags[GameTitle .. " No Spread"] then
					local Char = Players[Client].Character
					if Char then
					    Args[1] = Ray.new(LocalPlayer.Character.Head.Position, (SilentRagebot.target.Position - LocalPlayer.Character.Head.Position).unit * (WeaponsData[LocalPlayer.Character.EquippedTool.Value].Range.Value * 0.1))
						Args[1] = Ray.new(Vector3.new(Char.HumanoidRootPart.Position.X, Char.Head.Position.Y, Char.HumanoidRootPart.Position.Z), Camera.CFrame.LookVector * 1000)
					end
				end
				if library.flags[GameTitle .. " Wallbang"] then
					Args[2][#Args[2] + 1] = workspace.Map
				end
				if library.flags["Aimbot Mode"] == "Silent" and library.Aimbot.Position3d then
					local Char = Players[Client].Character
					if Char then
						local Origin = Vector3.new(Char.HumanoidRootPart.Position.X, Char.Head.Position.Y, Char.HumanoidRootPart.Position.Z)
						Args[1] = Ray.new(Origin, (library.Aimbot.Position3d - Origin).Unit * 1000)
					end
				end
			end
		end

	elseif Method == "FireServer" then
		if GameTitle == "Counter Blox" then
		    if self.Name == "ReplicateCamera" and library.flags[GameTitle .. " anti spectate"] then      
		        args[1] = CF()		
			end
		elseif GameTitle == "Death Zone" then
			if self.Name == "Executioner" then
				return wait(9e9)
			end
		end

	elseif Method == "InvokeServer" then

	elseif Method == "SetPrimaryPartCFrame" then
		if GameTitle == "Counter Blox" then
			if self.Name == "Arms" then
				if library.flags[GameTitle .. " Viewmodel Changer"] then
					if library.flags[GameTitle .. " Flip Z"] then
						Args[1] = Args[1] * CFrame.new(1, 1, 1, 0, 0, 1, 0)
					end
					if library.flags[GameTitle .. " Flip Y"] then
						Args[1] = Args[1] * CFrame.new(1, 1, 1, 0.5, 0, 0, 0)
					end
					local X = library.flags[GameTitle .. " X Offset"] * 120 / 500
					local Y = library.flags[GameTitle .. " Y Offset"] * 120 / 500
					local dl = library.flags[GameTitle .. " Z Offset"] * 120 / 500
					Args[1] = Args[1] * CFrame.new(X, Y, library.flags[GameTitle .. " Flip Y"] and dl * 2 or dl)
				end
			end
		end
	end

	return Old_call(self, unpack(Args))
end)