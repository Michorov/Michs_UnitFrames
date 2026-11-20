local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Texts = addon.Options.Pages.Texts or {}

local Texts = addon.Options.Pages.Texts

function Texts:Create(panel)
	local page = panel:RegisterPage("texts", {
		title = "Texts",
		showHeader = true,
		showSubpageDropdown = true,
		showModeSwitch = true,
		modeSwitchType = "dropdown",
	})

	self.Name:Create(page)
	self.Level:Create(page)
	self.Health:Create(page)
	self.Power:Create(page)

	return page
end
