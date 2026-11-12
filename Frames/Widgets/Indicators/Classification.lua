local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Indicators = addon.Frames.Widgets.Indicators or {}
addon.Frames.Widgets.Indicators.Classification = addon.Frames.Widgets.Indicators.Classification or {}

local Classification = addon.Frames.Widgets.Indicators.Classification
local PP = addon.PixelPerfect
local settingsCache = {}

local classificationIcons = {
	elite = { atlas = "nameplates-icon-elite-gold" },
	rare = { atlas = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Star" },
	rareelite = { atlas = "nameplates-icon-elite-silver" },
	worldboss = { texture = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull" },
}

local function UpdateSettingsCache(frame)
	local settings = addon.Database:GetProfile().frames[frame.settingsUnit].classification
	settingsCache[frame.settingsUnit] = {
		enabled = settings.enabled,
		anchor = settings.anchor,
		size = settings.size,
		position = {
			x = settings.position.x,
			y = settings.position.y,
		},
	}
end

function Classification:Ensure(frame)
	if not frame.classification then
		local indicator = CreateFrame("Frame", nil, frame)
		indicator:SetFrameLevel(55)
		indicator:Hide()

		indicator.texture = indicator:CreateTexture(nil, "OVERLAY")
		indicator.texture:SetAllPoints(indicator)

		frame.classification = indicator
	end

	self:UpdateSettings(frame)
end

function Classification:UpdateSettings(frame)
	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.classification:Hide()
		return
	end

	local anchor = cachedSettings.anchor
	local position = cachedSettings.position
	local size = PP:ToUIScaled(cachedSettings.size)
	frame.classification:SetSize(size, size)
	frame.classification:ClearAllPoints()
	frame.classification:SetPoint(anchor, frame, anchor, PP:ToUIScaled(position.x), PP:ToUIScaled(position.y))
	self:UpdateState(frame)
end

function Classification:UpdateState(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]
	if cachedSettings.enabled == false or not frame.unit or not UnitExists(frame.unit) then
		frame.classification:Hide()
		return
	end

	local classification = UnitClassification(frame.unit)
	local iconData = classificationIcons[classification]
	if not iconData then
		frame.classification:Hide()
		return
	end

	local texture = frame.classification.texture
	if iconData.atlas then
		texture:SetAtlas(iconData.atlas)
	else
		texture:SetTexture(iconData.texture)
		texture:SetTexCoord(0, 1, 0, 1)
	end
	frame.classification:Show()
end
