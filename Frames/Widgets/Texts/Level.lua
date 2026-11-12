local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Texts = addon.Frames.Widgets.Texts or {}
addon.Frames.Widgets.Texts.Level = addon.Frames.Widgets.Texts.Level or {}

local Level = addon.Frames.Widgets.Texts.Level
local PP = addon.PixelPerfect
local LSM = LibStub("LibSharedMedia-3.0")
local settingsCache = {}
local generalSettings

local function UpdateSettingsCache(frame)
	local profile = addon.Database:GetProfile()
	local settings = profile.frames[frame.settingsUnit].levelText or {}
	local position = settings.position or {}
	settingsCache[frame.settingsUnit] = {
		enabled = settings.enabled,
		anchor = settings.anchor or "TOPRIGHT",
		font = settings.font,
		outline = settings.outline or "",
		size = settings.size or 16,
		position = {
			x = position.x or 0,
			y = position.y or 0,
		},
	}
	generalSettings = {
		font = profile.general.font,
	}
end

function Level:Ensure(frame)
	if not frame.levelText then
		local levelFrame = CreateFrame("Frame", nil, frame)
		levelFrame:SetAllPoints(frame)
		levelFrame:SetFrameLevel(55)
		levelFrame.text = levelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		levelFrame:Hide()

		frame.levelText = levelFrame
	end

	self:UpdateSettings(frame)
end

function Level:UpdateSettings(frame)
	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.levelText:Hide()
		return
	end

	local levelText = frame.levelText.text
	local anchor = cachedSettings.anchor
	local position = cachedSettings.position
	local font = cachedSettings.font
	if font == -1 then
		font = generalSettings.font
	end

	levelText:ClearAllPoints()
	levelText:SetPoint(anchor, frame.levelText, anchor, PP:ToUIScaled(position.x), PP:ToUIScaled(position.y))
	levelText:SetFont(LSM:Fetch("font", font), PP:ScaleFont(cachedSettings.size), cachedSettings.outline)
	levelText:SetShadowColor(0, 0, 0, 0.9)
	levelText:SetShadowOffset(1, -1)

	self:UpdateState(frame)
end

function Level:UpdateState(frame)
	local unit = frame.unit
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false or not unit or not UnitExists(unit) then
		frame.levelText:Hide()
		return
	end

	local level = UnitEffectiveLevel(unit)
	local color = GetCreatureDifficultyColor(level)
	local text = level > 0 and tostring(level) or "??"
	frame.levelText.text:SetText(text)
	frame.levelText.text:SetTextColor(color.r, color.g, color.b)
	frame.levelText:Show()
end
