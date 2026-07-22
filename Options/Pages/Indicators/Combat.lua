local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Indicators = addon.Options.Pages.Indicators or {}
addon.Options.Pages.Indicators.Combat = addon.Options.Pages.Indicators.Combat or {}

local Combat = addon.Options.Pages.Indicators.Combat
local subpage

function Combat:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)

	subpage.enabledCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(178)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.player.combatIndicator.enabled = enabled
		addon.UpdateScheduler:Notify("combatIndicatorSettingsChanged", "player")
	end)

	function subpage:UpdateState(profile)
		self.enabledCheckbox:SetChecked(profile.frames.player.combatIndicator.enabled)
	end

	return subpage
end
