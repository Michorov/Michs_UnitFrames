local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Indicators = addon.Frames.Widgets.Indicators or {}
addon.Frames.Widgets.Indicators.RaidMarker = addon.Frames.Widgets.Indicators.RaidMarker or {}

local RaidMarker = addon.Frames.Widgets.Indicators.RaidMarker
local PP = addon.PixelPerfect

function RaidMarker:Ensure(frame, settings)
	if not frame.raidMarker then
		local indicator = CreateFrame("Frame", nil, frame)
		indicator:SetFrameLevel(35)
		indicator:Hide()

		indicator.texture = indicator:CreateTexture(nil, "OVERLAY")
		indicator.texture:SetAllPoints(indicator)
		indicator.texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")

		frame.raidMarker = indicator
	end

	self:UpdateSettings(frame, settings)
end

function RaidMarker:UpdateSettings(frame, settings)
	local raidMarkerSettings = (settings and settings.raidMarker) or {}
	local anchor = raidMarkerSettings.anchor or "TOP"
	local position = raidMarkerSettings.position or {}
	local size = PP:ToUIScaled(raidMarkerSettings.size or 16)
	frame.raidMarker.enabled = raidMarkerSettings.enabled ~= false
	frame.raidMarker:SetSize(size, size)
	frame.raidMarker:ClearAllPoints()
	frame.raidMarker:SetPoint(
		anchor,
		frame,
		anchor,
		PP:ToUIScaled(position.x or 0),
		PP:ToUIScaled(position.y or 0)
	)
	self:UpdateState(frame)
end

function RaidMarker:UpdateState(frame)
	if not frame.raidMarker.enabled or not frame.unit or not UnitExists(frame.unit) then
		frame.raidMarker:Hide()
		return
	end

	local raidTargetIndex = GetRaidTargetIndex(frame.unit)
	if not raidTargetIndex or not frame.raidMarker.texture.SetSpriteSheetCell then
		frame.raidMarker:Hide()
		return
	end

	frame.raidMarker.texture:SetSpriteSheetCell(raidTargetIndex, 4, 4, 64, 64)
	frame.raidMarker:Show()
end
