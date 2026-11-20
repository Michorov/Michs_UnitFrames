local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Indicators = addon.Options.Pages.Indicators or {}
addon.Options.Pages.Indicators.PetHappiness = addon.Options.Pages.Indicators.PetHappiness or {}

local PetHappiness = addon.Options.Pages.Indicators.PetHappiness
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

local sizeModeOptions = {
	{ value = "auto", text = "Auto" },
	{ value = "manual", text = "Manual" },
}

function PetHappiness:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)
	subpage.unavailableText = subpage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	subpage.unavailableText:SetPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.unavailableText:SetJustifyH("LEFT")
	subpage.unavailableText:SetTextColor(0.72, 0.74, 0.78, 1)
	subpage.unavailableText:SetText("Pet Happiness indicator not available for this frame")
	subpage.unavailableText:Hide()

	subpage.enabledCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(178)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.pet.petHappiness.enabled = enabled
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.happyCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Happy")
	subpage.happyCheckbox:SetLayoutWidth(178)
	subpage.happyCheckbox:SetLayoutPoint("TOPLEFT", subpage.enabledCheckbox, "BOTTOMLEFT", 0, -24)
	subpage.happyCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.pet.petHappiness.happy = enabled
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.neutralCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Neutral")
	subpage.neutralCheckbox:SetLayoutWidth(178)
	subpage.neutralCheckbox:SetLayoutPoint("TOPLEFT", subpage.happyCheckbox, "TOPRIGHT", 24, 0)
	subpage.neutralCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.pet.petHappiness.neutral = enabled
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.unhappyCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Unhappy")
	subpage.unhappyCheckbox:SetLayoutWidth(178)
	subpage.unhappyCheckbox:SetLayoutPoint("TOPLEFT", subpage.neutralCheckbox, "TOPRIGHT", 24, 0)
	subpage.unhappyCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.pet.petHappiness.unhappy = enabled
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.anchorDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Position")
	subpage.anchorDropdown:SetLayoutWidth(178)
	subpage.anchorDropdown:SetOptions(anchorOptions)
	subpage.anchorDropdown:SetLayoutPoint("TOPLEFT", subpage.happyCheckbox, "BOTTOMLEFT", 0, -24)
	subpage.anchorDropdown:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.pet.petHappiness.anchor = value
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.offsetXSlider = addon.Options.Controls.Slider:Create(subpage, "Offset X")
	subpage.offsetXSlider:SetLayoutWidth(178)
	subpage.offsetXSlider:SetMinMaxValues(-100, 100)
	subpage.offsetXSlider:SetStep(1)
	subpage.offsetXSlider:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "TOPRIGHT", 24, 0)
	subpage.offsetXSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.pet.petHappiness.position.x = value
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.offsetYSlider = addon.Options.Controls.Slider:Create(subpage, "Offset Y")
	subpage.offsetYSlider:SetLayoutWidth(178)
	subpage.offsetYSlider:SetMinMaxValues(-100, 100)
	subpage.offsetYSlider:SetStep(1)
	subpage.offsetYSlider:SetLayoutPoint("TOPLEFT", subpage.offsetXSlider, "TOPRIGHT", 24, 0)
	subpage.offsetYSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.pet.petHappiness.position.y = value
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.sizeModeDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Icon Size")
	subpage.sizeModeDropdown:SetLayoutWidth(178)
	subpage.sizeModeDropdown:SetOptions(sizeModeOptions)
	subpage.sizeModeDropdown:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "BOTTOMLEFT", 0, -24)
	subpage.sizeModeDropdown:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.pet.petHappiness.sizeMode = value
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.customSizeSlider = addon.Options.Controls.Slider:Create(subpage, "Custom Size")
	subpage.customSizeSlider:SetLayoutWidth(178)
	subpage.customSizeSlider:SetMinMaxValues(8, 64)
	subpage.customSizeSlider:SetStep(1)
	subpage.customSizeSlider:SetLayoutPoint("TOPLEFT", subpage.sizeModeDropdown, "TOPRIGHT", 24, 0)
	subpage.customSizeSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.pet.petHappiness.customSize = value
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	function subpage:UpdateLayout()
		self.unavailableText:SetFont("Fonts\\ARIALN.TTF", PP:ToUI(14), "")
	end

	function subpage:UpdateState(profile, unit)
		local available = unit == "pet"
		self.enabledCheckbox:SetShown(available)
		self.happyCheckbox:SetShown(available)
		self.neutralCheckbox:SetShown(available)
		self.unhappyCheckbox:SetShown(available)
		self.anchorDropdown:SetShown(available)
		self.offsetXSlider:SetShown(available)
		self.offsetYSlider:SetShown(available)
		self.sizeModeDropdown:SetShown(available)
		self.customSizeSlider:SetShown(available)
		self.unavailableText:SetShown(not available)

		if not available then
			return
		end

		local settings = profile.frames.pet.petHappiness
		self.enabledCheckbox:SetChecked(settings.enabled)
		self.happyCheckbox:SetChecked(settings.happy)
		self.neutralCheckbox:SetChecked(settings.neutral)
		self.unhappyCheckbox:SetChecked(settings.unhappy)
		self.anchorDropdown:SetValue(settings.anchor)
		self.offsetXSlider:SetValueSilently(settings.position.x)
		self.offsetYSlider:SetValueSilently(settings.position.y)
		self.sizeModeDropdown:SetValue(settings.sizeMode)
		self.customSizeSlider:SetValueSilently(settings.customSize)
	end

	subpage:UpdateLayout()

	return subpage
end
