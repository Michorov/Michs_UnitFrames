local _, addon = ...

addon.Options = addon.Options or {}
local Options = addon.Options

local PP = addon.PixelPerfect
local initialized = false
local panel
local deferredOpen = false
local panelOffsetX = 0
local panelOffsetY = 0

function Options:CreateSectionHeader(parent, text)
	local header = CreateFrame("Frame", nil, parent)
	header.label = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	header.label:SetTextColor(0.72, 0.72, 0.75, 1)
	header.label:SetText(text)
	header.line = header:CreateTexture(nil, "ARTWORK")
	header.line:SetColorTexture(0.15, 0.17, 0.20, 1)
	return header
end

function Options:UpdateSectionHeader(header)
	header:SetSize(PP:ToUIScaled(582), PP:ToUIScaled(16))
	header.label:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(12), "")
	header.label:ClearAllPoints()
	header.label:SetPoint("LEFT", header, "LEFT", 0, 0)
	header.line:ClearAllPoints()
	header.line:SetPoint("LEFT", header.label, "RIGHT", PP:ToUIScaled(12), 0)
	header.line:SetPoint("RIGHT", header, "RIGHT", 0, 0)
	header.line:SetHeight(PP:ToUIScaled(1))
end

function Options:Initialize()
	if initialized then
		error("Options already initialized", 2)
	end

	SLASH_MICHSUNITFRAMES1 = "/muf"
	SlashCmdList["MICHSUNITFRAMES"] = function(message)
		local normalizedMessage = (message or ""):match("^%s*(.-)%s*$")
		if normalizedMessage ~= "" then
			print("|cffff9900Mich's UnitFrames:|r Unknown command. Use /muf")
			return
		end

		if Options:IsOpen() then
			Options:Close()
		else
			Options:Open()
		end
	end

	initialized = true
end

function Options:Ensure()
	if panel then
		return
	end

	panel = CreateFrame("Frame", "MichsUnitFramesOptionsPanel", UIParent, "BackdropTemplate")
	panel:Hide()
	panel:SetFrameStrata("DIALOG")
	panel:EnableMouse(true)
	panel:SetMovable(true)
	panel:SetClampedToScreen(true)
	panel:RegisterForDrag("LeftButton")

	panel:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
	})
	panel:SetBackdropColor(0.05, 0.07, 0.09, 0.96)

	panel.topBorder = panel:CreateTexture(nil, "OVERLAY")
	panel.topBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	panel.topBorder:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
	panel.topBorder:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)

	panel.bottomBorder = panel:CreateTexture(nil, "OVERLAY")
	panel.bottomBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	panel.bottomBorder:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
	panel.bottomBorder:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)

	panel.leftBorder = panel:CreateTexture(nil, "OVERLAY")
	panel.leftBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	panel.leftBorder:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
	panel.leftBorder:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)

	panel.rightBorder = panel:CreateTexture(nil, "OVERLAY")
	panel.rightBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	panel.rightBorder:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
	panel.rightBorder:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)

	panel.header = addon.Options.Sections.Header:Ensure(panel)
	panel.header:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
	panel.header:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)

	panel.statusBar = addon.Options.Sections.StatusBar:Ensure(panel)
	panel.statusBar:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
	panel.statusBar:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)

	panel.sideMenu = addon.Options.Sections.SideMenu:Ensure(panel)
	panel.sideMenu:SetPoint("TOPLEFT", panel.header, "BOTTOMLEFT", 0, 0)
	panel.sideMenu:SetPoint("BOTTOMLEFT", panel.statusBar, "TOPLEFT", 0, 0)

	panel.content = addon.Options.Sections.Content:Ensure(panel)
	panel.content:SetPoint("TOPLEFT", panel.sideMenu, "TOPRIGHT", 0, 0)
	panel.content:SetPoint("TOPRIGHT", panel.header, "BOTTOMRIGHT", 0, 0)
	panel.content:SetPoint("BOTTOMRIGHT", panel.statusBar, "TOPRIGHT", 0, 0)

	if not tContains(UISpecialFrames, panel:GetName()) then
		table.insert(UISpecialFrames, panel:GetName())
	end

	panel:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)

	panel:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()

		local panelCenterX, panelCenterY = self:GetCenter()
		local parentCenterX, parentCenterY = UIParent:GetCenter()
		panelOffsetX = panelCenterX - parentCenterX
		panelOffsetY = panelCenterY - parentCenterY
		PP:CenterElement(self, UIParent, panelOffsetX, panelOffsetY)
	end)

	PP:RegisterForUpdate(function()
		Options:UpdateLayout()
	end)
end

function Options:UpdateLayout()
	panel:SetSize(PP:ToUIScaled(800), PP:ToUIScaled(500))
	PP:CenterElement(panel, UIParent, panelOffsetX, panelOffsetY)

	local borderThickness = PP:ToUIScaled(1)
	panel.topBorder:SetHeight(borderThickness)
	panel.bottomBorder:SetHeight(borderThickness)
	panel.leftBorder:SetWidth(borderThickness)
	panel.rightBorder:SetWidth(borderThickness)

	panel.header:SetHeight(PP:ToUIScaled(40))
	panel.statusBar:SetHeight(PP:ToUIScaled(32))
	panel.sideMenu:SetWidth(PP:ToUIScaled(154))

	addon.Options.Sections.Header:UpdateLayout()
	addon.Options.Sections.StatusBar:UpdateLayout()
	addon.Options.Sections.SideMenu:UpdateLayout()
	addon.Options.Sections.Content:UpdateLayout()
end

function Options:IsOpen()
	return panel and panel:IsShown() or false
end

function Options:ShouldOpenAfterCombat()
	return deferredOpen
end

function Options:Open()
	if InCombatLockdown() then
		deferredOpen = true
		print("|cffff9900Mich's UnitFrames:|r Options will open after combat.")
		return
	end

	deferredOpen = false
	self:Ensure()
	panel:Show()
end

function Options:Close()
	if panel then
		panel:Hide()
	end
end
