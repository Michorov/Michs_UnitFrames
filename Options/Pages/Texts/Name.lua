local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Texts = addon.Options.Pages.Texts or {}
addon.Options.Pages.Texts.Name = addon.Options.Pages.Texts.Name or {}

local Name = addon.Options.Pages.Texts.Name
local subpage

function Name:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)

	subpage.enabledCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(174)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].nameText.enabled = enabled
		addon.UpdateScheduler:Notify("nameTextSettingsChanged", unit)
	end)

	function subpage:UpdateState(profile, unit)
		self.enabledCheckbox:SetChecked(profile.frames[unit].nameText.enabled)
	end

	return subpage
end
