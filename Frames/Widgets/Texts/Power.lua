local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Texts = addon.Frames.Widgets.Texts or {}
addon.Frames.Widgets.Texts.Power = addon.Frames.Widgets.Texts.Power or {}

local Power = addon.Frames.Widgets.Texts.Power
local PP = addon.PixelPerfect
local LSM = LibStub("LibSharedMedia-3.0")

local function UpdateColor(frame, settings)
	local powerTextSettings = (settings and settings.powerText) or {}
	local color = powerTextSettings.color or {}
	local r = color.r or 1
	local g = color.g or 1
	local b = color.b or 1
	local a = color.a or 1

	if powerTextSettings.colorByPowerType ~= false then
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

function Power:Ensure(frame, settings)
	if not frame.powerText then
		local powerText = CreateFrame("Frame", nil, frame)
		powerText:SetAllPoints(frame)
		powerText:SetFrameLevel(32)
		powerText.text = powerText:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

		frame.powerText = powerText
	end

	self:UpdateSettings(frame, settings)
end

function Power:UpdateSettings(frame, settings)
	local text = frame.powerText.text
	local powerTextSettings = (settings and settings.powerText) or {}
	local anchor = powerTextSettings.anchor or "BOTTOMRIGHT"
	local position = powerTextSettings.position or {}
	local font = powerTextSettings.font
	frame.powerText.enabled = powerTextSettings.enabled ~= false

	if font == -1 or not font then
		font = addon.Database:GetProfile().general.font
	end

	text:ClearAllPoints()
	text:SetPoint(
		anchor,
		frame.powerText,
		anchor,
		PP:ToUIScaled(position.x or 0),
		PP:ToUIScaled(position.y or 0)
	)
	text:SetFont(
		LSM:Fetch("font", font),
		PP:ScaleFont(powerTextSettings.size or 12),
		powerTextSettings.outline or ""
	)
	text:SetShadowColor(0, 0, 0, 0.9)
	text:SetShadowOffset(1, -1)

	self:UpdateState(frame, settings)
end

function Power:UpdateState(frame, settings)
	if not frame.powerText.enabled or not frame.unit or not UnitExists(frame.unit) then
		frame.powerText:Hide()
		return
	end

	local power = UnitPower(frame.unit)
	local abbreviated = AbbreviateNumbers(power)
	local full = BreakUpLargeNumbers(power)
	local percent = string.format(
		"%.0f%%",
		UnitPowerPercent(frame.unit, nil, true, CurveConstants.ScaleTo100)
	)
	local format = ((settings and settings.powerText) or {}).format or "abbreviated"
	local text

	if format == "percent" then
		text = percent
	elseif format == "full" then
		text = full
	elseif format == "abbreviatedPercent" then
		text = abbreviated .. " | " .. percent
	elseif format == "percentAbbreviated" then
		text = percent .. " | " .. abbreviated
	elseif format == "fullPercent" then
		text = full .. " | " .. percent
	elseif format == "percentFull" then
		text = percent .. " | " .. full
	else
		text = abbreviated
	end

	frame.powerText.text:SetText(text)
	UpdateColor(frame, settings)
	frame.powerText:Show()
end
