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

local function CreateUnitFrame(unit, frameName)
	local frame = CreateFrame("Button", frameName, UIParent, "SecureUnitButtonTemplate")
	frame.unit = unit
	frame:SetAttribute("unit", unit)
	frame:SetAttribute("toggleForVehicle", true)
	frame:SetAttribute("*type1", "target")
	frame:SetAttribute("*type2", "togglemenu")
	frame:RegisterForClicks("AnyUp")
	RegisterUnitWatch(frame)

	addon.Frames.Widgets.Background:Ensure(frame)
	addon.Frames.Widgets.Health:Ensure(frame)
	addon.Frames.Widgets.Health:UpdateState(frame)
	addon.Frames.Widgets.Name:Ensure(frame)
	addon.Frames.Widgets.Name:UpdateState(frame)
	addon.Frames.Widgets.Border:Ensure(frame)

	map[unit] = frame

	return frame
end

local function UpdateMainFrameLayout(frame, offsetX, offsetY)
	frame:SetSize(PP:ToUIScaled(140), PP:ToUIScaled(32))
	PP:CenterElement(frame, UIParent, PP:ToUIScaled(offsetX), PP:ToUIScaled(offsetY))
	addon.Frames.Widgets.Name:UpdateSettings(frame)
	addon.Frames.Widgets.Border:UpdateSettings(frame)
end

local function UpdateAttachedFrameLayout(frame, parent, point, relativePoint)
	frame:SetSize(PP:ToUIScaled(80), PP:ToUIScaled(24))
	frame:ClearAllPoints()
	frame:SetPoint(point, parent, relativePoint, PP:ToUIScaled(0), PP:ToUIScaled(-4))
	addon.Frames.Widgets.Name:UpdateSettings(frame)
	addon.Frames.Widgets.Border:UpdateSettings(frame)
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

	local playerFrame = CreateUnitFrame("player", "MUF_PlayerFrame")
	local targetFrame = CreateUnitFrame("target", "MUF_TargetFrame")
	local petFrame = CreateUnitFrame("pet", "MUF_PetFrame")
	local targetOfTargetFrame = CreateUnitFrame("targettarget", "MUF_TargetOfTargetFrame")

	PP:RegisterForUpdate(function()
		UpdateMainFrameLayout(playerFrame, -300, -200)
		UpdateMainFrameLayout(targetFrame, 300, -200)
		UpdateAttachedFrameLayout(petFrame, playerFrame, "TOPLEFT", "BOTTOMLEFT")
		UpdateAttachedFrameLayout(targetOfTargetFrame, targetFrame, "TOPRIGHT", "BOTTOMRIGHT")
	end)

	initialized = true
end

function FrameRegistry:IsInitialized()
	return initialized
end
