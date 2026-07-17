local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Border = addon.Frames.Widgets.Border or {}

local Border = addon.Frames.Widgets.Border
local PP = addon.PixelPerfect

function Border:Ensure(frame)
	if not frame.border then
		local border = CreateFrame("Frame", nil, frame)
		border:SetAllPoints(frame)
		border:SetFrameLevel(25)

		border.top = border:CreateTexture(nil, "OVERLAY", nil, 0)
		border.bottom = border:CreateTexture(nil, "OVERLAY", nil, 0)
		border.left = border:CreateTexture(nil, "OVERLAY", nil, 0)
		border.right = border:CreateTexture(nil, "OVERLAY", nil, 0)

		frame.border = border
	end

	self:UpdateSettings(frame)
end

function Border:UpdateSettings(frame, settings)
	local borderSettings = (settings and settings.border) or {}
	local thickness = borderSettings.thicknessPx or 1
	local border = frame.border

	if thickness == 0 then
		border:Hide()
		return
	end

	local uiThickness = PP:ToUIScaled(thickness)

	border.left:ClearAllPoints()
	border.left:SetPoint("TOPLEFT", border, "TOPLEFT", 0, 0)
	border.left:SetPoint("BOTTOMLEFT", border, "BOTTOMLEFT", 0, 0)
	border.left:SetWidth(uiThickness)

	border.right:ClearAllPoints()
	border.right:SetPoint("TOPRIGHT", border, "TOPRIGHT", 0, 0)
	border.right:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", 0, 0)
	border.right:SetWidth(uiThickness)

	border.top:ClearAllPoints()
	border.top:SetPoint("TOPLEFT", border.left, "TOPRIGHT", 0, 0)
	border.top:SetPoint("TOPRIGHT", border.right, "TOPLEFT", 0, 0)
	border.top:SetHeight(uiThickness)

	border.bottom:ClearAllPoints()
	border.bottom:SetPoint("BOTTOMLEFT", border.left, "BOTTOMRIGHT", 0, 0)
	border.bottom:SetPoint("BOTTOMRIGHT", border.right, "BOTTOMLEFT", 0, 0)
	border.bottom:SetHeight(uiThickness)

	local color = borderSettings.color or {}
	for _, texture in ipairs({ border.top, border.bottom, border.left, border.right }) do
		texture:SetColorTexture(color.r or 0, color.g or 0, color.b or 0, color.a or 1)
		texture:SetSnapToPixelGrid(true)
		texture:SetTexelSnappingBias(0)
	end

	border:Show()
end
