local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Texts = addon.Options.Pages.Texts or {}
addon.Options.Pages.Texts.Health = addon.Options.Pages.Texts.Health or {}

local Health = addon.Options.Pages.Texts.Health
local PP = addon.PixelPerfect
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

function Health:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)
	subpage.typographyHeader = addon.Options:CreateSectionHeader(subpage, "Typography")
	subpage.positionHeader = addon.Options:CreateSectionHeader(subpage, "Layout")
	subpage.colorHeader = addon.Options:CreateSectionHeader(subpage, "Style")

	subpage.enabledCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(178)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.enabled = enabled
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.fontDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Font")
	subpage.fontDropdown:SetLayoutWidth(178)
	subpage.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions())
	subpage.fontDropdown:SetLayoutPoint("TOPLEFT", subpage.typographyHeader, "BOTTOMLEFT", 0, -8)
	subpage.fontDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.font = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.outlineDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Font Style")
	subpage.outlineDropdown:SetLayoutWidth(178)
	subpage.outlineDropdown:SetOptions(outlineOptions)
	subpage.outlineDropdown:SetLayoutPoint("TOPLEFT", subpage.fontDropdown, "TOPRIGHT", 24, 0)
	subpage.outlineDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.outline = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.sizeSlider = addon.Options.Controls.Slider:Create(subpage, "Font Size")
	subpage.sizeSlider:SetLayoutWidth(178)
	subpage.sizeSlider:SetMinMaxValues(6, 32)
	subpage.sizeSlider:SetStep(1)
	subpage.sizeSlider:SetLayoutPoint("TOPLEFT", subpage.outlineDropdown, "TOPRIGHT", 24, 0)
	subpage.sizeSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.size = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.anchorDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Position")
	subpage.anchorDropdown:SetLayoutWidth(178)
	subpage.anchorDropdown:SetOptions(anchorOptions)
	subpage.anchorDropdown:SetLayoutPoint("TOPLEFT", subpage.positionHeader, "BOTTOMLEFT", 0, -8)
	subpage.anchorDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.anchor = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.offsetXSlider = addon.Options.Controls.Slider:Create(subpage, "Offset X")
	subpage.offsetXSlider:SetLayoutWidth(178)
	subpage.offsetXSlider:SetMinMaxValues(-100, 100)
	subpage.offsetXSlider:SetStep(1)
	subpage.offsetXSlider:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "TOPRIGHT", 24, 0)
	subpage.offsetXSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.position.x = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.offsetYSlider = addon.Options.Controls.Slider:Create(subpage, "Offset Y")
	subpage.offsetYSlider:SetLayoutWidth(178)
	subpage.offsetYSlider:SetMinMaxValues(-100, 100)
	subpage.offsetYSlider:SetStep(1)
	subpage.offsetYSlider:SetLayoutPoint("TOPLEFT", subpage.offsetXSlider, "TOPRIGHT", 24, 0)
	subpage.offsetYSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.position.y = value
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.colorModeDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Color Mode")
	subpage.colorModeDropdown:SetLayoutWidth(178)
	subpage.colorModeDropdown:SetOptions(colorModeOptions)
	subpage.colorModeDropdown:SetLayoutPoint("TOPLEFT", subpage.colorHeader, "BOTTOMLEFT", 0, -8)
	subpage.colorModeDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.colorByClassOrReaction = value == "classOrReaction"
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	subpage.colorPicker = addon.Options.Controls.ColorPicker:Create(subpage, "Static Color")
	subpage.colorPicker:SetLayoutWidth(178)
	subpage.colorPicker:SetLayoutPoint("BOTTOMLEFT", subpage.colorModeDropdown, "BOTTOMRIGHT", 24, 0)
	subpage.colorPicker:SetOnValueChanged(function(_, r, g, b, a)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].healthText.color = { r = r, g = g, b = b, a = a }
		addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
	end)

	function subpage:UpdateLayout()
		self.typographyHeader:ClearAllPoints()
		self.typographyHeader:SetPoint("TOPLEFT", self.enabledCheckbox, "BOTTOMLEFT", 0, PP:ToUIScaled(-24))

		self.positionHeader:ClearAllPoints()
		self.positionHeader:SetPoint("TOPLEFT", self.fontDropdown, "BOTTOMLEFT", 0, PP:ToUIScaled(-24))

		self.colorHeader:ClearAllPoints()
		self.colorHeader:SetPoint("TOPLEFT", self.anchorDropdown, "BOTTOMLEFT", 0, PP:ToUIScaled(-24))

		addon.Options:UpdateSectionHeader(self.typographyHeader)
		addon.Options:UpdateSectionHeader(self.positionHeader)
		addon.Options:UpdateSectionHeader(self.colorHeader)
	end

	function subpage:UpdateState(profile, unit)
		local settings = profile.frames[unit].healthText
		self.enabledCheckbox:SetChecked(settings.enabled)
		self.anchorDropdown:SetValue(settings.anchor)
		self.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions())
		self.fontDropdown:SetValue(addon.Style.Fonts:GetName(settings.font))
		self.outlineDropdown:SetValue(settings.outline)
		self.sizeSlider:SetValueSilently(settings.size)
		self.offsetXSlider:SetValueSilently(settings.position.x)
		self.offsetYSlider:SetValueSilently(settings.position.y)
		self.colorModeDropdown:SetValue(settings.colorByClassOrReaction and "classOrReaction" or "static")
		self.colorPicker:SetColor(settings.color)
	end

	return subpage
end
