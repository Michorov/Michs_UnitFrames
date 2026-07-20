local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Texts = addon.Options.Pages.Texts or {}
addon.Options.Pages.Texts.Health = addon.Options.Pages.Texts.Health or {}

local Health = addon.Options.Pages.Texts.Health
local subpage

function Health:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)

	subpage.enabledCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(174)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.enabled = enabled
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	function subpage:UpdateState(profile, unit)
		self.enabledCheckbox:SetChecked(profile.frames[unit].healthText.enabled)
	end

	return subpage
end
