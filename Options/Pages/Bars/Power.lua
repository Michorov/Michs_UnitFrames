local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}
addon.Options.Pages.Bars.Power = addon.Options.Pages.Bars.Power or {}

local Power = addon.Options.Pages.Bars.Power
local subpage

function Power:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)

	subpage.enabledCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(178)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].power.enabled = enabled
		addon.UpdateScheduler:Notify("powerSettingsChanged", unit)
	end)

	subpage.textureDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Texture")
	subpage.textureDropdown:SetLayoutWidth(178)
	subpage.textureDropdown:SetOptions(addon.Style.Textures:GetOptions(nil, true))
	subpage.textureDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.enabledCheckbox,
		"BOTTOMLEFT",
		0,
		-24
	)
	subpage.textureDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].power.texture = value
		addon.UpdateScheduler:Notify("powerSettingsChanged", unit)
	end)

	subpage.sizeSlider = addon.Options.Controls.Slider:Create(subpage, "Size")
	subpage.sizeSlider:SetLayoutWidth(178)
	subpage.sizeSlider:SetMinMaxValues(1, 20)
	subpage.sizeSlider:SetStep(1)
	subpage.sizeSlider:SetLayoutPoint(
		"TOPLEFT",
		subpage.textureDropdown,
		"BOTTOMLEFT",
		0,
		-24
	)
	subpage.sizeSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].power.height = value
		addon.UpdateScheduler:Notify("powerSettingsChanged", unit)
	end)

	function subpage:UpdateState(profile, unit)
		local settings = profile.frames[unit].power

		self.enabledCheckbox:SetChecked(settings.enabled)
		self.textureDropdown:SetOptions(addon.Style.Textures:GetOptions(settings.texture, true))
		self.textureDropdown:SetValue(settings.texture)
		self.sizeSlider:SetValueSilently(settings.height)
	end

	return subpage
end
