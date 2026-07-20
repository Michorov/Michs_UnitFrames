local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}
addon.Options.Pages.Bars.Absorbs = addon.Options.Pages.Bars.Absorbs or {}

local Absorbs = addon.Options.Pages.Bars.Absorbs
local subpage

function Absorbs:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)

	subpage.colorPicker = addon.Options.Controls.ColorPicker:Create(subpage, "Color")
	subpage.colorPicker:SetLayoutWidth(174)
	subpage.colorPicker:SetHasOpacity(true)
	subpage.colorPicker:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.colorPicker:SetOnValueChanged(function(_, r, g, b, a)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].absorbs.color = { r = r, g = g, b = b, a = a }
		addon.UpdateScheduler:Notify("absorbsSettingsChanged", unit)
	end)

	function subpage:UpdateState(profile, unit)
		self.colorPicker:SetColor(profile.frames[unit].absorbs.color)
	end

	return subpage
end
