local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Texts = addon.Frames.Widgets.Texts or {}
addon.Frames.Widgets.Texts.Power = addon.Frames.Widgets.Texts.Power or {}

local Power = addon.Frames.Widgets.Texts.Power
local PP = addon.PixelPerfect
local LSM = LibStub("LibSharedMedia-3.0")
local settingsCache = {}
local generalSettings

local function FormatPercent(unit)
	return string.format("%.0f%%", UnitPowerPercent(unit, nil, true, CurveConstants.ScaleTo100))
end

local formatters = {
	abbreviated = function(unit)
		return AbbreviateNumbers(UnitPower(unit))
	end,
	percent = FormatPercent,
	full = function(unit)
		return BreakUpLargeNumbers(UnitPower(unit))
	end,
	abbreviatedPercent = function(unit)
		return AbbreviateNumbers(UnitPower(unit)) .. " | " .. FormatPercent(unit)
	end,
	percentAbbreviated = function(unit)
		return FormatPercent(unit) .. " | " .. AbbreviateNumbers(UnitPower(unit))
	end,
	fullPercent = function(unit)
		return BreakUpLargeNumbers(UnitPower(unit)) .. " | " .. FormatPercent(unit)
	end,
	percentFull = function(unit)
		return FormatPercent(unit) .. " | " .. BreakUpLargeNumbers(UnitPower(unit))
	end,
}

local function UpdateSettingsCache(frame)
	local profile = addon.Database:GetProfile()
	local settings = profile.frames[frame.settingsUnit].powerText or {}
	local position = settings.position or {}
	local color = settings.color or {}
	settingsCache[frame.settingsUnit] = {
		enabled = settings.enabled,
		format = settings.format,
		anchor = settings.anchor or "BOTTOMRIGHT",
		font = settings.font,
		outline = settings.outline or "",
		size = settings.size or 12,
		colorByPowerType = settings.colorByPowerType ~= false,
		position = {
			x = position.x or 0,
			y = position.y or 0,
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

	if cachedSettings.colorByPowerType then
		local powerType, powerToken, typeR, typeG, typeB = UnitPowerType(frame.unit)
		local powerColor = PowerBarColor[powerToken] or PowerBarColor[powerType]

		if powerColor then
			r = powerColor.r
			g = powerColor.g
			b = powerColor.b
		else
			r = typeR or r
			g = typeG or g
			b = typeB or b
		end
	end

	frame.powerText.text:SetTextColor(r, g, b, a)
end

function Power:Ensure(frame)
	if not frame.powerText then
		local powerText = CreateFrame("Frame", nil, frame)
		powerText:SetAllPoints(frame)
		powerText:SetFrameLevel(32)
		powerText.text = powerText:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

		frame.powerText = powerText
	end

	self:UpdateSettings(frame)
end

function Power:UpdateSettings(frame)
	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.powerText:Hide()
		return
	end

	local text = frame.powerText.text
	local anchor = cachedSettings.anchor
	local position = cachedSettings.position
	local font = cachedSettings.font
	if font == -1 or not font then
		font = generalSettings.font
	end

	text:ClearAllPoints()
	text:SetPoint(anchor, frame.powerText, anchor, PP:ToUIScaled(position.x), PP:ToUIScaled(position.y))
	text:SetFont(LSM:Fetch("font", font), PP:ScaleFont(cachedSettings.size), cachedSettings.outline)
	text:SetShadowColor(0, 0, 0, 0.9)
	text:SetShadowOffset(1, -1)

	self:UpdateState(frame)
end

function Power:UpdateState(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false or not frame.unit or not UnitExists(frame.unit) then
		frame.powerText:Hide()
		return
	end

	local formatter = formatters[cachedSettings.format] or formatters.abbreviated
	frame.powerText.text:SetText(formatter(frame.unit))
	UpdateColor(frame)
	frame.powerText:Show()
end

function Power:UpdateValue(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false or not frame.unit or not UnitExists(frame.unit) then
		frame.powerText:Hide()
		return
	end

	local formatter = formatters[cachedSettings.format] or formatters.abbreviated
	frame.powerText.text:SetText(formatter(frame.unit))
end

function Power:UpdateMaximum(frame)
	self:UpdateValue(frame)
end
