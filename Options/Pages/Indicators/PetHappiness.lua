local _, addon = ...

local OptionsUILib = LibStub("MichsOptionsUILib-1.0")

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Indicators = addon.Options.Pages.Indicators or {}
addon.Options.Pages.Indicators.PetHappiness = addon.Options.Pages.Indicators.PetHappiness or {}

local PetHappiness = addon.Options.Pages.Indicators.PetHappiness
local PP = addon.OptionsUI.PP
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

function PetHappiness:Create(page)
	local owner = page:RegisterSubPage("petHappiness", { title = "Pet Happiness" })
	subpage = owner.frame
	subpage.unavailableText = subpage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	subpage.unavailableText:SetPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.unavailableText:SetJustifyH("LEFT")
	subpage.unavailableText:SetTextColor(OptionsUILib.Theme:GetTextColor("secondary"))
	subpage.unavailableText:SetText("Pet Happiness indicator not available for this frame")
	subpage.unavailableText:Hide()

	subpage.enabledCheckbox = owner:CreateControl("Checkbox", "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(176)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.pet.petHappiness.enabled = enabled
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.happyCheckbox = owner:CreateControl("Checkbox", "Happy")
	subpage.happyCheckbox:SetLayoutWidth(176)
	subpage.happyCheckbox:SetLayoutPoint("TOPLEFT", subpage.enabledCheckbox, "BOTTOMLEFT", 0, -24)
	subpage.happyCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.pet.petHappiness.happy = enabled
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.neutralCheckbox = owner:CreateControl("Checkbox", "Neutral")
	subpage.neutralCheckbox:SetLayoutWidth(176)
	subpage.neutralCheckbox:SetLayoutPoint("TOPLEFT", subpage.happyCheckbox, "TOPRIGHT", 24, 0)
	subpage.neutralCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.pet.petHappiness.neutral = enabled
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.unhappyCheckbox = owner:CreateControl("Checkbox", "Unhappy")
	subpage.unhappyCheckbox:SetLayoutWidth(176)
	subpage.unhappyCheckbox:SetLayoutPoint("TOPLEFT", subpage.neutralCheckbox, "TOPRIGHT", 24, 0)
	subpage.unhappyCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.pet.petHappiness.unhappy = enabled
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.anchorDropdown = owner:CreateControl("Dropdown", "Position")
	subpage.anchorDropdown:SetLayoutWidth(176)
	subpage.anchorDropdown:SetOptions(anchorOptions)
	subpage.anchorDropdown:SetLayoutPoint("TOPLEFT", subpage.happyCheckbox, "BOTTOMLEFT", 0, -24)
	subpage.anchorDropdown:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.pet.petHappiness.anchor = value
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.offsetXSlider = owner:CreateControl("Slider", "Offset X")
	subpage.offsetXSlider:SetLayoutWidth(176)
	subpage.offsetXSlider:SetMinMaxValues(-100, 100)
	subpage.offsetXSlider:SetStep(1)
	subpage.offsetXSlider:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "TOPRIGHT", 24, 0)
	subpage.offsetXSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.pet.petHappiness.position.x = value
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.offsetYSlider = owner:CreateControl("Slider", "Offset Y")
	subpage.offsetYSlider:SetLayoutWidth(176)
	subpage.offsetYSlider:SetMinMaxValues(-100, 100)
	subpage.offsetYSlider:SetStep(1)
	subpage.offsetYSlider:SetLayoutPoint("TOPLEFT", subpage.offsetXSlider, "TOPRIGHT", 24, 0)
	subpage.offsetYSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.pet.petHappiness.position.y = value
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.sizeModeDropdown = owner:CreateControl("Dropdown", "Icon Size")
	subpage.sizeModeDropdown:SetLayoutWidth(176)
	subpage.sizeModeDropdown:SetOptions(sizeModeOptions)
	subpage.sizeModeDropdown:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "BOTTOMLEFT", 0, -24)
	subpage.sizeModeDropdown:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.pet.petHappiness.sizeMode = value
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	subpage.customSizeSlider = owner:CreateControl("Slider", "Custom Size")
	subpage.customSizeSlider:SetLayoutWidth(176)
	subpage.customSizeSlider:SetMinMaxValues(8, 64)
	subpage.customSizeSlider:SetStep(1)
	subpage.customSizeSlider:SetLayoutPoint("TOPLEFT", subpage.sizeModeDropdown, "TOPRIGHT", 24, 0)
	subpage.customSizeSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.pet.petHappiness.customSize = value
		addon.UpdateScheduler:Notify("petHappinessSettingsChanged", "pet")
	end)

	function subpage:UpdateLayout()
		OptionsUILib.Theme:ApplyFont(self.unavailableText, PP:ToUI(14), "")
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

	owner:SetStateUpdater(function(profile, unit)
		subpage:UpdateState(profile, unit)
	end)

	local UpdateLayout = owner.UpdateLayout
	function owner:UpdateLayout()
		UpdateLayout(self)
		subpage:UpdateLayout()
	end

	return owner
end
