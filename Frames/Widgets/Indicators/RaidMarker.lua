local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Indicators = addon.Frames.Widgets.Indicators or {}
addon.Frames.Widgets.Indicators.RaidMarker = addon.Frames.Widgets.Indicators.RaidMarker or {}

local RaidMarker = addon.Frames.Widgets.Indicators.RaidMarker
local PP = addon.PixelPerfect
local settingsCache = {}

local function UpdateSettingsCache(frame)
	local settings = addon.Database:GetProfile().frames[frame.settingsUnit]
	local raidMarker = settings.raidMarker or {}
	local position = raidMarker.position or {}
	settingsCache[frame.settingsUnit] = {
		enabled = raidMarker.enabled,
		anchor = raidMarker.anchor,
		size = raidMarker.size,
		position = {
			x = position.x,
			y = position.y,
		},
	}
end

function RaidMarker:Ensure(frame)
	if not frame.raidMarker then
		local indicator = CreateFrame("Frame", nil, frame)
		indicator:SetFrameLevel(35)
		indicator:Hide()

		indicator.texture = indicator:CreateTexture(nil, "OVERLAY")
		indicator.texture:SetAllPoints(indicator)
		indicator.texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")

		frame.raidMarker = indicator
	end

	self:UpdateSettings(frame)
end

function RaidMarker:UpdateSettings(frame)
	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.raidMarker:Hide()
		return
	end

	local anchor = cachedSettings.anchor
	local position = cachedSettings.position
	local size = PP:ToUIScaled(cachedSettings.size)
	frame.raidMarker:SetSize(size, size)
	frame.raidMarker:ClearAllPoints()
	frame.raidMarker:SetPoint(anchor, frame, anchor, PP:ToUIScaled(position.x), PP:ToUIScaled(position.y))
	self:UpdateState(frame)
end

function RaidMarker:UpdateState(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false or not frame.unit or not UnitExists(frame.unit) then
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
