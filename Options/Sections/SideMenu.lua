local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Sections = addon.Options.Sections or {}
addon.Options.Sections.SideMenu = addon.Options.Sections.SideMenu or {}

local SideMenu = addon.Options.Sections.SideMenu
local PP = addon.PixelPerfect
local sideMenu

function SideMenu:Ensure(parent)
	if sideMenu then
		return sideMenu
	end

	sideMenu = CreateFrame("Frame", nil, parent)
	sideMenu.rightBorder = sideMenu:CreateTexture(nil, "OVERLAY")
	sideMenu.rightBorder:SetColorTexture(0.15, 0.17, 0.20, 1)

	return sideMenu
end

function SideMenu:UpdateLayout()
	sideMenu.rightBorder:ClearAllPoints()
	sideMenu.rightBorder:SetPoint("TOPRIGHT", sideMenu, "TOPRIGHT", 0, PP:ToUIScaled(-8))
	sideMenu.rightBorder:SetPoint("BOTTOMRIGHT", sideMenu, "BOTTOMRIGHT", 0, PP:ToUIScaled(8))
	sideMenu.rightBorder:SetWidth(PP:ToUIScaled(1))
end
