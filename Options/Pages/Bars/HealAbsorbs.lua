local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}
addon.Options.Pages.Bars.HealAbsorbs = addon.Options.Pages.Bars.HealAbsorbs or {}

local HealAbsorbs = addon.Options.Pages.Bars.HealAbsorbs
local PP = addon.PixelPerfect
local subpage

function HealAbsorbs:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)
	subpage.styleHeader = addon.Options:CreateSectionHeader(subpage, "Style")

	subpage.enabledCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(178)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healAbsorbs.enabled = enabled
		addon.UpdateScheduler:Notify("healAbsorbsSettingsChanged", unit)
	end)

	subpage.colorPicker = addon.Options.Controls.ColorPicker:Create(subpage, "Color")
	subpage.colorPicker:SetLayoutWidth(178)
	subpage.colorPicker:SetHasOpacity(true)
	subpage.colorPicker:SetLayoutPoint("TOPLEFT", subpage.styleHeader, "BOTTOMLEFT", 0, -8)
	subpage.colorPicker:SetOnValueChanged(function(_, r, g, b, a)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healAbsorbs.color = { r = r, g = g, b = b, a = a }
		addon.UpdateScheduler:Notify("healAbsorbsSettingsChanged", unit)
	end)

	function subpage:UpdateLayout()
		self.styleHeader:ClearAllPoints()
		self.styleHeader:SetPoint("TOPLEFT", self.enabledCheckbox, "BOTTOMLEFT", 0, PP:ToUIScaled(-24))

		addon.Options:UpdateSectionHeader(self.styleHeader)
	end

	function subpage:UpdateState(profile, unit)
		local settings = profile.frames[unit].healAbsorbs
		self.enabledCheckbox:SetChecked(settings.enabled)
		self.colorPicker:SetColor(settings.color)
	end

	return subpage
end
