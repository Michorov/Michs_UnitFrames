local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Texts = addon.Frames.Widgets.Texts or {}
addon.Frames.Widgets.Texts.Name = addon.Frames.Widgets.Texts.Name or {}

local Name = addon.Frames.Widgets.Texts.Name
local PP = addon.PixelPerfect

local function UpdateColor(frame, settings)
	local nameTextSettings = (settings and settings.nameText) or {}
	local color = nameTextSettings.color or {}
	local r = color.r or 1
	local g = color.g or 1
	local b = color.b or 1
	local a = color.a or 1

	if nameTextSettings.colorByClassOrReaction then
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

	frame.nameText.text:SetTextColor(r, g, b, a)
end

function Name:Ensure(frame, settings)
	if not frame.nameText then
		local nameFrame = CreateFrame("Frame", nil, frame)
		nameFrame:SetAllPoints(frame)
		nameFrame:SetFrameLevel(30)
		nameFrame.text = nameFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

		frame.nameText = nameFrame
	end

	self:UpdateSettings(frame, settings)
end

function Name:UpdateSettings(frame, settings)
	local nameText = frame.nameText.text
	local nameTextSettings = (settings and settings.nameText) or {}
	frame.nameText.enabled = nameTextSettings.enabled ~= false
	local anchor = nameTextSettings.anchor or "LEFT"
	local position = nameTextSettings.position or {}

	nameText:ClearAllPoints()
	nameText:SetPoint(
		anchor,
		frame.nameText,
		anchor,
		PP:ToUIScaled(position.x or 0),
		PP:ToUIScaled(position.y or 0)
	)

	addon.Style.Fonts:SetFont(
		nameText,
		nameTextSettings.font,
		PP:ScaleFont(nameTextSettings.size or 12),
		nameTextSettings.outline
	)
	nameText:SetShadowColor(0, 0, 0, 0.9)
	nameText:SetShadowOffset(1, -1)

	self:UpdateState(frame, settings)
end

function Name:UpdateState(frame, settings)
	local unit = frame.unit
	if not frame.nameText.enabled or not unit or not UnitExists(unit) then
		frame.nameText:Hide()
		return
	end

	local name = UnitName(unit) or ""
	local nameTextSettings = (settings and settings.nameText) or {}
	if nameTextSettings.truncate then
		local maxLength = nameTextSettings.maxLength or 12
		if maxLength > 0 and #name > maxLength then
			name = name:sub(1, maxLength):gsub("%s+$", "")
		end
	end

	frame.nameText.text:SetText(name)
	UpdateColor(frame, settings)
	frame.nameText:Show()
end
