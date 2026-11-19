local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Indicators = addon.Frames.Widgets.Indicators or {}
addon.Frames.Widgets.Indicators.PetHappiness = addon.Frames.Widgets.Indicators.PetHappiness or {}

local PetHappiness = addon.Frames.Widgets.Indicators.PetHappiness
local PP = addon.PixelPerfect
local settingsCache = {}

local happinessAtlases = {
	[1] = "UI-PetMad",
	[2] = "UI-PetNeutral",
	[3] = "UI-PetHappiness",
}

local function UpdateSettingsCache(frame)
	local settings = addon.Database:GetProfile().frames[frame.settingsUnit].petHappiness or {}
	local position = settings.position or {}
	settingsCache[frame.settingsUnit] = {
		enabled = settings.enabled ~= false,
		happy = settings.happy ~= false,
		neutral = settings.neutral ~= false,
		unhappy = settings.unhappy ~= false,
		anchor = settings.anchor or "RIGHT",
		sizeMode = settings.sizeMode or "auto",
		customSize = settings.customSize or 28,
		position = {
			x = position.x or 32,
			y = position.y or 0,
		},
	}
end

function PetHappiness:Ensure(frame)
	if frame.settingsUnit ~= "pet" or not C_PetInfo or not C_PetInfo.GetPetHappiness then
		return
	end

	if not frame.petHappiness then
		local indicator = CreateFrame("Frame", nil, frame)
		indicator:SetFrameLevel(50)
		indicator:EnableMouse(false)
		indicator:Hide()

		indicator.texture = indicator:CreateTexture(nil, "OVERLAY")
		indicator.texture:SetAllPoints(indicator)
		frame.petHappiness = indicator
	end

	self:UpdateSettings(frame)
end

function PetHappiness:UpdateSettings(frame)
	local indicator = frame.petHappiness
	if not indicator then
		return
	end

	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]
	if not cachedSettings.enabled then
		indicator:Hide()
		return
	end

	local size = frame:GetHeight()
	if cachedSettings.sizeMode == "manual" then
		size = PP:ToUIScaled(cachedSettings.customSize)
	end
	local anchor = cachedSettings.anchor
	local position = cachedSettings.position
	indicator:SetSize(size, size)
	indicator:ClearAllPoints()
	indicator:SetPoint(anchor, frame, anchor, PP:ToUIScaled(position.x), PP:ToUIScaled(position.y))
	self:UpdateState(frame)
end

function PetHappiness:UpdateState(frame)
	local indicator = frame.petHappiness
	if not indicator then
		return
	end

	local cachedSettings = settingsCache[frame.settingsUnit]
	if not cachedSettings.enabled then
		indicator:Hide()
		return
	end

	local _, isHunterPet = HasPetUI()
	if not UnitExists("pet") or not isHunterPet then
		indicator:Hide()
		return
	end

	local happiness = C_PetInfo.GetPetHappiness()
	local show = (happiness == 3 and cachedSettings.happy)
		or (happiness == 2 and cachedSettings.neutral)
		or (happiness == 1 and cachedSettings.unhappy)
	local atlas = happinessAtlases[happiness]
	if not show or not atlas then
		indicator:Hide()
		return
	end

	indicator.texture:SetAtlas(atlas)
	indicator:Show()
end
