local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}

local Bars = addon.Options.Pages.Bars

function Bars:Create(panel)
	local page = panel:RegisterPage("bars", {
		title = "Bars",
		showHeader = true,
		showSubpageDropdown = true,
		showModeSwitch = true,
		modeSwitchType = "dropdown",
	})

	self.Health:Create(page)
	self.Power:Create(page)
	self.Cast:Create(page)
	self.Background:Create(page)
	self.Absorbs:Create(page)
	self.HealAbsorbs:Create(page)

	return page
end
