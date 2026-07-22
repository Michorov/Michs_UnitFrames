local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Texts = addon.Frames.Widgets.Texts or {}
addon.Frames.Widgets.Texts.Health = addon.Frames.Widgets.Texts.Health or {}

local Health = addon.Frames.Widgets.Texts.Health
local PP = addon.PixelPerfect
local LSM = LibStub("LibSharedMedia-3.0")
local settingsCache = {}
local generalSettings

local function FormatPercent(unit)
	return string.format("%.0f%%", UnitHealthPercent(unit, false, CurveConstants.ScaleTo100))
end

local formatters = {
	abbreviated = function(unit)
		return AbbreviateNumbers(UnitHealth(unit))
	end,
	percent = FormatPercent,
	full = function(unit)
		return BreakUpLargeNumbers(UnitHealth(unit))
	end,
	abbreviatedPercent = function(unit)
		return AbbreviateNumbers(UnitHealth(unit)) .. " | " .. FormatPercent(unit)
	end,
	percentAbbreviated = function(unit)
		return FormatPercent(unit) .. " | " .. AbbreviateNumbers(UnitHealth(unit))
	end,
	fullPercent = function(unit)
		return BreakUpLargeNumbers(UnitHealth(unit)) .. " | " .. FormatPercent(unit)
	end,
	percentFull = function(unit)
		return FormatPercent(unit) .. " | " .. BreakUpLargeNumbers(UnitHealth(unit))
	end,
}

local function UpdateSettingsCache(frame)
	local profile = addon.Database:GetProfile()
	local settings = profile.frames[frame.settingsUnit].healthText or {}
	local position = settings.position or {}
	local color = settings.color or {}
	settingsCache[frame.settingsUnit] = {
		enabled = settings.enabled,
		format = settings.format,
		anchor = settings.anchor,
		font = settings.font,
		outline = settings.outline,
		size = settings.size,
		colorByClassOrReaction = settings.colorByClassOrReaction == true,
		position = {
			x = position.x,
			y = position.y,
		},
		color = {
			r = color.r or 1,
			g = color.g or 1,
			b = color.b or 1,
			a = color.a or 1,
		},
	}
	generalSettings = {
		font = profile.general.font,
	}
end

local function UpdateColor(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	local color = cachedSettings.color
	local r = color.r
	local g = color.g
	local b = color.b
	local a = color.a

	if cachedSettings.colorByClassOrReaction then
		if UnitIsPlayer(frame.unit) then
			r, g, b, a = addon.Style.Colors:GetUnitClassTextColor(frame.unit, color)
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

	frame.healthText.text:SetTextColor(r, g, b, a)
end

function Health:Ensure(frame)
	if not frame.healthText then
		local healthText = CreateFrame("Frame", nil, frame)
		healthText:SetAllPoints(frame)
		healthText:SetFrameLevel(31)
		healthText.text = healthText:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

		frame.healthText = healthText
	end

	self:UpdateSettings(frame)
end

function Health:UpdateSettings(frame)
	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.healthText:Hide()
		return
	end

	local text = frame.healthText.text
	local anchor = cachedSettings.anchor
	local position = cachedSettings.position
	local font = cachedSettings.font
	if font == -1 then
		font = generalSettings.font
	end

	text:ClearAllPoints()
	text:SetPoint(anchor, frame.healthText, anchor, PP:ToUIScaled(position.x), PP:ToUIScaled(position.y))
	text:SetFont(LSM:Fetch("font", font), PP:ScaleFont(cachedSettings.size), cachedSettings.outline)
	text:SetShadowColor(0, 0, 0, 0.9)
	text:SetShadowOffset(1, -1)

	self:UpdateState(frame)
end

function Health:UpdateState(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false or not frame.unit or not UnitExists(frame.unit) then
		frame.healthText:Hide()
		return
	end

	local formatter = formatters[cachedSettings.format] or formatters.abbreviated
	frame.healthText.text:SetText(formatter(frame.unit))
	UpdateColor(frame)
	frame.healthText:Show()
end
