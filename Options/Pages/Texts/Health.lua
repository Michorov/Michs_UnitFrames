local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Texts = addon.Options.Pages.Texts or {}
addon.Options.Pages.Texts.Health = addon.Options.Pages.Texts.Health or {}

local Health = addon.Options.Pages.Texts.Health
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

local outlineOptions = {
	{ value = "", text = "None" },
	{ value = "OUTLINE", text = "Outline" },
	{ value = "THICKOUTLINE", text = "Thick Outline" },
	{ value = "MONOCHROME", text = "Monochrome" },
}

local colorModeOptions = {
	{ value = "static", text = "Static" },
	{ value = "classOrReaction", text = "Class/Reaction" },
}

local healthFormatOptions = {
	{ value = "abbreviated", text = "100k" },
	{ value = "percent", text = "100%" },
	{ value = "full", text = "100,000" },
	{ value = "abbreviatedPercent", text = "100k | 100%" },
	{ value = "percentAbbreviated", text = "100% | 100k" },
	{ value = "fullPercent", text = "100,000 | 100%" },
	{ value = "percentFull", text = "100% | 100,000" },
}

function Health:Create(page)
	local owner = page:RegisterSubPage("health", { title = "Health" })
	subpage = owner.frame

	subpage.enabledCheckbox = owner:CreateControl("Checkbox", "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(176)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.enabled = enabled
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.fontDropdown = owner:CreateControl("Dropdown", "Font")
	subpage.fontDropdown:SetLayoutWidth(176)
	subpage.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions(nil, true))
	subpage.fontDropdown:SetLayoutPoint("TOPLEFT", subpage.enabledCheckbox, "BOTTOMLEFT", 0, -24)
	subpage.fontDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.font = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.outlineDropdown = owner:CreateControl("Dropdown", "Font Style")
	subpage.outlineDropdown:SetLayoutWidth(176)
	subpage.outlineDropdown:SetOptions(outlineOptions)
	subpage.outlineDropdown:SetLayoutPoint("TOPLEFT", subpage.fontDropdown, "TOPRIGHT", 24, 0)
	subpage.outlineDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.outline = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.sizeSlider = owner:CreateControl("Slider", "Font Size")
	subpage.sizeSlider:SetLayoutWidth(176)
	subpage.sizeSlider:SetMinMaxValues(6, 32)
	subpage.sizeSlider:SetStep(1)
	subpage.sizeSlider:SetLayoutPoint("TOPLEFT", subpage.outlineDropdown, "TOPRIGHT", 24, 0)
	subpage.sizeSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.size = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.anchorDropdown = owner:CreateControl("Dropdown", "Position")
	subpage.anchorDropdown:SetLayoutWidth(176)
	subpage.anchorDropdown:SetOptions(anchorOptions)
	subpage.anchorDropdown:SetLayoutPoint("TOPLEFT", subpage.fontDropdown, "BOTTOMLEFT", 0, -24)
	subpage.anchorDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.anchor = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.offsetXSlider = owner:CreateControl("Slider", "Offset X")
	subpage.offsetXSlider:SetLayoutWidth(176)
	subpage.offsetXSlider:SetMinMaxValues(-100, 100)
	subpage.offsetXSlider:SetStep(1)
	subpage.offsetXSlider:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "TOPRIGHT", 24, 0)
	subpage.offsetXSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.position.x = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.offsetYSlider = owner:CreateControl("Slider", "Offset Y")
	subpage.offsetYSlider:SetLayoutWidth(176)
	subpage.offsetYSlider:SetMinMaxValues(-100, 100)
	subpage.offsetYSlider:SetStep(1)
	subpage.offsetYSlider:SetLayoutPoint("TOPLEFT", subpage.offsetXSlider, "TOPRIGHT", 24, 0)
	subpage.offsetYSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.position.y = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.colorModeDropdown = owner:CreateControl("Dropdown", "Color Mode")
	subpage.colorModeDropdown:SetLayoutWidth(176)
	subpage.colorModeDropdown:SetOptions(colorModeOptions)
	subpage.colorModeDropdown:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "BOTTOMLEFT", 0, -24)
	subpage.colorModeDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.colorByClassOrReaction = value == "classOrReaction"
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.colorPicker = owner:CreateControl("ColorPicker", "Static Color")
	subpage.colorPicker:SetLayoutWidth(176)
	subpage.colorPicker:SetLayoutPoint("BOTTOMLEFT", subpage.colorModeDropdown, "BOTTOMRIGHT", 24, 0)
	subpage.colorPicker:SetOnValueChanged(function(_, r, g, b, a)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.color = { r = r, g = g, b = b, a = a }
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.healthFormatDropdown = owner:CreateControl("Dropdown", "Health Format")
	subpage.healthFormatDropdown:SetLayoutWidth(176)
	subpage.healthFormatDropdown:SetOptions(healthFormatOptions)
	subpage.healthFormatDropdown:SetLayoutPoint("TOPLEFT", subpage.colorModeDropdown, "BOTTOMLEFT", 0, -24)
	subpage.healthFormatDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.format = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	function subpage:UpdateState(profile, unit)
		local settings = profile.frames[unit].healthText
		self.enabledCheckbox:SetChecked(settings.enabled)
		self.anchorDropdown:SetValue(settings.anchor)
		self.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions(settings.font, true))
		self.fontDropdown:SetValue(settings.font)
		self.outlineDropdown:SetValue(settings.outline)
		self.sizeSlider:SetValueSilently(settings.size)
		self.offsetXSlider:SetValueSilently(settings.position.x)
		self.offsetYSlider:SetValueSilently(settings.position.y)
		self.colorModeDropdown:SetValue(settings.colorByClassOrReaction and "classOrReaction" or "static")
		self.colorPicker:SetColor(settings.color)
		self.healthFormatDropdown:SetValue(settings.format)
	end

	owner:SetStateUpdater(function(profile, unit)
		subpage:UpdateState(profile, unit)
	end)

	return owner
end
