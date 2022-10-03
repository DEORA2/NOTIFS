--custom notification thing, library required for this to work
local LastNotification = 0
function library:SendNotification(duration, message)
	LastNotification = LastNotification + tick()
	if LastNotification < 0.2 or not library.base then return end
	LastNotification = 0
	if duration then
		duration = tonumber(duration) or 2
		duration = duration < 2 and 2 or duration
	else
		duration = message
	end
	message = message and tostring(message) or "Empty"

	--create the thing
	local notification = library:Create("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Size = UDim2.new(0, 0, 0, 80),
		Position = UDim2.new(1, -5, 1, -5),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderColor3 = Color3.fromRGB(20, 20, 20),
		Parent = library.base
	})
	tweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 240, 0, 80), BackgroundTransparency = 0}):Play()

	tweenService:Create(library:Create("TextLabel", {
		Position = UDim2.new(0, 5, 0, 25),
		Size = UDim2.new(1, -10, 0, 40),
		BackgroundTransparency = 1,
		Text = tostring(message),
		Font = Enum.Font.SourceSans,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 18,
		TextTransparency = 1,
		TextWrapped = true,
		Parent = notification
	}), TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.3), {TextTransparency = 0}):Play()

	--bump existing notifications
	for _,notification in next, library.notifications do
		notification:TweenPosition(UDim2.new(1, -5, 1, notification.Position.Y.Offset - 85), "Out", "Quad", 0.2)
	end
	library.notifications[notification] = notification

	wait(0.4)

	--create other things
	library:Create("Frame", {
		Position = UDim2.new(0, 0, 0, 20),
		Size = UDim2.new(0, 0, 0, 1),
		BackgroundColor3 = library.flags["Menu Accent Color"],
		BorderSizePixel = 0,
		Parent = notification
	}):TweenSize(UDim2.new(1, 0, 0, 1), "Out", "Linear", duration)

	tweenService:Create(library:Create("TextLabel", {
		Position = UDim2.new(0, 4, 0, 0),
		Size = UDim2.new(0, 70, 0, 16),
		BackgroundTransparency = 1,
		Text = "Daddyware",
		Font = Enum.Font.Gotham,
		TextColor3 = library.flags["Menu Accent Color"],
		TextSize = 16,
		TextTransparency = 1,
		Parent = notification
	}), TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

	--remove
	delay(duration, function()
		if not library then return end
		library.notifications[notification] = nil
		--bump existing notifications down
		for _,otherNotif in next, library.notifications do
			if otherNotif.Position.Y.Offset < notification.Position.Y.Offset then
				otherNotif:TweenPosition(UDim2.new(1, -5, 1, otherNotif.Position.Y.Offset + 85), "Out", "Quad", 0.2)
			end
		end
		notification:Destroy()
	end)
end