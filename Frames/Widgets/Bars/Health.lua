local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Bars = addon.Frames.Widgets.Bars or {}
addon.Frames.Widgets.Bars.Health = addon.Frames.Widgets.Bars.Health or {}

local Health = addon.Frames.Widgets.Bars.Health
local LSM = LibStub("LibSharedMedia-3.0")
local settingsCache = {}
local generalSettings

local function UpdateSettingsCache(frame)
	local profile = addon.Database:GetProfile()
	settingsCache[frame.settingsUnit] = profile.frames[frame.settingsUnit].health or {}
	generalSettings = profile.general
end

function Health:Ensure(frame)
	if not frame.healthBar then
		local healthBar = CreateFrame("StatusBar", nil, frame)
		healthBar:SetAllPoints(frame)
		healthBar:SetMinMaxValues(0, 1)
		healthBar:SetValue(0)
		frame.healthBar = healthBar
	end

	self:UpdateSettings(frame)
end

function Health:UpdateSettings(frame)
	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	local texture = cachedSettings.texture
	if texture == -1 then
		texture = generalSettings.texture
	end
	texture = texture or "Solid"

	if not LSM:IsValid("statusbar", texture) then
		texture = "Solid"
	end

	frame.healthBar:SetStatusBarTexture(LSM:Fetch("statusbar", texture))
	self:UpdateState(frame)
end

function Health:UpdateColor(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]
	local color = cachedSettings.color or {}
	local r = color.r or 0.12
	local g = color.g or 0.12
	local b = color.b or 0.12
	local a = color.a or 1

	if cachedSettings.colorByClassOrReaction then
		if UnitIsPlayer(frame.unit) then
			r, g, b = addon.Style.Colors:GetUnitClassBackgroundColor(frame.unit)
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

	frame.healthBar:SetStatusBarColor(r, g, b, a)
end

function Health:UpdateState(frame)
	local unit = frame.unit
	if not unit then
		return
	end

	local currentHealth = UnitHealth(unit)
	local maximumHealth = UnitHealthMax(unit)

	frame.healthBar:SetMinMaxValues(0, maximumHealth)
	frame.healthBar:SetValue(currentHealth)
	self:UpdateColor(frame)
end
