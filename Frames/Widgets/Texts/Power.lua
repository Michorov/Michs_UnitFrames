local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Texts = addon.Frames.Widgets.Texts or {}
addon.Frames.Widgets.Texts.Power = addon.Frames.Widgets.Texts.Power or {}

local Power = addon.Frames.Widgets.Texts.Power
local PP = addon.PixelPerfect
local LSM = LibStub("LibSharedMedia-3.0")

local function UpdateColor(frame)
	local powerType, powerToken, r, g, b = UnitPowerType(frame.unit)
	local color = PowerBarColor[powerToken] or PowerBarColor[powerType]

	if color then
		r = color.r
		g = color.g
		b = color.b
	end

	frame.powerText.text:SetTextColor(r or 1, g or 1, b or 1, 1)
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

	self:UpdateState(frame)
end

function Power:UpdateState(frame)
	if not frame.powerText.enabled or not frame.unit or not UnitExists(frame.unit) then
		frame.powerText:Hide()
		return
	end

	frame.powerText.text:SetText(UnitPower(frame.unit))
	UpdateColor(frame)
	frame.powerText:Show()
end
