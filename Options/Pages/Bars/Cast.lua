local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}
addon.Options.Pages.Bars.Cast = addon.Options.Pages.Bars.Cast or {}

local Cast = addon.Options.Pages.Bars.Cast
local PP = addon.PixelPerfect
local subpage

local availableUnits = {
	player = true,
	pet = true,
	target = true,
	focus = true,
	boss = true,
}

local elementPositionOptions = {
	{ value = "LEFT", text = "Left" },
	{ value = "RIGHT", text = "Right" },
	{ value = "HIDE", text = "Hide" },
}

local positionOptions = {
	{ value = "TOP", text = "Top" },
	{ value = "BOTTOM", text = "Bottom" },
}

function Cast:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)
	subpage.unavailableText = subpage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	subpage.unavailableText:SetPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.unavailableText:SetJustifyH("LEFT")
	subpage.unavailableText:SetTextColor(0.72, 0.74, 0.78, 1)
	subpage.unavailableText:SetText("Cast bar is not available for this frame")
	subpage.unavailableText:Hide()

	subpage.enabledCheckbox = addon.Options.Controls.Checkbox:Create(subpage, "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(178)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.enabled = enabled
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.hideBlizzardCastBarCheckbox = addon.Options.Controls.Checkbox:Create(
		subpage,
		"Hide Blizzard Castbar"
	)
	subpage.hideBlizzardCastBarCheckbox:SetLayoutWidth(178)
	subpage.hideBlizzardCastBarCheckbox:SetLayoutPoint(
		"TOPLEFT",
		subpage.enabledCheckbox,
		"BOTTOMLEFT",
		0,
		-8
	)
	subpage.hideBlizzardCastBarCheckbox:SetOnValueChanged(function(_, hidden)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		if unit ~= "player" then
			return
		end

		local castSettings = addon.Database:GetProfile().frames.player.cast
		castSettings.hideBlizzardCastBar = hidden
		addon.UpdateScheduler:Notify("visibilityChanged", "player")
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
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.texture = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.fontDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Font")
	subpage.fontDropdown:SetLayoutWidth(178)
	subpage.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions(nil, true))
	subpage.fontDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.textureDropdown,
		"TOPRIGHT",
		24,
		0
	)
	subpage.fontDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.font = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.positionDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Bar Position")
	subpage.positionDropdown:SetLayoutWidth(178)
	subpage.positionDropdown:SetOptions(positionOptions)
	subpage.positionDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.textureDropdown,
		"BOTTOMLEFT",
		0,
		-24
	)
	subpage.positionDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.position = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.iconDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Icon Position")
	subpage.iconDropdown:SetLayoutWidth(178)
	subpage.iconDropdown:SetOptions(elementPositionOptions)
	subpage.iconDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.positionDropdown,
		"TOPRIGHT",
		24,
		0
	)
	subpage.iconDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.icon = frameSettings.cast.icon or {}
		frameSettings.cast.icon.position = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.sizeSlider = addon.Options.Controls.Slider:Create(subpage, "Bar Size")
	subpage.sizeSlider:SetLayoutWidth(178)
	subpage.sizeSlider:SetMinMaxValues(1, 50)
	subpage.sizeSlider:SetStep(1)
	subpage.sizeSlider:SetLayoutPoint(
		"TOPLEFT",
		subpage.iconDropdown,
		"TOPRIGHT",
		24,
		0
	)
	subpage.sizeSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.height = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.spellNameDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Spell Name")
	subpage.spellNameDropdown:SetLayoutWidth(178)
	subpage.spellNameDropdown:SetOptions(elementPositionOptions)
	subpage.spellNameDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.positionDropdown,
		"BOTTOMLEFT",
		0,
		-24
	)
	subpage.spellNameDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.spellName = frameSettings.cast.spellName or {}
		frameSettings.cast.spellName.position = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.castTimeDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Cast Time")
	subpage.castTimeDropdown:SetLayoutWidth(178)
	subpage.castTimeDropdown:SetOptions(elementPositionOptions)
	subpage.castTimeDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.spellNameDropdown,
		"TOPRIGHT",
		24,
		0
	)
	subpage.castTimeDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.castTime = frameSettings.cast.castTime or {}
		frameSettings.cast.castTime.position = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.fontSizeSlider = addon.Options.Controls.Slider:Create(subpage, "Font Size")
	subpage.fontSizeSlider:SetLayoutWidth(178)
	subpage.fontSizeSlider:SetMinMaxValues(6, 32)
	subpage.fontSizeSlider:SetStep(1)
	subpage.fontSizeSlider:SetLayoutPoint(
		"TOPLEFT",
		subpage.castTimeDropdown,
		"TOPRIGHT",
		24,
		0
	)
	subpage.fontSizeSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.fontSize = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	function subpage:UpdateLayout()
		self.unavailableText:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(14), "")
	end

	function subpage:UpdateState(profile, unit)
		local available = availableUnits[unit] == true
		self.enabledCheckbox:SetShown(available)
		self.hideBlizzardCastBarCheckbox:SetShown(available and unit == "player")
		self.textureDropdown:SetShown(available)
		self.fontDropdown:SetShown(available)
		self.positionDropdown:SetShown(available)
		self.sizeSlider:SetShown(available)
		self.iconDropdown:SetShown(available)
		self.spellNameDropdown:SetShown(available)
		self.castTimeDropdown:SetShown(available)
		self.fontSizeSlider:SetShown(available)
		self.unavailableText:SetShown(not available)

		if not available then
			return
		end

		local castSettings = profile.frames[unit].cast
		self.enabledCheckbox:SetChecked(not castSettings or castSettings.enabled ~= false)
		if unit == "player" then
			self.hideBlizzardCastBarCheckbox:SetChecked(
				castSettings and castSettings.hideBlizzardCastBar == true
			)
			self.textureDropdown:SetLayoutPoint(
				"TOPLEFT",
				self.hideBlizzardCastBarCheckbox,
				"BOTTOMLEFT",
				0,
				-24
			)
		else
			self.textureDropdown:SetLayoutPoint(
				"TOPLEFT",
				self.enabledCheckbox,
				"BOTTOMLEFT",
				0,
				-24
			)
		end
		local texture = (castSettings and castSettings.texture) or -1
		self.textureDropdown:SetOptions(addon.Style.Textures:GetOptions(texture, true))
		self.textureDropdown:SetValue(texture)
		local font = (castSettings and castSettings.font) or -1
		self.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions(font, true))
		self.fontDropdown:SetValue(font)
		self.positionDropdown:SetValue(
			castSettings and castSettings.position
				or (unit == "focus" and "TOP" or "BOTTOM")
		)
		self.sizeSlider:SetValueSilently(
			(castSettings and castSettings.height)
				or ((unit == "pet" or unit == "focus") and 14 or 20)
		)
		local iconSettings = (castSettings and castSettings.icon) or {}
		self.iconDropdown:SetValue(iconSettings.position or "LEFT")
		local defaultFontSize = (unit == "pet" or unit == "focus") and 8 or 10
		local spellNameSettings = (castSettings and castSettings.spellName) or {}
		self.spellNameDropdown:SetValue(spellNameSettings.position or "LEFT")
		local castTimeSettings = (castSettings and castSettings.castTime) or {}
		self.castTimeDropdown:SetValue(castTimeSettings.position or "RIGHT")
		self.fontSizeSlider:SetValueSilently(
			(castSettings and castSettings.fontSize) or defaultFontSize
		)
	end

	subpage:UpdateLayout()

	return subpage
end
