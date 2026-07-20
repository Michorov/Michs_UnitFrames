local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Texts = addon.Frames.Widgets.Texts or {}
addon.Frames.Widgets.Texts.Health = addon.Frames.Widgets.Texts.Health or {}

local Health = addon.Frames.Widgets.Texts.Health
local PP = addon.PixelPerfect

function Health:Ensure(frame, settings)
	if not frame.healthText then
		local healthText = CreateFrame("Frame", nil, frame)
		healthText:SetAllPoints(frame)
		healthText:SetFrameLevel(31)
		healthText.text = healthText:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

		frame.healthText = healthText
	end

	self:UpdateSettings(frame, settings)
end

function Health:UpdateSettings(frame, settings)
	local text = frame.healthText.text
	local healthTextSettings = (settings and settings.healthText) or {}
	frame.healthText.enabled = healthTextSettings.enabled ~= false
	local anchor = healthTextSettings.anchor or "RIGHT"
	local position = healthTextSettings.position or {}

	text:ClearAllPoints()
	text:SetPoint(
		anchor,
		frame.healthText,
		anchor,
		PP:ToUIScaled(position.x or 0),
		PP:ToUIScaled(position.y or 0)
	)
	addon.Style.Fonts:SetFont(text, healthTextSettings.font, PP:ScaleFont(12), "")
	text:SetShadowColor(0, 0, 0, 0.9)
	text:SetShadowOffset(1, -1)
	text:SetTextColor(1, 1, 1, 1)

	self:UpdateState(frame, settings)
end

function Health:UpdateState(frame, settings)
	if not frame.healthText.enabled or not frame.unit or not UnitExists(frame.unit) then
		frame.healthText:Hide()
		return
	end

	frame.healthText.text:SetText(AbbreviateNumbers(UnitHealth(frame.unit)))
	frame.healthText:Show()
end
