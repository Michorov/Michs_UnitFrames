local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Texts = addon.Frames.Widgets.Texts or {}
addon.Frames.Widgets.Texts.Name = addon.Frames.Widgets.Texts.Name or {}

local Name = addon.Frames.Widgets.Texts.Name
local PP = addon.PixelPerfect

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

	nameText:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(12), "")
	nameText:SetShadowColor(0, 0, 0, 0.9)
	nameText:SetShadowOffset(1, -1)
	nameText:SetTextColor(1, 1, 1, 1)

	self:UpdateState(frame, settings)
end

function Name:UpdateState(frame, settings)
	local unit = frame.unit
	if not frame.nameText.enabled or not unit or not UnitExists(unit) then
		frame.nameText:Hide()
		return
	end

	frame.nameText.text:SetText(UnitName(unit) or "")
	frame.nameText:Show()
end
