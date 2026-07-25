local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Auras = addon.Options.Pages.Auras or {}
addon.Options.Pages.Auras.Buffs = addon.Options.Pages.Auras.Buffs or {}

local Buffs = addon.Options.Pages.Auras.Buffs
local PP = addon.PixelPerfect
local subpage

if addon.IsRestrictedAuraAPI then
	function Buffs:Ensure(parent)
		if subpage then
			return subpage
		end

		subpage = CreateFrame("Frame", nil, parent)
		subpage.message = subpage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		subpage.message:SetPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
		subpage.message:SetJustifyH("LEFT")
		subpage.message:SetTextColor(0.72, 0.74, 0.78, 1)
		subpage.message:SetText("Auras for 12.1 will be available soon")

		function subpage:UpdateLayout()
			self.message:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(14), "")
		end

		function subpage:UpdateState()
			self.message:Show()
		end

		subpage:UpdateLayout()

		return subpage
	end

	return
end

local defaults = {
	enabled = false,
	anchor = "TOPRIGHT",
	maxIcons = 4,
	iconsPerRow = 4,
	iconSize = 24,
	spacing = 1,
	showStacks = true,
	stacksFontSize = 10,
	showCooldown = false,
	cooldownFontSize = 10,
	position = { x = 0, y = 1 },
}

local visibilityOptions = {
	{ value = true, text = "Show" },
	{ value = false, text = "Hide" },
}

local anchorOptions = {
	{ value = "TOPRIGHT", text = "Top Right" },
	{ value = "TOPLEFT", text = "Top Left" },
	{ value = "BOTTOMRIGHT", text = "Bottom Right" },
	{ value = "BOTTOMLEFT", text = "Bottom Left" },
}

local bossAnchorOptions = {
	{ value = "LEFT", text = "Left" },
	{ value = "RIGHT", text = "Right" },
}

local function IsAvailableUnit(unit)
	return unit == "player" or unit == "target" or unit == "boss"
end

local function GetSettings(profile, unit, create)
	local frameSettings = profile.frames[unit]
	if create then
		frameSettings.buffs = frameSettings.buffs or {}
		frameSettings.buffs.position = frameSettings.buffs.position or {}
	end

	return frameSettings.buffs
end

local function GetEditableSettings(unit)
	return GetSettings(addon.Database:GetProfile(), unit, true)
end

local function Notify(unit)
	addon.UpdateScheduler:Notify("buffsSettingsChanged", unit)
end

