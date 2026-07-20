local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Absorbs = addon.Frames.Widgets.Absorbs or {}

local Absorbs = addon.Frames.Widgets.Absorbs

function Absorbs:Ensure(frame, settings)
	if not frame.absorbBar then
		local absorbBar = CreateFrame("StatusBar", nil, frame)
		absorbBar:SetFrameLevel(15)
		absorbBar:SetOrientation("HORIZONTAL")
		absorbBar:SetReverseFill(true)
		absorbBar:SetAllPoints(frame)
		absorbBar:Hide()

		local texture = absorbBar:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\Michs_UnitFrames\\Media\\Textures\\Absorb", "REPEAT", "REPEAT")
		texture:SetHorizTile(true)
		texture:SetVertTile(true)
		absorbBar:SetStatusBarTexture(texture)

		frame.absorbBar = absorbBar
	end

	self:UpdateSettings(frame, settings)
end

function Absorbs:UpdateSettings(frame, settings)
	local color = (settings and settings.absorbs and settings.absorbs.color) or {}
	frame.absorbBar:SetStatusBarColor(
		color.r or 0.2,
		color.g or 0.8,
		color.b or 1,
		color.a or 0.5
	)
end

function Absorbs:UpdateState(frame)
	if not frame.unit or not UnitExists(frame.unit) then
		frame.absorbBar:Hide()
		return
	end

	frame.absorbBar:SetMinMaxValues(0, UnitHealthMax(frame.unit))
	frame.absorbBar:SetValue(UnitGetTotalAbsorbs(frame.unit))
	frame.absorbBar:Show()
end
