local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Sections = addon.Options.Sections or {}
addon.Options.Sections.SideMenu = addon.Options.Sections.SideMenu or {}

local SideMenu = addon.Options.Sections.SideMenu
local PP = addon.PixelPerfect
local sideMenu

local function CreateSideMenuButton(parent, text, pageKey)
	local button = addon.Options.Controls.Button:Create(parent, text)
	button:SetLayoutSize(138, 32)
	button:SetBorderSize(0)
	button:SetFontSize(16)
	button:SetTextAlignment("LEFT", 10)
	button:SetBackdropColor(0, 0, 0, 0)

	button.hoverTexture = button:CreateTexture(nil, "BACKGROUND")
	button.hoverTexture:SetColorTexture(1, 1, 1, 0.03)
	button.hoverTexture:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	button.hoverTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	button.hoverTexture:Hide()

	button:SetScript("OnEnter", function(self)
		self.hoverTexture:Show()
	end)

	button:SetScript("OnLeave", function(self)
		self.hoverTexture:Hide()
	end)

	button:SetOnClick(function()
		addon.Options.Sections.Content:SetActivePage(pageKey)
	end)

	return button
end

function SideMenu:Ensure(parent)
	if sideMenu then
		return sideMenu
	end

	sideMenu = CreateFrame("Frame", nil, parent)

	local generalButton = CreateSideMenuButton(sideMenu, "General", "general")
	local layoutButton = CreateSideMenuButton(sideMenu, "Layout", "layout")
	local barsButton = CreateSideMenuButton(sideMenu, "Bars", "bars")
	local textsButton = CreateSideMenuButton(sideMenu, "Texts", "texts")
	local aurasButton = CreateSideMenuButton(sideMenu, "Auras", "auras")
	local indicatorsButton = CreateSideMenuButton(sideMenu, "Indicators", "indicators")
	local profilesButton = CreateSideMenuButton(sideMenu, "Profiles", "profiles")

	generalButton:SetLayoutPoint("TOPLEFT", sideMenu, "TOPLEFT", 8, -8)
	layoutButton:SetLayoutPoint("TOPLEFT", generalButton, "BOTTOMLEFT", 0, -4)
	barsButton:SetLayoutPoint("TOPLEFT", layoutButton, "BOTTOMLEFT", 0, -4)
	textsButton:SetLayoutPoint("TOPLEFT", barsButton, "BOTTOMLEFT", 0, -4)
	aurasButton:SetLayoutPoint("TOPLEFT", textsButton, "BOTTOMLEFT", 0, -4)
	indicatorsButton:SetLayoutPoint("TOPLEFT", aurasButton, "BOTTOMLEFT", 0, -4)
	profilesButton:SetLayoutPoint("BOTTOMLEFT", sideMenu, "BOTTOMLEFT", 8, 8)

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
