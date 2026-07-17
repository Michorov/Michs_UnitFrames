local _, addon = ...

local FrameRegistry = {}
addon.FrameRegistry = FrameRegistry

local PP = addon.PixelPerfect
local initialized = false
local map = {}

local function UpdateFrame(frame, stateCallback, settingsCallback)
	if not InCombatLockdown() and type(settingsCallback) == "function" then
		settingsCallback(frame)
	end

	if type(stateCallback) == "function" then
		stateCallback(frame)
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

function FrameRegistry:Initialize()
	if initialized then
		error("FrameRegistry already initialized", 2)
	end

	local playerUnit = "player"
	local playerFrame = CreateFrame("Button", "MUF_PlayerFrame", UIParent, "SecureUnitButtonTemplate")
	playerFrame.unit = playerUnit
	playerFrame:SetAttribute("unit", playerUnit)
	playerFrame:SetAttribute("toggleForVehicle", true)
	playerFrame:SetAttribute("*type1", "target")
	playerFrame:SetAttribute("*type2", "togglemenu")
	playerFrame:RegisterForClicks("AnyUp")
	RegisterUnitWatch(playerFrame)

	addon.Frames.Widgets.Background:Ensure(playerFrame)
	addon.Frames.Widgets.Health:Ensure(playerFrame)
	addon.Frames.Widgets.Health:UpdateState(playerFrame)
	addon.Frames.Widgets.Name:Ensure(playerFrame)
	addon.Frames.Widgets.Name:UpdateState(playerFrame)
	addon.Frames.Widgets.Border:Ensure(playerFrame)

	map[playerUnit] = playerFrame

	local targetUnit = "target"
	local targetFrame = CreateFrame("Button", "MUF_TargetFrame", UIParent, "SecureUnitButtonTemplate")
	targetFrame.unit = targetUnit
	targetFrame:SetAttribute("unit", targetUnit)
	targetFrame:SetAttribute("toggleForVehicle", true)
	targetFrame:SetAttribute("*type1", "target")
	targetFrame:SetAttribute("*type2", "togglemenu")
	targetFrame:RegisterForClicks("AnyUp")
	RegisterUnitWatch(targetFrame)

	addon.Frames.Widgets.Background:Ensure(targetFrame)
	addon.Frames.Widgets.Health:Ensure(targetFrame)
	addon.Frames.Widgets.Health:UpdateState(targetFrame)
	addon.Frames.Widgets.Name:Ensure(targetFrame)
	addon.Frames.Widgets.Name:UpdateState(targetFrame)
	addon.Frames.Widgets.Border:Ensure(targetFrame)

	map[targetUnit] = targetFrame

	PP:RegisterForUpdate(function()
		playerFrame:SetSize(PP:ToUIScaled(140), PP:ToUIScaled(32))
		PP:CenterElement(playerFrame, UIParent, PP:ToUIScaled(-150), PP:ToUIScaled(-300))
		addon.Frames.Widgets.Name:UpdateSettings(playerFrame)
		addon.Frames.Widgets.Border:UpdateSettings(playerFrame)

		targetFrame:SetSize(PP:ToUIScaled(140), PP:ToUIScaled(32))
		PP:CenterElement(targetFrame, UIParent, PP:ToUIScaled(150), PP:ToUIScaled(-300))
		addon.Frames.Widgets.Name:UpdateSettings(targetFrame)
		addon.Frames.Widgets.Border:UpdateSettings(targetFrame)
	end)

	initialized = true
end

function FrameRegistry:IsInitialized()
	return initialized
end
