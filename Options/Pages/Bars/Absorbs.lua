local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}
addon.Options.Pages.Bars.Absorbs = addon.Options.Pages.Bars.Absorbs or {}

local Absorbs = addon.Options.Pages.Bars.Absorbs
local subpage

function Absorbs:Create(page)
	local owner = page:RegisterSubPage("absorbs", { title = "Absorbs" })
	subpage = owner.frame

	subpage.enabledCheckbox = owner:CreateControl("Checkbox", "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(176)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].absorbs.enabled = enabled
		addon.UpdateScheduler:Notify("absorbsSettingsChanged", unit)
	end)

	subpage.colorPicker = owner:CreateControl("ColorPicker", "Color")
	subpage.colorPicker:SetLayoutWidth(176)
	subpage.colorPicker:SetHasOpacity(true)
	subpage.colorPicker:SetLayoutPoint("TOPLEFT", subpage.enabledCheckbox, "BOTTOMLEFT", 0, -24)
	subpage.colorPicker:SetOnValueChanged(function(_, r, g, b, a)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].absorbs.color = { r = r, g = g, b = b, a = a }
		addon.UpdateScheduler:Notify("absorbsSettingsChanged", unit)
	end)

	function subpage:UpdateState(profile, unit)
		local settings = profile.frames[unit].absorbs
		self.enabledCheckbox:SetChecked(settings.enabled)
		self.colorPicker:SetColor(settings.color)
	end

	owner:SetStateUpdater(function(profile, unit)
		subpage:UpdateState(profile, unit)
	end)

	return owner
end
