local _, addon = ...

local FrameRegistry = {}
addon.FrameRegistry = FrameRegistry

local PP = addon.PixelPerfect
local initialized = false
local map = {}
local bossContainer
local hiddenBlizzardFrames
local blizzardFrameStates = {}

local blizzardFrameNames = {
	player = "PlayerFrame",
	target = "TargetFrame",
	pet = "PetFrame",
	targettarget = "TargetFrameToT",
	focus = "FocusFrame",
	focustarget = "FocusFrameToT",
	boss = "BossTargetFrameContainer",
}

local function UpdateFrame(frame, stateCallback, settingsCallback)
	if not InCombatLockdown() and type(settingsCallback) == "function" then
		settingsCallback(frame)
	end

	if type(stateCallback) == "function" then
		stateCallback(frame)
	end
end

local function CreateUnitFrame(unit, frameName, parent)
	local frame = CreateFrame("Button", frameName, parent or UIParent, "SecureUnitButtonTemplate")
	frame:SetFrameStrata("MEDIUM")
	frame:SetFrameLevel(10)

	frame.unit = unit
	frame:SetAttribute("unit", unit)
	frame:SetAttribute("toggleForVehicle", true)
	frame:SetAttribute("*type1", "target")
	frame:SetAttribute("*type2", "togglemenu")
	frame:RegisterForClicks("AnyUp")

	addon.Frames.Widgets.Background:Ensure(frame)
	addon.Frames.Widgets.Health:Ensure(frame)
	addon.Frames.Widgets.Health:UpdateState(frame)
	addon.Frames.Widgets.Name:Ensure(frame)
	addon.Frames.Widgets.Name:UpdateState(frame)
	addon.Frames.Widgets.Border:Ensure(frame)

	map[unit] = frame

	return frame
end

local function SetUnitWatch(frame, enabled)
	UnregisterUnitWatch(frame)

	if enabled then
		RegisterUnitWatch(frame)
	else
		frame:Hide()
	end
end

local function SetBlizzardFrameHidden(unit, hidden)
	local frame = _G[blizzardFrameNames[unit]]
	if not frame then
		return
	end

	if hidden then
		if frame:GetParent() ~= hiddenBlizzardFrames then
			blizzardFrameStates[frame] = {
				parent = frame:GetParent(),
				strata = frame:GetFrameStrata(),
				level = frame:GetFrameLevel(),
			}

			frame:SetParent(hiddenBlizzardFrames)
		end
	elseif frame:GetParent() == hiddenBlizzardFrames then
		local state = blizzardFrameStates[frame]
		frame:SetParent((state and state.parent) or UIParent)

		if state then
			frame:SetFrameStrata(state.strata)
			frame:SetFrameLevel(state.level)
		end
	end
end

local function UpdateVisibility()
	local frameSettings = addon.Database:GetProfile().frames

	SetUnitWatch(map.player, frameSettings.player.enabled)
	SetUnitWatch(map.target, frameSettings.target.enabled)
	SetUnitWatch(map.pet, frameSettings.pet.enabled)
	SetUnitWatch(map.targettarget, frameSettings.targettarget.enabled)
	SetUnitWatch(map.focus, frameSettings.focus.enabled)
	SetUnitWatch(map.focustarget, frameSettings.focustarget.enabled)

	for bossIndex = 1, 5 do
		SetUnitWatch(map["boss" .. bossIndex], frameSettings.boss.enabled)
	end

	SetBlizzardFrameHidden("player", frameSettings.player.hideBlizzardFrame)
	SetBlizzardFrameHidden("target", frameSettings.target.hideBlizzardFrame)
	SetBlizzardFrameHidden("pet", frameSettings.pet.hideBlizzardFrame)
	SetBlizzardFrameHidden("targettarget", frameSettings.targettarget.hideBlizzardFrame)
	SetBlizzardFrameHidden("focus", frameSettings.focus.hideBlizzardFrame)
	SetBlizzardFrameHidden("focustarget", frameSettings.focustarget.hideBlizzardFrame)
	SetBlizzardFrameHidden("boss", frameSettings.boss.hideBlizzardFrame)
end

