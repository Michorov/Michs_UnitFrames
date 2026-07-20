local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Background = addon.Frames.Widgets.Background or {}

local Background = addon.Frames.Widgets.Background

function Background:UpdateColor(frame, settings)
	local backgroundSettings = (settings and settings.background) or {}
	local color = backgroundSettings.color or {}
	local r = color.r or 0.12
	local g = color.g or 0.12
	local b = color.b or 0.12
	local a = color.a or 1

	if backgroundSettings.colorByClassOrReaction then
		if UnitIsPlayer(frame.unit) then
			local _, class = UnitClass(frame.unit)
			local classColor = class and RAID_CLASS_COLORS[class]
			if classColor then
				r = classColor.r
				g = classColor.g
				b = classColor.b
			end
		else
			local reaction = UnitReaction(frame.unit, "player")
			local reactionColor = reaction and FACTION_BAR_COLORS[reaction]
			if reactionColor then
				r = reactionColor.r
				g = reactionColor.g
				b = reactionColor.b
			end
		end
	end

	frame.background:SetColorTexture(r, g, b, a)
end

function Background:Ensure(frame, settings)
	if not frame.background then
		local background = frame:CreateTexture(nil, "BACKGROUND")
		background:SetAllPoints(frame)
		frame.background = background
	end

	self:UpdateSettings(frame, settings)
end

function Background:UpdateSettings(frame, settings)
	self:UpdateColor(frame, settings)
end
