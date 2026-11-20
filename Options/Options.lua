local addonName, addon = ...

addon.Options = addon.Options or {}
local Options = addon.Options

local initialized = false
local panel
local deferredOpen = false
local addonVersion = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""

local unitOptions = {
	{ value = "player", text = "Player" },
	{ value = "target", text = "Target" },
	{ value = "targettarget", text = "Target of Target" },
	{ value = "pet", text = "Pet" },
	{ value = "focus", text = "Focus" },
	{ value = "focustarget", text = "Focus Target" },
	{ value = "boss", text = "Boss" },
}

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

	panel = addon.OptionsUI:CreatePanel({
		name = "MichsUnitFramesOptions",
		title = "Mich's UnitFrames",
		previewEnabled = false,
		modes = { "player", "target", "targettarget", "pet", "focus", "focustarget", "boss" },
		modeOptions = unitOptions,
		activeMode = "player",
		profileGetter = function()
			return addon.Database:GetProfile()
		end,
	})

	panel.frame:HookScript("OnHide", function()
		addon.FrameRegistry:SetUnlocked(false)
	end)

	panel:SetFooterUpdater(function()
		return ("Version %s | Active Profile: |cff00ff00%s|r"):format(
			addonVersion,
			addon.Database:GetCurrentProfileName() or "Default"
		)
	end)

	self.Pages.General:Create(panel)
	self.Pages.Layout:Create(panel)
	self.Pages.Bars:Create(panel)
	self.Pages.Texts:Create(panel)
	self.Pages.Auras:Create(panel)
	self.Pages.Indicators:Create(panel)
	self.Pages.Profiles:Create(panel)
	panel:SetDefaultPage("general")
	panel:UpdateLayout()
end

function Options:GetSelectedUnit()
	return panel and panel:GetActiveMode() or "player"
end

function Options:RefreshProfile()
	if panel then
		panel:UpdateState()
	end
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
