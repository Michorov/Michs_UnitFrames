local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Indicators = addon.Frames.Widgets.Indicators or {}
addon.Frames.Widgets.Indicators.Combat = addon.Frames.Widgets.Indicators.Combat or {}

local Combat = addon.Frames.Widgets.Indicators.Combat
local PP = addon.PixelPerfect

function Combat:Ensure(frame)
	if frame.unit ~= "player" then
		return
	end

	if not frame.combatIndicator then
		local indicator = CreateFrame("Frame", nil, frame)
		indicator:SetFrameLevel(35)
		indicator:Hide()

		indicator.texture = indicator:CreateTexture(nil, "OVERLAY")
		indicator.texture:SetAllPoints(indicator)
		indicator.texture:SetAtlas("UI-HUD-UnitFrame-Player-CombatIcon", false)

		frame.combatIndicator = indicator
	end

	self:UpdateSettings(frame)
end

function Combat:UpdateSettings(frame)
	if frame.unit ~= "player" or not frame.combatIndicator then
		return
	end

	frame.combatIndicator:SetSize(PP:ToUIScaled(16), PP:ToUIScaled(16))
	PP:CenterElement(frame.combatIndicator, frame, 0, 0)
	self:UpdateState(frame)
end

function Combat:UpdateState(frame)
	if frame.unit ~= "player" or not frame.combatIndicator then
		return
	end

	frame.combatIndicator:SetShown(addon.EventHandler:IsCombatActive())
end
