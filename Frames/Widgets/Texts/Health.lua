local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Texts = addon.Frames.Widgets.Texts or {}
addon.Frames.Widgets.Texts.Health = addon.Frames.Widgets.Texts.Health or {}

local Health = addon.Frames.Widgets.Texts.Health
local PP = addon.PixelPerfect

local function UpdateColor(frame, settings)
	local healthTextSettings = (settings and settings.healthText) or {}
	local color = healthTextSettings.color or {}
	local r = color.r or 1
	local g = color.g or 1
	local b = color.b or 1
	local a = color.a or 1

	if healthTextSettings.colorByClassOrReaction then
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
	addon.Style.Fonts:SetFont(
		text,
		healthTextSettings.font,
		PP:ScaleFont(healthTextSettings.size or 12),
		healthTextSettings.outline
	)
	text:SetShadowColor(0, 0, 0, 0.9)
	text:SetShadowOffset(1, -1)

	self:UpdateState(frame, settings)
end

function Health:UpdateState(frame, settings)
	if not frame.healthText.enabled or not frame.unit or not UnitExists(frame.unit) then
		frame.healthText:Hide()
		return
	end

	local health = UnitHealth(frame.unit)
	local abbreviated = AbbreviateNumbers(health)
	local full = BreakUpLargeNumbers(health)
	local percent = string.format(
		"%.0f%%",
		UnitHealthPercent(frame.unit, false, CurveConstants.ScaleTo100)
	)
	local format = ((settings and settings.healthText) or {}).format or "abbreviated"
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

	frame.healthText.text:SetText(text)
	UpdateColor(frame, settings)
	frame.healthText:Show()
end
