local _, addon = ...

local FrameRegistry = {}
addon.FrameRegistry = FrameRegistry

FrameRegistry.restoreLiveDriversAfterCombat = false

local PP = addon.PixelPerfect
local initialized = false
local map = {}
local dummyFrames = {}
local framesUnlocked = false
local liveContainer
local bossContainer
local hiddenBlizzardFrames
local blizzardFrameStates = {}
local hookedBlizzardFrames = {}

local blizzardFrameNames = {
	player = "PlayerFrame",
	playerCastBar = "PlayerCastingBarFrame",
	target = "TargetFrame",
	pet = "PetFrame",
	targettarget = "TargetFrameToT",
	focus = "FocusFrame",
	focustarget = "FocusFrameToT",
	boss = "BossTargetFrameContainer",
}

local function GetBlizzardFrameHiddenSetting(unit)
	local frames = addon.Database:GetProfile().frames
	if unit == "playerCastBar" then
		local castSettings = frames.player.cast
		return castSettings and castSettings.hideBlizzardCastBar == true
	end

	return frames[unit].hideBlizzardFrame
end

local function UpdateFrame(frame, stateCallback, settingsCallback)
	if not InCombatLockdown() and type(settingsCallback) == "function" then
		settingsCallback(frame)
	end

	if type(stateCallback) == "function" and frame.enabled ~= false then
		stateCallback(frame)
	end
end

local function CreateUnitFrame(unit, frameName, parent)
	local frame = CreateFrame("Button", frameName, parent or liveContainer, "SecureUnitButtonTemplate, PingableUnitFrameTemplate")
	local settingsUnit = unit:match("^boss%d+$") and "boss" or unit
	frame:SetFrameStrata("MEDIUM")
	frame:SetFrameLevel(10)

	frame.unit = unit
	frame.settingsUnit = settingsUnit
	frame:SetAttribute("unit", unit)
	frame:SetAttribute("toggleForVehicle", true)
	frame:SetAttribute("*type1", "target")
	frame:SetAttribute("*type2", "togglemenu")
	frame:RegisterForClicks("AnyUp")

	if unit == "player" then
		function frame:GetTargetInfo()
			return {
				guid = UnitGUID("player"),
				isPlayerResource = true,
			}
		end
	end

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

	addon.Frames.Widgets.Background:Ensure(frame)
	addon.Frames.Widgets.Bars.Health:Ensure(frame)
	addon.Frames.Widgets.Bars.Power:Ensure(frame)
	addon.Frames.Widgets.Bars.Cast:Ensure(frame)
	addon.Frames.Widgets.Bars.Absorbs:Ensure(frame)
	addon.Frames.Widgets.Bars.HealAbsorbs:Ensure(frame)
	addon.Frames.ManagedContainers.Buffs:Ensure(frame)
	addon.Frames.ManagedContainers.Debuffs:Ensure(frame)
	addon.Frames.Widgets.MouseoverHighlight:Ensure(frame)
	addon.Frames.Widgets.Indicators.Combat:Ensure(frame)
	addon.Frames.Widgets.Indicators.RaidMarker:Ensure(frame)
	addon.Frames.Widgets.Indicators.GroupStatus:Ensure(frame)
	addon.Frames.Widgets.Texts.Name:Ensure(frame)
	addon.Frames.Widgets.Texts.Health:Ensure(frame)
	addon.Frames.Widgets.Texts.Power:Ensure(frame)
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
			if not GetBlizzardFrameHiddenSetting(unit)
				or self:GetParent() == hiddenBlizzardFrames then
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
	local frame = map[unit]

	frame.enabled = settings.enabled ~= false
	SetUnitWatch(frame, settings.enabled)
	SetBlizzardFrameHidden(unit, settings.hideBlizzardFrame)

	if unit == "player" then
		SetBlizzardFrameHidden("playerCastBar", settings.cast.hideBlizzardCastBar)
	end
end

