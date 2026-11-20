local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Indicators = addon.Options.Pages.Indicators or {}

local Indicators = addon.Options.Pages.Indicators

function Indicators:Create(panel)
	local page = panel:RegisterPage("indicators", {
		title = "Indicators",
		showHeader = true,
		showSubpageDropdown = true,
		showModeSwitch = true,
		modeSwitchType = "dropdown",
	})

	self.RaidMarker:Create(page)
	self.Classification:Create(page)
	self.GroupStatus:Create(page)
	self.PetHappiness:Create(page)
	self.Combat:Create(page)
	page:SetActiveSubPage("combat")

	return page
end
