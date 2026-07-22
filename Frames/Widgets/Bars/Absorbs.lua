local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Bars = addon.Frames.Widgets.Bars or {}
addon.Frames.Widgets.Bars.Absorbs = addon.Frames.Widgets.Bars.Absorbs or {}

local Absorbs = addon.Frames.Widgets.Bars.Absorbs
local settingsCache = {}

local function UpdateSettingsCache(frame)
	local settings = addon.Database:GetProfile().frames[frame.settingsUnit]
	settingsCache[frame.settingsUnit] = settings.absorbs or {}
end

function Absorbs:Ensure(frame)
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

	self:UpdateSettings(frame)
end

function Absorbs:UpdateSettings(frame)
	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.absorbBar:Hide()
		return
	end

	local color = cachedSettings.color or {}
	frame.absorbBar:SetStatusBarColor(color.r or 0.2, color.g or 0.8, color.b or 1, color.a or 0.5)

	self:UpdateState(frame)
end

function Absorbs:UpdateState(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.absorbBar:Hide()
		return
	end

	if not frame.unit or not UnitExists(frame.unit) then
		frame.absorbBar:Hide()
		return
	end

	frame.absorbBar:SetMinMaxValues(0, UnitHealthMax(frame.unit))
	frame.absorbBar:SetValue(UnitGetTotalAbsorbs(frame.unit))
	frame.absorbBar:Show()
end
