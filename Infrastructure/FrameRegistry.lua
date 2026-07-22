local _, addon = ...

local FrameRegistry = {}
addon.FrameRegistry = FrameRegistry

local PP = addon.PixelPerfect
local initialized = false
local map = {}
local bossContainer
local hiddenBlizzardFrames
local blizzardFrameStates = {}
local hookedBlizzardFrames = {}

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
	local settingsUnit = unit:match("^boss%d+$") and "boss" or unit
	local settings = addon.Database:GetProfile().frames[settingsUnit]
	frame:SetFrameStrata("MEDIUM")
	frame:SetFrameLevel(10)

	frame.unit = unit
	frame:SetAttribute("unit", unit)
	frame:SetAttribute("toggleForVehicle", true)
	frame:SetAttribute("*type1", "target")
	frame:SetAttribute("*type2", "togglemenu")
	frame:RegisterForClicks("AnyUp")

	frame:HookScript("OnEnter", function(self)
		if not self.unit then
			return
		end

		local unit = self.unit
		C_Timer.After(0, function()
			if not self:IsMouseOver() or not UnitExists(unit) then
				return
			end

			GameTooltip_SetDefaultAnchor(GameTooltip, self)
			GameTooltip:SetUnit(unit)
		end)
	end)

	frame:HookScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	addon.Frames.Widgets.Background:Ensure(frame, settings)
	addon.Frames.Widgets.Bars.Health:Ensure(frame, settings)
	addon.Frames.Widgets.Bars.Absorbs:Ensure(frame, settings)
	addon.Frames.Widgets.Bars.HealAbsorbs:Ensure(frame, settings)
	addon.Frames.Widgets.MouseoverHighlight:Ensure(frame, addon.Database:GetProfile().general)
	addon.Frames.Widgets.Indicators.Combat:Ensure(frame)
	addon.Frames.Widgets.Texts.Name:Ensure(frame, settings)
	addon.Frames.Widgets.Texts.Health:Ensure(frame, settings)
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

	if not hookedBlizzardFrames[frame] then
		hooksecurefunc(frame, "SetParent", function(self)
			local settings = addon.Database:GetProfile().frames[unit]
			if not settings.hideBlizzardFrame or self:GetParent() == hiddenBlizzardFrames then
				return
			end

			if InCombatLockdown() and self:IsProtected() then
				return
			end

			self:SetParent(hiddenBlizzardFrames)
		end)

		hookedBlizzardFrames[frame] = true
	end

	if hidden then
		if frame:GetParent() ~= hiddenBlizzardFrames then
			if InCombatLockdown() and frame:IsProtected() then
				return
			end

			blizzardFrameStates[frame] = {
				parent = frame:GetParent(),
				strata = frame:GetFrameStrata(),
				level = frame:GetFrameLevel(),
			}

			frame:SetParent(hiddenBlizzardFrames)
		end
	elseif frame:GetParent() == hiddenBlizzardFrames then
		if InCombatLockdown() and frame:IsProtected() then
			return
		end

		local state = blizzardFrameStates[frame]
		frame:SetParent((state and state.parent) or UIParent)

		if state then
			frame:SetFrameStrata(state.strata)
			frame:SetFrameLevel(state.level)
		end
	end
end

local function UpdateFrameVisibility(unit)
	local settings = addon.Database:GetProfile().frames[unit]

	SetUnitWatch(map[unit], settings.enabled)
	SetBlizzardFrameHidden(unit, settings.hideBlizzardFrame)
end

local function UpdateBossVisibility()
	local settings = addon.Database:GetProfile().frames.boss

	for bossIndex = 1, 5 do
		SetUnitWatch(map["boss" .. bossIndex], settings.enabled)
	end

	SetBlizzardFrameHidden("boss", settings.hideBlizzardFrame)
end

local function UpdateFrameLayout(unit)
	local frame = map[unit]
	local settings = addon.Database:GetProfile().frames[unit]
	local position = settings.position

	frame:SetSize(PP:ToUIScaled(settings.size.width), PP:ToUIScaled(settings.size.height))
	PP:CenterElement(frame, UIParent, PP:ToUIScaled(position.x), PP:ToUIScaled(position.y))

	addon.Frames.Widgets.Texts.Name:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Texts.Health:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Indicators.Combat:UpdateSettings(frame)
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

		addon.Frames.Widgets.Texts.Name:UpdateSettings(frame, settings)
		addon.Frames.Widgets.Texts.Health:UpdateSettings(frame, settings)
		addon.Frames.Widgets.Border:UpdateSettings(frame)
		previousBossFrame = frame
	end
end

function FrameRegistry:UpdateUnit(unit, stateCallback, settingsCallback)
	if not initialized then
		error("FrameRegistry is not initialized", 2)
	end

	if unit == "boss" then
		for bossIndex = 1, 5 do
			UpdateFrame(map["boss" .. bossIndex], stateCallback, settingsCallback)
		end
	elseif map[unit] then
		UpdateFrame(map[unit], stateCallback, settingsCallback)
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

function FrameRegistry:UpdateVisibility(unit)
	if not initialized then
		error("FrameRegistry is not initialized", 2)
	end

	if unit == "boss" then
		UpdateBossVisibility()
	elseif map[unit] then
		UpdateFrameVisibility(unit)
	end
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

function FrameRegistry:UpdateBlizzardFrameVisibility()
	if not initialized then
		error("FrameRegistry is not initialized", 2)
	end

	for unit in pairs(blizzardFrameNames) do
		local settings = addon.Database:GetProfile().frames[unit]
		SetBlizzardFrameHidden(unit, settings.hideBlizzardFrame)
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

	UpdateFrameVisibility("player")
	UpdateFrameVisibility("target")
	UpdateFrameVisibility("pet")
	UpdateFrameVisibility("targettarget")
	UpdateFrameVisibility("focus")
	UpdateFrameVisibility("focustarget")
	UpdateBossVisibility()

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
