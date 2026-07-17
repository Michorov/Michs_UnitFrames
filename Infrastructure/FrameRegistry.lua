local _, addon = ...

local FrameRegistry = {}
addon.FrameRegistry = FrameRegistry

local initialized = false

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

	self.playerFrame = playerFrame
	initialized = true
end
