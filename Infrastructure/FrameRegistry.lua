local _, addon = ...

local FrameRegistry = {}
addon.FrameRegistry = FrameRegistry

local PP = addon.PixelPerfect
local initialized = false
local map = {}

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

	local background = playerFrame:CreateTexture(nil, "BACKGROUND")
	background:SetAllPoints(playerFrame)
	background:SetColorTexture(0.15, 0.15, 0.15, 1)
	playerFrame.background = background

	map["player"] = playerFrame

	PP:RegisterForUpdate(function()
		playerFrame:SetSize(PP:ToUIScaled(140), PP:ToUIScaled(32))
		PP:CenterElement(playerFrame, UIParent, PP:ToUIScaled(0), PP:ToUIScaled(0))
	end)

	initialized = true
end
