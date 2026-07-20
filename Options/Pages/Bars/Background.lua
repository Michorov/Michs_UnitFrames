local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}
addon.Options.Pages.Bars.Background = addon.Options.Pages.Bars.Background or {}

local Background = addon.Options.Pages.Bars.Background
local subpage

function Background:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)

	subpage.colorByClassOrReactionCheckbox =
		addon.Options.Controls.Checkbox:Create(subpage, "Color by Class/Reaction")
	subpage.colorByClassOrReactionCheckbox:SetLayoutWidth(174)
	subpage.colorByClassOrReactionCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.colorByClassOrReactionCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].background.colorByClassOrReaction = enabled
		addon.UpdateScheduler:Notify("backgroundSettingsChanged", unit)
	end)

	subpage.colorPicker = addon.Options.Controls.ColorPicker:Create(subpage, "Color")
	subpage.colorPicker:SetLayoutWidth(174)
	subpage.colorPicker:SetLayoutPoint("LEFT", subpage.colorByClassOrReactionCheckbox, "RIGHT", 30, 0)
	subpage.colorPicker:SetOnValueChanged(function(_, r, g, b, a)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].background.color = { r = r, g = g, b = b, a = a }
		addon.UpdateScheduler:Notify("backgroundSettingsChanged", unit)
	end)

	function subpage:UpdateState(profile, unit)
		local settings = profile.frames[unit].background
		self.colorByClassOrReactionCheckbox:SetChecked(settings.colorByClassOrReaction)
		self.colorPicker:SetColor(settings.color)
	end

	return subpage
end
