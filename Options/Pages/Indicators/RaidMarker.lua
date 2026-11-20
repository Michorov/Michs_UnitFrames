local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Indicators = addon.Options.Pages.Indicators or {}
addon.Options.Pages.Indicators.RaidMarker = addon.Options.Pages.Indicators.RaidMarker or {}

local RaidMarker = addon.Options.Pages.Indicators.RaidMarker
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

function RaidMarker:Create(page)
	local owner = page:RegisterSubPage("raidMarker", { title = "Raid Marker" })
	subpage = owner.frame

	subpage.enabledCheckbox = owner:CreateControl("Checkbox", "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(176)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].raidMarker.enabled = enabled
		addon.UpdateScheduler:Notify("raidMarkerSettingsChanged", unit)
	end)

	subpage.anchorDropdown = owner:CreateControl("Dropdown", "Position")
	subpage.anchorDropdown:SetLayoutWidth(176)
	subpage.anchorDropdown:SetOptions(anchorOptions)
	subpage.anchorDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.enabledCheckbox,
		"BOTTOMLEFT",
		0,
		-24
	)
	subpage.anchorDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].raidMarker.anchor = value
		addon.UpdateScheduler:Notify("raidMarkerSettingsChanged", unit)
	end)

	subpage.offsetXSlider = owner:CreateControl("Slider", "Offset X")
	subpage.offsetXSlider:SetLayoutWidth(176)
	subpage.offsetXSlider:SetMinMaxValues(-100, 100)
	subpage.offsetXSlider:SetStep(1)
	subpage.offsetXSlider:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "TOPRIGHT", 24, 0)
	subpage.offsetXSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].raidMarker.position.x = value
		addon.UpdateScheduler:Notify("raidMarkerSettingsChanged", unit)
	end)

	subpage.offsetYSlider = owner:CreateControl("Slider", "Offset Y")
	subpage.offsetYSlider:SetLayoutWidth(176)
	subpage.offsetYSlider:SetMinMaxValues(-100, 100)
	subpage.offsetYSlider:SetStep(1)
	subpage.offsetYSlider:SetLayoutPoint("TOPLEFT", subpage.offsetXSlider, "TOPRIGHT", 24, 0)
	subpage.offsetYSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].raidMarker.position.y = value
		addon.UpdateScheduler:Notify("raidMarkerSettingsChanged", unit)
	end)

	subpage.sizeSlider = owner:CreateControl("Slider", "Size")
	subpage.sizeSlider:SetLayoutWidth(176)
	subpage.sizeSlider:SetMinMaxValues(8, 64)
	subpage.sizeSlider:SetStep(1)
	subpage.sizeSlider:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "BOTTOMLEFT", 0, -24)
	subpage.sizeSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].raidMarker.size = value
		addon.UpdateScheduler:Notify("raidMarkerSettingsChanged", unit)
	end)

	function subpage:UpdateState(profile, unit)
		local settings = profile.frames[unit].raidMarker
		self.enabledCheckbox:SetChecked(settings.enabled)
		self.anchorDropdown:SetValue(settings.anchor)
		self.offsetXSlider:SetValueSilently(settings.position.x)
		self.offsetYSlider:SetValueSilently(settings.position.y)
		self.sizeSlider:SetValueSilently(settings.size)
	end

	owner:SetStateUpdater(function(profile, unit)
		subpage:UpdateState(profile, unit)
	end)

	return owner
end
