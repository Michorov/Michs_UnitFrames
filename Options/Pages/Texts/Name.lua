local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Texts = addon.Options.Pages.Texts or {}
addon.Options.Pages.Texts.Name = addon.Options.Pages.Texts.Name or {}

local Name = addon.Options.Pages.Texts.Name
local subpage

local anchorOptions = {
	{ value = "TOPLEFT", text = "Top Left" },
	{ value = "TOP", text = "Top" },
	{ value = "TOPRIGHT", text = "Top Right" },
	{ value = "RIGHT", text = "Right" },
	{ value = "BOTTOMRIGHT", text = "Bottom Right" },
	{ value = "BOTTOM", text = "Bottom" },
	{ value = "BOTTOMLEFT", text = "Bottom Left" },
	{ value = "LEFT", text = "Left" },
	{ value = "CENTER", text = "Center" },
}

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

	subpage.anchorDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Position")
	subpage.anchorDropdown:SetLayoutWidth(174)
	subpage.anchorDropdown:SetOptions(anchorOptions)
	subpage.anchorDropdown:SetLayoutPoint("TOPLEFT", subpage.enabledCheckbox, "BOTTOMLEFT", 0, -16)
	subpage.anchorDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].nameText.anchor = value
		addon.UpdateScheduler:Notify("nameTextSettingsChanged", unit)
	end)

	subpage.fontDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Font")
	subpage.fontDropdown:SetLayoutWidth(174)
	subpage.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions())
	subpage.fontDropdown:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "TOPRIGHT", 24, 0)
	subpage.fontDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].nameText.font = value
		addon.UpdateScheduler:Notify("nameTextSettingsChanged", unit)
	end)

	subpage.offsetXSlider = addon.Options.Controls.Slider:Create(subpage, "Offset X")
	subpage.offsetXSlider:SetLayoutWidth(174)
	subpage.offsetXSlider:SetMinMaxValues(-100, 100)
	subpage.offsetXSlider:SetStep(1)
	subpage.offsetXSlider:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "BOTTOMLEFT", 0, -16)
	subpage.offsetXSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].nameText.position.x = value
		addon.UpdateScheduler:Notify("nameTextSettingsChanged", unit)
	end)

	subpage.offsetYSlider = addon.Options.Controls.Slider:Create(subpage, "Offset Y")
	subpage.offsetYSlider:SetLayoutWidth(174)
	subpage.offsetYSlider:SetMinMaxValues(-100, 100)
	subpage.offsetYSlider:SetStep(1)
	subpage.offsetYSlider:SetLayoutPoint("TOPLEFT", subpage.offsetXSlider, "TOPRIGHT", 24, 0)
	subpage.offsetYSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].nameText.position.y = value
		addon.UpdateScheduler:Notify("nameTextSettingsChanged", unit)
	end)

	subpage.colorByClassOrReactionCheckbox =
		addon.Options.Controls.Checkbox:Create(subpage, "Color by Class/Reaction")
	subpage.colorByClassOrReactionCheckbox:SetLayoutWidth(174)
	subpage.colorByClassOrReactionCheckbox:SetLayoutPoint("TOPLEFT", subpage.offsetXSlider, "BOTTOMLEFT", 0, -16)
	subpage.colorByClassOrReactionCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].nameText.colorByClassOrReaction = enabled
		addon.UpdateScheduler:Notify("nameTextSettingsChanged", unit)
	end)

	subpage.colorPicker = addon.Options.Controls.ColorPicker:Create(subpage, "Color")
	subpage.colorPicker:SetLayoutWidth(174)
	subpage.colorPicker:SetLayoutPoint("TOPLEFT", subpage.colorByClassOrReactionCheckbox, "TOPRIGHT", 24, 0)
	subpage.colorPicker:SetOnValueChanged(function(_, r, g, b, a)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].nameText.color = { r = r, g = g, b = b, a = a }
		addon.UpdateScheduler:Notify("nameTextSettingsChanged", unit)
	end)

	function subpage:UpdateState(profile, unit)
		local settings = profile.frames[unit].nameText
		self.enabledCheckbox:SetChecked(settings.enabled)
		self.anchorDropdown:SetValue(settings.anchor)
		self.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions())
		self.fontDropdown:SetValue(addon.Style.Fonts:GetName(settings.font))
		self.offsetXSlider:SetValueSilently(settings.position.x)
		self.offsetYSlider:SetValueSilently(settings.position.y)
		self.colorByClassOrReactionCheckbox:SetChecked(settings.colorByClassOrReaction)
		self.colorPicker:SetColor(settings.color)
	end

	return subpage
end
