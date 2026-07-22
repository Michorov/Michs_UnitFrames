local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Texts = addon.Frames.Widgets.Texts or {}
addon.Frames.Widgets.Texts.Name = addon.Frames.Widgets.Texts.Name or {}

local Name = addon.Frames.Widgets.Texts.Name
local PP = addon.PixelPerfect
local LSM = LibStub("LibSharedMedia-3.0")
local settingsCache = {}
local generalSettings

local function UpdateSettingsCache(frame)
	local profile = addon.Database:GetProfile()
	settingsCache[frame.settingsUnit] = profile.frames[frame.settingsUnit].nameText or {}
	generalSettings = profile.general
end

local function UpdateColor(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	local color = cachedSettings.color or {}
	local r = color.r or 1
	local g = color.g or 1
	local b = color.b or 1
	local a = color.a or 1

	if cachedSettings.colorByClassOrReaction then
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

function Name:Ensure(frame)
	if not frame.nameText then
		local nameFrame = CreateFrame("Frame", nil, frame)
		nameFrame:SetAllPoints(frame)
		nameFrame:SetFrameLevel(30)
		nameFrame.text = nameFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

		frame.nameText = nameFrame
	end

	self:UpdateSettings(frame)
end

function Name:UpdateSettings(frame)
	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.nameText:Hide()
		return
	end

	local nameText = frame.nameText.text
	local anchor = cachedSettings.anchor or "LEFT"
	local position = cachedSettings.position or {}
	local font = cachedSettings.font
	if font == -1 then
		font = generalSettings.font
	end

	nameText:ClearAllPoints()
	nameText:SetPoint(anchor, frame.nameText, anchor, PP:ToUIScaled(position.x or 0), PP:ToUIScaled(position.y or 0))

	nameText:SetFont(LSM:Fetch("font", font), PP:ScaleFont(cachedSettings.size or 12), cachedSettings.outline or "")
	nameText:SetShadowColor(0, 0, 0, 0.9)
	nameText:SetShadowOffset(1, -1)

	self:UpdateState(frame)
end

function Name:UpdateState(frame)
	local unit = frame.unit
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false or not unit or not UnitExists(unit) then
		frame.nameText:Hide()
		return
	end

	frame.nameText.text:SetText(UnitName(unit) or "")
	UpdateColor(frame)
	frame.nameText:Show()
end
