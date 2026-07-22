local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Indicators = addon.Frames.Widgets.Indicators or {}
addon.Frames.Widgets.Indicators.Combat = addon.Frames.Widgets.Indicators.Combat or {}

local Combat = addon.Frames.Widgets.Indicators.Combat
local PP = addon.PixelPerfect
local settingsCache = {}

local function UpdateSettingsCache(frame)
	local settings = addon.Database:GetProfile().frames[frame.settingsUnit]
	local combatIndicator = settings.combatIndicator or {}
	local position = combatIndicator.position or {}
	settingsCache[frame.settingsUnit] = {
		enabled = combatIndicator.enabled,
		anchor = combatIndicator.anchor or "CENTER",
		size = combatIndicator.size or 16,
		position = {
			x = position.x or 0,
			y = position.y or 0,
		},
	}
end

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

	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.combatIndicator:Hide()
		return
	end

	local anchor = cachedSettings.anchor
	local position = cachedSettings.position
	local size = PP:ToUIScaled(cachedSettings.size)
	frame.combatIndicator:SetSize(size, size)
	frame.combatIndicator:ClearAllPoints()
	frame.combatIndicator:SetPoint(
		anchor,
		frame,
		anchor,
		PP:ToUIScaled(position.x),
		PP:ToUIScaled(position.y)
	)
	self:UpdateState(frame)
end

function Combat:UpdateState(frame)
	if frame.unit ~= "player" or not frame.combatIndicator then
		return
	end

	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.combatIndicator:Hide()
		return
	end

	frame.combatIndicator:SetShown(addon.EventHandler:IsCombatActive())
end
