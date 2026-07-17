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

	local playerFrame = CreateFrame("Button", "MUF_PlayerFrame", UIParent, "SecureUnitButtonTemplate")
	playerFrame:SetAttribute("unit", "player")
	playerFrame:SetAttribute("toggleForVehicle", true)
	playerFrame:SetAttribute("*type1", "target")
	playerFrame:SetAttribute("*type2", "togglemenu")
	playerFrame:RegisterForClicks("AnyUp")

	addon.Frames.Widgets.Background:Ensure(playerFrame)
	addon.Frames.Widgets.Background:UpdateSettings(playerFrame)
	addon.Frames.Widgets.Health:Ensure(playerFrame)
	addon.Frames.Widgets.Health:UpdateSettings(playerFrame)
	addon.Frames.Widgets.Health:UpdateState(playerFrame)
	addon.Frames.Widgets.Border:Ensure(playerFrame)

	map["player"] = playerFrame

	PP:RegisterForUpdate(function()
		playerFrame:SetSize(PP:ToUIScaled(140), PP:ToUIScaled(32))
		PP:CenterElement(playerFrame, UIParent, PP:ToUIScaled(0), PP:ToUIScaled(0))
		addon.Frames.Widgets.Border:UpdateSettings(playerFrame)
	end)

	initialized = true
end

function FrameRegistry:IsInitialized()
	return initialized
end
