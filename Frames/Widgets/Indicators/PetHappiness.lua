local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Indicators = addon.Frames.Widgets.Indicators or {}
addon.Frames.Widgets.Indicators.PetHappiness = addon.Frames.Widgets.Indicators.PetHappiness or {}

local PetHappiness = addon.Frames.Widgets.Indicators.PetHappiness
local PP = addon.PixelPerfect

local happinessAtlases = {
	[1] = "UI-PetMad",
	[2] = "UI-PetNeutral",
	[3] = "UI-PetHappiness",
}

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

	local size = frame:GetHeight()
	indicator:SetSize(size, size)
	indicator:ClearAllPoints()
	indicator:SetPoint("LEFT", frame, "RIGHT", PP:ToUIScaled(4), 0)
	self:UpdateState(frame)
end

function PetHappiness:UpdateState(frame)
	local indicator = frame.petHappiness
	if not indicator then
		return
	end

	local _, isHunterPet = HasPetUI()
	if not UnitExists("pet") or not isHunterPet then
		indicator:Hide()
		return
	end

	local happiness = C_PetInfo.GetPetHappiness()
	local atlas = happinessAtlases[happiness]
	if not atlas then
		indicator:Hide()
		return
	end

	indicator.texture:SetAtlas(atlas)
	indicator:Show()
end