local function UpdateBossVisibility()
	local settings = addon.Database:GetProfile().frames.boss
	local enabled = settings.enabled ~= false

	for bossIndex = 1, 5 do
		local frame = map["boss" .. bossIndex]
		frame.enabled = enabled
		SetUnitWatch(frame, settings.enabled)
	end

	SetBlizzardFrameHidden("boss", settings.hideBlizzardFrame)
end

local function UpdateFrameLayout(unit)
	local frame = map[unit]
	local profile = addon.Database:GetProfile()
	local settings = profile.frames[unit]
	local width = PP:ToUIScaled(settings.size.width)
	local height = PP:ToUIScaled(settings.size.height)

	for _, layoutFrame in ipairs({ frame, dummyFrames[unit] }) do
		layoutFrame:SetSize(width, height)
		PP:CenterElement(layoutFrame, UIParent, PP:ToUIScaled(settings.position.x), PP:ToUIScaled(settings.position.y))
	end

	addon.Frames.Widgets.Texts.Name:UpdateSettings(frame)
	addon.Frames.Widgets.Texts.Health:UpdateSettings(frame)
	addon.Frames.Widgets.Texts.Power:UpdateSettings(frame)
	addon.Frames.Widgets.Bars.Power:UpdateSettings(frame)
	addon.Frames.Widgets.Bars.Cast:UpdateLayout(frame)
	addon.Frames.ManagedContainers.Buffs:UpdateSettings(frame)
	addon.Frames.ManagedContainers.Debuffs:UpdateSettings(frame)
	addon.Frames.Widgets.Indicators.Combat:UpdateSettings(frame)
	addon.Frames.Widgets.Indicators.RaidMarker:UpdateSettings(frame)
	addon.Frames.Widgets.Indicators.GroupStatus:UpdateSettings(frame)
	addon.Frames.Widgets.Border:UpdateSettings(frame)
end

local function UpdateBossLayout()
	local profile = addon.Database:GetProfile()
	local settings = profile.frames.boss
	local frameWidth = PP:ToUIScaled(settings.size.width)
	local frameHeight = PP:ToUIScaled(settings.size.height)
	local spacing = PP:ToUIScaled(settings.spacing)
	local containerHeight = (frameHeight * 5) + (spacing * 4)
	local dummyContainer = dummyFrames.boss

	for _, container in ipairs({ bossContainer, dummyContainer }) do
		container:SetSize(frameWidth, containerHeight)
		PP:CenterElement(container, UIParent, PP:ToUIScaled(settings.position.x), PP:ToUIScaled(settings.position.y))
	end

	local previousBossFrame
	for bossIndex = 1, 5 do
		local frame = map["boss" .. bossIndex]
		local dummyFrame = dummyContainer.frames[bossIndex]
		frame:SetSize(frameWidth, frameHeight)
		frame:ClearAllPoints()
		dummyFrame:SetSize(frameWidth, frameHeight)
		dummyFrame:ClearAllPoints()

		if previousBossFrame then
			frame:SetPoint("TOPLEFT", previousBossFrame, "BOTTOMLEFT", 0, -spacing)
			dummyFrame:SetPoint("TOPLEFT", dummyContainer.frames[bossIndex - 1], "BOTTOMLEFT", 0, -spacing)
		else
			frame:SetPoint("TOPLEFT", bossContainer, "TOPLEFT", 0, 0)
			dummyFrame:SetPoint("TOPLEFT", dummyContainer, "TOPLEFT", 0, 0)
		end

		addon.Frames.Widgets.Texts.Name:UpdateSettings(frame)
		addon.Frames.Widgets.Texts.Health:UpdateSettings(frame)
		addon.Frames.Widgets.Texts.Power:UpdateSettings(frame)
		addon.Frames.Widgets.Bars.Power:UpdateSettings(frame)
		addon.Frames.Widgets.Bars.Cast:UpdateLayout(frame)
		addon.Frames.ManagedContainers.Buffs:UpdateSettings(frame)
		addon.Frames.Widgets.Indicators.RaidMarker:UpdateSettings(frame)
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

