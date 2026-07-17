local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Background = addon.Frames.Widgets.Background or {}

local Background = addon.Frames.Widgets.Background

function Background:Ensure(frame)
	if not frame.background then
		local background = frame:CreateTexture(nil, "BACKGROUND")
		background:SetAllPoints(frame)
		frame.background = background
	end

	self:UpdateSettings(frame)
end

function Background:UpdateSettings(frame, settings)
	local backgroundSettings = (settings and settings.background) or {}
	local color = backgroundSettings.color or {}

	frame.background:SetColorTexture(
		color.r or 0.12,
		color.g or 0.12,
		color.b or 0.12,
		color.a or 1
	)
end
