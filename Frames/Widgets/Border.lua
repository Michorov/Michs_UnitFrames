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

		border.left:SetPoint("TOPLEFT", border, "TOPLEFT", 0, 0)
		border.left:SetPoint("BOTTOMLEFT", border, "BOTTOMLEFT", 0, 0)

		border.right:SetPoint("TOPRIGHT", border, "TOPRIGHT", 0, 0)
		border.right:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", 0, 0)

		border.top:SetPoint("TOPLEFT", border.left, "TOPRIGHT", 0, 0)
		border.top:SetPoint("TOPRIGHT", border.right, "TOPLEFT", 0, 0)

		border.bottom:SetPoint("BOTTOMLEFT", border.left, "BOTTOMRIGHT", 0, 0)
		border.bottom:SetPoint("BOTTOMRIGHT", border.right, "BOTTOMLEFT", 0, 0)

		border.top:SetColorTexture(0, 0, 0, 1)
		border.bottom:SetColorTexture(0, 0, 0, 1)
		border.left:SetColorTexture(0, 0, 0, 1)
		border.right:SetColorTexture(0, 0, 0, 1)

		frame.border = border
	end

	self:UpdateSettings(frame)
end

function Border:UpdateSettings(frame)
	local border = frame.border
	local uiThickness = PP:ToUIScaled(1)

	border.left:SetWidth(uiThickness)
	border.right:SetWidth(uiThickness)
	border.top:SetHeight(uiThickness)
	border.bottom:SetHeight(uiThickness)
end
