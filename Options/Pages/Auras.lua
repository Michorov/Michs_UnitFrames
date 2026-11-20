local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Auras = addon.Options.Pages.Auras or {}

local Auras = addon.Options.Pages.Auras

function Auras:Create(panel)
	local page = panel:RegisterPage("auras", {
		title = "Auras",
		showHeader = true,
		showSubpageDropdown = true,
		showModeSwitch = true,
		modeSwitchType = "dropdown",
	})

	self.Buffs:Create(page)
	self.Debuffs:Create(page)

	return page
end
