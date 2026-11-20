local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}
addon.Options.Pages.Bars.Power = addon.Options.Pages.Bars.Power or {}

local Power = addon.Options.Pages.Bars.Power
local subpage

function Power:Create(page)
	local owner = page:RegisterSubPage("power", { title = "Power" })
	subpage = owner.frame

	subpage.enabledCheckbox = owner:CreateControl("Checkbox", "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(176)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].power.enabled = enabled
		addon.UpdateScheduler:Notify("powerSettingsChanged", unit)
	end)

	subpage.textureDropdown = owner:CreateControl("Dropdown", "Texture")
	subpage.textureDropdown:SetLayoutWidth(176)
	subpage.textureDropdown:SetOptions(addon.Style.Textures:GetOptions(nil, true))
	subpage.textureDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.enabledCheckbox,
		"BOTTOMLEFT",
		0,
		-24
	)
	subpage.textureDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].power.texture = value
		addon.UpdateScheduler:Notify("powerSettingsChanged", unit)
	end)

	subpage.sizeSlider = owner:CreateControl("Slider", "Size")
	subpage.sizeSlider:SetLayoutWidth(176)
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
		local unit = addon.Options:GetSelectedUnit()
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

	owner:SetStateUpdater(function(profile, unit)
		subpage:UpdateState(profile, unit)
	end)

	return owner
end