function Buffs:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)
	subpage.unavailableText = subpage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	subpage.unavailableText:SetPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.unavailableText:SetJustifyH("LEFT")
	subpage.unavailableText:SetTextColor(0.72, 0.74, 0.78, 1)
	subpage.unavailableText:SetText("Buffs are not available for this frame")
	subpage.unavailableText:Hide()

	subpage.enabledCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(126)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		GetEditableSettings(unit).enabled = enabled == true
		Notify(unit)
	end)

	subpage.anchorDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Position")
	subpage.anchorDropdown:SetLayoutWidth(126)
	subpage.anchorDropdown:SetOptions(anchorOptions)
	subpage.anchorDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		GetEditableSettings(unit).anchor = value
		Notify(unit)
	end)

	subpage.maxIconsSlider = addon.Options.Controls.Slider:Create(subpage, "Max Icons")
	subpage.maxIconsSlider:SetLayoutWidth(126)
	subpage.maxIconsSlider:SetMinMaxValues(1, 20)
	subpage.maxIconsSlider:SetStep(1)
	subpage.maxIconsSlider:SetLayoutPoint("TOPLEFT", subpage.enabledCheckbox, "BOTTOMLEFT", 0, -16)
	subpage.maxIconsSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		GetEditableSettings(unit).maxIcons = value
		Notify(unit)
	end)

	subpage.iconsPerRowSlider = addon.Options.Controls.Slider:Create(subpage, "Icons Per Row")
	subpage.iconsPerRowSlider:SetLayoutWidth(126)
	subpage.iconsPerRowSlider:SetMinMaxValues(1, 10)
	subpage.iconsPerRowSlider:SetStep(1)
	subpage.iconsPerRowSlider:SetLayoutPoint("TOPLEFT", subpage.maxIconsSlider, "TOPRIGHT", 24, 0)
	subpage.iconsPerRowSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		GetEditableSettings(unit).iconsPerRow = value
		Notify(unit)
	end)

	subpage.spacingSlider = addon.Options.Controls.Slider:Create(subpage, "Spacing")
	subpage.spacingSlider:SetLayoutWidth(126)
	subpage.spacingSlider:SetMinMaxValues(-4, 12)
	subpage.spacingSlider:SetStep(1)
	subpage.spacingSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		GetEditableSettings(unit).spacing = value
		Notify(unit)
	end)

	subpage.offsetXSlider = addon.Options.Controls.Slider:Create(subpage, "Offset X")
	subpage.offsetXSlider:SetLayoutWidth(126)
	subpage.offsetXSlider:SetMinMaxValues(-100, 100)
	subpage.offsetXSlider:SetStep(1)
	subpage.offsetXSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		GetEditableSettings(unit).position.x = value
		Notify(unit)
	end)

	subpage.offsetYSlider = addon.Options.Controls.Slider:Create(subpage, "Offset Y")
	subpage.offsetYSlider:SetLayoutWidth(126)
	subpage.offsetYSlider:SetMinMaxValues(-100, 100)
	subpage.offsetYSlider:SetStep(1)
	subpage.offsetYSlider:SetLayoutPoint("TOPLEFT", subpage.offsetXSlider, "TOPRIGHT", 24, 0)
	subpage.offsetYSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		GetEditableSettings(unit).position.y = value
		Notify(unit)
	end)

	subpage.iconSizeSlider = addon.Options.Controls.Slider:Create(subpage, "Icon Size")
	subpage.iconSizeSlider:SetLayoutWidth(126)
	subpage.iconSizeSlider:SetMinMaxValues(12, 48)
	subpage.iconSizeSlider:SetStep(1)
	subpage.iconSizeSlider:SetLayoutPoint("TOPLEFT", subpage.iconsPerRowSlider, "TOPRIGHT", 24, 0)
	subpage.spacingSlider:SetLayoutPoint("TOPLEFT", subpage.iconSizeSlider, "TOPRIGHT", 24, 0)
	subpage.anchorDropdown:SetLayoutPoint("TOPLEFT", subpage.maxIconsSlider, "BOTTOMLEFT", 0, -16)
	subpage.offsetXSlider:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "TOPRIGHT", 24, 0)
	subpage.iconSizeSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		GetEditableSettings(unit).iconSize = value
		Notify(unit)
	end)

	subpage.showStacksDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Show Stacks")
	subpage.showStacksDropdown:SetLayoutWidth(126)
	subpage.showStacksDropdown:SetOptions(visibilityOptions)
	subpage.showStacksDropdown:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "BOTTOMLEFT", 0, -16)
	subpage.showStacksDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		GetEditableSettings(unit).showStacks = value == true
		Notify(unit)
	end)

	subpage.stacksFontSizeSlider = addon.Options.Controls.Slider:Create(subpage, "Stack Font Size")
	subpage.stacksFontSizeSlider:SetLayoutWidth(126)
	subpage.stacksFontSizeSlider:SetMinMaxValues(6, 20)
	subpage.stacksFontSizeSlider:SetStep(1)
	subpage.stacksFontSizeSlider:SetLayoutPoint("TOPLEFT", subpage.showStacksDropdown, "TOPRIGHT", 24, 0)
	subpage.stacksFontSizeSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		GetEditableSettings(unit).stacksFontSize = value
		Notify(unit)
	end)

	subpage.showCooldownDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Show Cooldown")
	subpage.showCooldownDropdown:SetLayoutWidth(126)
	subpage.showCooldownDropdown:SetOptions(visibilityOptions)
	subpage.showCooldownDropdown:SetLayoutPoint("TOPLEFT", subpage.showStacksDropdown, "BOTTOMLEFT", 0, -16)
	subpage.showCooldownDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		GetEditableSettings(unit).showCooldown = value == true
		Notify(unit)
	end)

	subpage.cooldownFontSizeSlider = addon.Options.Controls.Slider:Create(subpage, "Cooldown Font Size")
	subpage.cooldownFontSizeSlider:SetLayoutWidth(126)
	subpage.cooldownFontSizeSlider:SetMinMaxValues(6, 20)
	subpage.cooldownFontSizeSlider:SetStep(1)
	subpage.cooldownFontSizeSlider:SetLayoutPoint("TOPLEFT", subpage.showCooldownDropdown, "TOPRIGHT", 24, 0)
	subpage.cooldownFontSizeSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		GetEditableSettings(unit).cooldownFontSize = value
		Notify(unit)
	end)

	local controls = {
		subpage.enabledCheckbox,
		subpage.anchorDropdown,
		subpage.maxIconsSlider,
		subpage.iconsPerRowSlider,
		subpage.spacingSlider,
		subpage.offsetXSlider,
		subpage.offsetYSlider,
		subpage.iconSizeSlider,
		subpage.showStacksDropdown,
		subpage.stacksFontSizeSlider,
		subpage.showCooldownDropdown,
		subpage.cooldownFontSizeSlider,
	}

	function subpage:UpdateLayout()
		self.unavailableText:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(14), "")
	end

	function subpage:UpdateState(profile, unit)
		local available = IsAvailableUnit(unit)
		for _, control in ipairs(controls) do
			control:SetShown(available)
		end
		self.unavailableText:SetShown(not available)

		if not available then
			return
		end

		local settings = GetSettings(profile, unit) or defaults
		local position = settings.position or defaults.position
		local isBoss = unit == "boss"
		local anchor = settings.anchor

		if isBoss then
			if anchor ~= "LEFT" and anchor ~= "RIGHT" then
				anchor = "LEFT"
			end
		elseif
			anchor ~= "TOPLEFT"
			and anchor ~= "TOPRIGHT"
			and anchor ~= "BOTTOMLEFT"
			and anchor ~= "BOTTOMRIGHT"
		then
			anchor = defaults.anchor
		end

		self.anchorDropdown:SetOptions(isBoss and bossAnchorOptions or anchorOptions)
		if isBoss then
			self.iconsPerRowSlider:Hide()
			self.iconSizeSlider:SetLayoutPoint("TOPLEFT", self.maxIconsSlider, "TOPRIGHT", 24, 0)
			self.spacingSlider:SetLayoutPoint("TOPLEFT", self.iconSizeSlider, "TOPRIGHT", 24, 0)
		else
			self.iconsPerRowSlider:Show()
			self.iconsPerRowSlider:SetLayoutPoint("TOPLEFT", self.maxIconsSlider, "TOPRIGHT", 24, 0)
			self.iconSizeSlider:SetLayoutPoint("TOPLEFT", self.iconsPerRowSlider, "TOPRIGHT", 24, 0)
			self.spacingSlider:SetLayoutPoint("TOPLEFT", self.iconSizeSlider, "TOPRIGHT", 24, 0)
		end

		self.enabledCheckbox:SetChecked(settings.enabled == true)
		self.anchorDropdown:SetValue(anchor)
		self.maxIconsSlider:SetValueSilently(settings.maxIcons or defaults.maxIcons)
		self.iconsPerRowSlider:SetValueSilently(settings.iconsPerRow or defaults.iconsPerRow)
		self.iconSizeSlider:SetValueSilently(settings.iconSize or defaults.iconSize)
		self.spacingSlider:SetValueSilently(settings.spacing or defaults.spacing)
		self.stacksFontSizeSlider:SetValueSilently(settings.stacksFontSize or defaults.stacksFontSize)
		self.showStacksDropdown:SetValue(settings.showStacks ~= false)
		self.showCooldownDropdown:SetValue(settings.showCooldown == true)
		self.cooldownFontSizeSlider:SetValueSilently(settings.cooldownFontSize or defaults.cooldownFontSize)
		self.offsetXSlider:SetValueSilently(position.x or defaults.position.x)
		self.offsetYSlider:SetValueSilently(position.y or defaults.position.y)
	end

	subpage:UpdateLayout()

	return subpage
end
