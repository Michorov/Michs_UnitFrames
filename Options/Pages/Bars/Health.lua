local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}
addon.Options.Pages.Bars.Health = addon.Options.Pages.Bars.Health or {}

local Health = addon.Options.Pages.Bars.Health
local subpage

local colorModeOptions = {
	{ value = "static", text = "Static" },
	{ value = "classOrReaction", text = "Class/Reaction" },
}

function Health:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)
	subpage.styleHeader = addon.Options:CreateSectionHeader(subpage, "Style")
	subpage.styleHeader:SetPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)

	subpage.colorModeDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Color Mode")
	subpage.colorModeDropdown:SetLayoutWidth(178)
	subpage.colorModeDropdown:SetOptions(colorModeOptions)
	subpage.colorModeDropdown:SetLayoutPoint("TOPLEFT", subpage.styleHeader, "BOTTOMLEFT", 0, -8)
	subpage.colorModeDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].health.colorByClassOrReaction = value == "classOrReaction"
		addon.UpdateScheduler:Notify("healthSettingsChanged", unit)
	end)

	subpage.colorPicker = addon.Options.Controls.ColorPicker:Create(subpage, "Static Color")
	subpage.colorPicker:SetLayoutWidth(178)
	subpage.colorPicker:SetLayoutPoint("BOTTOMLEFT", subpage.colorModeDropdown, "BOTTOMRIGHT", 24, 0)
	subpage.colorPicker:SetOnValueChanged(function(_, r, g, b, a)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].health.color = { r = r, g = g, b = b, a = a }
		addon.UpdateScheduler:Notify("healthSettingsChanged", unit)
	end)

	function subpage:UpdateLayout()
		addon.Options:UpdateSectionHeader(self.styleHeader)
	end

	function subpage:UpdateState(profile, unit)
		local settings = profile.frames[unit].health
		self.colorModeDropdown:SetValue(settings.colorByClassOrReaction and "classOrReaction" or "static")
		self.colorPicker:SetColor(settings.color)
	end

	return subpage
end