function FrameRegistry:UpdateAllVisibility()
	if not initialized then
		error("FrameRegistry is not initialized", 2)
	end

	for unit in pairs(map) do
		if not unit:match("^boss%d+$") then
			UpdateFrameVisibility(unit)
		end
	end

	UpdateBossVisibility()
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

function FrameRegistry:UpdateAllLayouts()
	if not initialized then
		error("FrameRegistry is not initialized", 2)
	end

	for unit in pairs(map) do
		if not unit:match("^boss%d+$") then
			UpdateFrameLayout(unit)
		end
	end

	UpdateBossLayout()
end

function FrameRegistry:UpdateBlizzardFrameVisibility()
	if not initialized then
		error("FrameRegistry is not initialized", 2)
	end

	for unit in pairs(blizzardFrameNames) do
		SetBlizzardFrameHidden(unit, GetBlizzardFrameHiddenSetting(unit))
	end
end

function FrameRegistry:UpdateStateDrivers()
	if not initialized then
		error("FrameRegistry is not initialized", 2)
	end

	if InCombatLockdown() then
		self.restoreLiveDriversAfterCombat = true
		return
	end

	UnregisterStateDriver(liveContainer, "visibility")
	if framesUnlocked then
		RegisterStateDriver(liveContainer, "visibility", "[combat] show; hide")
	else
		liveContainer:Show()
	end

	self.restoreLiveDriversAfterCombat = false
end

function FrameRegistry:IsUnlocked()
	return framesUnlocked
end

function FrameRegistry:SetUnlocked(unlocked)
	if not initialized then
		error("FrameRegistry is not initialized", 2)
	end

	unlocked = unlocked == true
	if unlocked and InCombatLockdown() then
		return
	end

	if unlocked then
		self:UpdateAllLayouts()
	end

	framesUnlocked = unlocked
	for _, frame in pairs(dummyFrames) do
		frame:SetShown(unlocked)
	end

	self:UpdateStateDrivers()
end

function FrameRegistry:Initialize()
	if initialized then
		error("FrameRegistry already initialized", 2)
	end

	liveContainer = CreateFrame("Frame", "MUF_LiveFrameContainer", UIParent)
	liveContainer:SetAllPoints(UIParent)
	liveContainer:SetFrameStrata("MEDIUM")
	liveContainer:SetFrameLevel(0)

	CreateUnitFrame("player", "MUF_PlayerFrame")
	CreateUnitFrame("target", "MUF_TargetFrame")
	CreateUnitFrame("pet", "MUF_PetFrame")
	CreateUnitFrame("targettarget", "MUF_TargetOfTargetFrame")
	CreateUnitFrame("focus", "MUF_FocusFrame")
	CreateUnitFrame("focustarget", "MUF_FocusTargetFrame")

	bossContainer = CreateFrame("Frame", "MUF_BossContainer", liveContainer)
	bossContainer:SetFrameStrata("MEDIUM")
	bossContainer:SetFrameLevel(9)
	hiddenBlizzardFrames = CreateFrame("Frame", "MUF_HiddenBlizzardFrames", UIParent)
	hiddenBlizzardFrames:Hide()

	for bossIndex = 1, 5 do
		local unit = "boss" .. bossIndex
		CreateUnitFrame(unit, "MUF_Boss" .. bossIndex .. "Frame", bossContainer)
	end

	dummyFrames.player = addon.Frames:CreateDummyFrame("player", "MUF_DummyPlayerFrame")
	dummyFrames.target = addon.Frames:CreateDummyFrame("target", "MUF_DummyTargetFrame")
	dummyFrames.pet = addon.Frames:CreateDummyFrame("pet", "MUF_DummyPetFrame")
	dummyFrames.targettarget = addon.Frames:CreateDummyFrame("targettarget", "MUF_DummyTargetOfTargetFrame")
	dummyFrames.focus = addon.Frames:CreateDummyFrame("focus", "MUF_DummyFocusFrame")
	dummyFrames.focustarget = addon.Frames:CreateDummyFrame("focustarget", "MUF_DummyFocusTargetFrame")
	dummyFrames.boss = addon.Frames:CreateDummyBossGroup("MUF_DummyBossContainer")

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
