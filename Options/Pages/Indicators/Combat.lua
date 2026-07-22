local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Indicators = addon.Options.Pages.Indicators or {}
addon.Options.Pages.Indicators.Combat = addon.Options.Pages.Indicators.Combat or {}

local Combat = addon.Options.Pages.Indicators.Combat
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

function Combat:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)

	subpage.enabledCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(178)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.player.combatIndicator.enabled = enabled
		addon.UpdateScheduler:Notify("combatIndicatorSettingsChanged", "player")
	end)

	subpage.anchorDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Position")
	subpage.anchorDropdown:SetLayoutWidth(178)
	subpage.anchorDropdown:SetOptions(anchorOptions)
	subpage.anchorDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.enabledCheckbox,
		"BOTTOMLEFT",
		0,
		-24
	)
	subpage.anchorDropdown:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.combatIndicator.anchor = value
		addon.UpdateScheduler:Notify("combatIndicatorSettingsChanged", "player")
	end)

	subpage.offsetXSlider = addon.Options.Controls.Slider:Create(subpage, "Offset X")
	subpage.offsetXSlider:SetLayoutWidth(178)
	subpage.offsetXSlider:SetMinMaxValues(-100, 100)
	subpage.offsetXSlider:SetStep(1)
	subpage.offsetXSlider:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "TOPRIGHT", 24, 0)
	subpage.offsetXSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.combatIndicator.position.x = value
		addon.UpdateScheduler:Notify("combatIndicatorSettingsChanged", "player")
	end)

	subpage.offsetYSlider = addon.Options.Controls.Slider:Create(subpage, "Offset Y")
	subpage.offsetYSlider:SetLayoutWidth(178)
	subpage.offsetYSlider:SetMinMaxValues(-100, 100)
	subpage.offsetYSlider:SetStep(1)
	subpage.offsetYSlider:SetLayoutPoint("TOPLEFT", subpage.offsetXSlider, "TOPRIGHT", 24, 0)
	subpage.offsetYSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.combatIndicator.position.y = value
		addon.UpdateScheduler:Notify("combatIndicatorSettingsChanged", "player")
	end)

	subpage.sizeSlider = addon.Options.Controls.Slider:Create(subpage, "Size")
	subpage.sizeSlider:SetLayoutWidth(178)
	subpage.sizeSlider:SetMinMaxValues(8, 64)
	subpage.sizeSlider:SetStep(1)
	subpage.sizeSlider:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "BOTTOMLEFT", 0, -24)
	subpage.sizeSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.combatIndicator.size = value
		addon.UpdateScheduler:Notify("combatIndicatorSettingsChanged", "player")
	end)

	function subpage:UpdateState(profile)
		local settings = profile.frames.player.combatIndicator
		self.enabledCheckbox:SetChecked(settings.enabled)
		self.anchorDropdown:SetValue(settings.anchor)
		self.offsetXSlider:SetValueSilently(settings.position.x)
		self.offsetYSlider:SetValueSilently(settings.position.y)
		self.sizeSlider:SetValueSilently(settings.size)
	end

	return subpage
end