local function UpdateFrameLayout(unit)
	local frame = map[unit]
	local settings = addon.Database:GetProfile().frames[unit]
	local position = settings.position

	frame:SetSize(PP:ToUIScaled(settings.size.width), PP:ToUIScaled(settings.size.height))

	if position.anchor == "CENTER" then
		PP:CenterElement(frame, UIParent, PP:ToUIScaled(position.x), PP:ToUIScaled(position.y))
	else
		frame:ClearAllPoints()
		frame:SetPoint(
			position.anchor,
			UIParent,
			"CENTER",
			PP:ToUIScaled(position.x),
			PP:ToUIScaled(position.y)
		)
	end

	addon.Frames.Widgets.Name:UpdateSettings(frame)
	addon.Frames.Widgets.Border:UpdateSettings(frame)
end

local function UpdateBossLayout()
	local settings = addon.Database:GetProfile().frames.boss
	local frameWidth = PP:ToUIScaled(settings.size.width)
	local frameHeight = PP:ToUIScaled(settings.size.height)
	local spacing = PP:ToUIScaled(settings.spacing)

	bossContainer:SetSize(frameWidth, (frameHeight * 5) + (spacing * 4))
	PP:CenterElement(
		bossContainer,
		UIParent,
		PP:ToUIScaled(settings.position.x),
		PP:ToUIScaled(settings.position.y)
	)

	local previousBossFrame
	for bossIndex = 1, 5 do
		local frame = map["boss" .. bossIndex]
		frame:SetSize(frameWidth, frameHeight)
		frame:ClearAllPoints()

		if previousBossFrame then
			frame:SetPoint("TOPLEFT", previousBossFrame, "BOTTOMLEFT", 0, -spacing)
		else
			frame:SetPoint("TOPLEFT", bossContainer, "TOPLEFT", 0, 0)
		end

		addon.Frames.Widgets.Name:UpdateSettings(frame)
		addon.Frames.Widgets.Border:UpdateSettings(frame)
		previousBossFrame = frame
	end
end

function FrameRegistry:UpdateUnit(unit, stateCallback, settingsCallback)
	if not initialized then
		error("FrameRegistry is not initialized", 2)
	end

	local frame = map[unit]
	if frame then
		UpdateFrame(frame, stateCallback, settingsCallback)
	end
end

function FrameRegistry:UpdateAllUnits(stateCallback, settingsCallback)
	if not initialized then
		error("FrameRegistry is not initialized", 2)
	end

	for _, frame in pairs(map) do
		UpdateFrame(frame, stateCallback, settingsCallback)
	end
end

function FrameRegistry:UpdateVisibility()
	if not initialized then
		error("FrameRegistry is not initialized", 2)
	end

	UpdateVisibility()
end

function FrameRegistry:UpdateLayout(unit)
	if not initialized then
		error("FrameRegistry is not initialized", 2)
	end

	if unit == "boss" then
		UpdateBossLayout()
	elseif map[unit] then
		UpdateFrameLayout(unit)
	end
end

function FrameRegistry:Initialize()
	if initialized then
		error("FrameRegistry already initialized", 2)
	end

	CreateUnitFrame("player", "MUF_PlayerFrame")
	CreateUnitFrame("target", "MUF_TargetFrame")
	CreateUnitFrame("pet", "MUF_PetFrame")
	CreateUnitFrame("targettarget", "MUF_TargetOfTargetFrame")
	CreateUnitFrame("focus", "MUF_FocusFrame")
	CreateUnitFrame("focustarget", "MUF_FocusTargetFrame")

	bossContainer = CreateFrame("Frame", "MUF_BossContainer", UIParent)
	bossContainer:SetFrameStrata("MEDIUM")
	bossContainer:SetFrameLevel(9)
	hiddenBlizzardFrames = CreateFrame("Frame", "MUF_HiddenBlizzardFrames", UIParent)
	hiddenBlizzardFrames:Hide()

	for bossIndex = 1, 5 do
		local unit = "boss" .. bossIndex
		CreateUnitFrame(unit, "MUF_Boss" .. bossIndex .. "Frame", bossContainer)
	end

	UpdateVisibility()

	PP:RegisterForUpdate(function()
		UpdateFrameLayout("player")
		UpdateFrameLayout("target")
		UpdateFrameLayout("pet")
		UpdateFrameLayout("targettarget")
		UpdateFrameLayout("focus")
		UpdateFrameLayout("focustarget")
		UpdateBossLayout()
	end)

	initialized = true
end

function FrameRegistry:IsInitialized()
	return initialized
end
